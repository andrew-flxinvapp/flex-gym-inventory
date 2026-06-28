import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flex_gym_inventory/service/image_service.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_theme.dart';
import '../../../enum/app_enums.dart';
import '../placeholders/image_placeholder_large.dart';

class EquipmentImage extends StatelessWidget {
  final String? imageId;
  final double? width;
  final double? height;
  final BoxFit fit;
  final ValueChanged<ImageAction?>? onImageActionSelected;

  const EquipmentImage({
    super.key,
    this.imageId,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.onImageActionSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (imageId == null) {
      return Stack(
        children: [
          ImagePlaceholderLarge(width: width, height: height),
          Positioned(
            top: 12,
            right: 12,
            child: PopupMenuButton<ImageAction>(
              icon: const ImageIcon(
                AssetImage(AppIcons.more),
                size: 20,
                color: AppTheme.lightTextPrimary,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: Colors.white,
              itemBuilder:
                  (context) => [
                    const PopupMenuItem(
                      value: ImageAction.edit,
                      child: Text('Edit'),
                    ),
                    const PopupMenuItem(
                      value: ImageAction.delete,
                      child: Text('Delete'),
                    ),
                  ],
              onSelected: (value) => onImageActionSelected?.call(value),
            ),
          ),
        ],
      );
    }

    return FutureBuilder<File?>(
      future: ImageService.instance.fileFor(imageId!),
      builder: (ctx, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return Stack(
            children: [
              SizedBox(
                width: width,
                height: height,
                child: const Center(child: CircularProgressIndicator()),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: PopupMenuButton<ImageAction>(
                  icon: const ImageIcon(
                    AssetImage(AppIcons.more),
                    size: 20,
                    color: AppTheme.lightTextPrimary,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: Colors.white,
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(
                          value: ImageAction.edit,
                          child: Text('Edit'),
                        ),
                        const PopupMenuItem(
                          value: ImageAction.delete,
                          child: Text('Delete'),
                        ),
                      ],
                  onSelected: (value) => onImageActionSelected?.call(value),
                ),
              ),
            ],
          );
        }
        final file = snap.data;
        if (file != null) {
          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(file, width: width, height: height, fit: fit),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: PopupMenuButton<ImageAction>(
                  icon: const ImageIcon(
                    AssetImage(AppIcons.more),
                    size: 20,
                    color: AppTheme.lightTextPrimary,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: Colors.white,
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(
                          value: ImageAction.edit,
                          child: Text('Edit'),
                        ),
                        const PopupMenuItem(
                          value: ImageAction.delete,
                          child: Text('Delete'),
                        ),
                      ],
                  onSelected: (value) => onImageActionSelected?.call(value),
                ),
              ),
            ],
          );
        }
        return Stack(
          children: [
            ImagePlaceholderLarge(width: width, height: height),
            Positioned(
              top: 12,
              right: 12,
              child: PopupMenuButton<ImageAction>(
                icon: const ImageIcon(
                  AssetImage(AppIcons.more),
                  size: 20,
                  color: AppTheme.lightTextPrimary,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: Colors.white,
                itemBuilder:
                    (context) => [
                      const PopupMenuItem(
                        value: ImageAction.edit,
                        child: Text('Edit'),
                      ),
                      const PopupMenuItem(
                        value: ImageAction.delete,
                        child: Text('Delete'),
                      ),
                    ],
                onSelected: (value) => onImageActionSelected?.call(value),
              ),
            ),
          ],
        );
      },
    );
  }
}
