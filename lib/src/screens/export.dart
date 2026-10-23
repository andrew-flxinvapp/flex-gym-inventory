import 'package:flutter/material.dart';
import '../widgets/top_app_bar.dart';
import '../../theme/app_theme.dart';
import 'package:isar/isar.dart';
import '../../service/export_service.dart';
import '../../service/isar_service.dart';
import '../../service/supabase_service.dart';
import 'package:flex_gym_inventory/src/models/gym_model.dart';
import 'package:flex_gym_inventory/src/data/repositories/gym_repository.dart';
import 'package:flex_gym_inventory/src/data/repositories/equipment_repository.dart';
import '../widgets/selectors/export_selector.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/snackbar.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  static const routeName = '/export';

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  final List<Gym> _gyms = [];
  final Map<String, int> _counts = {};
  String? _selectedGymId;
  bool _loading = true;
  bool _exporting = false;

  void _showMessage(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _loadGyms() async {
    try {
      await IsarService.openIsar();
      final userId = SupabaseAuthService().currentUser?.id ?? 'local';
      final gymRepository = GymRepository();
      final equipmentRepository = EquipmentRepository();
      final gyms = await gymRepository.getAllForUser(userId);
      final counts = await Future.wait<int>(
        gyms.map((gym) async {
          final equipment = await equipmentRepository.getAllForGym(gym.gymId);
          return equipment.fold<int>(0, (total, item) => total + item.quantity);
        }),
      );
      if (!mounted) return;
      setState(() {
        _gyms.clear();
        _gyms.addAll(gyms);
        _counts.clear();
        for (var i = 0; i < gyms.length; i++) {
          _counts[gyms[i].gymId] = counts[i];
        }
        _selectedGymId = _gyms.isNotEmpty ? _gyms.first.gymId : null;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showMessage('Failed to load gyms: $e');
    }
  }

  Future<void> _exportPdf() async {
    if (!mounted) return;
    setState(() => _exporting = true);
    try {
      final isar = await IsarService.openIsar();
      final gymId = _selectedGymId;
      if (gymId == null) {
        _showMessage('No gym selected');
        return;
      }
      final userId = SupabaseAuthService().currentUser?.id ?? 'local';
      final gym =
          await isar.gyms
              .filter()
              .userIdEqualTo(userId)
              .and()
              .gymIdEqualTo(gymId)
              .findFirst();
      if (gym == null) {
        _showMessage('Selected gym is not available for this account');
        return;
      }
      await ExportService.exportPdfAndShare(
        isar,
        gym.gymId,
        userId: userId,
        shareText: 'Exported ${gym.name} inventory',
      );
      if (!mounted) return;
      showFlexSnackbar(
        context,
        title: 'Export complete',
        subtitle: 'Prepared ${gym.name} summary',
        type: SnackbarType.success,
      );
    } catch (e) {
      if (mounted) {
        showFlexSnackbar(
          context,
          title: 'Export failed',
          subtitle: e.toString(),
          type: SnackbarType.warning,
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadGyms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopAppBar(title: 'Export', showBackArrow: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Export your gym inventory',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Export a PDF summary of your gym inventory.\n'
                'Select which gym you want to export, then generate a shareable file you can save, print, or send.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Select a gym to export',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.lightTextPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child:
                    _loading
                        ? const Center(child: CircularProgressIndicator())
                        : _gyms.isEmpty
                        ? Text(
                          'Add a gym to use the export feature.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppTheme.lightTextPrimary),
                        )
                        : ListView.separated(
                          itemCount: _gyms.length,
                          itemBuilder: (context, index) {
                            final g = _gyms[index];
                            return ExportSelector(
                              gymName: g.name,
                              itemCount: _counts[g.gymId] ?? 0,
                              selected: _selectedGymId == g.gymId,
                              onChanged:
                                  (_) =>
                                      setState(() => _selectedGymId = g.gymId),
                            );
                          },
                          separatorBuilder:
                              (context, index) => const SizedBox(height: 16),
                        ),
              ),

              Center(
                child: PrimaryButton(
                  label: 'Export PDF',
                  onPressed:
                      (_loading || _exporting) ? null : () => _exportPdf(),
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
