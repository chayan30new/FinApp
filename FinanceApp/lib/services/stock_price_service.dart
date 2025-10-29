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
        
        final currentPrice = meta['regularMarketPrice']?.toDouble();
        final previousClose = meta['previousClose']?.toDouble();
        final currency = meta['currency'] ?? 'AUD';
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

  /// Fetch historical prices for a symbol
  /// period: '1mo', '3mo', '6mo', '1y', '2y', '5y', 'max'
  static Future<HistoricalPriceData?> fetchHistoricalPrices(
    String symbol, {
    String period = '1y',
  }) async {
    try {
      // Ensure symbol has .AX suffix for ASX stocks if not already present
      String formattedSymbol = symbol.toUpperCase();
      if (!formattedSymbol.contains('.') && !formattedSymbol.contains(':')) {
        formattedSymbol = '$formattedSymbol.AX';
      }

      // Using Yahoo Finance query API for historical data
      final url = Uri.parse(
        'https://query1.finance.yahoo.com/v8/finance/chart/$formattedSymbol?interval=1d&range=$period',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        final result = data['chart']?['result']?[0];
        if (result == null) return null;

        final timestamps = (result['timestamp'] as List?)?.cast<int>();
        final quotes = result['indicators']?['quote']?[0];
        
        if (timestamps == null || quotes == null) return null;

        final closes = (quotes['close'] as List?)?.cast<double?>();
        final opens = (quotes['open'] as List?)?.cast<double?>();
        final highs = (quotes['high'] as List?)?.cast<double?>();
        final lows = (quotes['low'] as List?)?.cast<double?>();
        
        if (closes == null) return null;

        List<HistoricalPrice> prices = [];
        for (int i = 0; i < timestamps.length; i++) {
          final close = closes[i];
          if (close != null) {
            prices.add(HistoricalPrice(
              date: DateTime.fromMillisecondsSinceEpoch(timestamps[i] * 1000),
              close: close,
              open: opens?[i],
              high: highs?[i],
              low: lows?[i],
            ));
          }
        }

        final meta = result['meta'];
        final currentPrice = meta['regularMarketPrice']?.toDouble();

        return HistoricalPriceData(
          symbol: formattedSymbol,
          prices: prices,
          currentPrice: currentPrice,
          period: period,
        );
      }
    } catch (e) {
      print('Error fetching historical prices for $symbol: $e');
      return null;
    }
    return null;
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

class HistoricalPrice {
  final DateTime date;
  final double close;
  final double? open;
  final double? high;
  final double? low;

  HistoricalPrice({
    required this.date,
    required this.close,
    this.open,
    this.high,
    this.low,
  });
}

class HistoricalPriceData {
  final String symbol;
  final List<HistoricalPrice> prices;
  final double? currentPrice;
  final String period;

  HistoricalPriceData({
    required this.symbol,
    required this.prices,
    this.currentPrice,
    required this.period,
  });

  double? get minPrice => prices.isEmpty 
      ? null 
      : prices.map((p) => p.close).reduce((a, b) => a < b ? a : b);

  double? get maxPrice => prices.isEmpty 
      ? null 
      : prices.map((p) => p.close).reduce((a, b) => a > b ? a : b);

  double? get priceChangePercent {
    if (prices.isEmpty || currentPrice == null) return null;
    final firstPrice = prices.first.close;
    return ((currentPrice! - firstPrice) / firstPrice) * 100;
  }
}
