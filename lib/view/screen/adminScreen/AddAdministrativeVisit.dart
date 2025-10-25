import 'package:althfeth/api/LinkApi.dart';
import 'package:althfeth/api/apiFunction.dart';
import 'package:althfeth/constants/function.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AddAdministrativeVisit extends StatelessWidget {
  final AddAdministrativeVisitController controller = Get.put(AddAdministrativeVisitController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("إضافة زيارة إدارية"),
        backgroundColor: Colors.indigo,
      ),
      body: Obx(() {
        if (controller.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // معلومات الزيارة
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('معلومات الزيارة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: "الحلقة", border: OutlineInputBorder()),
                        value: controller.selectedCircle.value,
                        items: controller.circlesList.map((c) => DropdownMenuItem(
                          value: c['id_circle'].toString(),
                          child: Text(c['name_circle'] ?? ''),
                        )).toList(),
                        onChanged: (val) => controller.selectedCircle.value = val,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: controller.notesController,
                        decoration: const InputDecoration(labelText: "ملاحظات عامة", border: OutlineInputBorder()),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // تقييم المدرس
              Card(
                color: Colors.purple.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.person, color: Colors.purple),
                          const SizedBox(width: 8),
                          const Text('تقييم المدرس', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...controller.teacherCriteria.map((criteria) {
                        final index = controller.teacherCriteria.indexOf(criteria);
                        return _buildEvaluationItem(
                          criteria['criteria_name'] ?? '',
                          controller.teacherRatings[index],
                          (rating) => controller.teacherRatings[index] = rating,
                          Colors.purple,
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // تقييم الطلاب
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.groups, color: Colors.blue),
                          const SizedBox(width: 8),
                          const Text('تقييم الطلاب', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...controller.studentsCriteria.map((criteria) {
                        final index = controller.studentsCriteria.indexOf(criteria);
                        return _buildEvaluationItem(
                          criteria['criteria_name'] ?? '',
                          controller.studentsRatings[index],
                          (rating) => controller.studentsRatings[index] = rating,
                          Colors.blue,
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // زر الحفظ
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text("حفظ الزيارة"),
                onPressed: () => controller.saveVisit(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildEvaluationItem(String title, RxInt rating, Function(int) onChanged, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildRatingButton('ممتاز', 5, rating.value, onChanged, color),
              _buildRatingButton('جيد جدا', 4, rating.value, onChanged, color),
              _buildRatingButton('جيد', 3, rating.value, onChanged, color),
              _buildRatingButton('مقبول', 2, rating.value, onChanged, color),
              _buildRatingButton('ضعيف', 1, rating.value, onChanged, color),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildRatingButton(String label, int value, int currentValue, Function(int) onChanged, Color color) {
    final isSelected = currentValue == value;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: ElevatedButton(
          onPressed: () => onChanged(value),
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected ? color : Colors.grey.shade200,
            foregroundColor: isSelected ? Colors.white : Colors.black87,
            padding: const EdgeInsets.symmetric(vertical: 8),
          ),
          child: Text(label, style: const TextStyle(fontSize: 10)),
        ),
      ),
    );
  }
}

class AddAdministrativeVisitController extends GetxController {
  var loading = true.obs;
  var selectedCircle = Rxn<String>();
  var circlesList = <Map<String, dynamic>>[].obs;
  var teacherCriteria = <Map<String, dynamic>>[].obs;
  var studentsCriteria = <Map<String, dynamic>>[].obs;
  var teacherRatings = <RxInt>[].obs;
  var studentsRatings = <RxInt>[].obs;
  var notesController = TextEditingController();
  var dataArg;

  @override
  void onInit() {
    super.onInit();
    dataArg = Get.arguments;
    loadData();
  }

  Future<void> loadData() async {
    loading.value = true;
    try {
      await Future.wait([
        loadCircles(),
        loadTeacherCriteria(),
        loadStudentsCriteria(),
      ]);
    } finally {
      loading.value = false;
    }
  }

  Future<void> loadCircles() async {
    try {
      final response = await postData(Linkapi.select_circle_for_center, {
        "responsible_user_id": dataArg?['id_user']?.toString(),
      });
      
      if (response['stat'] == 'ok') {
        circlesList.assignAll(List<Map<String, dynamic>>.from(response['data']));
        if (circlesList.isNotEmpty) {
          selectedCircle.value = circlesList.first['id_circle'].toString();
        }
      }
    } catch (e) {
      print("Error loading circles: $e");
    }
  }

  Future<void> loadTeacherCriteria() async {
    try {
      final response = await postData(Linkapi.select_teacher_evaluation_criteria, {});
      
      if (response['stat'] == 'ok') {
        teacherCriteria.assignAll(List<Map<String, dynamic>>.from(response['data']));
        teacherRatings.value = List.generate(teacherCriteria.length, (_) => 0.obs);
      }
    } catch (e) {
      print("Error loading teacher criteria: $e");
    }
  }

  Future<void> loadStudentsCriteria() async {
    try {
      final response = await postData(Linkapi.select_students_evaluation_criteria, {});
      
      if (response['stat'] == 'ok') {
        studentsCriteria.assignAll(List<Map<String, dynamic>>.from(response['data']));
        studentsRatings.value = List.generate(studentsCriteria.length, (_) => 0.obs);
      }
    } catch (e) {
      print("Error loading students criteria: $e");
    }
  }

  Future<void> saveVisit() async {
    if (selectedCircle.value == null) {
      mySnackbar("تنبيه", "الرجاء اختيار الحلقة");
      return;
    }

    // التحقق من أن جميع التقييمات تم إدخالها
    if (teacherRatings.any((r) => r.value == 0)) {
      mySnackbar("تنبيه", "الرجاء إكمال جميع تقييمات المدرس");
      return;
    }

    if (studentsRatings.any((r) => r.value == 0)) {
      mySnackbar("تنبيه", "الرجاء إكمال جميع تقييمات الطلاب");
      return;
    }

    loading.value = true;
    try {
      final now = DateTime.now();
      
      // تجهيز تقييمات المدرس
      final teacherEvaluations = teacherCriteria.asMap().entries.map((entry) {
        return {
          "criteria_id": teacherCriteria[entry.key]['id'],
          "rating": teacherRatings[entry.key].value,
          "notes": ""
        };
      }).toList();

      // تجهيز تقييمات الطلاب
      final studentsEvaluations = studentsCriteria.asMap().entries.map((entry) {
        return {
          "criteria_id": studentsCriteria[entry.key]['id'],
          "rating": studentsRatings[entry.key].value,
          "notes": ""
        };
      }).toList();

      final response = await postData(Linkapi.add_administrative_visit, {
        "id_circle": selectedCircle.value,
        "id_visit_type": "2", // نوع الزيارة الإدارية (تأكد من الرقم الصحيح)
        "id_user": dataArg?['id_user']?.toString(),
        "id_year": now.year.toString(),
        "id_month": now.month.toString(),
        "notes": notesController.text,
        "teacher_evaluations": teacherEvaluations,
        "students_evaluations": studentsEvaluations,
      });

      if (response['stat'] == 'ok') {
        mySnackbar("نجح", "تم حفظ الزيارة الإدارية بنجاح", type: "g");
        Get.back();
      } else {
        mySnackbar("خطأ", response['msg'] ?? "فشل في حفظ الزيارة");
      }
    } catch (e) {
      print("Error saving visit: $e");
      mySnackbar("خطأ", "حدث خطأ: $e");
    } finally {
      loading.value = false;
    }
  }

  @override
  void onClose() {
    notesController.dispose();
    super.onClose();
  }
}
