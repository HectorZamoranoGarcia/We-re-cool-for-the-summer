import 'package:flutter/material.dart';

class SupermarketBadge extends StatelessWidget {
  final String supermarketName;

  const SupermarketBadge({
    super.key,
    required this.supermarketName,
  });

  @override
  Widget build(BuildContext context) {
    final name = supermarketName.toLowerCase();
    Color brandColor = Theme.of(context).colorScheme.primary;
    Color textColor = Colors.white;

    if (name.contains('aldi')) {
      brandColor = const Color(0xFF00A2E8); // Cyan/Blue
    } else if (name.contains('lidl')) {
      brandColor = const Color(0xFF0050AA); // Lidl Blue
      textColor = const Color(0xFFFFE600); // Yellow text
    } else if (name.contains('carrefour')) {
      brandColor = const Color(0xFFE80A23); // Carrefour Red
    } else if (name.contains('mercadona')) {
      brandColor = const Color(0xFF008940); // Green
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: brandColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: brandColor.withOpacity(0.5), width: 1.5),
      ),
      child: Text(
        supermarketName,
        style: TextStyle(
          color: textColor != Colors.white && Theme.of(context).brightness == Brightness.dark
              ? textColor
              : brandColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
