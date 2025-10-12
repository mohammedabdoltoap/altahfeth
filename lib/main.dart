
import 'package:althfeth/view/screen/dilaysAndRevoews/daily_report.dart';
import 'package:althfeth/view/screen/login.dart';
import 'package:althfeth/view/screen/test.dart';
import 'package:althfeth/view/widget/home/appBarHome.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';

void main(){

  runApp(Rout());
}
//
class Rout extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
     home:Login(),
     //  home:ParentsPage(),
      debugShowCheckedModeBanner: false,

      locale: Locale(Get.deviceLocale!.languageCode),
    );
  }
}




