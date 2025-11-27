import 'package:althfeth/api/LinkApi.dart';
import 'package:althfeth/api/apiFunction.dart';
import 'package:althfeth/constants/appButton.dart';
import 'package:althfeth/constants/customTextField.dart';
import 'package:althfeth/constants/inline_loading.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/AttendanceController.dart';
import '../../widget/common/promotional_footer.dart';

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
                    final theme = Theme.of(context);
                    final primaryColor = theme.colorScheme.primary;
                    
                    // تحديد حالة الطالب: 1 = حاضر، 0 = غائب، 2 = غائب بعذر
                    int attendanceStatus = student["status"] is bool 
                        ? (student["status"] ? 1 : 0) 
                        : (student["status"] ?? 0);
                    
                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: attendanceStatus == 1 
                              ? Colors.green.withOpacity(0.3)
                              : attendanceStatus == 2
                                  ? Colors.orange.withOpacity(0.3)
                                  : Colors.red.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // الاسم + رقم الطالب
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.person,
                                    color: primaryColor,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        student["name_student"],
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),

                                    ],
                                  ),
                                ),
                                // أيقونة الحالة
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: attendanceStatus == 1
                                        ? Colors.green.withOpacity(0.1)
                                        : attendanceStatus == 2
                                            ? Colors.orange.withOpacity(0.1)
                                            : Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        attendanceStatus == 1
                                            ? Icons.check_circle
                                            : attendanceStatus == 2
                                                ? Icons.event_busy
                                                : Icons.cancel,
                                        color: attendanceStatus == 1
                                            ? Colors.green
                                            : attendanceStatus == 2
                                                ? Colors.orange
                                                : Colors.red,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        attendanceStatus == 1
                                            ? "حاضر"
                                            : attendanceStatus == 2
                                                ? "عذر"
                                                : "غائب",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: attendanceStatus == 1
                                              ? Colors.green
                                              : attendanceStatus == 2
                                                  ? Colors.orange
                                                  : Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 16),
                            const Divider(height: 1),
                            const SizedBox(height: 12),
                            
                            // خيارات الحضور
                            Row(
                              children: [
                                Expanded(
                                  child: _buildAttendanceOption(
                                    context: context,
                                    label: "حاضر",
                                    icon: Icons.check_circle_outline,
                                    color: Colors.green,
                                    isSelected: attendanceStatus == 1,
                                    onTap: () {
                                      student["status"] = 1;
                                      student["notes"] = "";
                                      controller.filteredStudents.refresh();
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildAttendanceOption(
                                    context: context,
                                    label: "غائب بعذر",
                                    icon: Icons.event_busy,
                                    color: Colors.orange,
                                    isSelected: attendanceStatus == 2,
                                    onTap: () {
                                      student["status"] = 2;
                                      controller.filteredStudents.refresh();
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildAttendanceOption(
                                    context: context,
                                    label: "غائب",
                                    icon: Icons.cancel_outlined,
                                    color: Colors.red,
                                    isSelected: attendanceStatus == 0,
                                    onTap: () {
                                      student["status"] = 0;
                                      controller.filteredStudents.refresh();
                                    },
                                  ),
                                ),
                              ],
                            ),

                            // سبب الغياب (للغائب أو الغائب بعذر)
                            if (attendanceStatus == 0 || attendanceStatus == 2)
                              Padding(
                                padding: const EdgeInsets.only(top: 12.0),
                                child: TextFormField(
                                  initialValue: student["notes"],
                                  onChanged: (val) => student["notes"] = val,
                                  maxLines: 2,
                                  decoration: InputDecoration(
                                    labelText: attendanceStatus == 2 
                                        ? "سبب العذر" 
                                        : "سبب الغياب",
                                    hintText: "أدخل السبب...",
                                    prefixIcon: Icon(
                                      Icons.note_alt_outlined,
                                      color: attendanceStatus == 2 
                                          ? Colors.orange 
                                          : Colors.red,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: attendanceStatus == 2 
                                            ? Colors.orange 
                                            : Colors.red,
                                        width: 2,
                                      ),
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

              const SizedBox(height: 12),

            ],
          );
        }),
      ),
    );
  }

  // ✅ دالة مساعدة لبناء خيار الحضور
  Widget _buildAttendanceOption({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey.shade600,
              size: 28,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
