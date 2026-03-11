import 'package:flex_gym_inventory/src/widgets/inputs/toggle_input.dart';
import 'package:flex_gym_inventory/enum/app_enums.dart';
import 'package:flutter/material.dart';
// ignore_for_file: use_build_context_synchronously
import 'package:flex_gym_inventory/src/repositories/equipment_repository.dart';
import 'package:flex_gym_inventory/src/models/ui_message.dart';
import 'package:flex_gym_inventory/src/repositories/gym_repository.dart';
import 'package:flex_gym_inventory/src/models/gym_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/snackbar.dart';
import '../../theme/app_theme.dart';
import '../widgets/top_app_bar.dart';
import '../widgets/inputs/text_input_field.dart';
import '../widgets/inputs/multiline_text_input.dart';
import '../widgets/inputs/date_input.dart';
import '../../theme/app_icons.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/buttons/secondary_button.dart';
import '../widgets/inputs/dropdown_field.dart';


class EditEquipmentScreen extends StatefulWidget {
  const EditEquipmentScreen({super.key});

  @override
  State<EditEquipmentScreen> createState() => _EditEquipmentScreenState();
}

class _EditEquipmentScreenState extends State<EditEquipmentScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for all input fields
  Gym? selectedGym;
  List<Gym> gyms = [];
  EquipmentCategory? selectedCategory;
  TrainingStyle? selectedTrainingStyle;
  EquipmentCondition? selectedCondition;
  DateTime? selectedPurchaseDate;
  bool isPair = false;
  bool isEstimateValue = false;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController brandController = TextEditingController();
  final TextEditingController modelController = TextEditingController();
  final TextEditingController serialController = TextEditingController();
  final TextEditingController maintenanceNotesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadGyms();
  }

  Future<void> _loadGyms() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      final userId = user?.id ?? 'local';
      final repo = GymRepository();
      final list = await repo.getAllForUser(userId);
      setState(() {
        gyms = list;
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: TopAppBar(
        title: 'Edit Equipment',
        showBackArrow: true,
        showRightIcon: true,
        rightIcon: AppIcons.reset,
        onRightIconPressed: () {
          _formKey.currentState?.reset();
          setState(() {
            selectedGym = null;
            selectedCategory = null;
            selectedTrainingStyle = null;
            selectedCondition = null;
            selectedPurchaseDate = null;
            isPair = false;
            isEstimateValue = false;
            nameController.clear();
            brandController.clear();
            modelController.clear();
            serialController.clear();
            maintenanceNotesController.clear();
          });
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                const SizedBox(height: 8),
                Text(
                  'Edit Equipment information below.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppTheme.lightTextPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '*',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.stopColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Required field',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTextPrimary,
                      ),
                    ),
                  ],
                ),
                // ...existing code...
                const SizedBox(height: 16),
                CustomDropdownField<Gym>(
                  hintText: 'Select Gym',
                  items: gyms,
                  value: selectedGym,
                  showAsterisk: true,
                  getLabel: (item) => item.name,
                  onChanged: (value) {
                    setState(() {
                      selectedGym = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Gym selection is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                CustomTextInputField(
                  hintText: 'Name',
                  showAsterisk: true,
                ),
                const SizedBox(height: 20),
                CustomDropdownField<EquipmentCategory>(
                  hintText: 'Category',
                  items: EquipmentCategory.values,
                  value: selectedCategory,
                  showAsterisk: true,
                  getLabel: (item) => item.label,
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Category selection is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                CustomTextInputField(
                  hintText: 'Brand',
                  showAsterisk: true,
                ),
                const SizedBox(height: 20),
                CustomTextInputField(
                  hintText: 'Model',
                  showAsterisk: true,
                ),
                const SizedBox(height: 20),
                CustomDropdownField<TrainingStyle>(
                  hintText: 'Training Style',
                  items: TrainingStyle.values,
                  value: selectedTrainingStyle,
                  showAsterisk: true,
                  getLabel: (item) => item.label,
                  onChanged: (value) {
                    setState(() {
                      selectedTrainingStyle = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Training style selection is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ToggleInput(
                  leftPlaceholder: 'Quantity',
                  showAsterisk: true,
                  rightLabel: 'Pair:',
                  value: false, // TODO: Connect to state
                  onChanged: (val) {
                    // TODO: Handle toggle change
                  },
                ),
                const SizedBox(height: 20),
                CustomDropdownField<EquipmentCondition>(
                  hintText: 'Condition',
                  items: EquipmentCondition.values,
                  value: selectedCondition,
                  showAsterisk: true,
                  getLabel: (item) => item.label,
                  onChanged: (value) {
                    setState(() {
                      selectedCondition = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Condition selection is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                CustomDateInput(
                  hintText: 'Purchase Date',
                  onDateChanged: (date) {
                    // Handle selected date if needed
                  },
                ),
                const SizedBox(height: 20),
                ToggleInput(
                  leftPlaceholder: 'Value',
                  showAsterisk: false,
                  rightLabel: 'Estimate:',
                  value: false, // TODO: Connect to state
                  onChanged: (val) {
                    // TODO: Handle toggle change
                  },
                ),
                const SizedBox(height: 20),
                CustomTextInputField(
                  hintText: 'Serial Number',
                  showAsterisk: false,
                ),
                const SizedBox(height: 20),
                CustomMultilineTextInput(
                  hintText: 'Maintenance Notes',
                  maxLines: 3,
                ),
                const SizedBox(height: 32),
                PrimaryButton(
                  label: 'Save',
                  onPressed: () async {
                    if (!(_formKey.currentState?.validate() ?? false)) return;
                    final ctx = context;
                    try {
                      final repo = EquipmentRepository();

                      // Try to detect an existing Isar id from route args
                      final args = ModalRoute.of(ctx)?.settings.arguments;
                      int? isarId;
                      if (args is int) isarId = args;
                      if (args is Map && args['isarId'] is int) isarId = args['isarId'] as int;

                      if (isarId != null) {
                        final updated = await repo.updateEquipment(
                          id: isarId,
                          name: nameController.text.trim().isEmpty ? null : nameController.text.trim(),
                          category: selectedCategory,
                          brand: brandController.text.trim().isEmpty ? null : brandController.text.trim(),
                          model: modelController.text.trim().isEmpty ? null : modelController.text.trim(),
                          trainingStyle: selectedTrainingStyle,
                          quantity: null,
                          condition: selectedCondition,
                          purchaseDate: selectedPurchaseDate,
                          value: null,
                          isPair: null,
                          isEstimate: null,
                          serialNumber: serialController.text.trim().isEmpty ? null : serialController.text.trim(),
                          maintenanceNotes: maintenanceNotesController.text.trim().isEmpty ? null : maintenanceNotesController.text.trim(),
                        );
                        if (!mounted) return;
                        showFlexSnackbarFromUiMessage(
                          ctx,
                          UiMessage('Equipment updated', subtitle: 'Updated ${updated?.name ?? ''}', type: UiMessageType.success),
                        );
                        Navigator.of(ctx).pop(updated);
                      } else {
                        // Create new equipment (best-effort defaults)
                        final gymId = selectedGym?.gymId ?? 'GYM-0001';
                        final created = await repo.createEquipment(
                          gymId: gymId,
                          name: nameController.text.trim(),
                          category: selectedCategory ?? EquipmentCategory.other,
                          brand: brandController.text.trim(),
                          model: modelController.text.trim(),
                          trainingStyle: selectedTrainingStyle ?? TrainingStyle.general,
                          quantity: 1,
                          condition: selectedCondition ?? EquipmentCondition.good,
                        );
                        if (!mounted) return;
                        showFlexSnackbarFromUiMessage(
                          ctx,
                          UiMessage('Equipment saved', subtitle: 'Created ${created.name}', type: UiMessageType.success),
                        );
                        Navigator.of(ctx).pop(created);
                      }
                    } catch (e) {
                      if (!mounted) return;
                      showFlexSnackbarFromUiMessage(
                        ctx,
                        UiMessage('Save failed', subtitle: e.toString(), type: UiMessageType.error),
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),
                SecondaryButton(
                  label: 'Cancel',
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}
