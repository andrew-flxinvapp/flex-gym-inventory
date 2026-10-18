import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'purchase_info_item.dart';

class FooterLinks extends StatelessWidget {
  final VoidCallback onRestore;
  final String termsLabel;
  final String privacyLabel;
  final VoidCallback? onTerms;
  final VoidCallback? onPrivacy;

  const FooterLinks({
    super.key,
    required this.onRestore,
    this.termsLabel = 'Terms of Use',
    this.privacyLabel = 'Privacy Policy',
    this.onTerms,
    this.onPrivacy,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: double.infinity),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: PurchaseInfoItem(
              label: 'Restore Purchases',
              onTap: onRestore,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PurchaseInfoItem(
                label: termsLabel,
                onTap:
                    onTerms ??
                    () => _launchUrl(
                      context,
                      Uri.parse(
                        'https://flexgyminventory.app/terms-and-conditions',
                      ),
                      'Could not open Terms and Conditions',
                    ),
              ),
              const SizedBox(width: 40),
              PurchaseInfoItem(
                label: privacyLabel,
                onTap:
                    onPrivacy ??
                    () => _launchUrl(
                      context,
                      Uri.parse('https://flexgyminventory.app/privacy-policy'),
                      'Could not open Privacy Policy',
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Future<void> _launchUrl(
    BuildContext context,
    Uri uri,
    String errorMessage,
  ) async {
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (launched == false) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }
}
