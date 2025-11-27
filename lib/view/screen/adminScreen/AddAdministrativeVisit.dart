import 'package:althfeth/api/LinkApi.dart';
import 'package:althfeth/api/apiFunction.dart';
import 'package:althfeth/constants/function.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddAdministrativeVisit extends StatelessWidget {
  final AddAdministrativeVisitController controller = Get.put(AddAdministrativeVisitController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("زيارة إدارية", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo,
        elevation: 0,
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.loading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.indigo),
                const SizedBox(height: 16),
                const Text("جاري التحميل...", style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Header مع معلومات الحلقة
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.indigo, Colors.indigo.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(Icons.school_rounded, size: 50, color: Colors.white.withOpacity(0.9)),
                  const SizedBox(height: 12),
                  Text(
                    controller.circleName.value,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "تقييم شامل للحلقة",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),

            // المحتوى
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // تقييم المدرس
                    _buildSectionCard(
                      title: "تقييم المعلم",
                      icon: Icons.person_rounded,
                      color: Colors.purple,
                      child: Column(
                        children: controller.teacherCriteria.asMap().entries.map((entry) {
                          return _buildModernEvaluationItem(
                            entry.value['criteria_name'] ?? '',
                            entry.key + 1,
                            controller.teacherRatings[entry.key],
                            (rating) => controller.teacherRatings[entry.key].value = rating,
                            Colors.purple,
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // تقييم الطلاب
                    _buildSectionCard(
                      title: "تقييم الطلاب",
                      icon: Icons.groups_rounded,
                      color: Colors.blue,
                      child: Column(
                        children: controller.studentsCriteria.asMap().entries.map((entry) {
                          return _buildModernEvaluationItem(
                            entry.value['criteria_name'] ?? '',
                            entry.key + 1,
                            controller.studentsRatings[entry.key],
                            (rating) => controller.studentsRatings[entry.key].value = rating,
                            Colors.blue,
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ملاحظات
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade50,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(Icons.note_alt_rounded, color: Colors.orange, size: 24),
                                ),
                                const SizedBox(width: 12),
                                const Text("ملاحظات عامة", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: controller.notesController,
                              maxLines: 4,
                              decoration: InputDecoration(
                                hintText: "أضف ملاحظاتك هنا...",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.orange, width: 2),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // زر الحفظ
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.indigo, Colors.indigo.shade700],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.indigo.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () => controller.saveVisit(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.check_circle_rounded, size: 28),
                            SizedBox(width: 12),
                            Text("حفظ التقييم", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required Color color, required Widget child}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 12),
                Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildModernEvaluationItem(String title, int number, RxInt rating, Function(int) onChanged, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    number.toString(),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, height: 1.3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() => Row(
            children: [
              _buildModernRatingChip('ممتاز', 5, rating.value, onChanged, color, Icons.star_rounded),
              _buildModernRatingChip('جيد جدا', 4, rating.value, onChanged, color, Icons.thumb_up_rounded),
              _buildModernRatingChip('جيد', 3, rating.value, onChanged, color, Icons.check_circle_rounded),
              _buildModernRatingChip('مقبول', 2, rating.value, onChanged, color, Icons.remove_circle_outline_rounded),
              _buildModernRatingChip('ضعيف', 1, rating.value, onChanged, color, Icons.close_rounded),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildModernRatingChip(String label, int value, int currentValue, Function(int) onChanged, Color color, IconData icon) {
    final isSelected = currentValue == value;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: InkWell(
          onTap: () => onChanged(value),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? color : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? color : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected ? [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ] : [],
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AddAdministrativeVisitController extends GetxController {
  var loading = true.obs;
  var selectedCircle = Rxn<String>();
  var circleName = ''.obs;
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
    // استخدام الحلقة المُمررة
    selectedCircle.value = dataArg?['id_circle']?.toString();
    loadData();
  }

  Future<void> loadData() async {
    loading.value = true;
    try {
      await Future.wait([
        loadCircleName(),
        loadTeacherCriteria(),
        loadStudentsCriteria(),
      ]);
    } finally {
      loading.value = false;
    }
  }

  Future<void> loadCircleName() async {
    try {
      print("dataArg=====${dataArg}");
      final response = await postData(Linkapi.select_circle_for_center, {
        "responsible_user_id": dataArg['id_user'],
      });
      print("response===${response}");
      if (response['stat'] == 'ok') {
        circlesList.assignAll(List<Map<String, dynamic>>.from(response['data']));
        // البحث عن اسم الحلقة المختارة
        final circle = circlesList.firstWhere(
          (c) => c['id_circle'].toString() == selectedCircle.value,
          orElse: () => {'name_circle': 'غير محدد'},
        );
        circleName.value = circle['name_circle'] ?? 'غير محدد';
      }
    } catch (e) {
      print("Error loading circle name: $e");
      circleName.value = 'خطأ في التحميل';
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
        "id_visit_type": "2", // نوع الزيارة الإدارية
        "id_user": dataArg?['id_user']?.toString(),
        "id_year": dataArg?['id_year']?.toString(),
        "id_month": dataArg?['id_month']?.toString(),
        "notes": notesController.text,
        "teacher_evaluations": teacherEvaluations,
        "students_evaluations": studentsEvaluations,
      });

      if (response['stat'] == 'ok') {
        // إظهار رسالة نجاح
        Get.back(); // العودة للصفحة السابقة
        mySnackbar("نجح", "تم حفظ الزيارة الإدارية بنجاح ✓", type: "g");
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
