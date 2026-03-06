class MacroSummaryModel {
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFats;

  const MacroSummaryModel({
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFats,
  });

  MacroSummaryModel copyWith({
    double? totalCalories,
    double? totalProtein,
    double? totalCarbs,
    double? totalFats,
  }) {
    return MacroSummaryModel(
      totalCalories: totalCalories ?? this.totalCalories,
      totalProtein: totalProtein ?? this.totalProtein,
      totalCarbs: totalCarbs ?? this.totalCarbs,
      totalFats: totalFats ?? this.totalFats,
    );
  }
}
