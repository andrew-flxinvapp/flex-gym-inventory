import 'package:material_ui/material_ui.dart';
import '/../../theme/app_theme.dart';
import '../switch_adapter.dart';

class AppToggle extends StatefulWidget {
  final String label;
  final bool initialValue;
  final ValueChanged<bool>? onChanged;

  const AppToggle({
    super.key,
    required this.label,
    this.initialValue = false,
    this.onChanged,
  });

  @override
  State<AppToggle> createState() => _AppToggleState();
}

class _AppToggleState extends State<AppToggle> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  void didUpdateWidget(covariant AppToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      setState(() {
        _value = widget.initialValue;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 370,
      height: 50,
      decoration: BoxDecoration(
        color: AppTheme.lightCard,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.lightTextPrimary),
          ),
          AdaptiveSwitch(
            value: _value,
            onChanged: (val) {
              setState(() => _value = val);
              if (widget.onChanged != null) widget.onChanged!(val);
            },
          ),
        ],
      ),
    );
  }
}
