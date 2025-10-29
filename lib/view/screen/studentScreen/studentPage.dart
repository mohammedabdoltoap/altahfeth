import 'package:althfeth/constants/appButton.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/studentControllers/StudentPageController.dart';
import 'StudentPlanReport.dart';
import '../../widget/common/promotional_footer.dart';

class StudentPage extends StatelessWidget {
  StudentPageController controller=Get.put(StudentPageController());
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        centerTitle: true,
        elevation: 2,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person, size: 22, color: Colors.white.withOpacity(0.9)),
                const SizedBox(width: 8),
                const Text(
                  "ملف الطالب",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              controller.student['name_student'] ?? '',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.95),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // بطاقة المعلومات الشخصية
                _buildSectionCard(
                  theme: theme,
                  title: "المعلومات الشخصية",
                  icon: Icons.person,
                  children: [
                    _buildInfoRow(Icons.badge, "الاسم الكامل", "${controller.student['name_student']}", theme),
                    _buildInfoRow(Icons.family_restroom, "اللقب", "${controller.student['surname']}", theme),
                    _buildInfoRow(Icons.wc, "الجنس", "${controller.student['sex']}", theme),
                    _buildInfoRow(Icons.cake, "تاريخ الميلاد", "${controller.student['date_of_birth']}", theme),
                    _buildInfoRow(Icons.location_city, "مكان الميلاد", "${controller.student['place_of_birth']}", theme),
                    _buildInfoRow(Icons.home, "العنوان", "${controller.student['address_student']}", theme),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // بطاقة معلومات الاتصال والعائلة
                _buildSectionCard(
                  theme: theme,
                  title: "معلومات الاتصال والعائلة",
                  icon: Icons.contacts,
                  children: [
                    _buildInfoRow(Icons.phone, "رقم الهاتف", "${controller.student['phone']}", theme),
                    _buildInfoRow(Icons.supervisor_account, "ولي الأمر", "${controller.student['guardian']}", theme),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // بطاقة المعلومات الدراسية
                _buildSectionCard(
                  theme: theme,
                  title: "المعلومات الدراسية",
                  icon: Icons.school,
                  children: [
                    _buildInfoRow(Icons.school_outlined, "المدرسة", "${controller.student['school_name']}", theme),
                    _buildInfoRow(Icons.class_, "الصف", "${controller.student['classroom']}", theme),
                    _buildInfoRow(Icons.workspace_premium, "المؤهل", "${controller.student['qualification']}", theme),
                    _buildInfoRow(Icons.book, "القارئ", "${controller.student['name_reder']}", theme),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // بطاقة معلومات إضافية
                _buildSectionCard(
                  theme: theme,
                  title: "معلومات إضافية",
                  icon: Icons.info_outline,
                  children: [
                    _buildInfoRow(Icons.work, "الوظيفة", "${controller.student['jop']}", theme),
                    _buildInfoRow(Icons.calendar_today, "تاريخ التسجيل", "${controller.student['date']}", theme),
                    _buildInfoRow(Icons.medical_services, "الأمراض المزمنة", "${controller.student['chronic_diseases']}", theme),
                    _buildInfoRow(
                      controller.student['status'] == 1 ? Icons.check_circle : Icons.cancel,
                      "الحالة",
                      controller.student['status'] == 1 ? "نشط" : "غير نشط",
                      theme,
                      valueColor: controller.student['status'] == 1 ? Colors.green : Colors.red,
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // أزرار الإجراءات
                _buildActionsSection(theme),
                
                const SizedBox(height: 16),
              ],
            ),
          ),
          
          // البصمة الترويجية
          const PromotionalFooter(
            backgroundColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required ThemeData theme,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    ThemeData theme, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: theme.colorScheme.primary.withOpacity(0.7),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value.isNotEmpty && value != 'null' ? value : "—",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: valueColor ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "التقارير والخطط",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        AppButton(
          text: "خطة الطالب الدراسية",
          icon: Icons.assignment_outlined,
          onPressed: () {
            Get.to(() => StudentPlanReport(), arguments: controller.student);
          },
          color: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          height: 52,
        ),
        const SizedBox(height: 12),
        AppButton(
          text: "تقرير التسميع اليومي",
          icon: Icons.menu_book,
          onPressed: () {
            controller.select_daily_report();
          },
          color: theme.colorScheme.secondary,
          foregroundColor: theme.colorScheme.onSecondary,
          height: 52,
        ),
        const SizedBox(height: 12),
        AppButton(
          text: "تقرير المراجعة",
          icon: Icons.rate_review,
          onPressed: () {
            controller.select_review_report();
          },
          color: theme.colorScheme.tertiary,
          foregroundColor: theme.colorScheme.onTertiary,
          height: 52,
        ),
        const SizedBox(height: 12),
        AppButton(
          text: "تقرير الحضور والغياب",
          icon: Icons.event_available,
          onPressed: () {
            controller.select_absence_report();
          },
          color: Colors.orange,
          foregroundColor: Colors.white,
          height: 52,
        ),
      ],
    );
  }
}
