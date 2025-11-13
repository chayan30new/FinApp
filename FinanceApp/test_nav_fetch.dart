import 'package:http/http.dart' as http;

/// Quick test to verify NAV fetching works
void main() async {
  print('Testing NAV fetch for SBI Bluechip (119598)...\n');
  
  try {
    final url = Uri.parse('https://www.amfiindia.com/spages/NAVAll.txt');
    print('Fetching from: $url');
    final response = await http.get(url);
    
    if (response.statusCode == 200) {
      print('✅ Response received: ${response.body.length} bytes\n');
      
      // Search for scheme code 119598
      final lines = response.body.split('\n');
      bool found = false;
      
      for (var line in lines) {
        if (line.startsWith('119598;')) {
          print('✅ Found SBI Bluechip!');
          print('Raw line: $line\n');
          
          final parts = line.split(';');
          if (parts.length >= 6) {
            print('Parsed data:');
            print('  Scheme Code: ${parts[0]}');
            print('  ISIN: ${parts[1]}');
            print('  Scheme Name: ${parts[3]}');
            print('  NAV: ${parts[4]}');
            print('  Date: ${parts[5]}');
            
            // Test parsing
            final nav = double.tryParse(parts[4].trim());
            if (nav != null) {
              print('\n✅ NAV successfully parsed: ₹$nav');
            } else {
              print('\n❌ Failed to parse NAV from: "${parts[4]}"');
            }
          }
          found = true;
          break;
        }
      }
      
      if (!found) {
        print('❌ Scheme code 119598 not found in AMFI data');
        print('Showing first 5 lines of data:');
        for (int i = 0; i < 5 && i < lines.length; i++) {
          print('  $i: ${lines[i]}');
        }
      }
    } else {
      print('❌ HTTP Error: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Exception: $e');
  }
}
