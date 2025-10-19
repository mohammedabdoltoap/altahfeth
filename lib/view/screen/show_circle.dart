import 'package:althfeth/constants/appButton.dart';
import 'package:althfeth/constants/loadingWidget.dart';
import 'package:althfeth/view/screen/home.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/show_CircleController.dart';
import '../../globals.dart';

class Show_Circle extends StatelessWidget {
  final Show_CircleController show_circleController = Get.put(Show_CircleController());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "الحلقات المسؤولة عنها",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal.shade600,
        elevation: 4,
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

                      return GestureDetector(
                        onTap: () {
                          data_circle["username"] = show_circleController.dataArg["username"];
                          data_circle["id_user"] = show_circleController.dataArg["id_user"];
                          data_circle["role"] = show_circleController.dataArg["role"];
                          print(data_circle);
                          holidayData.clear();
                          Get.to(() => Home(), arguments: data_circle);
                        },
                        child: Container(
                          width: double.infinity,
                          height: 100,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              colors: [Colors.teal.shade400, Colors.teal.shade700],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 6,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.group, size: 40, color: Colors.white),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  "${data_circle["name_circle"]}",
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Icon(Icons.arrow_forward_ios, color: Colors.white),
                            ],
                          ),
                        ),
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
