import '../../theme/app_icons.dart';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../widgets/top_app_bar.dart';
import '../../src/widgets/bottom_navigation.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/dashboard_piechart.dart';
import '../../enum/app_enums.dart';
import '../widgets/dashboard_gym_card.dart';

/// DashboardScreen
/// 
/// This screen provides an overview of gym equipment breakdowns at a glance.
/// Follows MVVM architecture. Connect to a ViewModel for state management.
/// 
/// TODO: Connect to DashboardViewModel and implement Riverpod for state management.
/// TODO: Add responsive layout using size_config.dart.
/// TODO: Add modular widgets for dashboard cards and summaries.

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample data for demonstration
    final sampleCategoryCounts = {
      EquipmentCategory.cardio: 5,
      EquipmentCategory.barbell: 8,
      EquipmentCategory.dumbbell: 2,
      EquipmentCategory.accessory: 3,
    };
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: TopAppBar(
        title: 'Dashboard',
        showBackArrow: false,
        showRightIcon: true,
        rightIcon: AppIcons.plus,
        onRightIconPressed: () {
          // TODO: Add action for plus icon
        },
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Equipment Breakdown',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: AppTheme.lightTextPrimary,
                      ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: DashboardPieChart(categoryCounts: sampleCategoryCounts),
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'My Gyms',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: AppTheme.lightTextPrimary,
                      ),
                ),
              ),
              const SizedBox(height: 16),
              DashboardGymCard(
                gymName: 'Flex Home Gym',
                equipmentCount: 27,
                lastUpdated: DateTime.now().subtract(const Duration(days: 3)),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Component Gallery',
                onPressed: () {
                  Navigator.of(context).pushNamed('/component-gallery');
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBarModern(
        currentIndex: 0,
        onTap: (index) {},
      ),
    );
  }
}