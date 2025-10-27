import 'package:flutter/material.dart';

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
    final theme = Theme.of(context);
    
    dynamic displayValue = value;
    
    // التحقق من وجود القيمة في القائمة
    if (items.isNotEmpty && displayValue != null) {
      bool valueExists = items.any((item) => item[valueKey] == displayValue);
      if (!valueExists) {
        displayValue = null; // إذا القيمة غير موجودة، نجعلها null
      }
    }
    
    // إذا كانت القيمة 0 أو null، نجعلها null
    if (displayValue == 0 || displayValue == null) {
      displayValue = null;
    }
    
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<dynamic>(
        decoration: InputDecoration(
          labelText: label,
          hintText: items.isEmpty ? "لا توجد بيانات" : label,
          filled: theme.inputDecorationTheme.filled,
          fillColor: fillColor ?? theme.inputDecorationTheme.fillColor,
          prefixIcon: icon != null ? Icon(icon, color: theme.colorScheme.primary.withOpacity(0.7)) : null,
        ),
        value: displayValue,
        isExpanded: true,
        items: items.isEmpty 
          ? null 
          : items.map((item) {
              return DropdownMenuItem<dynamic>(
                value: item[valueKey],
                child: Text(
                  item[displayKey].toString(),
                  style: const TextStyle(fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
        onChanged: items.isEmpty ? null : onChanged,
      ),
    );
  }
}
