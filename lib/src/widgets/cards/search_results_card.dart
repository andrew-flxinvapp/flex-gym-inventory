import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/app_icons.dart';

class SearchResultsCard extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

  const SearchResultsCard({
    super.key,
    this.title = 'Equipment Name',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 370,
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.lightCard,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTextPrimary,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            SizedBox(
              width: 32,
              height: 32,
              child: Image.asset(
                AppIcons.forward,
                color: AppTheme.lightTextPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
