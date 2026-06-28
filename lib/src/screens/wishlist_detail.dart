import 'package:flutter/material.dart';
import '../../theme/app_icons.dart';
import '../widgets/top_app_bar.dart';
import '../widgets/equipment/equipment_image.dart';
import 'package:flex_gym_inventory/routes/routes.dart';
import 'package:flex_gym_inventory/src/repositories/wishlist_repository.dart';
import 'package:flex_gym_inventory/src/models/wishlist_model.dart';
import 'package:flex_gym_inventory/enum/app_enums.dart';
import '../../theme/app_theme.dart';
import '../widgets/cards/wishlist_card.dart';
import '../widgets/cards/notes_card.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/dialogs/confirm_dialog.dart';

class WishlistDetailScreen extends StatefulWidget {
  const WishlistDetailScreen({super.key});

  @override
  State<WishlistDetailScreen> createState() => _WishlistDetailScreenState();
}

class _WishlistDetailScreenState extends State<WishlistDetailScreen> {
  Wishlist? item;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadItem());
  }

  Future<void> _loadItem() async {
    final args = ModalRoute.of(context)?.settings.arguments;
    int? isarId;
    if (args is int) isarId = args;
    if (args is Map && args['isarId'] is int) isarId = args['isarId'] as int;
    if (isarId == null) {
      setState(() {
        error = 'No wishlist id provided';
        isLoading = false;
      });
      return;
    }

    try {
      final repo = WishlistRepository();
      final w = await repo.getByIsarId(isarId);
      if (!mounted) return;
      setState(() {
        item = w;
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

  Future<void> _deleteItem() async {
    if (item == null) return;
    final repo = WishlistRepository();
    await repo.deleteWishlist(item!.id);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: TopAppBar(
          title: 'Wishlist Detail',
          showBackArrow: true,
          showRightIcon: true,
          rightIcon: AppIcons.edit,
          onRightIconPressed: () {
            if (item?.id != null) {
              Navigator.of(
                context,
              ).pushNamed(AppRoutes.editWishlist, arguments: item!.id);
            } else {
              Navigator.of(context).pushNamed(AppRoutes.editWishlist);
            }
          },
        ),
      ),
      body: SafeArea(
        child:
            isLoading
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
                          style: Theme.of(context).textTheme.displaySmall
                              ?.copyWith(color: AppTheme.lightTextPrimary),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: EquipmentImage(
                          imageId: item?.imagePath,
                          width: 370,
                          height: 208,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text(
                          item?.name ?? '-',
                          style: Theme.of(context).textTheme.displaySmall
                              ?.copyWith(color: AppTheme.lightTextPrimary),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text(
                          'Details',
                          style: Theme.of(context).textTheme.displaySmall
                              ?.copyWith(color: AppTheme.lightTextPrimary),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: WishlistCard(
                          details: [
                            MapEntry('Brand', item?.brand ?? '-'),
                            MapEntry('Category', item?.category.label ?? '-'),
                            MapEntry('Type', item?.wishlistType.label ?? '-'),
                            MapEntry('Priority', item?.priority.label ?? '-'),
                            MapEntry('Link', item?.productUrl ?? '-'),
                            MapEntry('Price', item?.price ?? '-'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text(
                          'Notes',
                          style: Theme.of(context).textTheme.displaySmall
                              ?.copyWith(color: AppTheme.lightTextPrimary),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: NotesCard(notes: item?.notes ?? '-'),
                      ),
                      const SizedBox(height: 32),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: PrimaryButton(
                          label: 'Delete Item',
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder:
                                  (ctx) => ConfirmDialog(
                                    title: 'Delete Item',
                                    content:
                                        'Are you sure you want to delete this item? This action cannot be undone.',
                                    confirmText: 'Delete',
                                    onConfirm: () async {
                                      await _deleteItem();
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
