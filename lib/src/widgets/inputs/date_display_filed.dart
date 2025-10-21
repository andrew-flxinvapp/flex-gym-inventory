import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

/// Displays a non-editable Gym ID in a form field style.
class DateDisplayField extends StatelessWidget {
  final String date;

  const DateDisplayField({
    super.key,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final Color textColor = AppTheme.lightTextPrimary;
    return Container(
      width: 370,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        date,
        style: TextStyle(
          color: textColor.withValues(alpha: 0.6),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
