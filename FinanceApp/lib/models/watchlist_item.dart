class WatchlistItem {
  final String id;
  final String symbol;
  final String name;
  final double? targetPrice;
  final String? notes;
  final DateTime addedAt;

  WatchlistItem({
    required this.id,
    required this.symbol,
    required this.name,
    this.targetPrice,
    this.notes,
    required this.addedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'symbol': symbol,
      'name': name,
      'targetPrice': targetPrice,
      'notes': notes,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  factory WatchlistItem.fromMap(Map<String, dynamic> map) {
    return WatchlistItem(
      id: map['id'] as String,
      symbol: map['symbol'] as String,
      name: map['name'] as String,
      targetPrice: map['targetPrice'] as double?,
      notes: map['notes'] as String?,
      addedAt: DateTime.parse(map['addedAt'] as String),
    );
  }

  WatchlistItem copyWith({
    String? id,
    String? symbol,
    String? name,
    double? targetPrice,
    String? notes,
    DateTime? addedAt,
  }) {
    return WatchlistItem(
      id: id ?? this.id,
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      targetPrice: targetPrice ?? this.targetPrice,
      notes: notes ?? this.notes,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}
