import 'package:althfeth/constants/function.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../api/LinkApi.dart';
import '../../api/apiFunction.dart';
import '../../controller/FirstPageExamStudentController.dart';

class FirstPageExamStudent extends StatelessWidget {
  final FirstPageExamStudentController controller = Get.put(FirstPageExamStudentController());

  @override
  Widget build(BuildContext context) {
    final Color primaryTeal = Colors.teal.shade600;

    return Directionality(
      // 👈 هنا الحل
      textDirection: TextDirection.rtl, // 🔹 يخلي التابات تبدأ من اليمين
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              "الاختبار الشهري لحلقة ${controller.dataCircle["name_circle"]}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            backgroundColor: primaryTeal,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(50),
              child: TabBar(
                isScrollable: true,
                indicatorColor: Colors.white,
                // indicatorWeight: 3,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                unselectedLabelColor: Colors.white70,
                labelColor: Colors.white,
                tabs: const [
                  Tab(text: "اختبروا الحفظ والمراجعة"),
                  Tab(text: "اختبروا الحفظ فقط"),
                  Tab(text: "اختبروا المراجعة فقط"),
                  Tab(text: "لم يختبروا بعد"),
                ],
              ),
            ),
          ),
          body: Obx(() {
            if (controller.students.isEmpty) {
              return const Center(
                child: Text("لا يوجد طلاب في هذه الحلقة حالياً"),
              );
            }

            final bothExamsStudents = controller.students
                .where((s) =>
                    s["has_monthly_exam"] == 1 &&
                    s["has_review_exam"] == 1)
                .toList();

            final onlyMonthlyStudents = controller.students
                .where((s) =>
                    s["has_monthly_exam"] == 1 &&
                    s["has_review_exam"] == 0)
                .toList();

            final onlyReviewStudents = controller.students
                .where((s) =>
                    s["has_monthly_exam"] == 0 &&
                    s["has_review_exam"] == 1)
                .toList();

            final notTestedStudents = controller.students
                .where((s) =>
                    s["has_monthly_exam"] == 0 &&
                    s["has_review_exam"] == 0)
                .toList();

            return TabBarView(
              children: [
                _buildStudentList(bothExamsStudents),
                _buildStudentList(onlyMonthlyStudents),
                _buildStudentList(onlyReviewStudents),
                _buildStudentList(notTestedStudents),
              ],
            );
          }),
        ),
      ),
    );
  }

  // 🔸 دالة بناء قائمة الطلاب بكروت جميلة
  Widget _buildStudentList(List<dynamic> students) {
    if (students.isEmpty) {
      return const Center(
        child: Text(
          "لا يوجد طلاب في هذه الفئة",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        return StudentCard(
          studentName: "${student["name_student"]}",
          level: "${student["name_level"]}",
          stage: "${student["name_stages"]}",
          onMonthlyExam: () {
            controller.select_student_exam(student["id_student"]);
          },
          onReviewExam: () {
            // 👇 تروح لصفحة اختبار المراجعة
            // Get.to(() => ReviewExamPage(), arguments: student);
          },
        );
      },
    );
  }
}



class StudentCard extends StatelessWidget {
  final String studentName;
  final String level;
  final String stage;
  final VoidCallback onMonthlyExam;
  final VoidCallback onReviewExam;

  const StudentCard({
    super.key,
    required this.studentName,
    required this.level,
    required this.stage,
    required this.onMonthlyExam,
    required this.onReviewExam,
  });

  @override
  Widget build(BuildContext context) {
    final Color mainTeal = Colors.teal.shade600;
    final Color lightTeal = Colors.teal.shade400;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🧑‍🎓 معلومات الطالب
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: mainTeal.withOpacity(0.1),
                  child: Icon(Icons.person, color: mainTeal, size: 32),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        studentName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "المرحلة: $stage",
                        style: TextStyle(
                            fontSize: 15, color: Colors.grey.shade600),
                      ),
                      Text(
                        "المستوى: $level",
                        style: TextStyle(
                            fontSize: 15, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Divider(thickness: 1, color: Colors.grey.shade300),
            const SizedBox(height: 8),

            // 🎯 الزرين بتصميمك
            Row(
              children: [
                Expanded(
                  child: _buildButton(
                    "اختبار الحفظ الشهري",
                    onMonthlyExam,
                    mainTeal,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildButton(
                    "اختبار المراجعة",
                    onReviewExam,
                    lightTeal,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 🎨 دالة الزر بنفس ستايلك الأصلي
  Widget _buildButton(String text, VoidCallback? onPressed, Color color) {
    return SizedBox(
      height: 45,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
