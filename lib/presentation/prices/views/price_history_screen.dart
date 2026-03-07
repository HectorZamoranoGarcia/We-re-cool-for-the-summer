import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../controllers/price_history_controller.dart';
import '../controllers/cheapest_supermarket_controller.dart';
import '../../core/widgets/premium_card.dart';
import '../../core/widgets/supermarket_tag.dart';

class PriceHistoryScreen extends ConsumerWidget {
  final String barcode;
  const PriceHistoryScreen({super.key, required this.barcode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(priceHistoryProvider(barcode));
    final cheapest = ref.watch(cheapestSupermarketProvider(barcode));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Price Engine', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_chart_outlined),
            tooltip: 'Log a price',
            onPressed: () => _showPriceEntrySheet(context, ref, barcode),
          ),
        ],
      ),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (state) => _PriceHistoryBody(
          state: state,
          barcode: barcode,
          cheapest: cheapest,
          theme: theme,
        ),
      ),
    );
  }

  void _showPriceEntrySheet(BuildContext context, WidgetRef ref, String barcode) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PriceEntrySheet(barcode: barcode),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────
class _PriceHistoryBody extends StatelessWidget {
  final PriceHistoryState state;
  final String barcode;
  final CheapestPriceModel? cheapest;
  final ThemeData theme;

  const _PriceHistoryBody({
    required this.state,
    required this.barcode,
    required this.cheapest,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final series = state.priceTrendSeries;
    final records = state.filtered;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Stat bar ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                _StatChip(
                  label: 'Lowest Ever',
                  value: state.lowestPriceEver != null
                      ? '€${state.lowestPriceEver!.toStringAsFixed(2)}'
                      : 'No data',
                  accent: const Color(0xFF00C853),
                  icon: Icons.arrow_downward_rounded,
                ),
                const SizedBox(width: 10),
                if (cheapest != null)
                  _StatChip(
                    label: 'Best: ${cheapest!.supermarketName[0].toUpperCase()}${cheapest!.supermarketName.substring(1)}',
                    value: '€${cheapest!.lowestPrice.toStringAsFixed(2)}',
                    accent: const Color(0xFF40C4FF),
                    icon: Icons.storefront_outlined,
                  ),
              ],
            ),
          ),

          // ── fl_chart trend line ───────────────────────────────────────────
          if (series.length >= 2)
            Container(
              height: 220,
              padding: const EdgeInsets.only(right: 24, left: 8, top: 16, bottom: 8),
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    getDrawingHorizontalLine: (_) => const FlLine(
                      color: Colors.white12, strokeWidth: 1),
                    drawVerticalLine: false,
                  ),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 44,
                        getTitlesWidget: (val, _) => Text(
                          '€${val.toStringAsFixed(1)}',
                          style: const TextStyle(color: Colors.white38, fontSize: 11),
                        ),
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: series
                          .map((e) => FlSpot(e.$1, e.$2))
                          .toList(),
                      isCurved: true,
                      color: const Color(0xFF00C853),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                          radius: 4,
                          color: const Color(0xFF00C853),
                          strokeWidth: 2,
                          strokeColor: Colors.black,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF00C853).withOpacity(0.4),
                            const Color(0xFF00C853).withOpacity(0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fade(duration: 800.ms).slideY(begin: 0.08, curve: Curves.easeOutExpo),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Text(
                'Scan a price at 2+ different times to see the trend chart.',
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.white38),
              ),
            ),

          // ── Supermarket filter chips ───────────────────────────────────────
          Consumer(builder: (ctx, ref, _) {
            final historyCtrl = ref.read(priceHistoryProvider(barcode).notifier);
            final currentFilter = state.supermarketFilter;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: Text('Filter', style: theme.textTheme.labelSmall?.copyWith(color: Colors.white38, letterSpacing: 1)),
                ),
                SupermarketSelector(
                  selected: currentFilter,
                  onSupermarketSelected: historyCtrl.filterBySupermarket,
                ),
                if (currentFilter != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 16, top: 8),
                    child: GestureDetector(
                      onTap: historyCtrl.clearFilter,
                      child: const Text(
                        '✕ Clear filter',
                        style: TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                    ),
                  ),
              ],
            );
          }),

          const SizedBox(height: 16),

          // ── Dense price record list ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('Records', style: theme.textTheme.labelSmall?.copyWith(color: Colors.white38, letterSpacing: 1)),
          ),
          const SizedBox(height: 8),

          if (records.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Text('No price records yet.', style: theme.textTheme.bodySmall?.copyWith(color: Colors.white38)),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: records.length,
              itemBuilder: (_, i) {
                final rec = records[i];
                final isBest = rec.price == state.lowestPriceEver;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: PremiumCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    customBorder: isBest
                        ? Border.all(color: const Color(0xFF00C853).withOpacity(0.6), width: 1.5)
                        : null,
                    child: Row(
                      children: [
                        SupermarketTag(name: rec.supermarketName),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${rec.recordedAt.day}/${rec.recordedAt.month}/${rec.recordedAt.year}',
                            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white54),
                          ),
                        ),
                        if (isBest)
                          const Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: Text('★', style: TextStyle(color: Color(0xFF00C853), fontSize: 16)),
                          ),
                        Text(
                          '€${rec.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: isBest ? const Color(0xFF00C853) : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().fade(delay: (80 * i).ms).slideX(begin: 0.05);
              },
            ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ── Stat chip ─────────────────────────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;
  final IconData icon;

  const _StatChip({required this.label, required this.value, required this.accent, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: accent, size: 14),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: accent, fontSize: 10, fontWeight: FontWeight.w600)),
              Text(value, style: TextStyle(color: accent, fontSize: 16, fontWeight: FontWeight.w900)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Price entry sheet ─────────────────────────────────────────────────────────
class _PriceEntrySheet extends ConsumerStatefulWidget {
  final String barcode;
  const _PriceEntrySheet({required this.barcode});

  @override
  ConsumerState<_PriceEntrySheet> createState() => _PriceEntrySheetState();
}

class _PriceEntrySheetState extends ConsumerState<_PriceEntrySheet> {
  final _priceCtrl = TextEditingController();
  String? _selectedMarket;

  @override
  void dispose() {
    _priceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Log a Price', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text('Barcode: ${widget.barcode}', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
          const SizedBox(height: 16),
          SupermarketSelector(
            selected: _selectedMarket,
            onSupermarketSelected: (m) => setState(() => _selectedMarket = m),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _priceCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Price',
              prefixText: '€ ',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () async {
                final price = double.tryParse(_priceCtrl.text);
                if (price == null || _selectedMarket == null) return;
                final ctrl = ref.read(priceHistoryProvider(widget.barcode).notifier);
                // TODO: wire through AddPriceRecordUseCase via DI
                Navigator.of(context).pop();
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Save Price', style: TextStyle(fontSize: 15)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
