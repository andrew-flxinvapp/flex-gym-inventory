import 'package:flutter/material.dart';
import '../widgets/top_app_bar.dart';
import '../../theme/app_theme.dart';
import 'package:isar/isar.dart';
import '../../service/export_service.dart';
import '../../service/isar_service.dart';
import 'package:flex_gym_inventory/src/models/gym_model.dart';
import '../widgets/selectors/export_selector.dart';
import '../widgets/buttons/primary_button.dart';

class ExportScreen extends StatelessWidget {
  const ExportScreen({Key? key}) : super(key: key);

  static const routeName = '/export';

  void _showMessage(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _exportCsv(BuildContext context) {
    _showMessage(context, 'Exporting CSV...');
    // TODO: implement CSV export
  }

  Future<void> _exportPdf(BuildContext context) async {
    _showMessage(context, 'Preparing export...');
    try {
      final isar = await IsarService.openIsar();
      final gyms = await isar.gyms.filter().nameEqualTo('Downtown Fitness').findAll();
      final gym = gyms.isNotEmpty ? gyms.first : null;
      if (gym == null) {
        _showMessage(context, 'Selected gym not found');
        return;
      }
      await ExportService.exportPdfAndShare(isar, gym.gymId, shareText: 'Exported ${gym.name} inventory');
    } catch (e) {
      _showMessage(context, 'Export failed: $e');
    }
  }

  void _shareExport(BuildContext context) {
    _showMessage(context, 'Preparing share...');
    // TODO: implement share functionality
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopAppBar(
        title: 'Export',
        showBackArrow: true,
      ),
      body: Padding(
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
            const SizedBox(height: 8),
            Text(
              'Choose the gym whose data you want to export.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTextPrimary,
                  ),
            ),
            const SizedBox(height: 12),
            Builder(builder: (context) {
              // Toggle this to false to show the empty state message.
              const bool hasGyms = true;

              if (!hasGyms) {
                return Text(
                  'Add a gym to use the export feature.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTextPrimary,
                      ),
                );
              }

              return ExportSelector(
                gymName: 'Downtown Fitness',
                itemCount: 123,
                selected: true,
                onChanged: (_) => _showMessage(context, 'Gym selection toggled'),
              );
            }),
            const SizedBox(height: 24),
            Center(
              child: PrimaryButton(
                label: 'Export PDF',
                onPressed: () => _exportPdf(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
