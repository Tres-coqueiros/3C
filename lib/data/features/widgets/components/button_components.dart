import 'package:flutter/material.dart';

class ButtonComponents extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final Color textColor;
  final Color backgroundColor;
  final double fontSize;
  final EdgeInsetsGeometry padding;
  final Alignment textAlign;

  ButtonComponents({
    required this.onPressed,
    required this.text,
    required this.textColor,
    required this.backgroundColor,
    required this.fontSize,
    required this.padding,
    required this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: textAlign,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: textColor,
          backgroundColor: backgroundColor,
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(3.0),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: fontSize),
        ),
      ),
    );
  }
}
