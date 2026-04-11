import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class BaseCard extends StatelessWidget {
	final double? width; // default applied in build
	final double? height;
	final Color? color;
	final EdgeInsetsGeometry padding;
	final BorderRadiusGeometry borderRadius;
	final List<BoxShadow>? boxShadow;
	final Widget? leading;
	final Widget? header;
	final Widget? body;
	final Widget? footer;
	final Widget? trailing;
	final Map<String, Widget>? extraSlots;
	final VoidCallback? onTap;

	const BaseCard({
		super.key,
		this.width,
		this.height,
		this.color,
		this.padding = const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
		this.borderRadius = const BorderRadius.all(Radius.circular(16)),
		this.boxShadow,
		this.leading,
		this.header,
		this.body,
		this.footer,
		this.trailing,
		this.extraSlots,
		this.onTap,
	});

	@override
	Widget build(BuildContext context) {
		final decoration = BoxDecoration(
			color: color ?? AppTheme.lightCard,
			borderRadius: borderRadius,
			boxShadow: boxShadow ?? [
				BoxShadow(
					color: Colors.black.withValues(alpha: 0.04),
					blurRadius: 8,
					offset: const Offset(0, 2),
				),
			],
		);

		Widget buildHeaderRow() {
			return Row(
				crossAxisAlignment: CrossAxisAlignment.center,
				children: [
					if (leading != null) ...[
						leading!,
						const SizedBox(width: 8),
					],
					if (header != null) Expanded(child: header!),
					if (trailing != null) ...[
						const SizedBox(width: 8),
						trailing!,
					],
				],
			);
		}

		return Material(
			color: Colors.transparent,
			child: InkWell(
				onTap: onTap,
				borderRadius: borderRadius as BorderRadius?,
				child: Container(
					width: width ?? 370,
					// no fixed height by default
					height: height,
					decoration: decoration,
					padding: padding,
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							if (leading != null || header != null || trailing != null)
								buildHeaderRow(),
							if (body != null) ...[
								if (header != null) const SizedBox(height: 12),
								body!,
							],
							if (footer != null) ...[
								const SizedBox(height: 12),
								footer!,
							],
							if (extraSlots != null)
								for (final slot in extraSlots!.values) ...[
									const SizedBox(height: 8),
									slot,
								],
						],
					),
				),
			),
		);

	}
}