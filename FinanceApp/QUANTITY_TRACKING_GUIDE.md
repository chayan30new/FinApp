# Quantity Tracking & Current Value Updates - User Guide

## How Current Market Value is Calculated

Your Investment Tracker app now intelligently calculates the current market value based on what information you provide.

---

## Scenario 1: Provide Current Market Value Explicitly ✅ Most Accurate

**When to use:** You've checked your broker/app and know the exact current value

**What you enter:**
- Transaction Amount: `$2,500`
- Quantity: `100` shares (optional)
- **Current Market Value: `$17,500`** ← You provide this

**What happens:**
- ✅ Portfolio value updated to exactly **$17,500**
- ✅ Quantity tracked (if provided)
- ✅ Price per unit calculated: $2,500 ÷ 100 = $25/share

**Example:**
```
Initial Investment:
- Amount: $10,000
- Quantity: 400 shares
- Current Value: $10,000

Second Transaction (Buy):
- Amount: $2,500
- Quantity: 100 shares
- Current Value: $12,750 (you checked your portfolio)

Result:
- Total Quantity: 500 shares
- Current Value: $12,750 (as you specified)
- Current Price/Share: $12,750 ÷ 500 = $25.50/share
```

---

## Scenario 2: Auto-Calculate from Quantity 🔢 Simplified

**When to use:** You know shares bought but haven't checked total value

**What you enter:**
- Transaction Amount: `$2,500`
- **Quantity: `100` shares** ← You provide this
- Current Market Value: *(leave empty)*

**What happens:**
- ✅ App calculates price per unit: $2,500 ÷ 100 = **$25/share**
- ✅ App calculates total value: Total Quantity × Price per unit
- ✅ Portfolio value auto-updated based on quantity calculation

**Example:**
```
Initial Investment:
- Amount: $10,000
- Quantity: 400 shares
- Current Value: $10,000 (auto-calculated: 400 × $25)

Second Transaction (Buy):
- Amount: $2,500
- Quantity: 100 shares
- Current Value: (empty)

Calculation:
- Price from this transaction: $2,500 ÷ 100 = $25/share
- New total quantity: 400 + 100 = 500 shares
- New current value: 500 × $25 = $12,500 (auto-calculated)

Result:
- Total Quantity: 500 shares
- Current Value: $12,500 (calculated automatically)
- Current Price/Share: $25.00/share
```

---

## Scenario 3: No Quantity Tracking 💰 Traditional

**When to use:** Mutual funds, complex instruments, or when quantity isn't relevant

**What you enter:**
- Transaction Amount: `$2,500`
- Quantity: *(leave empty)*
- **Current Market Value: `$12,750`** ← Required

**What happens:**
- ✅ Portfolio value updated to **$12,750**
- ⚠️ No quantity tracking
- ⚠️ No price per unit calculation

**Example:**
```
Initial Investment:
- Amount: $10,000
- Current Value: $10,000

Second Transaction (Buy):
- Amount: $2,500
- Current Value: $12,750

Result:
- Total Invested: $12,500
- Current Value: $12,750
- Profit/Loss: +$250
- No quantity information
```

---

## Smart Auto-Calculation Logic

The app uses this logic to update current market value:

```
IF user provides Current Value explicitly:
    ✅ Use that value (most accurate)
    
ELSE IF user provides Quantity:
    1. Calculate price per unit = Transaction Amount ÷ Quantity
    2. Get total quantity after transaction
    3. Calculate current value = Total Quantity × Price per unit
    ✅ Use calculated value
    
ELSE:
    ❌ Must provide either Current Value OR Quantity
```

---

## Best Practices

### For Individual Stocks/ETFs 📈
**Recommended:** Provide both quantity AND current value
- Most accurate tracking
- Complete portfolio metrics
- Price per share history

**Alternative:** Provide quantity only
- Simplified entry
- Assumes price per share from your transaction
- Good for regular dollar-cost averaging

### For Mutual Funds 🏦
**Recommended:** Provide current value only
- Units often fractional and complex
- Total value is what matters
- Simpler tracking

### For Mixed Portfolios 📊
**Recommended:** Mix approaches as needed
- Use quantity for stocks
- Use current value for mutual funds
- Maximum flexibility

---

## Understanding the Metrics

When you track quantities, you get additional insights:

### Without Quantity Tracking:
```
Investment: Mutual Fund ABC
├─ Total Invested: $12,500
├─ Total Withdrawn: $0
├─ Net Invested: $12,500
├─ Current Value: $13,200
├─ Profit/Loss: +$700 (+5.6%)
├─ XIRR: 8.5%
└─ CAGR: 8.2%
```

### With Quantity Tracking:
```
Investment: Apple Inc. (AAPL)
├─ Total Invested: $12,500
├─ Total Withdrawn: $0
├─ Net Invested: $12,500
├─ Current Value: $13,200
├─ Profit/Loss: +$700 (+5.6%)
├─ XIRR: 8.5%
├─ CAGR: 8.2%
└─ Portfolio Details:
    ├─ Total Quantity: 75.00 shares
    ├─ Average Price/Unit: $166.67
    └─ Current Price/Unit: $176.00
```

---

## Example: Buying More Stock

### Transaction 1 (Initial):
```
Date: Jan 1, 2025
Amount: $10,000
Quantity: 50 shares
Current Value: $10,000

Calculated:
- Price per share: $10,000 ÷ 50 = $200/share
```

### Transaction 2 (Buy More):
```
Date: Jun 1, 2025
Amount: $2,500
Quantity: 10 shares
Current Value: (leave empty or provide actual value)

Option A - Leave empty (auto-calculate):
- Price from transaction: $2,500 ÷ 10 = $250/share
- New total: 50 + 10 = 60 shares
- Calculated value: 60 × $250 = $15,000

Option B - Provide actual value from broker:
- Current Value: $15,300 (checked broker app)
- New total: 60 shares
- Actual price/share: $15,300 ÷ 60 = $255/share
```

---

## Example: Selling Some Stock

### Transaction 3 (Sell):
```
Date: Dec 1, 2025
Type: Sell (Withdraw)
Amount: $5,100
Quantity: 20 shares
Current Value: $12,750 (or leave empty)

With auto-calculate:
- Price from sale: $5,100 ÷ 20 = $255/share
- New total: 60 - 20 = 40 shares
- Calculated value: 40 × $255 = $10,200

With provided value:
- Current Value: $12,750 (actual portfolio value)
- New total: 40 shares
- Actual price/share: $12,750 ÷ 40 = $318.75/share
```

---

## Validation Rules

The app enforces these rules:

1. ✅ **Must provide either:**
   - Current Market Value, OR
   - Quantity, OR
   - Both (recommended)

2. ✅ **Transaction Amount:** Always required, must be > 0

3. ✅ **Quantity:** If provided, must be > 0

4. ✅ **Current Value:** If provided, must be ≥ 0

5. ❌ **Cannot provide:**
   - Nothing (must have current value OR quantity)
   - Negative values

---

## Tips for Accuracy

### 🎯 Maximum Accuracy
Always provide **both** quantity AND current market value:
- Enter the shares you bought/sold
- Check your broker app for exact portfolio value
- Enter that total value

This gives you:
- Exact portfolio tracking
- Real-time price per share
- Complete transaction history

### ⚡ Quick Entry
Just provide **quantity**:
- Enter shares bought/sold
- Skip current value
- App calculates based on transaction price

Good for:
- Dollar-cost averaging
- Regular purchases
- When you don't need exact values immediately

### 📊 Value-Only Tracking
Just provide **current value**:
- Skip quantity field
- Enter total portfolio value
- Traditional tracking method

Good for:
- Mutual funds
- Complex instruments
- When quantity doesn't matter

---

## Summary

Your Investment Tracker app is now **smart and flexible**:

✅ Tracks quantities when you want detail
✅ Auto-calculates when you want speed  
✅ Works without quantities when not needed
✅ Always updates portfolio value correctly
✅ Gives you the metrics you care about

Choose the approach that works best for each investment! 🚀
