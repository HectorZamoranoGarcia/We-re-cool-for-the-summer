class PantryItemEntity {
  final int id;
  final String productBarcode;
  final int quantity;
  final DateTime addedAt;
  final DateTime? expirationDate;
  final bool isConsumed;

  const PantryItemEntity({
    required this.id,
    required this.productBarcode,
    required this.quantity,
    required this.addedAt,
    this.expirationDate,
    required this.isConsumed,
  });

  PantryItemEntity copyWith({
    int? id,
    String? productBarcode,
    int? quantity,
    DateTime? addedAt,
    DateTime? expirationDate,
    bool? isConsumed,
  }) {
    return PantryItemEntity(
      id: id ?? this.id,
      productBarcode: productBarcode ?? this.productBarcode,
      quantity: quantity ?? this.quantity,
      addedAt: addedAt ?? this.addedAt,
      expirationDate: expirationDate ?? this.expirationDate,
      isConsumed: isConsumed ?? this.isConsumed,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PantryItemEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          productBarcode == other.productBarcode &&
          quantity == other.quantity &&
          addedAt == other.addedAt &&
          expirationDate == other.expirationDate &&
          isConsumed == other.isConsumed;

  @override
  int get hashCode =>
      id.hashCode ^
      productBarcode.hashCode ^
      quantity.hashCode ^
      addedAt.hashCode ^
      expirationDate.hashCode ^
      isConsumed.hashCode;
}
