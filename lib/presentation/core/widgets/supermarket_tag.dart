import 'package:flutter/material.dart';

/// Corporate brand identity for each supported supermarket chain.
class SupermarketTheme {
  const SupermarketTheme._();

  static const _themes = <String, ({Color bg, Color text})>{
    'mercadona': (bg: Color(0xFF008940), text: Colors.white),
    'lidl':      (bg: Color(0xFF0050AA), text: Color(0xFFFFE600)),
    'carrefour': (bg: Color(0xFFE80A23), text: Colors.white),
    'aldi':      (bg: Color(0xFF00A2E8), text: Colors.white),
    'consum':    (bg: Color(0xFFD10012), text: Colors.white),
    'spar':      (bg: Color(0xFF009F3D), text: Colors.white),
    'auchan':    (bg: Color(0xFFE8001C), text: Colors.white),
    'other':     (bg: Color(0xFF607D8B), text: Colors.white),
  };

  static ({Color bg, Color text}) of(String name) {
    return _themes[name.toLowerCase()] ??
        _themes['other']!;
  }
}

/// Compact pill badge showing the supermarket's corporate brand colours.
class SupermarketTag extends StatelessWidget {
  final String name;
  final bool isSelected;
  final VoidCallback? onTap;

  const SupermarketTag({
    super.key,
    required this.name,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SupermarketTheme.of(name);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? theme.bg : theme.bg.withOpacity(0.12),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? theme.bg : theme.bg.withOpacity(0.4),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: theme.bg.withOpacity(0.35), blurRadius: 8, spreadRadius: 1)]
              : null,
        ),
        child: Text(
          // Display the real supermarket brand name with proper capitalisation
          '${name[0].toUpperCase()}${name.substring(1)}',
          style: TextStyle(
            color: isSelected ? theme.text : theme.bg,
            fontWeight: FontWeight.w700,
            fontSize: 13,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}

/// Horizontally scrollable row of [SupermarketTag] chips;
/// calls [onSupermarketSelected] with the chosen supermarket name.
class SupermarketSelector extends StatefulWidget {
  final String? selected;
  final void Function(String name) onSupermarketSelected;

  const SupermarketSelector({
    super.key,
    this.selected,
    required this.onSupermarketSelected,
  });

  @override
  State<SupermarketSelector> createState() => _SupermarketSelectorState();
}

class _SupermarketSelectorState extends State<SupermarketSelector> {
  static const _supermarkets = [
    'mercadona', 'lidl', 'carrefour', 'aldi', 'consum', 'spar', 'auchan', 'other',
  ];

  late String? _current;

  @override
  void initState() {
    super.initState();
    _current = widget.selected;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _supermarkets.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final name = _supermarkets[i];
          return SupermarketTag(
            name: name,
            isSelected: _current == name,
            onTap: () {
              setState(() => _current = name);
              widget.onSupermarketSelected(name);
            },
          );
        },
      ),
    );
  }
}
