import 'package:althfeth/api/LinkApi.dart';
import 'package:althfeth/api/apiFunction.dart';
import 'package:althfeth/constants/function.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ComprehensiveStudentPerformance extends StatelessWidget {
  final ComprehensiveStudentPerformanceController controller = 
      Get.put(ComprehensiveStudentPerformanceController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("تقرير أداء الطالب الشامل"),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () => controller.exportToPDF(),
          ),
        ],
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
    final studentInfo = Map<String, dynamic>.from(data['student_info'] ?? {});
    final recitationStats = Map<String, dynamic>.from(data['recitation_stats'] ?? {});
    final reviewStats = Map<String, dynamic>.from(data['review_stats'] ?? {});
    final attendanceStats = Map<String, dynamic>.from(data['attendance_stats'] ?? {});
    
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

  // دالة مساعدة لحساب نسبة الحضور في PDF

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
    var res = await handleRequest(
      isLoading: RxBool(false),
      useDialog: true,
      immediateLoading: true,
      loadingMessage: "تحميل الحلقات...",
      action: () async {
        return await postData(Linkapi.select_circle_for_center, {
          "responsible_user_id": dataArg?['id_user']?.toString(),
        });
      }
    );

    if (res == null) {
      return;
    }

    if (res is! Map) {
      mySnackbar("خطأ", "فشل الاتصال بالخادم");
      return;
    }
    
    if (res["stat"] == "ok") {
      circlesList.assignAll(List<Map<String, dynamic>>.from(res['data']));
      if (circlesList.isNotEmpty) {
        selectedCircle.value = circlesList.first['id_circle'].toString();
        loadStudentsByCircle();
      }
    } else if (res["stat"] == "no") {
      mySnackbar("تنبيه", "لا يوجد لديك حلقات");
    } else {
      mySnackbar("خطأ", res["msg"] ?? "حصل خطأ أثناء جلب البيانات");
    }
  }

  Future<void> loadStudentsByCircle() async {
    if (selectedCircle.value == null) return;
    
    var res = await handleRequest(
      isLoading: RxBool(false),
      useDialog: true,
      immediateLoading: true,
      loadingMessage: "تحميل الطلاب...",
      action: () async {
        return await postData(Linkapi.select_students, {
          "id_circle": selectedCircle.value,
        });
      }
    );

    if (res == null) {
      return;
    }

    if (res is! Map) {
      mySnackbar("خطأ", "فشل الاتصال بالخادم");
      return;
    }
    
    if (res["stat"] == "ok") {
      studentsList.assignAll(List<Map<String, dynamic>>.from(res['data']));
      if (studentsList.isNotEmpty) {
        selectedStudent.value = studentsList.first['id_student'].toString();
      }
    } else if (res["stat"] == "no") {
      mySnackbar("تنبيه", "لا يوجد طلاب في هذه الحلقة");
    } else {
      mySnackbar("خطأ", res["msg"] ?? "حصل خطأ أثناء جلب البيانات");
    }
  }

  Future<void> selectStartDate(BuildContext context) async {
    final now = DateTime.now();
    final defaultInitial = now.subtract(const Duration(days: 30));
    final initial = startDate.value ?? defaultInitial;
    
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isAfter(now) ? now : initial,
      firstDate: DateTime(2020),
      lastDate: now,
    );
    if (picked != null) {
      startDate.value = picked;
      
      if (endDate.value != null && endDate.value!.isBefore(picked)) {
        endDate.value = null;
      }
    }
  }
  
  Future<void> selectEndDate(BuildContext context) async {
    if (startDate.value == null) {
      mySnackbar("تنبيه", "الرجاء اختيار تاريخ البداية أولاً");
      return;
    }
    
    final now = DateTime.now();
    final firstDate = startDate.value!;
    
    DateTime initialDate;
    if (endDate.value != null && !endDate.value!.isBefore(firstDate) && !endDate.value!.isAfter(now)) {
      initialDate = endDate.value!;
    } else if (firstDate.isAfter(now)) {
      initialDate = now;
    } else {
      initialDate = firstDate;
    }
    
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: now,
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
    
    if (startDate.value!.isAfter(endDate.value!)) {
      mySnackbar("خطأ", "تاريخ البداية يجب أن يكون أصغر من تاريخ النهاية");
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

    Map<String, dynamic> requestData = {
      "start_date": DateFormat('yyyy-MM-dd').format(startDate.value!),
      "end_date": DateFormat('yyyy-MM-dd').format(endDate.value!),
    };
    
    if (!showAllStudents.value) {
      requestData["id_student"] = selectedStudent.value;
    } else {
      requestData["id_circle"] = selectedCircle.value;
    }

    var res = await handleRequest(
      isLoading: loading,
      useDialog: true,
      immediateLoading: true,
      loadingMessage: "جاري تحميل بيانات الأداء الشامل...",
      action: () async {
        return await postData(Linkapi.select_comprehensive_student_performance, requestData);
      }
    );
    
    if (res == null) {
      performanceData.clear();
      return;
    }
    
    if (res is! Map) {
      mySnackbar("خطأ", "فشل الاتصال بالخادم");
      performanceData.clear();
      return;
    }
    
    if (res["stat"] == "ok") {
      if (res['data'] != null) {
        performanceData.assignAll(Map<String, dynamic>.from(res['data']));
        mySnackbar("نجح", "تم تحميل البيانات", type: "g");
      } else {
        performanceData.clear();
        mySnackbar("تنبيه", "لا توجد بيانات");
      }
    } else if (res["stat"] == "no") {
      performanceData.clear();
      mySnackbar("تنبيه", "لا توجد بيانات لهذه الفترة");
    } else {
      performanceData.clear();
      mySnackbar("خطأ", res["msg"] ?? "حدث خطأ أثناء جلب البيانات");
    }
  }
  String _calculateAttendanceRateForPDF(Map<String, dynamic> stats) {
    final present = int.tryParse(stats['present_count']?.toString() ?? '0') ?? 0;
    final total = int.tryParse(stats['total_days']?.toString() ?? '0') ?? 0;
    if (total == 0) return '0';
    return (present / total * 100).toStringAsFixed(0);
  }

  Future<void> exportToPDF() async {
    if (performanceData.isEmpty) {
      mySnackbar("تنبيه", "لا توجد بيانات للتصدير");
      return;
    }

    try {
      final pdf = pw.Document();
      final fontData = await rootBundle.load('assets/fonts/Amiri-Bold.ttf');
      final arabicFont = pw.Font.ttf(fontData);
      
      // تحميل الشعار
      final logoData = await rootBundle.load('assets/icon/app_icon.png');
      final logoImage = pw.MemoryImage(logoData.buffer.asUint8List());

      final dateStr = startDate.value != null && endDate.value != null
          ? 'من ${DateFormat('yyyy-MM-dd').format(startDate.value!)} إلى ${DateFormat('yyyy-MM-dd').format(endDate.value!)}'
          : '';

      if (!showAllStudents.value) {
        // PDF لطالب واحد
        final studentInfo = Map<String, dynamic>.from(performanceData['student_info'] ?? {});
        final recitationStats = Map<String, dynamic>.from(performanceData['recitation_stats'] ?? {});
        final reviewStats = Map<String, dynamic>.from(performanceData['review_stats'] ?? {});
        final attendanceStats = Map<String, dynamic>.from(performanceData['attendance_stats'] ?? {});

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
                          pw.Container(
                            width: 45,
                            height: 45,
                            child: pw.Image(logoImage),
                          ),
                          pw.SizedBox(width: 8),
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
                              'تقرير أداء الطالب الشامل',
                              style: pw.TextStyle(
                                fontSize: 16,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.SizedBox(height: 4),
                            pw.Text(
                              'الفترة: $dateStr',
                              style: const pw.TextStyle(fontSize: 11),
                            ),
                            pw.SizedBox(height: 2),
                            pw.Text(
                              'الطالب: ${studentInfo['name_student'] ?? '-'}',
                              style: const pw.TextStyle(fontSize: 9),
                            ),
                            pw.Text(
                              'الحلقة: ${studentInfo['name_circle'] ?? '-'}',
                              style: const pw.TextStyle(fontSize: 9),
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

                // جدول الإحصائيات
                pw.Directionality(
                  textDirection: pw.TextDirection.rtl,
                  child: pw.Table.fromTextArray(
                    headers: ['النوع', 'العدد', 'المتوسط', 'الأعلى', 'الأقل'],
                    data: [
                      [
                        'التسميع',
                        '${recitationStats['total_recitations'] ?? 0}',
                        '${double.tryParse(recitationStats['avg_mark']?.toString() ?? '0')?.toStringAsFixed(1) ?? '0.0'}',
                        '${recitationStats['max_mark'] ?? 0}',
                        '${recitationStats['min_mark'] ?? 0}',
                      ],
                      [
                        'المراجعة',
                        '${reviewStats['total_reviews'] ?? 0}',
                        '${double.tryParse(reviewStats['avg_mark']?.toString() ?? '0')?.toStringAsFixed(1) ?? '0.0'}',
                        '${reviewStats['max_mark'] ?? 0}',
                        '${reviewStats['min_mark'] ?? 0}',
                      ],
                      [
                        'الحضور',
                        '${attendanceStats['total_days'] ?? 0}',
                        '${_calculateAttendanceRateForPDF(attendanceStats)}%',
                        '-',
                        '-',
                      ],
                    ],
                    border: pw.TableBorder.all(width: 0.5, color: PdfColors.indigo300),
                    headerStyle: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                    headerDecoration: const pw.BoxDecoration(
                      color: PdfColors.indigo,
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
      } else {
        // PDF لجميع الطلاب
        final studentsData = performanceData['students'] as List<dynamic>? ?? [];
        final circleName = circlesList.firstWhere(
          (circle) => circle['id_circle'].toString() == selectedCircle.value.toString(), 
          orElse: () => {'name_circle': 'غير محدد'}
        )['name_circle'];

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
                          pw.Container(
                            width: 45,
                            height: 45,
                            child: pw.Image(logoImage),
                          ),
                          pw.SizedBox(width: 8),
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
                              'تقرير أداء الطلاب الشامل',
                              style: pw.TextStyle(
                                fontSize: 16,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.SizedBox(height: 4),
                            pw.Text(
                              'الفترة: $dateStr',
                              style: const pw.TextStyle(fontSize: 11),
                            ),
                            pw.SizedBox(height: 2),
                            pw.Text(
                              'الحلقة: $circleName | إجمالي: ${studentsData.length}',
                              style: const pw.TextStyle(fontSize: 9),
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

                // جدول الطلاب
                pw.Directionality(
                  textDirection: pw.TextDirection.rtl,
                  child: pw.Table.fromTextArray(
                    headers: ['الحضور%', 'المراجعة', 'التسميع', 'الحلقة', 'اسم الطالب', '#'],
                    data: studentsData.asMap().entries.map((entry) {
                      final index = entry.key + 1;
                      final student = entry.value;
                      
                      final presentCount = int.tryParse(student['present_count']?.toString() ?? '0') ?? 0;
                      final absentCount = int.tryParse(student['absent_count']?.toString() ?? '0') ?? 0;
                      final totalDays = presentCount + absentCount;
                      final attendanceRate = totalDays > 0 ? (presentCount / totalDays * 100).toStringAsFixed(0) : '0';
                      
                      return [
                        '$attendanceRate%',
                        '${double.tryParse(student['avg_review_mark']?.toString() ?? '0')?.toStringAsFixed(1) ?? '0.0'}',
                        '${double.tryParse(student['avg_recitation_mark']?.toString() ?? '0')?.toStringAsFixed(1) ?? '0.0'}',
                        student['name_circle'] ?? circleName,
                        student['name_student'] ?? '-',
                        index.toString(),
                      ];
                    }).toList(),
                    border: pw.TableBorder.all(width: 0.5, color: PdfColors.indigo300),
                    headerStyle: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                    headerDecoration: const pw.BoxDecoration(
                      color: PdfColors.indigo,
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
      }

      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
        name: 'تقرير_أداء_الطالب_الشامل_$dateStr.pdf',
      );
    } catch (e) {
      print("Error generating PDF: $e");
      mySnackbar("خطأ", "حدث خطأ أثناء إنشاء التقرير");
    }
  }
}
