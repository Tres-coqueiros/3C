import 'package:flutter/material.dart';

class ButtonComponents extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final Color textColor;
  final Color backgroundColor;
  final double fontSize;
  final EdgeInsetsGeometry padding;
  final Alignment textAlign;
  final bool isLoading;
  final double borderRadius;
  final double elevation;
  final IconData? icon;

  ButtonComponents({
    required this.onPressed,
    required this.text,
    required this.textColor,
    required this.backgroundColor,
    required this.fontSize,
    required this.padding,
    required this.textAlign,
    this.isLoading = false,
    this.borderRadius = 4.0,
    this.elevation = 4.0,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: textAlign,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: textColor,
          backgroundColor: backgroundColor,
          padding: padding,
          elevation: elevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: textColor,
                  strokeWidth: 3,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: textColor),
                    SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: TextStyle(fontSize: fontSize),
                  ),
                ],
              ),
      ),
    );
  }
}
