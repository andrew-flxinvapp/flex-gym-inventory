import '../../theme/app_theme.dart';
import '../widgets/buttons/secondary_button.dart';
import '../widgets/buttons/warning_button.dart';
import '../widgets/dialogs/confirm_dialog.dart';
import '../widgets/cards/gym_stats_card.dart';
import '../widgets/cards/equipment_card.dart';
import 'package:flutter/material.dart';
import 'package:flex_gym_inventory/theme/app_icons.dart';
import '../widgets/top_app_bar.dart';
import 'package:flex_gym_inventory/routes/routes.dart';
import 'package:flex_gym_inventory/service/active_gym_service.dart';
import 'package:flex_gym_inventory/service/isar_service.dart';
import 'package:flex_gym_inventory/src/repositories/equipment_repository.dart';
import 'package:flex_gym_inventory/src/repositories/gym_repository.dart';
import '../widgets/buttons/primary_button.dart';
import 'package:flex_gym_inventory/src/models/equipment_model.dart';
import 'package:flex_gym_inventory/src/models/gym_model.dart';

class GymDetailScreen extends StatefulWidget {
  const GymDetailScreen({super.key});

  @override
  State<GymDetailScreen> createState() => _GymDetailScreenState();
}

class _GymDetailScreenState extends State<GymDetailScreen> {
  Future<Map<String, dynamic>> _fetchData() async {
    final service = ActiveGymService(IsarService.isar);
    final gym = await service.getActiveGym();
    if (gym == null) {
      return {'gym': null, 'items': <Equipment>[]};
    }
    final repo = EquipmentRepository();
    final items = await repo.getAllForGym(gym.gymId);
    return {'gym': gym, 'items': items};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopAppBar(
        title: 'Gym Details',
        showBackArrow: true,
        showRightIcon: true,
        rightIcon: AppIcons.edit,
        onRightIconPressed: () async {
          // Navigate to edit with current gym's Isar id if available
          final service = ActiveGymService(IsarService.isar);
          final gym = await service.getActiveGym();
          if (gym != null) {
            Navigator.of(context).pushNamed(AppRoutes.editGym, arguments: gym.id);
          } else {
            Navigator.of(context).pushNamed(AppRoutes.editGym);
          }
        },
      ),
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _fetchData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final gym = snapshot.data?['gym'] as Gym?;
            final items = snapshot.data?['items'] as List<Equipment>? ?? [];

            if (gym == null) {
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
                        "No gym selected.",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.lightTextPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            if (items.isEmpty) {
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
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.lightTextPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      SecondaryButton(
                        label: 'Add Equipment',
                        onPressed: () {
                          Navigator.of(context).pushNamed(AppRoutes.addEquipment).then((_) => setState(() {}));
                        },
                      ),
                    ],
                  ),
                ),
              );
            }

            // Filled state
            final int itemCount = items.fold<int>(0, (acc, e) => acc + e.quantity);
            final double estimatedValue = items.fold<double>(0, (acc, e) => acc + (e.value ?? 0) * e.quantity);
            final DateTime lastUpdated = items.map((e) => e.createdDate).whereType<DateTime>().fold<DateTime?>(null, (prev, d) => prev == null || d.isAfter(prev) ? d : prev) ?? gym.createdDate;

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
                    estimatedValue: estimatedValue,
                    lastUpdated: lastUpdated,
                  ),
                  const SizedBox(height: 32),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          'Equipment List',
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: AppTheme.lightTextPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Image.asset(AppIcons.plus, height: 22, width: 22),
                        onPressed: () {
                          Navigator.of(context).pushNamed(AppRoutes.addEquipment).then((_) => setState(() {}));
                        },
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                  const SizedBox(height: 16),
                  for (final e in items) ...[
                    EquipmentCard(
                      brand: e.brand,
                      itemName: e.name,
                      quantity: e.quantity,
                      category: e.category,
                      isarId: e.id,
                      onTapCallback: () async {
                        await Navigator.of(context).pushNamed(AppRoutes.equipmentDetail, arguments: e.id);
                        if (mounted) setState(() {});
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                  const SizedBox(height: 8),
                      WarningButton(
                        label: 'Delete Gym',
                        onPressed: () {
                          Future<void> deleteAction() async {
                            final service = ActiveGymService(IsarService.isar);
                            final gym = await service.getActiveGym();
                            if (gym != null) {
                              final repo = GymRepository();
                              await repo.deleteGym(gym.id);
                              await service.clearActiveGym();
                            }
                            if (!mounted) return;
                            Navigator.of(context).popUntil((route) => route.isFirst);
                          }

                          showDialog(
                            context: context,
                            builder: (ctx) => ConfirmDialog(
                              title: 'Delete Gym',
                              content: 'Are you sure you want to delete this gym and all its equipment?',
                              confirmText: 'Delete',
                              cancelText: 'Cancel',
                              onConfirm: () async {
                                await deleteAction();
                              },
                            ),
                          );
                        },
                      ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}


