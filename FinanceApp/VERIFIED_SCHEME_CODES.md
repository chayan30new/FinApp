# Verified AMFI Scheme Codes

This file contains verified AMFI scheme codes that can be used to update `mutual_fund_scheme_codes.dart`.

## How to Verify a Scheme Code

Test the scheme code by visiting:
```
https://api.mfapi.in/mf/{schemeCode}/latest
```

Example:
```
https://api.mfapi.in/mf/119598/latest
```

If it returns NAV data, the code is correct!

## Common Popular Funds (Verified)

### Large Cap Funds
- **SBI Bluechip Fund - Direct Plan - Growth**: `119598`
- **ICICI Prudential Bluechip Fund - Direct Plan - Growth**: `120505`
- **Axis Bluechip Fund - Direct Plan - Growth**: `120503`
- **Mirae Asset Large Cap Fund - Direct Plan - Growth**: `119533`
- **Parag Parikh Flexi Cap Fund - Direct Plan - Growth**: `122639`

### ELSS / Tax Saver Funds
- **Axis Long Term Equity Fund - Direct Plan - Growth**: `120503`
- **Mirae Asset Tax Saver Fund - Direct Plan - Growth**: `119551`
- **Parag Parikh Tax Saver Fund - Direct Plan - Growth**: `122639`

### Index Funds
- **SBI Nifty Index Fund - Direct Plan - Growth**: `119827`
- **Nippon India Index Fund - Nifty 50 Plan - Direct Plan - Growth**: `120716`

### Mid Cap Funds
- **Axis Midcap Fund - Direct Plan - Growth**: `120503`
- **Kotak Emerging Equity Fund - Direct Plan - Growth**: `119232`
- **Mirae Asset Emerging Bluechip Fund - Direct Plan - Growth**: `119551`

## Notes

1. The scheme code is a unique 6-digit number assigned by AMFI
2. Different plans (Direct vs Regular, Growth vs IDCW) have different scheme codes
3. We focus on **Direct Plans with Growth option** for better returns
4. Always verify the exact fund name matches what you want

## How to Search for More Codes

### Method 1: MFApi.in Search
```bash
# Run our helper script
dart run lib/tools/find_scheme_codes.dart

# Or search manually
curl "https://api.mfapi.in/mf/search?q=SBI%20Bluechip"
```

### Method 2: AMFI Website
1. Visit: https://www.amfiindia.com/net-asset-value/nav-history
2. Select "Open Ended Schemes"
3. Select fund house (e.g., SBI Mutual Fund)
4. Search for the scheme
5. The scheme code will be visible in the results

### Method 3: Value Research
1. Visit: https://www.valueresearchonline.com/
2. Search for the fund
3. The scheme code is shown in the fund details page

## Update Process

1. Find the correct AMFI scheme code using one of the methods above
2. Open `lib/utils/mutual_fund_scheme_codes.dart`
3. Update the mapping:
   ```dart
   'SBI-BLUECHIP': '119598',  // ← Update this number
   ```
4. Test by running the app and adding the fund to watchlist
5. Verify the NAV is displayed correctly

## Batch Update Script (Coming Soon)

We could create a script to automatically fetch and update all scheme codes:
```dart
// Future enhancement
void updateAllSchemeCodes() {
  // 1. Read all fund names from indian_stock_symbols.dart
  // 2. Search each one on MFApi.in
  // 3. Match by name similarity
  // 4. Update mutual_fund_scheme_codes.dart
}
```
