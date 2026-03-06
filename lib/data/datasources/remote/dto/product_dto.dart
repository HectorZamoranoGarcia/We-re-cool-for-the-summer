import '../../../../domain/entities/product_entity.dart';

class ProductDto {
  final String? barcode;
  final String? name;
  final String? brand;
  final String? imageUrl;
  final double? caloriesPer100g;
  final double? proteinPer100g;
  final double? carbsPer100g;
  final double? fatsPer100g;

  const ProductDto({
    this.barcode,
    this.name,
    this.brand,
    this.imageUrl,
    this.caloriesPer100g,
    this.proteinPer100g,
    this.carbsPer100g,
    this.fatsPer100g,
  });

  factory ProductDto.fromJson(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>? ?? {};
    final nutriments = product['nutriments'] as Map<String, dynamic>? ?? {};

    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return ProductDto(
      barcode: json['code'] as String?,
      name: product['product_name'] as String?,
      brand: product['brands'] as String?,
      imageUrl: product['image_url'] as String?,
      caloriesPer100g: parseDouble(nutriments['energy-kcal_100g']),
      proteinPer100g: parseDouble(nutriments['proteins_100g']),
      carbsPer100g: parseDouble(nutriments['carbohydrates_100g']),
      fatsPer100g: parseDouble(nutriments['fat_100g']),
    );
  }

  ProductEntity toEntity() {
    return ProductEntity(
      barcode: barcode ?? 'UNKNOWN',
      name: name ?? 'Unknown Product',
      brand: brand,
      imageUrl: imageUrl,
      caloriesPer100g: caloriesPer100g,
      proteinPer100g: proteinPer100g,
      carbsPer100g: carbsPer100g,
      fatsPer100g: fatsPer100g,
    );
  }
}
