import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/watchlist_item.dart';
import '../providers/watchlist_provider.dart';
import '../utils/calculations.dart';

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
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Text(
            item.symbol.substring(0, item.symbol.length > 3 ? 3 : item.symbol.length),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        title: Text(
          item.symbol,
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
              item.name,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 13,
              ),
            ),
            if (item.targetPrice != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.flag, size: 14, color: Colors.orange[700]),
                  const SizedBox(width: 4),
                  Text(
                    'Target: ${FinancialCalculations.formatCurrency(item.targetPrice!)}',
                    style: TextStyle(
                      color: Colors.orange[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
            if (item.notes != null && item.notes!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                item.notes!,
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
              'Added ${DateFormat('MMM d, yyyy').format(item.addedAt)}',
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
              _showAddWatchlistDialog(context, item: item);
            } else if (value == 'delete') {
              _confirmDelete(context, provider, item);
            }
          },
        ),
      ),
    );
  }

  void _showAddWatchlistDialog(BuildContext context, {WatchlistItem? item}) {
    final symbolController = TextEditingController(text: item?.symbol ?? '');
    final nameController = TextEditingController(text: item?.name ?? '');
    final targetPriceController = TextEditingController(
      text: item?.targetPrice?.toString() ?? '',
    );
    final notesController = TextEditingController(text: item?.notes ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(item == null ? 'Add to Watchlist' : 'Edit Watchlist Item'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: symbolController,
                decoration: const InputDecoration(
                  labelText: 'Ticker Symbol *',
                  hintText: 'e.g., VAS.AX, CBA.AX',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name *',
                  hintText: 'e.g., Vanguard Australian Shares',
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
              if (symbolController.text.isEmpty || nameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Symbol and Name are required'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final targetPrice = targetPriceController.text.isNotEmpty
                  ? double.tryParse(targetPriceController.text)
                  : null;

              final watchlistItem = WatchlistItem(
                id: item?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                symbol: symbolController.text.toUpperCase(),
                name: nameController.text,
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
}
