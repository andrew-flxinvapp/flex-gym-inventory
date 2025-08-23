import 'package:flutter/material.dart';
import '../../theme/app_icons.dart';
import '../widgets/top_app_bar.dart';
import 'package:flex_gym_inventory/routes/routes.dart';
import '../../theme/app_theme.dart';

class EquipmentDetailScreen extends StatelessWidget {
  const EquipmentDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
      body: Column(
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
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.lightCard,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DetailRow(label: 'Brand', value: 'Rogue'),
                  Divider(color: AppTheme.lightTextSecondary, thickness: 1, height: 1),
                  DetailRow(label: 'Weight', value: '20kg'),
                  Divider(color: AppTheme.lightTextSecondary, thickness: 1, height: 1),
                  DetailRow(label: 'Type', value: 'Barbell'),
                  Divider(color: AppTheme.lightTextSecondary, thickness: 1, height: 1),
                  DetailRow(label: 'Purchase Date', value: '2023-01-15'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Additional content can be added here in the future.
        ],
      ),
    );
  }
}

class DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const DetailRow({required this.label, required this.value, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
          Text(value, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}