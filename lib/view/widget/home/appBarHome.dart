import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/home_cont.dart';

class AppBarHome extends StatelessWidget implements PreferredSizeWidget {
  final HomeCont homeCont = Get.find();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      centerTitle: true,
      toolbarHeight: 80,
      title: Text(
        homeCont.dataArg["name_circle"] ?? "",
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(80); // نفس ارتفاع الـ AppBar
}