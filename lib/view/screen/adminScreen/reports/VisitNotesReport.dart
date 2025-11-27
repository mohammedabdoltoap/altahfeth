import 'package:althfeth/api/LinkApi.dart';
import 'package:althfeth/api/apiFunction.dart';
import 'package:althfeth/constants/function.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class VisitNotesReport extends StatelessWidget {
  final VisitNotesReportController controller = Get.put(VisitNotesReportController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ملاحظات الزيارات"),
        backgroundColor: Colors.amber,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.amber.shade50,
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
                    backgroundColor: Colors.amber,
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

              if (controller.notesList.isEmpty) {
                return const Center(child: Text("لا توجد ملاحظات"));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.notesList.length,
                itemBuilder: (context, index) {
                  final note = controller.notesList[index];
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ExpansionTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.amber,
                        child: Icon(Icons.note, color: Colors.white),
                      ),
                      title: Text(
                        note['name_circle'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('التاريخ: ${note['note_date']?.toString().substring(0, 10) ?? ''}'),
                          Text('الأستاذ: ${note['teacher_name'] ?? ''}'),
                          Text('الزائر: ${note['visitor_name'] ?? ''}'),
                        ],
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.amber.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'الملاحظة:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  note['note'] ?? 'لا توجد ملاحظة',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
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
}

class VisitNotesReportController extends GetxController {
  var startDate = Rxn<DateTime>();
  var endDate = Rxn<DateTime>();
  var notesList = <Map<String, dynamic>>[].obs;
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
      
      final response = await postData(Linkapi.select_visit_notes_report, requestData);

      print("========== VISIT NOTES RESPONSE ==========");
      print("Response: $response");
      print("Response Type: ${response.runtimeType}");
      
      if (response == null || response is! Map) {
        print("ERROR: Response is null or not a Map");
        mySnackbar("خطأ", "فشل الاتصال بالخادم");
        notesList.clear();
        return;
      }
      
      print("Response stat: ${response['stat']}");
      print("Response msg: ${response['msg']}");
      print("Response data: ${response['data']}");
      
      if (response['stat'] == 'ok') {
        notesList.assignAll(List<Map<String, dynamic>>.from(response['data']));
        mySnackbar("نجح", "تم تحميل ${notesList.length} ملاحظة", type: "g");
      } else {
        notesList.clear();
        mySnackbar("تنبيه", response['msg'] ?? "لا توجد بيانات");
      }
    } catch (e, stackTrace) {
      print("========== ERROR IN VISIT NOTES ==========");
      print("Error: $e");
      print("StackTrace: $stackTrace");
      print("==========================================");
      mySnackbar("خطأ", "حدث خطأ: $e");
      notesList.clear();
    } finally {
      loading.value = false;
    }
  }
}
