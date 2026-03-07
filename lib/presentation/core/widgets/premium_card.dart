import 'dart:ui';
import 'package:flutter/material.dart';

class PremiumCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double? width;
  final double? height;
  final List<BoxShadow>? customShadows;
  final BoxBorder? customBorder;

  const PremiumCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.width,
    this.height,
    this.customShadows,
    this.customBorder,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Dynamic colors based on theme to ensure high contrast
    final gradStart = isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.04);
    final gradEnd = isDark ? Colors.white.withOpacity(0.02) : Colors.black.withOpacity(0.01);
    final borderColor = isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05);
    final shadowColor = isDark ? Colors.black38 : Colors.black.withOpacity(0.05);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [gradStart, gradEnd],
            ),
            border: customBorder ?? Border.all(
              color: borderColor,
              width: 1.5,
            ),
            boxShadow: customShadows ?? [
              BoxShadow(
                color: shadowColor,
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
