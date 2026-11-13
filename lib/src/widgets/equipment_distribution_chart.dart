import 'package:flutter/material.dart';

import '../../enum/app_enums.dart';
import '../../theme/app_theme.dart';

class EquipmentDistributionChart extends StatefulWidget {
  final Map<EquipmentCategory, int> categoryCounts;

  const EquipmentDistributionChart({super.key, required this.categoryCounts});

  @override
  State<EquipmentDistributionChart> createState() =>
      _EquipmentDistributionChartState();
}

class _EquipmentDistributionChartState
    extends State<EquipmentDistributionChart> {
  bool _hasUpdated = false;

  @override
  void didUpdateWidget(covariant EquipmentDistributionChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    _hasUpdated = true;
  }

  @override
  Widget build(BuildContext context) {
    final counts = widget.categoryCounts.entries
        .where((entry) => entry.value > 0)
        .toList(growable: false);
    final total = counts.fold<int>(0, (sum, entry) => sum + entry.value);
    final target = _ChartDistribution.fromCounts(widget.categoryCounts);
    final duration =
        MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : Duration(milliseconds: _hasUpdated ? 300 : 500);
    final semanticLabel = StringBuffer(
      '$total ${total == 1 ? 'item' : 'items'}',
    );
    for (final entry in counts) {
      semanticLabel.write(', ${entry.key.label}: ${entry.value}');
    }

    return Semantics(
      container: true,
      label: semanticLabel.toString(),
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$total ',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.lightTextPrimary,
                    ),
                  ),
                  TextSpan(
                    text: 'Items',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTextPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 24,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: ColoredBox(
                  key: const ValueKey('equipment-distribution-bar'),
                  color: AppTheme.transparent,
                  child: TweenAnimationBuilder<_ChartDistribution>(
                    tween: _ChartDistributionTween(end: target),
                    duration: duration,
                    builder: (context, distribution, _) {
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          final segments = distribution.segments
                              .where((segment) => segment.quantity > 0)
                              .toList(growable: false);
                          final animatedTotal = segments.fold<double>(
                            0,
                            (sum, segment) => sum + segment.quantity,
                          );
                          if (segments.isEmpty || animatedTotal == 0) {
                            return const SizedBox.expand();
                          }

                          final width = constraints.maxWidth;
                          const gap = 2.0;
                          final gapsWidth = gap * (segments.length - 1);
                          final segmentsWidth = (width - gapsWidth).clamp(
                            0.0,
                            width,
                          );
                          return ClipRect(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              widthFactor: distribution.reveal,
                              child: SizedBox(
                                width: width,
                                child: Row(
                                  children: [
                                    for (
                                      var index = 0;
                                      index < segments.length;
                                      index++
                                    ) ...[
                                      if (index > 0) const SizedBox(width: gap),
                                      SizedBox(
                                        key: ValueKey(
                                          'equipment-distribution-segment-${segments[index].category.name}',
                                        ),
                                        width:
                                            segmentsWidth *
                                            segments[index].quantity /
                                            animatedTotal,
                                        height: 24,
                                        child: ColoredBox(
                                          color: segments[index].category.color,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
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

class _ChartSegment {
  final EquipmentCategory category;
  final double quantity;

  const _ChartSegment(this.category, this.quantity);
}

class _ChartDistribution {
  final List<_ChartSegment> segments;
  final double reveal;

  const _ChartDistribution({required this.segments, required this.reveal});

  static const empty = _ChartDistribution(segments: [], reveal: 0);

  factory _ChartDistribution.fromCounts(Map<EquipmentCategory, int> counts) {
    final segments = [
      for (final entry in counts.entries)
        if (entry.value > 0) _ChartSegment(entry.key, entry.value.toDouble()),
    ];
    return _ChartDistribution(
      segments: List.unmodifiable(segments),
      reveal: segments.isEmpty ? 0 : 1,
    );
  }

  static _ChartDistribution lerp(
    _ChartDistribution begin,
    _ChartDistribution end,
    double t,
  ) {
    final beginQuantities = {
      for (final segment in begin.segments) segment.category: segment.quantity,
    };
    final endQuantities = {
      for (final segment in end.segments) segment.category: segment.quantity,
    };
    final categories = <EquipmentCategory>[
      for (final segment in end.segments) segment.category,
      for (final segment in begin.segments)
        if (!endQuantities.containsKey(segment.category)) segment.category,
    ];

    return _ChartDistribution(
      segments: [
        for (final category in categories)
          _ChartSegment(
            category,
            (beginQuantities[category] ?? 0) +
                ((endQuantities[category] ?? 0) -
                        (beginQuantities[category] ?? 0)) *
                    t,
          ),
      ],
      reveal: begin.reveal + (end.reveal - begin.reveal) * t,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is! _ChartDistribution ||
        reveal != other.reveal ||
        segments.length != other.segments.length) {
      return false;
    }
    for (var index = 0; index < segments.length; index++) {
      if (segments[index].category != other.segments[index].category ||
          segments[index].quantity != other.segments[index].quantity) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
    reveal,
    Object.hashAll(
      segments.map(
        (segment) => Object.hash(segment.category, segment.quantity),
      ),
    ),
  );
}

class _ChartDistributionTween extends Tween<_ChartDistribution> {
  _ChartDistributionTween({required _ChartDistribution end})
    : super(begin: _ChartDistribution.empty, end: end);

  @override
  _ChartDistribution lerp(double t) => _ChartDistribution.lerp(begin!, end!, t);
}
