# 💰 Investment Value Tracking - How It Works

## 🎯 Understanding Investment Growth and Tracking

Your investments can grow or shrink over time. This app now properly tracks the actual current market value, not just what you put in minus what you took out.

## 📊 Key Concepts

### 1. **Total Invested (Buy Transactions)**
- All the money you put INTO the investment
- Example: $10,000 on Jan 1 + $5,000 on Jun 1 = $15,000 total invested

### 2. **Total Withdrawn (Sell Transactions)**
- All the money you took OUT of the investment
- Example: Withdrew $3,000 on Dec 1 = $3,000 total withdrawn

### 3. **Net Invested**
- Formula: `Total Invested - Total Withdrawn`
- This is your "actual money at risk"
- Example: $15,000 invested - $3,000 withdrawn = $12,000 net invested

### 4. **Current Market Value** ⭐ NEW!
- What your investment is worth RIGHT NOW in the market
- This can be:
  - **Higher** than net invested (profit! 📈)
  - **Lower** than net invested (loss 📉)
  - **Equal** to net invested (break-even)

### 5. **Profit/Loss**
- Formula: `Current Market Value - Net Invested`
- Shows absolute gain or loss
- Example: $14,500 current - $12,000 net = +$2,500 profit

## 💡 Real-World Examples

### Example 1: Growing Investment (Profit)

```
Timeline:
├── Jan 1, 2024: Buy $10,000
├── Jun 1, 2024: Buy $5,000
├── Sep 1, 2024: Sell $3,000 (partial withdrawal)
└── Dec 1, 2024: Check current value

Calculations:
├── Total Invested: $15,000 ($10k + $5k)
├── Total Withdrawn: $3,000
├── Net Invested: $12,000 ($15k - $3k)
├── Current Market Value: $14,500 (grown!)
├── Profit/Loss: +$2,500 ($14.5k - $12k)
├── Absolute Return: +20.83%
└── XIRR: ~25% annualized
```

### Example 2: Shrinking Investment (Loss)

```
Timeline:
├── Jan 1, 2024: Buy $10,000
├── Jun 1, 2024: Buy $5,000
└── Dec 1, 2024: Check current value

Calculations:
├── Total Invested: $15,000
├── Total Withdrawn: $0
├── Net Invested: $15,000
├── Current Market Value: $13,000 (shrunk!)
├── Profit/Loss: -$2,000
├── Absolute Return: -13.33%
└── XIRR: ~-15% annualized
```

### Example 3: Withdrawal Greater Than Investment

```
Scenario: Investment grew so much you withdrew more than you put in!

Timeline:
├── Jan 1, 2023: Buy $10,000
├── Jan 1, 2024: Sell $12,000 (more than invested!)
└── Jun 1, 2024: Check remaining value

Calculations:
├── Total Invested: $10,000
├── Total Withdrawn: $12,000
├── Net Invested: -$2,000 (you took out more!)
├── Current Market Value: $5,000 (what's left)
├── Total Gain: $7,000 ($12k + $5k - $10k invested)
└── XIRR: Excellent returns!
```

## 🔄 How to Use This Feature

### Step 1: Add Your Investment
1. Click "+ Add Investment"
2. Enter name and initial amount
3. Click "Add Investment"

### Step 2: Add Transactions Over Time
1. Open investment details
2. Click "+ Add Transaction"
3. Choose:
   - **Buy (Invest More)**: Adding more money
   - **Sell (Withdraw)**: Taking money out
4. Enter amount and date

### Step 3: Update Current Market Value
1. Open investment details
2. Click **"Update Value"** button (top right)
3. Enter the current market value from:
   - Your investment app
   - Bank statement
   - Broker account
   - Mutual fund statement
4. Click "Update"

### Step 4: See Accurate Metrics
The app automatically calculates:
- ✅ Net invested (your actual money at risk)
- ✅ Current value (real market worth)
- ✅ Profit/Loss (absolute gain/loss)
- ✅ Absolute Return (percentage)
- ✅ XIRR (annualized return)
- ✅ CAGR (steady growth rate)

## 📱 UI Breakdown

### Home Screen Shows:
```
Investment Card:
├── Investment Name
├── Net Invested: $12,000 (your actual money in)
├── Current Value: $14,500 (market value)
└── XIRR: 25.3% (annualized return)
```

### Detail Screen Shows:
```
Performance Metrics:
├── Total Invested (Buy): $15,000
├── Total Withdrawn (Sell): $3,000
├── Net Invested: $12,000 (blue)
├── ────────────────────────
├── Current Market Value: $14,500 (green) ← Update this!
├── Profit/Loss: +$2,500 (green/red)
├── Absolute Return: +20.83%
├── ────────────────────────
├── XIRR (Annualized): 25.3%
└── CAGR: 23.8%
```

## 🎯 Best Practices

### 1. Update Current Value Regularly
- **Weekly/Monthly** for active trading
- **Monthly/Quarterly** for mutual funds
- **Quarterly** for long-term investments

### 2. Record All Transactions
- Don't skip any buy or sell
- Include dividend reinvestments as "buy"
- Include bonus units as "buy" with $0 or market value

### 3. Use Actual Market Values
- For stocks: Last traded price × quantity
- For mutual funds: Latest NAV × units
- For bonds: Current market value, not face value

### 4. Check XIRR vs CAGR
- **XIRR**: More accurate for irregular investments (SIPs, multiple deposits)
- **CAGR**: Better for single lump sum investments
- Both should be similar if only one investment was made

## 🔍 Understanding the Math

### Why Net Invested Matters
```
Wrong approach:
Current Value ÷ Total Invested = Return
$14,500 ÷ $15,000 = -3.33% ❌ (Wrong! You withdrew $3k)

Correct approach:
Current Value ÷ Net Invested = Return
$14,500 ÷ $12,000 = +20.83% ✅ (Correct!)
```

### XIRR Calculation
Considers:
- ✅ Exact dates of each transaction
- ✅ Amount of each transaction
- ✅ Current value
- ✅ Time value of money
- ❌ Not just simple average

Formula (simplified):
```
NPV = Σ (Cash Flow / (1 + XIRR)^years) = 0
Solved using Newton-Raphson method
```

## 💡 Pro Tips

### Tip 1: Partial Withdrawals
When you sell part of your investment:
- Record it as "Sell" transaction
- Update current value for the remaining portion
- XIRR will account for both

### Tip 2: Grown Investments
If investment grew from $10k to $15k:
- Don't add $5k as a "buy" transaction
- Instead, click "Update Value" and enter $15,000
- This accurately reflects growth, not new money

### Tip 3: Multiple Investments
For SIP (Systematic Investment Plan):
- Each monthly SIP = one "buy" transaction
- Update current value monthly
- XIRR will show true annualized return

### Tip 4: Loss Scenarios
If your investment is in loss:
- Still update the current value honestly
- App shows red indicators for losses
- XIRR can be negative (that's okay, it's real data)

## 📈 Sample Workflow

### Monthly Routine:
1. **Day 1**: Check investment values in app/statement
2. **Day 2**: Open each investment in tracker
3. **Day 3**: Click "Update Value" for each
4. **Day 4**: Review XIRR and adjust strategy if needed
5. **Day 5**: Add any new transactions (SIP, withdrawals)

## 🎓 Learning Resources

- XIRR calculation: Used by all mutual fund companies
- CAGR calculation: Standard industry measure
- Absolute Return: Simple profit/loss percentage

---

## ✅ Quick Checklist

Before asking "Why are my numbers wrong?":

- [ ] Did you update the current market value recently?
- [ ] Did you record ALL buy and sell transactions?
- [ ] Are your transaction dates accurate?
- [ ] Did you use net invested (not total invested) for calculations?
- [ ] Is your current value from an official source?

---

**Remember**: The app is only as accurate as the data you provide. Update current values regularly for the best insights! 📊💡
