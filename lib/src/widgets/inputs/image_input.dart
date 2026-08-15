import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as p;

import '../cards/base_card.dart';
import '../snackbar.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_theme.dart';

class ImageInput extends StatefulWidget {
  final VoidCallback? onTap;
  final ValueChanged<File?>? onImageChanged;

  const ImageInput({super.key, this.onTap, this.onImageChanged});

  @override
  State<ImageInput> createState() => _ImageInputState();
}

class _ImageInputState extends State<ImageInput> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  bool _isProcessing = false;

  Future<void> _handleTap() async {
    if (widget.onTap != null) {
      widget.onTap!();
      return;
    }

    // Let image_picker handle runtime permissions for gallery access.

    try {
      final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return;

      // Convert XFile to dart:io File for downstream APIs
      final File originalFile = File(picked.path);

      setState(() => _isProcessing = true);

      final dir = await getTemporaryDirectory();
      final targetPath = p.join(dir.path, '${const Uuid().v4()}.jpg');

      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        originalFile.path,
        targetPath,
        quality: 85,
        keepExif: false,
      );

      if (compressedFile == null) {
        showFlexSnackbar(
          context,
          title: 'Upload failed',
          subtitle: 'Could not compress the selected image.',
          type: SnackbarType.stop,
        );
        setState(() => _isProcessing = false);
        return;
      }

      // Ensure we have a dart:io File regardless of return type (File or XFile)
      final File savedFile = File(compressedFile.path);

      // Optionally enforce size limit (10 MB)
      final bytes = await savedFile.length();
      if (bytes > 10 * 1024 * 1024) {
        showFlexSnackbar(
          context,
          title: 'File too large',
          subtitle: 'Please choose an image smaller than 10 MB.',
          type: SnackbarType.warning,
        );
        setState(() => _isProcessing = false);
        return;
      }

      setState(() {
        _imageFile = savedFile;
        // notify parent about new file
        widget.onImageChanged?.call(_imageFile);
        _isProcessing = false;
      });

      showFlexSnackbar(
        context,
        title: 'Screenshot ready',
        subtitle: 'Your screenshot was saved locally.',
        type: SnackbarType.success,
      );
    } catch (e) {
      setState(() => _isProcessing = false);
      showFlexSnackbar(
        context,
        title: 'Upload error',
        subtitle: e.toString(),
        type: SnackbarType.stop,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      onTap: _handleTap,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppTheme.lightBackground,
                border: Border.all(color: AppTheme.dividers),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _isProcessing
                  ? const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator()))
                  : (_imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(_imageFile!, fit: BoxFit.cover, width: 60, height: 60),
                        )
                      : Center(
                          child: Image.asset(
                            AppIcons.upload,
                            width: 24,
                            height: 24,
                            color: AppTheme.dividers,
                          ),
                        )),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Upload screenshot',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'PNG, JPG, or HEIC up to 10 MB',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppTheme.lightSecondary,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
