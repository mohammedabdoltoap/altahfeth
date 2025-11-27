import 'dart:developer' as developer;
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../view/screen/errorScreen/CustomErrorScreen.dart';

class ErrorHandler {
  static bool _isInitialized = false;
  static final Set<String> _handledErrors = <String>{};

  static void initialize() {
    if (_isInitialized) return;
    _isInitialized = true;

    // معالج الأخطاء العام لـ Flutter - يمنع الشاشة الحمراء دائماً
    FlutterError.onError = (FlutterErrorDetails details) {
      _logError(details.exception, details.stack);
      
      // منع ظهور الشاشة الحمراء في جميع الأوضاع
      if (kDebugMode) {
        // في وضع التطوير، اطبع في الكونسول فقط
        developer.log(
          'Flutter Error Intercepted',
          error: details.exception,
          stackTrace: details.stack,
        );
      }
      
      // عرض واجهة مخصصة بدلاً من الشاشة الحمراء
      _handleFlutterError(details);
    };

    // معالج الأخطاء للمنطقة (Zone errors) - يمنع الأخطاء غير المعالجة
    PlatformDispatcher.instance.onError = (error, stack) {
      _logError(error, stack);
      
      if (kDebugMode) {
        developer.log(
          'Platform Error Intercepted',
          error: error,
          stackTrace: stack,
        );
      }
      
      // عرض واجهة مخصصة بدلاً من crash
      _handlePlatformError(error, stack);
      return true; // منع انتشار الخطأ
    };
  }

  static void _handleFlutterError(FlutterErrorDetails details) {
    // منع تكرار معالجة نفس الخطأ
    String errorKey = '${details.exception.runtimeType}_${details.exception.toString().hashCode}';
    if (_handledErrors.contains(errorKey)) return;
    _handledErrors.add(errorKey);
    
    // تنظيف الذاكرة إذا أصبحت كبيرة
    if (_handledErrors.length > 100) {
      _handledErrors.clear();
    }
    
    // عرض واجهة آمنة بدلاً من الشاشة الحمراء
    _safeShowError(
      message: "حدث خطأ في واجهة التطبيق",
      details: details.exception.toString(),
    );
  }

  static void _handlePlatformError(Object error, StackTrace stack) {
    // منع تكرار معالجة نفس الخطأ
    String errorKey = '${error.runtimeType}_${error.toString().hashCode}';
    if (_handledErrors.contains(errorKey)) return;
    _handledErrors.add(errorKey);
    
    // تنظيف الذاكرة إذا أصبحت كبيرة
    if (_handledErrors.length > 100) {
      _handledErrors.clear();
    }
    
    // عرض واجهة آمنة بدلاً من crash
    _safeShowError(
      message: "حدث خطأ غير متوقع في التطبيق",
      details: error.toString(),
    );
  }

  // دالة آمنة لعرض الأخطاء مع طرق بديلة متعددة
  static void _safeShowError({
    required String message,
    String? details,
  }) {
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _tryShowErrorScreen(message, details);
      });
    } catch (e) {
      // إذا فشل كل شيء، اطبع في الكونسول فقط
      developer.log('Failed to show error UI: $e');
    }
  }

  // محاولة عرض واجهة الخطأ مع طرق بديلة
  static void _tryShowErrorScreen(String message, String? details) {
    try {
      // الطريقة الأولى: صفحة خطأ مخصصة
      if (Get.context != null) {
        _showErrorScreen(message: message, details: details);
        return;
      }
    } catch (e) {
      developer.log('Custom error screen failed: $e');
    }

    try {
      // الطريقة الثانية: Snackbar
      if (Get.context != null) {
        Get.snackbar(
          "خطأ في التطبيق",
          message,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade800,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 5),
          icon: const Icon(Icons.error, color: Colors.red),
        );
        return;
      }
    } catch (e) {
      developer.log('Snackbar failed: $e');
    }

    try {
      // الطريقة الثالثة: Dialog بسيط
      if (Get.context != null) {
        showDialog(
          context: Get.context!,
          barrierDismissible: true,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.error, color: Colors.red),
                SizedBox(width: 8),
                Text("خطأ"),
              ],
            ),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("موافق"),
              ),
            ],
          ),
        );
        return;
      }
    } catch (e) {
      developer.log('Dialog failed: $e');
    }

    // الطريقة الأخيرة: طباعة فقط
    developer.log('Error UI fallback: $message');
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
    bool showSnackbar = true,
  }) {
    String message = customMessage ?? "حدث خطأ غير متوقع";
    
    // منع تكرار معالجة نفس الخطأ
    String errorKey = '${error.runtimeType}_${error.toString().hashCode}';
    if (_handledErrors.contains(errorKey)) return;
    _handledErrors.add(errorKey);
    
    if (showSnackbar) {
      _safeShowSnackbar(message);
    } else {
      _safeShowError(message: message, details: error?.toString());
    }

    // تسجيل الخطأ
    _logError(error ?? "Unknown error", StackTrace.current);
  }

  // دالة آمنة لعرض Snackbar
  static void _safeShowSnackbar(String message) {
    try {
      if (Get.context != null) {
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
      }
    } catch (e) {
      developer.log('Snackbar display failed: $e');
    }
  }

  // دالة ديناميكية لحماية أي دالة غير متزامنة
  static Future<T?> safeExecute<T>(
    Future<T> Function() function, {
    String? errorMessage,
    bool showSnackbar = true,
    VoidCallback? onError,
  }) async {
    try {
      return await function();
    } catch (error, stackTrace) {
      _logError(error, stackTrace);
      
      String message = errorMessage ?? "حدث خطأ أثناء تنفيذ العملية";
      
      if (showSnackbar) {
        _safeShowSnackbar(message);
      } else {
        _safeShowError(message: message, details: error.toString());
      }
      
      onError?.call();
      return null;
    }
  }

  // دالة ديناميكية لحماية أي دالة متزامنة
  static T? safeExecuteSync<T>(
    T Function() function, {
    String? errorMessage,
    bool showSnackbar = true,
    VoidCallback? onError,
  }) {
    try {
      return function();
    } catch (error, stackTrace) {
      _logError(error, stackTrace);
      
      String message = errorMessage ?? "حدث خطأ أثناء تنفيذ العملية";
      
      if (showSnackbar) {
        _safeShowSnackbar(message);
      } else {
        _safeShowError(message: message, details: error.toString());
      }
      
      onError?.call();
      return null;
    }
  }

  // دالة خاصة لحماية دوال PDF
  static Future<void> safePdfGeneration(
    Future<void> Function() pdfFunction, {
    String? customMessage,
  }) async {
    await safeExecute(
      pdfFunction,
      errorMessage: customMessage ?? "حدث خطأ أثناء إنشاء التقرير",
      showSnackbar: true,
    );
  }

  // دالة خاصة لحماية دوال API
  static Future<T?> safeApiCall<T>(
    Future<T> Function() apiFunction, {
    String? customMessage,
  }) async {
    return await safeExecute(
      apiFunction,
      errorMessage: customMessage ?? "حدث خطأ في الاتصال بالخادم",
      showSnackbar: true,
    );
  }

  // دالة لحماية دوال UI
  static void safeUIOperation(
    VoidCallback uiFunction, {
    String? errorMessage,
  }) {
    safeExecuteSync(
      () {
        uiFunction();
        return null;
      },
      errorMessage: errorMessage ?? "حدث خطأ في واجهة المستخدم",
      showSnackbar: true,
    );
  }
}
