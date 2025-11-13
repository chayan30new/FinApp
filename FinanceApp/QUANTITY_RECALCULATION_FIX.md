# 🔧 Fix: Quantity Auto-Recalculation on Date Change

## Problem

**Issue**: When user changes the investment date after quantity was auto-calculated, the quantity doesn't recalculate with the new date's NAV.

**Example**:
```
1. User enters: ICICI-HYBRID, ₹10,000, Date: Nov 1
   → Quantity auto-calculates: 22.2425 units (NAV ₹449.68)
   
2. User changes date to: Oct 1
   → Quantity stays: 22.2425 units ❌
   → Should recalculate with Oct 1 NAV ✓
```

---

## Root Cause

The auto-calculation logic had this check:

```dart
// Don't override if user already entered quantity
if (_quantityController.text.isNotEmpty) {
  return;
}
```

**Problem**: After first auto-calculation, the quantity field is no longer empty, so subsequent date changes don't trigger recalculation!

---

## Solution

### Approach: Track Auto-Calculation vs Manual Entry

Added two flags to distinguish between:
1. **Auto-calculated quantity** - Can be recalculated when date/amount/ticker changes
2. **Manually entered quantity** - Should NOT be overwritten

### Implementation

#### 1. Added State Variables

```dart
bool _quantityWasAutoCalculated = false;
bool _isSettingQuantityProgrammatically = false;
```

- `_quantityWasAutoCalculated`: Tracks if current quantity came from auto-calculation
- `_isSettingQuantityProgrammatically`: Prevents onChanged from firing during programmatic updates

#### 2. Updated Auto-Calculation Logic

**Before**:
```dart
// Don't override if user already entered quantity
if (_quantityController.text.isNotEmpty) {
  return;
}
```

**After**:
```dart
// Don't override if user manually entered quantity
// (only recalculate if it was auto-calculated before)
if (_quantityController.text.isNotEmpty && !_quantityWasAutoCalculated) {
  return;
}
```

Now it checks:
- If field is empty → auto-calculate ✓
- If field has value AND it was auto-calculated → recalculate ✓
- If field has value AND it was manually entered → don't override ✓

#### 3. Mark When Auto-Calculating

```dart
setState(() {
  _isSettingQuantityProgrammatically = true;
  _quantityController.text = quantity.toStringAsFixed(4);
  _quantityWasAutoCalculated = true; // Mark as auto-calculated
  _isSettingQuantityProgrammatically = false;
});
```

#### 4. Detect Manual Entry

```dart
onChanged: (value) {
  // Don't react if we're setting it programmatically
  if (_isSettingQuantityProgrammatically) {
    return;
  }
  
  // If user manually clears or types, mark as manual
  setState(() {
    _quantityWasAutoCalculated = false;
    _navCalculationMessage = null;
  });
}
```

---

## Behavior After Fix

### Scenario 1: Auto-Calculate → Change Date → Recalculate ✓

```
Step 1: Enter ticker + amount + date
→ Quantity: 22.2425 (auto-calculated)
→ Flag: _quantityWasAutoCalculated = true

Step 2: Change date
→ Auto-calculation runs again
→ Fetches new NAV for new date
→ Quantity: 20.1234 (recalculated)
→ Flag: Still true
```

### Scenario 2: Auto-Calculate → Manual Edit → Change Date → No Override ✓

```
Step 1: Enter ticker + amount + date
→ Quantity: 22.2425 (auto-calculated)
→ Flag: _quantityWasAutoCalculated = true

Step 2: User manually types "25"
→ onChanged fires
→ Flag: _quantityWasAutoCalculated = false

Step 3: Change date
→ Auto-calculation checks flag
→ Sees manual entry (flag = false)
→ Doesn't override ✓
→ Quantity stays: 25
```

### Scenario 3: Manual Entry from Start → Change Date → No Override ✓

```
Step 1: Enter ticker + amount + date
Step 2: User manually types quantity "50"
→ Flag: _quantityWasAutoCalculated = false

Step 3: Change date
→ Auto-calculation sees manual entry
→ Doesn't override ✓
→ Quantity stays: 50
```

### Scenario 4: Auto-Calculate → Clear → Change Date → Recalculate ✓

```
Step 1: Auto-calculated quantity: 22.2425
→ Flag: _quantityWasAutoCalculated = true

Step 2: User clears quantity field
→ onChanged fires with empty value
→ Flag: _quantityWasAutoCalculated = false

Step 3: Change date
→ Sees empty field
→ Auto-calculates with new date ✓
```

---

## Testing

### Test Case 1: Basic Recalculation
```
1. Add Investment
2. Ticker: ICICI-HYBRID
3. Amount: 10000
4. Date: Nov 1, 2025
   → Verify quantity auto-fills
5. Change date to: Oct 1, 2025
   → Verify quantity recalculates
   → Verify message updates with new NAV
```

### Test Case 2: Manual Entry Protection
```
1. Add Investment
2. Ticker: ICICI-HYBRID
3. Amount: 10000
4. Date: Nov 1, 2025
   → Quantity auto-fills: 22.2425
5. Manually change quantity to: 25
6. Change date to: Oct 1, 2025
   → Verify quantity STAYS 25 (not recalculated)
```

### Test Case 3: Amount Change
```
1. Add Investment
2. Ticker: ICICI-HYBRID
3. Amount: 10000
4. Date: Nov 1, 2025
   → Quantity auto-fills: 22.2425
5. Change amount to: 20000
   → Verify quantity recalculates to: ~44.48
```

### Test Case 4: Ticker Change
```
1. Add Investment
2. Ticker: ICICI-HYBRID
3. Amount: 10000
4. Date: Nov 1, 2025
   → Quantity auto-fills: 22.2425
5. Change ticker to: HDFC-TOP100
   → Verify quantity recalculates with HDFC NAV
```

---

## Edge Cases Handled

✅ **Empty to Auto**: Empty field → auto-calculates
✅ **Auto to Auto**: Auto-calculated → recalculates on changes
✅ **Auto to Manual**: Auto-calculated → user edits → no more auto
✅ **Manual to Manual**: Manual entry → stays manual
✅ **Clear Field**: Clearing field → allows auto-calculation again
✅ **Programmatic Updates**: onChanged doesn't interfere with auto-calculation

---

## Files Modified

**File**: `lib/screens/add_investment_screen.dart`

**Changes**:
1. Added `_quantityWasAutoCalculated` flag
2. Added `_isSettingQuantityProgrammatically` flag
3. Updated `_autoCalculateQuantityForMutualFund()` logic
4. Updated quantity field `onChanged` handler
5. Set flags when auto-calculating

---

## Impact

### Before Fix ❌
- Quantity auto-calculates once
- Date changes don't update quantity
- User has to manually recalculate
- Confusing behavior

### After Fix ✓
- Quantity recalculates when date/amount/ticker changes
- Respects manual entries (doesn't override)
- Clear distinction between auto vs manual
- Expected behavior achieved

---

## Summary

**Problem**: Quantity doesn't recalculate on date change
**Root Cause**: Logic prevented override of non-empty field
**Solution**: Track auto-calculated vs manual entry
**Result**: Smart recalculation that respects user input

**Status**: ✅ Fixed and Ready to Test

---

## How to Test

1. **Hot reload** your app (press `r` in terminal)

2. **Test basic recalculation**:
   ```
   - Add investment: ICICI-HYBRID, ₹10,000, Nov 1
   - Note the quantity (e.g., 22.24)
   - Change date to Oct 1
   - Quantity should recalculate with Oct NAV
   ```

3. **Test manual entry protection**:
   ```
   - Let quantity auto-calculate
   - Manually change it to a different value
   - Change the date
   - Quantity should NOT change (respects your manual entry)
   ```

The fix maintains the smart behavior: auto-calculated quantities update automatically, but manual entries are protected!

---

**Fixed**: November 9, 2025
**Impact**: Improved UX for mutual fund quantity tracking
**Backward Compatible**: Yes, no breaking changes
