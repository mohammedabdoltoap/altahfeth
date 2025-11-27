import 'dart:async';
import 'package:althfeth/view/screen/adminScreen/UserSearchPage.dart';
import 'package:althfeth/view/screen/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import 'constants/AppTheme.dart';
import 'constants/function.dart';
import 'controller/studentControllers/addstudentController.dart';
import 'utils/ErrorHandler.dart';

void main() {
  // تشغيل التطبيق في منطقة محمية لحماية شاملة من الأخطاء
  runZonedGuarded(() {
    // تفعيل معالج الأخطاء العام
    ErrorHandler.initialize();

    runApp(MyApp());
  }, (error, stackTrace) {
    // معالجة الأخطاء الحرجة في المنطقة الرئيسية
    ErrorHandler.handleError(
      error,
      customMessage: "حدث خطأ حرج في التطبيق",
      showSnackbar: false, // عرض صفحة خطأ للأخطاء الحرجة
    );
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return GetMaterialApp(
      // home: ForLoopExamplePage(),
      home: Login(),
      // home: UserSearchPage(),
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
      
      // ✅ دعم التواريخ بالإنجليزية حتى مع اللغة العربية
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
      ],

      theme: AppTheme.lightTheme,
    );
  }
}

