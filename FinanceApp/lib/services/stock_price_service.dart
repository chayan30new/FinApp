import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service to fetch live stock/ETF prices
/// Uses Yahoo Finance API (free, no API key required)
class StockPriceService {
  /// Fetch current price for a symbol (e.g., 'VAS.AX' for Vanguard Australian Shares)
  /// Australian stocks should have '.AX' suffix (ASX: Australian Securities Exchange)
  static Future<StockPrice?> fetchPrice(String symbol) async {
    try {
      // Ensure symbol has .AX suffix for ASX stocks if not already present
      String formattedSymbol = symbol.toUpperCase();
      if (!formattedSymbol.contains('.') && !formattedSymbol.contains(':')) {
        formattedSymbol = '$formattedSymbol.AX';
      }

      // Using Yahoo Finance query API
      final url = Uri.parse(
        'https://query1.finance.yahoo.com/v8/finance/chart/$formattedSymbol?interval=1d&range=1d',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        final result = data['chart']?['result']?[0];
        if (result == null) return null;

        final meta = result['meta'];
        final quote = result['indicators']?['quote']?[0];
        
        final currentPrice = meta['regularMarketPrice']?.toDouble();
        final previousClose = meta['previousClose']?.toDouble();
        final currency = meta['currency'] ?? 'AUD';
        final shortName = meta['symbol'] ?? formattedSymbol;
        final longName = meta['longName'] ?? meta['shortName'] ?? formattedSymbol;

        if (currentPrice == null) return null;

        double? changePercent;
        if (previousClose != null && previousClose > 0) {
          changePercent = ((currentPrice - previousClose) / previousClose) * 100;
        }

        return StockPrice(
          symbol: formattedSymbol,
          name: longName,
          currentPrice: currentPrice,
          previousClose: previousClose,
          changePercent: changePercent,
          currency: currency,
          lastUpdated: DateTime.now(),
        );
      }
    } catch (e) {
      print('Error fetching price for $symbol: $e');
      return null;
    }
    return null;
  }

  /// Search for stock symbols by name or ticker
  static Future<List<StockSearchResult>> searchSymbols(String query) async {
    try {
      final url = Uri.parse(
        'https://query1.finance.yahoo.com/v1/finance/search?q=$query&quotesCount=10&newsCount=0',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final quotes = data['quotes'] as List?;

        if (quotes == null) return [];

        return quotes
            .where((quote) => 
                quote['exchange']?.toString().contains('ASX') == true ||
                quote['symbol']?.toString().contains('.AX') == true)
            .map((quote) => StockSearchResult(
                  symbol: quote['symbol'] ?? '',
                  name: quote['shortname'] ?? quote['longname'] ?? '',
                  exchange: quote['exchange'] ?? '',
                  type: quote['quoteType'] ?? '',
                ))
            .where((result) => result.symbol.isNotEmpty)
            .toList();
      }
    } catch (e) {
      print('Error searching symbols: $e');
      return [];
    }
    return [];
  }

  /// Get multiple prices at once
  static Future<Map<String, StockPrice>> fetchMultiplePrices(
      List<String> symbols) async {
    final results = <String, StockPrice>{};
    
    await Future.wait(
      symbols.map((symbol) async {
        final price = await fetchPrice(symbol);
        if (price != null) {
          results[symbol] = price;
        }
      }),
    );
    
    return results;
  }
}

class StockPrice {
  final String symbol;
  final String name;
  final double currentPrice;
  final double? previousClose;
  final double? changePercent;
  final String currency;
  final DateTime lastUpdated;

  StockPrice({
    required this.symbol,
    required this.name,
    required this.currentPrice,
    this.previousClose,
    this.changePercent,
    required this.currency,
    required this.lastUpdated,
  });

  bool get isPositiveChange => (changePercent ?? 0) >= 0;
}

class StockSearchResult {
  final String symbol;
  final String name;
  final String exchange;
  final String type;

  StockSearchResult({
    required this.symbol,
    required this.name,
    required this.exchange,
    required this.type,
  });
}
