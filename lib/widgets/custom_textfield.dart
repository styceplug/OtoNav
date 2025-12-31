import 'package:flutter/material.dart';
import 'package:otonav/utils/colors.dart';

import '../utils/dimensions.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final TextStyle? hintStyle;
  final IconData? prefixIcon;
  final bool obscureText;
  final List<String>? autofillHints;
  final bool enabled;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final Color? textColor;
  final int? maxLines;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.hintStyle,
    this.prefixIcon,
    this.obscureText = false,
    this.enabled = true,
    this.suffixIcon,
    this.textColor,
    this.keyboardType = TextInputType.text,
    this.maxLines,
    this.onChanged,
    this.autofillHints,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Use theme-based colors
    final Color effectiveTextColor = textColor ?? Colors.black;
    final Color fillColor = AppColors.cardColor.withOpacity(0.7);
    final Color borderColor = Colors.transparent;
    final Color focusColor = theme.colorScheme.primary.withOpacity(0.6);
    final Color enabledBorderColor = Colors.transparent;

    return TextFormField(
      onChanged: onChanged,
      controller: controller,
      obscureText: obscureText,
      enabled: enabled,
      maxLines: maxLines,
      autofillHints: autofillHints,
      keyboardType: keyboardType,
      style: TextStyle(color: textColor, fontFamily: 'Poppins'),
      validator: validator,
      decoration: InputDecoration(
        filled: true,
        fillColor: fillColor,
        labelText: labelText,
        labelStyle:
            hintStyle ??
            TextStyle(
              color: textColor?.withOpacity(0.5),
              fontFamily: 'Poppins',
            ),
        hintText: hintText,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: textColor?.withOpacity(0.6))
            : null,
        suffixIcon: suffixIcon,
        hintStyle:
            hintStyle ??
            TextStyle(
              color: AppColors.black.withOpacity(0.2),
              fontFamily: 'Poppins',
            ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimensions.radius10),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimensions.radius10),
          borderSide: BorderSide(color: enabledBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimensions.radius10),
          borderSide: BorderSide(color: focusColor),
        ),
      ),
    );
  }
}
