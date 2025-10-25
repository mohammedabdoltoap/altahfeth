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

class CircleStatisticsReport extends StatelessWidget {
  final CircleStatisticsReportController controller = Get.put(CircleStatisticsReportController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("إحصائيات الحلقات"),
        backgroundColor: Colors.pink,
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
            color: Colors.pink.shade50,
            child: Column(
              children: [
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
                    backgroundColor: Colors.pink,
                    minimumSize: const Size(double.infinity, 45),
                  ),
                ),
              ],
            ),
          ),
          
          // Statistics Summary
          Obx(() {
            if (controller.circlesList.isEmpty) return const SizedBox.shrink();
            
            final totalStudents = controller.circlesList.fold(0, (sum, c) => 
              sum + (int.tryParse(c['total_students'].toString()) ?? 0));
            final totalCircles = controller.circlesList.length;
            
            return Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey.shade100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatCard("عدد الحلقات", totalCircles.toString(), Colors.pink),
                  _buildStatCard("إجمالي الطلاب", totalStudents.toString(), Colors.blue),
                ],
              ),
            );
          }),
          
          // Circles List
          Expanded(
            child: Obx(() {
              if (controller.loading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.circlesList.isEmpty) {
                return const Center(
                  child: Text("لا توجد بيانات"),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.circlesList.length,
                itemBuilder: (context, index) {
                  final circle = controller.circlesList[index];
                  return _buildCircleCard(circle);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleCard(Map<String, dynamic> circle) {
    final totalStudents = int.tryParse(circle['total_students'].toString()) ?? 0;
    final activeStudents = int.tryParse(circle['active_students'].toString()) ?? 0;
    final totalRecitations = int.tryParse(circle['total_recitations'].toString()) ?? 0;
    final avgRecitationMark = double.tryParse(circle['avg_recitation_mark'].toString()) ?? 0;
    final totalReviews = int.tryParse(circle['total_reviews'].toString()) ?? 0;
    final avgReviewMark = double.tryParse(circle['avg_review_mark'].toString()) ?? 0;
    final presentCount = int.tryParse(circle['present_count'].toString()) ?? 0;
    final absentCount = int.tryParse(circle['absent_count'].toString()) ?? 0;
    final totalAttendance = presentCount + absentCount;
    final attendanceRate = totalAttendance > 0 ? (presentCount / totalAttendance * 100) : 0.0;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Colors.pink,
          child: Text(
            totalStudents.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          circle['name_circle'] ?? '',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الأستاذ: ${circle['teacher_name'] ?? ''}'),
            if (circle['center_name'] != null)
              Text('المركز: ${circle['center_name']}'),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // الطلاب
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('إجمالي الطلاب', totalStudents.toString(), Colors.blue),
                    _buildStatItem('الطلاب النشطين', activeStudents.toString(), Colors.green),
                  ],
                ),
                const Divider(height: 24),
                
                // التسميع
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('التسميع', totalRecitations.toString(), Colors.purple),
                    _buildStatItem('متوسط التسميع', avgRecitationMark.toStringAsFixed(1), Colors.purple),
                  ],
                ),
                const Divider(height: 24),
                
                // المراجعة
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('المراجعة', totalReviews.toString(), Colors.orange),
                    _buildStatItem('متوسط المراجعة', avgReviewMark.toStringAsFixed(1), Colors.orange),
                  ],
                ),
                const Divider(height: 24),
                
                // الحضور
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('الحضور', presentCount.toString(), Colors.green),
                    _buildStatItem('الغياب', absentCount.toString(), Colors.red),
                    _buildStatItem('نسبة الحضور', '${attendanceRate.toStringAsFixed(0)}%', Colors.teal),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
      ],
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
        Text(
          label,
          style: const TextStyle(fontSize: 11),
        ),
      ],
    );
  }
}

class CircleStatisticsReportController extends GetxController {
  var startDate = Rxn<DateTime>();
  var endDate = Rxn<DateTime>();
  var circlesList = <Map<String, dynamic>>[].obs;
  var loading = false.obs;
  var dataArg;

  @override
  void onInit() {
    super.onInit();
    dataArg = Get.arguments;
    // تعيين تواريخ افتراضية (آخر 30 يوم)
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

    loading.value = true;
    try {
      Map<String, dynamic> requestData = {
        "start_date": DateFormat('yyyy-MM-dd').format(startDate.value!),
        "end_date": DateFormat('yyyy-MM-dd').format(endDate.value!),
      };
      
      // إضافة id_center إذا كان موجود
      if (dataArg?['id_center'] != null) {
        requestData["id_center"] = dataArg['id_center'].toString();
      }
      
      final response = await postData(Linkapi.select_circle_statistics, requestData);

      if (response == null) {
        mySnackbar("خطأ", "فشل الاتصال بالخادم");
        circlesList.clear();
        return;
      }

      if (response is! Map) {
        mySnackbar("خطأ", "استجابة غير صحيحة من الخادم");
        circlesList.clear();
        return;
      }
      
      if (response['stat'] == 'ok') {
        if (response['data'] != null && response['data'] is List) {
          circlesList.assignAll(List<Map<String, dynamic>>.from(response['data']));
          mySnackbar("نجح", "تم تحميل ${circlesList.length} حلقة", type: "g");
        } else {
          circlesList.clear();
          mySnackbar("تنبيه", "لا توجد بيانات");
        }
      } else if (response['stat'] == 'no') {
        circlesList.clear();
        mySnackbar("تنبيه", "لا توجد بيانات لهذه الفترة");
      } else {
        circlesList.clear();
        mySnackbar("خطأ", response['msg'] ?? "حدث خطأ");
      }
    } catch (e) {
      print("Error: $e");
      mySnackbar("خطأ", "حدث خطأ: $e");
      circlesList.clear();
    } finally {
      loading.value = false;
    }
  }
  
  Future<void> exportToPDF() async {
    if (circlesList.isEmpty) {
      mySnackbar("تنبيه", "لا توجد بيانات للتصدير");
      return;
    }

    try {
      final pdf = pw.Document();
      final fontData = await rootBundle.load('assets/fonts/Amiri-Bold.ttf');
      final arabicFont = pw.Font.ttf(fontData);

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          textDirection: pw.TextDirection.rtl,
          theme: pw.ThemeData.withFont(base: arabicFont, bold: arabicFont),
          build: (context) {
            return [
              // Header
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                color: PdfColor.fromHex('#E91E63'),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'إحصائيات الحلقات',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.Text(
                      'عدد الحلقات: ${circlesList.length}',
                      style: const pw.TextStyle(fontSize: 10, color: PdfColors.white),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 8),
              
              // جدول مضغوط
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2.5),
                  1: const pw.FlexColumnWidth(1.5),
                  2: const pw.FlexColumnWidth(1),
                  3: const pw.FlexColumnWidth(1),
                  4: const pw.FlexColumnWidth(1),
                  5: const pw.FlexColumnWidth(1),
                  6: const pw.FlexColumnWidth(1),
                },
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColor.fromHex('#F8BBD0')),
                    children: [
                      _buildCompactCell('الحلقة', isHeader: true),
                      _buildCompactCell('الأستاذ', isHeader: true),
                      _buildCompactCell('الطلاب', isHeader: true),
                      _buildCompactCell('التسميع', isHeader: true),
                      _buildCompactCell('م.تسميع', isHeader: true),
                      _buildCompactCell('المراجعة', isHeader: true),
                      _buildCompactCell('الحضور%', isHeader: true),
                    ],
                  ),
                  ...circlesList.map((circle) {
                    final totalStudents = int.tryParse(circle['total_students'].toString()) ?? 0;
                    final totalRecitations = int.tryParse(circle['total_recitations'].toString()) ?? 0;
                    final avgRecitationMark = double.tryParse(circle['avg_recitation_mark'].toString()) ?? 0;
                    final totalReviews = int.tryParse(circle['total_reviews'].toString()) ?? 0;
                    final presentCount = int.tryParse(circle['present_count'].toString()) ?? 0;
                    final absentCount = int.tryParse(circle['absent_count'].toString()) ?? 0;
                    final totalAttendance = presentCount + absentCount;
                    final attendanceRate = totalAttendance > 0 ? (presentCount / totalAttendance * 100) : 0.0;

                    return pw.TableRow(
                      children: [
                        _buildCompactCell(circle['name_circle'] ?? '-'),
                        _buildCompactCell(circle['teacher_name'] ?? '-'),
                        _buildCompactCell(totalStudents.toString()),
                        _buildCompactCell(totalRecitations.toString()),
                        _buildCompactCell(avgRecitationMark.toStringAsFixed(1)),
                        _buildCompactCell(totalReviews.toString()),
                        _buildCompactCell('${attendanceRate.toStringAsFixed(0)}%'),
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
        name: 'إحصائيات_الحلقات.pdf',
      );

      mySnackbar("نجح", "تم إنشاء التقرير بنجاح", type: "g");
    } catch (e) {
      print("PDF Error: $e");
      mySnackbar("خطأ", "حدث خطأ أثناء إنشاء التقرير: $e");
    }
  }

  pw.Widget _buildCompactCell(String text, {bool isHeader = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 9 : 8,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? PdfColor.fromHex('#E91E63') : PdfColors.black,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }
}
