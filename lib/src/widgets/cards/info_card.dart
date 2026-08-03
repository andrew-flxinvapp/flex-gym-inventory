import 'package:flutter/material.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_theme.dart';
import 'base_card.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final String? subtitle;

  const InfoCard({
    super.key,
    this.title = 'Title',
    this.subtitle = 'Subtitle',
  });

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      color: AppTheme.lightSecondary.withValues(alpha: 0.5),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      body: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Image.asset(
                  AppIcons.update,
                  width: 24,
                  height: 24,
                  color: AppTheme.darkBackground,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.darkBackground,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppTheme.darkBackground,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
