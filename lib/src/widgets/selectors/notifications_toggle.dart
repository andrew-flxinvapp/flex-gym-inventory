import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '/../../theme/app_theme.dart';



class NotificationsToggle extends StatefulWidget {
	final String label;
	final bool initialValue;
	final ValueChanged<bool>? onChanged;

	const NotificationsToggle({
		super.key,
		required this.label,
		this.initialValue = false,
		this.onChanged,
	});

	@override
	State<NotificationsToggle> createState() => _NotificationsToggleState();
}

class _NotificationsToggleState extends State<NotificationsToggle> {
	late bool _value;

	@override
	void initState() {
		super.initState();
		_value = widget.initialValue;
	}

	@override
	Widget build(BuildContext context) {
		return Container(
			width: 370,
			height: 50,
			decoration: BoxDecoration(
				color: AppTheme.lightCard,
				borderRadius: BorderRadius.circular(16),
			),
			padding: const EdgeInsets.symmetric(horizontal: 20),
			child: Row(
				mainAxisAlignment: MainAxisAlignment.spaceBetween,
				children: [
								Text(
									widget.label,
									style: Theme.of(context).textTheme.bodyMedium?.copyWith(
														color: AppTheme.lightTextPrimary,
													),
								),
					CupertinoSwitch(
						value: _value,
						onChanged: (val) {
							setState(() => _value = val);
							if (widget.onChanged != null) widget.onChanged!(val);
						},
					),
				],
			),
		);
	}
}
