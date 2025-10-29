import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/watchlist_item.dart';
import '../providers/watchlist_provider.dart';
import '../utils/calculations.dart';
import '../utils/stock_symbols.dart';
import '../services/stock_price_service.dart';
import 'watchlist_detail_screen.dart';

class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Watchlist'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<WatchlistProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.watchlist.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.playlist_add,
                    size: 100,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No stocks in watchlist',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add stocks/ETFs you want to track',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.watchlist.length,
            itemBuilder: (context, index) {
              final item = provider.watchlist[index];
              return _buildWatchlistCard(context, provider, item);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddWatchlistDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add to Watchlist'),
      ),
    );
  }

  Widget _buildWatchlistCard(BuildContext context, WatchlistProvider provider, WatchlistItem item) {
    return WatchlistItemCard(
      item: item,
      provider: provider,
      onEdit: () => _showAddWatchlistDialog(context, item: item),
      onDelete: () => _confirmDelete(context, provider, item),
    );
  }

  void _showAddWatchlistDialog(BuildContext context, {WatchlistItem? item}) {
    final symbolController = TextEditingController(text: item?.symbol ?? '');
    final nameController = TextEditingController(text: item?.name ?? '');
    final targetPriceController = TextEditingController(
      text: item?.targetPrice?.toString() ?? '',
    );
    final notesController = TextEditingController(text: item?.notes ?? '');

    // Auto-fill name when symbol is entered
    symbolController.addListener(() {
      if (item == null && nameController.text.isEmpty) {
        // Only auto-fill if it's a new item and name is empty
        final symbol = symbolController.text.toUpperCase();
        if (symbol.isNotEmpty) {
          nameController.text = symbol;
        }
      }
    });

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Expanded(
              child: Text(item == null ? 'Add to Watchlist' : 'Edit Watchlist Item'),
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => _showStockSearch(dialogContext, symbolController, nameController),
              tooltip: 'Search stocks',
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: symbolController,
                decoration: const InputDecoration(
                  labelText: 'Ticker Symbol *',
                  hintText: 'e.g., VAS.AX, CBA.AX',
                  helperText: 'Name will auto-fill with symbol. Click 🔍 to search',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name (Optional)',
                  hintText: 'Auto-filled or enter custom name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: targetPriceController,
                decoration: const InputDecoration(
                  labelText: 'Target Price (Optional)',
                  hintText: 'e.g., 85.00',
                  prefixText: '\$ ',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  hintText: 'Why are you watching this?',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (symbolController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Symbol is required'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final targetPrice = targetPriceController.text.isNotEmpty
                  ? double.tryParse(targetPriceController.text)
                  : null;

              // Use symbol as name if name is empty
              final name = nameController.text.isEmpty 
                  ? symbolController.text.toUpperCase()
                  : nameController.text;

              final watchlistItem = WatchlistItem(
                id: item?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                symbol: symbolController.text.toUpperCase(),
                name: name,
                targetPrice: targetPrice,
                notes: notesController.text.isEmpty ? null : notesController.text,
                addedAt: item?.addedAt ?? DateTime.now(),
              );

              try {
                final provider = Provider.of<WatchlistProvider>(context, listen: false);
                if (item == null) {
                  await provider.addWatchlistItem(watchlistItem);
                } else {
                  await provider.updateWatchlistItem(watchlistItem);
                }
                
                if (dialogContext.mounted) Navigator.pop(dialogContext);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        item == null
                            ? '${watchlistItem.symbol} added to watchlist'
                            : '${watchlistItem.symbol} updated',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: Text(item == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WatchlistProvider provider, WatchlistItem item) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove from Watchlist?'),
        content: Text('Remove ${item.symbol} from your watchlist?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await provider.deleteWatchlistItem(item.id);
              if (dialogContext.mounted) Navigator.pop(dialogContext);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${item.symbol} removed from watchlist'),
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _showStockSearch(
    BuildContext context,
    TextEditingController symbolController,
    TextEditingController nameController,
  ) {
    final allSymbols = AustralianStockSymbols.getAllSymbols();
    final searchController = TextEditingController();
    List<MapEntry<String, String>> filteredSymbols = allSymbols.entries.toList();

    showDialog(
      context: context,
      builder: (searchContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Search Stocks/ETFs'),
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
                        filteredSymbols = AustralianStockSymbols.search(query);
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
                              title: Text(
                                entry.key,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(entry.value),
                              onTap: () {
                                symbolController.text = entry.key;
                                nameController.text = entry.value;
                                Navigator.pop(searchContext);
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
              onPressed: () => Navigator.pop(searchContext),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}

class WatchlistItemCard extends StatefulWidget {
  final WatchlistItem item;
  final WatchlistProvider provider;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const WatchlistItemCard({
    super.key,
    required this.item,
    required this.provider,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<WatchlistItemCard> createState() => _WatchlistItemCardState();
}

class _WatchlistItemCardState extends State<WatchlistItemCard> {
  StockPrice? _priceData;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchPrice();
  }

  Future<void> _fetchPrice() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final priceData = await StockPriceService.fetchPrice(widget.item.symbol);
      if (mounted) {
        setState(() {
          _priceData = priceData;
          _isLoading = false;
        });
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
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WatchlistDetailScreen(item: widget.item),
            ),
          );
        },
        child: Column(
          children: [
            ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: Colors.blue,
                child: Text(
                  widget.item.symbol.substring(0, widget.item.symbol.length > 3 ? 3 : widget.item.symbol.length),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              title: Text(
                widget.item.symbol,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  widget.item.name,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 13,
                  ),
                ),
                if (widget.item.notes != null && widget.item.notes!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.item.notes!,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  'Added ${DateFormat('MMM d, yyyy').format(widget.item.addedAt)}',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 18),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'edit') {
                  widget.onEdit();
                } else if (value == 'delete') {
                  widget.onDelete();
                }
              },
            ),
          ),
          // Price information section
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Loading price...',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            )
          else if (_error != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.orange[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Price unavailable (browser restriction)',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.orange[900],
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _showManualPriceDialog,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Enter Price', style: TextStyle(fontSize: 11)),
                  ),
                ],
              ),
            )
          else if (_priceData != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Current Price',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            FinancialCalculations.formatCurrency(_priceData!.currentPrice),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      if (_priceData!.changePercent != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _priceData!.changePercent! >= 0
                                ? Colors.green[100]
                                : Colors.red[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _priceData!.changePercent! >= 0
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                                size: 12,
                                color: _priceData!.changePercent! >= 0
                                    ? Colors.green[700]
                                    : Colors.red[700],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${_priceData!.changePercent!.toStringAsFixed(2)}%',
                                style: TextStyle(
                                  fontSize: 12,
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
                  if (widget.item.targetPrice != null) ...[
                    const SizedBox(height: 8),
                    const Divider(height: 1),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.flag, size: 14, color: Colors.orange[700]),
                            const SizedBox(width: 4),
                            Text(
                              'Target: ${FinancialCalculations.formatCurrency(widget.item.targetPrice!)}',
                              style: TextStyle(
                                color: Colors.orange[700],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Builder(
                          builder: (context) {
                            final distancePercent = 
                                ((widget.item.targetPrice! - _priceData!.currentPrice) / 
                                _priceData!.currentPrice) * 100;
                            final isAboveTarget = _priceData!.currentPrice >= widget.item.targetPrice!;
                            
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isAboveTarget ? Colors.green[100] : Colors.orange[100],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${distancePercent >= 0 ? '+' : ''}${distancePercent.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isAboveTarget ? Colors.green[700] : Colors.orange[700],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Updated: ${DateFormat('MMM d, h:mm a').format(_priceData!.lastUpdated)}',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                      TextButton(
                        onPressed: _fetchPrice,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.refresh, size: 12),
                            SizedBox(width: 4),
                            Text('Refresh', style: TextStyle(fontSize: 11)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
