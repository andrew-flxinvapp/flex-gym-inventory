import 'package:flutter/material.dart';
import 'package:flex_gym_inventory/theme/app_theme.dart';

class DeleteAccountSelector extends StatelessWidget {
	final bool selected;
	final VoidCallback? onTap;
	final String text;

	const DeleteAccountSelector({
		Key? key,
		required this.selected,
		required this.text,
		this.onTap,
	}) : super(key: key);

	@override
	Widget build(BuildContext context) {
		return InkWell(
			onTap: onTap,
			child: Row(
				children: [
					Radio<bool>(
						value: true,
						groupValue: selected,
						onChanged: (_) => onTap?.call(),
					),
								const SizedBox(width: 8),
						Expanded(
							child: Text(
								text,
								style: Theme.of(context).textTheme.bodySmall?.copyWith(
									color: AppTheme.lightTextPrimary,
								),
								overflow: TextOverflow.visible,
								softWrap: true,
							),
								),
				],
			),
		);
	}
}
