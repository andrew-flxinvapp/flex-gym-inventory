import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../enum/app_enums.dart';
import '../../theme/app_theme.dart';

class DashboardPieChart extends StatefulWidget {
  final Map<EquipmentCategory, int> categoryCounts;
  final double height;

  const DashboardPieChart({
    super.key,
    required this.categoryCounts,
    this.height = 220,
  });

  @override
  State<DashboardPieChart> createState() => _DashboardPieChartState();
}

class _DashboardPieChartState extends State<DashboardPieChart> {
  @override
  Widget build(BuildContext context) {
    final total = widget.categoryCounts.values.fold<int>(0, (a, b) => a + b);
    final theme = Theme.of(context);
    final List<Color> pieColors = [
      Color(0xFFE63946),
      Color(0xFFF4A261),
      Color(0xFFE9C46A),
      Color(0xFF2A9D8F),
      Color(0xFF457B9D),
      Color(0xFF6A4C93),
      Color(0xFFA8A8A8),
      Color(0xFF264653),
    ];

    final entries = widget.categoryCounts.entries.toList();

    return Center(
      child: Container(
        width: 420,
        height: 420,
        decoration: BoxDecoration(
          color: AppTheme.lightCard,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'By Category',
              style: theme.textTheme.displaySmall?.copyWith(
                color: AppTheme.lightTextPrimary,
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Center(
                child: total == 0
                    ? Text(
                        "Your stats will show up here once you've added a gym and some equipment.",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.lightTextPrimary,
                        ),
                        textAlign: TextAlign.center,
                      )
                    : SizedBox(
                        width: 360,
                        height: 360,
                        child: PieChart(
                          PieChartData(
                            sections: List.generate(entries.length, (i) {
                              final entry = entries[i];
                              final percent = total == 0 ? 0.0 : entry.value / total;
                              return PieChartSectionData(
                                color: pieColors[i % pieColors.length],
                                value: entry.value.toDouble(),
                                title: percent > 0.07
                                    ? '${(percent * 100).toStringAsFixed(0)}%'
                                    : '',
                                radius: 100, // Increased radius for larger slices
                                titleStyle: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }),
                            sectionsSpace: 2,
                            centerSpaceRadius: 36,
                          ),
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
