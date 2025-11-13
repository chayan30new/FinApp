import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/watchlist_item.dart';
import '../services/stock_price_service.dart';
import '../services/mutual_fund_nav_service.dart';
import '../utils/calculations.dart';
import '../widgets/historical_price_chart.dart';
import '../providers/settings_provider.dart';

class WatchlistDetailScreen extends StatefulWidget {
  final WatchlistItem item;

  const WatchlistDetailScreen({
    super.key,
    required this.item,
  });

  @override
  State<WatchlistDetailScreen> createState() => _WatchlistDetailScreenState();
}

class _WatchlistDetailScreenState extends State<WatchlistDetailScreen> {
  StockPrice? _priceData;
  bool _isLoading = false;
  String? _error;
  
  HistoricalPriceData? _historicalData;
  bool _isLoadingHistory = false;
  String? _historyError;
  String _selectedPeriod = '1y';

  @override
  void initState() {
    super.initState();
    _fetchPrice();
    _fetchHistoricalPrices();
  }

  Future<void> _fetchPrice() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    // Check if this is a mutual fund
    final isMutualFund = !(widget.item.symbol.contains('.NS') || 
                            widget.item.symbol.contains('.AX') ||
                            widget.item.symbol.contains('.BSE'));

    try {
      if (isMutualFund) {
        // Fetch NAV for mutual fund
        final navData = await MutualFundNavService.fetchLatestNavBySymbol(widget.item.symbol);
        
        if (mounted) {
          if (navData != null) {
            setState(() {
              _priceData = StockPrice(
                symbol: widget.item.symbol,
                name: widget.item.name,
                currentPrice: navData.nav,
                previousClose: null,
                changePercent: null,
                currency: '₹',
                lastUpdated: navData.date,
              );
              _isLoading = false;
            });
          } else {
            setState(() {
              _error = 'Could not fetch NAV';
              _isLoading = false;
            });
          }
        }
      } else {
        // Fetch price for stocks/ETFs
        final priceData = await StockPriceService.fetchPrice(widget.item.symbol);
        if (mounted) {
          setState(() {
            _priceData = priceData;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchHistoricalPrices() async {
    setState(() {
      _isLoadingHistory = true;
      _historyError = null;
    });

    // Check if this is a mutual fund
    final isMutualFund = !(widget.item.symbol.contains('.NS') || 
                            widget.item.symbol.contains('.AX') ||
                            widget.item.symbol.contains('.BSE'));

    try {
      if (isMutualFund) {
        // Fetch historical NAV for mutual fund
        print('===> WATCHLIST: Fetching historical NAV for ${widget.item.symbol}');
        final periodDays = _getPeriodDays(_selectedPeriod);
        print('===> WATCHLIST: Period = $_selectedPeriod, Days = $periodDays');
        
        final navList = await MutualFundNavService.fetchHistoricalNavBySymbol(
          widget.item.symbol,
          limitDays: periodDays,
        );
        
        print('===> WATCHLIST: Received ${navList.length} NAV records');
        
        if (mounted) {
          if (navList.isNotEmpty) {
            // Convert NAV data to HistoricalPriceData format
            final prices = navList.map((nav) => HistoricalPrice(
              date: nav.date,
              close: nav.nav,
            )).toList();
            
            print('===> WATCHLIST: Converted to ${prices.length} HistoricalPrice objects');
            print('===> WATCHLIST: Setting state with historical data');
            
            setState(() {
              _historicalData = HistoricalPriceData(
                symbol: widget.item.symbol,
                prices: prices,
                period: _selectedPeriod,
              );
              _isLoadingHistory = false;
            });
            
            print('===> WATCHLIST: State updated successfully');
          } else {
            print('===> WATCHLIST: ERROR - No NAV data received');
            setState(() {
              _historyError = 'No historical NAV data available for this period';
              _isLoadingHistory = false;
            });
          }
        }
      } else {
        // Fetch historical prices for stocks/ETFs
        final histData = await StockPriceService.fetchHistoricalPrices(
          widget.item.symbol,
          period: _selectedPeriod,
        );
        if (mounted) {
          setState(() {
            _historicalData = histData;
            _isLoadingHistory = false;
            // If histData is null or has no prices, set an error
            if (histData == null || histData.prices.isEmpty) {
              _historyError = 'No data available';
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _historyError = e.toString();
          _isLoadingHistory = false;
        });
      }
    }
  }

  // Convert period string to number of days
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

  void _changePeriod(String period) {
    setState(() {
      _selectedPeriod = period;
    });
    _fetchHistoricalPrices();
  }

  void _showManualPriceDialog() {
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enter Price for ${widget.item.symbol}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Due to browser CORS restrictions, we cannot fetch prices automatically in the web app.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(
                labelText: 'Current Price (AUD)',
                prefixText: '\$',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            const Text(
              'Check current price:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            InkWell(
              onTap: () {
                // Open ASX website
              },
              child: Text(
                'ASX Website: asx.com.au',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.blue[700],
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 2),
            InkWell(
              onTap: () {
                // Open Google Finance
              },
              child: Text(
                'Google Finance: google.com/finance',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.blue[700],
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final price = double.tryParse(priceController.text);
              if (price != null && price > 0) {
                setState(() {
                  _priceData = StockPrice(
                    symbol: widget.item.symbol,
                    name: widget.item.name,
                    currentPrice: price,
                    previousClose: null,
                    changePercent: null,
                    currency: 'AUD',
                    lastUpdated: DateTime.now(),
                  );
                  _error = null;
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final currencySymbol = settings.currencySymbol;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item.symbol),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchPrice,
            tooltip: 'Refresh Price',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.blue,
                            radius: 24,
                            child: Text(
                              widget.item.symbol.substring(
                                0,
                                widget.item.symbol.length > 3 ? 3 : widget.item.symbol.length,
                              ),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.item.symbol,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.item.name,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Price Information Card
              if (_isLoading)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Center(
                      child: Column(
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 12),
                          Text(
                            'Loading price data...',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else if (_error != null)
                Card(
                  color: Colors.orange[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.orange[700]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Unable to fetch price automatically',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange[900],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Due to browser CORS restrictions, automatic price fetching is blocked in web browsers.',
                          style: TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: _showManualPriceDialog,
                          icon: const Icon(Icons.edit),
                          label: const Text('Enter Price Manually'),
                        ),
                      ],
                    ),
                  ),
                )
              else if (_priceData != null)
                Card(
                  color: Colors.green[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Current Price',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  FinancialCalculations.formatCurrency(_priceData!.currentPrice, symbol: currencySymbol),
                                  style: const TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            if (_priceData!.changePercent != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _priceData!.changePercent! >= 0
                                      ? Colors.green[100]
                                      : Colors.red[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _priceData!.changePercent! >= 0
                                          ? Icons.arrow_upward
                                          : Icons.arrow_downward,
                                      size: 16,
                                      color: _priceData!.changePercent! >= 0
                                          ? Colors.green[700]
                                          : Colors.red[700],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${_priceData!.changePercent!.toStringAsFixed(2)}%',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: _priceData!.changePercent! >= 0
                                            ? Colors.green[700]
                                            : Colors.red[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        if (_priceData!.previousClose != null) ...[
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Text(
                                'Previous Close: ',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                FinancialCalculations.formatCurrency(_priceData!.previousClose!, symbol: currencySymbol),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Last Updated: ${DateFormat('MMM d, yyyy h:mm a').format(_priceData!.lastUpdated)}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                            TextButton.icon(
                              onPressed: _showManualPriceDialog,
                              icon: const Icon(Icons.edit, size: 14),
                              label: const Text('Update', style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // Historical Price Chart Card
              Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Price History',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          DropdownButton<String>(
                            value: _selectedPeriod,
                            underline: Container(),
                            items: const [
                              DropdownMenuItem(value: '1mo', child: Text('1M')),
                              DropdownMenuItem(value: '3mo', child: Text('3M')),
                              DropdownMenuItem(value: '6mo', child: Text('6M')),
                              DropdownMenuItem(value: '1y', child: Text('1Y')),
                              DropdownMenuItem(value: '2y', child: Text('2Y')),
                              DropdownMenuItem(value: '5y', child: Text('5Y')),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                _changePeriod(value);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    if (_isLoadingHistory)
                      const Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Center(
                          child: Column(
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 12),
                              Text('Loading chart data...'),
                            ],
                          ),
                        ),
                      )
                    else if (_historyError != null)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange[200]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.error_outline, color: Colors.orange[700]),
                                  const SizedBox(width: 8),
                                  const Expanded(
                                    child: Text(
                                      'Unable to Load Historical Data',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _historyError!,
                                style: const TextStyle(fontSize: 12),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: _fetchHistoricalPrices,
                                icon: const Icon(Icons.refresh, size: 16),
                                label: const Text('Retry'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (_historicalData != null && _historicalData!.prices.isNotEmpty)
                      HistoricalPriceChart(data: _historicalData!)
                    else
                      const Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Center(
                          child: Text('No historical data available'),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Target Price Analysis Card
              if (widget.item.targetPrice != null && _priceData != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.flag, color: Colors.orange[700]),
                            const SizedBox(width: 8),
                            const Text(
                              'Target Price Analysis',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Your Target',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  FinancialCalculations.formatCurrency(widget.item.targetPrice!, symbol: currencySymbol),
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange[700],
                                  ),
                                ),
                              ],
                            ),
                            Builder(
                              builder: (context) {
                                final distancePercent = 
                                    ((widget.item.targetPrice! - _priceData!.currentPrice) / 
                                    _priceData!.currentPrice) * 100;
                                final distanceAmount = widget.item.targetPrice! - _priceData!.currentPrice;
                                final isAboveTarget = _priceData!.currentPrice >= widget.item.targetPrice!;
                                
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: isAboveTarget ? Colors.green[100] : Colors.orange[100],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '${distancePercent >= 0 ? '+' : ''}${distancePercent.toStringAsFixed(1)}%',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: isAboveTarget ? Colors.green[700] : Colors.orange[700],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${distanceAmount >= 0 ? '+' : ''}${FinancialCalculations.formatCurrency(distanceAmount.abs(), symbol: currencySymbol)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _priceData!.currentPrice >= widget.item.targetPrice!
                                ? Colors.green[50]
                                : Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _priceData!.currentPrice >= widget.item.targetPrice!
                                  ? Colors.green[200]!
                                  : Colors.blue[200]!,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _priceData!.currentPrice >= widget.item.targetPrice!
                                    ? Icons.check_circle
                                    : Icons.info_outline,
                                color: _priceData!.currentPrice >= widget.item.targetPrice!
                                    ? Colors.green[700]
                                    : Colors.blue[700],
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _priceData!.currentPrice >= widget.item.targetPrice!
                                      ? 'Price has reached or exceeded your target!'
                                      : 'Waiting for price to reach target...',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _priceData!.currentPrice >= widget.item.targetPrice!
                                        ? Colors.green[900]
                                        : Colors.blue[900],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // Additional Details Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow('Symbol', widget.item.symbol),
                      const Divider(),
                      _buildDetailRow('Name', widget.item.name),
                      const Divider(),
                      _buildDetailRow(
                        'Target Price',
                        widget.item.targetPrice != null
                            ? FinancialCalculations.formatCurrency(widget.item.targetPrice!, symbol: currencySymbol)
                            : 'Not set',
                      ),
                      if (widget.item.notes != null && widget.item.notes!.isNotEmpty) ...[
                        const Divider(),
                        _buildDetailRow('Notes', widget.item.notes!),
                      ],
                      const Divider(),
                      _buildDetailRow(
                        'Added to Watchlist',
                        DateFormat('MMMM d, yyyy').format(widget.item.addedAt),
                      ),
                      const Divider(),
                      _buildDetailRow(
                        'Days on Watchlist',
                        '${DateTime.now().difference(widget.item.addedAt).inDays} days',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Information Card
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lightbulb_outline, color: Colors.blue[700]),
                          const SizedBox(width: 8),
                          const Text(
                            'About Watchlist',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Use the watchlist to track stocks and ETFs you\'re interested in but haven\'t invested in yet. Set target prices and monitor historical trends to identify the best time to buy!',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
