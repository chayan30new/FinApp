# 📱 Investment Tracker - User Flow & Features

## 🗺️ App Navigation Flow

```
┌─────────────────────────────────────────────────────────────┐
│                        HOME SCREEN                          │
│  ┌───────────────────────────────────────────────────────┐  │
│  │           📊 Portfolio Summary Card                   │  │
│  │  • Total Invested: $50,000                           │  │
│  │  • Current Value: $55,000                            │  │
│  │  • Total Return: +10%                                │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                             │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  💼 Mutual Fund ABC              [XIRR: 15.2%] 📈    │  │
│  │  Invested: $20,000  Current: $23,000                 │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                             │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  💰 Stock XYZ                     [XIRR: 8.5%] 📈    │  │
│  │  Invested: $30,000  Current: $32,000                 │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                             │
│                           [+ Add Investment]                │
└─────────────────────────────────────────────────────────────┘
                               │
                               │ Tap on Investment
                               ↓
┌─────────────────────────────────────────────────────────────┐
│                  INVESTMENT DETAIL SCREEN                   │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                                             │
│  ┌───────────────────────────────────────────────────────┐  │
│  │              📊 Performance Metrics                   │  │
│  │  ────────────────────────────────────────────────    │  │
│  │  Total Invested:      $20,000                        │  │
│  │  Current Value:       $23,000                        │  │
│  │  Absolute Return:     +15%  🟢                       │  │
│  │  ────────────────────────────────────────────────    │  │
│  │  XIRR:               15.2%  🟢                       │  │
│  │  CAGR:               14.8%  🟢                       │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                             │
│  ┌───────────────────────────────────────────────────────┐  │
│  │                   📝 Transactions                     │  │
│  │  ─────────────────────────────────────────────────   │  │
│  │  🔴 Investment        01 Jan 2024       $10,000      │  │
│  │  🔴 Investment        01 Jun 2024       $5,000       │  │
│  │  🟢 Withdrawal        01 Dec 2024       $2,000       │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                             │
│                        [+ Add Transaction]                  │
└─────────────────────────────────────────────────────────────┘
```

## 🎯 Key Features Explained

### 1. **XIRR Calculation**
**What it does**: Calculates your annualized return rate even when you invest different amounts at different times.

**Example**:
```
You invest:
- $10,000 on 1st Jan 2024
- $5,000 on 1st Jun 2024
- $3,000 on 1st Sep 2024

Current value: $19,500 on 31st Dec 2024

XIRR tells you: "Your money is growing at 12.5% per year"
```

**Why it's useful**: 
- Works with irregular investments (like SIPs that vary)
- More accurate than simple returns
- Industry standard for mutual funds

### 2. **CAGR Calculation**
**What it does**: Shows steady growth rate from start to end.

**Example**:
```
Initial investment: $10,000 on 1st Jan 2023
Current value: $12,100 on 31st Dec 2024

CAGR = 10% per year
(This means your investment grew at a steady 10% annually)
```

**Why it's useful**:
- Easy to understand
- Good for comparing investments
- Shows long-term performance

### 3. **Absolute Return**
**What it does**: Simple profit/loss percentage.

**Formula**: `(Current Value - Invested) / Invested × 100`

**Example**:
```
Invested: $10,000
Current Value: $11,500
Absolute Return: 15%
```

## 🎨 Color Coding System

| Color | Meaning | Where Used |
|-------|---------|------------|
| 🟢 Green | Profit/Gain | Positive returns, upward trends |
| 🔴 Red | Loss | Negative returns, downward trends |
| 🔵 Blue | Neutral | Total invested amount |
| ⚫ Black | Default | Labels, text |

## 📱 Screen-by-Screen Guide

### Home Screen
**Purpose**: Overview of all investments

**What you see**:
- Portfolio summary (total invested, current value, overall return)
- List of all investments with quick stats
- Each card shows: Name, invested amount, current value, XIRR

**Actions**:
- Tap investment → View details
- Tap "+ Add Investment" → Create new investment

### Add Investment Screen
**Purpose**: Create or edit an investment

**Fields**:
- Investment Name (required) - e.g., "HDFC Mutual Fund"
- Description (optional) - e.g., "Large cap equity fund"
- Initial Amount (required) - e.g., $10,000
- Investment Date (required) - When you first invested

**Validation**:
- Name can't be empty
- Amount must be > 0
- Date can't be in future

### Investment Detail Screen
**Purpose**: Deep dive into one investment

**Top Section - Performance Metrics**:
- Total Invested
- Current Value
- Absolute Return (with color indicator)
- XIRR (annualized return)
- CAGR (steady growth rate)

**Bottom Section - Transaction History**:
- List of all buy/sell transactions
- Each shows: Type, Date, Amount
- 🔴 Red arrow down = Investment (money out)
- 🟢 Green arrow up = Withdrawal (money in)

**Actions**:
- Edit investment (top-right edit icon)
- Delete investment (top-right delete icon)
- Add transaction (bottom button)
- Long-press transaction to delete

### Add Transaction Dialog
**Purpose**: Record a new buy or sell

**Fields**:
- Type: Investment or Withdrawal (segmented button)
- Amount (required) - e.g., $5,000
- Date (required) - When transaction occurred
- Notes (optional) - Any additional info

**Transaction Types**:
- **Investment**: You're putting money in (reduces your cash)
- **Withdrawal**: You're taking money out (gives you cash)

## 💾 Data Storage

**Where data is stored**: SQLite database on your device

**Tables**:
1. `investments` - Stores investment details
2. `transactions` - Stores all buy/sell records

**Data Safety**:
- Automatic save after each action
- Data persists even if app is closed
- No internet needed
- No data sent to servers

## 🔄 How Calculations Update

```
User Action → Database Update → Provider Notified → UI Rebuilds → New Values Shown
```

**Real-time Updates**:
- Add transaction → XIRR/CAGR recalculated immediately
- Delete transaction → Metrics update instantly
- Edit investment → Home screen refreshes

## 📊 Understanding the Metrics

### When to use XIRR vs CAGR?

**Use XIRR when**:
- Multiple investments at different times
- Irregular contributions (varying SIPs)
- Want accurate annualized returns
- Comparing mutual funds

**Use CAGR when**:
- Single lump sum investment
- Want simple growth rate
- Comparing with fixed deposits
- Long-term performance view

### What's a good return?

| Investment Type | Good XIRR/CAGR |
|----------------|----------------|
| Equity Mutual Funds | 12-15% |
| Debt Funds | 7-9% |
| Fixed Deposits | 6-7% |
| Stocks | 15%+ |
| Gold | 8-10% |

## 🎯 Best Practices

### 1. **Enter Accurate Dates**
- Use actual transaction dates
- Don't use today's date for old investments
- Accuracy matters for XIRR

### 2. **Track All Transactions**
- Record every investment
- Don't forget withdrawals
- Include dividend reinvestments

### 3. **Update Current Value**
- For ongoing investments, add a "sell" transaction with current value
- Or the app will use your last invested amount

### 4. **Regular Reviews**
- Check XIRR monthly
- Compare with benchmarks
- Rebalance if needed

## 🚀 Quick Start Workflow

```
1. Install Flutter & Dependencies
   ↓
2. Run: flutter pub get
   ↓
3. Run: flutter run
   ↓
4. Add First Investment
   ↓
5. Add More Transactions
   ↓
6. Track Performance
   ↓
7. Make Informed Decisions!
```

## 🎓 Learning Resources

**Understanding XIRR**:
- Excel XIRR function works similarly
- Used by all mutual fund companies
- More accurate than simple average

**Understanding CAGR**:
- Standard measure of investment growth
- Smooths out volatility
- Easy comparison tool

---

**Remember**: Past performance doesn't guarantee future results. These calculations help you track, but investment decisions should consider multiple factors! 📈💡
