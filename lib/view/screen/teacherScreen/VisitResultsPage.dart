import 'package:althfeth/api/LinkApi.dart';
import 'package:althfeth/api/apiFunction.dart';
import 'package:althfeth/constants/color.dart';
import 'package:althfeth/constants/inline_loading.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/function.dart';

class VisitResultsPage extends StatelessWidget {
  final VisitResultsController controller = Get.put(VisitResultsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("نتائج الطلاب"),
        backgroundColor: primaryGreen,
      ),
      body: Obx(() {
        if (controller.loadingVisits.value) {
          return InlineLoading(message: "جاري تحميل الزيارات...");
        }

        if (controller.visits.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.assignment_outlined, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  "لا توجد زيارات فنية",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.visits.length,
          itemBuilder: (context, index) {
            final visit = controller.visits[index];
            return _buildVisitCard(visit, context);
          },
        );
      }),
    );
  }

  Widget _buildVisitCard(Map<String, dynamic> visit, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade50, Colors.teal.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => controller.viewVisitResults(visit),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primaryGreen.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.assignment_turned_in,
                        color: primaryGreen,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            visit["name_visit_type"] ?? "زيارة فنية",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${visit["name_circle"]}",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: primaryGreen, size: 20),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      "${visit["name_year"]} - ${visit["month_name"]}",
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),
                if (visit["notes"] != null && visit["notes"].toString().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.note, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          visit["notes"],
                          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
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
        ),
      ),
    );
  }
}

class VisitResultsController extends GetxController {
  var dataArg;
  RxList<Map<String, dynamic>> visits = <Map<String, dynamic>>[].obs;
  RxBool loadingVisits = false.obs;

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
          "id_user": dataArg["id_user"],
        });
      },
    );

    if (res == null) return;

    if (res is! Map) {
      mySnackbar("خطأ", "فشل الاتصال بالخادم");
      return;
    }

    if (res["stat"] == "ok") {
      visits.assignAll(List<Map<String, dynamic>>.from(res["data"]));
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
        title: const Text("نتائج الطلاب"),
        backgroundColor: primaryGreen,
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
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student name
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: primaryGreen,
                  child: Text(
                    result["name_student"][0],
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    result["name_student"],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),

            // Monthly test
            if (hasMonthly) ...[
              _buildSectionHeader("الاختبار الشهري", Icons.calendar_month, Colors.blue),
              const SizedBox(height: 8),
              _buildTestInfo(
                "الحفظ",
                result["from_soura_monthly_name"],
                result["to_soura_monthly_name"],
                result["from_id_aya_monthly"],
                result["to_id_aya_monthly"],
                result["hifz_monthly"],
              ),
              const SizedBox(height: 8),
              _buildTestInfo(
                "التلاوة",
                result["from_soura_monthly_name"],
                result["to_soura_monthly_name"],
                result["from_id_aya_monthly"],
                result["to_id_aya_monthly"],
                result["tilawa_monthly"],
              ),
              const SizedBox(height: 16),
            ],

            // Revision test
            if (hasRevision) ...[
              _buildSectionHeader("المراجعة", Icons.refresh, Colors.orange),
              const SizedBox(height: 8),
              _buildTestInfo(
                "الحفظ",
                result["from_soura_revision_name"],
                result["to_soura_revision_name"],
                result["from_id_aya_revision"],
                result["to_id_aya_revision"],
                result["hifz_revision"],
              ),
              const SizedBox(height: 8),
              _buildTestInfo(
                "التلاوة",
                result["from_soura_revision_name"],
                result["to_soura_revision_name"],
                result["from_id_aya_revision"],
                result["to_id_aya_revision"],
                result["tilawa_revision"],
              ),
            ],

            if (!hasMonthly && !hasRevision)
              Center(
                child: Text(
                  "لم يتم اختبار الطالب",
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTestInfo(
    String type,
    String? fromSoura,
    String? toSoura,
    dynamic fromAya,
    dynamic toAya,
    dynamic mark,
  ) {
    if (fromSoura == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "$type:",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              if (mark != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getMarkColor(mark),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "$mark",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  "من: $fromSoura ${fromAya != null ? '($fromAya)' : ''}",
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  "إلى: $toSoura ${toAya != null ? '($toAya)' : ''}",
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
              ),
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

    if (res == null) return;

    if (res is! Map) {
      mySnackbar("خطأ", "فشل الاتصال بالخادم");
      return;
    }

    if (res["stat"] == "ok") {
      results.assignAll(List<Map<String, dynamic>>.from(res["data"]));
    } else if (res["stat"] == "no") {
      mySnackbar("تنبيه", res["msg"] ?? "لا توجد نتائج");
    }
  }
}
