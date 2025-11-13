/// Common Australian Stock/ETF Symbols
/// Use this as a quick reference guide

class AustralianStockSymbols {
  // Major Banks
  static const banks = {
    'CBA.AX': 'Commonwealth Bank',
    'WBC.AX': 'Westpac',
    'NAB.AX': 'National Australia Bank',
    'ANZ.AX': 'ANZ Banking Group',
    'MQG.AX': 'Macquarie Group',
  };

  // Major Miners
  static const miners = {
    'BHP.AX': 'BHP Group',
    'RIO.AX': 'Rio Tinto',
    'FMG.AX': 'Fortescue Metals',
    'NCM.AX': 'Newcrest Mining',
    'S32.AX': 'South32',
  };

  // Technology
  static const tech = {
    'WTC.AX': 'WiseTech Global',
    'XRO.AX': 'Xero',
    'CPU.AX': 'Computershare',
    'APX.AX': 'Appen',
    'ALU.AX': 'Altium',
  };

  // Popular ETFs
  static const etfs = {
    'VAS.AX': 'Vanguard Australian Shares Index ETF',
    'VGS.AX': 'Vanguard MSCI Index International Shares ETF',
    'IOZ.AX': 'iShares Core S&P/ASX 200 ETF',
    'A200.AX': 'BetaShares Australia 200 ETF',
    'IVV.AX': 'iShares S&P 500 ETF',
    'VTS.AX': 'Vanguard US Total Market Shares Index ETF',
    'VEU.AX': 'Vanguard All-World ex-US Shares Index ETF',
    'NDQ.AX': 'BetaShares NASDAQ 100 ETF',
    'VDHG.AX': 'Vanguard Diversified High Growth Index ETF',
    'DHHF.AX': 'BetaShares Diversified All Growth ETF',
  };

  // Retail
  static const retail = {
    'WES.AX': 'Wesfarmers (Bunnings, Kmart)',
    'WOW.AX': 'Woolworths',
    'COL.AX': 'Coles',
    'JBH.AX': 'JB Hi-Fi',
    'HVN.AX': 'Harvey Norman',
  };

  // Telecom & Media
  static const telecom = {
    'TLS.AX': 'Telstra',
    'TPG.AX': 'TPG Telecom',
    'NXT.AX': 'NextDC',
    'SEK.AX': 'Seek',
    'REA.AX': 'REA Group',
  };

  // Healthcare
  static const healthcare = {
    'CSL.AX': 'CSL Limited',
    'RMD.AX': 'ResMed',
    'COH.AX': 'Cochlear',
    'SHL.AX': 'Sonic Healthcare',
    'RHC.AX': 'Ramsay Health Care',
  };

  // Get all symbols
  static Map<String, String> getAllSymbols() {
    return {
      ...banks,
      ...miners,
      ...tech,
      ...etfs,
      ...retail,
      ...telecom,
      ...healthcare,
    };
  }

  // Search for symbols
  static Map<String, String> search(String query) {
    final allSymbols = getAllSymbols();
    final queryLower = query.toLowerCase();
    
    return Map.fromEntries(
      allSymbols.entries.where((entry) {
        return entry.key.toLowerCase().contains(queryLower) ||
               entry.value.toLowerCase().contains(queryLower);
      }),
    );
  }

  // Get suggestions based on partial input
  static List<String> getSuggestions(String partial) {
    if (partial.isEmpty) return [];
    
    final allSymbols = getAllSymbols();
    final partialUpper = partial.toUpperCase();
    
    return allSymbols.keys
        .where((symbol) => symbol.startsWith(partialUpper))
        .take(5)
        .toList();
  }

  // Get all categories
  static List<String> getCategories() {
    return [
      'Banks',
      'Miners',
      'Tech',
      'ETFs',
      'Retail',
      'Telecom',
      'Healthcare',
    ];
  }
}
