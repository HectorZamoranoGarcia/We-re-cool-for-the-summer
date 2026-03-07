import '../../../../domain/entities/price_record_entity.dart';

/// Data Transfer Object for mapping Price Records to and from Supabase.
/// Ensures strict mapping of Supabase types (UUIDs -> String, timestamptz -> DateTime via ISO8601).
class PriceRecordDto {
  final int id;
  final String productBarcode;
  final String supermarketName;
  final double price;
  final String currency;
  final DateTime recordedAt;

  // Auditing & Cloud Sync fields
  final String? userId; // Supabase UUID
  final DateTime createdAt; // timestamptz

  const PriceRecordDto({
    required this.id,
    required this.productBarcode,
    required this.supermarketName,
    required this.price,
    required this.currency,
    required this.recordedAt,
    this.userId,
    required this.createdAt,
  });

  /// Safely parses a Supabase JSON payload into the DTO.
  /// Enforces ISO8601 parsing for Supabase `timestamptz` compliance.
  factory PriceRecordDto.fromJson(Map<String, dynamic> json) {
    return PriceRecordDto(
      id: json['id'] as int,
      productBarcode: json['product_barcode'] as String,
      supermarketName: json['supermarket_name'] as String,
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String,
      recordedAt: DateTime.parse(json['recorded_at'] as String),
      userId: json['user_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Serializes the DTO into a Map suitable for Supabase insertion/updating.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_barcode': productBarcode,
      'supermarket_name': supermarketName,
      'price': price,
      'currency': currency,
      'recorded_at': recordedAt.toIso8601String(),
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Converts this network DTO to the core Domain Entity.
  PriceRecordEntity toEntity() {
    return PriceRecordEntity(
      id: id,
      productBarcode: productBarcode,
      supermarketName: supermarketName,
      price: price,
      currency: currency,
      recordedAt: recordedAt,
    );
  }

  /// Creates a DTO from the core Domain Entity, requiring sync fields.
  factory PriceRecordDto.fromEntity(
    PriceRecordEntity entity, {
    String? userId,
    required DateTime createdAt,
  }) {
    return PriceRecordDto(
      id: entity.id,
      productBarcode: entity.productBarcode,
      supermarketName: entity.supermarketName,
      price: entity.price,
      currency: entity.currency,
      recordedAt: entity.recordedAt,
      userId: userId,
      createdAt: createdAt,
    );
  }
}
