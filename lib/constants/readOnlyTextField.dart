import 'package:flutter/material.dart';

class ReadOnlyTextField extends StatelessWidget {
  final String label;
  final String? value;
  final IconData? icon;
  final Color color;
  final Color color_line;

  const ReadOnlyTextField({
    Key? key,
    required this.label,
    this.value,
    this.icon,
    this.color = Colors.teal,
    this.color_line=Colors.grey,
    // اللون الافتراضي
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: false, // فقط للعرض
      initialValue: value ?? "",

      decoration: InputDecoration(
        prefixIcon: icon != null ? Icon(icon, color: color) : null,
        labelText: label,
        labelStyle: TextStyle(color: color),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      style:  TextStyle(fontSize: 15,fontWeight:FontWeight.bold,color: color_line ),
    );
  }
}
