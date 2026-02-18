import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../enum/app_enums.dart';
import '../../theme/app_theme.dart';

class DashboardArcChart extends StatefulWidget {
  final Map<EquipmentCategory, int> categoryCounts;
  final double height;

  const DashboardArcChart({
    super.key,
    required this.categoryCounts,
    this.height = 220,
  });

  @override
  State<DashboardArcChart> createState() => _DashboardArcChartState();
}

class _DashboardArcChartState extends State<DashboardArcChart> {
  int? _tappedIndex;
  @override
  Widget build(BuildContext context) {
    final total = widget.categoryCounts.values.fold<int>(0, (a, b) => a + b);
    final theme = Theme.of(context);
    final double chartSize = widget.height; // use provided height to size the chart
    // Use colors defined on the `EquipmentCategory` enum via extension.

    final entries = widget.categoryCounts.entries.toList();

    // Build chart sections and a gap slice to create an "arc" effect.
    // For a 270° visible arc, set gap to 90° (90/360 = 0.25).
    // gapFraction controls how much of the circle is left empty (0.0..0.5).
    const double gapFraction = 90 / 360;
    final nonZeroEntries = entries.where((e) => e.value > 0).toList();

    List<PieChartSectionData> sections = [];
    if (total > 0) {
      // Add slices for each category
      for (var i = 0; i < nonZeroEntries.length; i++) {
        final entry = nonZeroEntries[i];
        final percent = entry.value / total;
        final isSelected = _tappedIndex == i;
        // Show item count on slice instead of percent (hide for very small slices)
        final title = percent > 0.03 ? '${entry.value}' : '';
        sections.add(
          PieChartSectionData(
            color: entry.key.color,
            value: entry.value.toDouble(),
            title: title,
            radius: isSelected ? chartSize * 0.52 : chartSize * 0.45,
            titleStyle: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }

      // Add a gap slice colored to match the card background so the chart looks like an arc.
      final gapValue = total * gapFraction / (1 - gapFraction);
      sections.add(
        PieChartSectionData(
          color: AppTheme.lightCard,
          value: gapValue,
          title: '',
          radius: chartSize * 0.45,
        ),
      );
    }

    Widget chartWidget() {
      if (total == 0) {
        return Text(
          "Your stats will show up here once you've added a gym and some equipment.",
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.lightTextPrimary,
          ),
          textAlign: TextAlign.center,
        );
      }

      // Compute start offset so the gap slice is centered at the bottom (90deg).
      final startDegreeOffset = 90 - (1 - gapFraction / 2) * 360;

      return SizedBox(
        width: chartSize,
        height: chartSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            PieChart(
              PieChartData(
                  sections: sections,
                  sectionsSpace: 2,
                  centerSpaceRadius: chartSize * 0.33,
                  startDegreeOffset: startDegreeOffset,
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      // Respond on tap up or long-press end. Ignore gap slice.
                      if (event is FlTapUpEvent || event is FlLongPressEnd) {
                          final resp = pieTouchResponse;
                          if (resp == null) {
                            setState(() => _tappedIndex = null);
                          } else {
                            final touched = resp.touchedSection;
                            final idx = touched?.touchedSectionIndex ?? -1;
                            // Validate index: must be >= 0 and not the gap slice (last section).
                            if (idx < 0 || idx >= sections.length - 1) {
                              setState(() => _tappedIndex = null);
                            } else {
                              setState(() => _tappedIndex = idx);
                            }
                          }
                      }
                    },
                  ),
                ),
            ),
            // Center column: show tapped category + count as a tooltip,
            // otherwise show total items.
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_tappedIndex != null && _tappedIndex! >= 0 && _tappedIndex! < nonZeroEntries.length) ...[
                      Text(
                        nonZeroEntries[_tappedIndex!].key.label,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.lightTextPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        nonZeroEntries[_tappedIndex!].value.toString(),
                        style: theme.textTheme.displayMedium?.copyWith(
                          color: AppTheme.lightTextPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ] else ...[
                  Text(
                    total.toString(),
                    style: theme.textTheme.displayLarge?.copyWith(
                      color: AppTheme.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Items',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightPrimary,
                    ),
                  ),
                ]
              ],
            ),
          ],
        ),
      );
    }

    Widget legend() {
      // Two-column legend: left column shows first 5 items, right column shows next 5.
      // Always render exactly 5 rows per column (10 slots total).
      final leftSlots = List<MapEntry<EquipmentCategory, int>?>.generate(
        5,
        (i) => i < entries.length ? entries[i] : null,
      );
      final rightSlots = List<MapEntry<EquipmentCategory, int>?>.generate(
        5,
        (i) {
          final idx = i + 5;
          return idx < entries.length ? entries[idx] : null;
        },
      );

      Widget buildLegendItem(MapEntry<EquipmentCategory, int>? entry, int i) {
        final bool hasEntry = entry != null;
        final color = hasEntry ? entry.key.color : AppTheme.lightTextPrimary.withOpacity(0.12);
        final label = hasEntry ? entry.key.label : '';
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: hasEntry ? AppTheme.lightTextPrimary : AppTheme.lightTextPrimary.withOpacity(0.35),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(5, (i) => buildLegendItem(leftSlots[i], i)),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(5, (i) => buildLegendItem(rightSlots[i], i + 5)),
            ),
          ),
        ],
      );
    }

    return Center(
      child: Container(
        width: 420,
        height: 600,
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
            const SizedBox(height: 40),
            Expanded(
              child: Center(
                child: chartWidget(),
              ),
            ),
            const SizedBox(height: 8),
            legend(),
          ],
        ),
      ),
    );
  }

  // Labels are provided by `EquipmentCategory.label` in `app_enums.dart`.
}
