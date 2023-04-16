import 'package:alert_up_project/utilities/constants.dart';
import 'package:flutter/material.dart';

InputDecoration textFieldStyle(
    {String? label,
    String? hint,
    Color? backgroundColor,
    Widget? suffixIcon,
    Widget? prefixIcon,
    String? suffix,
    String? prefix,
    String? counterText}) {
  return InputDecoration(
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(5),
      ),
      counterText: counterText,
      prefix: prefix != null ? Text(prefix) : null,
      prefixIcon: prefixIcon,
      fillColor: backgroundColor ?? ACCENT_COLOR.withOpacity(.05),
      filled: true,
      errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red, width: 0.0),
      ),
      suffix: suffix != null ? Text(suffix) : null,
      suffixIcon: suffixIcon,
      hintText: hint,
      labelText: label);
}
