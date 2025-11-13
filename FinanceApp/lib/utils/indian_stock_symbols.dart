/// Indian stock symbols and mutual funds database
class IndianStockSymbols {
  static final Map<String, String> _nifty50 = {
    'RELIANCE.NS': 'Reliance Industries',
    'TCS.NS': 'Tata Consultancy Services',
    'HDFCBANK.NS': 'HDFC Bank',
    'INFY.NS': 'Infosys',
    'ICICIBANK.NS': 'ICICI Bank',
    'HINDUNILVR.NS': 'Hindustan Unilever',
    'ITC.NS': 'ITC Limited',
    'SBIN.NS': 'State Bank of India',
    'BHARTIARTL.NS': 'Bharti Airtel',
    'KOTAKBANK.NS': 'Kotak Mahindra Bank',
    'LT.NS': 'Larsen & Toubro',
    'AXISBANK.NS': 'Axis Bank',
    'ASIANPAINT.NS': 'Asian Paints',
    'MARUTI.NS': 'Maruti Suzuki',
    'TITAN.NS': 'Titan Company',
    'SUNPHARMA.NS': 'Sun Pharmaceutical',
    'ULTRACEMCO.NS': 'UltraTech Cement',
    'BAJFINANCE.NS': 'Bajaj Finance',
    'NESTLEIND.NS': 'Nestle India',
    'HCLTECH.NS': 'HCL Technologies',
    'WIPRO.NS': 'Wipro',
    'M&M.NS': 'Mahindra & Mahindra',
    'TATAMOTORS.NS': 'Tata Motors',
    'TATASTEEL.NS': 'Tata Steel',
    'POWERGRID.NS': 'Power Grid Corporation',
    'NTPC.NS': 'NTPC',
    'ONGC.NS': 'Oil and Natural Gas Corporation',
    'ADANIPORTS.NS': 'Adani Ports',
    'COALINDIA.NS': 'Coal India',
    'TECHM.NS': 'Tech Mahindra',
  };

  static final Map<String, String> _banks = {
    'HDFCBANK.NS': 'HDFC Bank',
    'ICICIBANK.NS': 'ICICI Bank',
    'SBIN.NS': 'State Bank of India',
    'KOTAKBANK.NS': 'Kotak Mahindra Bank',
    'AXISBANK.NS': 'Axis Bank',
    'INDUSINDBK.NS': 'IndusInd Bank',
    'BANKBARODA.NS': 'Bank of Baroda',
    'PNB.NS': 'Punjab National Bank',
    'FEDERALBNK.NS': 'Federal Bank',
    'IDFCFIRSTB.NS': 'IDFC First Bank',
  };

  static final Map<String, String> _it = {
    'TCS.NS': 'Tata Consultancy Services',
    'INFY.NS': 'Infosys',
    'HCLTECH.NS': 'HCL Technologies',
    'WIPRO.NS': 'Wipro',
    'TECHM.NS': 'Tech Mahindra',
    'LTI.NS': 'LTI Mindtree',
    'COFORGE.NS': 'Coforge',
    'MPHASIS.NS': 'Mphasis',
    'PERSISTENT.NS': 'Persistent Systems',
  };

  static final Map<String, String> _pharma = {
    'SUNPHARMA.NS': 'Sun Pharmaceutical',
    'DRREDDY.NS': 'Dr. Reddy\'s Laboratories',
    'CIPLA.NS': 'Cipla',
    'DIVISLAB.NS': 'Divi\'s Laboratories',
    'BIOCON.NS': 'Biocon',
    'AUROPHARMA.NS': 'Aurobindo Pharma',
    'LUPIN.NS': 'Lupin',
    'TORNTPHARM.NS': 'Torrent Pharmaceuticals',
  };

  static final Map<String, String> _auto = {
    'MARUTI.NS': 'Maruti Suzuki',
    'TATAMOTORS.NS': 'Tata Motors',
    'M&M.NS': 'Mahindra & Mahindra',
    'BAJAJ-AUTO.NS': 'Bajaj Auto',
    'EICHERMOT.NS': 'Eicher Motors',
    'HEROMOTOCO.NS': 'Hero MotoCorp',
    'TVSMOTOR.NS': 'TVS Motor',
    'ASHOKLEY.NS': 'Ashok Leyland',
  };

  static final Map<String, String> _etfs = {
    'NIFTYBEES.NS': 'Nippon India ETF Nifty BeES',
    'JUNIORBEES.NS': 'Nippon India ETF Junior BeES',
    'BANKBEES.NS': 'Nippon India ETF Bank BeES',
    'GOLDBEES.NS': 'Nippon India ETF Gold BeES',
    'LIQUIDBEES.NS': 'Nippon India ETF Liquid BeES',
    'SETFNIF50.NS': 'SBI ETF Nifty 50',
    'ICICIB22.NS': 'ICICI Prudential Nifty ETF',
    'HDFCNIFETF.NS': 'HDFC Nifty 50 ETF',
  };

  static final Map<String, String> _mutualFunds = {
    // Note: Mutual funds don't have live price tickers on Yahoo Finance
    // These are popular AMFI registered mutual funds for reference
    // Users can track NAV manually
    
    // Large Cap Funds
    'SBI-BLUECHIP': 'SBI Bluechip Fund - Direct Growth',
    'HDFC-TOP100': 'HDFC Top 100 Fund - Direct Growth',
    'ICICI-BLUECHIP': 'ICICI Prudential Bluechip Fund - Direct Growth',
    'AXIS-BLUECHIP': 'Axis Bluechip Fund - Direct Growth',
    'MIRAE-LARGECAP': 'Mirae Asset Large Cap Fund - Direct Growth',
    'PARAG-FLEXI': 'Parag Parikh Flexi Cap Fund - Direct Growth',
    'NIPPON-LARGECAP': 'Nippon India Large Cap Fund - Direct Growth',
    'KOTAK-BLUECHIP': 'Kotak Bluechip Fund - Direct Growth',
    'CANARA-BLUECHIP': 'Canara Robeco Bluechip Equity Fund - Direct Growth',
    'INVESCO-LARGECAP': 'Invesco India Large Cap Fund - Direct Growth',
    
    // Mid Cap Funds
    'AXIS-MIDCAP': 'Axis Midcap Fund - Direct Growth',
    'HDFC-MIDCAP': 'HDFC Mid-Cap Opportunities Fund - Direct Growth',
    'KOTAK-EMRG-EQ': 'Kotak Emerging Equity Fund - Direct Growth',
    'MIRAE-EMRG-BL': 'Mirae Asset Emerging Bluechip Fund - Direct Growth',
    'DSP-MIDCAP': 'DSP Midcap Fund - Direct Growth',
    'SUNDARAM-MIDCAP': 'Sundaram Mid Cap Fund - Direct Growth',
    'EDELWEISS-MIDCAP': 'Edelweiss Mid Cap Fund - Direct Growth',
    'NIPPON-GROWTH': 'Nippon India Growth Fund - Direct Growth',
    
    // Small Cap Funds
    'AXIS-SMALLCAP': 'Axis Small Cap Fund - Direct Growth',
    'SBI-SMALLCAP': 'SBI Small Cap Fund - Direct Growth',
    'KOTAK-SMALLCAP': 'Kotak Small Cap Fund - Direct Growth',
    'HDFC-SMALLCAP': 'HDFC Small Cap Fund - Direct Growth',
    'NIPPON-SMALLCAP': 'Nippon India Small Cap Fund - Direct Growth',
    'DSP-SMALLCAP': 'DSP Small Cap Fund - Direct Growth',
    'QUANT-SMALLCAP': 'Quant Small Cap Fund - Direct Growth',
    
    // Flexi Cap / Multi Cap Funds
    'PARAG-FLEXI-CAP': 'Parag Parikh Flexi Cap Fund - Direct Growth',
    'CANARA-FLEXI': 'Canara Robeco Flexi Cap Fund - Direct Growth',
    'PGIM-FLEXI': 'PGIM India Flexi Cap Fund - Direct Growth',
    'JM-MULTICAP': 'JM Multicap Fund - Direct Growth',
    'SUNDARAM-MULTICAP': 'Sundaram Multi Cap Fund - Direct Growth',
    'HSBC-MULTICAP': 'HSBC Multi Cap Fund - Direct Growth',
    'FRANKLIN-FLEXI': 'Franklin India Flexi Cap Fund - Direct Growth',
    
    // Index Funds
    'HDFC-NIFTY50': 'HDFC Index Fund - Nifty 50 Plan - Direct Growth',
    'ICICI-NIFTY50': 'ICICI Prudential Nifty 50 Index Fund - Direct Growth',
    'UTI-NIFTY50': 'UTI Nifty 50 Index Fund - Direct Growth',
    'SBI-NIFTY': 'SBI Nifty Index Fund - Direct Growth',
    'NIPPON-NIFTY': 'Nippon India Index Fund - Nifty 50 Plan - Direct Growth',
    'AXIS-NIFTY50': 'Axis Nifty 50 Index Fund - Direct Growth',
    'HDFC-SENSEX': 'HDFC Index Fund - Sensex Plan - Direct Growth',
    'ICICI-SENSEX': 'ICICI Prudential Sensex Index Fund - Direct Growth',
    'UTI-NIFTYNEXT50': 'UTI Nifty Next 50 Index Fund - Direct Growth',
    'ICICI-NIFTYNEXT50': 'ICICI Prudential Nifty Next 50 Index Fund - Direct Growth',
    
    // Sectoral / Thematic Funds
    'ICICI-TECH': 'ICICI Prudential Technology Fund - Direct Growth',
    'SBI-TECH': 'SBI Technology Opportunities Fund - Direct Growth',
    'NIPPON-PHARMA': 'Nippon India Pharma Fund - Direct Growth',
    'ICICI-BANKING': 'ICICI Prudential Banking and Financial Services Fund - Direct Growth',
    'SBI-BANKING': 'SBI Banking & Financial Services Fund - Direct Growth',
    'HDFC-INFRA': 'HDFC Infrastructure Fund - Direct Growth',
    'ICICI-INFRA': 'ICICI Prudential Infrastructure Fund - Direct Growth',
    'NIPPON-INDIA-CONS': 'Nippon India Consumption Fund - Direct Growth',
    'MIRAE-HEALTH': 'Mirae Asset Healthcare Fund - Direct Growth',
    'QUANT-INFRA': 'Quant Infrastructure Fund - Direct Growth',
    
    // Hybrid / Balanced Funds
    'HDFC-BAL-ADV': 'HDFC Balanced Advantage Fund - Direct Growth',
    'ICICI-BAL-ADV': 'ICICI Prudential Balanced Advantage Fund - Direct Growth',
    'AXIS-BAL-ADV': 'Axis Balanced Advantage Fund - Direct Growth',
    'SBI-BAL-ADV': 'SBI Balanced Advantage Fund - Direct Growth',
    'HDFC-HYBRID-EQ': 'HDFC Hybrid Equity Fund - Direct Growth',
    'ICICI-HYBRID': 'ICICI Prudential Equity & Debt Fund - Direct Growth',
    'MIRAE-HYBRID': 'Mirae Asset Hybrid Equity Fund - Direct Growth',
    'CANARA-HYBRID': 'Canara Robeco Equity Hybrid Fund - Direct Growth',
    
    // ELSS / Tax Saving Funds
    'AXIS-ELSS': 'Axis Long Term Equity Fund - Direct Growth',
    'MIRAE-ELSS': 'Mirae Asset Tax Saver Fund - Direct Growth',
    'PARAG-ELSS': 'Parag Parikh Tax Saver Fund - Direct Growth',
    'HDFC-ELSS': 'HDFC Tax Saver Fund - Direct Growth',
    'ICICI-ELSS': 'ICICI Prudential Long Term Equity Fund - Direct Growth',
    'DSP-ELSS': 'DSP Tax Saver Fund - Direct Growth',
    'CANARA-ELSS': 'Canara Robeco Equity Tax Saver Fund - Direct Growth',
    'QUANT-ELSS': 'Quant Tax Plan - Direct Growth',
    
    // Debt Funds
    'HDFC-SHORT-TERM': 'HDFC Short Term Debt Fund - Direct Growth',
    'ICICI-SHORT-TERM': 'ICICI Prudential Short Term Fund - Direct Growth',
    'AXIS-SHORT-TERM': 'Axis Short Term Fund - Direct Growth',
    'HDFC-CORP-BOND': 'HDFC Corporate Bond Fund - Direct Growth',
    'ICICI-CORP-BOND': 'ICICI Prudential Corporate Bond Fund - Direct Growth',
    'AXIS-CORP-DEBT': 'Axis Corporate Debt Fund - Direct Growth',
    'SBI-MAGNUM-MED': 'SBI Magnum Medium Duration Fund - Direct Growth',
    'KOTAK-BOND': 'Kotak Bond Fund - Direct Growth',
    'HDFC-LIQUID': 'HDFC Liquid Fund - Direct Growth',
    'ICICI-LIQUID': 'ICICI Prudential Liquid Fund - Direct Growth',
    'AXIS-LIQUID': 'Axis Liquid Fund - Direct Growth',
    'SBI-LIQUID': 'SBI Liquid Fund - Direct Growth',
    'MOTILAL-NIFTY': 'Motilal Oswal Nifty 50 Index Fund - Direct Growth',
  };

  static final Map<String, String> _fmcg = {
    'HINDUNILVR.NS': 'Hindustan Unilever',
    'ITC.NS': 'ITC Limited',
    'NESTLEIND.NS': 'Nestle India',
    'BRITANNIA.NS': 'Britannia Industries',
    'DABUR.NS': 'Dabur India',
    'MARICO.NS': 'Marico',
    'GODREJCP.NS': 'Godrej Consumer Products',
    'TATACONSUM.NS': 'Tata Consumer Products',
  };

  static final Map<String, String> _energy = {
    'RELIANCE.NS': 'Reliance Industries',
    'ONGC.NS': 'Oil and Natural Gas Corporation',
    'BPCL.NS': 'Bharat Petroleum',
    'IOC.NS': 'Indian Oil Corporation',
    'ADANIGREEN.NS': 'Adani Green Energy',
    'TATAPOWER.NS': 'Tata Power',
    'NTPC.NS': 'NTPC',
    'POWERGRID.NS': 'Power Grid Corporation',
  };

  /// Get all stock symbols (including mutual funds)
  static Map<String, String> getAllSymbols() {
    return {
      ..._nifty50,
      ..._banks,
      ..._it,
      ..._pharma,
      ..._auto,
      ..._etfs,
      ..._mutualFunds,
      ..._fmcg,
      ..._energy,
    };
  }

  /// Get mutual funds list
  static Map<String, String> getMutualFunds() {
    return Map.from(_mutualFunds);
  }

  /// Search for symbols by query
  static Map<String, String> search(String query) {
    if (query.isEmpty) return {};
    
    final allSymbols = getAllSymbols();
    final lowerQuery = query.toLowerCase();
    
    return Map.fromEntries(
      allSymbols.entries.where((entry) {
        return entry.key.toLowerCase().contains(lowerQuery) ||
               entry.value.toLowerCase().contains(lowerQuery);
      }),
    );
  }

  /// Get suggestions for partial symbol
  static List<String> getSuggestions(String partial) {
    if (partial.isEmpty) return [];
    
    final allSymbols = getAllSymbols();
    final lowerPartial = partial.toLowerCase();
    
    return allSymbols.keys
        .where((symbol) => symbol.toLowerCase().startsWith(lowerPartial))
        .take(10)
        .toList();
  }

  /// Get symbol by category
  static Map<String, String> getByCategory(String category) {
    switch (category.toLowerCase()) {
      case 'nifty50':
        return Map.from(_nifty50);
      case 'banks':
        return Map.from(_banks);
      case 'it':
        return Map.from(_it);
      case 'pharma':
        return Map.from(_pharma);
      case 'auto':
        return Map.from(_auto);
      case 'etfs':
        return Map.from(_etfs);
      case 'fmcg':
        return Map.from(_fmcg);
      case 'energy':
        return Map.from(_energy);
      case 'mutualfunds':
        return Map.from(_mutualFunds);
      default:
        return {};
    }
  }

  /// Get all categories
  static List<String> getCategories() {
    return [
      'Nifty 50',
      'Banks',
      'IT',
      'Pharma',
      'Auto',
      'ETFs',
      'FMCG',
      'Energy',
      'Mutual Funds',
    ];
  }
}
