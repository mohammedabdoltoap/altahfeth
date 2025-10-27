import 'package:althfeth/api/LinkApi.dart';
import 'package:althfeth/api/apiFunction.dart';
import 'package:althfeth/constants/appButton.dart';
import 'package:althfeth/constants/customTextField.dart';
import 'package:althfeth/constants/inline_loading.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/AttendanceController.dart';

class Attendance extends StatelessWidget {
  final AttendanceController controller = Get.put(AttendanceController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("تحضير الطلاب"),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          // ✅ أثناء التحميل
          if (controller.isLoading.value) {
            return const InlineLoading(
              message: "جاري تحميل الطلاب...",
              indicatorSize: 35,
            );
          }

          // ✅ في حال لا يوجد طلاب
          if (controller.students.isEmpty) {
            return const Center(
              child: Text("لا يوجد طلاب في هذه الحلقة."),
            );
          }

          // ✅ بعد التحميل
          return Column(
            children: [
              // 🔍 حقل البحث باستخدام CustomTextField
              CustomTextField(
                controller: controller.searchController,
                label: "بحث عن الطالب",
                hint: "أدخل اسم الطالب...",
                prefixIcon: Icons.search,
                onChanged: controller.filterStudents,
              ),

              const SizedBox(height: 12),

              // 📋 قائمة الطلاب
              Expanded(
                child: ListView.builder(
                  itemCount: controller.filteredStudents.length,
                  itemBuilder: (context, index) {
                    final student = controller.filteredStudents[index];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // الاسم + مفتاح التحضير
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  student["name_student"],
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Switch(
                                  value: student["status"],
                                  activeColor: Theme.of(context).colorScheme.primary,
                                  onChanged: (val) {
                                    student["status"] = val;
                                    if (val) student["notes"] = "";
                                    controller.filteredStudents.refresh();
                                  },
                                ),
                              ],
                            ),

                            // سبب الغياب
                            if (!student["status"])
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: TextFormField(
                                  initialValue: student["notes"],
                                  onChanged: (val) => student["notes"] = val,
                                  decoration: InputDecoration(
                                    labelText: "سبب الغياب",
                                    hintText: "أدخل السبب...",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),

                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // 💾 زر الحفظ
              Obx(() => AppButton(
                text: "حفظ التحضير",
                isLoading: controller.isSaving.value, // ✅ ربطه بالـ isSaving
                onPressed: controller.insertAttendance,
              )),

            ],
          );
        }),
      ),
    );
  }
}
