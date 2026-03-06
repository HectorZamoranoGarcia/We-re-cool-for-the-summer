class SupermarketEntity {
  final int id;
  final String name;
  final String countryCode;
  final String iconAssetPath;

  const SupermarketEntity({
    required this.id,
    required this.name,
    required this.countryCode,
    required this.iconAssetPath,
  });

  SupermarketEntity copyWith({
    int? id,
    String? name,
    String? countryCode,
    String? iconAssetPath,
  }) {
    return SupermarketEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      countryCode: countryCode ?? this.countryCode,
      iconAssetPath: iconAssetPath ?? this.iconAssetPath,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SupermarketEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          countryCode == other.countryCode &&
          iconAssetPath == other.iconAssetPath;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      countryCode.hashCode ^
      iconAssetPath.hashCode;
}
