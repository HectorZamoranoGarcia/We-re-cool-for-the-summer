import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../controllers/price_history_controller.dart';
import '../controllers/cheapest_supermarket_controller.dart';
import '../../core/widgets/premium_card.dart';
import '../../core/widgets/supermarket_badge.dart';

class PriceHistoryScreen extends ConsumerWidget {
  final String barcode;
  const PriceHistoryScreen({super.key, required this.barcode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyState = ref.watch(priceHistoryProvider(barcode));
    final cheapestMarketState = ref.watch(cheapestSupermarketProvider(barcode));

    final String cheapestMarketName = 'Mercadona';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Price Engine', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 320,
              padding: const EdgeInsets.only(right: 24, left: 12, top: 40),
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 42,
                        getTitlesWidget: (val, meta) => Text('€${val.toStringAsFixed(1)}', style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(1, 2.8), FlSpot(2, 2.9), FlSpot(3, 2.4), FlSpot(4, 2.6), FlSpot(5, 2.1),
                      ],
                      isCurved: true,
                      color: const Color(0xFF00C853),
                      barWidth: 5,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF00C853).withOpacity(0.5),
                            const Color(0xFF00C853).withOpacity(0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fade(duration: 800.ms).slideY(begin: 0.1, curve: Curves.easeOutExpo),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
              child: Text('Price Records', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: 4,
              itemBuilder: (context, index) {
                final markets = ['Mercadona', 'Carrefour', 'Lidl', 'Aldi'];
                final prices = [2.10, 2.60, 2.80, 2.90];
                final marketName = markets[index];
                final price = prices[index];
                final isCheapest = marketName == cheapestMarketName;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: PremiumCard(
                    padding: const EdgeInsets.all(16),
                    customBorder: isCheapest
                        ? Border.all(color: const Color(0xFF00C853).withOpacity(0.6), width: 2)
                        : null,
                    customShadows: isCheapest
                        ? [BoxShadow(color: const Color(0xFF00C853).withOpacity(0.25), blurRadius: 25, spreadRadius: 2)]
                        : null,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SupermarketBadge(supermarketName: marketName),
                            if (isCheapest)
                              const Padding(
                                padding: EdgeInsets.only(top: 8.0),
                                child: Text('Best Price ✨', style: TextStyle(color: Color(0xFF00C853), fontSize: 13, fontWeight: FontWeight.bold)),
                              ),
                          ],
                        ),
                        Text('€${price.toStringAsFixed(2)}', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: isCheapest ? const Color(0xFF00C853) : Colors.white)),
                      ],
                    ),
                  ),
                ).animate().fade(delay: (200 + index * 100).ms).slideX(begin: 0.1, curve: Curves.easeOutQuad);
              },
            ),
          ],
        ),
      ),
    );
  }
}
