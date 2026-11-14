import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flex_gym_inventory/service/image_service.dart';
import '../../theme/app_icons.dart';
import '../widgets/top_app_bar.dart';
import '../widgets/equipment/equipment_image.dart';
import 'package:flex_gym_inventory/routes/routes.dart';
import 'package:flex_gym_inventory/src/data/repositories/wishlist_repository.dart';
import 'package:flex_gym_inventory/src/models/wishlist_model.dart';
import 'package:flex_gym_inventory/enum/app_enums.dart';
import '../../theme/app_theme.dart';
import '../widgets/cards/wishlist_card.dart';
import '../widgets/cards/notes_card.dart';
import '../widgets/buttons/warning_button.dart';
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
  Future<File?>? _imageFileFuture;

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
        _imageFileFuture = _resolveImageFile(w?.imagePath);
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

  Future<File?>? _resolveImageFile(String? imageId) {
    final normalizedImageId = imageId?.trim();
    if (normalizedImageId == null || normalizedImageId.isEmpty) return null;
    return _loadImageFile(normalizedImageId);
  }

  Future<File?> _loadImageFile(String imageId) async {
    try {
      return await ImageService.instance.fileFor(imageId);
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'Flex Gym Inventory',
          context: ErrorDescription('while resolving a wishlist image'),
        ),
      );
      return null;
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
    final imageFileFuture = _imageFileFuture;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
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
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
                        child: Text(
                          'Overview',
                          style: Theme.of(context).textTheme.displaySmall
                              ?.copyWith(color: AppTheme.lightTextPrimary),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (imageFileFuture != null)
                        FutureBuilder<File?>(
                          future: imageFileFuture,
                          builder: (context, snapshot) {
                            final file = snapshot.data;
                            if (snapshot.connectionState !=
                                    ConnectionState.done ||
                                snapshot.hasError ||
                                file == null) {
                              return const SizedBox.shrink();
                            }
                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    16.0,
                                    0,
                                    16.0,
                                    0,
                                  ),
                                  child: Center(
                                    child: EquipmentImage(
                                      imageId: item?.imagePath,
                                      resolvedFile: file,
                                      width: double.infinity,
                                      height: 208,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                            );
                          },
                        ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
                        child: Text(
                          item?.name ?? '-',
                          style: Theme.of(context).textTheme.displaySmall
                              ?.copyWith(color: AppTheme.lightTextPrimary),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
                        child: Text(
                          'Details',
                          style: Theme.of(context).textTheme.displaySmall
                              ?.copyWith(color: AppTheme.lightTextPrimary),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
                        child: WishlistCard(
                          details: [
                            MapEntry('Brand', item?.brand ?? '-'),
                            MapEntry('Category', item?.category.label ?? '-'),
                            MapEntry('Type', item?.wishlistType.label ?? '-'),
                            MapEntry('Priority', item?.priority.label ?? '-'),
                            MapEntry('Link', item?.productUrl?.trim() ?? ''),
                            MapEntry('Price', item?.price ?? '-'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
                        child: Text(
                          'Notes',
                          style: Theme.of(context).textTheme.displaySmall
                              ?.copyWith(color: AppTheme.lightTextPrimary),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
                        child: NotesCard(notes: item?.notes ?? '-'),
                      ),
                      const SizedBox(height: 32),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
                        child: WarningButton(
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
