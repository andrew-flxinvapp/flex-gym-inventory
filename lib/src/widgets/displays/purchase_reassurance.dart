import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../placeholders/vertical_divider.dart';

class PurchaseReassurance extends StatelessWidget {
	/// Three pieces of fixed text displayed in a single row separated by
	/// `CustomVerticalDivider` widgets. These strings are constant and
	/// intentionally not configurable.
	const PurchaseReassurance({Key? key}) : super(key: key);

	static const _leftText = '7-day free trial';
	static const _centerText = 'No commitment';
	static const _rightText = 'Cancel anytime';

	@override
	Widget build(BuildContext context) {
		final textStyle = Theme.of(context)
			.textTheme
			.labelSmall
			?.copyWith(color: AppTheme.darkTextPrimary) ??
			const TextStyle(fontSize: 12, color: AppTheme.darkTextPrimary);

				return SizedBox(
					width: 330,
					child: Row(
						mainAxisAlignment: MainAxisAlignment.center,
						crossAxisAlignment: CrossAxisAlignment.center,
						mainAxisSize: MainAxisSize.min,
						children: <Widget>[
							Flexible(
								fit: FlexFit.loose,
								child: Text(_leftText, style: textStyle, overflow: TextOverflow.ellipsis),
							),

							SizedBox(
								width: 20,
								height: 32,
								child: Center(child: const CustomVerticalDivider(height: 16.0)),
							),

							Flexible(
								fit: FlexFit.loose,
								child: Text(_centerText, style: textStyle, textAlign: TextAlign.center, overflow: TextOverflow.visible),
							),

							SizedBox(
								width: 20,
								height: 32,
								child: Center(child: const CustomVerticalDivider(height: 16.0)),
							),

							Flexible(
								fit: FlexFit.loose,
								child: Text(_rightText, style: textStyle, textAlign: TextAlign.right, overflow: TextOverflow.ellipsis),
							),
						],
					),
				);
	}
}

