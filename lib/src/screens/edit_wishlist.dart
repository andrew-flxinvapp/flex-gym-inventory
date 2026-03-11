// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flex_gym_inventory/enum/app_enums.dart';
import 'package:flex_gym_inventory/src/repositories/wishlist_repository.dart';
import 'package:flex_gym_inventory/src/models/ui_message.dart';
import '../../theme/app_theme.dart';
import '../widgets/top_app_bar.dart';
import '../widgets/inputs/text_input_field.dart';
import '../widgets/inputs/multiline_text_input.dart';
import '../../theme/app_icons.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/buttons/secondary_button.dart';
import '../widgets/inputs/dropdown_field.dart';
import '../widgets/snackbar.dart';


class EditWishlistScreen extends StatefulWidget {
  const EditWishlistScreen({super.key});

  @override
  State<EditWishlistScreen> createState() => _EditWishlistScreenState();
}

class _EditWishlistScreenState extends State<EditWishlistScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for all input fields
  EquipmentCategory? selectedCategory;
  WishlistType? selectedItemType;
  WishlistPriority? selectedPriority;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController brandController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController linkController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: TopAppBar(
        title: 'Edit Item',
        showBackArrow: true,
        showRightIcon: true,
        rightIcon: AppIcons.reset,
        onRightIconPressed: () {
          _formKey.currentState?.reset();
          setState(() {
            selectedCategory = null;
            selectedItemType = null;
            selectedPriority = null;
            nameController.clear();
            brandController.clear();
            notesController.clear();
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
                    'Edit Wishlist Item information below.',
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
                  const SizedBox(height: 20),
                  CustomTextInputField(
                    hintText: 'Name',
                    showAsterisk: true,
                  ),
                  const SizedBox(height: 20),
                  CustomDropdownField<WishlistType>(
                    hintText: 'Item Type',
                    items: WishlistType.values,
                    value: selectedItemType,
                    showAsterisk: true,
                    getLabel: (item) => item.label,
                    onChanged: (value) {
                      setState(() {
                        selectedItemType = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Item Type selection is required';
                      }
                      return null;
                    },
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
                  CustomDropdownField<WishlistPriority>(
                    hintText: 'Priority',
                    items: WishlistPriority.values,
                    value: selectedPriority,
                    showAsterisk: true,
                    getLabel: (item) => item.label,
                    onChanged: (value) {
                      setState(() {
                        selectedPriority = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Priority selection is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  CustomTextInputField(
                    hintText: 'Link (URL)',
                    showAsterisk: false,
                  ),
                  const SizedBox(height: 20),
                  CustomMultilineTextInput(
                    hintText: 'Notes',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 32),
                  PrimaryButton(
                    label: 'Save',
                    onPressed: () async {
                      if (!(_formKey.currentState?.validate() ?? false)) return;
                      final ctx = context;
                      try {
                        final repo = WishlistRepository();

                        // Try to detect an existing Isar id from route args
                        final args = ModalRoute.of(ctx)?.settings.arguments;
                        int? isarId;
                        if (args is int) isarId = args;
                        if (args is Map && args['isarId'] is int) isarId = args['isarId'] as int;

                        if (isarId != null) {
                          final updated = await repo.updateWishlist(
                            id: isarId,
                            name: nameController.text.trim().isEmpty ? null : nameController.text.trim(),
                            wishlistType: selectedItemType,
                            category: selectedCategory,
                            brand: brandController.text.trim().isEmpty ? null : brandController.text.trim(),
                            priority: selectedPriority,
                            productUrl: linkController.text.trim().isEmpty ? null : linkController.text.trim(),
                            notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                          );
                          if (!mounted) return;
                          showFlexSnackbarFromUiMessage(
                            ctx,
                            UiMessage('Wishlist item updated', subtitle: 'Updated ${updated?.name ?? ''}', type: UiMessageType.success),
                          );
                          Navigator.of(ctx).pop(updated);
                        } else {
                          final user = Supabase.instance.client.auth.currentUser;
                          final userId = user?.id ?? 'local';
                          final created = await repo.createWishlist(
                            userId: userId,
                            name: nameController.text.trim(),
                            wishlistType: selectedItemType ?? WishlistType.newItem,
                            category: selectedCategory ?? EquipmentCategory.other,
                            brand: brandController.text.trim(),
                            priority: selectedPriority ?? WishlistPriority.medium,
                            productUrl: linkController.text.trim().isEmpty ? null : linkController.text.trim(),
                            notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                          );
                          if (!mounted) return;
                          showFlexSnackbarFromUiMessage(
                            ctx,
                            UiMessage('Wishlist item saved', subtitle: 'Created ${created.name}', type: UiMessageType.success),
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
      ),
    );
  }
}
