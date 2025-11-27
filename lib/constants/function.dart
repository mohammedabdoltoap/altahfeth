
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'dart:async';
import 'dart:io';
import '../controller/NewWork/NetworkController.dart';
import '../utils/ErrorHandler.dart';
import 'loadingWidget.dart';

// ========== دوال مساعدة لحماية التطبيق من الأخطاء ==========

/// دالة لحماية دوال PDF من الأخطاء
Future<void> safePdfExecution(
  Future<void> Function() pdfFunction, {
  String? customMessage,
}) async {
  await ErrorHandler.safePdfGeneration(
    pdfFunction,
    customMessage: customMessage,
  );
}

/// دالة لحماية دوال API من الأخطاء
Future<T?> safeApiExecution<T>(
  Future<T> Function() apiFunction, {
  String? customMessage,
}) async {
  return await ErrorHandler.safeApiCall<T>(
    apiFunction,
    customMessage: customMessage,
  );
}

/// دالة عامة لحماية أي دالة غير متزامنة
Future<T?> safeExecution<T>(
  Future<T> Function() function, {
  String? errorMessage,
  bool showSnackbar = true,
  VoidCallback? onError,
}) async {
  return await ErrorHandler.safeExecute<T>(
    function,
    errorMessage: errorMessage,
    showSnackbar: showSnackbar,
    onError: onError,
  );
}

/// دالة لحماية أي دالة متزامنة
T? safeSyncExecution<T>(
  T Function() function, {
  String? errorMessage,
  bool showSnackbar = true,
  VoidCallback? onError,
}) {
  return ErrorHandler.safeExecuteSync<T>(
    function,
    errorMessage: errorMessage,
    showSnackbar: showSnackbar,
    onError: onError,
  );
}

/// دالة لحماية عمليات واجهة المستخدم
void safeUIExecution(
  VoidCallback uiFunction, {
  String? errorMessage,
}) {
  ErrorHandler.safeUIOperation(
    uiFunction,
    errorMessage: errorMessage,
  );
}

mySnackbar( titile, messige,{type="r"}){
  final Color bg = type=="r" ? Colors.red : type=="y" ? Colors.amberAccent : Colors.green;
  Get.snackbar(
    "$titile",
    "$messige",
    colorText: Colors.white,
    backgroundColor: bg,
    duration: const Duration(seconds: 3),
    snackPosition: SnackPosition.BOTTOM,
    margin: const EdgeInsets.all(12),
    borderRadius: 12,
  );
}

Future<T?> handleRequest<T>({
  required RxBool isLoading,
  required Future<T> Function() action,
  String loadingMessage = "جاري المعالجة...",
  String defaultErrorTitle = "خطأ",
    bool useDialog = true,
  bool immediateLoading = false,
}) async {
  if (isLoading.value) return null;
  if (immediateLoading) {
    isLoading.value = true;
  }

  //
  if (!await checkInternet()) {
    isLoading.value = false; // إيقاف Loading في جميع الحالات
    return null;
  }

  String? _message;
  String _title = defaultErrorTitle;
  if (!immediateLoading) {
    isLoading.value = true;
  }
  try {
    if (useDialog) {
      // تصميم حديث للويدجت مع تدرّج وظل لتفاصيل بصرية محسّنة
      final theme = Get.theme;
      final cs = theme.colorScheme;
      final txt = theme.textTheme;
      final Widget overlay = Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                cs.surface,
                cs.surfaceVariant,
              ],
            ),
            border: Border.all(color: cs.primary.withOpacity(0.4), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 28,
                width: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 3.2,
                  valueColor: AlwaysStoppedAnimation(cs.primary),
                ),
              ),
              const SizedBox(width: 14),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loadingMessage,
                    style: txt.bodyMedium?.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 200,
                    height: 6,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        backgroundColor: cs.outlineVariant.withOpacity(0.35),
                        valueColor: AlwaysStoppedAnimation(cs.primary),
                        minHeight: 6,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
      return await Get.showOverlay<T?>(
        asyncFunction: () async {
          final start = DateTime.now();
          
          // ✅ زيادة المهلة للنت الضعيف
          final result = await action().timeout(const Duration(seconds: 25));
          
          // ✅ منع الوميض: إذا كان النت سريع جداً، انتظر قليلاً
          final elapsed = DateTime.now().difference(start);
          const minDisplayDuration = Duration(milliseconds: 500);
          if (elapsed < minDisplayDuration) {
            await Future.delayed(minDisplayDuration - elapsed);
          }
          
          return result;
        },
        loadingWidget: overlay,
        opacityColor: theme.colorScheme.scrim.withOpacity(0.25),
        opacity: 1,

      );
    } else {
      // ✅ زيادة المهلة للنت الضعيف
      final result = await action().timeout(const Duration(seconds: 25));
      return result;
    }
  } on TimeoutException {
    // ✅ رسالة واضحة
    _message = "انتهت مهلة الاتصال (25 ثانية).\nتحقق من سرعة الإنترنت وحاول مرة أخرى";
    mySnackbar("انتهت المهلة", _message, type: "r");
    return null;
  } on SocketException catch (e) {
    // ✅ رسالة واضحة - ErrorHandler سيعرضها
    if (e.osError?.errorCode == 7) {
      _message = "لا يمكن الوصول للخادم. تحقق من اتصالك بالإنترنت";
    } else if (e.osError?.errorCode == 111) {
      _message = "الخادم غير متاح حالياً. حاول مرة أخرى بعد قليل";
    } else {
      _message = "فشل الاتصال بالخادم. تحقق من الإنترنت";
    }
    ErrorHandler.handleNetworkError();
    return null;
  } on HandshakeException {
    // ✅ رسالة واضحة - ErrorHandler سيعرضها
    _message = "خطأ في الاتصال الآمن. تحقق من إعدادات الشبكة";
    ErrorHandler.handleNetworkError();
    return null;
  } on FormatException catch (e) {
    // ✅ رسالة واضحة - ErrorHandler سيعرضها
    _message = "البيانات المستلمة تالفة. حاول مرة أخرى";
    ErrorHandler.handleApiError("$_message: ${e.toString()}");
    return null;
  } on HttpException catch (e) {
    // ✅ رسالة واضحة - ErrorHandler سيعرضها
    _message = "خطأ في الخادم: ${e.message}. حاول مرة أخرى";
    ErrorHandler.handleApiError(_message);
    return null;
  } catch (e) {
    // ✅ رسالة واضحة - ErrorHandler سيعرضها
    String errorString = e.toString();
    if (errorString.contains('خطأ API:')) {
      _message = errorString.replaceAll('Exception: ', '').replaceAll('خطأ API: ', '');
      ErrorHandler.handleApiError(_message);
    } else {
      _message = "حدث خطأ غير متوقع. حاول مرة أخرى";
      ErrorHandler.handleError(e, customMessage: _message, showSnackbar: true);
    }
    return null;
  } finally {
    isLoading.value = false;
    // لا نعرض snackbar هنا لأن ErrorHandler يتولى ذلك
  }
}


Future<bool?> showConfirmDialog({
  required BuildContext context,
  required String message,
  String title = "تأكيد",
  String yesText = "نعم",
  String noText = "لا",
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false, // يمنع الإغلاق بالضغط خارج الحوار
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.teal.shade700,
          ),
          textAlign: TextAlign.center,
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(yesText),
          ),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.teal,
              side: BorderSide(color: Colors.teal),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(noText),
          ),
        ],
      );
    },
  );
}

Future del()async{
  await Future.delayed(Duration(seconds: 1));

}

checkApi(res,{massge="لايوجد بيانات",type="s"}){
  if(res["stat"]=="ok"){
    if(type=="s")
    return res["data"];
    if(type=="i")
      mySnackbar("تنبية", "تم الاضافة بنجاح",type: "g");
  }
  else if(res["stat"]=="no"){
    mySnackbar("تنبية", massge);
    return [];
  }
  else if(res["stat"]=="error"){
    mySnackbar("تنبية", "${res["msg"]}");
    return [];
  }
}

