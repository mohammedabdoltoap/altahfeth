import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';

import '../../../api/LinkApi.dart';
import '../../../api/apiFunction.dart';
import '../../../constants/ErrorRetryWidget.dart';
import '../../../constants/function.dart';
import '../../../constants/myreport.dart';

class StudentPlanReport extends StatelessWidget {
  final StudentPlanController controller = Get.put(StudentPlanController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "خطة الطالب",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.colorScheme.primary,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => controller.loadStudentPlan(),
            tooltip: "تحديث",
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_rounded),
            onPressed: () => controller.generatePlanPdf(),
            tooltip: "تصدير PDF",
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: theme.colorScheme.primary),
                const SizedBox(height: 16),
                const Text(
                  "جاري تحميل خطة الطالب...",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          );
        }

        if (controller.planList.isEmpty) {
          // التحقق من نوع المشكلة
          if (controller.hasNetworkError.value) {
            // خطأ في الشبكة أو الاتصال
            return ErrorRetryWidget(
              onRetry: () => controller.loadStudentPlan(),
            );
          } else {
            // لا توجد خطة للطالب (stat: "no")
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    size: 100,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "لا توجد خطة للطالب",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "لم يتم إنشاء خطة دراسية لهذا الطالب بعد",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadStudentPlan(),
          color: theme.colorScheme.primary,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // معلومات الطالب
              _buildStudentInfoCard(theme),
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.list_alt_rounded,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "الخطط الدراسية (${controller.planList.length})",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              
              // قائمة الخطط
              ...controller.planList.asMap().entries.map((entry) {
                int index = entry.key;
                Map<String, dynamic> plan = entry.value;
                return _buildPlanCard(plan, index + 1, theme);
              }).toList(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStudentInfoCard(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.7),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person_rounded,
                  size: 32,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.studentName.value.isNotEmpty 
                        ? controller.studentName.value 
                        : 'الطالب',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.assignment_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "${controller.planList.length} خطة",
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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

  Widget _buildPlanCard(Map<String, dynamic> plan, int index, ThemeData theme) {
    try {
      final startDate = plan['start_date'] != null 
          ? _formatDate(plan['start_date']?.toString()) 
          : 'غير محدد';
      final endDate = plan['end_date'] != null 
          ? _formatDate(plan['end_date']?.toString()) 
          : 'غير محدد';
      final days = (plan['days']?.toString() ?? plan['level_detail_days']?.toString() ?? '0');
      
      final status = _getPlanStatus(plan['start_date']?.toString(), plan['end_date']?.toString());
      final statusColor = _getStatusColor(status);
      final statusIcon = _getStatusIcon(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showPlanDetails(plan, theme),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: statusColor.withOpacity(0.3),
                width: 2,
              ),
            ),
            padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(statusIcon, color: statusColor, size: 22),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "خطة #$index",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            status,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_left_rounded,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // المعلومات الأساسية
              _buildInfoRow(
                Icons.calendar_today_rounded,
                "تاريخ البدء",
                startDate,
                theme,
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.event_rounded,
                "تاريخ الانتهاء",
                endDate,
                theme,
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.access_time_rounded,
                "عدد الأيام",
                "$days يوم",
                theme,
              ),
              
              // المراحل والمستويات
              if (plan['stage_name'] != null || plan['level_name'] != null) ...[
                const Divider(height: 24),
                Row(
                  children: [
                    if (plan['stage_name'] != null)
                      Expanded(
                        child: _buildChip(
                          "المرحلة: ${plan['stage_name']}",
                          theme.colorScheme.secondary,
                        ),
                      ),
                    if (plan['stage_name'] != null && plan['level_name'] != null)
                      const SizedBox(width: 8),
                    if (plan['level_name'] != null)
                      Expanded(
                        child: _buildChip(
                          "المستوى: ${plan['level_name']}",
                          theme.colorScheme.tertiary,
                        ),
                      ),
                  ],
                ),
              ],
              
              if (plan['from_soura_name'] != null && plan['to_soura_name'] != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.orange.shade50,
                        Colors.orange.shade100.withOpacity(0.3),
                      ],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.orange.shade300, width: 2),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.menu_book_rounded,
                            color: Colors.orange.shade700,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "نطاق الحفظ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.orange.shade900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.orange.shade200,
                                    blurRadius: 3,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    "من",
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    plan['from_soura_name']?.toString() ?? '',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Colors.orange.shade900,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 3),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade100,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      "آية ${plan['from_aya_id']?.toString() ?? '0'}",
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange.shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.orange.shade700,
                              size: 18,
                            ),
                          ),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.orange.shade200,
                                    blurRadius: 3,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    "إلى",
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    plan['to_soura_name']?.toString() ?? '',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Colors.orange.shade900,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 3),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade100,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      "آية ${plan['to_aya_id']?.toString() ?? '0'}",
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange.shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    )
    );
    } catch (e) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade700),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'خطأ في عرض الخطة #$index',
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildInfoRow(IconData icon, String label, String value, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: theme.colorScheme.primary),
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
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return 'غير محدد';
    try {
      final parsedDate = DateTime.parse(date);
      return DateFormat('yyyy/MM/dd', 'en').format(parsedDate);
    } catch (e) {
      // إذا فشل التحويل، نحاول استخراج التاريخ من النص
      try {
        final parts = date.split(' ')[0].split('-');
        if (parts.length == 3) {
          return '${parts[0]}/${parts[1]}/${parts[2]}';
        }
      } catch (_) {}
      return 'غير محدد';
    }
  }

  String _getPlanStatus(String? startDate, String? endDate) {
    if (startDate == null || endDate == null) return 'غير محدد';
    
    try {
      final now = DateTime.now();
      final start = DateTime.parse(startDate);
      final end = DateTime.parse(endDate);
      
      if (now.isBefore(start)) {
        return 'قادمة';
      } else if (now.isAfter(end)) {
        return 'منتهية';
      } else {
        return 'جارية';
      }
    } catch (e) {
      return 'غير محدد';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'جارية':
        return Colors.green;
      case 'منتهية':
        return Colors.grey;
      case 'قادمة':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'جارية':
        return Icons.play_circle_filled_rounded;
      case 'منتهية':
        return Icons.check_circle_rounded;
      case 'قادمة':
        return Icons.schedule_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  void _showPlanDetails(Map<String, dynamic> plan, ThemeData theme) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.assignment_rounded,
                    color: theme.colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "تفاصيل الخطة",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const Divider(height: 24),
              _buildDetailRow("المرحلة", plan['stage_name'] ?? 'غير محدد'),
              _buildDetailRow("المستوى", plan['level_name'] ?? 'غير محدد'),
              if (plan['from_soura_name'] != null && plan['to_soura_name'] != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.book_rounded, color: Colors.orange.shade700, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            "نطاق الحفظ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow("من سورة", "${plan['from_soura_name']} - آية ${plan['from_aya_id']}"),
                      _buildDetailRow("إلى سورة", "${plan['to_soura_name']} - آية ${plan['to_aya_id']}"),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
              _buildDetailRow("تاريخ البدء", _formatDate(plan['start_date'])),
              _buildDetailRow("تاريخ الانتهاء", _formatDate(plan['end_date'])),
              _buildDetailRow("عدد الأيام", "${plan['days'] ?? plan['level_detail_days'] ?? '0'} يوم"),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.check),
                  label: const Text("حسناً"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StudentPlanController extends GetxController {
  var planList = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  RxBool hasData = false.obs; // للتحقق من نجاح جلب البيانات
  RxBool hasNetworkError = false.obs; // للتحقق من وجود خطأ في الشبكة

  var studentName = ''.obs;
  var studentId = 0;
  var currentLevelId = 0;
  var currentStageId = 0;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args is Map) {
      studentId = args['id_student'] ?? 0;
      studentName.value = args['name_student'] ?? 'الطالب';
      currentLevelId = args['current_level_id'] ?? 0;
      currentStageId = args['current_stage_id'] ?? 0;
    }
    loadStudentPlan();
  }

  Future<void> loadStudentPlan() async {

    try {

      final res = await handleRequest(isLoading: isLoading,
        useDialog: false,
        immediateLoading:true,
        action: ()async {
        return await postData(
          Linkapi.select_student_plan,
          {"id_student": studentId},
        );
      },);


      if (res == null || res is! Map) {
        planList.clear();
        hasData.value = false;
        hasNetworkError.value = true; // خطأ في الشبكة
        return;
      }

      if (res['stat'] == 'ok') {
        print("SUCCESS: Data received");
        print("Data count: ${res['data']?.length ?? 0}");
        hasData.value = true;
        hasNetworkError.value = false;

        // ترتيب الخطط: الجارية أولاً، ثم القادمة، ثم المنتهية
        List<Map<String, dynamic>> allPlans = List<Map<String, dynamic>>.from(res['data'] ?? []);
        allPlans.sort((a, b) {
          try {
            String statusA = _getPlanStatusForSort(a['start_date'], a['end_date']);
            String statusB = _getPlanStatusForSort(b['start_date'], b['end_date']);
            
            // ترتيب الأولوية: جارية (1) > قادمة (2) > منتهية (3)
            int priorityA = statusA == 'جارية' ? 1 : (statusA == 'قادمة' ? 2 : 3);
            int priorityB = statusB == 'جارية' ? 1 : (statusB == 'قادمة' ? 2 : 3);
            
            if (priorityA != priorityB) {
              return priorityA.compareTo(priorityB);
            }
            
            // إذا كانت نفس الحالة، رتب حسب تاريخ البدء
            DateTime? dateA = DateTime.tryParse(a['start_date'] ?? '');
            DateTime? dateB = DateTime.tryParse(b['start_date'] ?? '');
            
            if (dateA != null && dateB != null) {
              // الجارية والقادمة: الأقرب أولاً (تصاعدي)
              // المنتهية: الأحدث أولاً (تنازلي)
              if (statusA == 'منتهية') {
                return dateB.compareTo(dateA);
              } else {
                return dateA.compareTo(dateB);
              }
            }
            
            return 0;
          } catch (e) {
            return 0;
          }
        });
        
        planList.assignAll(allPlans);
        print("planList updated: ${planList.length} items");
      } else if (res['stat'] == 'no') {
        hasData.value = false;
        hasNetworkError.value = false; // ليس خطأ شبكة، فقط لا توجد بيانات
        planList.clear();
      } else {
        hasData.value = false;
        hasNetworkError.value = true; // خطأ من الخادم
        planList.clear();
        mySnackbar("خطأ", res['msg'] ?? "حدث خطأ أثناء جلب البيانات");
      }
      
      print("========== END DEBUG ==========");
    } catch (e, stackTrace) {
      print("========== EXCEPTION ==========");
      print("Error: $e");
      print("StackTrace: $stackTrace");
      print("===============================");
      hasNetworkError.value = true; // خطأ غير متوقع
      planList.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> generatePlanPdf() async {
    if (planList.isEmpty) {
      mySnackbar("تنبيه", "لا توجد بيانات لتصديرها");
      return;
    }

    final headers = [
      'الأيام',
      'تاريخ الانتهاء',
      'تاريخ البدء',
      'إلى سورة',
      'من سورة',
      'المستوى',
      'المرحلة',
    ];

    final rows = planList.map((plan) {
      try {
        return [
          (plan['days']?.toString() ?? plan['level_detail_days']?.toString() ?? '0'),
          _formatDateForPdf(plan['end_date']?.toString()),
          _formatDateForPdf(plan['start_date']?.toString()),
          plan['to_soura_name'] != null 
              ? '${plan['to_soura_name']} (${plan['to_aya_id']?.toString() ?? '0'})'
              : 'غير محدد',
          plan['from_soura_name'] != null 
              ? '${plan['from_soura_name']} (${plan['from_aya_id']?.toString() ?? '0'})'
              : 'غير محدد',
          (plan['level_name']?.toString() ?? 'غير محدد'),
          (plan['stage_name']?.toString() ?? 'غير محدد'),
        ];
      } catch (e) {
        return ['0', 'خطأ', 'خطأ', 'خطأ', 'خطأ', 'خطأ', 'خطأ'];
      }
    }).toList();

    await generateStandardPdfReport(
      title: "خطة الطالب",
      subTitle: studentName.value,
      headers: headers,
      rows: rows,
    );
  }

  String _formatDateForPdf(String? date) {
    if (date == null || date.isEmpty) return 'غير محدد';
    try {
      final parsedDate = DateTime.parse(date);
      return DateFormat('yyyy/MM/dd', 'en').format(parsedDate);
    } catch (e) {
      try {
        final parts = date.split(' ')[0].split('-');
        if (parts.length == 3) {
          return '${parts[0]}/${parts[1]}/${parts[2]}';
        }
      } catch (_) {}
      return 'غير محدد';
    }
  }

  String _getPlanStatusForSort(String? startDate, String? endDate) {
    if (startDate == null || endDate == null) return 'غير محدد';

    try {
      final now = DateTime.now();
      final start = DateTime.parse(startDate);
      final end = DateTime.parse(endDate);

      if (now.isBefore(start)) {
        return 'قادمة';
      } else if (now.isAfter(end)) {
        return 'منتهية';
      } else {
        return 'جارية';
      }
    } catch (e) {
      return 'غير محدد';
    }
  }
}
