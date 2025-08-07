import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/app_icons.dart';

class WishlistItemCard extends StatelessWidget {
  final String itemName;
  final String brand;

  const WishlistItemCard({
    super.key,
    required this.itemName,
    required this.brand,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 370,
      height: 103,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppTheme.lightCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: AppTheme.lightSecondary.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Image.asset(
                AppIcons.round,
                width: 55,
                height: 55,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  itemName,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.lightTextPrimary,
                        fontFamily: 'Roboto',
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  brand,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTextPrimary.withOpacity(0.7),
                        fontFamily: 'Roboto',
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
