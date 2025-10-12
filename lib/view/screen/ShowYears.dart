import 'package:althfeth/api/LinkApi.dart';
import 'package:althfeth/api/apiFunction.dart';
import 'package:althfeth/constants/function.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../constants/appButton.dart';
import '../../controller/ShowYearsController.dart';
import 'FirstPageExamStudent.dart';


class ShowYears extends StatelessWidget {
  final ShowYearsController controller = Get.put(ShowYearsController());

  @override
  Widget build(BuildContext context) {
    final themeColor = Colors.teal.shade600;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          "السنوات الدراسية",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: themeColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "اختر السنة الدراسية:",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 15),

            // ✅ قائمة السنوات
            Expanded(
              child: Obx(() {
                if (controller.dataYears.isEmpty) {
                  return Center(
                    child: Text(
                      "لا يوجد لديك حلقات مسؤول عنها حالياً",
                      style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                    ),
                  );
                } else {
                  return ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    itemCount: controller.dataYears.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final dataYear = controller.dataYears[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 3,
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          title: Text(
                            "${dataYear["name_year"]}",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 17,
                            ),
                          ),
                          tileColor: Colors.white,
                          onTap: () {
                            controller.select_visits(dataYear["id_year"]);
                          },
                        ),
                      );
                    },
                  );
                }
              }),
            ),

            const Divider(height: 25, thickness: 1.2),

            // ✅ قائمة الأشهر بعد اختيار السنة
            Obx(() {
              if (controller.dataMonths.isNotEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "اختر الشهر:",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 220,
                      child: ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: controller.dataMonths.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final dataMonth = controller.dataMonths[index];
                          return GestureDetector(
                            onTap: () {
                              controller.data_circle["id_visit"]=controller.dataMonths[index]["id_visit"];
                             print(controller.data_circle);
                              Get.to(() => FirstPageExamStudent(),
                                  arguments: controller.data_circle);
                              //
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: themeColor,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 20),
                              child: Center(
                                child: Text(
                                  "${dataMonth["month_name"]}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              } else {
                return const SizedBox();
              }
            }),
          ],
        ),
      ),
    );
  }
}

