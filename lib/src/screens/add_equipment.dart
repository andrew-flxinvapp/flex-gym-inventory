import 'package:flex_gym_inventory/enum/app_enums.dart';
import 'package:flex_gym_inventory/src/widgets/inputs/toggle_input.dart';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../widgets/top_app_bar.dart';
import '../widgets/inputs/text_input_field.dart';
import '../widgets/inputs/multiline_text_input.dart';
import '../widgets/inputs/date_input.dart';
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
  String? selectedGym;
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
      body: SingleChildScrollView(
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
                CustomDropdownField<String>(
                  hintText: 'Select Gym',
                  items: const ['Flex Home Gym', 'Garage Gym', 'Studio Gym'], // TODO: Replace with dynamic gym list
                  value: selectedGym,
                  showAsterisk: true,
                  getLabel: (item) => item,
                  onChanged: (value) {
                    setState(() {
                      selectedGym = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
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
                  onPressed: () {
                    // TODO: Implement save logic
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
    );
  }
}
