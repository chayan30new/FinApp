import 'dart:convert';
import 'package:http/http.dart' as http;

/// Quick script to search for AMFI scheme codes
/// Run this to find the correct scheme codes for your mutual funds
/// 
/// Usage: dart run lib/tools/find_scheme_codes.dart

void main() async {
  print('=== AMFI Scheme Code Finder ===\n');

  // List of fund names to search
  final fundSearches = [
    'SBI Bluechip Fund Direct Growth',
    'HDFC Top 100 Fund Direct Growth',
    'ICICI Prudential Bluechip Fund Direct Growth',
    'Axis Bluechip Fund Direct Growth',
    'Mirae Asset Large Cap Fund Direct Growth',
    'Parag Parikh Flexi Cap Fund Direct Growth',
    'Axis Long Term Equity Fund Direct Growth', // ELSS
    'HDFC Tax Saver Fund Direct Growth', // ELSS
  ];

  for (final fundName in fundSearches) {
    print('Searching for: $fundName');
    await searchFund(fundName);
    print('---');
  }
}

Future<void> searchFund(String fundName) async {
  try {
    final encodedQuery = Uri.encodeComponent(fundName);
    final url = Uri.parse('https://api.mfapi.in/mf/search?q=$encodedQuery');
    
    print('  URL: $url');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> results = json.decode(response.body);
      
      if (results.isEmpty) {
        print('  ❌ No results found\n');
        return;
      }

      print('  ✅ Found ${results.length} result(s):');
      
      // Show top 3 results
      for (int i = 0; i < results.length && i < 3; i++) {
        final fund = results[i];
        print('    ${i + 1}. Scheme Code: ${fund['schemeCode']}');
        print('       Name: ${fund['schemeName']}');
      }
      print('');
    } else {
      print('  ❌ Error: HTTP ${response.statusCode}\n');
    }
  } catch (e) {
    print('  ❌ Exception: $e\n');
  }
}
