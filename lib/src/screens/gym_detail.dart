import '../../theme/app_theme.dart';
import '../widgets/buttons/secondary_button.dart';
import '../widgets/cards/gym_stats_card.dart';
import '../widgets/cards/equipment_card.dart';
import 'package:flutter/material.dart';
import 'package:flex_gym_inventory/theme/app_icons.dart';
import '../widgets/top_app_bar.dart';

class GymDetailScreen extends StatelessWidget {
  const GymDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopAppBar(
        title: 'Gym Details',
        showBackArrow: true,
        showRightIcon: true,
        rightIcon: AppIcons.edit,
        onRightIconPressed: () {
          // TODO: Implement edit action
        },
      ),
      body: Builder(
        builder: (context) {
          // TODO: Replace with real itemCount from database
          final int itemCount = 27; // Change to >0 to test filled state
          if (itemCount == 0) {
            // Empty State
            return Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'lib/assets/images/empty_gym.png',
                      height: 350,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Looks like your gym is empty.",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.lightTextPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Add equipment below',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTextPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    SecondaryButton(
                      label: 'Add Equipment',
                      onPressed: () {
                        // TODO: Implement add equipment action
                      },
                    ),
                  ],
                ),
              ),
            );
          } else {
            // Filled State
            return Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Text(
                    'Overview',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppTheme.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GymStatsCard(
                    itemCount: itemCount,
                    estimatedValue: 4200.00,
                    lastUpdated: DateTime.now().subtract(const Duration(days: 1)),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Equipment List',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppTheme.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  EquipmentCard(
                    itemName: 'Rogue Ohio Bar',
                    quantity: 2,
                    value: 325.00,
                  ),
                  const SizedBox(height: 16),
                  EquipmentCard(
                    itemName: 'Rep PR-4000 Rack',
                    quantity: 1,
                    value: 1200.00,
                  ),
                  const SizedBox(height: 16),
                  EquipmentCard(
                    itemName: 'Kabuki Strength Plates',
                    quantity: 8,
                    value: 800.00,
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}


