import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class PurchaseCard extends StatelessWidget {
  final List<MapEntry<String, String>> details;
  const PurchaseCard({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    // Only show up to 4 rows, fill with empty if less
    final rows = List<MapEntry<String, String>>.generate(
      4,
      (i) => i < details.length
          ? details[i]
          : const MapEntry('', ''),
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
          for (int i = 0; i < 4; i++) ...[
            _PurchaseDetailRow(
              label: rows[i].key,
              value: rows[i].value,
            ),
            if (i != 3) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _PurchaseDetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _PurchaseDetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label.isNotEmpty ? "$label:" : '',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTextPrimary,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTextPrimary,
              ),
        ),
      ],
    );
  }
}
