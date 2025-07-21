import 'package:flutter/material.dart';

class FloatingBottomNav extends StatelessWidget {
  const FloatingBottomNav({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 386,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF010D1B).withOpacity(0.10),
            offset: const Offset(0, 0),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _NavItem(
            iconPath: 'lib/assets/icons/dashboard_filled.png',
            label: 'Dashboard',
            onTap: () => Navigator.of(context).pushNamed('/dashboard'),
          ),
          _NavItem(
            iconPath: 'lib/assets/icons/sparkles.png',
            label: 'Upgrades',
            onTap: () => Navigator.of(context).pushNamed('/upgrades'),
          ),
          _NavItem(
            iconPath: 'lib/assets/icons/settings.png',
            label: 'Settings',
            onTap: () => Navigator.of(context).pushNamed('/settings'),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String iconPath;
  final String label;
  final VoidCallback onTap;

  const _NavItem({required this.iconPath, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 55,
      height: 45,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              iconPath,
              height: 24,
              width: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF010D1B),
                fontFamily: 'Roboto',
              ),
            ),
          ],
        ),
      ),
    );
  }
}