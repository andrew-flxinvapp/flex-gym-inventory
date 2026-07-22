import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

enum SubscriptionPlanCardVariant { monthly, yearly }

class SubscriptionPlanCard extends StatelessWidget {
	final String title;
	final String price;
	final String? badge;
	final String? subtext;
	final SubscriptionPlanCardVariant variant;
	final bool selected;
	final VoidCallback? onTap;

	const SubscriptionPlanCard({
		Key? key,
		required this.title,
		required this.price,
		this.badge,
		this.subtext,
		this.variant = SubscriptionPlanCardVariant.yearly,
		this.selected = false,
		this.onTap,
	}) : super(key: key);

	@override
	Widget build(BuildContext context) {
		final bool isMonthly = variant == SubscriptionPlanCardVariant.monthly;
		final bool isYearly = variant == SubscriptionPlanCardVariant.yearly;


		// Both variants use transparent background; strokes differ per variant
		final background = AppTheme.transparent;
		final Border? border = isMonthly
			? Border.all(color: AppTheme.updateColor, width: 1.5)
			: isYearly
				? Border.all(color: AppTheme.darkCard.withOpacity(0.5), width: 1.5)
				: null;

		// Title/price use darkTextPrimary on transparent backgrounds
		final titleColor = AppTheme.darkTextPrimary;
		final priceColor = AppTheme.darkTextPrimary;

		// Badge: monthly uses lightTextPrimary fill + updateColor text;
		// yearly uses #006519 at 30% opacity with successColor for text and stroke
		final badgeBg = isMonthly ? AppTheme.lightTextPrimary : const Color(0xFF006519).withOpacity(0.30);
		final badgeTextColor = isMonthly ? AppTheme.updateColor : AppTheme.successColor;

		return SizedBox(
			width: 177,
			height: 127,
			child: Material(
				color: Colors.transparent,
				child: InkWell(
					borderRadius: BorderRadius.circular(16),
					onTap: onTap,
					child: Container(
						padding: const EdgeInsets.all(12),
						decoration: BoxDecoration(
							color: background,
							borderRadius: BorderRadius.circular(16),
							border: border,
							boxShadow: isYearly
								? [
									BoxShadow(
										color: Colors.black.withOpacity(0.06),
										blurRadius: 6,
										offset: const Offset(0, 2),
									),
								]
								: null,
						),
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.center,
							children: [
								Text(
									title,
									textAlign: TextAlign.center,
									style: Theme.of(context).textTheme.bodyMedium?.copyWith(
										color: titleColor,
										fontWeight: FontWeight.w600,
									),
									maxLines: 1,
									overflow: TextOverflow.ellipsis,
								),
								const SizedBox(height: 8),
								Text(
									price,
									style: Theme.of(context).textTheme.titleSmall?.copyWith(
												color: priceColor,
												fontWeight: FontWeight.bold,
											),
								),
								if (badge != null && badge!.isNotEmpty)
									Padding(
										padding: const EdgeInsets.only(top: 8.0),
										child: Column(
											children: [
												Container(
													padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
													decoration: BoxDecoration(
														color: badgeBg,
														borderRadius: BorderRadius.circular(12),
														border: Border.all(color: isYearly ? AppTheme.successColor : AppTheme.updateColor, width: 1),
													),
													child: Text(
														badge!,
														style: Theme.of(context).textTheme.labelSmall?.copyWith(
															color: badgeTextColor,
															fontWeight: FontWeight.w600,
														),
													),
												),
												if (subtext != null && subtext!.isNotEmpty)
													Padding(
														padding: const EdgeInsets.only(top: 6.0),
														child: Text(
															subtext!,
															textAlign: TextAlign.center,
															style: Theme.of(context).textTheme.labelSmall?.copyWith(
																color: isYearly ? Theme.of(context).colorScheme.onPrimary.withOpacity(0.9) : Colors.black54,
																),
													),
												),
										],
										),
									),
								const Spacer(),
		
							],
						),
					),
				),
			),
		);
	}
}

