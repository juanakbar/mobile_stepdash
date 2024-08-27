import 'package:flutter/material.dart';

class FormFieldApp extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final bool isPassword;
  final TextInputType keyboardType;
  final int maxLine;
  final bool readOnly;
  final String? initialValue;
  final String? validator;
  final String label;

  const FormFieldApp({
    this.controller,
    this.hintText,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.maxLine = 1,
    this.readOnly = false,
    this.validator,
    this.initialValue,
    this.label = '',
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: keyboardType,
      controller: controller,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validator;
        }
        return null;
      },
      decoration: InputDecoration(
        label: Text(label),
        hintText: hintText,
        hintStyle: const TextStyle(
          fontFamily: 'Poppins',
          color: Colors.black26,
        ),
        border: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.black12, // Default border color
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.black12, // Default border color
          ),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
