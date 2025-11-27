import 'package:althfeth/view/screen/home.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/show_CircleController.dart';
import '../../globals.dart';
import 'package:althfeth/constants/color.dart';
import 'package:althfeth/constants/inline_loading.dart';
import '../widget/common/promotional_footer.dart';

class Show_Circle extends StatelessWidget {
  final Show_CircleController show_circleController = Get.put(Show_CircleController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("الحلقات المسؤولة عنها"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),

            Expanded(
              child: Obx(() {
                // حالة التحميل داخل الصفحة
                if (show_circleController.isLoading.value && show_circleController.data_circle.isEmpty) {
                  return const InlineLoading(message: "جاري تحميل الحلقات...");
                }

                // حالة فارغة مع زر إعادة محاولة
                if (show_circleController.data_circle.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "لا يوجد لديك حلقات مسؤول عنها",
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: 220,
                          child: ElevatedButton(
                            onPressed: () => show_circleController.get_circle(),
                            child: const Text("إعادة المحاولة"),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // قائمة الحلقات
                return ListView.separated(
                  itemCount: show_circleController.data_circle.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 15),
                  itemBuilder: (context, index) {
                    final dataCircle = show_circleController.data_circle[index];

                    return InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        final args = {
                          ...dataCircle,
                          "username": show_circleController.dataArg["username"],
                          "id_user": show_circleController.dataArg["id_user"],
                          "role": show_circleController.dataArg["role"],
                        };
                        holidayData.clear();
                        Get.to(() => Home(), arguments: args);
                      },
                      child: Container(
                        width: double.infinity,
                        height: 100,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: [kPrimaryColor.withOpacity(0.9), kPrimaryColor],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.group, size: 40, color: Colors.white),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                "${dataCircle["name_circle"]}",
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, color: Colors.white),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),

          ],
        ),
      ),
    );
  }
}
