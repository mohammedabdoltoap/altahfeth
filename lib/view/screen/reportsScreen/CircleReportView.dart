import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../controller/reportsController/CircleReportController.dart';

class CircleReportView extends StatelessWidget {
  final CircleReportController controller = Get.put(CircleReportController());

  CircleReportView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Obx(() => Text(
          controller.reportTitle.value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        )),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        elevation: 0,
        actions: [
          // زر الطباعة
          Obx(() => controller.reportData.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.print_rounded),
                  onPressed: () => controller.generatePDF(),
                  tooltip: "طباعة PDF",
                )
              : const SizedBox()),
          // زر التحديث
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => controller.fetchReport(),
            tooltip: "تحديث",
          ),
        ],
      ),
      body: Column(
        children: [
          // فلاتر التاريخ
          _buildDateFilters(theme),
          
          // محتوى التقرير
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "جاري تحميل التقرير...",
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                );
              }

              if (controller.reportData.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.description_outlined,
                        size: 80,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "لا توجد بيانات للفترة المحددة",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "جرب تغيير نطاق التاريخ",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return _buildReportContent(theme);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDateFilters(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // عنوان الفلاتر
          Row(
            children: [
              Icon(
                Icons.filter_list_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                "تحديد نطاق التاريخ",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // حقول التاريخ
          Row(
            children: [
              // من
              Expanded(
                child: _buildDateField(
                  theme: theme,
                  label: "من",
                  date: controller.startDate,
                  onTap: () => controller.selectStartDate(),
                ),
              ),
              const SizedBox(width: 12),
              // إلى
              Expanded(
                child: _buildDateField(
                  theme: theme,
                  label: "إلى",
                  date: controller.endDate,
                  onTap: () => controller.selectEndDate(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // زر البحث
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => controller.fetchReport(),
              icon: const Icon(Icons.search_rounded),
              label: const Text(
                "عرض التقرير",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: theme.colorScheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField({
    required ThemeData theme,
    required String label,
    required Rx<DateTime> date,
    required VoidCallback onTap,
  }) {
    return Obx(() => InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              color: theme.colorScheme.primary,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    DateFormat('yyyy-MM-dd', 'en').format(date.value),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildReportContent(ThemeData theme) {
    return Obx(() {
      final reportType = controller.reportType.value;
      
      if (reportType == 'daily_report') {
        return _buildDailyReportList(theme);
      } else if (reportType == 'review') {
        return _buildReviewReportList(theme);
      } else if (reportType == 'attendance') {
        return _buildAttendanceReportList(theme);
      }
      
      return const SizedBox();
    });
  }

  Widget _buildDailyReportList(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.groupedData.length,
      itemBuilder: (context, index) {
        final studentData = controller.groupedData[index];
        final records = List<Map<String, dynamic>>.from(studentData['records'] ?? []);
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.withOpacity(0.1),
              child: Icon(
                Icons.person_rounded,
                color: Colors.blue,
              ),
            ),
            title: Text(
              studentData['name_student'] ?? 'طالب',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              "${records.length} سجل تسميع",
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
            children: records.map((report) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 14, color: Colors.blue),
                        const SizedBox(width: 6),
                        Text(
                          "التاريخ: ${report['date'] ?? '-'}",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    _buildInfoRow(
                      icon: Icons.book_rounded,
                      label: "التسميع",
                      value: report['recitation'] ?? '-',
                    ),
                    const Divider(height: 12),
                    _buildInfoRow(
                      icon: Icons.star_rounded,
                      label: "التقييم",
                      value: report['evaluation_name'] != null 
                          ? '${report['evaluation_name']} (${report['mark'] ?? '-'})'
                          : report['mark']?.toString() ?? '-',
                    ),
                    if (report['notes'] != null && report['notes'].toString().isNotEmpty) ...[
                      const Divider(height: 12),
                      _buildInfoRow(
                        icon: Icons.notes_rounded,
                        label: "الملاحظات",
                        value: report['notes'] ?? '-',
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildReviewReportList(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.groupedData.length,
      itemBuilder: (context, index) {
        final studentData = controller.groupedData[index];
        final records = List<Map<String, dynamic>>.from(studentData['records'] ?? []);
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green.withOpacity(0.1),
              child: Icon(
                Icons.person_rounded,
                color: Colors.green,
              ),
            ),
            title: Text(
              studentData['name_student'] ?? 'طالب',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              "${records.length} سجل مراجعة",
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
            children: records.map((review) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 14, color: Colors.green),
                        const SizedBox(width: 6),
                        Text(
                          "التاريخ: ${review['date'] ?? '-'}",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    _buildInfoRow(
                      icon: Icons.rate_review_rounded,
                      label: "المراجعة",
                      value: review['review_content'] ?? '-',
                    ),
                    const Divider(height: 12),
                    _buildInfoRow(
                      icon: Icons.star_rounded,
                      label: "التقييم",
                      value: review['evaluation_name'] != null 
                          ? '${review['evaluation_name']} (${review['mark'] ?? '-'})'
                          : review['mark']?.toString() ?? '-',
                    ),
                    if (review['notes'] != null && review['notes'].toString().isNotEmpty) ...[
                      const Divider(height: 12),
                      _buildInfoRow(
                        icon: Icons.notes_rounded,
                        label: "الملاحظات",
                        value: review['notes'] ?? '-',
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildAttendanceReportList(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.groupedData.length,
      itemBuilder: (context, index) {
        final studentData = controller.groupedData[index];
        final records = List<Map<String, dynamic>>.from(studentData['records'] ?? []);
        
        // ✅ حساب الحضور والغياب
        int present = 0;
        int absent = 0;
        int excused = 0;
        
        for (var record in records) {
          final status = record['status'];
          if (status == 1 || status == '1') {
            present++;
          } else if (status == 2 || status == '2') {
            excused++;
          } else {
            absent++;
          }
        }
        
        final total = records.length;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: Colors.orange.withOpacity(0.1),
              child: Icon(
                Icons.person_rounded,
                color: Colors.orange,
              ),
            ),
            title: Text(
              studentData['name_student'] ?? 'طالب',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            // ✅ عرض ملخص الحضور والغياب
            subtitle: Text(
              'الحضور: $present | الغياب بدون عذر: $absent | الغياب بعذر: $excused | الإجمالي: $total',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
            children: records.map((attendance) {
              // تحديد الحالة
              Color statusColor;
              IconData statusIcon;
              String statusText = attendance['status_text'] ?? 'غائب';
              
              if (attendance['status'] == 1 || attendance['status'] == '1') {
                statusColor = Colors.green;
                statusIcon = Icons.check_circle_rounded;
              } else if (attendance['status'] == 2 || attendance['status'] == '2') {
                statusColor = Colors.orange;
                statusIcon = Icons.info_rounded;
              } else {
                statusColor = Colors.red;
                statusIcon = Icons.cancel_rounded;
              }
              
              return Container(
                margin: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withOpacity(0.3), width: 2),
                ),
                child: Row(
                  children: [
                    Icon(statusIcon, color: statusColor, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "التاريخ: ${attendance['date'] ?? '-'}",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              statusText,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                          ),
                          if (attendance['notes'] != null && attendance['notes'].toString().isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              "ملاحظات: ${attendance['notes']}",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
