import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

class AnimatedCompletionIcon extends StatefulWidget {
  final double size;
  final Color color;

  const AnimatedCompletionIcon({
    super.key,
    this.size = 128,
    this.color = AppTheme.darkTextPrimary,
  });

  @override
  State<AnimatedCompletionIcon> createState() => _AnimatedCompletionIconState();
}

class _AnimatedCompletionIconState extends State<AnimatedCompletionIcon>
    with SingleTickerProviderStateMixin {
  static const _totalDuration = Duration(milliseconds: 950);
  static const _circleEnd = 0.631578947368421;

  late final AnimationController _controller;
  late final Animation<double> _circleProgress;
  late final Animation<double> _checkProgress;
  bool? _disableAnimations;
  bool _hasStarted = false;
  bool _isComplete = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _totalDuration);
    _circleProgress = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, _circleEnd, curve: Curves.easeInOut),
    );
    _checkProgress = CurvedAnimation(
      parent: _controller,
      curve: const Interval(_circleEnd, 1, curve: Curves.easeOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    if (_disableAnimations == disableAnimations) return;
    _disableAnimations = disableAnimations;

    if (disableAnimations) {
      _controller.stop();
      _controller.value = 1;
      _isComplete = true;
    } else if (!_hasStarted && !_isComplete) {
      _hasStarted = true;
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: 'Completed',
      child: ExcludeSemantics(
        child: SizedBox.square(
          dimension: widget.size,
          child: AnimatedBuilder(
            animation: _controller,
            builder:
                (context, _) => CustomPaint(
                  painter: _CompletionIconPainter(
                    color: widget.color,
                    circleProgress: _isComplete ? 1 : _circleProgress.value,
                    checkProgress: _isComplete ? 1 : _checkProgress.value,
                  ),
                ),
          ),
        ),
      ),
    );
  }
}

class _CompletionIconPainter extends CustomPainter {
  static const _designSize = 116.0;
  static const _strokeWidth = 9.0;

  final Color color;
  final double circleProgress;
  final double checkProgress;

  const _CompletionIconPainter({
    required this.color,
    required this.circleProgress,
    required this.checkProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / _designSize, size.height / _designSize);

    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = _strokeWidth
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..isAntiAlias = true;

    final circle =
        Path()..arcTo(
          Rect.fromCircle(center: const Offset(58, 58), radius: 53.5),
          math.pi / 3,
          2 * math.pi - (math.pi / 3 - 0.4),
          false,
        );
    final check =
        Path()
          ..moveTo(34, 58)
          ..lineTo(50, 74)
          ..lineTo(82, 41);

    _drawPathProgress(canvas, circle, paint, circleProgress);
    _drawPathProgress(canvas, check, paint, checkProgress);
    canvas.restore();
  }

  void _drawPathProgress(
    Canvas canvas,
    Path path,
    Paint paint,
    double progress,
  ) {
    if (progress <= 0) return;
    final metric = path.computeMetrics().first;
    canvas.drawPath(metric.extractPath(0, metric.length * progress), paint);
  }

  @override
  bool shouldRepaint(covariant _CompletionIconPainter oldDelegate) =>
      color != oldDelegate.color ||
      circleProgress != oldDelegate.circleProgress ||
      checkProgress != oldDelegate.checkProgress;
}
