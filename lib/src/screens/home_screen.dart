import 'package:flutter/material.dart';
import '../widgets/bottom_navigation.dart';
import '../screens/dashboard.dart';
import '../screens/wishlist.dart';
import '../screens/settings.dart';


class HomeScreen extends StatefulWidget {
  final int initialIndex;
  const HomeScreen({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _selectedIndex;

  final List<Widget> _screens = const [
    DashboardScreen(),
    WishlistScreen(),
    SettingsScreen(),
  ];

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
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBarModern(
        currentIndex: _selectedIndex,
        onTap: _onTabSelected,
      ),
    );
  }
}
