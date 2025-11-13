import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Market {
  india,
  australia,
}

class SettingsProvider with ChangeNotifier {
  Market _selectedMarket = Market.india;
  
  Market get selectedMarket => _selectedMarket;
  
  String get currencySymbol => _selectedMarket == Market.india ? '₹' : '\$';
  
  String get currencyCode => _selectedMarket == Market.india ? 'INR' : 'AUD';
  
  String get marketName => _selectedMarket == Market.india ? 'India' : 'Australia';
  
  String get stockSuffix => _selectedMarket == Market.india ? '.NS' : '.AX'; // .NS for NSE, .AX for ASX
  
  SettingsProvider() {
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final marketIndex = prefs.getInt('selected_market') ?? 0;
    _selectedMarket = Market.values[marketIndex];
    notifyListeners();
  }
  
  Future<void> setMarket(Market market) async {
    _selectedMarket = market;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selected_market', market.index);
    notifyListeners();
  }
}
