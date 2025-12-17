import 'package:althfeth/constants/function.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/studentControllers/pendingStudentsController.dart';
import '../../../constants/inline_loading.dart';

class PendingStudentsManagement extends StatelessWidget {
  final PendingStudentsController controller = Get.put(PendingStudentsController());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          toolbarHeight: 88,
          elevation: 0,
          // backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
            onPressed: () => Get.back(),
          ),
          title: Column(
            children: [
              const Text(
                "إدارة الطلاب(الذي لم يتم قبولهم الي الان)",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  // color: Colors.black87,
                ),
              ),
              Obx(() => Text(
                "عدد الطلاب: ${controller.pendingStudents.length}",
                style: TextStyle(
                  fontSize: 12,
                  // color: Colors.grey.shade600,
                  // fontWeight: FontWeight.w500,
                ),
              )),
            ],
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.grey[50]!,
                Colors.white,
              ],
            ),
          ),
          child: Obx(() {
            // حالة التحميل
            if (controller.isLoading.value) {
              return const InlineLoading(message: "جاري تحميل الطلاب المعلقين...");
            }

            // إذا لم تكن هناك بيانات
            if (controller.pendingStudents.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_circle_outline,
                        size: 80,
                        color: Colors.green.shade400,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "لا توجد طلاب معلقين",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "جميع الطلاب تم الموافقة عليهم ✓",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () => controller.getPendingStudents(),
                      icon: const Icon(Icons.refresh),
                      label: const Text("تحديث"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            // قائمة الطلاب المعلقين
            return RefreshIndicator(
              onRefresh: () => controller.getPendingStudents(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.pendingStudents.length,
                itemBuilder: (context, index) {
                  final student = controller.pendingStudents[index];
                  return Column(
                    children: [
                      _buildStudentCard(context, student, index),
                      Divider(),
                    ],
                  );
                },
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildStudentCard(BuildContext context, Map<String, dynamic> student, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            // رأس البطاقة مع تدرج لوني
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Colors.blue.shade400,
                    Colors.blue.shade600,
                  ],
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white,
                      child: Text(
                        student["name_student"]?.toString().substring(0, 1).toUpperCase() ?? "ط",
                        style: TextStyle(
                          color: Colors.blue.shade600,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${student["name_student"] ?? ""} ${student["surname"] ?? ""}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          student["phone"] ?? "بدون رقم",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // الأزرار
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showDeleteConfirmDialog(context, student["id_student"], index),
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text("حذف", style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade400,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => controller.editStudent(student),
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text("تعديل", style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade400,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, int studentId, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("تأكيد الحذف"),
        content: const Text("هل أنت متأكد من حذف هذا الطالب؟"),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("إلغاء"),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteStudent(studentId, index);
            },
            child: const Text("حذف", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
