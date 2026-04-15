import 'package:flutter/material.dart';

import '../cards/base_card.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_theme.dart';

class ImageInput extends StatelessWidget {
  final VoidCallback? onTap;

  const ImageInput({Key? key, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      onTap: onTap,
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
              child: Center(
                child: Image.asset(
                  AppIcons.upload,
                  width: 24,
                  height: 24,
                  color: AppTheme.dividers,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Upload image',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
