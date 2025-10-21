import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';


class ToggleInput extends StatelessWidget {
  final String leftPlaceholder;
  final bool showAsterisk;
  final String rightLabel;
  final bool value;
  final ValueChanged<bool> onChanged;
  final TextEditingController? controller;
  final ValueChanged<String>? onTextChanged;
  final String? initialValue;

  const ToggleInput({
    super.key,
    required this.leftPlaceholder,
    this.showAsterisk = false,
    this.rightLabel = 'Text:',
    required this.value,
    required this.onChanged,
    this.controller,
    this.onTextChanged,
    this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    final Color textColor = AppTheme.lightTextPrimary;
    return Container(
      width: 370,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  leftPlaceholder,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (showAsterisk)
                  const Text(
                    ' *',
                    style: TextStyle(
                      color: AppTheme.stopColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: controller,
                    onChanged: onTextChanged,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: '',
                      hintStyle: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Text(
                rightLabel,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              CupertinoSwitch(
                value: value,
                onChanged: onChanged,
                activeTrackColor: AppTheme.lightPrimary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
