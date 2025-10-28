import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/investment.dart';
import '../models/transaction.dart' as model;

/// Web-compatible database service using SharedPreferences
class DatabaseServiceWeb {
  static const String _investmentsKey = 'investments';
  static const String _transactionsKey = 'transactions';

  Future<SharedPreferences> get _prefs async {
    return await SharedPreferences.getInstance();
  }

  // Investment CRUD operations
  Future<void> insertInvestment(Investment investment) async {
    final prefs = await _prefs;
    final investments = await getInvestments();
    
    // Remove existing investment with same ID if any
    investments.removeWhere((inv) => inv.id == investment.id);
    investments.add(investment);
    
    // Save to SharedPreferences
    final investmentMaps = investments.map((inv) => inv.toMap()).toList();
    await prefs.setString(_investmentsKey, jsonEncode(investmentMaps));
  }

  Future<List<Investment>> getInvestments() async {
    final prefs = await _prefs;
    final jsonString = prefs.getString(_investmentsKey);
    
    if (jsonString == null) return [];
    
    final List<dynamic> jsonList = jsonDecode(jsonString);
    List<Investment> investments = [];
    
    for (var investmentMap in jsonList) {
      final transactions = await getTransactionsForInvestment(
        investmentMap['id'] as String,
      );
      investments.add(Investment.fromMap(investmentMap, transactions));
    }
    
    return investments;
  }

  Future<Investment?> getInvestment(String id) async {
    final investments = await getInvestments();
    try {
      return investments.firstWhere((inv) => inv.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateInvestment(Investment investment) async {
    await insertInvestment(investment);
  }

  Future<void> deleteInvestment(String id) async {
    final prefs = await _prefs;
    final investments = await getInvestments();
    
    investments.removeWhere((inv) => inv.id == id);
    
    // Delete associated transactions
    await _deleteTransactionsForInvestment(id);
    
    // Save updated list
    final investmentMaps = investments.map((inv) => inv.toMap()).toList();
    await prefs.setString(_investmentsKey, jsonEncode(investmentMaps));
  }

  // Transaction CRUD operations
  Future<void> insertTransaction(String investmentId, model.Transaction transaction) async {
    final prefs = await _prefs;
    final allTransactions = await _getAllTransactions();
    
    // Remove existing transaction with same ID if any
    allTransactions.removeWhere((t) => t['id'] == transaction.id);
    
    // Add new transaction
    final transactionMap = transaction.toMap();
    transactionMap['investmentId'] = investmentId;
    allTransactions.add(transactionMap);
    
    // Save to SharedPreferences
    await prefs.setString(_transactionsKey, jsonEncode(allTransactions));
  }

  Future<List<model.Transaction>> getTransactionsForInvestment(String investmentId) async {
    final allTransactions = await _getAllTransactions();
    
    final filteredTransactions = allTransactions
        .where((t) => t['investmentId'] == investmentId)
        .toList();
    
    // Sort by date
    filteredTransactions.sort((a, b) {
      final dateA = DateTime.parse(a['date'] as String);
      final dateB = DateTime.parse(b['date'] as String);
      return dateA.compareTo(dateB);
    });
    
    return filteredTransactions.map((t) => model.Transaction.fromMap(t)).toList();
  }

  Future<void> deleteTransaction(String transactionId) async {
    final prefs = await _prefs;
    final allTransactions = await _getAllTransactions();
    
    allTransactions.removeWhere((t) => t['id'] == transactionId);
    
    await prefs.setString(_transactionsKey, jsonEncode(allTransactions));
  }

  Future<void> updateTransaction(model.Transaction transaction) async {
    final prefs = await _prefs;
    final allTransactions = await _getAllTransactions();
    
    // Find the transaction to update and preserve its investmentId
    final existingIndex = allTransactions.indexWhere((t) => t['id'] == transaction.id);
    if (existingIndex == -1) return;
    
    final investmentId = allTransactions[existingIndex]['investmentId'];
    
    // Update the transaction
    final transactionMap = transaction.toMap();
    transactionMap['investmentId'] = investmentId;
    allTransactions[existingIndex] = transactionMap;
    
    await prefs.setString(_transactionsKey, jsonEncode(allTransactions));
  }

  // Helper methods
  Future<List<Map<String, dynamic>>> _getAllTransactions() async {
    final prefs = await _prefs;
    final jsonString = prefs.getString(_transactionsKey);
    
    if (jsonString == null) return [];
    
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((e) => e as Map<String, dynamic>).toList();
  }

  Future<void> _deleteTransactionsForInvestment(String investmentId) async {
    final prefs = await _prefs;
    final allTransactions = await _getAllTransactions();
    
    allTransactions.removeWhere((t) => t['investmentId'] == investmentId);
    
    await prefs.setString(_transactionsKey, jsonEncode(allTransactions));
  }

  Future<void> close() async {
    // No-op for SharedPreferences
  }
}
