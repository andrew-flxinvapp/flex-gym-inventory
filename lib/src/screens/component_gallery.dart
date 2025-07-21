import 'package:flutter/material.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/buttons/secondary_button.dart';
import '../widgets/buttons/warning_button.dart';
import '../widgets/buttons/disabled_button.dart';
import '../widgets/top_app_bar.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_icons.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/dashboard_piechart.dart';
import '../widgets/dashboard_gym_card.dart';
import '../../enum/app_enums.dart';

class ComponentGallery extends StatelessWidget {
  const ComponentGallery({super.key});

  @override
  Widget build(BuildContext context) {
    // Use the standard Flutter Scaffold
    return Material(
      color: AppTheme.lightBackground,
      child: Scaffold(
        backgroundColor: AppTheme.lightBackground,
        appBar: const TopAppBar(title: 'Component Gallery'),
        body: Scrollbar(
          thumbVisibility: true,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              const Text(
                'Buttons',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Primary Button',
                style: TextStyle(fontFamily: 'Roboto'),
              ),
              const SizedBox(height: 8),
              PrimaryButton(
                label: 'Primary',
                onPressed: () {},
              ),
              const SizedBox(height: 24),
              const Text(
                'Secondary Button',
                style: TextStyle(fontFamily: 'Roboto'),
              ),
              const SizedBox(height: 8),
              SecondaryButton(
                label: 'Secondary',
                onPressed: () {},
              ),
              const SizedBox(height: 24),
              const Text('Warning Button'),
              const SizedBox(height: 8),
              WarningButton(
                label: 'Warning',
                onPressed: () {},
              ),
              const SizedBox(height: 24),
              const Text('Disabled Button'),
              const SizedBox(height: 8),
              DisabledButton(
                label: 'Disabled',
                onPressed: () {},
              ),
              const SizedBox(height: 40),
              const Text(
                'App Bars',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                ),
              ),
              const SizedBox(height: 16),
              const Text('Title Only', style: TextStyle(fontFamily: 'Roboto')),
              const SizedBox(height: 8),
              PreferredSize(
                preferredSize: const Size.fromHeight(70),
                child: TopAppBar(title: 'Dashboard'),
              ),
              const SizedBox(height: 24),
              const Text('With Back Arrow', style: TextStyle(fontFamily: 'Roboto')),
              const SizedBox(height: 8),
              PreferredSize(
                preferredSize: const Size.fromHeight(70),
                child: TopAppBar(
                  title: 'Details',
                  showBackArrow: true,
                ),
              ),
              const SizedBox(height: 24),
              const Text('With Edit Icon', style: TextStyle(fontFamily: 'Roboto')),
              const SizedBox(height: 8),
              PreferredSize(
                preferredSize: const Size.fromHeight(70),
                child: TopAppBar(
                  title: 'Details',
                  showRightIcon: true,
                  rightIcon: AppIcons.edit,
                  onRightIconPressed: () {},
                ),
              ),
              const SizedBox(height: 24),
              const Text('With Back Arrow & Edit Icon', style: TextStyle(fontFamily: 'Roboto')),
              const SizedBox(height: 8),
              PreferredSize(
                preferredSize: const Size.fromHeight(70),
                child: TopAppBar(
                  title: 'Edit Gym',
                  showBackArrow: true,
                  showRightIcon: true,
                  rightIcon: AppIcons.edit,
                  onRightIconPressed: () {},
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Dashboard Gym Card',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                ),
              ),
              const SizedBox(height: 16),
              DashboardGymCard(
                gymName: 'Flex Home Gym',
                equipmentCount: 27,
                lastUpdated: DateTime.now().subtract(const Duration(days: 3)),
              ),
              const SizedBox(height: 40),
              const Text(
                'Dashboard Pie Chart',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                ),
              ),
              const SizedBox(height: 16),
              DashboardPieChart(
                categoryCounts: {
                  EquipmentCategory.implement: 5,
                  EquipmentCategory.weight: 8,
                  EquipmentCategory.machine: 3,
                  EquipmentCategory.rig: 2,
                  EquipmentCategory.other: 4,
                  EquipmentCategory.safety: 6,
                  EquipmentCategory.storage: 1,
                  EquipmentCategory.support: 2,
                },
              ),
              const SizedBox(height: 40),
              // Add more components here as you build them!
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBarModern(
          currentIndex: 0,
          onTap: (index) {},
        ),
      ),
    );
  }
}