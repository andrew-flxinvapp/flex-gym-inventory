import 'package:flutter/material.dart';
import 'package:flex_gym_inventory/theme/app_icons.dart';
import 'package:flex_gym_inventory/theme/app_theme.dart';
import 'package:flex_gym_inventory/src/data/dtos/social_proof_content.dart';

class UserRatings extends StatelessWidget {
  const UserRatings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ratingText = '${socialProofContent.formattedRating} Star Rating';
    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppTheme.darkTextPrimary,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(ratingText, style: textStyle, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            5,
            (i) => Padding(
              padding: EdgeInsets.only(right: i == 4 ? 0 : 10),
              child: ImageIcon(
                AssetImage(AppIcons.star),
                color: AppTheme.proColor,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
