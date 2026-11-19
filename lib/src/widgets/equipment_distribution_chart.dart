import 'package:flutter/material.dart';

import '../../enum/app_enums.dart';
import '../../theme/app_theme.dart';

class EquipmentDistributionChart extends StatefulWidget {
  final Map<EquipmentCategory, int> categoryCounts;
  final bool isVisible;
  final bool isDataReady;

  const EquipmentDistributionChart({
    super.key,
    required this.categoryCounts,
    this.isVisible = true,
    this.isDataReady = true,
  });

  @override
  State<EquipmentDistributionChart> createState() =>
      _EquipmentDistributionChartState();
}

enum _AnimationPhase { waiting, entrance, transition, settled }

class _EquipmentDistributionChartState extends State<EquipmentDistributionChart>
    with SingleTickerProviderStateMixin {
  static const _delayMs = 180;
  static const _firstDurationMs = 480;
  static const _laterDurationMs = 190;
  static const _overlapMs = 50;

  late final AnimationController _controller;
  late _ChartDistribution _target;
  _ChartDistribution _begin = _ChartDistribution.empty;
  _AnimationPhase _phase = _AnimationPhase.waiting;
  bool _disableAnimations = false;
  double? _barWidth;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _target = _ChartDistribution.fromCounts(widget.categoryCounts);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _disableAnimations = MediaQuery.disableAnimationsOf(context);
    _syncPlayback();
  }

  @override
  void didUpdateWidget(covariant EquipmentDistributionChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    final target = _ChartDistribution.fromCounts(widget.categoryCounts);
    if (target != _target) {
      var current = _displayedDistribution;
      final width = _barWidth;
      if (_phase == _AnimationPhase.entrance && width != null) {
        final visibleCount =
            current.segments.where((segment) => segment.proportion > 0).length;
        if (visibleCount > 0) {
          final entranceWidth = (width - 2 * (_target.segments.length - 1))
              .clamp(0.0, width);
          final transitionWidth = (width - 2 * (visibleCount - 1)).clamp(
            0.0,
            width,
          );
          final scale =
              transitionWidth == 0 ? 0.0 : entranceWidth / transitionWidth;
          current = _ChartDistribution([
            for (final segment in current.segments)
              _ChartSegment(segment.category, segment.proportion * scale),
          ]);
        }
      }
      _target = target;
      if (_phase != _AnimationPhase.waiting) {
        _begin = current;
        if (_disableAnimations) {
          _controller.stop();
          _phase = _AnimationPhase.settled;
        } else {
          _phase = _AnimationPhase.transition;
          _controller.duration = const Duration(milliseconds: 300);
          _controller.forward(from: 0);
        }
      }
    }
    _syncPlayback();
  }

  void _syncPlayback() {
    if (_disableAnimations) {
      if (_phase != _AnimationPhase.waiting ||
          (widget.isVisible &&
              widget.isDataReady &&
              _target.segments.isNotEmpty)) {
        _controller.stop();
        _phase = _AnimationPhase.settled;
      }
      return;
    }

    if (_phase == _AnimationPhase.waiting &&
        widget.isVisible &&
        widget.isDataReady &&
        _target.segments.isNotEmpty) {
      _phase = _AnimationPhase.entrance;
      final durationMs =
          _delayMs +
          _firstDurationMs +
          (_target.segments.length - 1) * (_laterDurationMs - _overlapMs);
      _controller.duration = Duration(milliseconds: durationMs);
      _controller.forward(from: 0);
    } else if (_phase == _AnimationPhase.entrance) {
      if (!widget.isVisible) {
        _controller.stop();
      } else if (!_controller.isAnimating && _controller.value < 1) {
        _controller.forward();
      }
    }
  }

  _ChartDistribution get _displayedDistribution {
    switch (_phase) {
      case _AnimationPhase.waiting:
        return _ChartDistribution.empty;
      case _AnimationPhase.settled:
        return _target;
      case _AnimationPhase.transition:
        return _ChartDistribution.lerp(
          _begin,
          _target,
          Curves.easeOutCubic.transform(_controller.value),
        );
      case _AnimationPhase.entrance:
        final elapsedMs =
            _controller.value * _controller.duration!.inMilliseconds;
        return _ChartDistribution([
          for (var index = 0; index < _target.segments.length; index++)
            _ChartSegment(
              _target.segments[index].category,
              _target.segments[index].proportion *
                  Curves.easeOutCubic.transform(
                    ((elapsedMs -
                                (index == 0
                                    ? _delayMs
                                    : _delayMs +
                                        _firstDurationMs -
                                        _overlapMs +
                                        (index - 1) *
                                            (_laterDurationMs - _overlapMs))) /
                            (index == 0 ? _firstDurationMs : _laterDurationMs))
                        .clamp(0.0, 1.0),
                  ),
            ),
        ]);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final counts = widget.categoryCounts.entries
        .where((entry) => entry.value > 0)
        .toList(growable: false);
    final total = counts.fold<int>(0, (sum, entry) => sum + entry.value);
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
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) {
                      final distribution = _displayedDistribution;
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          _barWidth = constraints.maxWidth;
                          final segments = distribution.segments
                              .where((segment) => segment.proportion > 0)
                              .toList(growable: false);
                          if (segments.isEmpty) return const SizedBox.expand();

                          final width = constraints.maxWidth;
                          const gap = 2.0;
                          final gapCount =
                              _phase == _AnimationPhase.entrance
                                  ? _target.segments.length - 1
                                  : segments.length - 1;
                          final gapsWidth = gap * gapCount;
                          final segmentsWidth = (width - gapsWidth).clamp(
                            0.0,
                            width,
                          );
                          return ClipRect(
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
                                        segments[index].proportion,
                                    height: 24,
                                    child: ColoredBox(
                                      color: segments[index].category.color,
                                    ),
                                  ),
                                ],
                              ],
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
  final double proportion;

  const _ChartSegment(this.category, this.proportion);
}

class _ChartDistribution {
  final List<_ChartSegment> segments;

  const _ChartDistribution(this.segments);

  static const empty = _ChartDistribution([]);

  factory _ChartDistribution.fromCounts(Map<EquipmentCategory, int> counts) {
    final total = counts.values
        .where((count) => count > 0)
        .fold<int>(0, (sum, count) => sum + count);
    return _ChartDistribution([
      for (final entry in counts.entries)
        if (entry.value > 0) _ChartSegment(entry.key, entry.value / total),
    ]);
  }

  static _ChartDistribution lerp(
    _ChartDistribution begin,
    _ChartDistribution end,
    double t,
  ) {
    final beginProportions = {
      for (final segment in begin.segments)
        segment.category: segment.proportion,
    };
    final endProportions = {
      for (final segment in end.segments) segment.category: segment.proportion,
    };
    final categories = <EquipmentCategory>[
      for (final segment in end.segments) segment.category,
      for (final segment in begin.segments)
        if (!endProportions.containsKey(segment.category)) segment.category,
    ];

    return _ChartDistribution([
      for (final category in categories)
        _ChartSegment(
          category,
          (beginProportions[category] ?? 0) +
              ((endProportions[category] ?? 0) -
                      (beginProportions[category] ?? 0)) *
                  t,
        ),
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (other is! _ChartDistribution ||
        segments.length != other.segments.length) {
      return false;
    }
    for (var index = 0; index < segments.length; index++) {
      if (segments[index].category != other.segments[index].category ||
          segments[index].proportion != other.segments[index].proportion) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(
    segments.map(
      (segment) => Object.hash(segment.category, segment.proportion),
    ),
  );
}
