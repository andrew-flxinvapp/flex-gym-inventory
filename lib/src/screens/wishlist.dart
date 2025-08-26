import '../../theme/app_theme.dart';
import '../widgets/buttons/secondary_button.dart';
import '../widgets/cards/wishlist_item_card.dart';
import 'package:flutter/material.dart';
import '../widgets/top_app_bar.dart';
import '../widgets/bottom_navigation.dart';
import 'package:flex_gym_inventory/routes/routes.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopAppBar(
        title: 'Wishlist',
        showBackArrow: true,
        showRightIcon: false,
        onBackArrowPressed: () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).maybePop();
          } else {
            Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
          }
        },
      ),
      body: Builder(
        builder: (context) {
          // TODO: Replace with real itemCount from database
          final int itemCount = 3; // Change to >0 to test filled state
          if (itemCount == 0) {
            // Empty State
            return Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'lib/assets/images/empty_gym.png',
                      height: 350,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Looks like your wishlist is empty.",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.lightTextPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Got anything in mind?',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTextPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    SecondaryButton(
                      label: 'Add Item',
                      onPressed: () {
                        // TODO: Implement add equipment action
                      },
                    ),
                  ],
                ),
              ),
            );
          } else {
            // Filled State
            return Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Text(
                    'My Wishlist',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppTheme.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  WishlistItemCard(
                    itemName: 'Kabuki Trap Bar HD',
                    brand: 'Kabuki Strength',
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed('/wishlist-detail');
                    },
                    child: WishlistItemCard(
                      itemName: 'Rogue Adjustable Bench 3.0',
                      brand: 'Rogue Fitness',
                    ),
                  ),
                  const SizedBox(height: 16),
                  WishlistItemCard(
                    itemName: 'REP 80lb Dumbbells (Pair)',
                    brand: 'REP Fitness',
                  ),
                ],
              ),
            );
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBarModern(
        currentIndex: 1, // Set to the correct index for Wishlist
        onTap: (index) {
          // Implement navigation logic here
          switch (index) {
            case 0:
              Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
              break;
            case 1:
              // Already on Wishlist
              break;
            case 2:
              Navigator.of(context).pushReplacementNamed(AppRoutes.settings);
              break;
            // Add more cases as needed
          }
        },
      ),
    );
  }
}


