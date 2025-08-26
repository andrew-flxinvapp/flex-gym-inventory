import 'package:flutter/material.dart';
import '../../theme/app_icons.dart';
import '../widgets/top_app_bar.dart';
import 'package:flex_gym_inventory/routes/routes.dart';
import '../../theme/app_theme.dart';
import '../widgets/cards/wishlist_card.dart';
import '../widgets/cards/notes_card.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/dialogs/confirm_dialog.dart';

class WishlistDetailScreen extends StatelessWidget {
  const WishlistDetailScreen({super.key});


  @override
  Widget build(BuildContext context) {
  // No age calculation needed for wishlist detail
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: TopAppBar(
          title: 'Wishlist Detail',
          showBackArrow: true,
          showRightIcon: true,
          rightIcon: AppIcons.edit,
          onRightIconPressed: () {
            Navigator.of(context).pushNamed(AppRoutes.editWishlist);
        },
      ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Text(
                'Overview',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppTheme.lightTextPrimary,
                    ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Image.asset(
                AppIcons.rectangle,
                width: 370,
                height: 208,
              ),
            ),
            
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'Rogue Adjustable Bench 3.0',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppTheme.lightTextPrimary,
                    ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'Details',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppTheme.lightTextPrimary,
                    ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: WishlistCard(
                details: const [
                  MapEntry('Brand', 'Rogue'),
                  MapEntry('Category', 'Rig'),
                  MapEntry('Type', 'Replacement'),
                  MapEntry('Priority', 'Medium'),
                  MapEntry('Link', 'https://www.roguefitness.com/rogue-adjustable-bench-3-0'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'Notes',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppTheme.lightTextPrimary,
                    ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: NotesCard(
                notes: 'This bench is great for various exercises.',
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: PrimaryButton(
                label: 'Delete Item',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => ConfirmDialog(
                      title: 'Delete Item',
                      content: 'Are you sure you want to delete this item? This action cannot be undone.',
                      confirmText: 'Delete',
                      onConfirm: () {
                        // TODO: Implement actual delete logic here
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}