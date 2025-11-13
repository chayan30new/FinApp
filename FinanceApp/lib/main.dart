import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'providers/investment_provider.dart';
import 'providers/watchlist_provider.dart';
import 'providers/settings_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SettingsProvider()),
        ChangeNotifierProvider(create: (context) => InvestmentProvider()),
        ChangeNotifierProvider(create: (context) => WatchlistProvider()),
      ],
      child: MaterialApp(
        title: 'Investment Tracker',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
