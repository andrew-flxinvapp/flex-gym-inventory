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
import '../widgets/inputs/date_display_filed.dart';
import '../widgets/inputs/gym_id_display_field.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/buttons/secondary_button.dart';


class EditGymScreen extends StatefulWidget {
  const EditGymScreen({super.key});

  @override
  State<EditGymScreen> createState() => _EditGymScreenState();
}

class _EditGymScreenState extends State<EditGymScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: TopAppBar(
        title: 'Edit Gym',
        showBackArrow: true,
        showRightIcon: false,
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
                  controller: nameController,
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
                  controller: locationController,
                ),
                const SizedBox(height: 20),
                CustomMultilineTextInput(
                  hintText: 'Gym Notes',
                  controller: notesController,
                ),
                const SizedBox(height: 20),
                DateDisplayField(date: selectedDate != null ? selectedDate!.toIso8601String().split('T').first : '2025-08-05'),
                const SizedBox(height: 24),
                GymIdDisplayField(gymId: 'GYM-0001'),
                const SizedBox(height: 32),
                PrimaryButton(
                  label: 'Save',
                  onPressed: () async {
                    if (!(_formKey.currentState?.validate() ?? false)) return;
                    final ctx = context;
                    try {
                      final repo = GymRepository();

                      // Try to detect an existing Isar id from route args
                      final args = ModalRoute.of(ctx)?.settings.arguments;
                      int? isarId;
                      if (args is int) isarId = args;
                      if (args is Map && args['isarId'] is int) isarId = args['isarId'] as int;

                      if (isarId != null) {
                        final updated = await repo.updateGym(
                          id: isarId,
                          name: nameController.text.trim().isEmpty ? null : nameController.text.trim(),
                          location: locationController.text.trim().isEmpty ? null : locationController.text.trim(),
                          gymNotes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                        );
                        if (!mounted) return;
                        showFlexSnackbarFromUiMessage(
                          ctx,
                          UiMessage('Gym updated', subtitle: 'Updated ${updated?.name ?? ''}', type: UiMessageType.success),
                        );
                        Navigator.of(ctx).pop(updated);
                      } else {
                        final user = Supabase.instance.client.auth.currentUser;
                        final userId = user?.id ?? 'local';
                        final gymId = 'GYM-${DateTime.now().millisecondsSinceEpoch}';
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
    );
  }
}
