import '../../theme/app_theme.dart';
import '../widgets/buttons/secondary_button.dart';
import '../widgets/cards/wishlist_item_card.dart';
import 'package:flutter/material.dart';
import '../widgets/top_app_bar.dart';
import 'package:flex_gym_inventory/theme/app_icons.dart';
import 'package:flex_gym_inventory/routes/routes.dart';
import 'package:flex_gym_inventory/src/repositories/wishlist_repository.dart';
import 'package:flex_gym_inventory/src/models/wishlist_model.dart';
// import '../widgets/buttons/primary_button.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  Future<List<Wishlist>> _fetchData() async {
    final repo = WishlistRepository();
    return await repo.getAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopAppBar(
        title: 'Wishlist',
        titleWidget: const Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: Text('Wishlist'),
        ),
        showBackArrow: false,
        showRightIcon: true,
        rightIcon: AppIcons.plus,
        onRightIconPressed: () {
          Navigator.of(
            context,
          ).pushNamed(AppRoutes.addWishlist).then((_) => setState(() {}));
        },
      ),
      body: SafeArea(
        child: FutureBuilder<List<Wishlist>>(
          future: _fetchData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final items = snapshot.data ?? [];

            if (items.isEmpty) {
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
                          Navigator.of(context)
                              .pushNamed(AppRoutes.addWishlist)
                              .then((_) => setState(() {}));
                        },
                      ),
                    ],
                  ),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
              child: ListView(
                children: [
                  const SizedBox(height: 24),
                  Text(
                    'My Wishlist',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppTheme.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  for (final w in items) ...[
                    WishlistItemCard.fromWishlist(
                      w,
                      onTapCallback: (id) async {
                        await Navigator.of(
                          context,
                        ).pushNamed(AppRoutes.wishlistDetail, arguments: id);
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
