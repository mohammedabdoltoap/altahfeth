import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../constants/function.dart';
import 'dart:io';
import 'dart:async';

Future<bool> checkInternet() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.none) {
    mySnackbar("تنبيه", "لا يوجد اتصال بالإنترنت", type: "y");
    return false;
  }

  // تحقّق من الوصول الفعلي للإنترنت (قد تكون متصلاً بشبكة بدون إنترنت)
  // 1) محاولة فتح Socket إلى خوادم DNS المعروفة (بدون حاجة لـ DNS)
  final dnsIps = [
    InternetAddress('1.1.1.1'), // Cloudflare DNS
    InternetAddress('8.8.8.8'), // Google DNS
  ];
  for (final ip in dnsIps) {
    try {
      final socket = await Socket.connect(ip, 53, timeout: const Duration(seconds: 2));
      socket.destroy();
      return true; // نجاح الوصول الفعلي
    } catch (_) {
      // جرّب التالي
    }
  }

  // 2) كخطة احتياط: محاولات DNS lookup لعدة نطاقات بمهلة قصيرة
  const domains = ['example.com', 'google.com'];
  for (final domain in domains) {
    try {
      final result = await InternetAddress.lookup(domain).timeout(const Duration(seconds: 5));
      if (result.isNotEmpty && result.first.rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException {
      // تابع المحاولة مع دومين آخر
    } on TimeoutException {
      // تابع المحاولة مع دومين آخر
    } catch (_) {
      // تابع المحاولة مع دومين آخر
    }
  }

  // إذا وصلنا هنا فالفحص فشل
  mySnackbar("تنبيه", "لا يوجد إنترنت فعلي. تحقق من الشبكة", type: "y");
  return false;
}
