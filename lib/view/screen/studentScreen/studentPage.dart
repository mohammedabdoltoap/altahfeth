import 'package:althfeth/constants/appButton.dart';
import 'package:althfeth/constants/customAppBar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/studentControllers/StudentPageController.dart';
import 'StudentPlanReport.dart';
import '../../widget/common/promotional_footer.dart';

class StudentPage extends StatelessWidget {
  StudentPageController controller=Get.put(StudentPageController());
  final RxBool showAllInfo = false.obs;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopScope(
      canPop: false, // منع الخروج المباشر
      onPopInvoked: (didPop) async {
        if (didPop) return;
        
        // عرض تنبيه التأكيد
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('تأكيد الخروج'),
            content: const Text('هل أنت متأكد من الخروج من التطبيق؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('خروج', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
        
        if (shouldExit == true && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: CustomAppBar(
        title: "ملف الطالب",
        subtitle: controller.student['name_student'] ?? '',
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: "تسجيل الخروج",
            onPressed: () {
              Get.defaultDialog(
                title: "تأكيد تسجيل الخروج",
                middleText: "هل أنت متأكد من تسجيل الخروج؟",
                textConfirm: "نعم",
                textCancel: "إلغاء",
                confirmTextColor: Colors.white,
                onConfirm: () {
                  Get.back();
                  controller.logout();
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // كارت واحد لجميع البيانات
                Obx(() => _buildUnifiedInfoCard(theme)),
                
                const SizedBox(height: 20),
                
                // كروت التقارير
                _buildActionsSection(theme),
                
                const SizedBox(height: 16),
              ],
            ),
          ),

        ],
      ),
    )
    );
  }


  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    ThemeData theme, {
    Color? valueColor,
  }) {
    // معالجة القيم الفارغة أو null
    final displayValue = (value.isEmpty || value == 'null' || value == 'NULL') ? "—" : value;

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
              displayValue,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: valueColor ?? Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
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
        // عنوان القسم مع أيقونة
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary.withOpacity(0.1),
                theme.colorScheme.primary.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.assessment,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                "التقارير والخطط",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // أزرار التقارير في شبكة
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildActionCard(
              theme: theme,
              title: "خطة الطالب",
              icon: Icons.assignment_outlined,
              color: theme.colorScheme.primary,
              onPressed: () {
                Get.to(() => StudentPlanReport(), arguments: controller.student);
              },
            ),
            _buildActionCard(
              theme: theme,
              title: "التسميع اليومي",
              icon: Icons.menu_book,
              color: theme.colorScheme.secondary,
              onPressed: () {
                controller.select_daily_report();
              },
            ),
            _buildActionCard(
              theme: theme,
              title: "المراجعة",
              icon: Icons.rate_review,
              color: theme.colorScheme.tertiary,
              onPressed: () {
                controller.select_review_report();
              },
            ),
            _buildActionCard(
              theme: theme,
              title: "الحضور والغياب",
              icon: Icons.event_available,
              color: Colors.orange,
              onPressed: () {
                controller.select_absence_report();
              },
            ),
            _buildActionCard(
              theme: theme,
              title: "نتائج الاختبارات",
              icon: Icons.grade,
              color: Colors.purple,
              onPressed: () {
                controller.select_exam_results();
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required ThemeData theme,
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // كارت موحد لجميع البيانات
  Widget _buildUnifiedInfoCard(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // العنوان
            Row(
              children: [
                Icon(Icons.person, color: theme.colorScheme.primary, size: 24),
                const SizedBox(width: 8),
                Text(
                  "بيانات الطالب",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const Spacer(),
                // زر عرض الكل
                TextButton.icon(
                  onPressed: () => showAllInfo.value = !showAllInfo.value,
                  icon: Icon(
                    showAllInfo.value ? Icons.visibility_off : Icons.visibility,
                    size: 18,
                  ),
                  label: Text(showAllInfo.value ? "إخفاء التفاصيل" : "عرض الكل"),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            
            // البيانات الأساسية (تظهر دائماً)
            _buildInfoRow(Icons.badge, "الاسم", "${controller.student['name_student']}", theme),
            _buildInfoRow(Icons.family_restroom, "اللقب", "${controller.student['surname']}", theme),
            _buildInfoRow(Icons.school, "المدرسة", "${controller.student['school_name']}", theme),
            _buildInfoRow(Icons.class_, "الصف", "${controller.student['classroom']}", theme),
            _buildInfoRow(Icons.phone, "الهاتف", "${controller.student['phone']}", theme),
            
            // البيانات الإضافية (تظهر عند الضغط على عرض الكل)
            if (showAllInfo.value) ...[
              const Divider(height: 24),
              Text(
                "معلومات إضافية",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 12),
              _buildInfoRow(Icons.wc, "الجنس", "${controller.student['sex']}", theme),
              _buildInfoRow(Icons.cake, "تاريخ الميلاد", "${controller.student['date_of_birth']}", theme),
              _buildInfoRow(Icons.location_city, "مكان الميلاد", "${controller.student['place_of_birth']}", theme),
              _buildInfoRow(Icons.home, "العنوان", "${controller.student['address_student']}", theme),
              _buildInfoRow(Icons.supervisor_account, "ولي الأمر", "${controller.student['guardian']}", theme),
              _buildInfoRow(Icons.work, "الوظيفة ", "${controller.student['jop']}", theme),
              _buildInfoRow(Icons.person_outline, "اسم القارى", "${controller.student['name_reder']}", theme),
              _buildInfoRow(Icons.calendar_today, "تاريخ التسجيل", "${controller.student['date']}", theme),
              _buildInfoRow(Icons.medical_services, "الأمراض المزمنة", "${controller.student['chronic_diseases']}", theme),
            ],
          ],
        ),
      ),

    ); // ✅ إغلاق build

  }
}
