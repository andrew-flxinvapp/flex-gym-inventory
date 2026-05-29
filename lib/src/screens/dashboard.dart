import '../../theme/app_icons.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/foundation.dart';
// import '../widgets/snackbar.dart';
// import 'package:flex_gym_inventory/src/models/ui_message.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import 'package:flex_gym_inventory/view_models/dashboard_view_model.dart';
import 'package:flex_gym_inventory/service/active_gym_service.dart';
import 'package:flex_gym_inventory/service/isar_service.dart';
import '../widgets/top_app_bar.dart';
import '../widgets/dialogs/confirm_dialog.dart';
import 'package:flex_gym_inventory/src/repositories/gym_repository.dart';
import '../widgets/buttons/primary_button.dart';
//import '../widgets/dashboard_piechart.dart';
import '../widgets/dashboard_arc_chart.dart';
import '../../enum/app_enums.dart';
import '../widgets/cards/dashboard_gym_card.dart';
import 'package:flex_gym_inventory/routes/routes.dart';



class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with WidgetsBindingObserver {

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // When the app resumes from background, refresh the dashboard data.
      ref.read(dashboardProvider.notifier).refresh();
    }
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
            onSelected: (value) async {
              switch (value) {
                case DashboardMenuAction.addGym:
                  await Navigator.of(context).pushNamed(AppRoutes.addGym);
                  await ref.read(dashboardProvider.notifier).refresh();
                  break;
                case DashboardMenuAction.addEquipment:
                  await Navigator.of(context).pushNamed(AppRoutes.addEquipment);
                  await ref.read(dashboardProvider.notifier).refresh();
                  break;
                case DashboardMenuAction.addWishlist:
                  await Navigator.of(context).pushNamed(AppRoutes.addWishlist);
                  await ref.read(dashboardProvider.notifier).refresh();
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
              Center(
                child: DashboardArcChart(categoryCounts: categoryCounts),
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
              if (gyms.isNotEmpty)
                InkWell(
                  onTap: () async {
                    final service = ActiveGymService(IsarService.isar);
                    await service.setActiveGymId(gyms[0].gymId);
                    Navigator.of(context).pushNamed(AppRoutes.gymDetail);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: DashboardGymCard(
                      gymName: gyms[0].gymName,
                      equipmentCount: gyms[0].equipmentCount,
                      lastUpdated: gyms[0].lastUpdated,
                      onDelete: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => ConfirmDialog(
                            title: 'Delete Gym',
                            content: 'Are you sure you want to delete this gym and all its equipment?',
                            confirmText: 'Delete',
                            onConfirm: () async {
                              // Resolve gym by gymId then delete
                              final repo = GymRepository();
                              final g = await repo.getByGymId(gyms[0].gymId);
                              if (g != null) {
                                await repo.deleteGym(g.id);
                              }
                              await ref.read(dashboardProvider.notifier).refresh();
                            },
                          ),
                        );
                      },
                    ),
                ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: 'Add Gym',
                onPressed: () async {
                  await Navigator.of(context).pushNamed(AppRoutes.addGym);
                  await ref.read(dashboardProvider.notifier).refresh();
                },
              ),
              /*const SizedBox(height: 24),
              PrimaryButton(
                label: 'Component Gallery',
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRoutes.componentGallery);
                },
              ),
              const SizedBox(height: 24),
              if (kDebugMode) ...[ //REMOVE IN PRODUCTION
                PrimaryButton(
                  label: 'Show Test Snackbar',
                  onPressed: () {
                    showFlexSnackbarFromUiMessage(
                      context,
                      UiMessage('Test Success', subtitle: 'This is a demo', type: UiMessageType.success),
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
              */
            ],
          ),
        ),
      ),
      // bottomNavigationBar removed; now managed by HomeScreen
    ));
  }
}