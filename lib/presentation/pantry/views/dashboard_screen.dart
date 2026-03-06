import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../controllers/pantry_controller.dart';
import '../controllers/macro_aggregation_controller.dart';
import '../../core/widgets/premium_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final macroState = ref.watch(macroAggregationControllerProvider);
    final pantryState = ref.watch(pantryControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverAppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text('My Pantry', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28)),
              floating: true,
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: PremiumCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Today\'s Macros', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white70)),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          _AnimatedMacroBar(label: 'Protein', value: '110g', color: Colors.blueAccent, percentage: 0.6),
                          _AnimatedMacroBar(label: 'Carbs', value: '250g', color: Colors.greenAccent, percentage: 0.8),
                          _AnimatedMacroBar(label: 'Fats', value: '65g', color: Colors.orangeAccent, percentage: 0.4),
                        ],
                      ),
                    ],
                  ),
                ).animate().fade(duration: 500.ms).slideY(begin: 0.2),
              ),
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Text('Inventory', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ),
            ),
            // Inventory list driven by real Riverpod state.
            // Loading → spinner. Error → visible red message (never silent).
            // Data → animated list of PantryItemEntity rows.
            pantryState.when(
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, stack) => SliverFillRemaining(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      'ERROR: $err\n\n$stack',
                      style: const TextStyle(
                          color: Colors.red, fontSize: 13),
                    ),
                  ),
                ),
              ),
              data: (items) => SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: items.isEmpty
                    ? const SliverFillRemaining(
                        child: Center(
                          child: Text(
                            'Your pantry is empty.\nScan a product to get started.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white54),
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final item = items[index];
                            final isConsumed = item.isConsumed;
                            final expiresIn = item.expirationDate
                                ?.difference(DateTime.now())
                                .inDays;
                            final isExpiringSoon =
                                expiresIn != null && expiresIn < 3 && !isConsumed;

                            return Opacity(
                              opacity: isConsumed ? 0.4 : 1.0,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: PremiumCard(
                                  padding: const EdgeInsets.all(16),
                                  customBorder: isExpiringSoon
                                      ? Border.all(
                                          color: Colors.amberAccent.withOpacity(0.8),
                                          width: 2)
                                      : null,
                                  customShadows: isExpiringSoon
                                      ? [BoxShadow(
                                          color: Colors.amberAccent.withOpacity(0.2),
                                          blurRadius: 15,
                                          spreadRadius: 1)]
                                      : null,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.05),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(Icons.fastfood_rounded,
                                            color: Colors.white70),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.productBarcode,
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              isConsumed
                                                  ? 'Consumed'
                                                  : isExpiringSoon
                                                      ? 'Expires in $expiresIn days!'
                                                      : expiresIn != null
                                                          ? '$expiresIn days left'
                                                          : 'No expiry set',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: isExpiringSoon
                                                    ? Colors.amberAccent
                                                    : Colors.white54,
                                                fontWeight: isExpiringSoon
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ).animate().slideY(
                                  begin: 50,
                                  duration: 400.ms,
                                  curve: Curves.easeOutQuad).fadeIn(),
                            );
                          },
                          childCount: items.length,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _AnimatedMacroBar extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final double percentage;

  const _AnimatedMacroBar({required this.label, required this.value, required this.color, required this.percentage});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 8),
        Container(
          width: 90,
          height: 8,
          decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(4)),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percentage,
            child: Container(
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
            ),
          ).animate().scaleX(begin: 0, alignment: Alignment.centerLeft, duration: 800.ms, curve: Curves.easeOutExpo),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
