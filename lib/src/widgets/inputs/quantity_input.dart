import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../theme/app_icons.dart';
import '../../../theme/app_theme.dart';

class QuantityInput extends StatefulWidget {
  final String hintText;
  final bool showAsterisk;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;
  final double width;
  final double height;

  const QuantityInput({
    super.key,
    required this.hintText,
    this.showAsterisk = false,
    this.controller,
    this.focusNode,
    this.validator,
    this.width = double.infinity,
    this.height = 50,
  });

  static String? validateQuantity(String? value) {
    final quantity = int.tryParse(value?.trim() ?? '');
    if (quantity == null || quantity < 1) {
      return 'Enter a whole number of 1 or more';
    }
    return null;
  }

  @override
  State<QuantityInput> createState() => _QuantityInputState();
}

class _QuantityInputState extends State<QuantityInput> {
  static const double _buttonExtent = 47;
  static final TextInputFormatter _digitsOnlyFormatter =
      TextInputFormatter.withFunction((oldValue, newValue) {
        if (newValue.text.isEmpty || RegExp(r'^\d+$').hasMatch(newValue.text)) {
          return newValue;
        }
        return oldValue;
      });

  late TextEditingController _effectiveController;
  late FocusNode _effectiveFocusNode;
  TextEditingController? _internalController;
  FocusNode? _internalFocusNode;

  @override
  void initState() {
    super.initState();
    _internalController =
        widget.controller == null ? TextEditingController() : null;
    _internalFocusNode = widget.focusNode == null ? FocusNode() : null;
    _effectiveController = widget.controller ?? _internalController!;
    _effectiveFocusNode = widget.focusNode ?? _internalFocusNode!;
    _effectiveController.addListener(_handleControllerChanged);
  }

  @override
  void didUpdateWidget(covariant QuantityInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      final oldController = _effectiveController;
      oldController.removeListener(_handleControllerChanged);
      if (widget.controller == null) {
        _internalController = TextEditingController.fromValue(
          oldController.value,
        );
        _effectiveController = _internalController!;
      } else {
        _internalController?.dispose();
        _internalController = null;
        _effectiveController = widget.controller!;
      }
      _effectiveController.addListener(_handleControllerChanged);
    }

    if (oldWidget.focusNode != widget.focusNode) {
      if (widget.focusNode == null) {
        _internalFocusNode = FocusNode();
        _effectiveFocusNode = _internalFocusNode!;
      } else {
        _internalFocusNode?.dispose();
        _internalFocusNode = null;
        _effectiveFocusNode = widget.focusNode!;
      }
    }
  }

  @override
  void dispose() {
    _effectiveController.removeListener(_handleControllerChanged);
    _internalController?.dispose();
    _internalFocusNode?.dispose();
    super.dispose();
  }

  void _handleControllerChanged() {
    if (mounted) setState(() {});
  }

  int? get _quantity => int.tryParse(_effectiveController.text.trim());

  bool get _canDecrement {
    final quantity = _quantity;
    return quantity != null && quantity > 1;
  }

  void _step(int amount) {
    final currentText = _effectiveController.text.trim();
    final current = int.tryParse(currentText);
    final int next;

    if (amount < 0) {
      if (current == null || current <= 1) return;
      next = current - 1;
    } else if (currentText.isEmpty) {
      next = 1;
    } else {
      if (current == null || current < 0) return;
      final incremented = current + 1;
      if (incremented <= current) return;
      next = incremented;
    }

    final shouldRestoreFocus = _effectiveFocusNode.hasFocus;
    _effectiveController.value = TextEditingValue(
      text: next.toString(),
      selection: TextSelection.collapsed(offset: next.toString().length),
    );

    if (shouldRestoreFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _effectiveFocusNode.requestFocus();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor =
        theme.textTheme.bodyMedium?.color ??
        (isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary);
    final disabledColor = theme.colorScheme.onSurface.withValues(alpha: 0.38);
    final dividerColor = theme.dividerColor;
    final fillColor = isDark ? AppTheme.darkCard : AppTheme.lightCard;

    return SizedBox(
      width: widget.width,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: widget.height),
        child: TextFormField(
          controller: _effectiveController,
          focusNode: _effectiveFocusNode,
          validator: widget.validator ?? QuantityInput.validateQuantity,
          keyboardType: TextInputType.number,
          inputFormatters: [_digitsOnlyFormatter],
          textAlign: TextAlign.left,
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            isDense: true,
            hint: RichText(
              text: TextSpan(
                text: widget.hintText,
                style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
                children:
                    widget.showAsterisk
                        ? [
                          TextSpan(
                            text: ' *',
                            style: theme.textTheme.bodySmall?.copyWith(
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
            fillColor: fillColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 11.5,
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
              borderSide: BorderSide(color: textColor, width: 4),
              borderRadius: BorderRadius.circular(16),
            ),
            suffixIconConstraints: const BoxConstraints(
              minWidth: _buttonExtent * 2 + 1,
              minHeight: _buttonExtent,
            ),
            suffixIcon: SizedBox(
              width: _buttonExtent * 2 + 1,
              child: Row(
                children: [
                  SizedBox(
                    width: _buttonExtent,
                    height: _buttonExtent,
                    child: IconButton(
                      tooltip: 'Decrease quantity',
                      onPressed: _canDecrement ? () => _step(-1) : null,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints.tightFor(
                        width: _buttonExtent,
                        height: _buttonExtent,
                      ),
                      icon: SvgPicture.asset(
                        AppIcons.quantityMinus,
                        width: 20,
                        height: 20,
                        colorFilter: ColorFilter.mode(
                          _canDecrement ? textColor : disabledColor,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                  Container(width: 1, height: 24, color: dividerColor),
                  SizedBox(
                    width: _buttonExtent,
                    height: _buttonExtent,
                    child: IconButton(
                      tooltip: 'Increase quantity',
                      onPressed: () => _step(1),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints.tightFor(
                        width: _buttonExtent,
                        height: _buttonExtent,
                      ),
                      icon: SvgPicture.asset(
                        AppIcons.quantityPlus,
                        width: 20,
                        height: 20,
                        colorFilter: ColorFilter.mode(
                          textColor,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
