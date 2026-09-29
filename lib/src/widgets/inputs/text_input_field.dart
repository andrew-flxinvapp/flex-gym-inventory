import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class CustomTextInputField extends StatefulWidget {
  final String hintText;
  final bool showAsterisk;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int? maxLines;
  final double width;
  final double height;

  const CustomTextInputField({
    super.key,
    required this.hintText,
    this.showAsterisk = false,
    this.controller,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
    this.width = double.infinity,
    this.height = 50,
  });
  @override
  State<CustomTextInputField> createState() => _CustomTextInputFieldState();
}

class _CustomTextInputFieldState extends State<CustomTextInputField> {
  TextEditingController? _internalController;

  TextEditingController get _effectiveController => widget.controller ?? _internalController!;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _internalController = TextEditingController();
    }
  }

  @override
  void didUpdateWidget(covariant CustomTextInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == null && widget.controller != null) {
      // external controller provided now — dispose internal
      _internalController?.dispose();
      _internalController = null;
    } else if (oldWidget.controller != null && widget.controller == null) {
      // external controller removed — create internal
      _internalController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _internalController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: TextFormField(
        controller: _effectiveController,
        validator: widget.validator,
        keyboardType: widget.keyboardType,
        maxLines: widget.maxLines,
        decoration: InputDecoration(
          hint: RichText(
            text: TextSpan(
              text: widget.hintText,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTextPrimary,
                  ),
              children: widget.showAsterisk
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
          floatingLabelBehavior: FloatingLabelBehavior.never,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: AppTheme.lightTextPrimary,
              width: 4,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}