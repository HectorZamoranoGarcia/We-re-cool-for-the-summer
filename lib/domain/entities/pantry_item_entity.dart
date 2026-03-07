class PantryItemEntity {
  final int id;
  final String productBarcode;
  final double grams;
  final DateTime addedAt;
  final DateTime? expirationDate;
  final bool isConsumed;

  const PantryItemEntity({
    required this.id,
    required this.productBarcode,
    required this.grams,
    required this.addedAt,
    this.expirationDate,
    required this.isConsumed,
  });

  PantryItemEntity copyWith({
    int? id,
    String? productBarcode,
    double? grams,
    DateTime? addedAt,
    DateTime? expirationDate,
    bool? isConsumed,
  }) {
    return PantryItemEntity(
      id: id ?? this.id,
      productBarcode: productBarcode ?? this.productBarcode,
      grams: grams ?? this.grams,
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
          grams == other.grams &&
          addedAt == other.addedAt &&
          expirationDate == other.expirationDate &&
          isConsumed == other.isConsumed;

  @override
  int get hashCode =>
      id.hashCode ^
      productBarcode.hashCode ^
      grams.hashCode ^
      addedAt.hashCode ^
      expirationDate.hashCode ^
      isConsumed.hashCode;
}
