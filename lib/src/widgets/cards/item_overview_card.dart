import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import 'base_card.dart';

class ItemOverviewCard extends StatelessWidget {
  const ItemOverviewCard({
    super.key,
    required this.name,
    required this.placeholderIconAsset,
    this.image,
  });

  final String name;
  final String placeholderIconAsset;
  final Widget? image;

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 3 / 2,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child:
                  image ??
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.lightBackground,
                      border: Border.all(color: AppTheme.dividers),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Image.asset(
                        placeholderIconAsset,
                        width: 48,
                        height: 48,
                        color: AppTheme.lightPrimary,
                      ),
                    ),
                  ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            textAlign: TextAlign.left,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppTheme.lightTextPrimary),
          ),
        ],
      ),
    );
  }
}
