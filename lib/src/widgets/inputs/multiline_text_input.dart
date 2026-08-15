import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class CustomMultilineTextInput extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final double width;
  final double height;
  final int maxLines;
  final bool showAsterisk;

  const CustomMultilineTextInput({
    super.key,
    required this.hintText,
    this.controller,
    this.validator,
    this.width = double.infinity,
    this.height = 120,
    this.maxLines = 5,
    this.showAsterisk = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: width,
        height: height,
        child: TextFormField(
          controller: controller,
          validator: validator,
          maxLines: maxLines,
          decoration: InputDecoration(
            alignLabelWithHint: true,
            label: Align(
              alignment: Alignment.topLeft,
              child: RichText(
                text: TextSpan(
                  text: hintText,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTextPrimary,
                    fontWeight: FontWeight.normal,
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
            ),
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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
        ),
      ),
    );
  }
}
