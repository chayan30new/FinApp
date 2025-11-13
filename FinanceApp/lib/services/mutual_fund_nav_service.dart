import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/mutual_fund_scheme_codes.dart';

/// Service to fetch NAV data for Indian mutual funds directly from AMFI India
/// Uses official AMFI data sources:
/// - Daily NAV: https://www.amfiindia.com/spages/NAVAll.txt
/// - Historical NAV: Using MF API as AMFI historical endpoint is unreliable
class MutualFundNavService {
  /// AMFI India official NAV data URL (all funds, daily)
  static const String _dailyNavUrl = 'https://www.amfiindia.com/spages/NAVAll.txt';
  
  /// MF API base URL for historical data (more reliable than AMFI portal)
  static const String _mfApiBaseUrl = 'https://api.mfapi.in/mf';

  /// Fetch latest NAV for a mutual fund using our fund code
  /// symbol: Our fund code (e.g., 'HDFC-TOP100') or AMFI scheme code (e.g., '120503')
  static Future<MutualFundNav?> fetchLatestNavBySymbol(String symbol) async {
    // Try to get AMFI scheme code from our mapping
    final schemeCode = MutualFundSchemeCodes.getSchemeCode(symbol) ?? symbol;
    return fetchLatestNav(schemeCode);
  }

  /// Fetch historical NAV using our fund code
  /// symbol: Our fund code (e.g., 'HDFC-TOP100') or AMFI scheme code (e.g., '120503')
  static Future<List<MutualFundNav>> fetchHistoricalNavBySymbol(
    String symbol, {
    int? limitDays,
  }) async {
    final schemeCode = MutualFundSchemeCodes.getSchemeCode(symbol) ?? symbol;
    return fetchHistoricalNav(schemeCode, limitDays: limitDays);
  }

  /// Fetch NAV for a specific date using our fund code
  /// symbol: Our fund code (e.g., 'HDFC-TOP100') or AMFI scheme code (e.g., '120503')
  static Future<MutualFundNav?> fetchNavForDateBySymbol(
    String symbol,
    DateTime targetDate,
  ) async {
    final schemeCode = MutualFundSchemeCodes.getSchemeCode(symbol) ?? symbol;
    return fetchNavForDate(schemeCode, targetDate);
  }

  /// Parse AMFI NAV text data
  /// Format: Scheme Code;ISIN;ISIN;Scheme Name;Net Asset Value;Date
  static List<Map<String, String>> _parseAmfiData(String body) {
    final List<Map<String, String>> fundData = [];
    final bodyClean = body.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    final lines = bodyClean.split('\n');
    
    if (lines.isEmpty) return fundData;
    
    final headers = lines[0].split(';');
    
    for (int i = 1; i < lines.length; i++) {
      final parts = lines[i].split(';');
      if (parts.length == 6) {
        final Map<String, String> obj = {};
        for (int j = 0; j < 6; j++) {
          if (j < headers.length) {
            obj[headers[j]] = parts[j];
          }
        }
        fundData.add(obj);
      }
    }
    
    return fundData;
  }

  /// Fetch latest NAV for a mutual fund scheme from AMFI
  /// schemeCode: The AMFI scheme code (e.g., '120503' for HDFC Top 100)
  static Future<MutualFundNav?> fetchLatestNav(String schemeCode) async {
    try {
      print('Fetching NAV from AMFI for scheme code: $schemeCode');
      final url = Uri.parse(_dailyNavUrl);
      final response = await http.get(url);

      if (response.statusCode == 200) {
        print('AMFI response received: ${response.body.length} bytes');
        final fundData = _parseAmfiData(response.body);
        print('Parsed ${fundData.length} funds from AMFI data');
        
        // Find the fund with matching scheme code
        for (var fund in fundData) {
          if (fund['Scheme Code'] == schemeCode) {
            print('Found matching scheme code: $schemeCode');
            final navValue = fund['Net Asset Value']?.trim();
            final dateStr = fund['Date']?.trim();
            
            if (navValue != null && dateStr != null && navValue.isNotEmpty && dateStr.isNotEmpty) {
              // Parse date in DD-Mon-YYYY format (e.g., "07-Nov-2025")
              final dateParts = dateStr.split('-');
              if (dateParts.length == 3) {
                final day = int.tryParse(dateParts[0].trim());
                final monthStr = dateParts[1].trim();
                final yearStr = dateParts[2].trim();
                final year = int.tryParse(yearStr);
                
                if (day != null && year != null) {
                  final monthMap = {
                    'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
                    'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12
                  };
                  final month = monthMap[monthStr] ?? 1;
                  
                  final navObj = MutualFundNav(
                    date: DateTime(year, month, day),
                    nav: double.tryParse(navValue) ?? 0.0,
                    schemeName: fund['Scheme Name']?.trim() ?? '',
                    schemeCode: schemeCode,
                  );
                  print('Successfully parsed NAV: ₹${navObj.nav} on ${navObj.date}');
                  return navObj;
                }
              }
            }
          }
        }
        print('No matching scheme code found in AMFI data');
      } else {
        print('AMFI API returned status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching NAV for scheme $schemeCode: $e');
    }
    return null;
  }

  /// Parse AMFI historical NAV text data
  /// Format: Scheme Code;Scheme Name;Net Asset Value;Repurchase Price;Sale Price;Date
  static List<Map<String, String>> _parseAmfiHistoricalData(String body) {
    final List<Map<String, String>> fundData = [];
    final bodyClean = body.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    final lines = bodyClean.split('\n');
    
    if (lines.isEmpty) return fundData;
    
    final headers = lines[0].split(';');
    
    for (int i = 1; i < lines.length; i++) {
      final parts = lines[i].split(';');
      if (parts.length == 8) {
        final Map<String, String> obj = {};
        // Skip some columns as per AMFI-API implementation
        for (int j = 0; j < 8; j++) {
          if (j == 2 || j == 3 || j == 5 || j == 6) {
            continue; // Skip ISIN and price columns
          }
          if (j < headers.length) {
            obj[headers[j]] = parts[j];
          }
        }
        fundData.add(obj);
      }
    }
    
    return fundData;
  }

  /// Fetch historical NAV data for a mutual fund scheme from MF API
  /// Returns list of NAV data points, limited to last 'days' worth of data
  static Future<List<MutualFundNav>> fetchHistoricalNav(
    String schemeCode, {
    int? limitDays,
  }) async {
    try {
      print('=== Fetching Historical NAV from MF API ===');
      print('Scheme Code: $schemeCode');
      print('Limit Days: ${limitDays ?? 365}');
      
      // MF API endpoint: https://api.mfapi.in/mf/{scheme_code}
      final url = Uri.parse('$_mfApiBaseUrl/$schemeCode');
      print('Request URL: $url');
      
      final response = await http.get(url);
      print('Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('Response received, parsing JSON...');
        
        // Parse JSON response
        final dynamic jsonData = json.decode(response.body);
        
        if (jsonData is! Map<String, dynamic>) {
          print('ERROR: Invalid JSON format');
          return [];
        }
        
        final schemeName = jsonData['meta']?['scheme_name'] as String? ?? '';
        final data = jsonData['data'] as List<dynamic>?;
        
        if (data == null || data.isEmpty) {
          print('ERROR: No data field in response');
          return [];
        }
        
        print('Total records in response: ${data.length}');
        
        final List<MutualFundNav> navData = [];
        final cutoffDate = DateTime.now().subtract(Duration(days: limitDays ?? 365));
        
        for (var item in data) {
          if (item is! Map<String, dynamic>) continue;
          
          final dateStr = item['date'] as String?;
          final navStr = item['nav'] as String?;
          
          if (dateStr == null || navStr == null) continue;
          
          try {
            // Parse date in DD-MM-YYYY format
            final parts = dateStr.split('-');
            if (parts.length != 3) continue;
            
            final day = int.parse(parts[0]);
            final month = int.parse(parts[1]);
            final year = int.parse(parts[2]);
            final date = DateTime(year, month, day);
            
            // Only include dates within our limit
            if (date.isBefore(cutoffDate)) continue;
            
            final nav = double.tryParse(navStr);
            if (nav == null) continue;
            
            navData.add(MutualFundNav(
              date: date,
              nav: nav,
              schemeName: schemeName,
              schemeCode: schemeCode,
            ));
          } catch (e) {
            print('Error parsing date/NAV: $dateStr / $navStr - $e');
            continue;
          }
        }
        
        // Sort by date (oldest first for chart display)
        navData.sort((a, b) => a.date.compareTo(b.date));
        
        print('NAV records after filtering: ${navData.length}');
        if (navData.isNotEmpty) {
          print('Date range in data: ${navData.first.date} to ${navData.last.date}');
        }
        
        return navData;
      } else {
        print('ERROR: HTTP ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('EXCEPTION in fetchHistoricalNav for scheme $schemeCode: $e');
    }
    print('Returning empty list for scheme $schemeCode');
    return [];
  }

  /// Search for mutual fund schemes by name
  /// Returns list of matching schemes with their codes
  static Future<List<MutualFundScheme>> searchSchemes(String query) async {
    try {
      // Note: MFApi doesn't have a search endpoint
      // This would need to be implemented with a local database or different API
      // For now, return empty list
      return [];
    } catch (e) {
      print('Error searching schemes: $e');
      return [];
    }
  }

  /// Get NAV for a specific date (finds closest available date)
  static Future<MutualFundNav?> fetchNavForDate(
    String schemeCode,
    DateTime targetDate,
  ) async {
    try {
      final historicalData = await fetchHistoricalNav(schemeCode, limitDays: 60);
      
      if (historicalData.isEmpty) return null;

      // Find the closest date to target date
      MutualFundNav? closestNav;
      int minDaysDiff = 999999;

      for (var nav in historicalData) {
        final daysDiff = (nav.date.difference(targetDate).inDays).abs();
        if (daysDiff < minDaysDiff) {
          minDaysDiff = daysDiff;
          closestNav = nav;
        }
      }

      return closestNav;
    } catch (e) {
      print('Error fetching NAV for date: $e');
      return null;
    }
  }
}

/// Mutual Fund NAV data model
class MutualFundNav {
  final DateTime date;
  final double nav;
  final String schemeName;
  final String schemeCode;

  MutualFundNav({
    required this.date,
    required this.nav,
    required this.schemeName,
    required this.schemeCode,
  });

  @override
  String toString() => 'NAV: ₹$nav on ${date.toLocal().toString().split(' ')[0]}';
}

/// Mutual Fund Scheme model
class MutualFundScheme {
  final String schemeCode;
  final String schemeName;
  final String fundHouse;

  MutualFundScheme({
    required this.schemeCode,
    required this.schemeName,
    required this.fundHouse,
  });
}
