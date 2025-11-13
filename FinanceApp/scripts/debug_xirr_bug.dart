import 'dart:math';

class CashFlow {
  final DateTime date;
  final double amount;
  
  CashFlow({required this.date, required this.amount});
}

double calculateNPV(List<CashFlow> cashFlows, double rate) {
  DateTime startDate = cashFlows.first.date;
  double npv = 0.0;
  
  for (var cashFlow in cashFlows) {
    double years = cashFlow.date.difference(startDate).inDays / 365.25;
    npv += cashFlow.amount / pow(1 + rate, years);
  }
  
  return npv;
}

double calculateDerivative(List<CashFlow> cashFlows, double rate) {
  DateTime startDate = cashFlows.first.date;
  double derivative = 0.0;
  
  for (var cashFlow in cashFlows) {
    double years = cashFlow.date.difference(startDate).inDays / 365.25;
    derivative -= years * cashFlow.amount / pow(1 + rate, years + 1);
  }
  
  return derivative;
}

double? calculateXIRR(List<CashFlow> cashFlows) {
  if (cashFlows.length < 2) return null;
  
  double guess = 0.1; // Initial guess: 10%
  double tolerance = 0.0001;
  int maxIterations = 100;
  
  for (int i = 0; i < maxIterations; i++) {
    double npv = calculateNPV(cashFlows, guess);
    double derivative = calculateDerivative(cashFlows, guess);
    
    if (derivative.abs() < 0.000001) break;
    
    double newGuess = guess - npv / derivative;
    
    if ((newGuess - guess).abs() < tolerance) {
      return newGuess;
    }
    
    guess = newGuess;
    
    if (guess < -0.99) guess = -0.99;
    if (guess > 10) guess = 10;
  }
  
  return guess;
}

void main() {
  print('=== PROBLEM SCENARIO: Why XIRR shows 10% when Profit/Loss is 0 ===\n');
  
  print('Scenario: Mutual Fund Investment');
  print('- Initial investment: ₹10,000 on Jan 1, 2024');
  print('- NAV at purchase: ₹100');
  print('- Units bought: 100 units');
  print('');
  print('- Current NAV: ₹110 (fetched from AMFI API)');
  print('- Current Value: 100 units × ₹110 = ₹11,000');
  print('- Profit/Loss: ₹11,000 - ₹10,000 = ₹1,000 (should be +10%)');
  print('');
  
  List<CashFlow> correctScenario = [
    CashFlow(date: DateTime(2024, 1, 1), amount: -10000),  // Invested
    CashFlow(date: DateTime(2025, 11, 9), amount: 11000),   // Current value with NAV growth
  ];
  
  final xirrCorrect = calculateXIRR(correctScenario);
  print('XIRR: ${xirrCorrect != null ? (xirrCorrect * 100).toStringAsFixed(2) : 'null'}%');
  print('✓ This is CORRECT - NAV grew from ₹100 to ₹110 (~10% annualized)');
  print('');
  print('===================================\n');
  
  print('=== BUG SCENARIO: What if currentValue is wrong? ===\n');
  print('If currentValue is manually set to ₹10,000 instead of calculating from NAV:');
  print('- Net Invested: ₹10,000');
  print('- Current Value (manual): ₹10,000');
  print('- Profit/Loss: ₹0 (looks like no gain)');
  print('');
  print('But transactions still contain the buy at ₹10,000');
  print('And "current value" cash flow uses ₹10,000 at TODAY\'s date');
  print('');
  
  List<CashFlow> bugScenario = [
    CashFlow(date: DateTime(2024, 1, 1), amount: -10000),  // Invested
    CashFlow(date: DateTime(2025, 11, 9), amount: 10000),   // Current value = invested
  ];
  
  final xirrBug = calculateXIRR(bugScenario);
  print('XIRR: ${xirrBug != null ? (xirrBug * 100).toStringAsFixed(2) : 'null'}%');
  print('✓ This is also CORRECT - no gain, no loss, XIRR ~0%');
  print('');
  print('===================================\n');
  
  print('=== THE REAL BUG: Multiple transactions with wrong current value ===\n');
  print('Scenario:');
  print('- Buy 1: ₹5,000 on Jan 1, 2024 (50 units @ ₹100/unit)');
  print('- Buy 2: ₹5,000 on Jun 1, 2024 (50 units @ ₹100/unit)');
  print('- Total invested: ₹10,000');
  print('- Total units: 100 units');
  print('');
  print('If NAV is now ₹100 (no change):');
  print('- Actual current value: 100 units × ₹100 = ₹10,000');
  print('- Profit/Loss: ₹0');
  print('');
  print('But if we pass TRANSACTIONS to XIRR + wrong currentValue...');
  print('');
  
  List<CashFlow> multiTransactionBug = [
    CashFlow(date: DateTime(2024, 1, 1), amount: -5000),   // Buy 1
    CashFlow(date: DateTime(2024, 6, 1), amount: -5000),   // Buy 2
    CashFlow(date: DateTime(2025, 11, 9), amount: 10000),  // Current value
  ];
  
  final xirrMulti = calculateXIRR(multiTransactionBug);
  print('XIRR with correct current value: ${xirrMulti != null ? (xirrMulti * 100).toStringAsFixed(2) : 'null'}%');
  print('✓ XIRR ~0% - Correct!');
  print('');
  
  // Now with WRONG current value (using old NAV or cached value)
  List<CashFlow> multiTransactionWrong = [
    CashFlow(date: DateTime(2024, 1, 1), amount: -5000),   // Buy 1
    CashFlow(date: DateTime(2024, 6, 1), amount: -5000),   // Buy 2
    CashFlow(date: DateTime(2025, 11, 9), amount: 11000),  // WRONG! Using old NAV ₹110
  ];
  
  final xirrWrong = calculateXIRR(multiTransactionWrong);
  print('XIRR with WRONG current value (₹11,000): ${xirrWrong != null ? (xirrWrong * 100).toStringAsFixed(2) : 'null'}%');
  print('✗ Shows ~5% even though profit/loss calculation might show ₹0');
  print('');
  print('===================================\n');
  
  print('ROOT CAUSE ANALYSIS:');
  print('');
  print('1. Profit/Loss = effectiveCurrentValue - netInvested');
  print('   - Uses: current value FROM database or NAV API');
  print('');
  print('2. XIRR = calculateXIRR(transactions, currentValue: investment.effectiveCurrentValue)');
  print('   - Uses: SAME current value');
  print('');
  print('3. If profit/loss is 0 but XIRR is 10%:');
  print('   → effectiveCurrentValue MUST equal netInvested (that\'s why profit/loss = 0)');
  print('   → But XIRR calculation shows 10% return');
  print('   → This means: The Newton-Raphson algorithm is converging to 10%');
  print('   → Question: Why would it converge to 10% when final value = invested?');
  print('');
  print('4. Possible causes:');
  print('   a) Initial guess is 10%, and iteration stopped early (derivative too small)');
  print('   b) Precision issues in Newton-Raphson causing wrong convergence');
  print('   c) Bug in the NPV or derivative calculation');
  print('   d) Transaction amounts are wrong (negative/positive flipped)');
  print('');
  print('RECOMMENDATION:');
  print('- Add debug logging in calculateXIRR to see NPV and iterations');
  print('- Check if derivative is becoming too small too early');
  print('- Verify transaction amounts are correct signs (buy = negative, sell = positive)');
  print('- Check if currentValue being passed is actually equal to netInvested');
}
