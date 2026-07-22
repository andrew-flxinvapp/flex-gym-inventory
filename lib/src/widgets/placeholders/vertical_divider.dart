import 'package:flutter/material.dart';
import 'package:flex_gym_inventory/theme/app_theme.dart';

/// A small, reusable vertical divider widget.
///
/// Use this inside `Row`-like layouts to separate children vertically.
/// It mirrors the common `Divider` parameters but for vertical use.
class CustomVerticalDivider extends StatelessWidget {
	/// Creates a vertical divider.
	const CustomVerticalDivider({
		Key? key,
		this.height = 16.0,
		this.thickness = 1.0,
		this.color = AppTheme.darkDividers,
		this.indent = 0.0,
		this.endIndent = 0.0,
	}) : super(key: key);

	/// The height of the divider. If null, the divider will expand to fit
	/// the available vertical space of its parent.
	final double? height;

	/// The width (thickness) of the divider line. Defaults to 1.0.
	final double thickness;

	/// The color of the divider. Defaults to `Theme.of(context).dividerColor`.
	final Color? color;

	/// Empty space above the divider.
	final double indent;

	/// Empty space below the divider.
	final double endIndent;

	@override
	Widget build(BuildContext context) {
		final dividerColor = color ?? Theme.of(context).dividerColor;

		return Container(
			width: thickness,
			margin: EdgeInsets.only(top: indent, bottom: endIndent),
			height: height ?? double.infinity,
			color: dividerColor,
		);
	}
}

