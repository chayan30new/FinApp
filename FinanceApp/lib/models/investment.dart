import 'transaction.dart';

class Investment {
  final String id;
  final String name;
  final String? description;
  final List<Transaction> transactions;
  final DateTime createdAt;
  final double? currentValue; // Manually set current market value

  Investment({
    required this.id,
    required this.name,
    this.description,
    required this.transactions,
    required this.createdAt,
    this.currentValue,
  });

  /// Total amount invested (all buy transactions)
  double get totalInvested {
    return transactions
        .where((t) => t.type == 'buy')
        .fold(0.0, (sum, t) => sum + t.amount.abs());
  }

  /// Total amount withdrawn (all sell transactions)
  double get totalWithdrawn {
    return transactions
        .where((t) => t.type == 'sell')
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Get the effective current value for calculations
  /// If currentValue is set, use it. Otherwise, use invested - withdrawn
  double get effectiveCurrentValue {
    if (currentValue != null && currentValue! > 0) {
      return currentValue!;
    }
    // Fallback: assume current value = invested - withdrawn
    return totalInvested - totalWithdrawn;
  }

  /// Net invested amount (invested - withdrawn)
  double get netInvested {
    return totalInvested - totalWithdrawn;
  }

  /// Profit or loss (current value - net invested)
  double get profitLoss {
    return effectiveCurrentValue - netInvested;
  }

  /// Total quantity held (buy quantities - sell quantities)
  double get totalQuantity {
    double buyQuantity = transactions
        .where((t) => t.type == 'buy' && t.quantity != null)
        .fold(0.0, (sum, t) => sum + t.quantity!);
    
    double sellQuantity = transactions
        .where((t) => t.type == 'sell' && t.quantity != null)
        .fold(0.0, (sum, t) => sum + t.quantity!);
    
    return buyQuantity - sellQuantity;
  }

  /// Average price per unit (if quantity data is available)
  double? get averagePricePerUnit {
    if (totalQuantity == 0 || netInvested == 0) return null;
    return netInvested / totalQuantity;
  }

  /// Current price per unit based on current value
  double? get currentPricePerUnit {
    if (totalQuantity == 0) return null;
    return effectiveCurrentValue / totalQuantity;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'currentValue': currentValue,
    };
  }

  factory Investment.fromMap(Map<String, dynamic> map, List<Transaction> transactions) {
    return Investment(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      transactions: transactions,
      createdAt: DateTime.parse(map['createdAt'] as String),
      currentValue: map['currentValue'] as double?,
    );
  }

  Investment copyWith({
    String? id,
    String? name,
    String? description,
    List<Transaction>? transactions,
    DateTime? createdAt,
    double? currentValue,
  }) {
    return Investment(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      transactions: transactions ?? this.transactions,
      createdAt: createdAt ?? this.createdAt,
      currentValue: currentValue ?? this.currentValue,
    );
  }
}
