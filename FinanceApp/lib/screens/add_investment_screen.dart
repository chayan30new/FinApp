import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/investment.dart';
import '../models/transaction.dart';
import '../providers/investment_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/stock_symbols_provider.dart';
import '../services/mutual_fund_nav_service.dart';

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
  bool _isCalculatingQuantity = false;
  String? _navCalculationMessage;
  bool _quantityWasAutoCalculated = false;
  bool _isSettingQuantityProgrammatically = false;

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
      // Auto-calculate quantity if conditions are met
      _autoCalculateQuantityForMutualFund();
    }
  }

  /// Auto-calculate quantity for mutual funds based on amount and NAV on investment date
  Future<void> _autoCalculateQuantityForMutualFund() async {
    // Only auto-calculate if:
    // 1. Ticker symbol is provided
    // 2. Amount is provided
    // 3. It's a mutual fund (not a stock)
    // 4. Quantity field is empty OR was previously auto-calculated (not manually entered)
    
    final ticker = _tickerController.text.trim().toUpperCase();
    if (ticker.isEmpty || _amountController.text.isEmpty) {
      return;
    }
    
    // Check if it's a mutual fund (not a stock with .NS or .AX suffix)
    if (ticker.endsWith('.NS') || ticker.endsWith('.AX')) {
      return; // It's a stock, not a mutual fund
    }
    
    // Don't override if user manually entered quantity (only recalculate if it was auto-calculated before)
    if (_quantityController.text.isNotEmpty && !_quantityWasAutoCalculated) {
      return;
    }
    
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      return;
    }
    
    setState(() {
      _isCalculatingQuantity = true;
      _navCalculationMessage = 'Fetching NAV for ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}...';
    });
    
    try {
      // Fetch NAV for the investment date
      final navData = await MutualFundNavService.fetchNavForDateBySymbol(
        ticker,
        _selectedDate,
      );
      
      if (navData != null && navData.nav > 0) {
        // Calculate quantity = amount / NAV
        final quantity = amount / navData.nav;
        
        setState(() {
          _isSettingQuantityProgrammatically = true;
          _quantityController.text = quantity.toStringAsFixed(4);
          _navCalculationMessage = 
            '✓ Auto-calculated: ₹${amount.toStringAsFixed(2)} ÷ NAV ₹${navData.nav.toStringAsFixed(2)} = ${quantity.toStringAsFixed(4)} units';
          _isCalculatingQuantity = false;
          _quantityWasAutoCalculated = true; // Mark as auto-calculated
          _isSettingQuantityProgrammatically = false;
        });
      } else {
        setState(() {
          _navCalculationMessage = 'NAV not found for this date. Please enter quantity manually.';
          _isCalculatingQuantity = false;
          _quantityWasAutoCalculated = false;
        });
      }
    } catch (e) {
      setState(() {
        _navCalculationMessage = 'Error fetching NAV: $e';
        _isCalculatingQuantity = false;
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
    final settings = Provider.of<SettingsProvider>(context);
    final isIndianMarket = settings.selectedMarket == Market.india;
    final currencySymbol = settings.currencySymbol;

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
              decoration: InputDecoration(
                labelText: 'Ticker Symbol (Optional)',
                hintText: isIndianMarket 
                    ? 'e.g., RELIANCE.NS for stocks, HDFC-TOP100 for MFs'
                    : 'e.g., VAS.AX for Australian stocks',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.show_chart),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _showStockSearch(context, isIndianMarket),
                  tooltip: 'Search stocks/ETFs/MFs',
                ),
                helperText: isIndianMarket
                    ? 'NSE stocks: .NS suffix (TCS.NS) | MFs: fund code (HDFC-TOP100). Click 🔍 to search'
                    : 'Add .AX suffix for ASX stocks (e.g., CBA.AX, BHP.AX). Click 🔍 to search',
              ),
              textCapitalization: TextCapitalization.characters,
              onChanged: (value) {
                // Auto-calculate quantity when ticker changes
                _autoCalculateQuantityForMutualFund();
              },
            ),
            if (!isEdit) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Initial Amount',
                  hintText: 'e.g., 10000',
                  border: const OutlineInputBorder(),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      currencySymbol,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
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
                onChanged: (value) {
                  // Auto-calculate quantity when amount changes
                  _autoCalculateQuantityForMutualFund();
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(
                  labelText: 'Initial Quantity (Optional)',
                  hintText: 'e.g., 100 (shares/units)',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.shopping_basket),
                  suffixIcon: _tickerController.text.isNotEmpty &&
                          !_tickerController.text.toUpperCase().endsWith('.NS') &&
                          !_tickerController.text.toUpperCase().endsWith('.AX')
                      ? IconButton(
                          icon: _isCalculatingQuantity
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.calculate),
                          onPressed: _isCalculatingQuantity ? null : _autoCalculateQuantityForMutualFund,
                          tooltip: 'Auto-calculate from NAV',
                        )
                      : null,
                  helperText: _navCalculationMessage,
                  helperMaxLines: 3,
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
                onChanged: (value) {
                  // Don't react if we're setting it programmatically
                  if (_isSettingQuantityProgrammatically) {
                    return;
                  }
                  
                  // If user manually clears the field, allow auto-calculation again
                  if (value.isEmpty) {
                    setState(() {
                      _quantityWasAutoCalculated = false;
                      _navCalculationMessage = null;
                    });
                  }
                  // If user types anything, mark as manual entry
                  else {
                    setState(() {
                      _quantityWasAutoCalculated = false;
                      _navCalculationMessage = null;
                    });
                  }
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

  void _showStockSearch(BuildContext context, bool isIndianMarket) {
    final allSymbols = StockSymbolsProvider.getAllSymbols(isIndianMarket);
    final searchController = TextEditingController();
    List<MapEntry<String, String>> filteredSymbols = allSymbols.entries.toList();

    showDialog(
      context: context,
      builder: (searchContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isIndianMarket 
              ? 'Search Stocks/ETFs/Mutual Funds'
              : 'Search Stocks/ETFs'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search',
                    hintText: 'Type symbol or name...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (query) {
                    setState(() {
                      if (query.isEmpty) {
                        filteredSymbols = allSymbols.entries.toList();
                      } else {
                        filteredSymbols = StockSymbolsProvider.search(query, isIndianMarket).entries.toList();
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 300,
                  child: filteredSymbols.isEmpty
                      ? const Center(child: Text('No results found'))
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: filteredSymbols.length,
                          itemBuilder: (context, index) {
                            final entry = filteredSymbols[index];
                            return ListTile(
                              title: Text(entry.key),
                              subtitle: Text(entry.value),
                              onTap: () {
                                _tickerController.text = entry.key;
                                _nameController.text = entry.value;
                                Navigator.pop(context);
                                // Trigger auto-calculation after selecting ticker
                                _autoCalculateQuantityForMutualFund();
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
