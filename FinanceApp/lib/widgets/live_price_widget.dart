import 'package:flutter/material.dart';
import '../models/investment.dart';
import '../services/stock_price_service.dart';
import '../utils/calculations.dart';

class LivePriceWidget extends StatefulWidget {
  final Investment investment;
  final Function(double) onPriceUpdate;

  const LivePriceWidget({
    super.key,
    required this.investment,
    required this.onPriceUpdate,
  });

  @override
  State<LivePriceWidget> createState() => _LivePriceWidgetState();
}

class _LivePriceWidgetState extends State<LivePriceWidget> {
  StockPrice? _stockPrice;
  bool _isLoading = false;
  String? _error;
  final _manualPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.investment.tickerSymbol != null &&
        widget.investment.tickerSymbol!.isNotEmpty) {
      _fetchPrice();
    }
  }

  @override
  void dispose() {
    _manualPriceController.dispose();
    super.dispose();
  }

  Future<void> _fetchPrice() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final price =
          await StockPriceService.fetchPrice(widget.investment.tickerSymbol!);

      if (mounted) {
        setState(() {
          _stockPrice = price;
          _isLoading = false;
          if (price == null) {
            _error = 'Could not fetch live price. You can enter the price manually below.';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Unable to fetch live price (CORS restriction in browser).\nEnter price manually below.';
          _isLoading = false;
        });
      }
    }
  }

  void _updateCurrentValue({double? customPrice}) {
    if (widget.investment.totalQuantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No quantity available. Please add transactions with quantities.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    double priceToUse;
    if (customPrice != null) {
      priceToUse = customPrice;
    } else if (_stockPrice != null) {
      priceToUse = _stockPrice!.currentPrice;
    } else {
      return;
    }

    final newValue = priceToUse * widget.investment.totalQuantity;
    widget.onPriceUpdate(newValue);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Updated to ${FinancialCalculations.formatCurrency(newValue)} '
          '(${widget.investment.totalQuantity.toStringAsFixed(2)} × '
          '${FinancialCalculations.formatCurrency(priceToUse)})',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showManualPriceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enter Current Price for ${widget.investment.tickerSymbol}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Look up the current price on:',
              style: TextStyle(color: Colors.grey[700], fontSize: 12),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () {
                // This will be handled by the user's browser
              },
              child: Text(
                '• ASX: www.asx.com.au',
                style: TextStyle(color: Colors.blue[700], fontSize: 12),
              ),
            ),
            InkWell(
              onTap: () {
                // This will be handled by the user's browser
              },
              child: Text(
                '• Google Finance: google.com/finance',
                style: TextStyle(color: Colors.blue[700], fontSize: 12),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _manualPriceController,
              decoration: const InputDecoration(
                labelText: 'Current Price per Unit',
                hintText: 'e.g., 85.50',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
            ),
            const SizedBox(height: 8),
            if (widget.investment.totalQuantity > 0)
              Text(
                'You hold ${widget.investment.totalQuantity.toStringAsFixed(2)} units',
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
            onPressed: () {
              final price = double.tryParse(_manualPriceController.text);
              if (price != null && price > 0) {
                Navigator.pop(context);
                _updateCurrentValue(customPrice: price);
                _manualPriceController.clear();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid price'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Update Value'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.investment.tickerSymbol == null ||
        widget.investment.tickerSymbol!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Live Market Price',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.investment.tickerSymbol!,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                  onPressed: _isLoading ? null : _fetchPrice,
                  tooltip: 'Refresh price',
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange[700], size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _error!,
                            style: TextStyle(color: Colors.orange[900], fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _showManualPriceDialog,
                  icon: const Icon(Icons.edit),
                  label: const Text('Enter Price Manually'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ]
            else if (_stockPrice != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        FinancialCalculations.formatCurrency(
                            _stockPrice!.currentPrice),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_stockPrice!.changePercent != null)
                        Text(
                          '${_stockPrice!.changePercent! >= 0 ? '+' : ''}'
                          '${_stockPrice!.changePercent!.toStringAsFixed(2)}%',
                          style: TextStyle(
                            color: _stockPrice!.isPositiveChange
                                ? Colors.green
                                : Colors.red,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                  if (widget.investment.totalQuantity > 0)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Portfolio Value',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          FinancialCalculations.formatCurrency(
                            _stockPrice!.currentPrice *
                                widget.investment.totalQuantity,
                          ),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (widget.investment.totalQuantity > 0)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _updateCurrentValue(),
                    icon: const Icon(Icons.update),
                    label: const Text('Update Current Value'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                'Last updated: ${_stockPrice!.lastUpdated.hour}:${_stockPrice!.lastUpdated.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 11,
                ),
              ),
            ] else if (!_isLoading) ...[
              const Text(
                'Tap refresh to load price',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _showManualPriceDialog,
                  icon: const Icon(Icons.edit),
                  label: const Text('Enter Price Manually'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
