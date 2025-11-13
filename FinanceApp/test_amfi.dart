import 'package:http/http.dart' as http;

/// Quick test to check AMFI data format
void main() async {
  print('Fetching AMFI data...\n');
  
  try {
    final url = Uri.parse('https://www.amfiindia.com/spages/NAVAll.txt');
    final response = await http.get(url);
    
    if (response.statusCode == 200) {
      final lines = response.body.split('\n');
      print('Total lines: ${lines.length}');
      print('\nFirst 5 lines:');
      for (int i = 0; i < 5 && i < lines.length; i++) {
        print('$i: ${lines[i]}');
      }
      
      print('\n\nSearching for SBI Bluechip (119598):');
      for (var line in lines) {
        if (line.startsWith('119598')) {
          print('Found: $line');
          final parts = line.split(';');
          print('Parts (${parts.length}):');
          for (int i = 0; i < parts.length; i++) {
            print('  [$i]: "${parts[i]}"');
          }
          break;
        }
      }
      
      print('\n\nSearching for any Direct Growth fund:');
      int count = 0;
      for (var line in lines) {
        if (line.contains('Direct') && line.contains('Growth') && count < 3) {
          print('Found: ${line.substring(0, line.length > 100 ? 100 : line.length)}...');
          count++;
        }
      }
    } else {
      print('Error: HTTP ${response.statusCode}');
    }
  } catch (e) {
    print('Exception: $e');
  }
}
