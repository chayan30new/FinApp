import 'dart:io';
import 'package:http/http.dart' as http;

class MutualFundScheme {
  final String code;
  final String isin;
  final String isinReinv;
  final String name;
  final String nav;
  final String date;

  MutualFundScheme({
    required this.code,
    required this.isin,
    required this.isinReinv,
    required this.name,
    required this.nav,
    required this.date,
  });

  bool get isDirect => name.toLowerCase().contains('direct');
  bool get isGrowth => name.toLowerCase().contains('growth');
  bool get isRegular => name.toLowerCase().contains('regular');
}

Future<List<MutualFundScheme>> fetchAMFIData() async {
  print('Fetching AMFI data...');
  final response = await http.get(
    Uri.parse('https://www.amfiindia.com/spages/NAVAll.txt'),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to fetch AMFI data');
  }

  final schemes = <MutualFundScheme>[];
  final lines = response.body.split('\n');

  for (var line in lines) {
    final parts = line.split(';');
    if (parts.length >= 5 && parts[0].trim().isNotEmpty && parts[0].trim() != 'Scheme Code') {
      schemes.add(MutualFundScheme(
        code: parts[0].trim(),
        isin: parts[1].trim(),
        isinReinv: parts.length > 2 ? parts[2].trim() : '',
        name: parts[3].trim(),
        nav: parts[4].trim(),
        date: parts.length > 5 ? parts[5].trim() : '',
      ));
    }
  }

  print('Loaded ${schemes.length} schemes\n');
  return schemes;
}

void searchFunds(List<MutualFundScheme> schemes, String query, {bool directOnly = true, bool growthOnly = true}) {
  final lowerQuery = query.toLowerCase();
  final results = schemes.where((s) {
    final nameMatch = s.name.toLowerCase().contains(lowerQuery);
    final directMatch = !directOnly || s.isDirect;
    final growthMatch = !growthOnly || s.isGrowth;
    return nameMatch && directMatch && growthMatch;
  }).toList();

  if (results.isEmpty) {
    print('No results found for "$query"');
    return;
  }

  print('\nFound ${results.length} matching schemes:');
  print('=' * 120);
  
  for (var i = 0; i < results.length && i < 20; i++) {
    final scheme = results[i];
    print('${i + 1}. Code: ${scheme.code}');
    print('   Name: ${scheme.name}');
    print('   NAV: ₹${scheme.nav} (${scheme.date})');
    print('   Type: ${scheme.isDirect ? "Direct" : "Regular"} | ${scheme.isGrowth ? "Growth" : "Other"}');
    print('');
  }
  
  if (results.length > 20) {
    print('... and ${results.length - 20} more results. Refine your search for better results.');
  }
}

void main(List<String> arguments) async {
  print('=' * 120);
  print('MUTUAL FUND SCHEME CODE SEARCH TOOL');
  print('=' * 120);
  print('');

  final schemes = await fetchAMFIData();

  if (arguments.isNotEmpty) {
    // Search from command line arguments
    final query = arguments.join(' ');
    searchFunds(schemes, query);
    return;
  }

  // Interactive mode
  print('Interactive search mode. Type fund name to search (e.g., "ICICI Bluechip", "SBI Large Cap")');
  print('Commands: "direct" (show only direct plans), "all" (show all plans), "quit" (exit)');
  print('');

  var directOnly = true;
  var growthOnly = true;

  while (true) {
    stdout.write('Search > ');
    final input = stdin.readLineSync()?.trim() ?? '';

    if (input.isEmpty) continue;
    if (input.toLowerCase() == 'quit' || input.toLowerCase() == 'exit') {
      print('Goodbye!');
      break;
    }
    if (input.toLowerCase() == 'direct') {
      directOnly = true;
      growthOnly = true;
      print('✓ Showing only Direct Plan - Growth options\n');
      continue;
    }
    if (input.toLowerCase() == 'all') {
      directOnly = false;
      growthOnly = false;
      print('✓ Showing all plans\n');
      continue;
    }

    searchFunds(schemes, input, directOnly: directOnly, growthOnly: growthOnly);
  }
}
