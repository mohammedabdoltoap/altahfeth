import 'package:althfeth/constants/appButton.dart';
import 'package:althfeth/constants/loadingWidget.dart';
import 'package:althfeth/view/screen/home.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get.dart';
import '../../api/LinkApi.dart';
import '../../api/apiFunction.dart';
import '../../constants/function.dart';
import '../../controller/ShowCircleExamController.dart';
import '../../globals.dart';
import 'ShowYears.dart';
import 'add _Visit.dart';

class ShowCircleExam extends StatelessWidget {
  ShowCircleExamController controller=Get.put(ShowCircleExamController());
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
            Center(
              child: Text(
                "اختر الحلقة التي تريد ان تختبرها :",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Obx(() {
                if (controller.data_circle.isEmpty) {
                  return Center(
                    child: Text(
                      "لا يوجد لديك حلقات مسؤول عنها",
                      style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                    ),
                  );
                } else {
                  return ListView.separated(
                    itemCount: controller.data_circle.length+1,
                    separatorBuilder: (_, __) => const SizedBox(height: 15),
                    itemBuilder: (context, index) {
                      if(index==controller.data_circle.length)
                        return AppButton(text: "عرض اسماء الطلاب لجميع الحلقات", onPressed: (){});
                      final data_circle = controller.data_circle[index];
                      return AppButton(
                        text: "${data_circle["name_circle"]}",
                        borderRadius: 16,
                        onPressed: () {

                          Get.to(()=>ShowYears(),arguments: data_circle);

                          // data_circle["username"] = controller.dataArg["username"];
                          // // //علشان يغير ادري من الي سمع للطالب المدير والي الاستاذ
                          // data_circle["id_user"] = controller.dataArg["id_user"];
                          // data_circle["role"] = controller.dataArg["role"];
                          // print(data_circle);

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
