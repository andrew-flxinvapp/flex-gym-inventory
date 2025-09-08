import '../../theme/app_icons.dart';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../widgets/top_app_bar.dart';
import '../../src/widgets/bottom_navigation.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/dashboard_piechart.dart';
import '../../enum/app_enums.dart';
import '../widgets/cards/dashboard_gym_card.dart';
import 'package:flex_gym_inventory/routes/routes.dart';

/// DashboardScreen
/// 
/// This screen provides an overview of gym equipment breakdowns at a glance.
/// Follows MVVM architecture. Connect to a ViewModel for state management.
/// 
/// TODO: Connect to DashboardViewModel and implement Riverpod for state management.
/// TODO: Add responsive layout using size_config.dart.
/// TODO: Add modular widgets for dashboard cards and summaries.

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sampleCategoryCounts = {
      EquipmentCategory.implement: 5,
      EquipmentCategory.weight: 8,
      EquipmentCategory.machine: 2,
      EquipmentCategory.other: 3,
    };
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: TopAppBar(
        title: 'Dashboard',
        titleWidget: const Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: Text('Dashboard'),
        ),
        showBackArrow: false,
        rightWidget: Builder(
          builder: (context) => PopupMenuButton<DashboardMenuAction>(
            icon: SizedBox(
              width: 24,
              height: 24,
              child: Image.asset(
                AppIcons.plus,
                color: AppTheme.darkTextPrimary,
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Colors.white,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: DashboardMenuAction.addGym,
                child: Text('Add Gym', style: TextStyle(color: AppTheme.lightTextPrimary)),
              ),
              PopupMenuItem(
                value: DashboardMenuAction.addEquipment,
                child: Text('Add Equipment', style: TextStyle(color: AppTheme.lightTextPrimary)),
              ),
              PopupMenuItem(
                value: DashboardMenuAction.addWishlist,
                child: Text('Add Wishlist Item', style: TextStyle(color: AppTheme.lightTextPrimary)),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case DashboardMenuAction.addGym:
                  Navigator.of(context).pushNamed(AppRoutes.addGym);
                  break;
                case DashboardMenuAction.addEquipment:
                  Navigator.of(context).pushNamed(AppRoutes.addEquipment);
                  break;
                case DashboardMenuAction.addWishlist:
                  Navigator.of(context).pushNamed(AppRoutes.addWishlist);
                  break;
              }
            },
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
        child: SingleChildScrollView(
          controller: _scrollController,
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
              InkWell(
                onTap: () {
                  Navigator.of(context).pushNamed(AppRoutes.gymDetail);
                },
                borderRadius: BorderRadius.circular(16),
                child: DashboardGymCard(
                  gymName: 'Flex Home Gym',
                  equipmentCount: 27,
                  lastUpdated: DateTime.now().subtract(const Duration(days: 3)),
                ),
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: 'Add Gym',
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRoutes.addGym);
                },
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Component Gallery',
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRoutes.componentGallery);
                },
              ),
              const SizedBox(height: 24),
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