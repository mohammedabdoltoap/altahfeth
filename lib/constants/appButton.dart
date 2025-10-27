import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? color;
  final Color? foregroundColor;
  final double? width;
  final double? height;
  final double borderRadius;
  final IconData? icon;

  const AppButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.color,
    this.foregroundColor,
    this.width,
    this.height,
    this.borderRadius = 12,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // اترك الثيم يتحكم بالأنماط، وعدّل فقط اللون عند تمريره اختيارياً
    final ButtonStyle? themed = theme.elevatedButtonTheme.style;
    final ButtonStyle style = (themed ?? const ButtonStyle()).copyWith(
      backgroundColor: color != null ? MaterialStatePropertyAll<Color>(color!) : null,
      foregroundColor: foregroundColor != null ? MaterialStatePropertyAll<Color>(foregroundColor!) : null,
      shape: MaterialStatePropertyAll<RoundedRectangleBorder>(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
      ),
    );

    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: style,
        child: isLoading
            ? SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  color: theme.colorScheme.onPrimary,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
