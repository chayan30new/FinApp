# Which Mutual Funds Will Show NAV?

## ✅ VERIFIED - These Will Work

Only these mutual funds have **verified AMFI scheme codes** and will show NAV automatically:

| Ticker Code | Fund Name | AMFI Code | Status |
|-------------|-----------|-----------|--------|
| **SBI-BLUECHIP** | SBI Large Cap FUND-DIRECT PLAN -GROWTH | 119598 | ✅ VERIFIED |
| **MIRAE-LARGECAP** | Mirae Asset Large Cap Fund - Direct Plan - Growth | 118825 | ✅ VERIFIED |
| **PARAG-FLEXI** | Parag Parikh Flexi Cap Fund - Direct Plan - Growth | 122639 | ✅ VERIFIED |
| **AXIS-MIDCAP** | Axis Midcap Fund - Direct Plan - Growth | 120505 | ✅ VERIFIED |

## ❌ NOT VERIFIED - These Won't Work Yet

All other mutual fund codes in the app have **placeholder scheme codes** that are incorrect:

- HDFC-TOP100
- ICICI-BLUECHIP
- AXIS-BLUECHIP
- HDFC-MIDCAP
- AXIS-ELSS
- And ~96 others...

## 🧪 How to Test

1. **Create a new investment** or edit an existing one
2. **Use ticker symbol**: `SBI-BLUECHIP`
3. **Add some transactions** with quantities
4. **Go to investment detail screen**
5. **You should see**:
   - Blue info banner: "NAV is fetched from AMFI India..."
   - Live Market Price card showing: ₹104.37 (or current NAV)
   - Last updated date
   - Portfolio value (NAV × quantity)

## 🔧 What to Do If Your Fund Doesn't Work

### Option 1: Use a Verified Fund (Quick Test)
Use one of the 4 verified funds above to test the NAV fetching.

### Option 2: Find the Scheme Code (For Your Fund)
1. Run this command:
   ```bash
   dart test_amfi.dart
   ```

2. Look for your fund name in the output

3. Copy the scheme code

4. Update `lib/utils/mutual_fund_scheme_codes.dart`:
   ```dart
   'YOUR-FUND-CODE': 'SCHEME_CODE_HERE',
   ```

### Option 3: Manual Entry
If you can't find the scheme code:
1. Click "Enter Price Manually" button
2. Look up NAV at:
   - https://www.amfiindia.com/
   - https://www.valueresearchonline.com/
3. Enter the NAV manually

## 🐛 Debugging

If even `SBI-BLUECHIP` doesn't show NAV:

1. **Check browser console** (F12) for error messages
2. **Look for these debug logs**:
   ```
   Fetching NAV for: SBI-BLUECHIP
   Fetching NAV from AMFI for scheme code: 119598
   AMFI response received: XXXXX bytes
   Parsed XXXX funds from AMFI data
   Found matching scheme code: 119598
   Successfully parsed NAV: ₹104.37 on 2025-11-07
   ```

3. **If you see "No matching scheme code found"**:
   - The scheme code mapping is wrong
   - Update the code in `mutual_fund_scheme_codes.dart`

4. **If you see "AMFI response received: 0 bytes"** or HTTP error:
   - Network issue or AMFI API is down
   - Try again in a few minutes

5. **If you see CORS errors**:
   - Make sure Chrome is running with `--disable-web-security` flag
   - Restart the Flutter app with the correct command

## 📝 Summary

- ✅ **SBI-BLUECHIP works** - Use this to test
- ❌ **Most others don't work yet** - Need correct scheme codes
- 🔍 **Use test scripts** to find scheme codes
- ✏️ **Manual entry** always available as fallback
