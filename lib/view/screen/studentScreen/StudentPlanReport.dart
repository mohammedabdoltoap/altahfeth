import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

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
              
              // عنوان القائمة
              Text(
                "الخطط الدراسية (${controller.planList.length})",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
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
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withOpacity(0.8),
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person,
                size: 35,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.studentName.value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "عدد الخطط: ${controller.planList.length}",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
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
    final startDate = plan['start_date'] != null 
        ? _formatDate(plan['start_date']) 
        : 'غير محدد';
    final endDate = plan['end_date'] != null 
        ? _formatDate(plan['end_date']) 
        : 'غير محدد';
    final days = plan['days']?.toString() ?? '0';
    
    // حساب الحالة (منتهية، جارية، قادمة)
    final status = _getPlanStatus(plan['start_date'], plan['end_date']);
    final statusColor = _getStatusColor(status);
    final statusIcon = _getStatusIcon(status);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showPlanDetails(plan, theme),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border(
              right: BorderSide(
                color: statusColor,
                width: 4,
              ),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // رأس البطاقة
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "خطة #$index",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(statusIcon, color: statusColor, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        status,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.chevron_left_rounded,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
              const Divider(height: 24),
              
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, ThemeData theme) {
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary.withOpacity(0.7)),
        const SizedBox(width: 8),
        Text(
          "$label:",
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
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
      return DateFormat('yyyy/MM/dd', 'ar').format(parsedDate);
    } catch (e) {
      return date;
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
              _buildDetailRow("تفاصيل المستوى", plan['level_detail_name'] ?? 'غير محدد'),
              _buildDetailRow("تاريخ البدء", _formatDate(plan['start_date'])),
              _buildDetailRow("تاريخ الانتهاء", _formatDate(plan['end_date'])),
              _buildDetailRow("عدد الأيام", "${plan['days'] ?? '0'} يوم"),
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
      print("========== DEBUG loadStudentPlan ==========");
      print("API URL: ${Linkapi.select_student_plan}");
      print("Sending data: {id_student: $studentId}");
      
      final res = await handleRequest(isLoading: isLoading,
        useDialog: false,

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

        // ترتيب الخطط بناءً على المستوى الحالي والتطور
        List<Map<String, dynamic>> allPlans = List<Map<String, dynamic>>.from(res['data'] ?? []);
        allPlans.sort((a, b) {
          try {
            int levelIdA = int.tryParse(a['id_level']?.toString() ?? '0') ?? 0;
            int levelIdB = int.tryParse(b['id_level']?.toString() ?? '0') ?? 0;
            int stageIdA = int.tryParse(a['id_stages']?.toString() ?? '0') ?? 0;
            int stageIdB = int.tryParse(b['id_stages']?.toString() ?? '0') ?? 0;
            
            // أولاً: ترتيب حسب المرحلة
            if (stageIdA != stageIdB) {
              // المرحلة الحالية أولاً
              if (stageIdA == currentStageId) return -1;
              if (stageIdB == currentStageId) return 1;
              // ثم المراحل بالترتيب التصاعدي
              return stageIdA.compareTo(stageIdB);
            }
            
            // ثانياً: إذا كانت نفس المرحلة، رتب حسب المستوى
            // المستوى الحالي أولاً
            if (levelIdA == currentLevelId) return -1;
            if (levelIdB == currentLevelId) return 1;
            
            // ثم المستويات بالترتيب التصاعدي
            return levelIdA.compareTo(levelIdB);
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
      'المرحلة',
      'المستوى',
      'تفاصيل المستوى',
      'تاريخ البدء',
      'تاريخ الانتهاء',
      'عدد الأيام',
    ];

    final rows = planList.map((plan) => [
      (plan['stage_name'] ?? 'غير محدد').toString(),
      (plan['level_name'] ?? 'غير محدد').toString(),
      (plan['level_detail_name'] ?? 'غير محدد').toString(),
      _formatDateForPdf(plan['start_date']),
      _formatDateForPdf(plan['end_date']),
      (plan['days']?.toString() ?? '0'),
    ]).toList();

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
      return DateFormat('yyyy/MM/dd').format(parsedDate);
    } catch (e) {
      return date;
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
