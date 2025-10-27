import 'package:althfeth/view/screen/login.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import 'constants/AppTheme.dart';
import 'constants/function.dart';
import 'utils/ErrorHandler.dart';

void main() {
  // تفعيل معالج الأخطاء العام
  ErrorHandler.initialize();
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: Login(),
      debugShowCheckedModeBanner: false,
      locale: Locale(Get.deviceLocale?.languageCode ?? 'ar'),
      theme: AppTheme.lightTheme,

    );
  }
}

