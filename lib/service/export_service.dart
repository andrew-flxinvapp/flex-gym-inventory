import 'dart:io';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path/path.dart' as p;
import '../src/models/gym_model.dart';
import '../src/models/equipment_model.dart';

/// Service for exporting and importing Isar database data.
class ExportService {
  /// Export the Isar database to a backup file (e.g., for user download or cloud backup).
  static Future<File> exportIsarBackup(
    Isar isar, {
    String fileName = 'isar_backup.isar',
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final backupFile = File('${dir.path}/$fileName');
    await isar.copyToFile(backupFile.path);
    return backupFile;
  }

  /// Generate a PDF summary for a gym and save it to disk.
  static Future<File> exportPdfSummary(
    Isar isar,
    String gymId, {
    String? fileName,
  }) async {
    // Query gym and its equipment
    final gym = await isar.gyms.filter().gymIdEqualTo(gymId).findFirst();
    final equipments =
        await isar.equipments.filter().gymIdEqualTo(gymId).findAll();

    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        build: (pw.Context context) {
          return [
            pw.Header(level: 0, child: pw.Text(gym?.name ?? 'Gym Summary')),
            pw.Text('Location: ${gym?.location ?? '—'}'),
            pw.SizedBox(height: 8),
            pw.Text('Generated: ${DateTime.now()}'),
            pw.SizedBox(height: 12),
            pw.Text(
              'Equipment',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            pw.TableHelper.fromTextArray(
              context: context,
              headers: ['Name', 'Qty', 'Condition', 'Value'],
              data:
                  equipments.map((e) {
                    return [
                      e.name,
                      e.quantity.toString(),
                      e.condition.toString().split('.').last,
                      e.value?.toStringAsFixed(2) ?? '-',
                    ];
                  }).toList(),
            ),
          ];
        },
      ),
    );

    final bytes = await doc.save();
    final dir = await getApplicationDocumentsDirectory();
    // Use the gym name in the filename when available. Sanitize to remove
    // unsafe characters and replace spaces with underscores.
    final rawName = gym?.name ?? gymId;
    final safeBase = rawName
      .replaceAll(RegExp(r'[^A-Za-z0-9 _-]'), '')
      .replaceAll(RegExp(r'\s+'), '_');
    final outName = fileName ?? '${safeBase}_summary.pdf';
    final outFile = File(p.join(dir.path, outName));
    await outFile.writeAsBytes(bytes);
    return outFile;
  }

  /// Generate and share a PDF summary for a gym.
  static Future<void> exportPdfAndShare(
    Isar isar,
    String gymId, {
    String? fileName,
    String? shareText,
  }) async {
    final file = await exportPdfSummary(isar, gymId, fileName: fileName);
    final bytes = await file.readAsBytes();
    final filename = p.basename(file.path);
    await Printing.sharePdf(bytes: bytes, filename: filename);
  }

  /// Import an Isar backup file (overwrites current database).
  static Future<void> importIsarBackup(Isar isar, File backupFile) async {
    // Note: Isar does not support direct import/restore, so you may need to handle this manually.
    // This is a placeholder for custom import logic.
    // You could read the backup file and manually insert data into the current Isar instance.
    throw UnimplementedError(
      'Import functionality must be implemented based on your data model.',
    );
  }
}
