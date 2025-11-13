import 'package:http/http.dart' as http;

/// Script to find and verify all AMFI scheme codes for mutual funds in our database
/// This will help update mutual_fund_scheme_codes.dart with correct codes

void main() async {
  print('╔══════════════════════════════════════════════════════════════╗');
  print('║       AMFI Scheme Code Finder & Verifier                    ║');
  print('╚══════════════════════════════════════════════════════════════╝\n');

  // List of funds to search (from indian_stock_symbols.dart)
  final fundsToFind = {
    'SBI-BLUECHIP': 'SBI Bluechip',
    'HDFC-TOP100': 'HDFC Top 100',
    'ICICI-BLUECHIP': 'ICICI Prudential Bluechip',
    'AXIS-BLUECHIP': 'Axis Bluechip',
    'MIRAE-LARGECAP': 'Mirae Asset Large Cap',
    'PARAG-FLEXI': 'Parag Parikh Flexi Cap',
    'AXIS-MIDCAP': 'Axis Midcap',
    'HDFC-MIDCAP': 'HDFC Mid-Cap Opportunities',
    'AXIS-ELSS': 'Axis Long Term Equity',
    'MIRAE-ELSS': 'Mirae Asset Tax Saver',
  };

  try {
    print('📥 Fetching AMFI data...');
    final url = Uri.parse('https://www.amfiindia.com/spages/NAVAll.txt');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      print('✅ Data fetched successfully! (${response.body.length} bytes)\n');
      
      final lines = response.body.split('\n');
      print('📊 Total lines: ${lines.length}\n');
      print('═══════════════════════════════════════════════════════════════\n');

      int found = 0;
      int notFound = 0;

      for (var entry in fundsToFind.entries) {
        final code = entry.key;
        final searchTerm = entry.value;
        
        print('🔍 Searching for: $code');
        print('   Query: "$searchTerm Direct.*Growth"');
        
        bool foundMatch = false;
        for (var line in lines) {
          if (line.contains('Direct') && 
              line.contains('Growth') && 
              line.toLowerCase().contains(searchTerm.toLowerCase())) {
            
            final parts = line.split(';');
            if (parts.length >= 6) {
              final schemeCode = parts[0].trim();
              final schemeName = parts[3].trim();
              final nav = parts[4].trim();
              final date = parts[5].trim();
              
              print('   ✅ FOUND!');
              print('   ├─ Scheme Code: $schemeCode');
              print('   ├─ Name: ${schemeName.substring(0, schemeName.length > 60 ? 60 : schemeName.length)}...');
              print('   ├─ NAV: ₹$nav');
              print('   └─ Date: $date');
              print('   Code to use: \'$code\': \'$schemeCode\',\n');
              
              foundMatch = true;
              found++;
              break;
            }
          }
        }
        
        if (!foundMatch) {
          print('   ❌ NOT FOUND');
          print('   Try searching manually at: https://www.amfiindia.com/\n');
          notFound++;
        }
      }

      print('═══════════════════════════════════════════════════════════════');
      print('\n📈 Summary:');
      print('   ✅ Found: $found');
      print('   ❌ Not Found: $notFound');
      print('   Total: ${found + notFound}');
      
      if (notFound > 0) {
        print('\n💡 Tip: For funds not found, try:');
        print('   1. Search exact fund name at https://www.amfiindia.com/');
        print('   2. Make sure to look for "Direct Plan - Growth" option');
        print('   3. Check if fund name has changed or been renamed');
      }

      print('\n✏️  Copy the codes above to lib/utils/mutual_fund_scheme_codes.dart');
      
    } else {
      print('❌ Error: HTTP ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Exception: $e');
  }
}
