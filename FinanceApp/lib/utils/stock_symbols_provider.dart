import 'indian_stock_symbols.dart';
import 'stock_symbols.dart';

/// Unified stock symbols provider that returns appropriate symbols based on market
class StockSymbolsProvider {
  static Map<String, String> getAllSymbols(bool isIndianMarket) {
    return isIndianMarket 
        ? IndianStockSymbols.getAllSymbols()
        : AustralianStockSymbols.getAllSymbols();
  }

  static Map<String, String> search(String query, bool isIndianMarket) {
    return isIndianMarket
        ? IndianStockSymbols.search(query)
        : AustralianStockSymbols.search(query);
  }

  static List<String> getSuggestions(String partial, bool isIndianMarket) {
    return isIndianMarket
        ? IndianStockSymbols.getSuggestions(partial)
        : AustralianStockSymbols.getSuggestions(partial);
  }

  static List<String> getCategories(bool isIndianMarket) {
    return isIndianMarket
        ? IndianStockSymbols.getCategories()
        : AustralianStockSymbols.getCategories();
  }

  static Map<String, String> getMutualFunds() {
    return IndianStockSymbols.getMutualFunds();
  }
}
