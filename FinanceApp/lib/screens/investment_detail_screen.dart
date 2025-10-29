import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/investment.dart';
import '../models/transaction.dart';
import '../providers/investment_provider.dart';
import '../utils/calculations.dart';
import '../widgets/investment_chart.dart';
import '../widgets/live_price_widget.dart';
import 'add_investment_screen.dart';

class InvestmentDetailScreen extends StatefulWidget {
  final String investmentId;

  const InvestmentDetailScreen({super.key, required this.investmentId});

  @override
  State<InvestmentDetailScreen> createState() => _InvestmentDetailScreenState();
}

class _InvestmentDetailScreenState extends State<InvestmentDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<InvestmentProvider>(
      builder: (context, provider, child) {
        final investment = provider.getInvestmentById(widget.investmentId);

        if (investment == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Investment Details')),
            body: const Center(child: Text('Investment not found')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(investment.name),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AddInvestmentScreen(investment: investment),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _confirmDelete(context, provider, investment.id),
              ),
            ],
          ),
          body: _buildBody(investment),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddTransactionDialog(context, provider, investment),
            icon: const Icon(Icons.add),
            label: const Text('Add Transaction'),
          ),
        );
      },
    );
  }

  Widget _buildBody(Investment investment) {
    final xirr = FinancialCalculations.calculateXIRR(
      investment.transactions,
      currentValue: investment.effectiveCurrentValue,
    );

    final cagr = investment.transactions.isNotEmpty && investment.netInvested > 0
        ? FinancialCalculations.calculateCAGR(
            initialInvestment: investment.netInvested,
            currentValue: investment.effectiveCurrentValue,
            startDate: investment.transactions.first.date,
          )
        : null;

    final absoluteReturn = FinancialCalculations.calculateAbsoluteReturn(
      invested: investment.netInvested,
      currentValue: investment.effectiveCurrentValue,
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Live Price Widget (if ticker symbol is set)
        if (investment.tickerSymbol != null && investment.tickerSymbol!.isNotEmpty)
          LivePriceWidget(
            investment: investment,
            onPriceUpdate: (newValue) async {
              final provider = Provider.of<InvestmentProvider>(context, listen: false);
              await provider.updateInvestmentValue(
                investment.id,
                newValue,
                DateTime.now(),
              );
            },
          ),
        // Performance Card
        Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Performance',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    TextButton.icon(
                      onPressed: () => _showUpdateValueDialog(
                        context,
                        Provider.of<InvestmentProvider>(context, listen: false),
                        investment,
                      ),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Update Value'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildMetricRow('Total Invested (Buy)',
                    FinancialCalculations.formatCurrency(investment.totalInvested)),
                const SizedBox(height: 8),
                _buildMetricRow('Total Withdrawn (Sell)',
                    FinancialCalculations.formatCurrency(investment.totalWithdrawn)),
                const SizedBox(height: 8),
                _buildMetricRow('Net Invested',
                    FinancialCalculations.formatCurrency(investment.netInvested),
                    color: Colors.blue),
                const Divider(height: 24),
                _buildMetricRow('Current Market Value',
                    FinancialCalculations.formatCurrency(investment.effectiveCurrentValue),
                    color: Colors.green),
                const SizedBox(height: 8),
                _buildMetricRow(
                  'Profit/Loss',
                  FinancialCalculations.formatCurrency(investment.profitLoss),
                  color: investment.profitLoss >= 0 ? Colors.green : Colors.red,
                ),
                const SizedBox(height: 8),
                _buildMetricRow(
                  'Absolute Return',
                  FinancialCalculations.formatPercentage(absoluteReturn),
                  color: absoluteReturn >= 0 ? Colors.green : Colors.red,
                ),
                const Divider(height: 24),
                _buildMetricRow(
                  'XIRR (Annualized)',
                  FinancialCalculations.formatPercentage(xirr),
                  color: (xirr ?? 0) >= 0 ? Colors.green : Colors.red,
                ),
                const SizedBox(height: 8),
                _buildMetricRow(
                  'CAGR',
                  FinancialCalculations.formatPercentage(cagr),
                  color: (cagr ?? 0) >= 0 ? Colors.green : Colors.red,
                ),
                // Add quantity information if available
                if (investment.totalQuantity > 0) ...[
                  const Divider(height: 24),
                  Text(
                    'Portfolio Details',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                  ),
                  const SizedBox(height: 8),
                  _buildMetricRow(
                    'Total Quantity',
                    investment.totalQuantity.toStringAsFixed(2),
                  ),
                  const SizedBox(height: 8),
                  if (investment.averagePricePerUnit != null)
                    _buildMetricRow(
                      'Average Price/Unit',
                      FinancialCalculations.formatCurrency(investment.averagePricePerUnit!),
                    ),
                  const SizedBox(height: 8),
                  if (investment.currentPricePerUnit != null)
                    _buildMetricRow(
                      'Current Price/Unit',
                      FinancialCalculations.formatCurrency(investment.currentPricePerUnit!),
                      color: Colors.green,
                    ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Investment Growth Chart
        InvestmentChart(investment: investment),
        const SizedBox(height: 16),
        // Transactions
        Text(
          'Transactions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        if (investment.transactions.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text('No transactions yet'),
              ),
            ),
          )
        else
          ...investment.transactions.map((transaction) {
            return _buildTransactionCard(transaction);
          }).toList(),
        // Add bottom padding so FAB doesn't cover last transaction
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildMetricRow(String label, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color ?? Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionCard(Transaction transaction) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final isBuy = transaction.type == 'buy';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isBuy ? Colors.red[100] : Colors.green[100],
          child: Icon(
            isBuy ? Icons.arrow_downward : Icons.arrow_upward,
            color: isBuy ? Colors.red : Colors.green,
          ),
        ),
        title: Text(
          isBuy ? 'Investment' : 'Withdrawal',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dateFormat.format(transaction.date)),
            if (transaction.quantity != null)
              Text(
                'Qty: ${transaction.quantity!.toStringAsFixed(2)} @ ${FinancialCalculations.formatCurrency(transaction.pricePerUnit!)} per unit',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            if (transaction.notes != null) 
              Text(
                transaction.notes!,
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              FinancialCalculations.formatCurrency(transaction.amount.abs()),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isBuy ? Colors.red : Colors.green,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () => _showEditTransactionDialog(
                context,
                Provider.of<InvestmentProvider>(context, listen: false),
                transaction,
              ),
              tooltip: 'Edit transaction',
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20),
              onPressed: () => _confirmDeleteTransaction(
                context,
                Provider.of<InvestmentProvider>(context, listen: false),
                transaction.id,
              ),
              tooltip: 'Delete transaction',
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTransactionDialog(
    BuildContext context,
    InvestmentProvider provider,
    Investment investment,
  ) {
    final amountController = TextEditingController();
    final quantityController = TextEditingController();
    final notesController = TextEditingController();
    final currentValueController = TextEditingController(); // Don't pre-fill - let user decide
    DateTime selectedDate = DateTime.now();
    String transactionType = 'buy';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Transaction'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'buy', label: Text('Buy (Invest More)')),
                    ButtonSegment(value: 'sell', label: Text('Sell (Withdraw)')),
                  ],
                  selected: {transactionType},
                  onSelectionChanged: (Set<String> newSelection) {
                    setState(() {
                      transactionType = newSelection.first;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: 'Transaction Amount',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.attach_money),
                    hintText: 'Amount invested or withdrawn',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: quantityController,
                  decoration: const InputDecoration(
                    labelText: 'Quantity (Optional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.shopping_basket),
                    hintText: 'Number of units/shares',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Date'),
                  subtitle: Text(
                    DateFormat('dd MMM yyyy').format(selectedDate),
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.info_outline, size: 20, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Current Market Value (Optional if quantity provided)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter total portfolio value. Optional if you entered quantity above.',
                  style: TextStyle(color: Colors.grey[700], fontSize: 12),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: currentValueController,
                  decoration: const InputDecoration(
                    labelText: 'Current Total Market Value (Optional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.trending_up),
                    hintText: 'Total value of investment today',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (amountController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter transaction amount'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                final amount = double.tryParse(amountController.text);
                if (amount == null || amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid transaction amount'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                // Parse quantity (optional)
                double? quantity;
                if (quantityController.text.isNotEmpty) {
                  quantity = double.tryParse(quantityController.text);
                  if (quantity == null || quantity <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a valid quantity'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }
                }

                // Parse current value (optional if quantity provided)
                double? currentValue;
                if (currentValueController.text.isNotEmpty) {
                  currentValue = double.tryParse(currentValueController.text);
                  if (currentValue == null || currentValue < 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a valid current market value'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }
                } else if (quantity == null) {
                  // If no current value and no quantity, require current value
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter either current market value or quantity'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                final transaction = Transaction(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  date: selectedDate,
                  amount: amount,
                  type: transactionType,
                  quantity: quantity,
                  notes: notesController.text.isEmpty
                      ? null
                      : notesController.text,
                );

                await provider.addTransaction(investment.id, transaction);
                
                // Reload to get updated investment with new transaction
                await provider.loadInvestments();
                final updatedInv = provider.getInvestmentById(investment.id);
                
                if (updatedInv == null) {
                  if (context.mounted) Navigator.pop(context);
                  return;
                }
                
                // Calculate and update current value
                double finalCurrentValue;
                if (currentValue != null) {
                  // Use provided current value
                  finalCurrentValue = currentValue;
                } else if (quantity != null) {
                  // Calculate based on quantity and current price per unit
                  // Use the transaction's price to calculate total value
                  final pricePerUnit = amount / quantity;
                  finalCurrentValue = updatedInv.totalQuantity * pricePerUnit;
                } else {
                  // Fallback - shouldn't happen due to validation
                  finalCurrentValue = updatedInv.effectiveCurrentValue;
                }

                // Update current value with the transaction date
                final finalInvestment = updatedInv.copyWith(
                  currentValue: finalCurrentValue,
                  currentValueDate: selectedDate,
                );
                await provider.updateInvestment(finalInvestment);

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Transaction added and value updated to ${FinancialCalculations.formatCurrency(finalCurrentValue)}',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    InvestmentProvider provider,
    String id,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Investment'),
        content: const Text('Are you sure you want to delete this investment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await provider.deleteInvestment(id);
              if (context.mounted) {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to home
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteTransaction(
    BuildContext context,
    InvestmentProvider provider,
    String transactionId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text('Are you sure you want to delete this transaction?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await provider.deleteTransaction(transactionId);
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showEditTransactionDialog(
    BuildContext context,
    InvestmentProvider provider,
    Transaction transaction,
  ) {
    final amountController = TextEditingController(
      text: transaction.amount.abs().toString(),
    );
    final quantityController = TextEditingController(
      text: transaction.quantity?.toString() ?? '',
    );
    final notesController = TextEditingController(
      text: transaction.notes ?? '',
    );
    DateTime selectedDate = transaction.date;
    String transactionType = transaction.type;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Transaction'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'buy', label: Text('Buy (Invest More)')),
                    ButtonSegment(value: 'sell', label: Text('Sell (Withdraw)')),
                  ],
                  selected: {transactionType},
                  onSelectionChanged: (Set<String> newSelection) {
                    setState(() {
                      transactionType = newSelection.first;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: quantityController,
                  decoration: const InputDecoration(
                    labelText: 'Quantity (Optional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.shopping_basket),
                    hintText: 'Number of units/shares',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Date'),
                  subtitle: Text(
                    DateFormat('dd MMM yyyy').format(selectedDate),
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (amountController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter an amount'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                final amount = double.tryParse(amountController.text);
                if (amount == null || amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid amount'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                // Parse quantity (optional)
                double? quantity;
                if (quantityController.text.isNotEmpty) {
                  quantity = double.tryParse(quantityController.text);
                  if (quantity == null || quantity <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a valid quantity'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }
                }

                final updatedTransaction = Transaction(
                  id: transaction.id,
                  date: selectedDate,
                  amount: amount,
                  type: transactionType,
                  quantity: quantity,
                  notes: notesController.text.isEmpty
                      ? null
                      : notesController.text,
                );

                await provider.updateTransaction(updatedTransaction);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Transaction updated successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateValueDialog(
    BuildContext context,
    InvestmentProvider provider,
    Investment investment,
  ) {
    final valueController = TextEditingController(
      text: investment.currentValue?.toString() ?? '',
    );
    
    // Find the latest date we should allow updates for
    DateTime? latestDate = investment.currentValueDate;
    
    // Also check the latest transaction date
    if (investment.transactions.isNotEmpty) {
      final latestTransactionDate = investment.transactions
          .map((t) => t.date)
          .reduce((a, b) => a.isAfter(b) ? a : b);
      
      if (latestDate == null || latestTransactionDate.isAfter(latestDate)) {
        latestDate = latestTransactionDate;
      }
    }
    
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Update Current Market Value'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter the current market value of this investment.',
                style: TextStyle(color: Colors.grey[700], fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                'Net Invested: ${FinancialCalculations.formatCurrency(investment.netInvested)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (latestDate != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Latest update: ${DateFormat('MMM dd, yyyy').format(latestDate)}',
                  style: TextStyle(color: Colors.blue[700], fontSize: 12),
                ),
              ],
              const SizedBox(height: 16),
              TextField(
                controller: valueController,
                decoration: const InputDecoration(
                  labelText: 'Current Market Value',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                  hintText: 'e.g., 12500',
                ),
                keyboardType: TextInputType.number,
                autofocus: true,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: latestDate ?? DateTime(2000),
                    lastDate: DateTime.now(),
                    helpText: 'Select value update date',
                  );
                  if (picked != null) {
                    setState(() {
                      selectedDate = picked;
                    });
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Value Date',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    DateFormat('MMM dd, yyyy').format(selectedDate),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tip: Check your investment app/statement for the latest value',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final value = double.tryParse(valueController.text);
                if (value == null || value < 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid positive number'),
                    ),
                  );
                  return;
                }
                
                // Validate that the selected date is not before the latest date
                if (latestDate != null && selectedDate.isBefore(latestDate)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Update date cannot be before ${DateFormat('MMM dd, yyyy').format(latestDate)}',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final updatedInvestment = investment.copyWith(
                  currentValue: value,
                  currentValueDate: selectedDate,
                );

                await provider.updateInvestment(updatedInvestment);

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Current value updated to ${FinancialCalculations.formatCurrency(value)}',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }
}
