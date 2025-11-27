import 'package:althfeth/api/LinkApi.dart';
import 'package:althfeth/api/apiFunction.dart';
import 'package:althfeth/constants/color.dart';
import 'package:althfeth/constants/inline_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../constants/ErrorRetryWidget.dart';
import '../../../constants/function.dart';
import '../../../constants/app_theme.dart';

class VisitResultsPage extends StatelessWidget {
  final VisitResultsController controller = Get.put(VisitResultsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "الزيارات الفنية",
          style: AppTheme.headingMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryColor,
                AppTheme.primaryColor.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.backgroundColor,
              Colors.white,
              AppTheme.backgroundColor.withOpacity(0.3),
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
        child: Obx(() {
          if (controller.loadingVisits.value) {
            return _buildLoadingState();
          }

          if (controller.visits.isEmpty) {
            if(controller.noHasData.value) {
              return _buildEmptyState();
            }

            return ErrorRetryWidget(
              onRetry: () => controller.loadVisits(),
            );
          }

          return _buildVisitsList();
        }),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingXXLarge),
        margin: const EdgeInsets.all(AppTheme.spacingLarge),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingLarge),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: AppTheme.spacingLarge),
            Text(
              "جاري تحميل الزيارات...",
              style: AppTheme.bodyLarge.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingXXLarge),
        margin: const EdgeInsets.all(AppTheme.spacingLarge),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Colors.grey.shade50,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
          boxShadow: [
            BoxShadow(
              color: AppTheme.reportColors[2].withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 2,
            ),
          ],
          border: Border.all(
            color: AppTheme.reportColors[2].withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingXLarge),
              decoration: BoxDecoration(
                color: AppTheme.reportColors[2].withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.assignment_outlined,
                size: 64,
                color: AppTheme.reportColors[2],
              ),
            ),
            const SizedBox(height: AppTheme.spacingLarge),
            Text(
              "لا توجد زيارات فنية بعد",
              style: AppTheme.headingMedium.copyWith(
                color: AppTheme.reportColors[2],
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingMedium),
            Text(
              "سيتم عرض الزيارات الفنية هنا عند إضافتها",
              style: AppTheme.bodyMedium.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisitsList() {
    return Column(
      children: [
        // عنوان القسم
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppTheme.spacingLarge),
          margin: const EdgeInsets.all(AppTheme.spacingMedium),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.reportColors[2].withOpacity(0.1),
                AppTheme.reportColors[2].withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            border: Border.all(
              color: AppTheme.reportColors[2].withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingMedium),
                decoration: BoxDecoration(
                  color: AppTheme.reportColors[2].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Icon(
                  Icons.assignment_turned_in_outlined,
                  color: AppTheme.reportColors[2],
                  size: 24,
                ),
              ),
              const SizedBox(width: AppTheme.spacingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "الزيارات الفنية",
                      style: AppTheme.headingMedium.copyWith(
                        color: AppTheme.reportColors[2],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingXSmall),
                    Text(
                      "${controller.visits.length} زيارة متاحة",
                      style: AppTheme.bodyMedium.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // قائمة الزيارات
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMedium),
            itemCount: controller.visits.length,
            itemBuilder: (context, index) {
              final visit = controller.visits[index];
              return _buildVisitCard(visit, context);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVisitCard(Map<String, dynamic> visit, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            Colors.grey.shade50,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
        boxShadow: [
          BoxShadow(
            color: AppTheme.reportColors[2].withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: AppTheme.reportColors[2].withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
          onTap: () => controller.viewVisitResults(visit),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // رأس الكارت
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingLarge),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.reportColors[1].withOpacity(0.05),
                        AppTheme.reportColors[2].withOpacity(0.05),

                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                    border: Border.all(
                      color: AppTheme.reportColors[2].withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppTheme.spacingMedium),
                        decoration: BoxDecoration(
                          color: AppTheme.reportColors[2].withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        ),
                        child: Icon(
                          Icons.assignment_turned_in_outlined,
                          color: AppTheme.reportColors[2],
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingMedium),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              visit["name_visit_type"] ?? "زيارة فنية",
                              style: AppTheme.headingMedium.copyWith(
                                color: AppTheme.reportColors[2],
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: AppTheme.spacingXSmall),
                            Text(
                              "${visit["name_circle"]}",
                              style: AppTheme.bodyMedium.copyWith(
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(AppTheme.spacingSmall),
                        decoration: BoxDecoration(
                          color: AppTheme.reportColors[2].withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: AppTheme.reportColors[2],
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.spacingLarge),
                
                // معلومات إضافية
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingMedium),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    border: Border.all(
                      color: Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppTheme.spacingXSmall),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                            ),
                            child: Icon(
                              Icons.calendar_today_outlined,
                              size: 16,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          const SizedBox(width: AppTheme.spacingSmall),
                          Expanded(
                            child: Text(
                              "${visit["name_year"]} - ${visit["month_name"]}",
                              style: AppTheme.bodyMedium.copyWith(
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (visit["notes"] != null && visit["notes"].toString().isNotEmpty) ...[
                        const SizedBox(height: AppTheme.spacingMedium),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppTheme.spacingXSmall),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                              ),
                              child: Icon(
                                Icons.note_outlined,
                                size: 16,
                                color: Colors.orange.shade700,
                              ),
                            ),
                            const SizedBox(width: AppTheme.spacingSmall),
                            Expanded(
                              child: Text(
                                visit["notes"],
                                style: AppTheme.bodySmall.copyWith(
                                  color: Colors.grey.shade600,
                                  fontStyle: FontStyle.italic,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class VisitResultsController extends GetxController {
  var dataArg;
  RxList<Map<String, dynamic>> visits = <Map<String, dynamic>>[].obs;
  RxBool loadingVisits = false.obs;
  RxBool noHasData = false.obs;

  @override
  void onInit() {
    super.onInit();
    dataArg = Get.arguments;
    WidgetsBinding.instance.addPostFrameCallback((_) => loadVisits());
  }

  Future<void> loadVisits() async {
    var res = await handleRequest(
      isLoading: loadingVisits,
      useDialog: false,
      immediateLoading: true,
      action: () async {
        return await postData(Linkapi.select_previous_visits, {
          "id_circle": dataArg["id_circle"],
        });
      },
    );

    if (res == null) return;

    if (res is! Map) {
      mySnackbar("خطأ", "فشل الاتصال بالخادم");
      return;
    }

    if (res["stat"] == "ok") {
      // تصفية الزيارات الفنية فقط (id_visit_type == 1)
      final allVisits = List<Map<String, dynamic>>.from(res["data"]);
      final technicalVisits = allVisits.where((visit) => 
        visit["id_visit_type"] == 1 || visit["id_visit_type"] == "1"
      ).toList();
      visits.assignAll(technicalVisits);
    }
    else if(res["stat"]=="no"){
      visits.clear();
      noHasData.value=true;
    }
  }

  Future<void> viewVisitResults(Map<String, dynamic> visit) async {
    Get.to(() => VisitResultsDetailsPage(), arguments: {
      "id_visit": visit["id_visit"],
      "visit_info": visit,
    });
  }
}

class VisitResultsDetailsPage extends StatelessWidget {
  final VisitResultsDetailsController controller = Get.put(VisitResultsDetailsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "تفاصيل النتائج",
          style: AppTheme.headingMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryColor,
                AppTheme.primaryColor.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          Obx(() => controller.results.isNotEmpty
              ? Container(
                  margin: const EdgeInsets.only(right: AppTheme.spacingSmall),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                    tooltip: "طباعة التقرير",
                    onPressed: () => controller.generatePDF(),
                  ),
                )
              : const SizedBox()),
        ],
      ),
      body: Obx(() {
        if (controller.loadingResults.value) {
          return InlineLoading(message: "جاري تحميل النتائج...");
        }

        if (controller.results.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.inbox_outlined, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  "لا توجد نتائج لهذه الزيارة",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.results.length,
          itemBuilder: (context, index) {
            final result = controller.results[index];
            return _buildResultCard(result);
          },
        );
      }),
    );
  }

  Widget _buildResultCard(Map<String, dynamic> result) {
    final hasMonthly = result["from_id_soura_monthly"] != null;
    final hasRevision = result["from_id_soura_revision"] != null;

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingSmall),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // اسم الطالب في صف واحد
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      result["name_student"][0],
                      style: AppTheme.bodyLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMedium),
                Expanded(
                  child: Text(
                    result["name_student"],
                    style: AppTheme.headingMedium.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            
            // فاصل خفيف
            const SizedBox(height: AppTheme.spacingMedium),
            Container(
              height: 1,
              color: Colors.grey.shade200,
            ),
            const SizedBox(height: AppTheme.spacingMedium),

            // الاختبارات في صفوف منظمة
            if (hasMonthly || hasRevision) ...[
              Row(
                children: [
                  if (hasMonthly) ...[
                    Expanded(
                      child: _buildTestSection(
                        "الاختبار الشهري",
                        Icons.calendar_month_outlined,
                        AppTheme.reportColors[1],
                        result["from_soura_monthly_name"],
                        result["to_soura_monthly_name"],
                        result["from_id_aya_monthly"],
                        result["to_id_aya_monthly"],
                        result["hifz_monthly"],
                        result["tilawa_monthly"],
                      ),
                    ),
                  ],
                  if (hasMonthly && hasRevision) 
                    const SizedBox(width: AppTheme.spacingMedium),
                  if (hasRevision) ...[
                    Expanded(
                      child: _buildTestSection(
                        "المراجعة",
                        Icons.refresh_outlined,
                        AppTheme.reportColors[3],
                        result["from_soura_revision_name"],
                        result["to_soura_revision_name"],
                        result["from_id_aya_revision"],
                        result["to_id_aya_revision"],
                        result["hifz_revision"],
                        result["tilawa_revision"],
                      ),
                    ),
                  ],
                ],
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingMedium),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.grey.shade600,
                      size: 20,
                    ),
                    const SizedBox(width: AppTheme.spacingSmall),
                    Text(
                      "لم يتم اختبار هذا الطالب",
                      style: AppTheme.bodyMedium.copyWith(
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTestSection(String title, IconData icon, Color color, 
      String? fromSoura, String? toSoura, dynamic fromAya, dynamic toAya, 
      dynamic hifzMark, dynamic tilawaMark) {
    
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان القسم
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: AppTheme.spacingSmall),
              Expanded(
                child: Text(
                  title,
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingSmall),
          
          // معلومات السور
          if (fromSoura != null) ...[
            Text(
              "من: $fromSoura ${fromAya != null ? '($fromAya)' : ''}",
              style: AppTheme.bodySmall.copyWith(
                color: Colors.grey.shade700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              "إلى: $toSoura ${toAya != null ? '($toAya)' : ''}",
              style: AppTheme.bodySmall.copyWith(
                color: Colors.grey.shade700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppTheme.spacingSmall),
          ],
          
          // الدرجات في صف واحد
          Row(
            children: [
              if (hifzMark != null) ...[
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getMarkColor(hifzMark),
                    ),
                    child: Text(
                      "حفظ: $hifzMark",
                      style: AppTheme.bodySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
              ],
              if (tilawaMark != null) ...[
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getMarkColor(tilawaMark),
                    ),
                    child: Text(
                      "تلاوة: $tilawaMark",
                      style: AppTheme.bodySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }



  Color _getMarkColor(dynamic mark) {
    if (mark == null) return Colors.grey;
    final score = double.tryParse(mark.toString()) ?? 0;
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }
}

class VisitResultsDetailsController extends GetxController {
  var dataArg;
  RxList<Map<String, dynamic>> results = <Map<String, dynamic>>[].obs;
  RxBool loadingResults = false.obs;

  @override
  void onInit() {
    super.onInit();
    dataArg = Get.arguments;
    WidgetsBinding.instance.addPostFrameCallback((_) => loadResults());
  }

  Future<void> loadResults() async {
    var res = await handleRequest(
      isLoading: loadingResults,
      useDialog: false,
      immediateLoading: true,
      action: () async {
        return await postData(Linkapi.select_visit_results, {
          "id_visit": dataArg["id_visit"],
        });
      },
    );

    if (res == null) {
      mySnackbar("خطأ", "فشل الاتصال بالخادم");
      return;
    }

    if (res is! Map) {
      mySnackbar("خطأ", "استجابة غير صحيحة من الخادم");
      return;
    }
    
    if (res["stat"] == "ok") {
      if (res["data"] != null && res["data"] is List) {
        results.assignAll(List<Map<String, dynamic>>.from(res["data"]));
      }
    } else if (res["stat"] == "no") {
      mySnackbar("تنبيه", res["msg"] ?? "لا توجد نتائج لهذه الزيارة");
    } else if (res["stat"] == "error") {
      mySnackbar("خطأ", res["msg"] ?? "حدث خطأ أثناء جلب البيانات");
    }
  }

  Future<void> generatePDF() async {
    if (results.isEmpty) {
      mySnackbar("تنبيه", "لا توجد بيانات للتصدير");
      return;
    }

    try {
      final pdf = pw.Document();
      final visitInfo = dataArg["visit_info"];
      
      // تحميل الخط العربي
      final fontData = await rootBundle.load('assets/fonts/Amiri-Bold.ttf');
      final arabicFont = pw.Font.ttf(fontData);
      
      // تحميل الشعار
      pw.ImageProvider? logoImage;
      try {
        final logoData = await rootBundle.load('assets/icon/app_icon.png');
        logoImage = pw.MemoryImage(logoData.buffer.asUint8List());
      } catch (e) {
        print('تعذر تحميل الشعار: $e');
      }

      // إحصائيات سريعة
      final testedStudents = results.where((r) => 
        r["hifz_monthly"] != null || r["hifz_revision"] != null ||
        r["tilawa_monthly"] != null || r["tilawa_revision"] != null
      ).length;
      final untestedStudents = results.length - testedStudents;

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(20),
          textDirection: pw.TextDirection.rtl,
          theme: pw.ThemeData.withFont(base: arabicFont, bold: arabicFont),
          build: (context) {
            return [
              // رأس الصفحة الاحترافي
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 10),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // الجانب الأيسر: الشعار + المؤسسة
                    pw.Row(
                      children: [
                        if (logoImage != null) ...[
                          pw.Container(
                            width: 45,
                            height: 45,
                            child: pw.Image(logoImage),
                          ),
                          pw.SizedBox(width: 8),
                        ],
                        pw.Directionality(
                          textDirection: pw.TextDirection.rtl,
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'مؤسسة مسارات',
                                style: pw.TextStyle(
                                  fontSize: 12,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              pw.Text(
                                'للتنمية الإنسانية',
                                style: const pw.TextStyle(fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // الجانب الأيمن: اسم التقرير + التفاصيل
                    pw.Directionality(
                      textDirection: pw.TextDirection.rtl,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text(
                            'تقرير نتائج الزيارة الفنية',
                            style: pw.TextStyle(
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            '${visitInfo["name_visit_type"]}',
                            style: const pw.TextStyle(fontSize: 11),
                          ),
                          pw.SizedBox(height: 2),
                          
                          pw.Text(
                            'الحلقة: ${visitInfo["name_circle"]} | ${visitInfo["name_year"]} - ${visitInfo["month_name"]}',
                            style: const pw.TextStyle(fontSize: 8),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Divider(thickness: 1.5),
              pw.SizedBox(height: 15),

              // جدول النتائج
              pw.Directionality(
                textDirection: pw.TextDirection.rtl,
                child: pw.Table.fromTextArray(
                  headers: ['الحالة', 'تلاوة مراجعة', 'حفظ مراجعة', 'تلاوة شهرية', 'حفظ شهري', 'اسم الطالب', '#'],
                  data: results.asMap().entries.map((entry) {
                    final index = entry.key + 1;
                    final result = entry.value;
                    
                    final hifzMonthly = result["hifz_monthly"]?.toString() ?? '-';
                    final tilawaMonthly = result["tilawa_monthly"]?.toString() ?? '-';
                    final hifzRevision = result["hifz_revision"]?.toString() ?? '-';
                    final tilawaRevision = result["tilawa_revision"]?.toString() ?? '-';
                    
                    final isTested = hifzMonthly != '-' || tilawaMonthly != '-' || 
                                   hifzRevision != '-' || tilawaRevision != '-';
                    
                    return [
                      isTested ? 'مختبر' : 'غير مختبر',
                      tilawaRevision,
                      hifzRevision,
                      tilawaMonthly,
                      hifzMonthly,
                      result["name_student"] ?? '-',
                      index.toString(),
                    ];
                  }).toList(),
                  border: pw.TableBorder.all(width: 0.5, color: PdfColors.teal300),
                  headerStyle: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                  headerDecoration: const pw.BoxDecoration(
                    color: PdfColors.teal,
                  ),
                  cellStyle: const pw.TextStyle(fontSize: 9),
                  cellAlignment: pw.Alignment.center,
                  cellHeight: 22,
                  headerHeight: 28,
                  cellDecoration: (index, data, rowNum) {
                    return pw.BoxDecoration(
                      color: rowNum % 2 == 0 
                          ? PdfColors.white 
                          : PdfColors.grey100,
                    );
                  },
                ),
              ),
              
              pw.Spacer(),
              
              // تذييل الصفحة
              pw.SizedBox(height: 10),
              pw.Divider(),
              pw.Directionality(
                textDirection: pw.TextDirection.rtl,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      "تاريخ الطباعة: ${DateTime.now().toLocal().toString().split(' ')[0]}",
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                    pw.Text(
                      "مؤسسة مسارات للتنمية الإنسانية",
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ],
                ),
              ),
            ];
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
        name: 'تقرير_نتائج_الزيارة_${visitInfo["name_circle"]}.pdf',
      );

      mySnackbar("نجح", "تم إنشاء التقرير بنجاح", type: "g");
    } catch (e) {
      print("PDF Error: $e");
      mySnackbar("خطأ", "حدث خطأ أثناء إنشاء التقرير: $e");
    }
  }

  Color _getMarkColor(dynamic mark) {
    if (mark == null) return Colors.grey;
    final score = double.tryParse(mark.toString()) ?? 0;
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }
}
