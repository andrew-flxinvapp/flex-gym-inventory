import '../widgets/inputs/dropdown_field.dart';
import '../widgets/snackbar.dart';
import 'package:flutter/material.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/buttons/secondary_button.dart';
import '../widgets/buttons/warning_button.dart';
import '../widgets/buttons/disabled_button.dart';
import '../widgets/top_app_bar.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_icons.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/dashboard_piechart.dart';
import '../widgets/inputs/text_input_field.dart';
import '../widgets/inputs/multiline_text_input.dart';
import '../widgets/inputs/date_input.dart';
import '../widgets/dashboard_gym_card.dart';
import '../widgets/cards/gym_stats_card.dart';
import '../widgets/cards/equipment_card.dart';
import '../widgets/cards/wishlist_item_card.dart';
import '../../enum/app_enums.dart';
import '../widgets/inputs/toggle_input.dart';
import '../widgets/inputs/gym_id_display_field.dart';

class ComponentGallery extends StatelessWidget {
  const ComponentGallery({super.key});

  @override
  Widget build(BuildContext context) {
    UpgradePriority? selectedPriority;
    return Material(
      color: AppTheme.lightBackground,
      child: Scaffold(
        backgroundColor: AppTheme.lightBackground,
        appBar: const TopAppBar(title: 'Component Gallery'),
        body: Scrollbar(
          thumbVisibility: true,
          child: StatefulBuilder(
            builder: (context, setState) => ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                const Text(
                  'Snackbars',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                  ),
                ),
                const SizedBox(height: 16),
                FlexSnackbar(
                  title: 'Success!',
                  subtitle: 'Your equipment was added.',
                  type: SnackbarType.success,
                  onClose: () {},
                ),
                const SizedBox(height: 16),
                FlexSnackbar(
                  title: 'Warning!',
                  subtitle: 'Check your equipment details.',
                  type: SnackbarType.warning,
                  onClose: () {},
                ),
                const SizedBox(height: 16),
                FlexSnackbar(
                  title: 'Update!',
                  subtitle: 'App features have been updated.',
                  type: SnackbarType.update,
                  onClose: () {},
                ),
                const SizedBox(height: 16),
                FlexSnackbar(
                  title: 'Stop!',
                  subtitle: 'Action not allowed.',
                  type: SnackbarType.stop,
                  onClose: () {},
                ),
                const SizedBox(height: 32),
              const Text(
                'Form Components',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Custom Text Input Field',
                style: TextStyle(fontFamily: 'Roboto'),
              ),
              const SizedBox(height: 8),
              CustomTextInputField(
                hintText: 'Field Name Here',
                showAsterisk: true,
              ),
              const SizedBox(height: 24),
              const Text(
                'Gym ID Display Field',
                style: TextStyle(fontFamily: 'Roboto'),
              ),
              const SizedBox(height: 8),
              GymIdDisplayField(gymId: 'GYM-0001'),
              const SizedBox(height: 24),
              const Text(
                'Custom Toggle Input',
                style: TextStyle(fontFamily: 'Roboto'),
              ),
              const SizedBox(height: 8),
              DemoToggleInput(),
              const SizedBox(height: 24),

              const Text(
                'Custom Dropdown Field',
                style: TextStyle(fontFamily: 'Roboto'),
              ),
              const SizedBox(height: 8),
              CustomDropdownField<UpgradePriority>(
                hintText: 'Upgrade Priority',
                items: UpgradePriority.values,
                value: selectedPriority,
                showAsterisk: true,
                getLabel: (item) => item.label,
                onChanged: (value) {
                  setState(() {
                    selectedPriority = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Custom Multiline Text Input',
                style: TextStyle(fontFamily: 'Roboto'),
              ),
              const SizedBox(height: 8),
              CustomMultilineTextInput(
                hintText: 'Multiline Field Here',
              ),
              const SizedBox(height: 24),
              const Text(
                'Custom Date Input',
                style: TextStyle(fontFamily: 'Roboto'),
              ),
              const SizedBox(height: 8),
              CustomDateInput(),
              const SizedBox(height: 32),
              const Text(
                'Buttons',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Primary Button',
                style: TextStyle(fontFamily: 'Roboto'),
              ),
              const SizedBox(height: 8),
              PrimaryButton(
                label: 'Primary',
                onPressed: () {},
              ),
              const SizedBox(height: 24),
              const Text(
                'Secondary Button',
                style: TextStyle(fontFamily: 'Roboto'),
              ),
              const SizedBox(height: 8),
              SecondaryButton(
                label: 'Secondary',
                onPressed: () {},
              ),
              const SizedBox(height: 24),
              const Text('Warning Button'),
              const SizedBox(height: 8),
              WarningButton(
                label: 'Warning',
                onPressed: () {},
              ),
              const SizedBox(height: 24),
              const Text('Disabled Button'),
              const SizedBox(height: 8),
              DisabledButton(
                label: 'Disabled',
                onPressed: () {},
              ),
              const SizedBox(height: 40),
              const Text(
                'Equipment Card',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                ),
              ),
              const SizedBox(height: 16),
              EquipmentCard(
                itemName: 'Rogue Ohio Bar',
                quantity: 2,
                value: 325.00,
              ),
              const SizedBox(height: 40),
              const Text(
                'Gym Stats Card',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                ),
              ),
              const SizedBox(height: 16),
              GymStatsCard(
                itemCount: 27,
                estimatedValue: 4200.00,
                lastUpdated: DateTime.now().subtract(const Duration(days: 1)),
              ),
              const SizedBox(height: 40),
              const Text(
                'App Bars',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                ),
              ),
              const SizedBox(height: 16),
              const Text('Title Only', style: TextStyle(fontFamily: 'Roboto')),
              const SizedBox(height: 8),
              PreferredSize(
                preferredSize: const Size.fromHeight(70),
                child: TopAppBar(title: 'Dashboard'),
              ),
              const SizedBox(height: 24),
              const Text('With Back Arrow', style: TextStyle(fontFamily: 'Roboto')),
              const SizedBox(height: 8),
              PreferredSize(
                preferredSize: const Size.fromHeight(70),
                child: TopAppBar(
                  title: 'Details',
                  showBackArrow: true,
                ),
              ),
              const SizedBox(height: 24),
              const Text('With Edit Icon', style: TextStyle(fontFamily: 'Roboto')),
              const SizedBox(height: 8),
              PreferredSize(
                preferredSize: const Size.fromHeight(70),
                child: TopAppBar(
                  title: 'Details',
                  showRightIcon: true,
                  rightIcon: AppIcons.edit,
                  onRightIconPressed: () {},
                ),
              ),
              const SizedBox(height: 24),
              const Text('With Back Arrow & Edit Icon', style: TextStyle(fontFamily: 'Roboto')),
              const SizedBox(height: 8),
              PreferredSize(
                preferredSize: const Size.fromHeight(70),
                child: TopAppBar(
                  title: 'Edit Gym',
                  showBackArrow: true,
                  showRightIcon: true,
                  rightIcon: AppIcons.edit,
                  onRightIconPressed: () {},
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Dashboard Gym Card',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                ),
              ),
              const SizedBox(height: 16),
              DashboardGymCard(
                gymName: 'Flex Home Gym',
                equipmentCount: 27,
                lastUpdated: DateTime.now().subtract(const Duration(days: 3)),
              ),
              const SizedBox(height: 40),
              const Text(
                'Dashboard Pie Chart',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                ),
              ),
              const SizedBox(height: 16),
              DashboardPieChart(
                categoryCounts: {
                  EquipmentCategory.implement: 5,
                  EquipmentCategory.weight: 8,
                  EquipmentCategory.machine: 3,
                  EquipmentCategory.rig: 2,
                  EquipmentCategory.other: 4,
                  EquipmentCategory.safety: 6,
                  EquipmentCategory.storage: 1,
                  EquipmentCategory.support: 2,
                },
              ),
              const SizedBox(height: 24),
              DashboardPieChart(
                categoryCounts: const {},
              ),
              const SizedBox(height: 40),
              const Text(
                'Wishlist Item Card',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                ),
              ),
              const SizedBox(height: 16),
              WishlistItemCard(
                itemName: 'Kabuki Trap Bar HD',
                brand: 'Kabuki Strength',
              ),
              const SizedBox(height: 40),
              // Add more components here as you build them!
            ],
          ),
        ),
        ),
        bottomNavigationBar: BottomNavigationBarModern(
          currentIndex: 0,
          onTap: (index) {},
        ),
      ),
    );
  }
}

class DemoToggleInput extends StatefulWidget {
  const DemoToggleInput({super.key});

  @override
  State<DemoToggleInput> createState() => _DemoToggleInputState();
}

class _DemoToggleInputState extends State<DemoToggleInput> {
  bool _value = false;

  @override
  Widget build(BuildContext context) {
    return ToggleInput(
      leftPlaceholder: 'Toggle Label',
      showAsterisk: true,
      rightLabel: 'Text:',
      value: _value,
      onChanged: (val) => setState(() => _value = val),
    );
  }
}