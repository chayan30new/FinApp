# 📱 Investment Tracker

A beautiful Flutter mobile application to track your investments and calculate XIRR (Extended Internal Rate of Return) and CAGR (Compound Annual Growth Rate).

![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)
![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

## ✨ Features

- 📊 **Track Multiple Investments** - Manage unlimited investment portfolios
- 💰 **Transaction Management** - Record all buy/sell transactions with dates
- 📈 **XIRR Calculation** - Accurate Extended Internal Rate of Return using Newton-Raphson method
- 📉 **CAGR Analysis** - Compound Annual Growth Rate for steady growth measurement
- 💾 **Local Storage** - SQLite database for offline access and data privacy
- 📱 **Beautiful UI** - Clean Material Design 3 interface with intuitive navigation
- 🎨 **Visual Indicators** - Color-coded profits (green) and losses (red)
- 📊 **Portfolio Dashboard** - Overview of all investments with total returns

## Prerequisites

Before running this app, make sure you have Flutter installed:

1. Visit [Flutter Installation Guide](https://flutter.dev/docs/get-started/install)
2. Follow the instructions for your operating system (Windows)
3. Run `flutter doctor` to verify installation

## Getting Started

1. **Install Flutter** (if not already installed):
   - Download Flutter SDK
   - Add Flutter to your PATH
   - Run `flutter doctor` to check setup

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the app**:
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── investment.dart
│   └── transaction.dart
├── screens/                  # UI screens
│   ├── home_screen.dart
│   ├── add_investment_screen.dart
│   └── investment_detail_screen.dart
├── providers/                # State management
│   └── investment_provider.dart
├── utils/                    # Utility functions
│   └── calculations.dart
└── services/                 # Data services
    └── database_service.dart
```

## Calculations

### XIRR (Extended Internal Rate of Return)
XIRR calculates the annualized return of investments with irregular cash flows using the Newton-Raphson method.

### CAGR (Compound Annual Growth Rate)
CAGR = (Ending Value / Beginning Value)^(1 / Years) - 1

## License

This project is open source and available under the MIT License.
