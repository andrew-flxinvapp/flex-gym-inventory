import 'package:flutter/material.dart';
import '../../theme/app_icons.dart';
import '../widgets/top_app_bar.dart';
import '../widgets/equipment/equipment_image.dart';
import 'package:flex_gym_inventory/routes/routes.dart';
import '../../theme/app_theme.dart';
import '../widgets/cards/details_card.dart';
import '../widgets/cards/purchase_card.dart';
import '../widgets/cards/notes_card.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/dialogs/confirm_dialog.dart';

class EquipmentDetailScreen extends StatelessWidget {
  const EquipmentDetailScreen({super.key});

  String _calculateAge(String purchaseDate) {
    try {
      final date = DateTime.parse(purchaseDate);
      final now = DateTime.now();
      final duration = now.difference(date);
      final years = duration.inDays ~/ 365;
      final months = (duration.inDays % 365) ~/ 30;
      if (years > 0) {
        return months > 0 ? '$years yr $months mo' : '$years yr';
      } else {
        return '$months mo';
      }
    } catch (_) {
      return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    const purchaseDate = '2023-01-15';
    final age = _calculateAge(purchaseDate);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: TopAppBar(
          title: 'Equipment Detail',
          showBackArrow: true,
          showRightIcon: true,
          rightIcon: AppIcons.edit,
          onRightIconPressed: () {
            Navigator.of(context).pushNamed(AppRoutes.editEquipment);
        },
      ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
                child: EquipmentImage(imageId: null),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Rogue Ohio Bar',
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
                child: DetailsCard(
                  details: const [
                    MapEntry('Brand', 'Rogue'),
                    MapEntry('Model', 'Ohio Bar'),
                    MapEntry('Category', 'Implement'),
                    MapEntry('Training Style', 'General'),
                    MapEntry('Quantity', '1'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Purchase Info',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: AppTheme.lightTextPrimary,
                      ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: PurchaseCard(
                  details: [
                    const MapEntry('Purchase Price', '295.00'),
                    MapEntry('Purchase Date', purchaseDate),
                    MapEntry('Age', age),
                    const MapEntry('Warranty', 'Lifetime'),
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
                  notes: 'This bar is used for all general training. No rust, knurling is still sharp, and sleeves spin smoothly.',
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
                        title: 'Delete Equipment',
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
      ),
    );
  }
}