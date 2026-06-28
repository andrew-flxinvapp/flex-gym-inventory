import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class DetailsCard extends StatelessWidget {
  final List<MapEntry<String, String>> details;
  const DetailsCard({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    // Only show up to 5 rows, fill with empty if less
    final rows = List<MapEntry<String, String>>.generate(
      5,
      (i) => i < details.length ? details[i] : const MapEntry('', ''),
    );

    return Container(
      width: 370,
      decoration: BoxDecoration(
        color: AppTheme.lightCard,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 0; i < 5; i++) ...[
            _DetailRow(label: rows[i].key, value: rows[i].value),
            if (i != 4) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label.isNotEmpty ? "$label:" : '',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppTheme.lightTextPrimary),
        ),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppTheme.lightTextPrimary),
        ),
      ],
    );
  }
}
