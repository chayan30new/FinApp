import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/investment.dart';
import '../models/transaction.dart';
import '../providers/investment_provider.dart';

class AddInvestmentScreen extends StatefulWidget {
  final Investment? investment;

  const AddInvestmentScreen({super.key, this.investment});

  @override
  State<AddInvestmentScreen> createState() => _AddInvestmentScreenState();
}

class _AddInvestmentScreenState extends State<AddInvestmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _quantityController = TextEditingController();
  final _tickerController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.investment != null) {
      _nameController.text = widget.investment!.name;
      _descriptionController.text = widget.investment!.description ?? '';
      _tickerController.text = widget.investment!.tickerSymbol ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _quantityController.dispose();
    _tickerController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveInvestment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<InvestmentProvider>(context, listen: false);

      final investment = Investment(
        id: widget.investment?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        transactions: widget.investment?.transactions ?? [],
        createdAt: widget.investment?.createdAt ?? DateTime.now(),
        tickerSymbol: _tickerController.text.isEmpty
            ? null
            : _tickerController.text.toUpperCase(),
      );

      if (widget.investment == null) {
        // New investment - add initial transaction
        final initialAmount = double.parse(_amountController.text);
        
        // Parse quantity (optional)
        double? quantity;
        if (_quantityController.text.isNotEmpty) {
          quantity = double.tryParse(_quantityController.text);
        }
        
        final transaction = Transaction(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          date: _selectedDate,
          amount: initialAmount,
          type: 'buy',
          quantity: quantity,
          notes: 'Initial investment',
        );

        await provider.addInvestment(investment);
        await provider.addTransaction(investment.id, transaction);
        
        // Set initial current value with date
        final investmentWithValue = investment.copyWith(
          currentValue: initialAmount,
          currentValueDate: _selectedDate,
        );
        await provider.updateInvestment(investmentWithValue);
      } else {
        await provider.updateInvestment(investment);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.investment != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Investment' : 'Add Investment'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Investment Name',
                hintText: 'e.g., Mutual Fund XYZ',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.account_balance_wallet),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter investment name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'e.g., Large cap equity fund',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _tickerController,
              decoration: const InputDecoration(
                labelText: 'Ticker Symbol (Optional)',
                hintText: 'e.g., VAS.AX for Australian stocks',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.show_chart),
                helperText: 'Add .AX suffix for ASX stocks (e.g., CBA.AX, BHP.AX)',
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            if (!isEdit) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Initial Amount',
                  hintText: 'e.g., 10000',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter initial amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Amount must be greater than 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Initial Quantity (Optional)',
                  hintText: 'e.g., 100 (shares/units)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.shopping_basket),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    if (double.parse(value) <= 0) {
                      return 'Quantity must be greater than 0';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Investment Date'),
                subtitle: Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                ),
                leading: const Icon(Icons.calendar_today),
                trailing: const Icon(Icons.edit),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                  side: BorderSide(color: Colors.grey[400]!),
                ),
                onTap: () => _selectDate(context),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveInvestment,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(isEdit ? 'Update Investment' : 'Add Investment'),
            ),
          ],
        ),
      ),
    );
  }
}
