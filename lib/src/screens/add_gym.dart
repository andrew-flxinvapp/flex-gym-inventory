// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flex_gym_inventory/src/repositories/gym_repository.dart';
import 'package:flex_gym_inventory/src/models/ui_message.dart';
import '../widgets/snackbar.dart';
import '../../theme/app_theme.dart';
import '../widgets/top_app_bar.dart';
import '../widgets/inputs/text_input_field.dart';
import '../widgets/inputs/multiline_text_input.dart';
import '../widgets/inputs/date_input.dart';
import '../../theme/app_icons.dart';
import '../widgets/inputs/gym_id_display_field.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/buttons/secondary_button.dart';


class AddGymScreen extends StatefulWidget {
  const AddGymScreen({super.key});

  @override
  State<AddGymScreen> createState() => _AddGymScreenState();
}

class _AddGymScreenState extends State<AddGymScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for all input fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: TopAppBar(
        title: 'Add Gym',
        showBackArrow: true,
        showRightIcon: true,
        rightIcon: AppIcons.reset,
        onRightIconPressed: () {
          _formKey.currentState?.reset();
          setState(() {
            nameController.clear();
            locationController.clear();
            notesController.clear();
            selectedDate = null;
          });
        },
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              const SizedBox(height: 8),
              Text(
                'Enter Gym information below.',
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
              CustomTextInputField(
                hintText: 'Gym Name',
                showAsterisk: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Gym name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              CustomTextInputField(
                hintText: 'Location',
                showAsterisk: false,
              ),
              const SizedBox(height: 20),
              CustomMultilineTextInput(
                hintText: 'Gym Notes',
              ),
              const SizedBox(height: 20),
              CustomDateInput(
                hintText: 'Date Created',
                onDateChanged: (date) {
                  // Handle selected date if needed
                },
              ),
              const SizedBox(height: 24),
              GymIdDisplayField(gymId: 'GYM-0001'),
              const SizedBox(height: 32),
              PrimaryButton(
                label: 'Save',
                onPressed: () async {
                  if (!(_formKey.currentState?.validate() ?? false)) return;
                  final ctx = context;
                  try {
                    final user = Supabase.instance.client.auth.currentUser;
                    final userId = user?.id ?? 'local';
                    final gymId = 'GYM-${DateTime.now().millisecondsSinceEpoch}';
                    final repo = GymRepository();
                    final created = await repo.createGym(
                      gymId: gymId,
                      name: nameController.text.trim(),
                      userId: userId,
                      location: locationController.text.trim().isEmpty ? null : locationController.text.trim(),
                      gymNotes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                    );
                    if (!mounted) return;
                    showFlexSnackbarFromUiMessage(
                      ctx,
                      UiMessage('Gym saved', subtitle: 'Created ${created.name}', type: UiMessageType.success),
                    );
                    Navigator.of(ctx).pop(created);
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
    ));
  }
}
