import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/home_cont.dart';

class AppBarHome extends StatelessWidget implements PreferredSizeWidget {
  final HomeCont homeCont = Get.find();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.teal,
      centerTitle: true,
      toolbarHeight: 80,
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            homeCont.dataArg["name_circle"] ?? "",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(80); // نفس ارتفاع الـ AppBar
}