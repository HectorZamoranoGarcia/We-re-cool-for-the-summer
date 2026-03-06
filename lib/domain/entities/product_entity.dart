class ProductEntity {
  final String barcode;
  final String name;
  final String? brand;
  final String? imageUrl;
  final double? caloriesPer100g;
  final double? proteinPer100g;
  final double? carbsPer100g;
  final double? fatsPer100g;

  const ProductEntity({
    required this.barcode,
    required this.name,
    this.brand,
    this.imageUrl,
    this.caloriesPer100g,
    this.proteinPer100g,
    this.carbsPer100g,
    this.fatsPer100g,
  });

  ProductEntity copyWith({
    String? barcode,
    String? name,
    String? brand,
    String? imageUrl,
    double? caloriesPer100g,
    double? proteinPer100g,
    double? carbsPer100g,
    double? fatsPer100g,
  }) {
    return ProductEntity(
      barcode: barcode ?? this.barcode,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      imageUrl: imageUrl ?? this.imageUrl,
      caloriesPer100g: caloriesPer100g ?? this.caloriesPer100g,
      proteinPer100g: proteinPer100g ?? this.proteinPer100g,
      carbsPer100g: carbsPer100g ?? this.carbsPer100g,
      fatsPer100g: fatsPer100g ?? this.fatsPer100g,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductEntity &&
          runtimeType == other.runtimeType &&
          barcode == other.barcode &&
          name == other.name &&
          brand == other.brand &&
          imageUrl == other.imageUrl &&
          caloriesPer100g == other.caloriesPer100g &&
          proteinPer100g == other.proteinPer100g &&
          carbsPer100g == other.carbsPer100g &&
          fatsPer100g == other.fatsPer100g;

  @override
  int get hashCode =>
      barcode.hashCode ^
      name.hashCode ^
      brand.hashCode ^
      imageUrl.hashCode ^
      caloriesPer100g.hashCode ^
      proteinPer100g.hashCode ^
      carbsPer100g.hashCode ^
      fatsPer100g.hashCode;
}
