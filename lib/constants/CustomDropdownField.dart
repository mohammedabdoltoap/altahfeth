import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

class CustomDropdownField extends StatelessWidget {
  final String label;
  final List<Map<String, dynamic>> items; // <-- هنا نحفظ قائمة من خرائط
  final dynamic value; // ممكن تكون int أو String
  final Function(dynamic)? onChanged;
  final String valueKey; // اسم المفتاح اللي يمثل القيمة (مثل id)
  final String displayKey; // اسم المفتاح اللي يمثل الاسم المعروض (مثل name)
  final IconData? icon;
  final Color? fillColor;
  final EdgeInsetsGeometry? margin;

  const CustomDropdownField({
    Key? key,
    required this.label,
    required this.items,
    required this.value,
    required this.onChanged,
    required this.valueKey,
    required this.displayKey,
    this.icon,
    this.fillColor,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
        return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<dynamic>(
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: fillColor ?? Colors.white,
          prefixIcon: icon != null ? Icon(icon, color: Colors.teal) : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        value: value,
        items: items.map((item) {
          return DropdownMenuItem<dynamic>(
            value: item[valueKey],
            child: Text(
              item[displayKey].toString(),
              style: const TextStyle(fontSize: 16),
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
      },);
      }
}
