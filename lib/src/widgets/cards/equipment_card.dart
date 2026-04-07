import 'package:flex_gym_inventory/routes/routes.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flex_gym_inventory/src/screens/equipment_detail.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/app_icons.dart';
import '../../../enum/app_enums.dart';
import 'base_card.dart';

class EquipmentCard extends StatelessWidget {
  final String itemName;
  final int quantity;
  final EquipmentCategory category;
  final String brand;

  const EquipmentCard({
    super.key,
    required this.itemName,
    required this.quantity,
    required this.category,
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
              Navigator.of(context).pushNamed(AppRoutes.editEquipment);
            },
            backgroundColor: AppTheme.updateColor,
            foregroundColor: AppTheme.lightBackground,
            icon: Icons.edit,
            label: 'Edit',
            borderRadius: BorderRadius.only(
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
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(0),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(0),
              bottomRight: Radius.circular(16),
            ),
          ),
        ],
      ),
      child: BaseCard(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const EquipmentDetailScreen(),
            ),
          );
        },
        body: Row(
          children: [
            // Image block
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppTheme.lightBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.dividers),
              ),
            ),
            const SizedBox(width: 12),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    brand,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.dividers,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    itemName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTextPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        category.label,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                              'Qty:',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.lightTextPrimary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              quantity.toString(),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.lightTextPrimary,
                              ),
                            ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 24,
              height: 24,
              child: Image.asset(
                AppIcons.forward,
                color: AppTheme.dividers,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
