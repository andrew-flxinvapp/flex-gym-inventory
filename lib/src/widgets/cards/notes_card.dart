import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class NotesCard extends StatelessWidget {
  final String notes;
  const NotesCard({super.key, required this.notes});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 370,
      height: 200,
      decoration: BoxDecoration(
        color: AppTheme.lightCard,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(
          notes,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTextPrimary,
              ),
        ),
      ),
    );
  }
}
