import 'dart:async';

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_icons.dart';
import '../models/ui_message.dart';

// Track active snackbar overlay entries and their vertical offsets
final List<ValueNotifier<double>> _snackbarOffsets = [];
final List<OverlayEntry> _snackbarEntries = [];
final List<double> _snackbarHeights = [];

VoidCallback showFlexSnackbar(
  BuildContext context, {
  required String title,
  String? subtitle,
  required SnackbarType type,
  Duration duration = const Duration(seconds: 3),
  bool multiline = false,
}) {
  // Stacked snackbars support: maintain a list of active overlay entries
  final overlay = Overlay.of(context);
  const double itemHeight = 58.0;
  const double gap = 8.0;
  // Add extra top offset to avoid OS UI like the Dynamic Island on newer iPhones
  final baseTop = MediaQuery.of(context).padding.top + 36.0;

  // Lists to track active entries and their top offsets (declared at file scope)

  final topNotifier = ValueNotifier<double>(
    baseTop +
        _snackbarHeights.fold<double>(0, (sum, height) => sum + height + gap),
  );

  late OverlayEntry overlayEntry;
  final snackbarKey = GlobalKey();
  void updateOffsets() {
    var top = baseTop;
    for (var i = 0; i < _snackbarOffsets.length; i++) {
      _snackbarOffsets[i].value = top;
      top += _snackbarHeights[i] + gap;
    }
  }

  void updateHeight() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final entryIndex = _snackbarEntries.indexOf(overlayEntry);
      final height = snackbarKey.currentContext?.size?.height;
      if (entryIndex == -1 ||
          height == null ||
          _snackbarHeights[entryIndex] == height) {
        return;
      }
      _snackbarHeights[entryIndex] = height;
      updateOffsets();
    });
  }

  void dismiss() {
    final removedIndex = _snackbarEntries.indexOf(overlayEntry);
    if (removedIndex == -1) return;
    _snackbarEntries.removeAt(removedIndex);
    final removedNotifier = _snackbarOffsets.removeAt(removedIndex);
    _snackbarHeights.removeAt(removedIndex);
    updateOffsets();
    removedNotifier.dispose();
    overlayEntry.remove();
  }

  overlayEntry = OverlayEntry(
    builder: (context) {
      if (multiline) updateHeight();
      return ValueListenableBuilder<double>(
        valueListenable: topNotifier,
        builder: (context, topValue, _) {
          return Positioned(
            top: topValue,
            left: 24,
            right: 24,
            child: NotificationListener<SizeChangedLayoutNotification>(
              onNotification: (_) {
                if (multiline) updateHeight();
                return false;
              },
              child: SizeChangedLayoutNotifier(
                child: Material(
                  key: snackbarKey,
                  color: Colors.transparent,
                  child: AnimatedFlexSnackbar(
                    title: title,
                    subtitle: subtitle,
                    type: type,
                    duration: duration,
                    multiline: multiline,
                    onDismissed: dismiss,
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );

  // register and insert
  _snackbarOffsets.add(topNotifier);
  _snackbarEntries.add(overlayEntry);
  _snackbarHeights.add(itemHeight);
  overlay.insert(overlayEntry);
  return dismiss;
}

void showFlexSnackbarFromUiMessage(
  BuildContext context,
  UiMessage message, {
  Duration duration = const Duration(seconds: 3),
}) {
  // Map UiMessageType -> SnackbarType
  SnackbarType type;
  switch (message.type) {
    case UiMessageType.success:
      type = SnackbarType.success;
      break;
    case UiMessageType.warning:
      type = SnackbarType.warning;
      break;
    case UiMessageType.info:
      type = SnackbarType.update;
      break;
    case UiMessageType.error:
      type = SnackbarType.stop;
      break;
  }

  showFlexSnackbar(
    context,
    title: message.title,
    subtitle: message.subtitle,
    type: type,
    duration: duration,
  );
}

enum SnackbarType { success, warning, update, stop }

class FlexSnackbar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final SnackbarType type;
  final VoidCallback? onClose;
  final bool multiline;

  const FlexSnackbar({
    super.key,
    required this.title,
    this.subtitle,
    required this.type,
    this.onClose,
    this.multiline = false,
  });

  String get _iconAsset {
    switch (type) {
      case SnackbarType.success:
        return AppIcons.success;
      case SnackbarType.warning:
        return AppIcons.warning;
      case SnackbarType.update:
        return AppIcons.update;
      case SnackbarType.stop:
        return AppIcons.stop;
    }
  }

  Color get _iconColor {
    switch (type) {
      case SnackbarType.success:
        return AppTheme.successColor;
      case SnackbarType.warning:
        return AppTheme.warningColor;
      case SnackbarType.update:
        return AppTheme.updateColor;
      case SnackbarType.stop:
        return AppTheme.stopColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 386,
      height: multiline ? null : 58,
      constraints: multiline ? const BoxConstraints(minHeight: 58) : null,
      decoration: BoxDecoration(
        color: AppTheme.lightCard,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: multiline ? 8 : 0),
        child: Row(
          children: [
            const SizedBox(width: 16),
            // Icon
            SizedBox(
              width: 32,
              height: 32,
              child: Image.asset(_iconAsset, color: _iconColor),
            ),
            const SizedBox(width: 16),
            // Texts
            Expanded(
              child: Column(
                mainAxisSize: multiline ? MainAxisSize.min : MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppTheme.lightTextPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: multiline ? null : 1,
                    overflow:
                        multiline
                            ? TextOverflow.visible
                            : TextOverflow.ellipsis,
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        color: AppTheme.lightTextPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            // Close icon
            IconButton(
              icon: const Icon(Icons.close, color: AppTheme.lightTextPrimary),
              onPressed: onClose,
              tooltip: 'Close',
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}

class AnimatedFlexSnackbar extends StatefulWidget {
  final String title;
  final String? subtitle;
  final SnackbarType type;
  final Duration duration;
  final VoidCallback? onDismissed;
  final bool multiline;

  const AnimatedFlexSnackbar({
    super.key,
    required this.title,
    this.subtitle,
    required this.type,
    this.duration = const Duration(seconds: 3),
    this.onDismissed,
    this.multiline = false,
  });

  @override
  State<AnimatedFlexSnackbar> createState() => _AnimatedFlexSnackbarState();
}

class _AnimatedFlexSnackbarState extends State<AnimatedFlexSnackbar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );
  late final Animation<Offset> _offsetAnimation = Tween<Offset>(
    begin: const Offset(0, -1),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  late final Timer _dismissTimer;

  @override
  void initState() {
    super.initState();
    _controller.forward();
    _dismissTimer = Timer(widget.duration, _hide);
  }

  void _hide() async {
    if (!mounted) return;
    _dismissTimer.cancel();
    await _controller.reverse();
    widget.onDismissed?.call();
  }

  @override
  void dispose() {
    _dismissTimer.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: FlexSnackbar(
        title: widget.title,
        subtitle: widget.subtitle,
        type: widget.type,
        multiline: widget.multiline,
        onClose: _hide,
      ),
    );
  }
}
