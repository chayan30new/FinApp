import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

// Copy of the scheme codes from the app
final Map<String, String> mutualFundSchemeCodes = {
  // Large Cap Funds
  'SBI-BLUECHIP': '119598',
  'HDFC-TOP100': '119533',
  'ICICI-BLUECHIP': '120503',
  'AXIS-BLUECHIP': '120503',
  'KOTAK-BLUECHIP': '119230',
  'MIRAE-LARGECAP': '118825',
  'NIPPON-LARGECAP': '119097',
  'PARAG-LARGECAP': '122639',
  'UTI-MASTERSHARE': '100109',
  'DSP-TOP100': '119526',
  
  // Mid Cap Funds
  'AXIS-MIDCAP': '120505',
  'KOTAK-EMERGEQUITY': '119167',
  'DSP-MIDCAP': '119527',
  'HDFC-MIDCAP': '119535',
  'SBI-MAGNUM-MIDCAP': '103023',
  'MIRAE-EMERGING': '118826',
  'NIPPON-GROWTH': '100132',
  'PARAG-MIDCAP': '122640',
  'ICICI-MIDCAP': '120504',
  'UTI-MIDCAP': '100111',
  
  // Small Cap Funds
  'AXIS-SMALLCAP': '120506',
  'KOTAK-SMALLCAP': '119168',
  'DSP-SMALLCAP': '119528',
  'HDFC-SMALLCAP': '119536',
  'SBI-SMALLCAP': '119600',
  'NIPPON-SMALLCAP': '119098',
  'PARAG-SMALLCAP': '122641',
  'ICICI-SMALLCAP': '120505',
  'UTI-MIDCAP-SELECT': '100112',
  'QUANT-SMALLCAP': '112316',
  
  // Multi Cap Funds
  'PARAG-FLEXI': '122639',
  'AXIS-MULTICAP': '135789',
  'KOTAK-MULTICAP': '119168',
  'DSP-MULTICAP': '119529',
  'HDFC-FLEXI': '119534',
  'SBI-MULTICAP': '119597',
  'MIRAE-MULTICAP': '118827',
  'NIPPON-MULTICAP': '119099',
  'ICICI-MULTICAP': '120506',
  'UTI-FLEXI': '100113',
  
  // Flexi Cap Funds
  'PARAG-FLEXI-CAP': '122639',
  'AXIS-FLEXI-CAP': '135790',
  'KOTAK-FLEXI-CAP': '119169',
  'DSP-FLEXI-CAP': '119530',
  'HDFC-FLEXI-CAP': '119537',
  'SBI-FLEXI-CAP': '119601',
  'MIRAE-FLEXI-CAP': '118828',
  'NIPPON-FLEXI-CAP': '119100',
  'ICICI-FLEXI-CAP': '120507',
  'UTI-FLEXI-CAP': '100114',
  
  // Focused Funds
  'AXIS-FOCUSED': '135791',
  'SBI-FOCUSED': '119602',
  'MIRAE-FOCUSED': '118829',
  'NIPPON-FOCUSED': '119101',
  'ICICI-FOCUSED': '120508',
  'DSP-FOCUSED': '119531',
  'HDFC-FOCUSED': '119538',
  'KOTAK-FOCUSED': '119170',
  'PARAG-FOCUSED': '122642',
  'UTI-FOCUSED': '100115',
  
  // Sectoral/Thematic Funds
  'SBI-TECHNOLOGY': '103026',
  'ICICI-TECHNOLOGY': '120509',
  'NIPPON-PHARMA': '100234',
  'ICICI-BANKING': '100227',
  'SBI-BANKING': '100228',
  'ICICI-INFRA': '100229',
  'SBI-INFRA': '100230',
  'ICICI-FMCG': '100231',
  'MIRAE-HEALTHCARE': '118830',
  'DSP-NATURAL-RESOURCES': '119532',
  
  // Value Funds
  'AXIS-VALUE': '135792',
  'SBI-CONTRA': '103024',
  'ICICI-VALUE': '100232',
  'NIPPON-VALUE': '119102',
  'DSP-VALUE': '119533',
  'HDFC-VALUE': '119539',
  'KOTAK-VALUE': '119171',
  'PARAG-VALUE': '122643',
  'UTI-VALUE': '100116',
  'MIRAE-VALUE': '118831',
  
  // ELSS (Tax Saving) Funds
  'AXIS-ELSS': '120506',
  'MIRAE-TAX-SAVER': '125497',
  'PARAG-ELSS': '119618',
  'DSP-ELSS': '119551',
  'HDFC-ELSS': '100019',
  'ICICI-ELSS': '100315',
  'SBI-ELSS': '119183',
  'KOTAK-ELSS': '112271',
  'NIPPON-ELSS': '100126',
  'UTI-ELSS': '100037',
  
  // Hybrid/Balanced Funds
  'ICICI-HYBRID': '120251', // CORRECTED: ICICI Prudential Equity & Debt Fund - Direct Plan - Growth (NAV ~₹450)
  'HDFC-HYBRID': '103007',
  'SBI-HYBRID': '103025',
  'AXIS-HYBRID': '135793',
  'KOTAK-HYBRID': '119172',
  'MIRAE-HYBRID': '118832',
  'NIPPON-HYBRID': '119103',
  'DSP-HYBRID': '119534',
  'PARAG-HYBRID': '122644',
  'UTI-HYBRID': '100117',
};

class SchemeInfo {
  final String schemeCode;
  final String schemeName;
  final String nav;
  final String date;
  final bool isDirect;
  final bool isGrowth;

  SchemeInfo({
    required this.schemeCode,
    required this.schemeName,
    required this.nav,
    required this.date,
    required this.isDirect,
    required this.isGrowth,
  });
}

Future<void> main() async {
  print('Fetching AMFI NAV data...\n');
  
  try {
    final response = await http.get(
      Uri.parse('https://www.amfiindia.com/spages/NAVAll.txt'),
    );

    if (response.statusCode != 200) {
      print('Error: Failed to fetch AMFI data (Status: ${response.statusCode})');
      return;
    }

    print('Parsing AMFI data...\n');
    final lines = response.body.split('\n');
    final Map<String, SchemeInfo> amfiData = {};

    for (var line in lines) {
      final parts = line.split(';');
      if (parts.length >= 5) {
        final schemeCode = parts[0].trim();
        final schemeName = parts[3].trim();
        final nav = parts[4].trim();
        final date = parts.length > 5 ? parts[5].trim() : '';

        if (schemeCode.isNotEmpty && schemeCode != 'Scheme Code') {
          amfiData[schemeCode] = SchemeInfo(
            schemeCode: schemeCode,
            schemeName: schemeName,
            nav: nav,
            date: date,
            isDirect: schemeName.toLowerCase().contains('direct'),
            isGrowth: schemeName.toLowerCase().contains('growth'),
          );
        }
      }
    }

    print('Total AMFI schemes loaded: ${amfiData.length}\n');
    print('=' * 100);
    print('VERIFICATION REPORT');
    print('=' * 100);
    print('\n');

    var verifiedCount = 0;
    var issuesFound = 0;
    var notFoundCount = 0;
    final List<String> issues = [];

    for (var entry in mutualFundSchemeCodes.entries) {
      final symbol = entry.key;
      final schemeCode = entry.value;
      
      if (amfiData.containsKey(schemeCode)) {
        final info = amfiData[schemeCode]!;
        final isDirect = info.isDirect;
        final isGrowth = info.isGrowth;
        
        print('✓ $symbol');
        print('  Code: $schemeCode');
        print('  Name: ${info.schemeName}');
        print('  NAV: ₹${info.nav} (${info.date})');
        
        // Check if it's Direct Plan and Growth option
        if (!isDirect) {
          print('  ⚠️  WARNING: This is NOT a Direct Plan (Regular Plan detected)');
          issues.add('$symbol ($schemeCode): Regular Plan - Should be Direct Plan');
          issuesFound++;
        }
        
        if (!isGrowth && !info.schemeName.toLowerCase().contains('idcw')) {
          print('  ⚠️  WARNING: This might not be a Growth option');
          issues.add('$symbol ($schemeCode): Not Growth option - ${info.schemeName}');
          issuesFound++;
        }
        
        if (isDirect && isGrowth) {
          verifiedCount++;
        }
        
        print('');
      } else {
        print('✗ $symbol');
        print('  Code: $schemeCode');
        print('  ⚠️  ERROR: Scheme code NOT FOUND in AMFI database');
        print('');
        issues.add('$symbol ($schemeCode): NOT FOUND in AMFI database');
        notFoundCount++;
        issuesFound++;
      }
    }

    print('=' * 100);
    print('SUMMARY');
    print('=' * 100);
    print('Total schemes checked: ${mutualFundSchemeCodes.length}');
    print('✓ Verified (Direct + Growth): $verifiedCount');
    print('⚠️  Issues found: $issuesFound');
    print('✗ Not found in AMFI: $notFoundCount');
    print('');

    if (issues.isNotEmpty) {
      print('=' * 100);
      print('ISSUES REQUIRING ATTENTION');
      print('=' * 100);
      for (var issue in issues) {
        print('• $issue');
      }
      print('');
    }

    if (issuesFound == 0) {
      print('🎉 All scheme codes are verified and correct!');
    } else {
      print('⚠️  Please review and correct the issues above.');
      print('   Most issues are likely Regular Plans that should be Direct Plans.');
    }

  } catch (e) {
    print('Error: $e');
  }
}
