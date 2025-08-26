import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../theme/app_theme.dart';
import '../snackbar.dart';

class WishlistCard extends StatelessWidget {
  final List<MapEntry<String, String>> details;
  const WishlistCard({Key? key, required this.details}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Only show up to 5 rows, fill with empty if less
    final rows = List<MapEntry<String, String>>.generate(
      5,
      (i) => i < details.length
          ? details[i]
          : const MapEntry('', ''),
    );

    return Container(
      width: 370,
      decoration: BoxDecoration(
        color: AppTheme.lightCard,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 0; i < 5; i++) ...[
            rows[i].key == 'Link' && rows[i].value.isNotEmpty
                ? _WishlistLinkRow(url: rows[i].value)
                : _WishlistDetailRow(
                    label: rows[i].key,
                    value: rows[i].value,
                  ),
            if (i != 4) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

// --- End of WishlistCard ---

class _WishlistLinkRow extends StatelessWidget {
  final String url;
  const _WishlistLinkRow({required this.url});

  Future<void> _launchUrl(BuildContext context) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // Show custom FlexSnackbar as a warning
      final overlay = Overlay.of(context);
      late OverlayEntry overlayEntry;
      overlayEntry = OverlayEntry(
        builder: (ctx) => Positioned(
          left: MediaQuery.of(context).size.width / 2 - 193,
          bottom: MediaQuery.of(context).padding.bottom + 32,
          child: Material(
            color: Colors.transparent,
            child: FlexSnackbar(
              title: 'Could not open link.',
              type: SnackbarType.warning,
              onClose: () => overlayEntry.remove(),
            ),
          ),
        ),
      );
      overlay.insert(overlayEntry);
      Future.delayed(const Duration(seconds: 3), () {
        if (overlayEntry.mounted) overlayEntry.remove();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Link:',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTextPrimary,
              ),
        ),
        GestureDetector(
          onTap: () => _launchUrl(context),
          child: Text(
            'Open Link',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
          ),
        ),
      ],
    );
  }
}


class _WishlistDetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _WishlistDetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label.isNotEmpty ? "$label:" : '',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTextPrimary,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTextPrimary,
              ),
        ),
      ],
    );
  }
}
