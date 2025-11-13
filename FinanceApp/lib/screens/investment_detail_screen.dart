import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/investment.dart';
import '../models/transaction.dart';
import '../providers/investment_provider.dart';
import '../providers/settings_provider.dart';
import '../services/stock_price_service.dart';
import '../services/mutual_fund_nav_service.dart';
import '../utils/calculations.dart';
import '../widgets/investment_chart.dart';
import '../widgets/live_price_widget.dart';
import '../widgets/historical_price_chart.dart';
import 'add_investment_screen.dart';

class InvestmentDetailScreen extends StatefulWidget {
  final String investmentId;

  const InvestmentDetailScreen({super.key, required this.investmentId});

  @override
  State<InvestmentDetailScreen> createState() => _InvestmentDetailScreenState();
}

class _InvestmentDetailScreenState extends State<InvestmentDetailScreen> {
  HistoricalPriceData? _historicalData;
  bool _isLoadingHistory = false;
  String? _historyError;
  String _selectedPeriod = '1y';
  Map<String, double>? _fundPerformance;

  @override
  void initState() {
    super.initState();
    // Fetch historical data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<InvestmentProvider>(context, listen: false);
      final investment = provider.getInvestmentById(widget.investmentId);
      if (investment != null && investment.tickerSymbol != null) {
        _fetchHistoricalPrices(investment.tickerSymbol!, investment);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final currencySymbol = settings.currencySymbol;
    
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
          body: _buildBody(investment, currencySymbol),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddTransactionDialog(context, provider, investment, currencySymbol),
            icon: const Icon(Icons.add),
            label: const Text('Add Transaction'),
          ),
        );
      },
    );
  }

  Widget _buildBody(Investment investment, String currencySymbol) {
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
        // Live Price Widget (for stocks/ETFs) or NAV Widget (for mutual funds)
        if (investment.tickerSymbol != null && 
            investment.tickerSymbol!.isNotEmpty)
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
        // Info card for mutual funds (NAV is fetched from AMFI)
        if (investment.tickerSymbol != null && 
            investment.tickerSymbol!.isNotEmpty &&
            !(investment.tickerSymbol!.contains('.NS') || 
              investment.tickerSymbol!.contains('.AX') ||
              investment.tickerSymbol!.contains('.BSE')))
          Card(
            color: Colors.blue[50],
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(Icons.account_balance, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Mutual Fund: NAV is fetched from AMFI India (updated daily after market close).',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[900],
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
                        currencySymbol,
                      ),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Update Value'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildMetricRow('Total Invested (Buy)',
                    FinancialCalculations.formatCurrency(investment.totalInvested, symbol: currencySymbol)),
                const SizedBox(height: 8),
                _buildMetricRow('Total Withdrawn (Sell)',
                    FinancialCalculations.formatCurrency(investment.totalWithdrawn, symbol: currencySymbol)),
                const SizedBox(height: 8),
                _buildMetricRow('Net Invested',
                    FinancialCalculations.formatCurrency(investment.netInvested, symbol: currencySymbol),
                    color: Colors.blue),
                const Divider(height: 24),
                _buildMetricRow('Current Market Value',
                    FinancialCalculations.formatCurrency(investment.effectiveCurrentValue, symbol: currencySymbol),
                    color: Colors.green),
                const SizedBox(height: 8),
                _buildMetricRow(
                  'Profit/Loss',
                  FinancialCalculations.formatCurrency(investment.profitLoss, symbol: currencySymbol),
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
                      FinancialCalculations.formatCurrency(investment.averagePricePerUnit!, symbol: currencySymbol),
                    ),
                  const SizedBox(height: 8),
                  if (investment.currentPricePerUnit != null)
                    _buildMetricRow(
                      'Current Price/Unit',
                      FinancialCalculations.formatCurrency(investment.currentPricePerUnit!, symbol: currencySymbol),
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
        // Historical Price/NAV Chart
        if (investment.tickerSymbol != null) ...[
          Text(
            'Historical Price Chart',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _isLoadingHistory
                  ? const SizedBox(
                      height: 250,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : _historyError != null
                      ? SizedBox(
                          height: 250,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 48,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _historyError!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.red),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () => _fetchHistoricalPrices(investment.tickerSymbol!, investment),
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : _historicalData != null
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Period selector
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      for (var period in ['1mo', '3mo', '6mo', '1y', '2y', '5y'])
                                        Padding(
                                          padding: const EdgeInsets.only(right: 8),
                                          child: ChoiceChip(
                                            label: Text(period.toUpperCase()),
                                            selected: _selectedPeriod == period,
                                            onSelected: (selected) {
                                              if (selected) {
                                                setState(() {
                                                  _selectedPeriod = period;
                                                });
                                                _fetchHistoricalPrices(investment.tickerSymbol!, investment);
                                              }
                                            },
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                HistoricalPriceChart(data: _historicalData!),
                              ],
                            )
                          : const SizedBox(
                              height: 250,
                              child: Center(
                                child: Text('No historical data available'),
                              ),
                            ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        // Fund Performance Metrics
        if (_fundPerformance != null && _fundPerformance!.isNotEmpty) ...[
          Text(
            'Fund Performance',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Returns',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  ..._fundPerformance!.entries.map((entry) {
                    final isPositive = entry.value >= 0;
                    final color = isPositive ? Colors.green : Colors.red;
                    final icon = isPositive ? Icons.arrow_upward : Icons.arrow_downward;
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            entry.key,
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(icon, size: 16, color: color),
                              const SizedBox(width: 4),
                              Text(
                                '${isPositive ? '+' : ''}${entry.value.toStringAsFixed(2)}%',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
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
            return _buildTransactionCard(transaction, currencySymbol);
          }),
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

  Widget _buildTransactionCard(Transaction transaction, String currencySymbol) {
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
                'Qty: ${transaction.quantity!.toStringAsFixed(2)} @ ${FinancialCalculations.formatCurrency(transaction.pricePerUnit!, symbol: currencySymbol)} per unit',
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
              FinancialCalculations.formatCurrency(transaction.amount.abs(), symbol: currencySymbol),
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
    String currencySymbol,
  ) {
    final amountController = TextEditingController();
    final quantityController = TextEditingController();
    final notesController = TextEditingController();
    final currentValueController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    String transactionType = 'buy';
    bool isLoadingSuggestion = false;

    // Function to fetch and suggest current value based on transaction date
    Future<void> fetchAndSuggestValue(StateSetter dialogSetState, DateTime transactionDate) async {
      if (investment.tickerSymbol == null || investment.tickerSymbol!.isEmpty) {
        return; // Can't fetch without ticker symbol
      }

      if (investment.totalQuantity <= 0) {
        return; // Need quantity to calculate value
      }

      // Check if this is a mutual fund
      final isMutualFund = !(investment.tickerSymbol!.contains('.NS') || 
                              investment.tickerSymbol!.contains('.AX') ||
                              investment.tickerSymbol!.contains('.BSE'));

      dialogSetState(() {
        isLoadingSuggestion = true;
      });

      try {
        final now = DateTime.now();
        final daysDifference = now.difference(transactionDate).inDays;
        
        double? priceOnDate;
        
        if (isMutualFund) {
          // Fetch NAV for mutual fund
          if (daysDifference <= 0) {
            // Today or future - use latest NAV
            final navData = await MutualFundNavService.fetchLatestNavBySymbol(investment.tickerSymbol!);
            priceOnDate = navData?.nav;
          } else {
            // Historical date - fetch NAV for that date
            final navData = await MutualFundNavService.fetchNavForDateBySymbol(
              investment.tickerSymbol!,
              transactionDate,
            );
            priceOnDate = navData?.nav;
          }
        } else if (daysDifference <= 0) {
          // Transaction is today or future - use current price
          final priceData = await StockPriceService.fetchPrice(investment.tickerSymbol!);
          priceOnDate = priceData?.currentPrice;
        } else {
          // Transaction is in the past - fetch historical price
          // Determine appropriate period based on how far back
          String period;
          if (daysDifference <= 30) {
            period = '1mo';
          } else if (daysDifference <= 90) {
            period = '3mo';
          } else if (daysDifference <= 180) {
            period = '6mo';
          } else if (daysDifference <= 365) {
            period = '1y';
          } else if (daysDifference <= 730) {
            period = '2y';
          } else if (daysDifference <= 1825) {
            period = '5y';
          } else {
            period = 'max';
          }
          
          final historicalData = await StockPriceService.fetchHistoricalPrices(
            investment.tickerSymbol!,
            period: period,
          );
          
          if (historicalData != null && historicalData.prices.isNotEmpty) {
            // Find the closest date to transaction date
            HistoricalPrice? closestPrice;
            int minDaysDiff = 999999;
            
            for (var price in historicalData.prices) {
              final diff = (price.date.difference(transactionDate).inDays).abs();
              if (diff < minDaysDiff) {
                minDaysDiff = diff;
                closestPrice = price;
              }
            }
            
            priceOnDate = closestPrice?.close;
          }
        }
        
        if (priceOnDate != null && investment.totalQuantity > 0) {
          // Calculate suggested value: price on transaction date * total quantity
          final suggestedValue = priceOnDate * investment.totalQuantity;
          currentValueController.text = suggestedValue.toStringAsFixed(2);
        }
      } catch (e) {
        // Silently fail - user can still enter manually
        debugPrint('Failed to fetch price suggestion: $e');
      } finally {
        dialogSetState(() {
          isLoadingSuggestion = false;
        });
      }
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          // Auto-fetch suggestion when dialog opens (only once)
          if (currentValueController.text.isEmpty && 
              investment.tickerSymbol != null && 
              investment.tickerSymbol!.isNotEmpty &&
              !isLoadingSuggestion) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              fetchAndSuggestValue(setState, selectedDate);
            });
          }
          
          return AlertDialog(
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
                      // Re-fetch suggestion with new date if ticker is available
                      if (investment.tickerSymbol != null && investment.tickerSymbol!.isNotEmpty) {
                        fetchAndSuggestValue(setState, picked);
                      }
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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        investment.tickerSymbol != null && 
                        investment.tickerSymbol!.isNotEmpty &&
                        (investment.tickerSymbol!.contains('.NS') || 
                         investment.tickerSymbol!.contains('.AX') ||
                         investment.tickerSymbol!.contains('.BSE'))
                            ? 'Auto-suggested based on price on ${DateFormat('dd MMM yyyy').format(selectedDate)}. You can edit if needed.'
                            : investment.tickerSymbol != null && investment.tickerSymbol!.isNotEmpty
                            ? 'Auto-suggested based on NAV from AMFI on ${DateFormat('dd MMM yyyy').format(selectedDate)}. You can edit if needed.'
                            : 'Enter total portfolio value. Optional if you entered quantity above.',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 12,
                        ),
                      ),
                    ),
                    if (investment.tickerSymbol != null && 
                        investment.tickerSymbol!.isNotEmpty)
                      IconButton(
                        icon: isLoadingSuggestion 
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.refresh, size: 20),
                        tooltip: 'Refresh suggested value',
                        onPressed: isLoadingSuggestion ? null : () => fetchAndSuggestValue(setState, selectedDate),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: currentValueController,
                  decoration: InputDecoration(
                    labelText: 'Current Total Market Value (Optional)',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.trending_up),
                    hintText: 'Total value of investment today',
                    suffixIcon: isLoadingSuggestion
                        ? const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : null,
                  ),
                  keyboardType: TextInputType.number,
                  enabled: !isLoadingSuggestion,
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
                        'Transaction added and value updated to ${FinancialCalculations.formatCurrency(finalCurrentValue, symbol: currencySymbol)}',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
          );
        },
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
    String currencySymbol,
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
                'Net Invested: ${FinancialCalculations.formatCurrency(investment.netInvested, symbol: currencySymbol)}',
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
                        'Current value updated to ${FinancialCalculations.formatCurrency(value, symbol: currencySymbol)}',
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

  Future<void> _fetchHistoricalPrices(String symbol, Investment investment) async {
    setState(() {
      _isLoadingHistory = true;
      _historyError = null;
    });

    try {
      // Check if it's a mutual fund (no .NS, .AX, .BSE suffix)
      final isMutualFund = !symbol.contains('.NS') && 
                          !symbol.contains('.AX') && 
                          !symbol.contains('.BSE');

      if (isMutualFund) {
        print('Fetching historical NAV for mutual fund: $symbol');
        
        final days = _getPeriodDays(_selectedPeriod);
        final navList = await MutualFundNavService.fetchHistoricalNavBySymbol(symbol, limitDays: days);

        if (navList.isNotEmpty) {
          print('Retrieved ${navList.length} NAV records');
          
          // Convert MutualFundNav to HistoricalPrice
          final historicalPrices = navList.map((nav) {
            return HistoricalPrice(
              date: nav.date,
              close: nav.nav,
            );
          }).toList();

          // Sort by date ascending
          historicalPrices.sort((a, b) => a.date.compareTo(b.date));

          // Calculate fund performance metrics (both NAV-based CAGR and transaction-based XIRR)
          final performance = _calculateFundPerformance(historicalPrices, investment);

          setState(() {
            _historicalData = HistoricalPriceData(
              prices: historicalPrices,
              symbol: symbol,
              period: _selectedPeriod,
            );
            _fundPerformance = performance;
            _isLoadingHistory = false;
          });
        } else {
          setState(() {
            _historyError = 'No historical NAV data available';
            _isLoadingHistory = false;
          });
        }
      } else {
        // For stocks, use Yahoo Finance
        print('Fetching historical prices for stock: $symbol');
        
        final data = await StockPriceService.fetchHistoricalPrices(symbol, period: _selectedPeriod);

        if (data != null) {
          setState(() {
            _historicalData = data;
            _fundPerformance = _calculateFundPerformance(data.prices, investment);
            _isLoadingHistory = false;
          });
        } else {
          setState(() {
            _historyError = 'Unable to fetch historical data';
            _isLoadingHistory = false;
          });
        }
      }
    } catch (e) {
      print('Error fetching historical prices: $e');
      setState(() {
        _historyError = 'Error: ${e.toString()}';
        _isLoadingHistory = false;
      });
    }
  }

  int _getPeriodDays(String period) {
    switch (period) {
      case '1mo':
        return 30;
      case '3mo':
        return 90;
      case '6mo':
        return 180;
      case '1y':
        return 365;
      case '2y':
        return 730;
      case '5y':
        return 1825;
      default:
        return 365;
    }
  }

  Map<String, double> _calculateFundPerformance(List<HistoricalPrice> prices, Investment investment) {
    if (prices.isEmpty) return {};

    final performance = <String, double>{};
    final latestPrice = prices.last.close;
    final latestDate = prices.last.date;

    // Calculate XIRR based on actual transactions (investor's actual return)
    if (investment.transactions.isNotEmpty) {
      final xirr = FinancialCalculations.calculateXIRR(
        investment.transactions,
        currentValue: investment.effectiveCurrentValue,
      );
      if (xirr != null) {
        performance['XIRR (Your Return)'] = xirr;
      }
    }

    // Calculate returns for different periods
    // For periods >= 1 year, use annualized returns (CAGR)
    // For periods < 1 year, use absolute returns
    final periods = {
      '1 Month': 30,
      '3 Months': 90,
      '6 Months': 180,
      '1 Year': 365,
      '2 Years': 730,
      '3 Years': 1095,
      '5 Years': 1825,
    };
    
    for (var entry in periods.entries) {
      final periodName = entry.key;
      final daysAgo = entry.value;
      final targetDate = latestDate.subtract(Duration(days: daysAgo));

      // Find the closest price to target date
      HistoricalPrice? closestPrice;
      Duration? minDifference;

      for (var price in prices) {
        final difference = price.date.difference(targetDate).abs();
        if (minDifference == null || difference < minDifference) {
          minDifference = difference;
          closestPrice = price;
        }
      }

      if (closestPrice != null && closestPrice.close > 0) {
        // Calculate actual days between the dates
        final actualDays = latestDate.difference(closestPrice.date).inDays;
        
        if (actualDays < 30) {
          // Not enough data for this period
          continue;
        }
        
        // For periods >= 1 year, calculate annualized return (CAGR)
        // For periods < 1 year, calculate absolute return
        if (daysAgo >= 365) {
          final years = actualDays / 365.0;
          final cagr = (pow(latestPrice / closestPrice.close, 1 / years) - 1) * 100;
          performance[periodName] = cagr.toDouble();
        } else {
          // Simple return for periods less than 1 year
          final returnPercent = ((latestPrice - closestPrice.close) / closestPrice.close) * 100;
          performance[periodName] = returnPercent;
        }
      }
    }

    // Calculate YoY (Year-over-Year) return
    if (performance.containsKey('1 Year')) {
      performance['YoY Return'] = performance['1 Year']!;
    }

    // Calculate CAGR since the earliest available data (NAV-based, assumes lump-sum investment)
    if (prices.length > 1) {
      final firstPrice = prices.first.close;
      final firstDate = prices.first.date;
      final daysDiff = latestDate.difference(firstDate).inDays;
      
      if (daysDiff >= 365 && firstPrice > 0) {
        final years = daysDiff / 365.0;
        final cagr = (pow(latestPrice / firstPrice, 1 / years) - 1) * 100;
        performance['CAGR (NAV Growth)'] = cagr.toDouble();
      } else if (daysDiff > 0 && firstPrice > 0) {
        // If less than a year, show absolute return
        final absoluteReturn = ((latestPrice - firstPrice) / firstPrice) * 100;
        performance['Total Return (NAV)'] = absoluteReturn;
      }
    }

    // Calculate volatility (standard deviation of daily returns)
    if (prices.length > 1) {
      final returns = <double>[];
      for (int i = 1; i < prices.length; i++) {
        final dailyReturn = (prices[i].close - prices[i - 1].close) / prices[i - 1].close;
        returns.add(dailyReturn);
      }

      if (returns.isNotEmpty) {
        final mean = returns.reduce((a, b) => a + b) / returns.length;
        final variance = returns.map((r) => pow(r - mean, 2)).reduce((a, b) => a + b) / returns.length;
        final stdDev = sqrt(variance);
        final annualizedVolatility = stdDev * sqrt(252) * 100; // Annualized volatility in percentage
        performance['Volatility (Annual)'] = annualizedVolatility;
      }
    }

    return performance;
  }
}
