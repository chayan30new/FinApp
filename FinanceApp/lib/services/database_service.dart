import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/investment.dart';
import '../models/transaction.dart' as model;

class DatabaseService {
  static Database? _database;
  static const String _dbName = 'investment_tracker.db';
  static const int _dbVersion = 2; // Incremented for quantity field

  // Tables
  static const String _investmentsTable = 'investments';
  static const String _transactionsTable = 'transactions';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _dbName);
    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create investments table
    await db.execute('''
      CREATE TABLE $_investmentsTable (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        createdAt TEXT NOT NULL,
        currentValue REAL
      )
    ''');

    // Create transactions table
    await db.execute('''
      CREATE TABLE $_transactionsTable (
        id TEXT PRIMARY KEY,
        investmentId TEXT NOT NULL,
        date TEXT NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        notes TEXT,
        quantity REAL,
        FOREIGN KEY (investmentId) REFERENCES $_investmentsTable (id)
          ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add quantity column to transactions table
      await db.execute('''
        ALTER TABLE $_transactionsTable ADD COLUMN quantity REAL
      ''');
    }
  }

  // Investment CRUD operations
  Future<void> insertInvestment(Investment investment) async {
    final db = await database;
    await db.insert(
      _investmentsTable,
      investment.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Investment>> getInvestments() async {
    final db = await database;
    final List<Map<String, dynamic>> investmentMaps =
        await db.query(_investmentsTable);

    List<Investment> investments = [];
    for (var investmentMap in investmentMaps) {
      final transactions = await getTransactionsForInvestment(
        investmentMap['id'] as String,
      );
      investments.add(Investment.fromMap(investmentMap, transactions));
    }

    return investments;
  }

  Future<Investment?> getInvestment(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _investmentsTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;

    final transactions = await getTransactionsForInvestment(id);
    return Investment.fromMap(maps.first, transactions);
  }

  Future<void> updateInvestment(Investment investment) async {
    final db = await database;
    await db.update(
      _investmentsTable,
      investment.toMap(),
      where: 'id = ?',
      whereArgs: [investment.id],
    );
  }

  Future<void> deleteInvestment(String id) async {
    final db = await database;
    await db.delete(
      _transactionsTable,
      where: 'investmentId = ?',
      whereArgs: [id],
    );
    await db.delete(
      _investmentsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Transaction CRUD operations
  Future<void> insertTransaction(String investmentId, model.Transaction transaction) async {
    final db = await database;
    final transactionMap = transaction.toMap();
    transactionMap['investmentId'] = investmentId;
    await db.insert(
      _transactionsTable,
      transactionMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<model.Transaction>> getTransactionsForInvestment(String investmentId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _transactionsTable,
      where: 'investmentId = ?',
      whereArgs: [investmentId],
      orderBy: 'date ASC',
    );

    return List.generate(maps.length, (i) {
      return model.Transaction.fromMap(maps[i]);
    });
  }

  Future<void> deleteTransaction(String transactionId) async {
    final db = await database;
    await db.delete(
      _transactionsTable,
      where: 'id = ?',
      whereArgs: [transactionId],
    );
  }

  Future<void> updateTransaction(model.Transaction transaction) async {
    final db = await database;
    // Get the investment ID for this transaction first
    final List<Map<String, dynamic>> maps = await db.query(
      _transactionsTable,
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
    
    if (maps.isEmpty) return;
    
    final transactionMap = transaction.toMap();
    transactionMap['investmentId'] = maps.first['investmentId'];
    
    await db.update(
      _transactionsTable,
      transactionMap,
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
