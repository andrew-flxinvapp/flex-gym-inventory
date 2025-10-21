import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/app_icons.dart';
import 'package:flex_gym_inventory/routes/routes.dart';

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
    return Slidable(
      key: ValueKey(itemName),
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              Navigator.of(context).pushNamed(AppRoutes.editWishlist);
            },
            backgroundColor: AppTheme.updateColor,
            foregroundColor: AppTheme.lightBackground,
            icon: Icons.edit,
            label: 'Edit',
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(0),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(0),
            ),
          ),
          SlidableAction(
            onPressed: (context) {
              // TODO: Implement delete functionality
            },
            backgroundColor: AppTheme.stopColor,
            foregroundColor: AppTheme.lightBackground,
            icon: Icons.delete,
            label: 'Delete',
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(0),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(0),
              bottomRight: Radius.circular(16),
            ),
          ),
        ],
      ),
      child: Container(
        width: 370,
        height: 103,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: AppTheme.lightCard,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
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
                color: AppTheme.lightSecondary.withValues(alpha: 0.15),
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
                          color: AppTheme.lightTextPrimary.withValues(alpha: 0.7),
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
      ),
    );
  }
}
