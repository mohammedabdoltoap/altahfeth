import 'package:althfeth/view/screen/addStudent.dart';
import 'package:althfeth/view/screen/home.dart';
import 'package:althfeth/view/screen/login.dart';
import 'package:althfeth/view/screen/test.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp( Rout());
}
//
class Rout extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home:Login(),
    );
  }
}
