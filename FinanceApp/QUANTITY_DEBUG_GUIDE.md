# 🐛 Mutual Fund Quantity Tracking Issue - Debug Guide

## Problem Report
**User states**: 
1. No quantity field when adding initial mutual fund investment
2. Quantity not showing in investment details

## Investigation Checklist

### ✅ Code Review - What SHOULD Work

#### 1. Add Investment Screen (`add_investment_screen.dart`)
**Lines 239-254**: Quantity field IS present
```dart
TextFormField(
  controller: _quantityController,
  decoration: const InputDecoration(
    labelText: 'Initial Quantity (Optional)',
    hintText: 'e.g., 100 (shares/units)',
    border: OutlineInputBorder(),
    prefixIcon: Icon(Icons.shopping_basket),
  ),
  keyboardType: TextInputType.number,
  // ... validation ...
)
```

**Lines 87-97**: Quantity IS being saved
```dart
// Parse quantity (optional)
double? quantity;
if (_quantityController.text.isNotEmpty) {
  quantity = double.tryParse(_quantityController.text);
}

final transaction = Transaction(
  // ...
  quantity: quantity,
  // ...
);
```

#### 2. Transaction Model (`transaction.dart`)
**Lines 6, 16**: Quantity field exists
```dart
final double? quantity; // Number of units/shares bought or sold

Transaction({
  // ...
  this.quantity,
});
```

**Lines 19-22**: Price per unit calculated correctly
```dart
double? get pricePerUnit {
  if (quantity == null || quantity == 0) return null;
  return amount.abs() / quantity!;
}
```

#### 3. Investment Model (`investment.dart`)
**Lines 58-68**: Total quantity calculated from transactions
```dart
double get totalQuantity {
  double buyQuantity = transactions
      .where((t) => t.type == 'buy' && t.quantity != null)
      .fold(0.0, (sum, t) => sum + t.quantity!);
  
  double sellQuantity = transactions
      .where((t) => t.type == 'sell' && t.quantity != null)
      .fold(0.0, (sum, t) => sum + t.quantity!);
  
  return buyQuantity - sellQuantity;
}
```

#### 4. Investment Detail Screen (`investment_detail_screen.dart`)
**Lines 227-252**: Quantity IS displayed (if > 0)
```dart
if (investment.totalQuantity > 0) ...[
  _buildMetricRow(
    'Total Quantity',
    investment.totalQuantity.toStringAsFixed(2),
  ),
  // ... average price, current price ...
]
```

#### 5. Database Schema (`database_service.dart`)
**Line 56**: Quantity column exists
```dart
quantity REAL,
```

### ❓ Possible Issues

#### Issue 1: UI Not Showing Quantity Field
**Symptoms**: Quantity input field not visible when adding investment

**Possible Causes**:
1. ✅ Quantity field only shows for NEW investments (not edits)
   - Check line 215: `if (!isEdit) ...`
   - When editing, quantity field is hidden
   - **This is by design** - quantity added per transaction

2. ❌ Code not updated in running app
   - Need hot reload or restart
   - Press `r` in terminal OR `Ctrl+S` in code

3. ❌ Form too long, need to scroll
   - Quantity field is BELOW the amount field
   - User might need to scroll down

**How to Test**:
1. Click "+ Add Investment" (NOT edit existing)
2. Scroll down past the "Initial Amount" field
3. You should see "Initial Quantity (Optional)"

#### Issue 2: Quantity Not Displaying in Details
**Symptoms**: Added quantity but not shown in investment details

**Possible Causes**:
1. ❌ Quantity is 0 or not saved
   - Check: `if (investment.totalQuantity > 0)`
   - If quantity = 0, the entire section is hidden

2. ❌ Transaction saved without quantity
   - Quantity field was empty when submitting
   - OR validation failed silently

3. ❌ Database not updated
   - Old investment created before quantity feature
   - Need to add new transaction with quantity

**How to Test**:
1. Open investment details
2. Add a new transaction with quantity
3. Check if "Portfolio Details" section appears

#### Issue 3: Mutual Fund Specific Issue
**Symptoms**: Works for stocks but not mutual funds

**Analysis**: There's NO difference in code between stocks and MFs
- Same `add_investment_screen.dart` for both
- Same transaction model
- Same quantity calculation

**Possible User Confusion**:
- Mutual funds use "units" instead of "shares"
- But field label says "shares/units"
- Functionality is identical

### 🔍 Debug Steps

#### Step 1: Verify Field Exists
1. Open app in Chrome (already running)
2. Click "+ Add Investment" button
3. Scroll down - do you see these fields in order?
   - ✅ Investment Name
   - ✅ Description (Optional)
   - ✅ Ticker Symbol (Optional)
   - ✅ Initial Amount
   - ❓ **Initial Quantity (Optional)** ← Should be here
   - ✅ Investment Date
   - ✅ Add Investment button

#### Step 2: Test Adding Investment with Quantity
```
1. Click "+ Add Investment"
2. Name: "Test Mutual Fund"
3. Ticker: "HDFC-TOP100"
4. Amount: 10000
5. Quantity: 22.24  ← Enter this
6. Date: Today
7. Click "Add Investment"
```

Expected Result:
- Investment created
- Transaction has quantity = 22.24
- Detail screen shows "Total Quantity: 22.24"
- Shows "Average Price/Unit: ₹449.64" (10000/22.24)

#### Step 3: Check Existing Investment
If quantity doesn't show for existing investment:

**Reason**: The initial transaction was created WITHOUT quantity

**Fix**: Add a new transaction with quantity
1. Open the investment
2. Click "+ Add Transaction"
3. Type: Buy
4. Amount: 5000
5. Quantity: 11.12 ← Enter quantity
6. Submit

Now check:
- Total Quantity should show 11.12
- Average Price/Unit should show

### 🔧 Potential Fixes

#### Fix 1: App Not Updated
```bash
# In Flutter terminal, press 'r' or run:
# Hot reload
```

#### Fix 2: Clear Old Data and Test Fresh
```bash
# In Chrome:
# 1. Open DevTools (F12)
# 2. Application tab
# 3. Storage → Clear site data
# 4. Refresh page
# 5. Add new investment with quantity
```

#### Fix 3: Check if Quantity Field is Conditional
Search for any code that might hide the quantity field:
- Check if `isEdit` condition is wrong
- Check if there's market-specific logic (India vs Australia)
- Check if there's asset type logic (MF vs Stock)

**Current code check** (line 215):
```dart
if (!isEdit) ...[
  // Quantity field IS here
]
```

This means quantity field ONLY shows when adding NEW investment, NOT when editing.
**This is correct behavior** - you add quantity per transaction, not at investment level.

### 📝 User Instructions

#### To Add Quantity to New Investment:
1. **Click "+ Add Investment"** (green button at bottom right)
2. Fill in details:
   - Name: Your mutual fund name
   - Ticker: HDFC-TOP100 (or other MF code)
   - Amount: Investment amount (e.g., 10000)
   - **Quantity**: Number of units (e.g., 22.24)
3. Click "Add Investment"

#### To Add Quantity to Existing Investment:
1. **Open the investment** (click on card)
2. **Click "+ Add Transaction"** (button at bottom)
3. Select "Investment (Buy)"
4. Amount: Additional investment (e.g., 5000)
5. **Quantity**: Additional units (e.g., 11.12)
6. Click "Add Transaction"

#### To View Quantity:
1. Open investment details
2. Look for **"Portfolio Details"** section
3. You should see:
   - Total Quantity: XX.XX
   - Average Price/Unit: ₹XXX.XX
   - Current Price/Unit: ₹XXX.XX

### ⚠️ Important Notes

1. **Quantity is optional** - you don't HAVE to enter it
2. **Quantity only shows if > 0** - if you didn't enter quantity, section is hidden
3. **Old investments won't have quantity** - need to add new transaction with quantity
4. **Editing investment doesn't show quantity field** - quantity is per transaction
5. **Mutual fund units can be decimal** - e.g., 22.24 units is valid

### 🎯 Most Likely Cause

Based on user report "no quantity in initial investment":

**Theory 1**: User is EDITING existing investment
- When you click "Edit" on existing investment, quantity field doesn't show
- This is by design - quantity is per transaction
- Solution: Add new transaction with quantity

**Theory 2**: User needs to scroll down
- Quantity field is below Amount field
- On small screens, might need to scroll
- Solution: Scroll down in the form

**Theory 3**: User added investment without quantity
- Then looking at details, no quantity shows
- This is correct behavior
- Solution: Add transaction with quantity

### 📸 Where to Find Quantity Field

**In Add Investment Screen**:
```
┌─────────────────────────────────────┐
│ ← Add Investment                    │
├─────────────────────────────────────┤
│                                     │
│ Investment Name       [____________]│
│                                     │
│ Description          [____________] │
│ (Optional)           [____________] │
│                      [____________] │
│                                     │
│ Ticker Symbol        [____________] │
│ (Optional)                      [🔍]│
│                                     │
│ ₹ Initial Amount     [____________] │
│                                     │
│ 🛒 Initial Quantity   [____________] │ ← HERE!
│    (Optional)                       │
│    e.g., 100 (shares/units)         │
│                                     │
│ 📅 Investment Date    [DD/MM/YYYY]  │
│                                     │
│         [ Add Investment ]          │
│                                     │
└─────────────────────────────────────┘
```

**In Investment Detail Screen** (after adding with quantity):
```
┌─────────────────────────────────────┐
│ Portfolio Overview                  │
│                                     │
│ Net Invested    Current Value       │
│ ₹10,000         ₹11,000            │
│                                     │
│ Profit/Loss     Return              │
│ ₹1,000 (10%)    12.5%              │
│                                     │
│ XIRR            CAGR                │
│ 5.27%           5.00%              │
│                                     │
├─────────────────────────────────────┤
│ Portfolio Details                   │ ← This section
│                                     │
│ Total Quantity:        22.24        │ ← Shows here
│ Average Price/Unit:    ₹449.64      │
│ Current Price/Unit:    ₹494.60      │
└─────────────────────────────────────┘
```

## Next Actions

1. **Hot reload app**: Press `r` in terminal
2. **Test adding NEW investment** with quantity field filled
3. **Check if quantity appears** in investment details
4. **If still not showing**: Take screenshot and check these:
   - Is "Initial Quantity" field visible in form?
   - Did you enter a number in quantity field?
   - Does "Portfolio Details" section appear in details?

---

**Status**: Code is correct, likely user confusion or hot reload needed
**Solution**: Follow user instructions above to test properly
