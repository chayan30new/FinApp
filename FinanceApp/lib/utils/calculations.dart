import 'dart:math';
import '../models/transaction.dart';

class FinancialCalculations {
  /// Calculate XIRR (Extended Internal Rate of Return) using Newton-Raphson method
  /// 
  /// XIRR finds the annualized rate of return for a series of cash flows
  /// that are not necessarily periodic.
  /// 
  /// [transactions] - List of transactions with dates and amounts
  /// [currentValue] - Current value of the investment (optional, used if no ending transaction)
  /// 
  /// Returns the XIRR as a percentage (e.g., 0.15 for 15%)
  static double? calculateXIRR(List<Transaction> transactions, {double? currentValue}) {
    if (transactions.isEmpty) return null;
    
    // Sort transactions by date
    List<Transaction> sortedTransactions = List.from(transactions)
      ..sort((a, b) => a.date.compareTo(b.date));
    
    // Prepare cash flows
    List<CashFlow> cashFlows = [];
    
    for (var transaction in sortedTransactions) {
      double amount = transaction.type == 'buy' 
          ? -transaction.amount.abs()  // Investment is negative cash flow
          : transaction.amount;         // Return is positive cash flow
      
      cashFlows.add(CashFlow(date: transaction.date, amount: amount));
    }
    
    // If current value is provided and last transaction is not a sell, add it
    if (currentValue != null && currentValue > 0) {
      DateTime lastDate = sortedTransactions.last.date;
      DateTime today = DateTime.now();
      
      // Only add current value if we don't already have a recent sell transaction
      if (sortedTransactions.last.type != 'sell' || 
          today.difference(lastDate).inDays > 30) {
        cashFlows.add(CashFlow(date: today, amount: currentValue));
      }
    }
    
    if (cashFlows.length < 2) return null;
    
    // Newton-Raphson method to find XIRR
    double guess = 0.1; // Initial guess: 10%
    double tolerance = 0.0001;
    int maxIterations = 100;
    
    for (int i = 0; i < maxIterations; i++) {
      double npv = _calculateNPV(cashFlows, guess);
      double derivative = _calculateDerivative(cashFlows, guess);
      
      // Check if we've converged to a solution (NPV is close to zero)
      if (npv.abs() < tolerance) {
        return guess;
      }
      
      // If derivative is too small, try a different guess
      if (derivative.abs() < 0.000001) {
        // If this is the first iteration and NPV is far from zero,
        // the initial guess is bad - try starting from 0
        if (i == 0 && npv.abs() > 1) {
          guess = 0.0;
          continue;
        }
        // Otherwise, we can't compute a better guess
        break;
      }
      
      double newGuess = guess - npv / derivative;
      
      if ((newGuess - guess).abs() < tolerance) {
        return newGuess;
      }
      
      guess = newGuess;
      
      // Prevent extreme values
      if (guess < -0.99) guess = -0.99;
      if (guess > 10) guess = 10;
    }
    
    // Final check: if NPV is close to zero, return the guess
    // Otherwise return null as we didn't converge
    double finalNpv = _calculateNPV(cashFlows, guess);
    if (finalNpv.abs() < 1.0) {  // Within ₹1 is good enough
      return guess;
    }
    
    return null;  // Failed to converge
  }
  
  /// Calculate Net Present Value
  static double _calculateNPV(List<CashFlow> cashFlows, double rate) {
    DateTime startDate = cashFlows.first.date;
    double npv = 0.0;
    
    for (var cashFlow in cashFlows) {
      double years = cashFlow.date.difference(startDate).inDays / 365.25;
      npv += cashFlow.amount / pow(1 + rate, years);
    }
    
    return npv;
  }
  
  /// Calculate derivative of NPV for Newton-Raphson method
  static double _calculateDerivative(List<CashFlow> cashFlows, double rate) {
    DateTime startDate = cashFlows.first.date;
    double derivative = 0.0;
    
    for (var cashFlow in cashFlows) {
      double years = cashFlow.date.difference(startDate).inDays / 365.25;
      derivative -= years * cashFlow.amount / pow(1 + rate, years + 1);
    }
    
    return derivative;
  }
  
  /// Calculate CAGR (Compound Annual Growth Rate)
  /// 
  /// CAGR = (Ending Value / Beginning Value) ^ (1 / Years) - 1
  /// 
  /// [initialInvestment] - Starting investment amount
  /// [currentValue] - Current value of investment
  /// [startDate] - Date of initial investment
  /// [endDate] - Date to calculate CAGR to (usually today)
  /// 
  /// Returns the CAGR as a percentage (e.g., 0.12 for 12%)
  static double? calculateCAGR({
    required double initialInvestment,
    required double currentValue,
    required DateTime startDate,
    DateTime? endDate,
  }) {
    if (initialInvestment <= 0) return null;
    
    endDate ??= DateTime.now();
    
    double years = endDate.difference(startDate).inDays / 365.25;
    
    if (years <= 0) return null;
    
    double cagr = pow(currentValue / initialInvestment, 1 / years) - 1;
    
    return cagr;
  }
  
  /// Calculate absolute return percentage
  static double calculateAbsoluteReturn({
    required double invested,
    required double currentValue,
  }) {
    if (invested == 0) return 0;
    return ((currentValue - invested) / invested);
  }
  
  /// Calculate total profit/loss
  static double calculateProfitLoss({
    required double invested,
    required double currentValue,
  }) {
    return currentValue - invested;
  }
  
  /// Format percentage for display
  static String formatPercentage(double? value, {int decimals = 2}) {
    if (value == null) return 'N/A';
    return '${(value * 100).toStringAsFixed(decimals)}%';
  }
  
  /// Format currency for display
  static String formatCurrency(double value, {String symbol = '\$'}) {
    // Format with Indian numbering system (lakhs, crores) if rupee symbol
    if (symbol == '₹') {
      return formatIndianCurrency(value);
    }
    return '$symbol${value.toStringAsFixed(2)}';
  }
  
  /// Format currency in Indian numbering system
  static String formatIndianCurrency(double value) {
    final isNegative = value < 0;
    final absValue = value.abs();
    
    String formatted;
    if (absValue >= 10000000) {
      // Crores
      formatted = '₹${(absValue / 10000000).toStringAsFixed(2)} Cr';
    } else if (absValue >= 100000) {
      // Lakhs
      formatted = '₹${(absValue / 100000).toStringAsFixed(2)} L';
    } else {
      formatted = '₹${absValue.toStringAsFixed(2)}';
    }
    
    return isNegative ? '-$formatted' : formatted;
  }
}

/// Helper class for cash flow data
class CashFlow {
  final DateTime date;
  final double amount;
  
  CashFlow({required this.date, required this.amount});
}
