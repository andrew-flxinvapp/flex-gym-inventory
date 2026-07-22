import 'package:flutter/material.dart';
import 'package:flex_gym_inventory/theme/app_icons.dart';
import 'package:flex_gym_inventory/theme/app_theme.dart';
import 'package:flex_gym_inventory/src/models/social_proof_data.dart';

/// A compact widget that displays a user count flanked by laurel icons.
///
/// - Fixed width: 122
/// - Left icon: `AppIcons.laurelLeft`
/// - Right icon: `AppIcons.laurelRight`
///
/// The widget supports two ways to provide the count:
/// - `countListenable`: a `ValueListenable<int>` that can be updated over time
/// - `count`: a static integer value
///
/// At least one of `countListenable` or `count` must be non-null.
class UserCount extends StatelessWidget {
	final int? count;
	final SocialProofData? data;
	final String label;

	const UserCount({
		Key? key,
		this.count,
		this.data,
		this.label = 'Happy gym\nowners',
	})  : assert(count != null || data != null,
						'Either count or data must be provided'),
				super(key: key);

	Widget _buildCountFromStrings(BuildContext context, String topText, String label) {
		final theme = Theme.of(context).textTheme;
		return Column(
			mainAxisSize: MainAxisSize.min,
			crossAxisAlignment: CrossAxisAlignment.center,
			children: [
				Text(
					topText,
					style: theme.displayMedium?.copyWith(
						fontWeight: FontWeight.normal,
						color: AppTheme.darkTextPrimary,
					),
					textAlign: TextAlign.center,
				),
				const SizedBox(height: 4),
				Text(
					label,
					style: theme.labelSmall?.copyWith(fontSize: 10, fontWeight: FontWeight.normal, color: AppTheme.darkTextPrimary),
					textAlign: TextAlign.center,
					maxLines: 2,
				),
			],
		);
	}

	String _ensureTwoLineLabel(String input) {
		if (input.contains('\n')) return input;
		final idx = input.trim().lastIndexOf(' ');
		if (idx <= 0) return input;
		return input.trim().substring(0, idx) + '\n' + input.trim().substring(idx + 1);
	}

	String _intToTopText(int value) {
		if (value >= 1000000) {
			final millions = value ~/ 1000000;
			return '${millions}M+';
		}
		if (value >= 1000) {
			final thousands = value ~/ 1000;
			return '${thousands}K+';
		}
		return value.toString();
	}

	@override
	Widget build(BuildContext context) {
		return SizedBox(
			width: 130,
			child: Row(
				mainAxisAlignment: MainAxisAlignment.spaceBetween,
				crossAxisAlignment: CrossAxisAlignment.center,
				children: [
					Image.asset(AppIcons.laurelLeft, width: 36, height: 65),

					// center column: prefer static SocialProofData if provided, then static int
					if (data != null)
						_buildCountFromStrings(context, data!.formattedUserCount, _ensureTwoLineLabel(data!.userLabel))
					else
						_buildCountFromStrings(context, _intToTopText(count!), _ensureTwoLineLabel(label)),

					Image.asset(AppIcons.laurelRight, width: 36, height: 65),
				],
			),
		);
	}
}

