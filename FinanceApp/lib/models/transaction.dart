class Transaction {
  final String id;
  final DateTime date;
  final double amount; // Negative for investment, positive for withdrawal/return
  final String type; // 'buy' or 'sell'
  final String? notes;
  final double? quantity; // Number of units/shares bought or sold

  Transaction({
    required this.id,
    required this.date,
    required this.amount,
    required this.type,
    this.notes,
    this.quantity,
  });

  // Calculate price per unit if quantity is available
  double? get pricePerUnit {
    if (quantity == null || quantity == 0) return null;
    return amount.abs() / quantity!;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'amount': amount,
      'type': type,
      'notes': notes,
      'quantity': quantity,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as String,
      date: DateTime.parse(map['date'] as String),
      amount: map['amount'] as double,
      type: map['type'] as String,
      notes: map['notes'] as String?,
      quantity: map['quantity'] as double?,
    );
  }

  Transaction copyWith({
    String? id,
    DateTime? date,
    double? amount,
    String? type,
    String? notes,
    double? quantity,
  }) {
    return Transaction(
      id: id ?? this.id,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      notes: notes ?? this.notes,
      quantity: quantity ?? this.quantity,
    );
  }
}
