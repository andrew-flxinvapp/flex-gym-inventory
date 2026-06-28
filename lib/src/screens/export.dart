import 'package:flutter/material.dart';
import '../widgets/top_app_bar.dart';
import '../../theme/app_theme.dart';
import 'package:isar/isar.dart';
import '../../service/export_service.dart';
import '../../service/isar_service.dart';
import 'package:flex_gym_inventory/src/models/gym_model.dart';
import 'package:flex_gym_inventory/src/models/equipment_model.dart';
import '../widgets/selectors/export_selector.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/snackbar.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({Key? key}) : super(key: key);

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
      final isar = await IsarService.openIsar();
      final gyms = await isar.gyms.where().findAll();
      final counts = await Future.wait<int>(
        gyms.map((g) => isar.equipments.filter().gymIdEqualTo(g.gymId).count()),
      );
      if (!mounted) return;
      setState(() {
        _gyms.clear();
        _gyms.addAll(gyms);
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
    showFlexSnackbar(
      context,
      title: 'Preparing export...',
      type: SnackbarType.success,
    );
    if (!mounted) return;
    setState(() => _exporting = true);
    try {
      final isar = await IsarService.openIsar();
      final gymId = _selectedGymId;
      if (gymId == null) {
        _showMessage('No gym selected');
        return;
      }
      final gym = (await isar.gyms.filter().gymIdEqualTo(gymId).findFirst());
      if (gym == null) {
        _showMessage('Selected gym not found');
        return;
      }
      await ExportService.exportPdfAndShare(
        isar,
        gym.gymId,
        shareText: 'Exported ${gym.name} inventory',
      );
    } catch (e) {
      _showMessage('Export failed: $e');
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
          padding: const EdgeInsets.all(16.0),
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
              if (_loading) const Center(child: CircularProgressIndicator()),
              if (!_loading && _gyms.isEmpty)
                Text(
                  'Add a gym to use the export feature.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTextPrimary,
                      ),
                ),
              if (!_loading && _gyms.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    itemCount: _gyms.length,
                    itemBuilder: (context, index) {
                      final g = _gyms[index];
                      return ExportSelector(
                        gymName: g.name,
                        itemCount: _counts[g.gymId] ?? 0,
                        selected: _selectedGymId == g.gymId,
                        onChanged: (_) => setState(() => _selectedGymId = g.gymId),
                      );
                    },
                  ),
                )
              else
                const SizedBox.shrink(),

              Center(
                child: PrimaryButton(
                  label: 'Export PDF',
                  onPressed: (_loading || _exporting) ? null : () => _exportPdf(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
