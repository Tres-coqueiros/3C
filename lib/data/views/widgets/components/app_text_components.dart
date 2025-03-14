import 'package:flutter/material.dart';
import 'package:senior/data/views/widgets/components/app_colors_components.dart';

class AppTextComponents extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool readOnly;
  final bool isNumeric;
  final bool isRequired;
  final bool autoFocus;
  final int maxLines;

  const AppTextComponents({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.readOnly = false,
    this.isNumeric = false,
    this.isRequired = true,
    this.autoFocus = false,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      autofocus: autoFocus,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.grey[300]!,
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.grey[300]!,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColorsComponents.primary,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        suffixIcon: !isRequired
            ? Tooltip(
                message: "Campo opcional",
                child: Icon(Icons.info_outline, color: Colors.grey[600]),
              )
            : null,
      ),
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return "Campo obrigatório";
        }
        return null;
      },
    );
  }
}
