import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_icons.dart';
import '../models/ui_message.dart';

void showFlexSnackbar(
  BuildContext context, {
  required String title,
  String? subtitle,
  required SnackbarType type,
  Duration duration = const Duration(seconds: 3),
}) {
  final overlay = Overlay.of(context);
  late OverlayEntry overlayEntry;
  overlayEntry = OverlayEntry(
    builder: (context) {
      final topOffset = MediaQuery.of(context).padding.top + 16;
      return Positioned(
        top: topOffset,
        left: 24,
        right: 24,
        child: Material(
          color: Colors.transparent,
          child: AnimatedFlexSnackbar(
            title: title,
            subtitle: subtitle,
            type: type,
            duration: duration,
            onDismissed: () {
              if (overlayEntry.mounted) overlayEntry.remove();
            },
          ),
        ),
      );
    },
  );
  overlay.insert(overlayEntry);
}

void showFlexSnackbarFromUiMessage(BuildContext context, UiMessage message,
    {Duration duration = const Duration(seconds: 3)}) {
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

  const FlexSnackbar({
    super.key,
    required this.title,
    this.subtitle,
    required this.type,
    this.onClose,
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
      height: 58,
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
      child: Row(
        children: [
          const SizedBox(width: 16),
          // Icon
          SizedBox(
            width: 32,
            height: 32,
            child: Image.asset(
              _iconAsset,
              color: _iconColor,
            ),
          ),
          const SizedBox(width: 16),
          // Texts
          Expanded(
            child: Column(
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
    );
  }
}

class AnimatedFlexSnackbar extends StatefulWidget {
  final String title;
  final String? subtitle;
  final SnackbarType type;
  final Duration duration;
  final VoidCallback? onDismissed;

  const AnimatedFlexSnackbar({
    super.key,
    required this.title,
    this.subtitle,
    required this.type,
    this.duration = const Duration(seconds: 3),
    this.onDismissed,
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

  @override
  void initState() {
    super.initState();
    _controller.forward();
    Future.delayed(widget.duration, () => _hide());
  }

  void _hide() async {
    if (!mounted) return;
    await _controller.reverse();
    widget.onDismissed?.call();
  }

  @override
  void dispose() {
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
        onClose: _hide,
      ),
    );
  }
}
