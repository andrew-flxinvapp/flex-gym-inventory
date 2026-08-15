import 'package:flutter/widgets.dart';
import 'package:material_ui/material_ui.dart' as material;

/// Small adapter around the platform-adaptive switch.
///
/// Keeps a single migration point if Material/Cupertino widgets move packages.
class AdaptiveSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const AdaptiveSwitch({super.key, required this.value, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return material.Material(
      child: material.Switch.adaptive(value: value, onChanged: onChanged),
    );
  }
}
