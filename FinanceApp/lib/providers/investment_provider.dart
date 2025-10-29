import 'package:flutter/foundation.dart';
import '../models/investment.dart';
import '../models/transaction.dart';
import '../services/database_factory.dart';

class InvestmentProvider with ChangeNotifier {
  final dynamic _dbService = DatabaseServiceFactory.createDatabaseService();
  List<Investment> _investments = [];
  bool _isLoading = false;

  List<Investment> get investments => _investments;
  bool get isLoading => _isLoading;

  InvestmentProvider() {
    loadInvestments();
  }

  Future<void> loadInvestments() async {
    _isLoading = true;
    notifyListeners();

    try {
      _investments = await _dbService.getInvestments();
    } catch (e) {
      debugPrint('Error loading investments: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addInvestment(Investment investment) async {
    try {
      await _dbService.insertInvestment(investment);
      await loadInvestments();
    } catch (e) {
      debugPrint('Error adding investment: $e');
      rethrow;
    }
  }

  Future<void> updateInvestment(Investment investment) async {
    try {
      await _dbService.updateInvestment(investment);
      await loadInvestments();
    } catch (e) {
      debugPrint('Error updating investment: $e');
      rethrow;
    }
  }

  Future<void> updateInvestmentValue(String id, double currentValue, DateTime currentValueDate) async {
    try {
      final investment = getInvestmentById(id);
      if (investment == null) return;

      final updatedInvestment = investment.copyWith(
        currentValue: currentValue,
        currentValueDate: currentValueDate,
      );

      await _dbService.updateInvestment(updatedInvestment);
      await loadInvestments();
    } catch (e) {
      debugPrint('Error updating investment value: $e');
      rethrow;
    }
  }

  Future<void> deleteInvestment(String id) async {
    try {
      await _dbService.deleteInvestment(id);
      await loadInvestments();
    } catch (e) {
      debugPrint('Error deleting investment: $e');
      rethrow;
    }
  }

  Future<void> addTransaction(String investmentId, Transaction transaction) async {
    try {
      await _dbService.insertTransaction(investmentId, transaction);
      await loadInvestments();
    } catch (e) {
      debugPrint('Error adding transaction: $e');
      rethrow;
    }
  }

  Future<void> deleteTransaction(String transactionId) async {
    try {
      await _dbService.deleteTransaction(transactionId);
      await loadInvestments();
    } catch (e) {
      debugPrint('Error deleting transaction: $e');
      rethrow;
    }
  }

  Future<void> updateTransaction(Transaction transaction) async {
    try {
      await _dbService.updateTransaction(transaction);
      await loadInvestments();
    } catch (e) {
      debugPrint('Error updating transaction: $e');
      rethrow;
    }
  }

  Investment? getInvestmentById(String id) {
    try {
      return _investments.firstWhere((inv) => inv.id == id);
    } catch (e) {
      return null;
    }
  }
}
