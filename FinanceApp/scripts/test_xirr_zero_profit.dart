import 'dart:math';

// Simplified cash flow class
class CashFlow {
  final DateTime date;
  final double amount;
  
  CashFlow({required this.date, required this.amount});
}

// Calculate NPV
double calculateNPV(List<CashFlow> cashFlows, double rate) {
  DateTime startDate = cashFlows.first.date;
  double npv = 0.0;
  
  for (var cashFlow in cashFlows) {
    double years = cashFlow.date.difference(startDate).inDays / 365.25;
    npv += cashFlow.amount / pow(1 + rate, years);
  }
  
  return npv;
}

// Calculate derivative
double calculateDerivative(List<CashFlow> cashFlows, double rate) {
  DateTime startDate = cashFlows.first.date;
  double derivative = 0.0;
  
  for (var cashFlow in cashFlows) {
    double years = cashFlow.date.difference(startDate).inDays / 365.25;
    derivative -= years * cashFlow.amount / pow(1 + rate, years + 1);
  }
  
  return derivative;
}

// Calculate XIRR
double? calculateXIRR(List<CashFlow> cashFlows) {
  if (cashFlows.length < 2) return null;
  
  // Newton-Raphson method
  double guess = 0.1; // Initial guess: 10%
  double tolerance = 0.0001;
  int maxIterations = 100;
  
  print('Starting Newton-Raphson with guess = ${(guess * 100).toStringAsFixed(2)}%');
  
  for (int i = 0; i < maxIterations; i++) {
    double npv = calculateNPV(cashFlows, guess);
    double derivative = calculateDerivative(cashFlows, guess);
    
    print('Iteration $i: guess = ${(guess * 100).toStringAsFixed(2)}%, npv = ${npv.toStringAsFixed(2)}, derivative = ${derivative.toStringAsFixed(2)}');
    
    if (derivative.abs() < 0.000001) {
      print('Breaking: Derivative too small');
      break;
    }
    
    double newGuess = guess - npv / derivative;
    
    if ((newGuess - guess).abs() < tolerance) {
      print('Converged to: ${(newGuess * 100).toStringAsFixed(2)}%');
      return newGuess;
    }
    
    guess = newGuess;
    
    // Prevent extreme values
    if (guess < -0.99) guess = -0.99;
    if (guess > 10) guess = 10;
  }
  
  print('Final guess after max iterations: ${(guess * 100).toStringAsFixed(2)}%');
  return guess;
}

void main() {
  print('=== Test Case 1: Zero Profit/Loss ===');
  print('Invested: ₹10,000 on Jan 1, 2024');
  print('Current Value: ₹10,000 on Nov 9, 2025');
  print('Expected XIRR: 0% (no gain, no loss)');
  print('');
  
  List<CashFlow> cashFlows1 = [
    CashFlow(date: DateTime(2024, 1, 1), amount: -10000),  // Buy
    CashFlow(date: DateTime(2025, 11, 9), amount: 10000),   // Current value
  ];
  
  final xirr1 = calculateXIRR(cashFlows1);
  print('');
  print('RESULT: XIRR = ${xirr1 != null ? (xirr1 * 100).toStringAsFixed(2) : 'null'}%');
  print('');
  print('===========================================');
  print('');
  
  print('=== Test Case 2: Small Profit ===');
  print('Invested: ₹10,000 on Jan 1, 2024');
  print('Current Value: ₹10,500 on Nov 9, 2025');
  print('Expected XIRR: ~2.5%');
  print('');
  
  List<CashFlow> cashFlows2 = [
    CashFlow(date: DateTime(2024, 1, 1), amount: -10000),  // Buy
    CashFlow(date: DateTime(2025, 11, 9), amount: 10500),   // Current value
  ];
  
  final xirr2 = calculateXIRR(cashFlows2);
  print('');
  print('RESULT: XIRR = ${xirr2 != null ? (xirr2 * 100).toStringAsFixed(2) : 'null'}%');
  print('');
  print('===========================================');
  print('');
  
  print('=== Test Case 3: Small Loss ===');
  print('Invested: ₹10,000 on Jan 1, 2024');
  print('Current Value: ₹9,500 on Nov 9, 2025');
  print('Expected XIRR: ~-2.7%');
  print('');
  
  List<CashFlow> cashFlows3 = [
    CashFlow(date: DateTime(2024, 1, 1), amount: -10000),  // Buy
    CashFlow(date: DateTime(2025, 11, 9), amount: 9500),    // Current value
  ];
  
  final xirr3 = calculateXIRR(cashFlows3);
  print('');
  print('RESULT: XIRR = ${xirr3 != null ? (xirr3 * 100).toStringAsFixed(2) : 'null'}%');
}
