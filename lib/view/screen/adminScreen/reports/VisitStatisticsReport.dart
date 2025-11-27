import 'package:althfeth/api/LinkApi.dart';
import 'package:althfeth/api/apiFunction.dart';
import 'package:althfeth/constants/function.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class VisitStatisticsReport extends StatelessWidget {
  final VisitStatisticsReportController controller = Get.put(VisitStatisticsReportController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("إحصائيات الزيارات"),
        backgroundColor: Colors.brown,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.brown.shade50,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.calendar_today, size: 18),
                        label: Obx(() => Text(
                          controller.startDate.value != null
                              ? DateFormat('yyyy-MM-dd', 'en').format(controller.startDate.value!)
                              : "من",
                          style: const TextStyle(fontSize: 12),
                        )),
                        onPressed: () => controller.selectStartDate(context),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.calendar_today, size: 18),
                        label: Obx(() => Text(
                          controller.endDate.value != null
                              ? DateFormat('yyyy-MM-dd', 'en').format(controller.endDate.value!)
                              : "إلى",
                          style: const TextStyle(fontSize: 12),
                        )),
                        onPressed: () => controller.selectEndDate(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.search),
                  label: const Text("عرض التقرير"),
                  onPressed: () => controller.loadData(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    minimumSize: const Size(double.infinity, 45),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.loading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.statisticsList.isEmpty) {
                return const Center(child: Text("لا توجد بيانات"));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.statisticsList.length,
                itemBuilder: (context, index) {
                  final stat = controller.statisticsList[index];
                  final totalVisits = int.tryParse(stat['total_visits'].toString()) ?? 0;
                  final totalResults = int.tryParse(stat['total_exam_results'].toString()) ?? 0;
                  final avgHifz = double.tryParse(stat['avg_hifz_monthly']?.toString() ?? '0') ?? 0;
                  final avgTilawa = double.tryParse(stat['avg_tilawa_monthly']?.toString() ?? '0') ?? 0;
                  final totalNotes = int.tryParse(stat['total_notes'].toString()) ?? 0;
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ExpansionTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.brown,
                        child: Text(
                          totalVisits.toString(),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(
                        stat['name_circle'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('الأستاذ: ${stat['teacher_name'] ?? ''}'),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildStatItem('الزيارات', totalVisits.toString(), Colors.brown),
                                  _buildStatItem('النتائج', totalResults.toString(), Colors.blue),
                                  _buildStatItem('الملاحظات', totalNotes.toString(), Colors.orange),
                                ],
                              ),
                              const Divider(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildStatItem('م.حفظ', avgHifz.toStringAsFixed(1), Colors.purple),
                                  _buildStatItem('م.تلاوة', avgTilawa.toStringAsFixed(1), Colors.green),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
        ),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}

class VisitStatisticsReportController extends GetxController {
  var startDate = Rxn<DateTime>();
  var endDate = Rxn<DateTime>();
  var statisticsList = <Map<String, dynamic>>[].obs;
  var loading = false.obs;
  var dataArg;

  @override
  void onInit() {
    super.onInit();
    dataArg = Get.arguments;
    endDate.value = DateTime.now();
    startDate.value = DateTime.now().subtract(const Duration(days: 30));
  }

  Future<void> selectStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate.value ?? DateTime.now().subtract(const Duration(days: 30)),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) startDate.value = picked;
  }
  
  Future<void> selectEndDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: endDate.value ?? DateTime.now(),
      firstDate: startDate.value ?? DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) endDate.value = picked;
  }

  Future<void> loadData() async {
    if (startDate.value == null || endDate.value == null) {
      mySnackbar("تنبيه", "الرجاء اختيار الفترة الزمنية");
      return;
    }

    loading.value = true;
    try {
      Map<String, dynamic> requestData = {
        "start_date": DateFormat('yyyy-MM-dd', 'en').format(startDate.value!),
        "end_date": DateFormat('yyyy-MM-dd', 'en').format(endDate.value!),
      };
      
      if (dataArg?['id_center'] != null) {
        requestData["id_center"] = dataArg['id_center'].toString();
      }
      
      final response = await postData(Linkapi.select_visit_statistics_report, requestData);

      print("========== VISIT STATISTICS RESPONSE ==========");
      print("Response: $response");
      print("Response Type: ${response.runtimeType}");
      
      if (response == null || response is! Map) {
        print("ERROR: Response is null or not a Map");
        mySnackbar("خطأ", "فشل الاتصال بالخادم");
        statisticsList.clear();
        return;
      }
      
      print("Response stat: ${response['stat']}");
      print("Response msg: ${response['msg']}");
      print("Response data: ${response['data']}");
      
      if (response['stat'] == 'ok') {
        statisticsList.assignAll(List<Map<String, dynamic>>.from(response['data']));
        mySnackbar("نجح", "تم تحميل ${statisticsList.length} حلقة", type: "g");
      } else {
        statisticsList.clear();
        mySnackbar("تنبيه", response['msg'] ?? "لا توجد بيانات");
      }
    } catch (e, stackTrace) {
      print("========== ERROR IN VISIT STATISTICS ==========");
      print("Error: $e");
      print("StackTrace: $stackTrace");
      print("===============================================");
      mySnackbar("خطأ", "حدث خطأ: $e");
      statisticsList.clear();
    } finally {
      loading.value = false;
    }
  }
}
