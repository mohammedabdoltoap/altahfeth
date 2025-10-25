import 'package:althfeth/api/LinkApi.dart';
import 'package:althfeth/api/apiFunction.dart';
import 'package:althfeth/constants/function.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ComprehensiveStudentPerformance extends StatelessWidget {
  final ComprehensiveStudentPerformanceController controller = 
      Get.put(ComprehensiveStudentPerformanceController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("تقرير أداء الطالب الشامل"),
        backgroundColor: Colors.indigo,
      ),
      body: Column(
        children: [
          // Filters
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.indigo.shade50,
            child: Column(
              children: [
                // اختيار نوع التقرير
                Obx(() => Row(
                  children: [
                    Expanded(
                      child: RadioListTile<bool>(
                        title: const Text("طالب محدد"),
                        value: false,
                        groupValue: controller.showAllStudents.value,
                        onChanged: (val) => controller.showAllStudents.value = val!,
                        dense: true,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<bool>(
                        title: const Text("جميع الطلاب"),
                        value: true,
                        groupValue: controller.showAllStudents.value,
                        onChanged: (val) => controller.showAllStudents.value = val!,
                        dense: true,
                      ),
                    ),
                  ],
                )),
                const SizedBox(height: 8),
                
                // اختيار الطالب أو الحلقة
                Obx(() {
                  if (!controller.showAllStudents.value) {
                    // اختيار طالب محدد
                    return DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: "الطالب",
                        border: OutlineInputBorder(),
                      ),
                      value: controller.selectedStudent.value,
                      items: controller.studentsList.map((student) {
                        return DropdownMenuItem(
                          value: student['id_student'].toString(),
                          child: Text(student['name_student'] ?? ''),
                        );
                      }).toList(),
                      onChanged: (val) {
                        controller.selectedStudent.value = val;
                      },
                    );
                  } else {
                    // اختيار حلقة
                    return DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: "الحلقة",
                        border: OutlineInputBorder(),
                      ),
                      value: controller.selectedCircle.value,
                      items: controller.circlesList.map((circle) {
                        return DropdownMenuItem(
                          value: circle['id_circle'].toString(),
                          child: Text(circle['name_circle'] ?? ''),
                        );
                      }).toList(),
                      onChanged: (val) {
                        controller.selectedCircle.value = val;
                        controller.loadStudentsByCircle();
                      },
                    );
                  }
                }),
                const SizedBox(height: 8),
                
                // اختيار الفترة
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.calendar_today, size: 18),
                        label: Obx(() => Text(
                          controller.startDate.value != null
                              ? DateFormat('yyyy-MM-dd').format(controller.startDate.value!)
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
                              ? DateFormat('yyyy-MM-dd').format(controller.endDate.value!)
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
                    backgroundColor: Colors.indigo,
                    minimumSize: const Size(double.infinity, 45),
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: Obx(() {
              if (controller.loading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.performanceData.isEmpty) {
                return const Center(
                  child: Text("لا توجد بيانات"),
                );
              }

              // عرض حسب النوع
              if (!controller.showAllStudents.value) {
                return _buildSingleStudentView();
              } else {
                return _buildAllStudentsView();
              }
            }),
          ),
        ],
      ),
    );
  }

  // عرض تقرير طالب واحد
  Widget _buildSingleStudentView() {
    final data = controller.performanceData;
    final studentInfo = data['student_info'] ?? {};
    final recitationStats = data['recitation_stats'] ?? {};
    final reviewStats = data['review_stats'] ?? {};
    final attendanceStats = data['attendance_stats'] ?? {};
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // معلومات الطالب
          Card(
            color: Colors.indigo.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.indigo,
                        radius: 30,
                        child: Text(
                          studentInfo['name_student']?.toString()[0] ?? 'ط',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              studentInfo['name_student'] ?? '',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'الحلقة: ${studentInfo['name_circle'] ?? ''}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // إحصائيات التسميع
          _buildStatCard(
            "التسميع اليومي",
            Icons.book,
            Colors.purple,
            [
              _buildStatRow("عدد التسميعات", recitationStats['total_recitations']?.toString() ?? '0'),
              _buildStatRow("متوسط الدرجات", (double.tryParse(recitationStats['avg_mark']?.toString() ?? '0') ?? 0).toStringAsFixed(1)),
              _buildStatRow("أعلى درجة", recitationStats['max_mark']?.toString() ?? '0'),
              _buildStatRow("أقل درجة", recitationStats['min_mark']?.toString() ?? '0'),
            ],
          ),
          const SizedBox(height: 12),
          
          // إحصائيات المراجعة
          _buildStatCard(
            "المراجعة",
            Icons.replay,
            Colors.orange,
            [
              _buildStatRow("عدد المراجعات", reviewStats['total_reviews']?.toString() ?? '0'),
              _buildStatRow("متوسط الدرجات", (double.tryParse(reviewStats['avg_mark']?.toString() ?? '0') ?? 0).toStringAsFixed(1)),
              _buildStatRow("أعلى درجة", reviewStats['max_mark']?.toString() ?? '0'),
              _buildStatRow("أقل درجة", reviewStats['min_mark']?.toString() ?? '0'),
            ],
          ),
          const SizedBox(height: 12),
          
          // إحصائيات الحضور
          _buildStatCard(
            "الحضور والغياب",
            Icons.calendar_today,
            Colors.teal,
            [
              _buildStatRow("إجمالي الأيام", attendanceStats['total_days']?.toString() ?? '0'),
              _buildStatRow("أيام الحضور", attendanceStats['present_count']?.toString() ?? '0', Colors.green),
              _buildStatRow("أيام الغياب", attendanceStats['absent_count']?.toString() ?? '0', Colors.red),
              _buildStatRow(
                "نسبة الحضور",
                _calculateAttendanceRate(attendanceStats),
                Colors.blue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // عرض تقرير جميع الطلاب
  Widget _buildAllStudentsView() {
    final students = controller.performanceData['students'] ?? [];
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        final totalRecitations = int.tryParse(student['total_recitations']?.toString() ?? '0') ?? 0;
        final avgRecitationMark = double.tryParse(student['avg_recitation_mark']?.toString() ?? '0') ?? 0;
        final totalReviews = int.tryParse(student['total_reviews']?.toString() ?? '0') ?? 0;
        final avgReviewMark = double.tryParse(student['avg_review_mark']?.toString() ?? '0') ?? 0;
        final presentCount = int.tryParse(student['present_count']?.toString() ?? '0') ?? 0;
        final absentCount = int.tryParse(student['absent_count']?.toString() ?? '0') ?? 0;
        final totalDays = presentCount + absentCount;
        final attendanceRate = totalDays > 0 ? (presentCount / totalDays * 100) : 0.0;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 3,
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: Colors.indigo,
              child: Text(
                student['name_student']?.toString()[0] ?? 'ط',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(
              student['name_student'] ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMiniStat("التسميع", totalRecitations.toString(), Colors.purple),
                        _buildMiniStat("المراجعة", totalReviews.toString(), Colors.orange),
                        _buildMiniStat("الحضور", "${attendanceRate.toStringAsFixed(0)}%", Colors.teal),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMiniStat("متوسط التسميع", avgRecitationMark.toStringAsFixed(1), Colors.purple),
                        _buildMiniStat("متوسط المراجعة", avgReviewMark.toStringAsFixed(1), Colors.orange),
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
  }

  Widget _buildStatCard(String title, IconData icon, Color color, List<Widget> children) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, [Color? valueColor]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  String _calculateAttendanceRate(Map<String, dynamic> stats) {
    final present = int.tryParse(stats['present_count']?.toString() ?? '0') ?? 0;
    final total = int.tryParse(stats['total_days']?.toString() ?? '0') ?? 0;
    if (total == 0) return '0%';
    return '${(present / total * 100).toStringAsFixed(0)}%';
  }
}

class ComprehensiveStudentPerformanceController extends GetxController {
  var startDate = Rxn<DateTime>();
  var endDate = Rxn<DateTime>();
  var selectedStudent = Rxn<String>();
  var selectedCircle = Rxn<String>();
  var showAllStudents = false.obs;
  var performanceData = <String, dynamic>{}.obs;
  var studentsList = <Map<String, dynamic>>[].obs;
  var circlesList = <Map<String, dynamic>>[].obs;
  var loading = false.obs;
  var dataArg;

  @override
  void onInit() {
    super.onInit();
    dataArg = Get.arguments;
    loadCircles();
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
          loadStudentsByCircle();
        }
      }
    } catch (e) {
      print("Error loading circles: $e");
    }
  }

  Future<void> loadStudentsByCircle() async {
    if (selectedCircle.value == null) return;
    
    try {
      final response = await postData(Linkapi.select_students, {
        "id_circle": selectedCircle.value,
      });
      
      if (response['stat'] == 'ok') {
        studentsList.assignAll(List<Map<String, dynamic>>.from(response['data']));
        if (studentsList.isNotEmpty) {
          selectedStudent.value = studentsList.first['id_student'].toString();
        }
      }
    } catch (e) {
      print("Error loading students: $e");
    }
  }

  Future<void> selectStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate.value ?? DateTime.now().subtract(const Duration(days: 30)),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      startDate.value = picked;
    }
  }
  
  Future<void> selectEndDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: endDate.value ?? DateTime.now(),
      firstDate: startDate.value ?? DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      endDate.value = picked;
    }
  }

  Future<void> loadData() async {
    if (startDate.value == null || endDate.value == null) {
      mySnackbar("تنبيه", "الرجاء اختيار الفترة الزمنية");
      return;
    }
    
    if (!showAllStudents.value && selectedStudent.value == null) {
      mySnackbar("تنبيه", "الرجاء اختيار الطالب");
      return;
    }
    
    if (showAllStudents.value && selectedCircle.value == null) {
      mySnackbar("تنبيه", "الرجاء اختيار الحلقة");
      return;
    }

    loading.value = true;
    try {
      Map<String, dynamic> requestData = {
        "start_date": DateFormat('yyyy-MM-dd').format(startDate.value!),
        "end_date": DateFormat('yyyy-MM-dd').format(endDate.value!),
      };
      
      if (!showAllStudents.value) {
        requestData["id_student"] = selectedStudent.value;
      } else {
        requestData["id_circle"] = selectedCircle.value;
      }
      
      final response = await postData(
        Linkapi.select_comprehensive_student_performance,
        requestData,
      );

      if (response == null) {
        mySnackbar("خطأ", "فشل الاتصال بالخادم");
        performanceData.clear();
        return;
      }

      if (response is! Map) {
        mySnackbar("خطأ", "استجابة غير صحيحة من الخادم");
        performanceData.clear();
        return;
      }
      
      if (response['stat'] == 'ok') {
        if (response['data'] != null) {
          performanceData.assignAll(Map<String, dynamic>.from(response['data']));
          mySnackbar("نجح", "تم تحميل البيانات", type: "g");
        } else {
          performanceData.clear();
          mySnackbar("تنبيه", "لا توجد بيانات");
        }
      } else if (response['stat'] == 'no') {
        performanceData.clear();
        mySnackbar("تنبيه", "لا توجد بيانات لهذه الفترة");
      } else {
        performanceData.clear();
        mySnackbar("خطأ", response['msg'] ?? "حدث خطأ");
      }
    } catch (e) {
      print("Error: $e");
      mySnackbar("خطأ", "حدث خطأ: $e");
      performanceData.clear();
    } finally {
      loading.value = false;
    }
  }
}
