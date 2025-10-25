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

class ComprehensiveCircleReport extends StatelessWidget {
  final ComprehensiveCircleReportController controller = Get.put(ComprehensiveCircleReportController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("تقرير شامل للحلقة"),
        backgroundColor: Colors.deepPurple,
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
            color: Colors.deepPurple.shade50,
            child: Column(
              children: [
                // اختيار الحلقة
                Obx(() => DropdownButtonFormField<String>(
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
                  },
                )),
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
                    backgroundColor: Colors.deepPurple,
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

              if (controller.reportData.isEmpty) {
                return const Center(child: Text("لا توجد بيانات"));
              }

              final circleInfo = Map<String, dynamic>.from(controller.reportData['circle_info'] ?? {});
              final students = controller.reportData['students'] ?? [];

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // معلومات الحلقة
                    Card(
                      color: Colors.deepPurple.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              circleInfo['name_circle'] ?? '',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('الأستاذ: ${circleInfo['teacher_name'] ?? ''}'),
                            Text('المركز: ${circleInfo['center_name'] ?? ''}'),
                            Text('عدد الطلاب: ${students.length}'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // قائمة الطلاب
                    const Text(
                      'قائمة الطلاب',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...students.map((student) => _buildStudentCard(student)).toList(),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student) {
    final totalRecitations = int.tryParse(student['total_recitations'].toString()) ?? 0;
    final avgRecitationMark = double.tryParse(student['avg_recitation_mark'].toString()) ?? 0;
    final totalReviews = int.tryParse(student['total_reviews'].toString()) ?? 0;
    final avgReviewMark = double.tryParse(student['avg_review_mark'].toString()) ?? 0;
    final presentCount = int.tryParse(student['present_count'].toString()) ?? 0;
    final absentCount = int.tryParse(student['absent_count'].toString()) ?? 0;
    final totalAttendance = presentCount + absentCount;
    final attendanceRate = totalAttendance > 0 ? (presentCount / totalAttendance * 100) : 0.0;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Colors.deepPurple,
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
                    _buildStatItem('التسميع', totalRecitations.toString(), Colors.purple),
                    _buildStatItem('م.تسميع', avgRecitationMark.toStringAsFixed(1), Colors.purple),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('المراجعة', totalReviews.toString(), Colors.orange),
                    _buildStatItem('م.مراجعة', avgReviewMark.toStringAsFixed(1), Colors.orange),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('الحضور', presentCount.toString(), Colors.green),
                    _buildStatItem('الغياب', absentCount.toString(), Colors.red),
                    _buildStatItem('النسبة', '${attendanceRate.toStringAsFixed(0)}%', Colors.teal),
                  ],
                ),
              ],
            ),
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
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}

class ComprehensiveCircleReportController extends GetxController {
  var startDate = Rxn<DateTime>();
  var endDate = Rxn<DateTime>();
  var selectedCircle = Rxn<String>();
  var reportData = <String, dynamic>{}.obs;
  var circlesList = <Map<String, dynamic>>[].obs;
  var loading = false.obs;
  var dataArg;

  @override
  void onInit() {
    super.onInit();
    dataArg = Get.arguments;
    endDate.value = DateTime.now();
    startDate.value = DateTime.now().subtract(const Duration(days: 30));
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
        }
      }
    } catch (e) {
      print("Error loading circles: $e");
    }
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
    if (selectedCircle.value == null) {
      mySnackbar("تنبيه", "الرجاء اختيار الحلقة");
      return;
    }
    
    if (startDate.value == null || endDate.value == null) {
      mySnackbar("تنبيه", "الرجاء اختيار الفترة الزمنية");
      return;
    }

    loading.value = true;
    try {
      final response = await postData(Linkapi.select_comprehensive_circle_report, {
        "id_circle": selectedCircle.value,
        "start_date": DateFormat('yyyy-MM-dd').format(startDate.value!),
        "end_date": DateFormat('yyyy-MM-dd').format(endDate.value!),
      });

      if (response == null || response is! Map) {
        mySnackbar("خطأ", "فشل الاتصال بالخادم");
        reportData.clear();
        return;
      }
      
      if (response['stat'] == 'ok') {
        reportData.assignAll(Map<String, dynamic>.from(response['data']));
        mySnackbar("نجح", "تم تحميل البيانات", type: "g");
      } else {
        reportData.clear();
        mySnackbar("خطأ", response['msg'] ?? "حدث خطأ");
      }
    } catch (e) {
      print("Error: $e");
      mySnackbar("خطأ", "حدث خطأ: $e");
      reportData.clear();
    } finally {
      loading.value = false;
    }
  }
  
  Future<void> exportToPDF() async {
    if (reportData.isEmpty) {
      mySnackbar("تنبيه", "لا توجد بيانات للتصدير");
      return;
    }

    try {
      final pdf = pw.Document();
      final fontData = await rootBundle.load('assets/fonts/Amiri-Bold.ttf');
      final arabicFont = pw.Font.ttf(fontData);
      
      final circleInfo = Map<String, dynamic>.from(reportData['circle_info'] ?? {});
      final students = reportData['students'] ?? [];

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          textDirection: pw.TextDirection.rtl,
          theme: pw.ThemeData.withFont(base: arabicFont, bold: arabicFont),
          build: (context) {
            return [
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                color: PdfColor.fromHex('#673AB7'),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'تقرير شامل للحلقة',
                      style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                    ),
                    pw.Text(
                      '${circleInfo['name_circle']} - ${circleInfo['teacher_name']}',
                      style: const pw.TextStyle(fontSize: 10, color: PdfColors.white),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2),
                  1: const pw.FlexColumnWidth(1),
                  2: const pw.FlexColumnWidth(1),
                  3: const pw.FlexColumnWidth(1),
                  4: const pw.FlexColumnWidth(1),
                  5: const pw.FlexColumnWidth(1),
                },
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColor.fromHex('#D1C4E9')),
                    children: [
                      _buildCell('الطالب', isHeader: true),
                      _buildCell('التسميع', isHeader: true),
                      _buildCell('م.تسميع', isHeader: true),
                      _buildCell('المراجعة', isHeader: true),
                      _buildCell('م.مراجعة', isHeader: true),
                      _buildCell('الحضور%', isHeader: true),
                    ],
                  ),
                  ...students.map((s) {
                    final present = int.tryParse(s['present_count'].toString()) ?? 0;
                    final absent = int.tryParse(s['absent_count'].toString()) ?? 0;
                    final total = present + absent;
                    final rate = total > 0 ? (present / total * 100) : 0.0;
                    
                    return pw.TableRow(
                      children: [
                        _buildCell(s['name_student'] ?? '-'),
                        _buildCell(s['total_recitations']?.toString() ?? '0'),
                        _buildCell((double.tryParse(s['avg_recitation_mark']?.toString() ?? '0') ?? 0).toStringAsFixed(1)),
                        _buildCell(s['total_reviews']?.toString() ?? '0'),
                        _buildCell((double.tryParse(s['avg_review_mark']?.toString() ?? '0') ?? 0).toStringAsFixed(1)),
                        _buildCell('${rate.toStringAsFixed(0)}%'),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ];
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
        name: 'تقرير_شامل_للحلقة.pdf',
      );

      mySnackbar("نجح", "تم إنشاء التقرير بنجاح", type: "g");
    } catch (e) {
      print("PDF Error: $e");
      mySnackbar("خطأ", "حدث خطأ أثناء إنشاء التقرير: $e");
    }
  }

  pw.Widget _buildCell(String text, {bool isHeader = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 9 : 8,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? PdfColor.fromHex('#673AB7') : PdfColors.black,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }
}
