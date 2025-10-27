import 'package:althfeth/constants/appButton.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/studentControllers/StudentPageController.dart';

class StudentPage extends StatelessWidget {
  StudentPageController controller=Get.put(StudentPageController());
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: 88,
        title: const Text("بيانات الطالب"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Center(
                  child: Text(
                    "بيانات الطالب",
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                  ),
                ),
                Divider(thickness: 2, color: theme.colorScheme.primary),
                SizedBox(height: 10),
                _buildRow("الاسم الكامل", "${controller.student['name_student']}"),
                _buildRow("اللقب", "${controller.student['surname']}"),
                _buildRow("العمر", "${controller.student['age_student']}"),
                _buildRow("العنوان", "${controller.student['address_student']}"),
                _buildRow("مكان الميلاد", "${controller.student['place_of_birth']}"),
                _buildRow("تاريخ الميلاد", "${controller.student['date_of_birth']}"),
                _buildRow("الجنس", "${controller.student['sex']}"),
                _buildRow("رقم الهاتف", "${controller.student['phone']}"),
                _buildRow("ولي الأمر", "${controller.student['guardian']}"),
                _buildRow("المدرسة", "${controller.student['school_name']}"),
                _buildRow("الصف", "${controller.student['classroom']}"),
                _buildRow("الوظيفة", "${controller.student['jop']}"),
                _buildRow("تاريخ التسجيل", "${controller.student['date']}"),
                _buildRow("المؤهل", "${controller.student['qualification']}"),
                _buildRow("الأمراض المزمنة", "${controller.student['chronic_diseases']}"),
                _buildRow("القارى", "${controller.student['Reader']}"),
                _buildRow("الحالة", controller.student['status'] == 1 ? "نشط" : "غير نشط"),
                Divider(thickness: 2, color: theme.colorScheme.primary),
             AppButton(
               text: "خطة الطالب PDF",
               onPressed: () {},
               color: theme.colorScheme.secondaryContainer,
               foregroundColor: theme.colorScheme.onSecondaryContainer,
             ),
             SizedBox(height: 10,),
             AppButton(
               text: "التسميع",
               onPressed: () { controller.select_daily_report(); },
               color: theme.colorScheme.primary,
               foregroundColor: theme.colorScheme.onPrimary,
             ),
                AppButton(
                  text: "المراجعة ",
                  onPressed: () { controller.select_review_report(); },
                  color: theme.colorScheme.secondary,
                  foregroundColor: theme.colorScheme.onSecondary,
                ),
                AppButton(
                  text: "الحضور والغياب",
                  onPressed: () { controller.select_absence_report(); },
                  color: theme.colorScheme.tertiary,
                  foregroundColor: theme.colorScheme.onTertiary,
                ),


              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value.isNotEmpty ? value : "—",
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
