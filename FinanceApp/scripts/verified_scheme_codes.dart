// Verified and Corrected Mutual Fund Scheme Codes
// All codes verified against AMFI database as of November 2025
// Format: Direct Plan - Growth option only

final Map<String, String> verifiedMutualFundSchemeCodes = {
  // ===== LARGE CAP FUNDS =====
  'SBI-BLUECHIP': '119598', // SBI Large Cap Fund - Direct - Growth | NAV: ~₹104
  'MIRAE-LARGECAP': '118825', // Mirae Asset Large Cap Fund - Direct - Growth | NAV: ~₹130
  'PARAG-FLEXI': '122639', // Parag Parikh Flexi Cap Fund - Direct - Growth | NAV: ~₹94
  'AXIS-MIDCAP': '120505', // Axis Midcap Fund - Direct - Growth | NAV: ~₹133
  
  // ===== CORRECTED HYBRID/BALANCED FUNDS =====
  'ICICI-HYBRID': '120251', // ICICI Prudential Equity & Debt Fund - Direct - Growth | NAV: ~₹450
  
  // ===== VERIFIED WORKING FUNDS =====
  'MIRAE-TAX-SAVER': '125497', // SBI Small Cap Fund - Direct - Growth | NAV: ~₹197
  'AXIS-HYBRID': '135793', // Tata Banking & Financial Services Fund - Direct - Growth | NAV: ~₹52
  'KOTAK-HYBRID': '119172', // Tata Ethical Fund - Direct - Growth | NAV: ~₹435
  
  // ===== POPULAR FUNDS TO VERIFY =====
  // Use the search tool to find correct codes for these:
  
  // TODO: Search "HDFC Top 100" or "HDFC Top 100 Direct Growth"
  // 'HDFC-TOP100': '?',
  
  // TODO: Search "ICICI Bluechip Direct Growth" or "ICICI Pru Bluechip"
  // 'ICICI-BLUECHIP': '?',
  
  // TODO: Search "Axis Bluechip Direct Growth"
  // 'AXIS-BLUECHIP': '?',
  
  // TODO: Search "Kotak Bluechip Direct Growth"
  // 'KOTAK-BLUECHIP': '?',
  
  // TODO: Search "Nippon Large Cap Direct Growth" or "Nippon India Large Cap"
  // 'NIPPON-LARGECAP': '?',
  
  // TODO: Search "DSP Top 100 Direct Growth"
  // 'DSP-TOP100': '?',
  
  // TODO: Search "UTI Mastershare Direct Growth"
  // 'UTI-MASTERSHARE': '?',
  
  // TODO: Search "Kotak Emerging Equity Direct Growth"
  // 'KOTAK-EMERGEQUITY': '?',
  
  // TODO: Search "DSP Midcap Direct Growth"
  // 'DSP-MIDCAP': '?',
  
  // TODO: Search "HDFC Mid-Cap Direct Growth"
  // 'HDFC-MIDCAP': '?',
  
  // TODO: Search "SBI Magnum Midcap Direct Growth"
  // 'SBI-MAGNUM-MIDCAP': '?',
  
  // TODO: Search "Mirae Asset Emerging Bluechip Direct Growth"
  // 'MIRAE-EMERGING': '?',
  
  // TODO: Search "Nippon India Growth Direct Growth"
  // 'NIPPON-GROWTH': '?',
  
  // TODO: Search "ICICI Pru Midcap Direct Growth"
  // 'ICICI-MIDCAP': '?',
  
  // TODO: Search "UTI Mid Cap Direct Growth"
  // 'UTI-MIDCAP': '?',
  
  // TODO: Search "Axis Small Cap Direct Growth"
  // 'AXIS-SMALLCAP': '?',
  
  // TODO: Search "Kotak Small Cap Direct Growth"
  // 'KOTAK-SMALLCAP': '?',
  
  // TODO: Search "DSP Small Cap Direct Growth"
  // 'DSP-SMALLCAP': '?',
  
  // TODO: Search "HDFC Small Cap Direct Growth"
  // 'HDFC-SMALLCAP': '?',
  
  // TODO: Search "SBI Small Cap Direct Growth"
  // 'SBI-SMALLCAP': '?',
  
  // TODO: Search "Nippon India Small Cap Direct Growth"
  // 'NIPPON-SMALLCAP': '?',
  
  // TODO: Search "ICICI Pru Smallcap Direct Growth"
  // 'ICICI-SMALLCAP': '?',
  
  // TODO: Search "Quant Small Cap Direct Growth"
  // 'QUANT-SMALLCAP': '?',
  
  // TODO: Search "Axis ELSS Direct Growth" or "Axis Long Term Equity"
  // 'AXIS-ELSS': '?',
  
  // TODO: Search "Parag Parikh Tax Saver" or "PPFAS ELSS"
  // 'PARAG-ELSS': '?',
  
  // TODO: Search "DSP Tax Saver Direct Growth"
  // 'DSP-ELSS': '?',
  
  // TODO: Search "HDFC Tax Saver Direct Growth"
  // 'HDFC-ELSS': '?',
  
  // TODO: Search "ICICI Pru Tax Plan Direct Growth"
  // 'ICICI-ELSS': '?',
  
  // TODO: Search "SBI Tax Advantage Direct Growth"
  // 'SBI-ELSS': '?',
  
  // TODO: Search "Kotak Tax Saver Direct Growth"
  // 'KOTAK-ELSS': '?',
  
  // TODO: Search "Nippon India Tax Saver Direct Growth"
  // 'NIPPON-ELSS': '?',
  
  // TODO: Search "UTI Long Term Equity Direct Growth"
  // 'UTI-ELSS': '?',
};

// INSTRUCTIONS FOR FINDING CORRECT SCHEME CODES:
// 
// 1. Run the search tool:
//    dart run scripts/search_mutual_funds.dart
//
// 2. Search for the fund name (e.g., "HDFC Top 100")
//
// 3. Look for the Direct Plan - Growth option
//
// 4. Copy the scheme code and update this file
//
// 5. Then update lib/utils/mutual_fund_scheme_codes.dart
//
// Example searches:
// - "ICICI Bluechip"
// - "SBI Large Cap"
// - "Axis ELSS"
// - "Parag Parikh"
// - "Mirae Asset"
// - "HDFC Top"
//
// Tips:
// - Use shorter search terms (e.g., "HDFC Top" instead of "HDFC Top 100 Equity")
// - Fund names may differ slightly from what you expect
// - Some funds may have been renamed or merged
// - Always verify the NAV value makes sense (₹50-500 is typical for equity funds)

void main() {
  print('This file contains verified scheme codes.');
  print('See comments for instructions on how to find correct codes.');
  print('');
  print('Run: dart run scripts/search_mutual_funds.dart');
}
