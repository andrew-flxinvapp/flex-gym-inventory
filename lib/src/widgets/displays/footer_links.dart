import 'package:flutter/material.dart';
import 'package:flex_gym_inventory/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class FooterLinks extends StatelessWidget {
  final VoidCallback onRestore;
  final String termsLabel;
  final String privacyLabel;
  final VoidCallback? onTerms;
  final VoidCallback? onPrivacy;

  const FooterLinks({
    Key? key,
    required this.onRestore,
    this.termsLabel = 'Terms of Use',
    this.privacyLabel = 'Privacy Policy',
    this.onTerms,
    this.onPrivacy,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelSmall;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 370),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
        // First row: single centered "Restore Purchases" link
            Center(
              child: TextButton(
                onPressed: onRestore,
                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
            child: Text(
              'Restore Purchases',
              style: labelStyle?.copyWith(color: AppTheme.darkTextPrimary),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Second row: two text links side-by-side
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
                TextButton(
                  onPressed: onTerms ?? () => _launchUrl(context, Uri.parse('https://flexgyminventory.app/terms-and-conditions'), 'Could not open Terms and Conditions'),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
              child: Text(termsLabel, style: labelStyle?.copyWith(color: AppTheme.darkTextPrimary),),
            ),

            const SizedBox(width: 40),

                TextButton(
                  onPressed: onPrivacy ?? () => _launchUrl(context, Uri.parse('https://flexgyminventory.app/privacy-policy'), 'Could not open Privacy Policy'),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
              child: Text(privacyLabel, style: labelStyle?.copyWith(color: AppTheme.darkTextPrimary),),
            ),
          ],
        ),
      ],
    ));
  }

  static Future<void> _launchUrl(BuildContext context, Uri uri, String errorMessage) async {
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (launched == false) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }
}
