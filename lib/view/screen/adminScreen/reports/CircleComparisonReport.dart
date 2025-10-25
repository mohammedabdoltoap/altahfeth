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

class CircleComparisonReport extends StatelessWidget {
  final CircleComparisonReportController controller = Get.put(CircleComparisonReportController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("مقارنة بين الحلقات"),
        backgroundColor: Colors.cyan,
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
            color: Colors.cyan.shade50,
            child: Column(
              children: [
                // اختيار الحلقات (متعدد)
                Obx(() => Wrap(
                  spacing: 8,
                  children: controller.circlesList.map((circle) {
                    final isSelected = controller.selectedCircles.contains(circle['id_circle'].toString());
                    return FilterChip(
                      label: Text(circle['name_circle'] ?? ''),
                      selected: isSelected,
                      onSelected: (selected) {
                        controller.toggleCircle(circle['id_circle'].toString());
                      },
                      selectedColor: Colors.cyan.shade200,
                    );
                  }).toList(),
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
                  icon: const Icon(Icons.compare),
                  label: const Text("مقارنة"),
                  onPressed: () => controller.loadData(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan,
                    minimumSize: const Size(double.infinity, 45),
                  ),
                ),
              ],
            ),
          ),
          
          // Comparison Table
          Expanded(
            child: Obx(() {
              if (controller.loading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.comparisonData.isEmpty) {
                return const Center(child: Text("اختر حلقتين على الأقل للمقارنة"));
              }

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildComparisonTable(),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonTable() {
    final columns = <DataColumn>[
      const DataColumn(label: Text('المؤشر', style: TextStyle(fontWeight: FontWeight.bold))),
      ...controller.comparisonData.map((c) => DataColumn(
        label: Text(c['name_circle'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
      )),
    ];
    
    return DataTable(
      headingRowColor: MaterialStateProperty.all(Colors.cyan.shade100),
      columns: columns,
      rows: [
        _buildDataRow('الأستاذ', controller.comparisonData.map((c) => (c['teacher_name'] ?? '-').toString()).toList()),
        _buildDataRow('عدد الطلاب', controller.comparisonData.map((c) => c['total_students']?.toString() ?? '0').toList()),
        _buildDataRow('التسميع', controller.comparisonData.map((c) => c['total_recitations']?.toString() ?? '0').toList()),
        _buildDataRow('م.تسميع', controller.comparisonData.map((c) => 
          (double.tryParse(c['avg_recitation_mark']?.toString() ?? '0') ?? 0).toStringAsFixed(1)).toList()),
        _buildDataRow('المراجعة', controller.comparisonData.map((c) => c['total_reviews']?.toString() ?? '0').toList()),
        _buildDataRow('م.مراجعة', controller.comparisonData.map((c) => 
          (double.tryParse(c['avg_review_mark']?.toString() ?? '0') ?? 0).toStringAsFixed(1)).toList()),
        _buildDataRow('الحضور%', controller.comparisonData.map((c) {
          final present = int.tryParse(c['present_count']?.toString() ?? '0') ?? 0;
          final absent = int.tryParse(c['absent_count']?.toString() ?? '0') ?? 0;
          final total = present + absent;
          return total > 0 ? '${(present / total * 100).toStringAsFixed(0)}%' : '0%';
        }).toList()),
      ],
    );
  }

  DataRow _buildDataRow(String label, List<String> values) {
    return DataRow(
      cells: [
        DataCell(Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
        ...values.map((v) => DataCell(Text(v))),
      ],
    );
  }
}

class CircleComparisonReportController extends GetxController {
  var startDate = Rxn<DateTime>();
  var endDate = Rxn<DateTime>();
  var selectedCircles = <String>[].obs;
  var comparisonData = <Map<String, dynamic>>[].obs;
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
      }
    } catch (e) {
      print("Error loading circles: $e");
    }
  }

  void toggleCircle(String circleId) {
    if (selectedCircles.contains(circleId)) {
      selectedCircles.remove(circleId);
    } else {
      selectedCircles.add(circleId);
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
    if (selectedCircles.length < 2) {
      mySnackbar("تنبيه", "الرجاء اختيار حلقتين على الأقل");
      return;
    }
    
    if (startDate.value == null || endDate.value == null) {
      mySnackbar("تنبيه", "الرجاء اختيار الفترة الزمنية");
      return;
    }

    loading.value = true;
    try {
      final response = await postData(Linkapi.select_circle_comparison, {
        "circle_ids": selectedCircles.toList(),
        "start_date": DateFormat('yyyy-MM-dd').format(startDate.value!),
        "end_date": DateFormat('yyyy-MM-dd').format(endDate.value!),
      });

      if (response == null || response is! Map) {
        mySnackbar("خطأ", "فشل الاتصال بالخادم");
        comparisonData.clear();
        return;
      }
      
      if (response['stat'] == 'ok') {
        comparisonData.assignAll(List<Map<String, dynamic>>.from(response['data']));
        mySnackbar("نجح", "تم تحميل البيانات", type: "g");
      } else {
        comparisonData.clear();
        mySnackbar("خطأ", response['msg'] ?? "حدث خطأ");
      }
    } catch (e) {
      print("Error: $e");
      mySnackbar("خطأ", "حدث خطأ: $e");
      comparisonData.clear();
    } finally {
      loading.value = false;
    }
  }
  
  Future<void> exportToPDF() async {
    if (comparisonData.isEmpty) {
      mySnackbar("تنبيه", "لا توجد بيانات للتصدير");
      return;
    }

    try {
      final pdf = pw.Document();
      final fontData = await rootBundle.load('assets/fonts/Amiri-Bold.ttf');
      final arabicFont = pw.Font.ttf(fontData);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4.landscape,
          textDirection: pw.TextDirection.rtl,
          theme: pw.ThemeData.withFont(base: arabicFont, bold: arabicFont),
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.all(8),
                  color: PdfColor.fromHex('#00BCD4'),
                  child: pw.Text(
                    'مقارنة بين الحلقات',
                    style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
                  children: [
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: PdfColor.fromHex('#B2EBF2')),
                      children: [
                        _buildCell('المؤشر', isHeader: true),
                        ...comparisonData.map((c) => _buildCell(c['name_circle'] ?? '', isHeader: true)),
                      ],
                    ),
                    _buildPdfRow('الأستاذ', comparisonData.map((c) => (c['teacher_name'] ?? '-').toString()).toList()),
                    _buildPdfRow('عدد الطلاب', comparisonData.map((c) => c['total_students']?.toString() ?? '0').toList()),
                    _buildPdfRow('التسميع', comparisonData.map((c) => c['total_recitations']?.toString() ?? '0').toList()),
                    _buildPdfRow('م.تسميع', comparisonData.map((c) => 
                      (double.tryParse(c['avg_recitation_mark']?.toString() ?? '0') ?? 0).toStringAsFixed(1)).toList()),
                    _buildPdfRow('المراجعة', comparisonData.map((c) => c['total_reviews']?.toString() ?? '0').toList()),
                    _buildPdfRow('م.مراجعة', comparisonData.map((c) => 
                      (double.tryParse(c['avg_review_mark']?.toString() ?? '0') ?? 0).toStringAsFixed(1)).toList()),
                    _buildPdfRow('الحضور%', comparisonData.map((c) {
                      final present = int.tryParse(c['present_count']?.toString() ?? '0') ?? 0;
                      final absent = int.tryParse(c['absent_count']?.toString() ?? '0') ?? 0;
                      final total = present + absent;
                      return total > 0 ? '${(present / total * 100).toStringAsFixed(0)}%' : '0%';
                    }).toList()),
                  ],
                ),
              ],
            );
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
        name: 'مقارنة_الحلقات.pdf',
      );

      mySnackbar("نجح", "تم إنشاء التقرير بنجاح", type: "g");
    } catch (e) {
      print("PDF Error: $e");
      mySnackbar("خطأ", "حدث خطأ أثناء إنشاء التقرير: $e");
    }
  }

  pw.TableRow _buildPdfRow(String label, List<String> values) {
    return pw.TableRow(
      children: [
        _buildCell(label),
        ...values.map((v) => _buildCell(v)),
      ],
    );
  }

  pw.Widget _buildCell(String text, {bool isHeader = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 9 : 8,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? PdfColor.fromHex('#00BCD4') : PdfColors.black,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }
}
