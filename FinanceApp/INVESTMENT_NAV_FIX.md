# Investment Detail Screen - NAV Integration Fix

## Issue
Investment detail screen was showing outdated message:
> "Mutual funds don't have live price data. Use 'Update Value' to manually enter NAV."

This was misleading because we now have automatic NAV fetching from AMFI India.

## What Was Fixed

### 1. Updated Info Banner (Line 114-137)
**Before:**
- Orange warning banner
- Message: "Mutual funds don't have live price data. Use 'Update Value' to manually enter NAV."
- Icon: ⚠️ Warning icon

**After:**
- Blue info banner
- Message: "Mutual Fund: NAV is fetched from AMFI India (updated daily after market close)."
- Icon: 🏦 Account balance icon (represents mutual fund)

### 2. Updated Transaction Dialog Helper Text (Line 595-610)
**Before:**
- For mutual funds: "Mutual fund: Enter NAV manually (× quantity = total value). No auto-fetch available."
- Orange text color
- No refresh button for mutual funds

**After:**
- For mutual funds: "Auto-suggested based on NAV from AMFI on [date]. You can edit if needed."
- Grey text color (consistent with stocks)
- Refresh button now available for mutual funds too!

### 3. Enable Refresh Button for Mutual Funds
**Before:**
```dart
if (investment.tickerSymbol != null && 
    investment.tickerSymbol!.isNotEmpty &&
    (investment.tickerSymbol!.contains('.NS') ||  // Only for stocks
     investment.tickerSymbol!.contains('.AX') ||
     investment.tickerSymbol!.contains('.BSE')))
  IconButton(...)
```

**After:**
```dart
if (investment.tickerSymbol != null && 
    investment.tickerSymbol!.isNotEmpty)  // For ALL investments including mutual funds
  IconButton(...)
```

## How It Works Now

### Adding a Transaction
1. Click "Add Transaction" button
2. Select transaction date
3. Enter quantity (if applicable)
4. Click the **refresh button** (🔄) next to value field
5. System fetches NAV from AMFI for that date
6. Auto-calculates: `NAV × quantity = suggested value`
7. User can edit if needed or click "Add Transaction"

### For Mutual Funds
- **Latest NAV**: Fetched when viewing investment
- **Historical NAV**: Fetched when adding transaction with past date
- **Source**: AMFI India official data
- **Update Frequency**: Daily after market close
- **Scheme Code**: Uses mapping from `mutual_fund_scheme_codes.dart`

### For Stocks/ETFs
- **Latest Price**: Fetched from Yahoo Finance
- **Historical Price**: Fetched from Yahoo Finance
- **Source**: Yahoo Finance API
- **Update Frequency**: Real-time (during market hours)
- **Symbol**: Uses market suffix (.NS, .AX, .BSE)

## Testing

### Test with Mutual Fund
1. Go to Investments screen
2. Open an investment with mutual fund (e.g., `SBI-BLUECHIP`)
3. **Verify**: Blue info banner appears (not orange)
4. **Verify**: Banner says "NAV is fetched from AMFI India"
5. Click "Add Transaction"
6. Select a date
7. Enter quantity: `10`
8. Click refresh button (🔄)
9. **Verify**: Value field auto-populates with NAV × 10
10. **Verify**: Helper text says "Auto-suggested based on NAV from AMFI..."

### Test with Stock
1. Open an investment with stock (e.g., `RELIANCE.NS`)
2. **Verify**: No blue info banner (stocks don't need it)
3. Click "Add Transaction"
4. Enter quantity: `5`
5. Click refresh button (🔄)
6. **Verify**: Value field auto-populates with price × 5
7. **Verify**: Helper text says "Auto-suggested based on price..."

## Files Modified
- `lib/screens/investment_detail_screen.dart`
  - Lines 114-137: Info banner update
  - Lines 595-610: Helper text and refresh button logic

## Benefits
✅ Clear messaging about automatic NAV fetching
✅ Refresh button now works for mutual funds
✅ Consistent UX between stocks and mutual funds
✅ Users know data comes from official AMFI source
✅ No more confusion about manual vs automatic entry
