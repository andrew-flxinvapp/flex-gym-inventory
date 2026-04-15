import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flex_gym_inventory/service/image_service.dart';
import '../placeholders/image_placeholder_large.dart';

class EquipmentImage extends StatelessWidget {
  final String? imageId;
  final double? width;
  final double? height;
  final BoxFit fit;

  const EquipmentImage({
    super.key,
    this.imageId,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (imageId == null) return ImagePlaceholderLarge(width: width, height: height);

    return FutureBuilder<File?>(
      future: ImageService.instance.fileFor(imageId!),
      builder: (ctx, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return SizedBox(
            width: width,
            height: height,
            child: const Center(child: CircularProgressIndicator()),
          );
        }
        final file = snap.data;
        if (file != null) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              file,
              width: width,
              height: height,
              fit: fit,
            ),
          );
        }
        return ImagePlaceholderLarge(width: width, height: height);
      },
    );
  }
}
