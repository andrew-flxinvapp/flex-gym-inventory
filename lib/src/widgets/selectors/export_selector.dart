import 'package:flutter/material.dart';
import 'package:flex_gym_inventory/src/widgets/cards/base_card.dart';
import 'package:flex_gym_inventory/theme/app_theme.dart';

class ExportSelector extends StatelessWidget {
  final String gymName;
  final int itemCount;
  final bool selected;
  final ValueChanged<bool?>? onChanged;
  final Color? color;

  const ExportSelector({
    Key? key,
    required this.gymName,
    required this.itemCount,
    this.selected = false,
    this.onChanged,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // debug: print when built to help verify rendering
    // ignore: avoid_print
    print('ExportSelector built for $gymName');

    return BaseCard(
      color: color,
      body: Row(
        children: [
          Checkbox(value: selected, onChanged: onChanged),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  gymName,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$itemCount items',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTextPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
