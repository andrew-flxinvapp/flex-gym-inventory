import 'package:flex_gym_inventory/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flex_gym_inventory/src/screens/equipment_detail.dart';
import '../../../theme/app_theme.dart';

class EquipmentCard extends StatelessWidget {
  final String itemName;
  final int quantity;
  final double value;

  const EquipmentCard({
    super.key,
    required this.itemName,
    required this.quantity,
    required this.value,
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
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const EquipmentDetailScreen(),
            ),
          );
        },
        child: Container(
          width: 370,
          height: 94,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                itemName,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'QTY:',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightPrimary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    quantity.toString(),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.lightTextPrimary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Value:',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightPrimary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '\$${value.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.lightTextPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
