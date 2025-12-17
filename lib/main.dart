import 'dart:async';
import 'package:althfeth/view/screen/adminScreen/UserSearchPage.dart';
import 'package:althfeth/view/screen/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'constants/AppTheme.dart';

void main()async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return GetMaterialApp(
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

