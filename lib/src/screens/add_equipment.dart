// ignore_for_file: use_build_context_synchronously
import 'package:flex_gym_inventory/enum/app_enums.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flex_gym_inventory/src/repositories/equipment_repository.dart';
import 'package:flex_gym_inventory/src/repositories/gym_repository.dart';
import 'package:flex_gym_inventory/src/models/gym_model.dart';
import 'package:flex_gym_inventory/src/models/ui_message.dart';
import '../widgets/snackbar.dart';
import '../../theme/app_theme.dart';
import '../widgets/top_app_bar.dart';
import '../widgets/inputs/text_input_field.dart';
import '../widgets/inputs/multiline_text_input.dart';
import '../widgets/inputs/date_input.dart';
import '../widgets/inputs/image_input.dart';
import '../../theme/app_icons.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/buttons/secondary_button.dart';
import '../widgets/inputs/dropdown_field.dart';



class AddEquipmentScreen extends StatefulWidget {
  const AddEquipmentScreen({super.key});

  @override
  State<AddEquipmentScreen> createState() => _AddEquipmentScreenState();
}

class _AddEquipmentScreenState extends State<AddEquipmentScreen> {
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
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController serialController = TextEditingController();
  final TextEditingController maintenanceNotesController = TextEditingController();
  final TextEditingController valueController = TextEditingController();

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
        title: 'Add Equipment',
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
                  'Enter Equipment information below.',
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
                  controller: nameController,
                ),
                const SizedBox(height: 20),
                ImageInput(),
                const SizedBox(height: 20),
                CustomDropdownField<EquipmentCategory>(
                  hintText: 'Select Category',
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
                  controller: brandController,
                ),
                const SizedBox(height: 20),
                CustomTextInputField(
                  hintText: 'Model',
                  showAsterisk: true,
                  controller: modelController,
                ),
                const SizedBox(height: 20),
                CustomDropdownField<TrainingStyle>(
                  hintText: 'Select Training Style',
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
                CustomTextInputField(
                  hintText: 'Quantity',
                  showAsterisk: true,
                  controller: quantityController,
                ),
                const SizedBox(height: 20),
                CustomTextInputField(
                  hintText: 'Value',
                  showAsterisk: false,
                  controller: valueController,
                ),
                const SizedBox(height: 20),
                CustomDropdownField<EquipmentCondition>(
                  hintText: 'Select Condition',
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
                    selectedPurchaseDate = date;
                  },
                ),
                const SizedBox(height: 20),
                CustomTextInputField(
                  hintText: 'Serial Number',
                  showAsterisk: false,
                  controller: serialController,
                ),
                const SizedBox(height: 20),
                CustomMultilineTextInput(
                  hintText: 'Maintenance Notes',
                  maxLines: 5,
                  controller: maintenanceNotesController,
                ),
                const SizedBox(height: 32),
                PrimaryButton(
                  label: 'Save',
                  onPressed: () async {
                    if (!(_formKey.currentState?.validate() ?? false)) return;
                    try {
                      final repo = EquipmentRepository();
                      final qty = int.tryParse(quantityController.text) ?? 1;
                      final val = double.tryParse(valueController.text);
                      final gymId = selectedGym?.gymId ?? 'GYM-0001';

                      final created = await repo.createEquipment(
                        gymId: gymId,
                        name: nameController.text.trim(),
                        category: selectedCategory ?? EquipmentCategory.other,
                        brand: brandController.text.trim(),
                        model: modelController.text.trim(),
                        trainingStyle: selectedTrainingStyle ?? TrainingStyle.general,
                        quantity: qty,
                        condition: selectedCondition ?? EquipmentCondition.good,
                        purchaseDate: selectedPurchaseDate,
                        value: val,
                        serialNumber: serialController.text.trim().isEmpty ? null : serialController.text.trim(),
                        maintenanceNotes: maintenanceNotesController.text.trim().isEmpty ? null : maintenanceNotesController.text.trim(),
                      );

                      showFlexSnackbarFromUiMessage(
                        context,
                        UiMessage('Equipment saved', subtitle: 'Created ${created.name}', type: UiMessageType.success),
                      );
                      Navigator.of(context).pop(created);
                    } catch (e) {
                      showFlexSnackbarFromUiMessage(
                        context,
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
