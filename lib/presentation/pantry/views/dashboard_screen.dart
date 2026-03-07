import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/helpers/expiration_helper.dart';
import '../../../core/di/auth_providers.dart';
import '../../../core/di/repository_providers.dart';
import '../../settings/controllers/settings_controller.dart';
import '../../core/widgets/premium_card.dart';
import '../models/macro_summary_model.dart';
import '../controllers/macro_aggregation_controller.dart';
import '../controllers/dashboard_controller.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsControllerProvider);
    final currentUser = ref.watch(currentUserProvider);

    // Use the custom username if set, otherwise fallback to the Google email or 'User'.
    // This entirely removes the "Gourmet" mock state.
    final customName = settingsState.valueOrNull?.username;
    final displayName = (customName != null && customName.isNotEmpty)
        ? customName
        : (currentUser?.email ?? 'User');

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryTextColor = isDark ? Colors.white70 : Colors.black87;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(
                'Hi, $displayName',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),
              floating: true,
            ),

            // ── 1. Nutritional Summary ─────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: PremiumCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nutritional Summary',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: secondaryTextColor),
                      ),
                      const SizedBox(height: 20),
                      Consumer(
                        builder: (context, ref, _) {
                          final statsAsync = ref.watch(pantryStatsProvider);
                          return statsAsync.when(
                            loading: () => const Center(
                                child: CircularProgressIndicator()),
                            error: (e, _) =>
                                Text('Error: $e', style: const TextStyle(color: Colors.red)),
                            data: (stats) => Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _MacroCell(
                                    label: 'Calories',
                                    value: '${stats.totalCalories.toInt()} kcal',
                                    color: Colors.deepPurpleAccent),
                                _MacroCell(
                                    label: 'Protein',
                                    value: '${stats.totalProtein.toInt()}g',
                                    color: Colors.blueAccent),
                                _MacroCell(
                                    label: 'Carbs',
                                    value: '${stats.totalCarbs.toInt()}g',
                                    color: Colors.greenAccent),
                                _MacroCell(
                                    label: 'Fats',
                                    value: '${stats.totalFats.toInt()}g',
                                    color: Colors.orangeAccent),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ).animate().fade(duration: 500.ms).slideY(begin: 0.1),
              ),
            ),

            // ── 2. Urgent Items ──────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Consumer(
                builder: (context, ref, _) {
                  final urgent = ref.watch(urgentItemsProvider);
                  if (urgent.isEmpty) return const SizedBox.shrink();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                        child: Text(
                          'Urgent Items',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: secondaryTextColor),
                        ),
                      ),
                      SizedBox(
                        height: 150,
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: urgent.length,
                          itemBuilder: (context, index) {
                            final item = urgent[index];
                            final eval = ExpirationHelper.evaluate(item.expirationDate);
                            final accentColor = ExpirationHelper.colorFor(eval.status);

                            return Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: SizedBox(
                                width: 140,
                                child: PremiumCard(
                                  padding: const EdgeInsets.all(12),
                                  customBorder: Border.all(
                                      color: accentColor.withOpacity(0.8),
                                      width: 2),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Icon(Icons.warning_amber_rounded,
                                              color: accentColor, size: 20),
                                          Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: accentColor.withOpacity(0.2),
                                            ),
                                            child: Icon(Icons.circle,
                                                size: 10, color: accentColor),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      Consumer(
                                        builder: (ctx, prodRef, _) {
                                          final pAsync = prodRef.watch(
                                            productDetailsProvider(item.productBarcode),
                                          );
                                          return pAsync.when(
                                            data: (p) => Text(
                                              p.name,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: secondaryTextColor,
                                              ),
                                            ),
                                            loading: () => const Text('Loading...'),
                                            error: (_, __) =>
                                                const Text('Unknown Product'),
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        ExpirationHelper.labelFor(
                                            eval.status, eval.daysUntilExpiration),
                                        style: TextStyle(
                                            color: accentColor,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w900),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ).animate().fade(delay: (50 * index).ms).slideX(begin: 0.1);
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // ── 3. Inventory List ────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 12),
                child: Text(
                  'Inventory List',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: secondaryTextColor),
                ),
              ),
            ),

            Consumer(
              builder: (context, ref, _) {
                final grouped = ref.watch(groupedInventoryProvider);

                if (grouped.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'Your pantry is empty.\nScan a product to get started.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: secondaryTextColor.withOpacity(0.5)),
                      ),
                    ),
                  );
                }

                final barcodes = grouped.keys.toList();

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final barcode = barcodes[index];
                        final totalGrams = grouped[barcode]!;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: PremiumCard(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // Thumbnail
                                Consumer(
                                  builder: (ctx, prodRef, _) {
                                    final pAsync = prodRef.watch(
                                      productDetailsProvider(barcode),
                                    );
                                    final imageUrl = pAsync.valueOrNull?.imageUrl;

                                    return Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: imageUrl != null && imageUrl.isNotEmpty
                                          ? ClipRRect(
                                              borderRadius: BorderRadius.circular(12),
                                              child: Image.network(imageUrl,
                                                  fit: BoxFit.cover),
                                            )
                                          : Icon(Icons.fastfood_rounded,
                                              color: secondaryTextColor),
                                    );
                                  },
                                ),
                                const SizedBox(width: 16),
                                // Text details
                                Expanded(
                                  child: Consumer(
                                    builder: (ctx, prodRef, _) {
                                      final pAsync = prodRef.watch(
                                        productDetailsProvider(barcode),
                                      );
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            pAsync.valueOrNull?.name ?? barcode,
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${totalGrams.toStringAsFixed(0)}g total',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: const Color(0xFF00E676),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                                // Consume Button
                                IconButton(
                                  icon: const Icon(Icons.restaurant_menu_outlined),
                                  tooltip: 'Consume product',
                                  color: Colors.white54,
                                  onPressed: () => _showConsumeDialog(
                                      context, ref, barcode, totalGrams),
                                ),
                              ],
                            ),
                          ),
                        ).animate().slideY(
                            begin: 0.1, duration: 400.ms, curve: Curves.easeOutQuad).fadeIn();
                      },
                      childCount: barcodes.length,
                    ),
                  ),
                );
              },
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  void _showConsumeDialog(
      BuildContext context, WidgetRef ref, String barcode, double maxGrams) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Consume Product'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Available: ${maxGrams.toStringAsFixed(0)}g'),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Grams to consume',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final val = double.tryParse(ctrl.text);
              if (val != null && val > 0) {
                try {
                  final repo = ref.read(pantryRepositoryProvider);
                  // Trigger fifoConsumptionLogic!
                  await repo.consumeProduct(barcode, val);
                  Navigator.of(ctx).pop();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text('Consume (FIFO)'),
          ),
        ],
      ),
    );
  }
}

class _MacroCell extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MacroCell({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tertiaryText = isDark ? Colors.white54 : Colors.black54;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
              fontWeight: FontWeight.w900, fontSize: 16, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
              color: tertiaryText, fontSize: 11, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
