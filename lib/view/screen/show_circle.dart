import 'package:althfeth/constants/appButton.dart';
import 'package:althfeth/constants/loadingWidget.dart';
import 'package:althfeth/view/screen/home.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/show_CircleController.dart';
import '../../globals.dart';
import 'add _Visit.dart';

class Show_Circle extends StatelessWidget {
  final Show_CircleController show_circleController = Get.put(Show_CircleController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "الحلقات المسؤولة عنها",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal.shade600,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    "اختر الحلقة للدخول إليها:",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                SizedBox(width: 10,),
                if(show_circleController.dataArg["role"]==2)
              Expanded(child: AppButton(text: "الزيارات", onPressed: (){
                Get.to(() => Add_Visit(),arguments: show_circleController.dataArg);

              })),
                  ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Obx(() {
                if (show_circleController.data_circle.isEmpty) {
                  return Center(
                    child: Text(
                      "لا يوجد لديك حلقات مسؤول عنها",
                      style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                    ),
                  );
                } else {
                  return ListView.separated(
                    itemCount: show_circleController.data_circle.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 15),
                    itemBuilder: (context, index) {
                      final data_circle = show_circleController.data_circle[index];
                      return AppButton(
                        text: "${data_circle["name_circle"]}",
                        borderRadius: 16,
                        onPressed: () {
                          data_circle["username"] = show_circleController.dataArg["username"];
                          //علشان يغير ادري من الي سمع للطالب المدير والي الاستاذ
                          data_circle["id_user"] = show_circleController.dataArg["id_user"];
                          data_circle["role"] = show_circleController.dataArg["role"];
                          print(data_circle);
                          holidayData.clear();
                          Get.to(() => Home(), arguments: data_circle);
                          //
                        },
                      );
                    },
                  );
                }
              }),
            ),
          ],
        ),
      ),
    );
  }
}
