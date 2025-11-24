import '../../theme/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import 'package:flex_gym_inventory/view_models/dashboard_view_model.dart';
import '../widgets/top_app_bar.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/dashboard_piechart.dart';
import '../../enum/app_enums.dart';
import '../widgets/cards/dashboard_gym_card.dart';
import 'package:flex_gym_inventory/routes/routes.dart';



class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {

  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardProvider);
    final categoryCounts = state.categoryCounts;
    final gyms = state.gyms;
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
      body: SafeArea(
        child: Padding(
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
              // TODO: When the app is live, ensure the pie chart receives an
              // empty/zeroed `categoryCounts` for brand-new users (no gyms)
              // so `DashboardPieChart` can render its built-in empty state.
              Center(
                child: DashboardPieChart(categoryCounts: categoryCounts),
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
                child: gyms.isNotEmpty
                    ? DashboardGymCard(
                        gymName: gyms[0].gymName,
                        equipmentCount: gyms[0].equipmentCount,
                        lastUpdated: gyms[0].lastUpdated,
                      )
                    : DashboardGymCard(
                        gymName: 'No gyms yet',
                        equipmentCount: 0,
                        lastUpdated: DateTime.now(),
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
      // bottomNavigationBar removed; now managed by HomeScreen
    ));
  }
}