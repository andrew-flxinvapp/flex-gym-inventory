import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class CustomMultilineTextInput extends StatefulWidget {
  final String hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final double width;
  final double height;
  final int maxLines;
  final int maxLength;
  final bool showAsterisk;

  const CustomMultilineTextInput({
    super.key,
    required this.hintText,
    this.controller,
    this.validator,
    this.width = double.infinity,
    this.height = 120,
    this.maxLines = 5,
    this.maxLength = 2000,
    this.showAsterisk = false,
  });

  @override
  State<CustomMultilineTextInput> createState() => _CustomMultilineTextInputState();
}

class _CustomMultilineTextInputState extends State<CustomMultilineTextInput> {
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
  void didUpdateWidget(covariant CustomMultilineTextInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == null && widget.controller != null) {
      _internalController?.dispose();
      _internalController = null;
    } else if (oldWidget.controller != null && widget.controller == null) {
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
        maxLines: widget.maxLines,
        maxLength: widget.maxLength,
        decoration: InputDecoration(
          counterText: '',
          hint: RichText(
            text: TextSpan(
              text: widget.hintText,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTextPrimary,
                    fontWeight: FontWeight.normal,
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
          contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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
