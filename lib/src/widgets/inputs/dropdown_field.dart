import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class CustomDropdownField<T> extends StatelessWidget {
  final String hintText;
  final bool showAsterisk;
  final List<T> items;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final String Function(T)? getLabel;
  final double width;
  final double height;
  final String? Function(T?)? validator;

  const CustomDropdownField({
    Key? key,
    required this.hintText,
    required this.items,
    this.value,
    this.onChanged,
    this.getLabel,
    this.showAsterisk = false,
    this.width = 370,
    this.height = 50,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: width,
        height: height,
        child: DropdownButtonFormField<T>(
          value: value,
          validator: validator,
          decoration: InputDecoration(
            hintText: null,
            label: RichText(
              text: TextSpan(
                text: hintText,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTextPrimary,
                ),
                children: showAsterisk
                    ? [
                        TextSpan(
                          text: ' *',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.stopColor,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ]
                    : [],
              ),
            ),
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.lightTextPrimary),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.lightTextPrimary,
          ),
          dropdownColor: Colors.white,
          items: items.map((item) {
            final label = getLabel != null
                ? getLabel!(item)
                : item.toString().split('.').last;
            return DropdownMenuItem<T>(
              value: item,
              child: Text(label),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
