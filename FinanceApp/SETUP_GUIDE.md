# Investment Tracker - Flutter App

## 🎯 Overview
Your Flutter investment tracking app is ready! This app helps you track XIRR (Extended Internal Rate of Return) and CAGR (Compound Annual Growth Rate) for your investments.

## 📋 Prerequisites

Before running the app, you need to install Flutter:

### Install Flutter on Windows

1. **Download Flutter SDK**
   - Visit: https://docs.flutter.dev/get-started/install/windows
   - Download the latest stable release

2. **Extract Flutter**
   - Extract the zip file to a location like `C:\src\flutter`
   - DO NOT install Flutter in `C:\Program Files\`

3. **Update Path**
   - Add Flutter to your system PATH:
     - Search for "Environment Variables" in Windows
     - Edit the PATH variable
     - Add: `C:\src\flutter\bin` (or your Flutter location)

4. **Install Dependencies**
   - Install Git for Windows: https://git-scm.com/download/win
   - Install Android Studio: https://developer.android.com/studio

5. **Run Flutter Doctor**
   ```powershell
   flutter doctor
   ```
   - Follow any additional setup instructions
   - Accept Android licenses: `flutter doctor --android-licenses`

## 🚀 Running the App

Once Flutter is installed:

1. **Get Dependencies**
   ```powershell
   flutter pub get
   ```

2. **Run the App**
   
   For Android Emulator:
   ```powershell
   flutter run
   ```
   
   For Chrome (Web):
   ```powershell
   flutter run -d chrome
   ```

3. **Build APK** (for Android)
   ```powershell
   flutter build apk --release
   ```

## 📱 Features

✅ **Track Multiple Investments**
- Add unlimited investments with custom names and descriptions
- Organize all your investments in one place

✅ **Transaction Management**
- Record buy/sell transactions with dates
- Add notes to transactions
- Delete or edit transactions easily

✅ **Advanced Calculations**
- **XIRR**: Extended Internal Rate of Return using Newton-Raphson method
- **CAGR**: Compound Annual Growth Rate
- **Absolute Returns**: Total profit/loss percentage
- Real-time calculation updates

✅ **Beautiful UI**
- Material Design 3
- Dark/Light theme support
- Intuitive navigation
- Visual indicators for profits/losses

✅ **Local Storage**
- SQLite database for offline access
- No internet required
- Fast and secure

## 📁 Project Structure

```
lib/
├── main.dart                          # App entry point
├── models/
│   ├── investment.dart                # Investment data model
│   └── transaction.dart               # Transaction data model
├── screens/
│   ├── home_screen.dart               # Main dashboard
│   ├── add_investment_screen.dart     # Add/Edit investment
│   └── investment_detail_screen.dart  # Investment details & analytics
├── providers/
│   └── investment_provider.dart       # State management
├── services/
│   └── database_service.dart          # SQLite operations
└── utils/
    └── calculations.dart              # XIRR & CAGR calculations
```

## 🧮 How XIRR & CAGR Work

### XIRR (Extended Internal Rate of Return)
XIRR calculates the annualized rate of return for investments with irregular cash flows. It uses the Newton-Raphson numerical method to find the rate where NPV = 0.

**Example**: If you invest $10,000 on Jan 1 and $5,000 on Jul 1, and the value is $16,000 on Dec 31, XIRR tells you the effective annual return rate.

### CAGR (Compound Annual Growth Rate)
CAGR shows the mean annual growth rate assuming the investment grew at a steady rate.

**Formula**: `CAGR = (Ending Value / Beginning Value)^(1/Years) - 1`

## 🔧 Troubleshooting

### "Flutter command not found"
- Make sure Flutter is in your PATH
- Restart your terminal/VS Code after adding to PATH

### Android build errors
- Run: `flutter doctor --android-licenses`
- Accept all licenses

### Package errors
- Run: `flutter clean`
- Then: `flutter pub get`

## 📝 Next Steps

Consider adding these features:
- Export data to CSV/Excel
- Charts and graphs (using fl_chart package)
- Multiple currency support
- Cloud backup
- Category-wise investment grouping
- Tax calculation helpers

## 📄 License

MIT License - Feel free to use this app for personal or commercial purposes!

---

**Happy Investing! 📈💰**
