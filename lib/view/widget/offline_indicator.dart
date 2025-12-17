import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/ConnectivityHelper.dart';
import '../../constants/app_theme.dart';

/// 🌐 مؤشر الاتصال بالإنترنت
/// يعرض شريط في أعلى الشاشة عند فقدان الاتصال
class OfflineIndicator extends StatelessWidget {
  final ConnectivityHelper connectivityHelper = Get.find<ConnectivityHelper>();

  OfflineIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // إذا كان هناك اتصال: لا تعرض شيء
      if (connectivityHelper.isOnline.value) {
        return const SizedBox.shrink();
      }

      // إذا لم يكن هناك اتصال: عرض شريط التحذير
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Colors.red.shade700,
              Colors.red.shade600,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // أيقونة الاتصال المقطوع
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            // النص
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'بدون اتصال إنترنت',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'البيانات المعروضة قد تكون قديمة',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // أيقونة التنبيه
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      );
    });
  }
}

/// 🌐 مؤشر اتصال بديل - نسخة مضغوطة
class CompactOfflineIndicator extends StatelessWidget {
  final ConnectivityHelper connectivityHelper = Get.find<ConnectivityHelper>();

  CompactOfflineIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (connectivityHelper.isOnline.value) {
        return const SizedBox.shrink();
      }

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.red.shade600,
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.wifi_off,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            const Text(
              'بدون اتصال إنترنت',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    });
  }
}

/// 🌐 مؤشر اتصال متقدم - مع حالات مختلفة
class AdvancedOfflineIndicator extends StatelessWidget {
  final ConnectivityHelper connectivityHelper = Get.find<ConnectivityHelper>();
  final bool showDetails;

  AdvancedOfflineIndicator({
    Key? key,
    this.showDetails = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (connectivityHelper.isOnline.value) {
        return const SizedBox.shrink();
      }

      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Colors.orange.shade700,
              Colors.red.shade600,
            ],
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                // أيقونة متحركة
                SizedBox(
                  width: 32,
                  height: 32,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const Icon(
                        Icons.wifi_off,
                        color: Colors.white,
                        size: 18,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // النص الرئيسي
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '⚠️ بدون اتصال إنترنت',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      if (showDetails) ...[
                        const SizedBox(height: 2),
                        Text(
                          'تم تفعيل الوضع بدون اتصال',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (showDetails) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'البيانات المعروضة محفوظة محلياً وقد تكون قديمة. اتصل بالإنترنت لتحديث البيانات.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    });
  }
}
