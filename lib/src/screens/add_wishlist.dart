// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flex_gym_inventory/enum/app_enums.dart';
import 'package:flex_gym_inventory/src/repositories/wishlist_repository.dart';
import 'package:flex_gym_inventory/src/models/ui_message.dart';
import '../widgets/snackbar.dart';
import '../../theme/app_theme.dart';
import '../widgets/top_app_bar.dart';
import '../widgets/inputs/text_input_field.dart';
import '../widgets/inputs/multiline_text_input.dart';
import '../../theme/app_icons.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/buttons/secondary_button.dart';
import '../widgets/inputs/dropdown_field.dart';


class AddWishlistScreen extends StatefulWidget {
  const AddWishlistScreen({super.key});

  @override
  State<AddWishlistScreen> createState() => _AddWishlistScreenState();
}

class _AddWishlistScreenState extends State<AddWishlistScreen> {
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
        title: 'Add Item',
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
                  'Enter Wishlist Item information below.',
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
                  controller: nameController,
                ),
                const SizedBox(height: 20),
                CustomDropdownField<WishlistType>(
                  hintText: 'Select Type',
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
                CustomDropdownField<WishlistPriority>(
                  hintText: 'Select Priority',
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
                  controller: linkController,
                ),
                const SizedBox(height: 20),
                CustomMultilineTextInput(
                  hintText: 'Notes',
                  maxLines: 3,
                  controller: notesController,
                ),
                const SizedBox(height: 32),
                PrimaryButton(
                  label: 'Save',
                  onPressed: () async {
                    if (!(_formKey.currentState?.validate() ?? false)) return;
                    try {
                      final user = Supabase.instance.client.auth.currentUser;
                      final userId = user?.id ?? 'local';
                      final repo = WishlistRepository();
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

                      showFlexSnackbarFromUiMessage(
                        context,
                        UiMessage('Wishlist item saved', subtitle: 'Created ${created.name}', type: UiMessageType.success),
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
