import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';


class DisplayField extends StatelessWidget {
  final String? iconPath;
  final String label;
  final String value;

  const DisplayField({
    super.key,
    this.iconPath,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 370,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.lightCard,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (iconPath != null)
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: Image.asset(
                  iconPath!,
                  width: 24,
                  height: 24,
                  fit: BoxFit.contain,
                  color: AppTheme.lightTextPrimary,
                ),
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTextPrimary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightPrimary,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}