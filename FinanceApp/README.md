# 📱 Investment Tracker

A comprehensive Flutter application to track your investments and calculate XIRR (Extended Internal Rate of Return) and CAGR (Compound Annual Growth Rate) with live stock price tracking and historical charts.

![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)
![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

## ✨ Features

- 📊 **Track Multiple Investments** - Manage unlimited investment portfolios
- 💰 **Transaction Management** - Record all buy/sell transactions with quantities
- 📈 **XIRR Calculation** - Accurate Extended Internal Rate of Return using Newton-Raphson method
- 📉 **CAGR Analysis** - Compound Annual Growth Rate for steady growth measurement
- � **Australian Dollar Support** - AUD currency formatting
- 📊 **Interactive Charts** - Investment growth visualization
- 📉 **Historical Price Charts** - View 1M, 3M, 6M, 1Y, 2Y, 5Y price history
- 🎯 **Watchlist** - Track stocks you want to invest in
- 💹 **Live Price Tracking** - Real-time prices from Yahoo Finance
- 🔍 **Stock Search** - Built-in database of 50+ Australian stocks/ETFs
- � **Cross-Platform Storage** - SQLite for mobile, SharedPreferences for web
- �📱 **Beautiful UI** - Clean Material Design 3 interface with intuitive navigation

## 🚀 Running the App

### Web Browser (Development)

⚠️ **Important:** Due to browser CORS restrictions when fetching live stock prices, you need to run Chrome with security disabled for development:

**Windows:**
```batch
run_web_dev.bat
```

Or manually:
```batch
flutter run -d chrome --web-browser-flag "--disable-web-security" --web-browser-flag "--user-data-dir=%TEMP%\chrome_dev_session"
```

**macOS/Linux:**
```bash
flutter run -d chrome --web-browser-flag "--disable-web-security" --web-browser-flag "--user-data-dir=/tmp/chrome_dev_session"
```

� **Note:** The browser will show a warning banner saying "You are using an unsupported command-line flag" - this is normal and expected for development.

### Mobile (Android/iOS)

Mobile apps don't have CORS restrictions and work perfectly without any special flags:

```bash
# Android
flutter run -d android

# iOS (requires macOS)
flutter run -d ios
```

## Prerequisites

Before running this app, make sure you have Flutter installed:

1. Visit [Flutter Installation Guide](https://flutter.dev/docs/get-started/install)
2. Follow the instructions for your operating system
3. Run `flutter doctor` to verify installation

## Getting Started

1. **Install dependencies**:
   ```bash
   flutter pub get
   ```

2. **Run the app** (use appropriate command from above based on your platform)

## 📁 Project Structure

```
lib/
├── main.dart                       # App entry point
├── models/                         # Data models
│   ├── investment.dart
│   ├── transaction.dart
│   └── watchlist_item.dart
├── screens/                        # UI screens
│   ├── home_screen.dart
│   ├── add_investment_screen.dart
│   ├── investment_detail_screen.dart
│   ├── watchlist_screen.dart
│   └── watchlist_detail_screen.dart
├── providers/                      # State management
│   ├── investment_provider.dart
│   └── watchlist_provider.dart
├── services/                       # Data services
│   ├── database_service.dart       # SQLite for mobile
│   ├── database_service_web.dart   # SharedPreferences for web
│   └── stock_price_service.dart    # Yahoo Finance API
├── utils/                          # Utility functions
│   ├── calculations.dart
│   └── stock_symbols.dart          # Australian stocks database
└── widgets/                        # Reusable widgets
    ├── investment_chart.dart
    └── historical_price_chart.dart
```

## 💡 Understanding CORS

### What is CORS?

CORS (Cross-Origin Resource Sharing) is a security feature in web browsers that blocks requests to external APIs (like Yahoo Finance) from web applications.

### Why does this affect the web app?

- ✅ **Mobile apps:** No CORS restrictions - works perfectly
- ⚠️ **Web browsers:** CORS blocks Yahoo Finance API calls

### Solutions:

1. **Development:** Run Chrome with `--disable-web-security` (use the provided `run_web_dev.bat` script)
2. **Production:** 
   - Use mobile apps (recommended - no CORS issues)
   - Deploy your own backend proxy server
   - Host on a server with proper CORS headers

## 📊 Stock Price Data

The app fetches real-time stock prices and historical data from Yahoo Finance API (free, no API key required).

**Supported Australian stocks (ASX):**
- **Banks:** CBA.AX, NAB.AX, WBC.AX, ANZ.AX
- **Miners:** BHP.AX, RIO.AX, FMG.AX
- **Tech:** XRO.AX, WTC.AX, CPU.AX
- **ETFs:** VAS.AX, VGS.AX, VTS.AX, VDHG.AX, DHHF.AX, NDQ.AX, A200.AX, IOZ.AX
- And 50+ more popular stocks!

## 📈 Calculations

### XIRR (Extended Internal Rate of Return)
XIRR calculates the annualized return of investments with irregular cash flows using the Newton-Raphson iterative method.

Formula: NPV = Σ (Cash Flow / (1 + XIRR)^(Days/365)) = 0

### CAGR (Compound Annual Growth Rate)
CAGR = ((Ending Value / Beginning Value)^(1 / Years)) - 1

## 🔧 Dependencies

Key packages used:
- `provider ^6.1.5` - State management
- `sqflite ^2.4.1` - SQLite database for mobile
- `shared_preferences ^2.5.4` - Web storage
- `fl_chart ^0.66.2` - Interactive charts
- `http ^1.5.0` - API requests for stock prices
- `intl ^0.19.0` - Date and currency formatting

## 🎯 Features in Detail

### Investment Tracking
- Add multiple investment portfolios
- Track buy and sell transactions
- Record quantities (shares/units)
- Set ticker symbols for price tracking
- View profit/loss and returns

### Watchlist
- Monitor stocks before investing
- Set target prices
- View historical price trends
- Built-in stock search

### Charts & Visualization
- Investment growth over time (blue=invested, green=current value)
- Historical price charts with multiple timeframes
- Interactive tooltips with exact values

## 🚀 Future Enhancements

- [ ] Backend proxy server for web deployment
- [ ] Price alerts and notifications
- [ ] Export to CSV/Excel
- [ ] Tax reporting features
- [ ] Dividend tracking
- [ ] Portfolio allocation pie charts
- [ ] Multi-currency support

## 📄 License

This project is open source and available under the MIT License.
