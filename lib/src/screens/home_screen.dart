import 'package:flutter/material.dart';
import '../widgets/bottom_navigation.dart';
import '../screens/dashboard.dart';
import '../screens/wishlist.dart';
import '../screens/settings.dart';

class HomeScreen extends StatefulWidget {
  final int initialIndex;
  const HomeScreen({super.key, this.initialIndex = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          DashboardScreen(isVisible: _selectedIndex == 0),
          const WishlistScreen(),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBarModern(
        currentIndex: _selectedIndex,
        onTap: _onTabSelected,
      ),
    );
  }
}
