import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../constants/app_theme.dart';

class PromotionalFooter extends StatelessWidget {
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;
  final bool isFixed;

  const PromotionalFooter({
    Key? key,
    this.padding,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
    this.isFixed = false,
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
    final footerContent = Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.fromLTRB(
        AppTheme.spacingMedium,
        AppTheme.spacingSmall,
        AppTheme.spacingMedium,
        isFixed ? MediaQuery.of(context).padding.bottom + AppTheme.spacingSmall : AppTheme.spacingSmall,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            backgroundColor ?? Colors.white,
            backgroundColor ?? Colors.grey.shade50,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: isFixed 
          ? const BorderRadius.only(
              topLeft: Radius.circular(AppTheme.radiusLarge),
              topRight: Radius.circular(AppTheme.radiusLarge),
            )
          : BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.12),
            blurRadius: 20,
            offset: isFixed ? const Offset(0, -5) : const Offset(0, 2),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: isFixed ? const Offset(0, -2) : const Offset(0, 1),
          ),
        ],
        border: isFixed 
          ? Border(
              top: BorderSide(
                color: AppTheme.primaryColor.withOpacity(0.15),
                width: 1,
              ),
              left: BorderSide(
                color: AppTheme.primaryColor.withOpacity(0.1),
                width: 1,
              ),
              right: BorderSide(
                color: AppTheme.primaryColor.withOpacity(0.1),
                width: 1,
              ),
            )
          : Border.all(
              color: AppTheme.primaryColor.withOpacity(0.1),
              width: 1,
            ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingSmall),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              border: Border.all(
                color: AppTheme.primaryColor.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    Icons.code_outlined,
                    size: 12,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'تم التطوير بواسطة',
                  style: AppTheme.bodySmall.copyWith(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'شركة برمج',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingSmall),
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingSmall),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              border: Border.all(
                color: Colors.grey.shade200,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    Icons.phone_outlined,
                    size: 10,
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'للتواصل:',
                  style: AppTheme.bodySmall.copyWith(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(width: 6),
                _buildPhoneButton('733369085'),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 1,
                  height: 12,
                  color: Colors.grey.shade300,
                ),
                _buildPhoneButton('770497988'),
              ],
            ),
          ),
        ],
      ),
    );

    if (isFixed) {
      return Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: footerContent,
      );
    } else {
      return footerContent;
    }
  }

  Widget _buildPhoneButton(String phoneNumber) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: Colors.blue.shade200,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: () => _makePhoneCall(phoneNumber),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 3,
            ),
            child: Text(
              phoneNumber,
              style: AppTheme.bodySmall.copyWith(
                color: Colors.blue.shade700,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
