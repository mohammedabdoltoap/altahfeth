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

class TeacherPerformanceReport extends StatelessWidget {
  final TeacherPerformanceReportController controller = Get.put(TeacherPerformanceReportController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("تقرير أداء الأساتذة"),
        backgroundColor: Colors.green,
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
            color: Colors.green.shade50,
            child: Column(
              children: [
                // اختيار الشهر والسنة
                Row(
                  children: [
                    Expanded(
                      child: Obx(() => DropdownButtonFormField<int>(
                        decoration: const InputDecoration(
                          labelText: "الشهر",
                          border: OutlineInputBorder(),
                        ),
                        value: controller.selectedMonth.value,
                        items: List.generate(12, (index) {
                          return DropdownMenuItem(
                            value: index + 1,
                            child: Text(_getMonthName(index + 1)),
                          );
                        }),
                        onChanged: (val) {
                          controller.selectedMonth.value = val;
                        },
                      )),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Obx(() => DropdownButtonFormField<int>(
                        decoration: const InputDecoration(
                          labelText: "السنة",
                          border: OutlineInputBorder(),
                        ),
                        value: controller.selectedYear.value,
                        items: List.generate(5, (index) {
                          int year = DateTime.now().year - index;
                          return DropdownMenuItem(
                            value: year,
                            child: Text(year.toString()),
                          );
                        }),
                        onChanged: (val) {
                          controller.selectedYear.value = val;
                        },
                      )),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.search),
                  label: const Text("عرض التقرير"),
                  onPressed: () => controller.loadData(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: const Size(double.infinity, 45),
                  ),
                ),
              ],
            ),
          ),
          
          // Data List
          Expanded(
            child: Obx(() {
              if (controller.loading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.performanceList.isEmpty) {
                return const Center(
                  child: Text("لا توجد بيانات أداء لهذه الفترة"),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.performanceList.length,
                itemBuilder: (context, index) {
                  final item = controller.performanceList[index];
                  final attendanceRate = _calculateRate(
                    item['attendance_count'],
                    item['total_days'],
                  );
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ExpansionTile(
                      leading: CircleAvatar(
                        backgroundColor: _getRateColor(attendanceRate),
                        child: Text(
                          '${attendanceRate.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      title: Text(
                        item['username'] ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        'الحلقة: ${item['name_circle'] ?? '-'}',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _buildStatRow(
                                Icons.check_circle,
                                'أيام الحضور',
                                '${item['attendance_count'] ?? 0}',
                                Colors.green,
                              ),
                              const Divider(),
                              _buildStatRow(
                                Icons.event_busy,
                                'أيام الإجازة',
                                '${item['leave_count'] ?? 0}',
                                Colors.orange,
                              ),
                              const Divider(),
                              _buildStatRow(
                                Icons.cancel,
                                'أيام الغياب',
                                '${item['absence_count'] ?? 0}',
                                Colors.red,
                              ),
                              const Divider(),
                              _buildStatRow(
                                Icons.calendar_month,
                                'إجمالي الأيام',
                                '${item['total_days'] ?? 0}',
                                Colors.blue,
                              ),
                              const SizedBox(height: 12),
                              LinearProgressIndicator(
                                value: attendanceRate / 100,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _getRateColor(attendanceRate),
                                ),
                                minHeight: 8,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'نسبة الحضور: ${attendanceRate.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _getRateColor(attendanceRate),
                                ),
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

  Widget _buildStatRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color,
          ),
        ),
      ],
    );
  }

  double _calculateRate(dynamic count, dynamic total) {
    if (total == null || total == 0) return 0;
    return ((count ?? 0) / total) * 100;
  }

  Color _getRateColor(double rate) {
    if (rate >= 90) return Colors.green;
    if (rate >= 75) return Colors.orange;
    return Colors.red;
  }

  String _getMonthName(int month) {
    const months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    return months[month - 1];
  }
}

class TeacherPerformanceReportController extends GetxController {
  var performanceList = <Map<String, dynamic>>[].obs;
  var loading = false.obs;
  var dataArg;
  
  var selectedMonth = Rx<int?>(DateTime.now().month);
  var selectedYear = Rx<int?>(DateTime.now().year);

  @override
  void onInit() {
    super.onInit();
    dataArg = Get.arguments;
  }

  Future<void> loadData() async {
    if (selectedMonth.value == null || selectedYear.value == null) {
      mySnackbar("تنبيه", "الرجاء اختيار الشهر والسنة");
      return;
    }

    loading.value = true;
    try {
      final response = await postData(Linkapi.select_teacher_performance, {
        "month": selectedMonth.value.toString(),
        "year": selectedYear.value.toString(),
        "id_user": dataArg?['id_user']?.toString(),
      });

      print("Teacher Performance Response: $response");

      if (response == null) {
        mySnackbar("خطأ", "فشل الاتصال بالخادم");
        performanceList.clear();
        return;
      }

      if (response is! Map) {
        mySnackbar("خطأ", "استجابة غير صحيحة من الخادم");
        performanceList.clear();
        return;
      }
      
      if (response['stat'] == 'ok') {
        if (response['data'] != null && response['data'] is List) {
          performanceList.assignAll(List<Map<String, dynamic>>.from(response['data']));
          mySnackbar("نجح", "تم تحميل ${performanceList.length} سجل", type: "g");
        } else {
          performanceList.clear();
          mySnackbar("تنبيه", "لا توجد بيانات");
        }
      } else if (response['stat'] == 'no') {
        performanceList.clear();
        mySnackbar("تنبيه", "لا توجد بيانات أداء لهذه الفترة");
      } else {
        performanceList.clear();
        mySnackbar("خطأ", response['msg'] ?? "حدث خطأ");
      }
    } catch (e) {
      print("Error loading teacher performance: $e");
      mySnackbar("خطأ", "حدث خطأ: $e");
      performanceList.clear();
    } finally {
      loading.value = false;
    }
  }
  
  Future<void> exportToPDF() async {
    if (performanceList.isEmpty) {
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
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#4CAF50'),
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'تقرير أداء الأساتذة',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      'الشهر: ${_getMonthName(selectedMonth.value!)} ${selectedYear.value}',
                      style: const pw.TextStyle(fontSize: 14, color: PdfColors.white),
                    ),
                    pw.Text(
                      'عدد الأساتذة: ${performanceList.length}',
                      style: const pw.TextStyle(fontSize: 14, color: PdfColors.white),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('#C8E6C9'),
                    ),
                    children: [
                      _buildTableCell('الاسم', isHeader: true),
                      _buildTableCell('الحلقة', isHeader: true),
                      _buildTableCell('الحضور', isHeader: true),
                      _buildTableCell('الإجازة', isHeader: true),
                      _buildTableCell('الغياب', isHeader: true),
                      _buildTableCell('النسبة', isHeader: true),
                    ],
                  ),
                  ...performanceList.map((item) {
                    double rate = _calculateRate(item['attendance_count'], item['total_days']);
                    
                    return pw.TableRow(
                      children: [
                        _buildTableCell(item['username'] ?? '-'),
                        _buildTableCell(item['name_circle'] ?? '-'),
                        _buildTableCell('${item['attendance_count'] ?? 0}'),
                        _buildTableCell('${item['leave_count'] ?? 0}'),
                        _buildTableCell('${item['absence_count'] ?? 0}'),
                        _buildTableCell('${rate.toStringAsFixed(1)}%'),
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
        name: 'تقرير_أداء_الأساتذة_${selectedMonth.value}_${selectedYear.value}.pdf',
      );

      mySnackbar("نجح", "تم إنشاء التقرير بنجاح", type: "g");
    } catch (e) {
      print("PDF Error: $e");
      mySnackbar("خطأ", "حدث خطأ أثناء إنشاء التقرير: $e");
    }
  }

  pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 11 : 9,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? PdfColor.fromHex('#2E7D32') : PdfColors.black,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  double _calculateRate(dynamic count, dynamic total) {
    if (total == null || total == 0) return 0;
    return ((count ?? 0) / total) * 100;
  }

  String _getMonthName(int month) {
    const months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    return months[month - 1];
  }
}
