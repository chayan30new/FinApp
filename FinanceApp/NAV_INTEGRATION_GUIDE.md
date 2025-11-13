# Mutual Fund NAV Integration - Setup Guide

## Overview
We've integrated NAV (Net Asset Value) fetching for Indian mutual funds using MFApi.in, a free API that provides AMFI mutual fund data.

## What We Built

### 1. **MutualFundNavService** (`lib/services/mutual_fund_nav_service.dart`)
Service to fetch NAV data from MFApi.in API:
- `fetchLatestNavBySymbol(symbol)` - Get the latest closing NAV
- `fetchHistoricalNavBySymbol(symbol, limitDays)` - Get historical NAV data
- `fetchNavForDateBySymbol(symbol, targetDate)` - Get NAV for a specific date (finds closest match)

### 2. **MutualFundSchemeCodes** (`lib/utils/mutual_fund_scheme_codes.dart`)
Mapping between our friendly fund codes and AMFI scheme codes:
- Our codes: `HDFC-TOP100`, `SBI-BLUECHIP`, etc.
- AMFI codes: 6-digit numeric codes required by the API

### 3. **Integration Points**
Updated these components to use NAV service:
- **WatchlistScreen** - Displays latest NAV for mutual funds
- **InvestmentDetailScreen** - Auto-suggests transaction value using historical NAV
- **LivePriceWidget** - Shows current NAV with last updated date

## Important: Update AMFI Scheme Codes

⚠️ **The scheme codes in `mutual_fund_scheme_codes.dart` are currently PLACEHOLDERS.**

You need to update them with actual AMFI scheme codes. Here's how:

### Method 1: Search MFApi.in
1. Visit: https://api.mfapi.in/mf/search?q=fund_name
2. Example: https://api.mfapi.in/mf/search?q=HDFC%20Top%20100
3. Find the scheme code in the results
4. Update the mapping file

### Method 2: Browse AMFI Website
1. Visit: https://www.amfiindia.com/net-asset-value/nav-history
2. Search for the fund name
3. Note the scheme code from the URL or page

### Method 3: Use Value Research
1. Visit: https://www.valueresearchonline.com/
2. Search for the fund
3. Look for the scheme code in fund details

### Example API Calls
```
# Get latest NAV
https://api.mfapi.in/mf/120503/latest

# Get all historical NAV data
https://api.mfapi.in/mf/120503

# Search for a fund
https://api.mfapi.in/mf/search?q=HDFC
```

## Testing the Integration

### 1. Add a Mutual Fund to Watchlist
1. Go to Watchlist screen
2. Click the + button
3. Search for a mutual fund (e.g., "HDFC-TOP100")
4. Add it to watchlist
5. The latest NAV should be fetched automatically

### 2. Track a Mutual Fund Investment
1. Go to Investments screen
2. Add a new investment with a mutual fund ticker
3. Add transactions with quantities
4. The NAV should be fetched and displayed

### 3. Historical NAV for Transactions
1. When adding a transaction with a date in the past
2. Click the refresh button next to the value field
3. The system will fetch the NAV for that date and suggest the value

## Features

### For Mutual Funds
✅ Latest NAV fetching from AMFI
✅ Historical NAV for any date
✅ Smart date matching (finds closest NAV if exact date not available)
✅ Manual NAV entry fallback
✅ NAV-specific UI (orange banners, "NAV" instead of "Price")
✅ AMFI reference links

### For Stocks/ETFs
✅ Live price from Yahoo Finance
✅ Historical prices
✅ Intraday change %
✅ Market-aware suffixes (.NS for India, .AX for Australia)

## How It Detects Mutual Funds
```dart
// A symbol is a mutual fund if it doesn't have stock market suffixes
final isMutualFund = !(symbol.contains('.NS') || 
                        symbol.contains('.AX') ||
                        symbol.contains('.BSE'));
```

Mutual fund codes: `HDFC-TOP100`, `SBI-BLUECHIP`, `AXIS-ELSS`
Stock codes: `RELIANCE.NS`, `CBA.AX`, `TCS.BSE`

## API Details

### MFApi.in Endpoints
- Base URL: `https://api.mfapi.in/mf`
- Latest NAV: `/mf/{schemeCode}/latest`
- All NAV history: `/mf/{schemeCode}`
- Search: `/mf/search?q={query}`

### Response Format
```json
{
  "meta": {
    "fund_house": "HDFC Mutual Fund",
    "scheme_type": "Open Ended Schemes",
    "scheme_category": "Equity Scheme - Large Cap Fund",
    "scheme_code": "120503",
    "scheme_name": "HDFC Top 100 Fund - Direct Plan - Growth Option"
  },
  "data": [
    {
      "date": "09-11-2025",
      "nav": "756.23"
    }
  ]
}
```

## Next Steps

1. **Update Scheme Codes** - Replace placeholder codes with real AMFI codes
2. **Test Each Fund** - Verify NAV fetching works for all 100+ funds
3. **Add More Funds** - Expand the database as needed
4. **Historical Charts** - Consider adding NAV trend charts
5. **Fund Search** - Implement MFApi search integration for discovering new funds

## Files Modified

- `lib/services/mutual_fund_nav_service.dart` (NEW)
- `lib/utils/mutual_fund_scheme_codes.dart` (NEW)
- `lib/screens/watchlist_screen.dart` (UPDATED)
- `lib/screens/investment_detail_screen.dart` (UPDATED)
- `lib/widgets/live_price_widget.dart` (UPDATED)

## Notes

- MFApi.in is free and doesn't require an API key
- NAV is published once daily after market close
- No intraday changes for mutual funds (changePercent is null)
- Fallback to manual entry if NAV fetch fails
- Works seamlessly with existing stock price system
