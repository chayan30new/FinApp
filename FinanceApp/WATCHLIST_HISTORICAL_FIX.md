# Fix: Historical Data for Mutual Funds in Watchlist

## The Problem

❌ **Watchlist Detail Screen**: Historical price chart was not working for mutual funds
- Only fetched data from Yahoo Finance (StockPriceService)
- Mutual funds don't have data in Yahoo Finance
- Chart showed "No data available" error

## Root Cause

The `_fetchHistoricalPrices()` method only used `StockPriceService.fetchHistoricalPrices()`:

```dart
// BEFORE - Only worked for stocks
final histData = await StockPriceService.fetchHistoricalPrices(
  widget.item.symbol,
  period: _selectedPeriod,
);
```

This worked for stocks with `.NS`, `.AX`, `.BSE` suffixes but failed for mutual funds.

## The Fix

### 1. Added Mutual Fund NAV Service Import

```dart
import '../services/mutual_fund_nav_service.dart';
```

### 2. Updated `_fetchPrice()` Method

Now detects mutual funds and fetches NAV instead of stock price:

```dart
final isMutualFund = !(widget.item.symbol.contains('.NS') || 
                        widget.item.symbol.contains('.AX') ||
                        widget.item.symbol.contains('.BSE'));

if (isMutualFund) {
  // Fetch NAV from AMFI
  final navData = await MutualFundNavService.fetchLatestNavBySymbol(...);
} else {
  // Fetch price from Yahoo Finance
  final priceData = await StockPriceService.fetchPrice(...);
}
```

### 3. Updated `_fetchHistoricalPrices()` Method

Added mutual fund support with historical NAV data:

```dart
if (isMutualFund) {
  // Convert period to days
  final periodDays = _getPeriodDays(_selectedPeriod);
  
  // Fetch historical NAV from AMFI
  final navList = await MutualFundNavService.fetchHistoricalNavBySymbol(
    widget.item.symbol,
    limitDays: periodDays,
  );
  
  // Convert to HistoricalPriceData format
  final prices = navList.map((nav) => HistoricalPrice(
    date: nav.date,
    close: nav.nav,
  )).toList();
  
  _historicalData = HistoricalPriceData(
    symbol: widget.item.symbol,
    prices: prices,
    period: _selectedPeriod,
  );
} else {
  // Fetch stock prices as before
  final histData = await StockPriceService.fetchHistoricalPrices(...);
}
```

### 4. Added Helper Method

```dart
int _getPeriodDays(String period) {
  switch (period) {
    case '1mo': return 30;
    case '3mo': return 90;
    case '6mo': return 180;
    case '1y': return 365;
    case '2y': return 730;
    case '5y': return 1825;
    default: return 365;
  }
}
```

## How It Works Now

### For Mutual Funds (e.g., SBI-BLUECHIP):

1. **Open watchlist item** → Click on mutual fund
2. **Current NAV** fetched from AMFI India
3. **Historical Chart** shows:
   - NAV trends over selected period (1M, 3M, 6M, 1Y, 2Y, 5Y)
   - Historical NAV data from AMFI
   - Properly formatted chart with dates and values

### For Stocks (e.g., RELIANCE.NS):

1. **Open watchlist item** → Click on stock
2. **Current Price** fetched from Yahoo Finance
3. **Historical Chart** shows:
   - Price trends over selected period
   - Stock price data from Yahoo Finance
   - Works as before

## What Changed

| Component | Before | After |
|-----------|--------|-------|
| **Current Price/NAV** | Only stocks | ✅ Stocks + Mutual Funds |
| **Historical Chart** | Only stocks | ✅ Stocks + Mutual Funds |
| **Data Source** | Yahoo Finance only | Yahoo Finance (stocks) + AMFI (MFs) |
| **Error Handling** | Generic errors | Specific error messages |

## Testing

### Test Mutual Fund Historical Data:

1. **Go to Watchlist**
2. **Click on** `SBI-BLUECHIP` (or any verified mutual fund)
3. **You should see**:
   - Current NAV: ₹104.37 (or current value)
   - Last Updated date
   - Historical chart with NAV trends
4. **Try different periods**:
   - 1M, 3M, 6M, 1Y, 2Y, 5Y
   - Chart updates with NAV data for each period
5. **Verify chart shows**:
   - X-axis: Dates
   - Y-axis: NAV values
   - Line showing NAV trend

### Test Stock Historical Data:

1. **Click on stock** with `.NS`, `.AX`, or `.BSE` suffix
2. **Chart should work** as before with Yahoo Finance data

## Files Modified

**`lib/screens/watchlist_detail_screen.dart`**
- Line 6: Added import for MutualFundNavService
- Lines 48-97: Updated `_fetchPrice()` with mutual fund support
- Lines 99-172: Updated `_fetchHistoricalPrices()` with historical NAV
- Lines 175-187: Added `_getPeriodDays()` helper method

## Data Flow

### Mutual Funds:
```
User clicks period → _fetchHistoricalPrices()
  ↓
Detect mutual fund (no .NS/.AX/.BSE)
  ↓
MutualFundNavService.fetchHistoricalNavBySymbol()
  ↓
Fetch from AMFI (http://portal.amfiindia.com/...)
  ↓
Convert to HistoricalPrice objects
  ↓
Display in HistoricalPriceChart widget
```

### Stocks:
```
User clicks period → _fetchHistoricalPrices()
  ↓
Detect stock (.NS/.AX/.BSE present)
  ↓
StockPriceService.fetchHistoricalPrices()
  ↓
Fetch from Yahoo Finance
  ↓
Display in HistoricalPriceChart widget
```

## Debug Information

Console logs will show:
```
Fetching NAV from AMFI for scheme code: 119598
AMFI response received: XXXXX bytes
Parsed XXXX funds from AMFI data
Found matching scheme code: 119598
```

## Known Limitations

1. **Only verified funds work**: Need correct AMFI scheme codes
   - ✅ SBI-BLUECHIP (119598)
   - ✅ MIRAE-LARGECAP (118825)
   - ✅ PARAG-FLEXI (122639)
   - ✅ AXIS-MIDCAP (120505)
   - ❌ Others need scheme code verification

2. **Historical data limitations**:
   - AMFI may not have full 5-year history for all funds
   - Data depends on fund's inception date
   - Weekend/holiday dates may be missing

3. **Period accuracy**:
   - Fetches approximate number of days
   - AMFI returns actual trading days only

## Summary

✅ **Fixed**: Watchlist historical charts now work for mutual funds
✅ **Method**: Fetches NAV data from AMFI India for historical trends
✅ **Integration**: Seamlessly switches between stocks (Yahoo) and MFs (AMFI)
✅ **User Experience**: Same chart interface for both types
✅ **Status**: Complete parity between stocks and mutual funds in watchlist

The app should update automatically with hot reload. Refresh the browser if needed! 🎉
