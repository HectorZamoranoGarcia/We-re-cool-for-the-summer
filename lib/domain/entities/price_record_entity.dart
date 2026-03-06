class PriceRecordEntity {
  final int id;
  final String productBarcode;
  final int supermarketId;
  final double price;
  final String currency;
  final DateTime recordedAt;

  const PriceRecordEntity({
    required this.id,
    required this.productBarcode,
    required this.supermarketId,
    required this.price,
    required this.currency,
    required this.recordedAt,
  });

  PriceRecordEntity copyWith({
    int? id,
    String? productBarcode,
    int? supermarketId,
    double? price,
    String? currency,
    DateTime? recordedAt,
  }) {
    return PriceRecordEntity(
      id: id ?? this.id,
      productBarcode: productBarcode ?? this.productBarcode,
      supermarketId: supermarketId ?? this.supermarketId,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      recordedAt: recordedAt ?? this.recordedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PriceRecordEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          productBarcode == other.productBarcode &&
          supermarketId == other.supermarketId &&
          price == other.price &&
          currency == other.currency &&
          recordedAt == other.recordedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      productBarcode.hashCode ^
      supermarketId.hashCode ^
      price.hashCode ^
      currency.hashCode ^
      recordedAt.hashCode;
}
