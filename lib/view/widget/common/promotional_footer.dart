import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PromotionalFooter extends StatelessWidget {
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;

  const PromotionalFooter({
    Key? key,
    this.padding,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
  }) : super(key: key);

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.grey[100],
        border: Border(
          top: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.code,
                size: fontSize ?? 14,
                color: textColor ?? Colors.grey[700],
              ),
              const SizedBox(width: 6),
              Text(
                'تم التطوير بواسطة',
                style: TextStyle(
                  fontSize: fontSize ?? 13,
                  color: textColor ?? Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'شركة برمج',
                style: TextStyle(
                  fontSize: (fontSize ?? 13) + 1,
                  color: textColor ?? Colors.grey[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.phone,
                size: (fontSize ?? 14) - 2,
                color: textColor ?? Colors.grey[600],
              ),
              const SizedBox(width: 6),
              Text(
                'للتواصل:',
                style: TextStyle(
                  fontSize: (fontSize ?? 13) - 1,
                  color: textColor ?? Colors.grey[600],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => _makePhoneCall('733369085'),
                child: Text(
                  '733369085',
                  style: TextStyle(
                    fontSize: (fontSize ?? 13) - 1,
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '-',
                style: TextStyle(
                  fontSize: (fontSize ?? 13) - 1,
                  color: textColor ?? Colors.grey[600],
                ),
              ),
              const SizedBox(width: 4),
              InkWell(
                onTap: () => _makePhoneCall('770497988'),
                child: Text(
                  '770497988',
                  style: TextStyle(
                    fontSize: (fontSize ?? 13) - 1,
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
