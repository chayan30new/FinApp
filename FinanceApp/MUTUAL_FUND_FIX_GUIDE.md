# Mutual Fund Scheme Code Fix Guide

## Problem Summary
Out of 100 mutual funds in the app, only **25 are correctly configured**:
- ❌ **43 funds** have non-existent scheme codes
- ❌ **15 funds** are Regular Plans (should be Direct Plans)
- ❌ **17 funds** are wrong fund types or options
- ✅ **25 funds** are correct

## Why This Matters
- **Direct Plans** have lower expense ratios (0.5-1% lower) = Higher returns
- **Growth options** compound returns vs IDCW (dividend payout)
- **Wrong NAV values** lead to incorrect portfolio calculations

## Solution: 3 Tools Created

### 1. **Verification Script** (Already Run)
```bash
dart run scripts/verify_scheme_codes.dart
```
Shows which funds have issues.

### 2. **Search Tool** (Use This to Find Codes)
```bash
dart run scripts/search_mutual_funds.dart
```
Interactive search through 14,000+ AMFI schemes.

### 3. **Verified Codes Template**
`scripts/verified_scheme_codes.dart` - Template for corrected codes

---

## How to Fix Fund Codes (Step-by-Step)

### Step 1: Run the Search Tool
```bash
cd "C:\Users\cagarwal\OneDrive - Amadeus Workplace\Desktop\FinanceApp"
dart run scripts/search_mutual_funds.dart
```

### Step 2: Search for a Fund
Example: Finding HDFC Top 100
```
Search > hdfc top 100

Found 2 matching schemes:
=======================================================
1. Code: 119528
   Name: Aditya Birla Sun Life Large Cap Fund - Growth - Direct Plan
   NAV: ₹594.49 (07-Nov-2025)
   Type: Direct | Growth

2. Code: 100270
   Name: HDFC Top 100 Fund - Direct Plan - Growth Option
   NAV: ₹856.32 (07-Nov-2025)
   Type: Direct | Growth
```

Pick the one with correct fund house name (HDFC, not Aditya Birla).

### Step 3: Update the Scheme Code File

Open: `lib/utils/mutual_fund_scheme_codes.dart`

Find the fund and update:
```dart
// OLD (wrong)
'HDFC-TOP100': '119533',  // Wrong fund

// NEW (correct)
'HDFC-TOP100': '100270',  // HDFC Top 100 Fund - Direct - Growth | NAV: ~₹856
```

### Step 4: Hot Reload the App
Press `r` in the Flutter terminal to reload.

### Step 5: Verify in App
- Check the fund shows correct NAV
- Check historical data loads
- Check fund performance calculations

---

## Priority Funds to Fix (Based on Popularity)

### High Priority (Fix These First)
1. ❌ **HDFC-TOP100** - Currently points to wrong fund
2. ❌ **ICICI-BLUECHIP** - Points to Axis ELSS (completely wrong!)
3. ❌ **AXIS-BLUECHIP** - Same as above
4. ❌ **HDFC-ELSS** - Code doesn't exist
5. ❌ **SBI-ELSS** - Code doesn't exist
6. ❌ **ICICI-ELSS** - Regular Plan (need Direct)
7. ❌ **PARAG-MIDCAP** - Regular Plan (need Direct)
8. ❌ **SBI-CONTRA** - Regular Plan (need Direct)

### Medium Priority
9. ❌ **KOTAK-BLUECHIP** - Code doesn't exist
10. ❌ **NIPPON-LARGECAP** - Points to bond fund
11. ❌ **MIRAE-EMERGING** - Points to wrong fund
12. ❌ **UTI-MASTERSHARE** - Code doesn't exist
13. ❌ **DSP-MIDCAP** - Points to wrong fund
14. ❌ **HDFC-MIDCAP** - Points to interval fund
15. ❌ **SBI-SMALLCAP** - Code doesn't exist

### Already Correct ✅
- ✅ **SBI-BLUECHIP** (119598)
- ✅ **MIRAE-LARGECAP** (118825)
- ✅ **AXIS-MIDCAP** (120505)
- ✅ **PARAG-FLEXI** (122639)
- ✅ **ICICI-HYBRID** (120251) - Just fixed!
- ✅ **AXIS-HYBRID** (135793)
- ✅ **KOTAK-HYBRID** (119172)

---

## Search Tips

### Good Search Terms
- ✅ `"icici bluechip"` - Will find ICICI Pru Bluechip
- ✅ `"sbi large"` - Will find SBI Large Cap funds
- ✅ `"axis elss"` - Will find Axis tax saver
- ✅ `"parag"` - Will find Parag Parikh funds
- ✅ `"hdfc top"` - Shorter is better

### Avoid
- ❌ `"HDFC Top 100 Equity Fund"` - Too specific, may not match
- ❌ `"bluechip"` alone - Too many results

### Fund Name Changes to Know
Many funds have been renamed:
- "Bluechip" → Often called "Large Cap" now
- "Top 100" → May be "Large Cap Fund"
- "Tax Saver" → May be "ELSS Tax Saver"
- "Reliance" → Now "Nippon India"
- "L&T" → Now "HSBC"

---

## Quick Fix Examples

### Example 1: HDFC Top 100
```bash
# Search
Search > hdfc top 100

# Find code (e.g., 100270)

# Update in mutual_fund_scheme_codes.dart
'HDFC-TOP100': '100270',  // HDFC Top 100 Fund - Direct - Growth
```

### Example 2: ICICI Bluechip
```bash
# Search
Search > icici bluechip

# Find code (e.g., 100033)

# Update
'ICICI-BLUECHIP': '100033',  // ICICI Pru Bluechip Fund - Direct - Growth
```

### Example 3: Axis ELSS
```bash
# Search
Search > axis elss

# OR
Search > axis long term equity

# Find code (e.g., 120505)

# Update
'AXIS-ELSS': '120505',  // Axis Long Term Equity Fund - Direct - Growth
```

---

## Commands Reference

### Search Tool Commands
```bash
# Start interactive search
dart run scripts/search_mutual_funds.dart

# Direct search from command line
dart run scripts/search_mutual_funds.dart hdfc top 100

# Inside interactive mode:
direct          # Show only Direct Plan - Growth (default)
all             # Show all plans (Regular + Direct)
quit            # Exit
```

### Verification Commands
```bash
# Check all funds
dart run scripts/verify_scheme_codes.dart

# After fixing, run again to verify improvements
dart run scripts/verify_scheme_codes.dart | grep "✓ Verified"
```

---

## Alternative: Use Only Working Funds

If fixing all 100 funds is too much work, you can:

1. **Remove broken funds** from the dropdown in your app
2. **Keep only the 25 verified funds** that work correctly
3. **Add new funds gradually** as you verify them

To do this, create a filtered list in `mutual_fund_scheme_codes.dart`:
```dart
// Only verified working funds
final Map<String, String> workingMutualFunds = {
  'SBI-BLUECHIP': '119598',
  'MIRAE-LARGECAP': '118825',
  'AXIS-MIDCAP': '120505',
  'PARAG-FLEXI': '122639',
  'ICICI-HYBRID': '120251',
  // Add more as you verify them
};
```

---

## Testing After Fixes

### Test Checklist
- [ ] NAV value looks reasonable (₹50-₹1000 for most equity funds)
- [ ] Fund name matches what you searched for
- [ ] Historical data loads without errors
- [ ] Performance metrics calculate correctly
- [ ] Fund is "Direct Plan" (check in AMFI name)
- [ ] Fund is "Growth" option (check in AMFI name)

### Common NAV Ranges
- **Large Cap Funds**: ₹50 - ₹600
- **Mid Cap Funds**: ₹50 - ₹200
- **Small Cap Funds**: ₹50 - ₹300
- **ELSS Funds**: ₹50 - ₹300
- **Hybrid/Balanced**: ₹50 - ₹500

If NAV is ₹10-₹15, it's likely:
- A newly launched fund
- An IDCW (dividend) option
- An interval fund
- Wrong scheme code

---

## Need Help?

### Can't Find a Fund?
1. Try shorter search terms
2. Try the fund house name (HDFC, ICICI, SBI, etc.)
3. Try "large cap", "mid cap", "small cap", "elss"
4. Search on AMFI website: https://www.amfiindia.com/net-asset-value/nav-history

### Fund Doesn't Exist?
Some funds may have:
- Been merged into other funds
- Been closed/wound up
- Changed names significantly
- Never had a Direct Plan option

### Still Stuck?
- Remove the fund from your app for now
- Use alternative funds from the same category
- Focus on verified funds that work

---

## Progress Tracking

Create a checklist as you fix funds:

### Large Cap Funds
- [x] SBI-BLUECHIP ✅ (Already correct)
- [x] MIRAE-LARGECAP ✅ (Already correct)
- [ ] HDFC-TOP100 ❌ (Fix needed)
- [ ] ICICI-BLUECHIP ❌ (Fix needed)
- [ ] AXIS-BLUECHIP ❌ (Fix needed)
- [ ] KOTAK-BLUECHIP ❌ (Fix needed)
- [ ] NIPPON-LARGECAP ❌ (Fix needed)

### ELSS (Tax Saver)
- [ ] AXIS-ELSS ❌ (Fix needed)
- [ ] PARAG-ELSS ❌ (Fix needed)
- [ ] HDFC-ELSS ❌ (Fix needed)
- [ ] ICICI-ELSS ❌ (Fix needed - Regular to Direct)
- [ ] SBI-ELSS ❌ (Fix needed)

### Hybrid Funds
- [x] ICICI-HYBRID ✅ (Just fixed!)
- [x] AXIS-HYBRID ✅ (Already correct)
- [x] KOTAK-HYBRID ✅ (Already correct)

---

## Next Steps

1. **Start with HDFC-TOP100** (most popular fund in the errors list)
2. **Fix 5 funds per session** (don't overwhelm yourself)
3. **Test each fund after fixing** (verify NAV and charts work)
4. **Keep this guide open** for reference

Good luck! 🚀
