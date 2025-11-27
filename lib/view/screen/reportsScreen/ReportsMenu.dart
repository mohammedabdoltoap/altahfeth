import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'CircleReportView.dart';

class ReportsMenu extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final data = Get.arguments; // الحصول على البيانات المرسلة من AppDrawer
    print("ReportsMenu data=====${data}");
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "تقارير الحلقة",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // عنوان القسم
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.assessment_rounded,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "اختر نوع التقرير",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // قائمة التقارير
            Expanded(
              child: ListView(
                children: [
                  _buildReportCard(
                    context: context,
                    theme: theme,
                    title: "تقرير التسميع",
                    subtitle: "عرض تقارير التسميع اليومية للطلاب",
                    icon: Icons.menu_book_rounded,
                    color: Colors.blue,
                    reportType: 'daily_report',
                    data: data,
                  ),
                  const SizedBox(height: 12),
                  _buildReportCard(
                    context: context,
                    theme: theme,
                    title: "تقرير المراجعة",
                    subtitle: "عرض تقارير المراجعة للطلاب",
                    icon: Icons.rate_review_rounded,
                    color: Colors.green,
                    reportType: 'review',
                    data: data,
                  ),
                  const SizedBox(height: 12),
                  _buildReportCard(
                    context: context,
                    theme: theme,
                    title: "تقرير الغياب",
                    subtitle: "عرض سجل حضور وغياب الطلاب",
                    icon: Icons.event_busy_rounded,
                    color: Colors.orange,
                    reportType: 'attendance',
                    data: data,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard({
    required BuildContext context,
    required ThemeData theme,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String reportType,
    dynamic data,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Get.to(
              () => CircleReportView(),
              arguments: {
                'report_type': reportType,
                'report_title': title,
                'id_circle': data?['id_circle'],
                'id_user': data?['id_user'],
              },
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // أيقونة التقرير
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                
                // معلومات التقرير
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // سهم
                Icon(
                  Icons.chevron_left_rounded,
                  color: color,
                  size: 28,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
