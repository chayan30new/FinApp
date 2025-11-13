import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Enhanced mutual fund search tool using MF API
/// Based on https://github.com/rajadilipkolli/mfscreener architecture
class MutualFundSearcher {
  static const String mfApiBase = 'https://api.mfapi.in';
  static const String amfiNavUrl = 'https://www.amfiindia.com/spages/NAVAll.txt';
  
  // Cache for scheme data
  static Map<String, SchemeDetails>? _allSchemes;
  static DateTime? _cacheTime;
  static const cacheDuration = Duration(hours: 1);

  /// Fetch all schemes from AMFI (cached)
  static Future<Map<String, SchemeDetails>> getAllSchemes() async {
    // Return cached data if still fresh
    if (_allSchemes != null && 
        _cacheTime != null && 
        DateTime.now().difference(_cacheTime!) < cacheDuration) {
      return _allSchemes!;
    }

    print('Fetching fresh AMFI data...');
    final response = await http.get(Uri.parse(amfiNavUrl));
    
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch AMFI data');
    }

    final schemes = <String, SchemeDetails>{};
    final lines = response.body.split('\n');
    String? currentFundHouse;

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;

      // Fund house name lines don't have semicolons
      if (!line.contains(';')) {
        currentFundHouse = line;
        continue;
      }

      final parts = line.split(';');
      if (parts.length >= 5 && parts[0].isNotEmpty && parts[0] != 'Scheme Code') {
        final code = parts[0].trim();
        schemes[code] = SchemeDetails(
          schemeCode: code,
          isin: parts[1].trim(),
          isinReinv: parts.length > 2 ? parts[2].trim() : '',
          schemeName: parts[3].trim(),
          nav: parts[4].trim(),
          date: parts.length > 5 ? parts[5].trim() : '',
          fundHouse: currentFundHouse ?? 'Unknown',
        );
      }
    }

    _allSchemes = schemes;
    _cacheTime = DateTime.now();
    print('Loaded ${schemes.length} schemes\n');
    
    return schemes;
  }

  /// Search schemes by name with smart filtering
  static Future<List<SchemeDetails>> searchSchemes(
    String query, {
    bool directOnly = true,
    bool growthOnly = true,
    String? fundHouse,
    String? category,
  }) async {
    final allSchemes = await getAllSchemes();
    final lowerQuery = query.toLowerCase();
    
    final results = allSchemes.values.where((scheme) {
      final nameLower = scheme.schemeName.toLowerCase();
      
      // Name matching
      final nameMatch = nameLower.contains(lowerQuery);
      if (!nameMatch) return false;
      
      // Direct Plan filter
      if (directOnly && !scheme.isDirect) return false;
      
      // Growth option filter
      if (growthOnly && !scheme.isGrowth) return false;
      
      // Fund house filter
      if (fundHouse != null && 
          !scheme.fundHouse.toLowerCase().contains(fundHouse.toLowerCase())) {
        return false;
      }
      
      // Category filter
      if (category != null && 
          !nameLower.contains(category.toLowerCase())) {
        return false;
      }
      
      return true;
    }).toList();

    // Sort by relevance (exact matches first, then by NAV)
    results.sort((a, b) {
      // Prioritize exact fund house matches
      if (fundHouse != null) {
        final aExact = a.fundHouse.toLowerCase().contains(fundHouse.toLowerCase());
        final bExact = b.fundHouse.toLowerCase().contains(fundHouse.toLowerCase());
        if (aExact && !bExact) return -1;
        if (!aExact && bExact) return 1;
      }
      
      // Then by scheme name length (shorter is more specific)
      return a.schemeName.length.compareTo(b.schemeName.length);
    });

    return results;
  }

  /// Search by fund house and category
  static Future<List<SchemeDetails>> searchByCategory(
    String fundHouse,
    String category, {
    bool directOnly = true,
    bool growthOnly = true,
  }) async {
    return searchSchemes(
      category,
      directOnly: directOnly,
      growthOnly: growthOnly,
      fundHouse: fundHouse,
    );
  }

  /// Get scheme details by code
  static Future<SchemeDetails?> getSchemeByCode(String schemeCode) async {
    final allSchemes = await getAllSchemes();
    return allSchemes[schemeCode];
  }

  /// Verify a scheme code is correct
  static Future<Map<String, dynamic>> verifySchemeCode(
    String schemeCode,
    String expectedFundHouse,
    String expectedCategory,
  ) async {
    final scheme = await getSchemeByCode(schemeCode);
    
    if (scheme == null) {
      return {
        'valid': false,
        'error': 'Scheme code not found in AMFI database',
      };
    }

    final issues = <String>[];
    
    if (!scheme.isDirect) {
      issues.add('Regular Plan (should be Direct Plan)');
    }
    
    if (!scheme.isGrowth) {
      issues.add('Not Growth option');
    }
    
    if (!scheme.fundHouse.toLowerCase().contains(expectedFundHouse.toLowerCase())) {
      issues.add('Wrong fund house: ${scheme.fundHouse} (expected $expectedFundHouse)');
    }
    
    if (!scheme.schemeName.toLowerCase().contains(expectedCategory.toLowerCase())) {
      issues.add('Wrong category (expected $expectedCategory)');
    }

    return {
      'valid': issues.isEmpty,
      'scheme': scheme.toMap(),
      'issues': issues,
    };
  }

  /// Smart fund matcher - suggests correct scheme for a given fund
  static Future<List<SchemeDetails>> findBestMatch(
    String fundSymbol,
    Map<String, String> fundMetadata,
  ) async {
    final fundHouse = fundMetadata['fundHouse'] ?? '';
    final category = fundMetadata['category'] ?? '';
    final keywords = fundMetadata['keywords'] ?? '';

    // Try exact category match first
    var results = await searchByCategory(fundHouse, category);
    
    // If no results, try with keywords
    if (results.isEmpty && keywords.isNotEmpty) {
      results = await searchSchemes(keywords, fundHouse: fundHouse);
    }
    
    // If still no results, try broader search
    if (results.isEmpty) {
      results = await searchSchemes(fundHouse);
    }

    return results.take(5).toList();
  }
}

class SchemeDetails {
  final String schemeCode;
  final String isin;
  final String isinReinv;
  final String schemeName;
  final String nav;
  final String date;
  final String fundHouse;

  SchemeDetails({
    required this.schemeCode,
    required this.isin,
    required this.isinReinv,
    required this.schemeName,
    required this.nav,
    required this.date,
    required this.fundHouse,
  });

  bool get isDirect => schemeName.toLowerCase().contains('direct');
  bool get isGrowth => schemeName.toLowerCase().contains('growth');
  bool get isRegular => schemeName.toLowerCase().contains('regular');
  bool get isLargeCap => schemeName.toLowerCase().contains('large cap') ||
      schemeName.toLowerCase().contains('bluechip') ||
      schemeName.toLowerCase().contains('top 100');
  bool get isMidCap => schemeName.toLowerCase().contains('mid cap') ||
      schemeName.toLowerCase().contains('midcap');
  bool get isSmallCap => schemeName.toLowerCase().contains('small cap') ||
      schemeName.toLowerCase().contains('smallcap');

  Map<String, dynamic> toMap() => {
        'schemeCode': schemeCode,
        'schemeName': schemeName,
        'fundHouse': fundHouse,
        'nav': nav,
        'date': date,
        'isDirect': isDirect,
        'isGrowth': isGrowth,
      };

  void displayDetails() {
    print('Code: $schemeCode');
    print('Fund House: $fundHouse');
    print('Name: $schemeName');
    print('NAV: ₹$nav ($date)');
    print('Type: ${isDirect ? "Direct" : "Regular"} | ${isGrowth ? "Growth" : "Other"}');
  }
}

// Fund metadata for intelligent matching
const Map<String, Map<String, String>> fundMetadata = {
  'HDFC-TOP100': {
    'fundHouse': 'HDFC',
    'category': 'large cap',
    'keywords': 'top 100 equity',
  },
  'ICICI-BLUECHIP': {
    'fundHouse': 'ICICI Prudential',
    'category': 'large cap',
    'keywords': 'bluechip equity focused',
  },
  'AXIS-BLUECHIP': {
    'fundHouse': 'Axis',
    'category': 'large cap',
    'keywords': 'bluechip',
  },
  'SBI-SMALLCAP': {
    'fundHouse': 'SBI',
    'category': 'small cap',
    'keywords': 'small cap',
  },
  'HDFC-ELSS': {
    'fundHouse': 'HDFC',
    'category': 'elss',
    'keywords': 'tax saver',
  },
  'ICICI-ELSS': {
    'fundHouse': 'ICICI Prudential',
    'category': 'elss',
    'keywords': 'tax plan long term',
  },
  'AXIS-ELSS': {
    'fundHouse': 'Axis',
    'category': 'elss',
    'keywords': 'long term equity tax saver',
  },
  'PARAG-ELSS': {
    'fundHouse': 'Parag Parikh',
    'category': 'elss',
    'keywords': 'tax saver',
  },
};

void main(List<String> arguments) async {
  print('=' * 120);
  print('ENHANCED MUTUAL FUND SEARCH TOOL');
  print('Based on mfscreener (github.com/rajadilipkolli/mfscreener) architecture');
  print('=' * 120);
  print('');

  if (arguments.isNotEmpty) {
    final command = arguments[0].toLowerCase();
    
    switch (command) {
      case 'search':
        if (arguments.length < 2) {
          print('Usage: dart run enhanced_search.dart search <query>');
          return;
        }
        final query = arguments.sublist(1).join(' ');
        final results = await MutualFundSearcher.searchSchemes(query);
        _displayResults(results);
        break;
        
      case 'fix':
        if (arguments.length < 2) {
          print('Usage: dart run enhanced_search.dart fix <FUND-SYMBOL>');
          print('Example: dart run enhanced_search.dart fix HDFC-TOP100');
          return;
        }
        final symbol = arguments[1].toUpperCase();
        await _fixFund(symbol);
        break;
        
      case 'verify':
        if (arguments.length < 2) {
          print('Usage: dart run enhanced_search.dart verify <scheme-code>');
          return;
        }
        final code = arguments[1];
        await _verifyCode(code);
        break;
        
      case 'batch':
        await _batchFix();
        break;
        
      default:
        _printUsage();
    }
    return;
  }

  // Interactive mode
  _printUsage();
}

void _printUsage() {
  print('Commands:');
  print('  search <query>        - Search for funds');
  print('  fix <FUND-SYMBOL>     - Find correct code for a fund');
  print('  verify <scheme-code>  - Verify a scheme code');
  print('  batch                 - Auto-fix all broken funds');
  print('');
  print('Examples:');
  print('  dart run enhanced_search.dart search "icici large cap"');
  print('  dart run enhanced_search.dart fix HDFC-TOP100');
  print('  dart run enhanced_search.dart verify 119533');
  print('  dart run enhanced_search.dart batch');
}

void _displayResults(List<SchemeDetails> results) {
  if (results.isEmpty) {
    print('No results found');
    return;
  }

  print('\nFound ${results.length} matching schemes:');
  print('=' * 120);
  
  for (var i = 0; i < results.length && i < 20; i++) {
    print('\n${i + 1}. ');
    results[i].displayDetails();
  }
  
  if (results.length > 20) {
    print('\n... and ${results.length - 20} more results');
  }
}

Future<void> _fixFund(String symbol) async {
  print('\nFinding correct scheme code for: $symbol\n');
  
  if (!fundMetadata.containsKey(symbol)) {
    print('No metadata found for $symbol');
    print('Available funds: ${fundMetadata.keys.join(", ")}');
    return;
  }

  final metadata = fundMetadata[symbol]!;
  print('Searching for:');
  print('  Fund House: ${metadata['fundHouse']}');
  print('  Category: ${metadata['category']}');
  print('  Keywords: ${metadata['keywords']}');
  print('');

  final results = await MutualFundSearcher.findBestMatch(symbol, metadata);
  
  if (results.isEmpty) {
    print('❌ No matching funds found');
    print('Try searching manually or check if fund was renamed/merged');
    return;
  }

  print('✅ Found ${results.length} potential matches:\n');
  print('=' * 120);
  
  for (var i = 0; i < results.length; i++) {
    print(i == 0 ? '\n${i + 1}. [RECOMMENDED]' : '\n${i + 1}. ');
    results[i].displayDetails();
  }

  print('\n' + '=' * 120);
  print('\nTO UPDATE:');
  print('Edit lib/utils/mutual_fund_scheme_codes.dart:');
  print("'$symbol': '${results[0].schemeCode}',  // ${results[0].schemeName}");
}

Future<void> _verifyCode(String code) async {
  print('\nVerifying scheme code: $code\n');
  
  final scheme = await MutualFundSearcher.getSchemeByCode(code);
  
  if (scheme == null) {
    print('❌ Scheme code not found in AMFI database');
    return;
  }

  print('✅ Found scheme:\n');
  scheme.displayDetails();
  
  if (!scheme.isDirect || !scheme.isGrowth) {
    print('\n⚠️  WARNINGS:');
    if (!scheme.isDirect) print('  - This is a Regular Plan (not Direct)');
    if (!scheme.isGrowth) print('  - This is not a Growth option');
  }
}

Future<void> _batchFix() async {
  print('\nBatch fixing all broken funds...\n');
  print('This will search for correct codes for all funds in metadata.');
  print('Processing ${fundMetadata.length} funds...\n');
  
  for (var entry in fundMetadata.entries) {
    print('─' * 120);
    await _fixFund(entry.key);
    print('');
  }
  
  print('=' * 120);
  print('Batch processing complete!');
  print('Review the suggestions above and update mutual_fund_scheme_codes.dart');
}
