import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class CustomTextInputField extends StatelessWidget {
  final String hintText;
  final bool showAsterisk;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int? maxLines;
  final double width;
  final double height;

  const CustomTextInputField({
    Key? key,
    required this.hintText,
    this.showAsterisk = false,
    this.controller,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
    this.width = 370,
    this.height = 50,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          children: [
            TextFormField(
              controller: controller,
              validator: validator,
              keyboardType: keyboardType,
              maxLines: maxLines,
              decoration: InputDecoration(
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
            ),
          ],
        ),
      ),
    );
  }
}
