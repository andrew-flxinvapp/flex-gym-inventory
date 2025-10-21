import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
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
    super.key,
    required this.hintText,
    this.showAsterisk = false,
    required this.items,
    required this.value,
    required this.onChanged,
    this.getLabel,
    this.width = 360,
    this.height = 56,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: width,
        height: height,
        child: DropdownButtonFormField2<T>(
          value: value,
          validator: validator,
          onChanged: onChanged,
          isExpanded: true, // keep child filling the field width

          // --- Label with optional asterisk (matches your current look) ---
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
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

          // --- Field (closed button) presentation ---
          buttonStyleData: ButtonStyleData(
            height: height,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),

          iconStyleData: IconStyleData(
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
            iconEnabledColor: AppTheme.lightTextPrimary,
            iconDisabledColor: AppTheme.lightTextPrimary.withValues(alpha: 0.4),
          ),

          // --- The key fix: force the menu to match the field width ---
          dropdownStyleData: DropdownStyleData(
            width: width,               // <- menu equals closed widget width
            maxHeight: 320,
            elevation: 4,
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            offset: const Offset(0, 4),
            useSafeArea: true,
          ),

          menuItemStyleData: const MenuItemStyleData(
            height: 48,
            padding: EdgeInsets.symmetric(horizontal: 12),
          ),

          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTextPrimary,
              ),

          items: items.map((item) {
            final label = getLabel != null
                ? getLabel!(item)
                : item.toString().split('.').last;
            return DropdownMenuItem<T>(
              value: item,
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
