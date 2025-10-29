
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'dart:async';
import 'dart:io';
import '../controller/NewWork/NetworkController.dart';
import '../utils/ErrorHandler.dart';
import 'loadingWidget.dart';

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
          try {
            final result = await action().timeout(const Duration(seconds: 15));
            return result;
          } finally {
            final elapsed = DateTime.now().difference(start);
            const minDuration = Duration(milliseconds: 100);
            if (elapsed < minDuration) {
              await Future.delayed(minDuration - elapsed);
            }
          }
        },
        loadingWidget: overlay,
        opacityColor: theme.colorScheme.scrim.withOpacity(0.25),
        opacity: 1,

      );
    } else {
      final result = await action().timeout(const Duration(seconds: 15));
      return result;
    }
  } on TimeoutException {
    _message = "انتهت مهلة الاتصال. تحقق من الإنترنت وحاول مرة أخرى";
    mySnackbar("انتهت المهلة", _message, type: "r");
    return null;
  } on SocketException {
    // خطأ في الاتصال بالشبكة (لا يوجد إنترنت، الخادم غير متاح، إلخ)
    _message = "فشل الاتصال بالخادم. تحقق من الإنترنت";
    ErrorHandler.handleNetworkError();
    return null;
  } on HandshakeException {
    // خطأ في SSL/TLS (شهادة غير صالحة، مشاكل في الاتصال الآمن)
    _message = "خطأ في الاتصال الآمن بالخادم";
    ErrorHandler.handleNetworkError();
    return null;
  } on FormatException {
    // خطأ في تحويل البيانات (JSON غير صالح، بيانات تالفة)
    _message = "خطأ في تنسيق البيانات المستلمة";
    ErrorHandler.handleApiError("$_message: ${e.toString()}");
    return null;
  } on HttpException catch (e) {
    // أخطاء HTTP (404, 500, إلخ)
    _message = "خطأ في الخادم: ${e.message}";
    ErrorHandler.handleApiError(_message);
    return null;
  } catch (e) {
    // التحقق إذا كان الخطأ من API (يحتوي على "خطأ API:")
    String errorString = e.toString();
    if (errorString.contains('خطأ API:')) {
      // خطأ من API (قاعدة بيانات، validation، إلخ)
      _message = errorString.replaceAll('Exception: ', '').replaceAll('خطأ API: ', '');
      ErrorHandler.handleApiError(_message);
    } else {
      // أي خطأ آخر غير متوقع (أخطاء في الكود، null pointer، إلخ)
      _message = "حدث خطأ غير متوقع أثناء العملية";
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

