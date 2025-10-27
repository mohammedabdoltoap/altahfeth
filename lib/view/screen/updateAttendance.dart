import 'package:althfeth/constants/customTextField.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/appButton.dart';
import '../../constants/inline_loading.dart';
import '../../controller/UpdateAttendanceController.dart';

class UpdateAttendance extends StatelessWidget {
  final UpdateAttendanceController controller = Get.put(UpdateAttendanceController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title:  Text("تعديل تحضير الطلاب"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Obx(() {

          if (controller.isLoading.value) {
            return const InlineLoading(
              message: "جاري تحميل الطلاب...",
              indicatorSize: 35,
            );
          }

          if (controller.students.isEmpty) {
            return const Center(
              child: Text(
                "لا يوجد طلاب",
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            );
          }

          return Column(
            children: [
              CustomTextField(
                controller: controller.searchController,
                label: "بحث عن الطالب",
                hint: "أدخل اسم الطالب...",
                prefixIcon: Icons.search,
                onChanged: controller.filterStudents,

              ),
              Divider(height: 2,thickness: 2,),
              Expanded(
                child: ListView.builder(
                  itemCount: controller.filteredStudents.length,
                  itemBuilder: (context, index) {
                    var student = controller.filteredStudents[index];
                    return Card(
                      color: Colors.white,
                      elevation: 3,
                      shadowColor: Colors.black12,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    student["name_student"],
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                Switch(
                                  value: student["status"],
                                  activeColor: Colors.teal,
                                  inactiveThumbColor: Colors.grey.shade400,
                                  onChanged: (val) {
                                    student["status"] = val;
                                    if (val) student["notes"] = "";
                                    controller.filteredStudents.refresh();
                                  },
                                ),
                              ],
                            ),
                            if (!student["status"])
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: TextFormField(
                                  initialValue: student["notes"],
                                  onChanged: (val) {
                                    student["notes"] = val;
                                    controller.filteredStudents.refresh();
                                  },
                                  decoration: InputDecoration(
                                    labelText: "سبب الغياب",
                                    hintText: "أدخل السبب...",
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(color: Colors.teal),
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
              const SizedBox(height: 10),
              Obx(() => AppButton(
                text: controller.isSaving.value ? "جاري التعديل..." : "تعديل التحضير",
                isLoading: controller.isSaving.value,
                onPressed: controller.isSaving.value
                    ? null
                    : () {
                  controller.updateAttendance();
                },
              )),
            ],
          );
        }),
      ),
    );
  }
}
