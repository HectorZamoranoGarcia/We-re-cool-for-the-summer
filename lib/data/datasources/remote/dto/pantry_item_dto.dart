import '../../../../domain/entities/pantry_item_entity.dart';

/// Data Transfer Object for mapping Pantry Items to and from Supabase.
/// Ensures strict mapping of Supabase types (UUIDs -> String, timestamptz -> DateTime via ISO8601).
class PantryItemDto {
  final int id;
  final String productBarcode;
  final double grams;
  final DateTime addedAt;
  final DateTime? expirationDate;
  final bool isConsumed;

  // Auditing & Cloud Sync fields
  final String? userId; // Supabase UUID
  final DateTime updatedAt; // timestamptz

  const PantryItemDto({
    required this.id,
    required this.productBarcode,
    required this.grams,
    required this.addedAt,
    this.expirationDate,
    required this.isConsumed,
    this.userId,
    required this.updatedAt,
  });

  /// Safely parses a Supabase JSON payload into the DTO.
  /// Enforces ISO8601 parsing for Supabase `timestamptz` compliance.
  factory PantryItemDto.fromJson(Map<String, dynamic> json) {
    return PantryItemDto(
      id: json['id'] as int,
      productBarcode: json['product_barcode'] as String,
      grams: (json['grams'] as num).toDouble(),
      addedAt: DateTime.parse(json['added_at'] as String),
      expirationDate: json['expiration_date'] != null
          ? DateTime.parse(json['expiration_date'] as String)
          : null,
      isConsumed: json['is_consumed'] as bool,
      userId: json['user_id'] as String?,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Serializes the DTO into a Map suitable for Supabase insertion/updating.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_barcode': productBarcode,
      'grams': grams,
      'added_at': addedAt.toIso8601String(),
      'expiration_date': expirationDate?.toIso8601String(),
      'is_consumed': isConsumed,
      'user_id': userId,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Converts this network DTO to the core Domain Entity.
  PantryItemEntity toEntity() {
    return PantryItemEntity(
      id: id,
      productBarcode: productBarcode,
      grams: grams,
      addedAt: addedAt,
      expirationDate: expirationDate,
      isConsumed: isConsumed,
    );
  }

  /// Creates a DTO from the core Domain Entity, requiring sync fields.
  factory PantryItemDto.fromEntity(
    PantryItemEntity entity, {
    String? userId,
    required DateTime updatedAt,
  }) {
    return PantryItemDto(
      id: entity.id,
      productBarcode: entity.productBarcode,
      grams: entity.grams,
      addedAt: entity.addedAt,
      expirationDate: entity.expirationDate,
      isConsumed: entity.isConsumed,
      userId: userId,
      updatedAt: updatedAt,
    );
  }
}
