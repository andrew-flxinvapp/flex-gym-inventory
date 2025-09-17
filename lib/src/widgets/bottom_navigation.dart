import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_icons.dart';

class BottomNavigationBarModern extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavigationBarModern({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  void _handleNavigation(BuildContext context, int index) {
    if (currentIndex != index) {
      onTap(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 84,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(40, 0, 40, 16),
      decoration: const BoxDecoration(
        color: AppTheme.lightBackground,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavTab(
            icon: currentIndex == 0 ? AppIcons.dashboardSelected : AppIcons.dashboard,
            label: 'Dashboard',
            selected: currentIndex == 0,
            onTap: () => _handleNavigation(context, 0),
          ),
          _NavTab(
            icon: currentIndex == 1 ? AppIcons.wishlistSelected : AppIcons.wishlist,
            label: 'Wishlist',
            selected: currentIndex == 1,
            onTap: () => _handleNavigation(context, 1),
          ),
          _NavTab(
            icon: currentIndex == 2 ? AppIcons.settingsSelected : AppIcons.settings,
            label: 'Settings',
            selected: currentIndex == 2,
            onTap: () => _handleNavigation(context, 2),
          ),
        ],
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  final String icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavTab({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 65,
      height: 45,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              icon,
              height: 24,
              width: 24,
              color: selected ? AppTheme.lightTextPrimary : AppTheme.lightTextPrimary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: selected ? AppTheme.lightTextPrimary : AppTheme.lightTextPrimary,
                fontFamily: 'Roboto',
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
