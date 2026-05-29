import 'package:flutter/material.dart';
import '../../theme/app_icons.dart';
import '../widgets/top_app_bar.dart';
import '../widgets/equipment/equipment_image.dart';
import 'package:flex_gym_inventory/routes/routes.dart';
import 'package:flex_gym_inventory/src/repositories/equipment_repository.dart';
import 'package:flex_gym_inventory/src/models/equipment_model.dart';
import 'package:flex_gym_inventory/enum/app_enums.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../widgets/cards/details_card.dart';
import '../widgets/cards/purchase_card.dart';
import '../widgets/cards/notes_card.dart';
import '../widgets/buttons/warning_button.dart';
import '../widgets/dialogs/confirm_dialog.dart';

class EquipmentDetailScreen extends StatefulWidget {
  const EquipmentDetailScreen({super.key});

  @override
  State<EquipmentDetailScreen> createState() => _EquipmentDetailScreenState();
}

class _EquipmentDetailScreenState extends State<EquipmentDetailScreen> {
  Equipment? equipment;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    // Delay to allow ModalRoute to be available
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadEquipment());
  }

  void _loadEquipment() async {
    final args = ModalRoute.of(context)?.settings.arguments;
    int? isarId;
    if (args is int) isarId = args;
    if (args is Map && args['isarId'] is int) isarId = args['isarId'] as int;
    if (isarId == null) {
      setState(() {
        error = 'No equipment id provided';
        isLoading = false;
      });
      return;
    }

    try {
      final repo = EquipmentRepository();
      final e = await repo.getByIsarId(isarId);
      if (!mounted) return;
      setState(() {
        equipment = e;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  String _calculateAgeFromDate(DateTime? date) {
    if (date == null) return '-';
    final now = DateTime.now();
    final duration = now.difference(date);
    final years = duration.inDays ~/ 365;
    final months = (duration.inDays % 365) ~/ 30;
    if (years > 0) {
      return months > 0 ? '$years yr $months mo' : '$years yr';
    } else {
      return '$months mo';
    }
  }

  Future<void> _deleteEquipment() async {
    if (equipment == null) return;
    final repo = EquipmentRepository();
    await repo.deleteEquipment(equipment!.id);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: TopAppBar(
          title: 'Equipment Detail',
          showBackArrow: true,
          showRightIcon: true,
          rightIcon: AppIcons.edit,
          onRightIconPressed: () {
            if (equipment?.id != null) {
              Navigator.of(context).pushNamed(AppRoutes.editEquipment, arguments: equipment!.id);
            }
          },
        ),
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : error != null
                ? Center(child: Text(error!))
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                          child: Text(
                            'Overview',
                            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                  color: AppTheme.lightTextPrimary,
                                ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: EquipmentImage(imageId: equipment?.imageId),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Text(
                            equipment?.name ?? '-',
                            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                  color: AppTheme.lightTextPrimary,
                                ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Text(
                            'Details',
                            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                  color: AppTheme.lightTextPrimary,
                                ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: DetailsCard(
                            details: [
                              MapEntry('Brand', equipment?.brand ?? '-'),
                              MapEntry('Model', equipment?.model ?? '-'),
                              MapEntry('Category', equipment?.category.label ?? '-'),
                              MapEntry('Training Style', equipment?.trainingStyle.label ?? '-'),
                              MapEntry('Quantity', (equipment?.quantity ?? 0).toString()),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Text(
                            'Purchase Info',
                            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                  color: AppTheme.lightTextPrimary,
                                ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: PurchaseCard(
                            details: [
                              MapEntry('Purchase Price', equipment?.value != null ? NumberFormat('#,##0.00').format(equipment!.value) : '-'),
                              MapEntry('Purchase Date', equipment?.purchaseDate != null ? DateFormat('yyyy-MM-dd').format(equipment!.purchaseDate!) : '-'),
                              MapEntry('Age', _calculateAgeFromDate(equipment?.purchaseDate)),
                              MapEntry('Condition', equipment?.condition.label ?? '-'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Text(
                            'Notes',
                            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                  color: AppTheme.lightTextPrimary,
                                ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: NotesCard(
                            notes: equipment?.maintenanceNotes ?? '-',
                          ),
                        ),
                        const SizedBox(height: 32),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: WarningButton(
                            label: 'Delete Item',
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => ConfirmDialog(
                                  title: 'Delete Equipment',
                                  content: 'Are you sure you want to delete this item? This action cannot be undone.',
                                  confirmText: 'Delete',
                                  onConfirm: () async {
                                    await _deleteEquipment();
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
      ),
    );
  }
}