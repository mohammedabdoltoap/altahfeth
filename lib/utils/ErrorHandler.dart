import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../view/screen/errorScreen/CustomErrorScreen.dart';

class ErrorHandler {
  static void initialize() {
    // معالج الأخطاء العام لـ Flutter
    FlutterError.onError = (FlutterErrorDetails details) {
      // طباعة الخطأ في وضع التطوير
      if (kDebugMode) {
        FlutterError.presentError(details);
      } else {
        // في وضع الإنتاج، عرض صفحة الخطأ المخصصة
        _handleFlutterError(details);
      }
    };

    // معالج الأخطاء للمنطقة (Zone errors)
    PlatformDispatcher.instance.onError = (error, stack) {
      if (kDebugMode) {
        developer.log(
          'Uncaught error',
          error: error,
          stackTrace: stack,
        );
      } else {
        _handlePlatformError(error, stack);
      }
      return true;
    };
  }

  static void _handleFlutterError(FlutterErrorDetails details) {
    // تسجيل الخطأ
    _logError(details.exception, details.stack);
    
    // عرض صفحة الخطأ المخصصة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.context != null) {
        _showErrorScreen(
          message: "حدث خطأ في واجهة التطبيق",
          details: details.exception.toString(),
        );
      }
    });
  }

  static void _handlePlatformError(Object error, StackTrace stack) {
    // تسجيل الخطأ
    _logError(error, stack);
    
    // عرض صفحة الخطأ المخصصة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.context != null) {
        _showErrorScreen(
          message: "حدث خطأ غير متوقع في التطبيق",
          details: error.toString(),
        );
      }
    });
  }

  static void _logError(Object error, StackTrace? stack) {
    // هنا يمكن إضافة كود لإرسال الأخطاء إلى خدمة مراقبة مثل Firebase Crashlytics
    developer.log(
      'Application Error',
      error: error,
      stackTrace: stack,
      time: DateTime.now(),
    );
  }

  static void _showErrorScreen({
    required String message,
    String? details,
  }) {
    try {
      Get.to(() => CustomErrorScreen(
        errorMessage: message,
        errorDetails: details,
        onRetry: () {
          Get.back();
          // يمكن إضافة منطق إعادة المحاولة هنا
        },
      ));
    } catch (e) {
      // إذا فشل عرض صفحة الخطأ، اعرض snackbar بسيط
      if (Get.context != null) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: "العودة",
              textColor: Colors.white,
              onPressed: () {
                if (Get.context != null && Navigator.canPop(Get.context!)) {
                  Get.back();
                }
              },
            ),
          ),
        );
      }
    }
  }

  // دالة للتعامل مع أخطاء API
  static void handleApiError(dynamic error, {VoidCallback? onRetry}) {
    String message = "حدث خطأ في الاتصال بالخادم";

    if (error is Exception) {
      message = error.toString().replaceAll('Exception: ', '');
    } else if (error is String) {
      message = error;
    } else {
      message = error.toString();
    }

    // عرض Snackbar بدلاً من صفحة الخطأ
    Get.snackbar(
      "خطأ في الخادم",
      message,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade800,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 4),
      icon: const Icon(Icons.error_outline, color: Colors.red),
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
    );
  }

  // دالة للتعامل مع أخطاء الشبكة
  static void handleNetworkError({VoidCallback? onRetry}) {
    // عرض Snackbar بدلاً من صفحة الخطأ
    Get.snackbar(
      "خطأ في الاتصال",
      "تحقق من اتصالك بالإنترنت وحاول مرة أخرى",
      backgroundColor: Colors.orange.shade100,
      colorText: Colors.orange.shade800,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 4),
      icon: const Icon(Icons.wifi_off, color: Colors.orange),
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
    );
  }

  // دالة للتعامل مع أخطاء التحقق من البيانات
  static void handleValidationError(String message) {
    Get.snackbar(
      "خطأ في البيانات",
      message,
      backgroundColor: Colors.orange.shade100,
      colorText: Colors.orange.shade800,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.warning, color: Colors.orange),
    );
  }

  // دالة عامة للتعامل مع أي خطأ
  static void handleError(dynamic error, {
    String? customMessage,
    VoidCallback? onRetry,
    bool showSnackbar = true, // تم تغيير القيمة الافتراضية إلى true
  }) {
    String message = customMessage ?? "حدث خطأ غير متوقع";
    
    if (showSnackbar) {
      Get.snackbar(
        "خطأ",
        message,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
        icon: const Icon(Icons.error, color: Colors.red),
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
      );
    } else {
      _showErrorScreen(
        message: message,
        details: error?.toString(),
      );
    }

    // تسجيل الخطأ
    _logError(error ?? "Unknown error", StackTrace.current);
  }
}
