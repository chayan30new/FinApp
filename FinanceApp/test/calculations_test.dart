import 'package:flutter_test/flutter_test.dart';
import 'package:financeapp/models/transaction.dart';
import 'package:financeapp/utils/calculations.dart';

void main() {
  group('XIRR Calculation Tests', () {
    test('Calculate XIRR for simple investment', () {
      final transactions = [
        Transaction(
          id: '1',
          date: DateTime(2024, 1, 1),
          amount: 10000,
          type: 'buy',
        ),
        Transaction(
          id: '2',
          date: DateTime(2024, 12, 31),
          amount: 11500,
          type: 'sell',
        ),
      ];

      final xirr = FinancialCalculations.calculateXIRR(transactions);
      
      expect(xirr, isNotNull);
      expect(xirr, greaterThan(0.10)); // Should be around 15%
      expect(xirr, lessThan(0.20));
    });

    test('Calculate XIRR for multiple investments', () {
      final transactions = [
        Transaction(
          id: '1',
          date: DateTime(2024, 1, 1),
          amount: 10000,
          type: 'buy',
        ),
        Transaction(
          id: '2',
          date: DateTime(2024, 6, 1),
          amount: 5000,
          type: 'buy',
        ),
      ];

      final xirr = FinancialCalculations.calculateXIRR(
        transactions,
        currentValue: 16500,
      );
      
      expect(xirr, isNotNull);
      expect(xirr, greaterThan(0));
    });

    test('XIRR returns null for single transaction without current value', () {
      final transactions = [
        Transaction(
          id: '1',
          date: DateTime(2024, 1, 1),
          amount: 10000,
          type: 'buy',
        ),
      ];

      final xirr = FinancialCalculations.calculateXIRR(transactions);
      
      expect(xirr, isNull);
    });

    test('XIRR handles negative returns', () {
      final transactions = [
        Transaction(
          id: '1',
          date: DateTime(2024, 1, 1),
          amount: 10000,
          type: 'buy',
        ),
        Transaction(
          id: '2',
          date: DateTime(2024, 12, 31),
          amount: 9000,
          type: 'sell',
        ),
      ];

      final xirr = FinancialCalculations.calculateXIRR(transactions);
      
      expect(xirr, isNotNull);
      expect(xirr, lessThan(0)); // Should be negative
    });
  });

  group('CAGR Calculation Tests', () {
    test('Calculate CAGR for 1 year investment', () {
      final cagr = FinancialCalculations.calculateCAGR(
        initialInvestment: 10000,
        currentValue: 11000,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2025, 1, 1),
      );

      expect(cagr, isNotNull);
      expect(cagr, closeTo(0.10, 0.01)); // Should be around 10%
    });

    test('Calculate CAGR for multi-year investment', () {
      final cagr = FinancialCalculations.calculateCAGR(
        initialInvestment: 10000,
        currentValue: 12100,
        startDate: DateTime(2023, 1, 1),
        endDate: DateTime(2025, 1, 1),
      );

      expect(cagr, isNotNull);
      expect(cagr, closeTo(0.10, 0.01)); // Should be around 10% CAGR
    });

    test('CAGR returns null for zero initial investment', () {
      final cagr = FinancialCalculations.calculateCAGR(
        initialInvestment: 0,
        currentValue: 1000,
        startDate: DateTime(2024, 1, 1),
      );

      expect(cagr, isNull);
    });

    test('CAGR handles negative returns', () {
      final cagr = FinancialCalculations.calculateCAGR(
        initialInvestment: 10000,
        currentValue: 9000,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2025, 1, 1),
      );

      expect(cagr, isNotNull);
      expect(cagr, lessThan(0)); // Should be negative
    });

    test('CAGR returns null for zero or negative time period', () {
      final cagr = FinancialCalculations.calculateCAGR(
        initialInvestment: 10000,
        currentValue: 11000,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 1), // Same date
      );

      expect(cagr, isNull);
    });
  });

  group('Absolute Return Tests', () {
    test('Calculate positive absolute return', () {
      final return_ = FinancialCalculations.calculateAbsoluteReturn(
        invested: 10000,
        currentValue: 12000,
      );

      expect(return_, closeTo(0.20, 0.01)); // 20% return
    });

    test('Calculate negative absolute return', () {
      final return_ = FinancialCalculations.calculateAbsoluteReturn(
        invested: 10000,
        currentValue: 9000,
      );

      expect(return_, closeTo(-0.10, 0.01)); // -10% return
    });

    test('Zero return when invested equals current value', () {
      final return_ = FinancialCalculations.calculateAbsoluteReturn(
        invested: 10000,
        currentValue: 10000,
      );

      expect(return_, equals(0));
    });

    test('Handle zero invested amount', () {
      final return_ = FinancialCalculations.calculateAbsoluteReturn(
        invested: 0,
        currentValue: 1000,
      );

      expect(return_, equals(0));
    });
  });

  group('Profit/Loss Tests', () {
    test('Calculate profit', () {
      final profit = FinancialCalculations.calculateProfitLoss(
        invested: 10000,
        currentValue: 12000,
      );

      expect(profit, equals(2000));
    });

    test('Calculate loss', () {
      final loss = FinancialCalculations.calculateProfitLoss(
        invested: 10000,
        currentValue: 9000,
      );

      expect(loss, equals(-1000));
    });
  });

  group('Formatting Tests', () {
    test('Format percentage correctly', () {
      expect(
        FinancialCalculations.formatPercentage(0.1234),
        equals('12.34%'),
      );
      expect(
        FinancialCalculations.formatPercentage(-0.05),
        equals('-5.00%'),
      );
      expect(
        FinancialCalculations.formatPercentage(null),
        equals('N/A'),
      );
    });

    test('Format currency correctly', () {
      expect(
        FinancialCalculations.formatCurrency(1234.56),
        equals('₹1234.56'),
      );
      expect(
        FinancialCalculations.formatCurrency(1000),
        equals('₹1000.00'),
      );
    });

    test('Format currency with custom symbol', () {
      expect(
        FinancialCalculations.formatCurrency(100, symbol: '\$'),
        equals('\$100.00'),
      );
    });
  });

  group('Real-world Scenarios', () {
    test('Mutual Fund SIP scenario', () {
      // Monthly SIP of 5000 for 6 months
      final transactions = [
        Transaction(
          id: '1',
          date: DateTime(2024, 1, 1),
          amount: 5000,
          type: 'buy',
        ),
        Transaction(
          id: '2',
          date: DateTime(2024, 2, 1),
          amount: 5000,
          type: 'buy',
        ),
        Transaction(
          id: '3',
          date: DateTime(2024, 3, 1),
          amount: 5000,
          type: 'buy',
        ),
        Transaction(
          id: '4',
          date: DateTime(2024, 4, 1),
          amount: 5000,
          type: 'buy',
        ),
        Transaction(
          id: '5',
          date: DateTime(2024, 5, 1),
          amount: 5000,
          type: 'buy',
        ),
        Transaction(
          id: '6',
          date: DateTime(2024, 6, 1),
          amount: 5000,
          type: 'buy',
        ),
      ];

      final xirr = FinancialCalculations.calculateXIRR(
        transactions,
        currentValue: 32000, // 30000 invested, now worth 32000
      );

      expect(xirr, isNotNull);
      expect(xirr, greaterThan(0)); // Should show positive returns
    });

    test('Lump sum investment with partial withdrawal', () {
      final transactions = [
        Transaction(
          id: '1',
          date: DateTime(2024, 1, 1),
          amount: 100000,
          type: 'buy',
        ),
        Transaction(
          id: '2',
          date: DateTime(2024, 6, 1),
          amount: 20000, // Withdrew 20000
          type: 'sell',
        ),
      ];

      final xirr = FinancialCalculations.calculateXIRR(
        transactions,
        currentValue: 90000, // Remaining value
      );

      expect(xirr, isNotNull);
    });
  });
}
