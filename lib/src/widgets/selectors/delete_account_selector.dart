import 'package:flutter/material.dart';
import 'package:flex_gym_inventory/theme/app_theme.dart';

class DeleteAccountSelector extends StatelessWidget {
  final bool selected;
  final VoidCallback? onTap;
  final String text;

  const DeleteAccountSelector({
    super.key,
    required this.selected,
    required this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Checkbox(
            value: selected,
            onChanged: (_) => onTap?.call(),
            fillColor: MaterialStateProperty.resolveWith<Color?>((states) {
              if (states.contains(MaterialState.selected)) {
                return AppTheme.lightAppBar;
              }
              return null; // use default unselected color
            }),
            checkColor: AppTheme.lightBackground,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.lightTextPrimary),
              overflow: TextOverflow.visible,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}
