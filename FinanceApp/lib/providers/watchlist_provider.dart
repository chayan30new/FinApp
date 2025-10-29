import 'package:flutter/foundation.dart';
import '../models/watchlist_item.dart';
import '../services/database_factory.dart';

class WatchlistProvider with ChangeNotifier {
  final dynamic _dbService = DatabaseServiceFactory.createDatabaseService();
  List<WatchlistItem> _watchlist = [];
  bool _isLoading = false;

  List<WatchlistItem> get watchlist => _watchlist;
  bool get isLoading => _isLoading;

  WatchlistProvider() {
    loadWatchlist();
  }

  Future<void> loadWatchlist() async {
    _isLoading = true;
    notifyListeners();

    try {
      _watchlist = await _dbService.getWatchlist();
    } catch (e) {
      debugPrint('Error loading watchlist: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addWatchlistItem(WatchlistItem item) async {
    try {
      await _dbService.insertWatchlistItem(item);
      await loadWatchlist();
    } catch (e) {
      debugPrint('Error adding watchlist item: $e');
      rethrow;
    }
  }

  Future<void> updateWatchlistItem(WatchlistItem item) async {
    try {
      await _dbService.updateWatchlistItem(item);
      await loadWatchlist();
    } catch (e) {
      debugPrint('Error updating watchlist item: $e');
      rethrow;
    }
  }

  Future<void> deleteWatchlistItem(String id) async {
    try {
      await _dbService.deleteWatchlistItem(id);
      await loadWatchlist();
    } catch (e) {
      debugPrint('Error deleting watchlist item: $e');
      rethrow;
    }
  }

  WatchlistItem? getWatchlistItemById(String id) {
    try {
      return _watchlist.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }
}
