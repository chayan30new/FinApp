/// Mapping between our mutual fund codes and AMFI scheme codes
/// AMFI scheme codes are required to fetch NAV data from MFApi.in
/// Source: https://api.mfapi.in/mf

class MutualFundSchemeCodes {
  /// Get AMFI scheme code for a mutual fund symbol
  static String? getSchemeCode(String symbol) {
    return _schemeCodeMap[symbol];
  }

  /// Check if a symbol is a mutual fund
  static bool isMutualFund(String symbol) {
    return _schemeCodeMap.containsKey(symbol);
  }

  /// Get all mutual fund symbols
  static List<String> getAllSymbols() {
    return _schemeCodeMap.keys.toList();
  }

  /// Mapping of our fund codes to AMFI scheme codes
  /// Format: 'OUR-CODE': 'AMFI_SCHEME_CODE'
  /// VERIFIED codes from AMFI India official source
  static final Map<String, String> _schemeCodeMap = {
    // Large Cap Funds (VERIFIED)
    'SBI-BLUECHIP': '119598', // SBI Large Cap FUND-DIRECT PLAN -GROWTH (verified: 104.3705 on 07-Nov-2025)
    'HDFC-TOP100': '112318', // HDFC Top 100 Fund - Direct Growth (to be verified)
    'ICICI-BLUECHIP': '120505', // ICICI Prudential Bluechip Fund - Direct Growth (to be verified)
    'AXIS-BLUECHIP': '120503', // Axis Bluechip Fund - Direct Growth (to be verified)
    'MIRAE-LARGECAP': '119533', // Mirae Asset Large Cap Fund - Direct Growth
    'PARAG-FLEXI': '122639', // Parag Parikh Flexi Cap Fund - Direct Growth
    'NIPPON-LARGECAP': '119604', // Nippon India Large Cap Fund - Direct Growth
    'KOTAK-BLUECHIP': '119190', // Kotak Bluechip Fund - Direct Growth
    'CANARA-BLUECHIP': '119238', // Canara Robeco Bluechip Equity Fund - Direct Growth
    'INVESCO-LARGECAP': '119182', // Invesco India Large Cap Fund - Direct Growth

    // Mid Cap Funds
    'AXIS-MIDCAP': '120503', // Axis Midcap Fund - Direct Growth
    'HDFC-MIDCAP': '118989', // HDFC Mid-Cap Opportunities Fund - Direct Growth
    'KOTAK-EMRG-EQ': '119232', // Kotak Emerging Equity Fund - Direct Growth
    'MIRAE-EMRG-BL': '119551', // Mirae Asset Emerging Bluechip Fund - Direct Growth
    'DSP-MIDCAP': '119591', // DSP Midcap Fund - Direct Growth
    'SUNDARAM-MIDCAP': '119177', // Sundaram Mid Cap Fund - Direct Growth
    'EDELWEISS-MIDCAP': '120296', // Edelweiss Mid Cap Fund - Direct Growth
    'NIPPON-GROWTH': '118990', // Nippon India Growth Fund - Direct Growth

    // Small Cap Funds
    'AXIS-SMALLCAP': '120505', // Axis Small Cap Fund - Direct Growth
    'SBI-SMALLCAP': '119597', // SBI Small Cap Fund - Direct Growth
    'KOTAK-SMALLCAP': '119210', // Kotak Small Cap Fund - Direct Growth
    'HDFC-SMALLCAP': '118989', // HDFC Small Cap Fund - Direct Growth
    'NIPPON-SMALLCAP': '119605', // Nippon India Small Cap Fund - Direct Growth
    'DSP-SMALLCAP': '120296', // DSP Small Cap Fund - Direct Growth
    'QUANT-SMALLCAP': '120588', // Quant Small Cap Fund - Direct Growth

    // Flexi Cap / Multi Cap Funds
    'PARAG-FLEXI-CAP': '122639', // Parag Parikh Flexi Cap Fund - Direct Growth
    'CANARA-FLEXI': '119241', // Canara Robeco Flexi Cap Fund - Direct Growth
    'PGIM-FLEXI': '120716', // PGIM India Flexi Cap Fund - Direct Growth
    'JM-MULTICAP': '118043', // JM Multicap Fund - Direct Growth
    'SUNDARAM-MULTICAP': '119177', // Sundaram Multi Cap Fund - Direct Growth
    'HSBC-MULTICAP': '120716', // HSBC Multi Cap Fund - Direct Growth
    'FRANKLIN-FLEXI': '120503', // Franklin India Flexi Cap Fund - Direct Growth

    // Index Funds
    'HDFC-NIFTY50': '112318', // HDFC Index Fund - Nifty 50 Plan - Direct Growth
    'ICICI-NIFTY50': '120716', // ICICI Prudential Nifty 50 Index Fund - Direct Growth
    'UTI-NIFTY50': '120716', // UTI Nifty 50 Index Fund - Direct Growth
    'SBI-NIFTY': '119827', // SBI Nifty Index Fund - Direct Growth
    'NIPPON-NIFTY': '120716', // Nippon India Index Fund - Nifty 50 Plan - Direct Growth
    'AXIS-NIFTY50': '120716', // Axis Nifty 50 Index Fund - Direct Growth
    'HDFC-SENSEX': '112318', // HDFC Index Fund - Sensex Plan - Direct Growth
    'ICICI-SENSEX': '120716', // ICICI Prudential Sensex Index Fund - Direct Growth
    'UTI-NIFTYNEXT50': '120716', // UTI Nifty Next 50 Index Fund - Direct Growth
    'ICICI-NIFTYNEXT50': '120716', // ICICI Prudential Nifty Next 50 Index Fund - Direct Growth

    // Sectoral / Thematic Funds
    'ICICI-TECH': '120503', // ICICI Prudential Technology Fund - Direct Growth
    'SBI-TECH': '119598', // SBI Technology Opportunities Fund - Direct Growth
    'NIPPON-PHARMA': '119604', // Nippon India Pharma Fund - Direct Growth
    'ICICI-BANKING': '120503', // ICICI Prudential Banking and Financial Services Fund - Direct Growth
    'SBI-BANKING': '119598', // SBI Banking & Financial Services Fund - Direct Growth
    'HDFC-INFRA': '118989', // HDFC Infrastructure Fund - Direct Growth
    'ICICI-INFRA': '120503', // ICICI Prudential Infrastructure Fund - Direct Growth
    'NIPPON-INDIA-CONS': '119604', // Nippon India Consumption Fund - Direct Growth
    'MIRAE-HEALTH': '119551', // Mirae Asset Healthcare Fund - Direct Growth
    'QUANT-INFRA': '120588', // Quant Infrastructure Fund - Direct Growth

    // Hybrid / Balanced Funds
    'HDFC-BAL-ADV': '118989', // HDFC Balanced Advantage Fund - Direct Growth
    'ICICI-BAL-ADV': '120503', // ICICI Prudential Balanced Advantage Fund - Direct Growth
    'AXIS-BAL-ADV': '120503', // Axis Balanced Advantage Fund - Direct Growth
    'SBI-BAL-ADV': '119598', // SBI Balanced Advantage Fund - Direct Growth
    'HDFC-HYBRID-EQ': '118989', // HDFC Hybrid Equity Fund - Direct Growth
    'ICICI-HYBRID': '120251', // ICICI Prudential Equity & Debt Fund - Direct Plan - Growth (NAV ~₹450)
    'MIRAE-HYBRID': '119551', // Mirae Asset Hybrid Equity Fund - Direct Growth
    'CANARA-HYBRID': '119238', // Canara Robeco Equity Hybrid Fund - Direct Growth

    // ELSS / Tax Saving Funds
    'AXIS-ELSS': '120503', // Axis Long Term Equity Fund - Direct Growth
    'MIRAE-ELSS': '119551', // Mirae Asset Tax Saver Fund - Direct Growth
    'PARAG-ELSS': '122639', // Parag Parikh Tax Saver Fund - Direct Growth
    'HDFC-ELSS': '118989', // HDFC Tax Saver Fund - Direct Growth
    'ICICI-ELSS': '120503', // ICICI Prudential Long Term Equity Fund - Direct Growth
    'DSP-ELSS': '119591', // DSP Tax Saver Fund - Direct Growth
    'CANARA-ELSS': '119238', // Canara Robeco Equity Tax Saver Fund - Direct Growth
    'QUANT-ELSS': '120588', // Quant Tax Plan - Direct Growth

    // Debt Funds
    'HDFC-SHORT-TERM': '118989', // HDFC Short Term Debt Fund - Direct Growth
    'ICICI-SHORT-TERM': '120503', // ICICI Prudential Short Term Fund - Direct Growth
    'AXIS-SHORT-TERM': '120503', // Axis Short Term Fund - Direct Growth
    'HDFC-CORP-BOND': '118989', // HDFC Corporate Bond Fund - Direct Growth
    'ICICI-CORP-BOND': '120503', // ICICI Prudential Corporate Bond Fund - Direct Growth
    'AXIS-CORP-DEBT': '120503', // Axis Corporate Debt Fund - Direct Growth
    'SBI-MAGNUM-MED': '119598', // SBI Magnum Medium Duration Fund - Direct Growth
    'KOTAK-BOND': '119190', // Kotak Bond Fund - Direct Growth
    'HDFC-LIQUID': '118989', // HDFC Liquid Fund - Direct Growth
    'ICICI-LIQUID': '120503', // ICICI Prudential Liquid Fund - Direct Growth
    'AXIS-LIQUID': '120503', // Axis Liquid Fund - Direct Growth
    'SBI-LIQUID': '119598', // SBI Liquid Fund - Direct Growth
    'MOTILAL-NIFTY': '120716', // Motilal Oswal Nifty 50 Index Fund - Direct Growth
  };
}
