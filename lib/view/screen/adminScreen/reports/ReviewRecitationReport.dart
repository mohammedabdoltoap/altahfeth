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

class ReviewRecitationReport extends StatelessWidget {
  final ReviewRecitationReportController controller = Get.put(ReviewRecitationReportController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("تقرير المراجعة"),
        backgroundColor: Colors.orange,
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
            color: Colors.orange.shade50,
            child: Column(
              children: [
                // اختيار الحلقة
                Obx(() => DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: "الحلقة",
                    border: OutlineInputBorder(),
                  ),
                  value: controller.selectedCircle.value,
                  items: [
                    const DropdownMenuItem(value: 'all', child: Text("جميع الحلقات")),
                    ...controller.circlesList.map((circle) {
                      return DropdownMenuItem(
                        value: circle['id_circle'].toString(),
                        child: Text(circle['name_circle'] ?? ''),
                      );
                    }).toList(),
                  ],
                  onChanged: (val) {
                    controller.selectedCircle.value = val;
                  },
                )),
                const SizedBox(height: 8),
                // اختيار نوع التاريخ
                Obx(() => Row(
                  children: [
                    Expanded(
                      child: RadioListTile<bool>(
                        title: const Text("يوم واحد"),
                        value: false,
                        groupValue: controller.useDateRange.value,
                        onChanged: (val) => controller.useDateRange.value = val!,
                        dense: true,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<bool>(
                        title: const Text("فترة"),
                        value: true,
                        groupValue: controller.useDateRange.value,
                        onChanged: (val) => controller.useDateRange.value = val!,
                        dense: true,
                      ),
                    ),
                  ],
                )),
                const SizedBox(height: 8),
                // اختيار التاريخ
                Obx(() {
                  if (controller.useDateRange.value) {
                    return Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.calendar_today, size: 18),
                            label: Text(
                              controller.startDate.value != null
                                  ? DateFormat('yyyy-MM-dd').format(controller.startDate.value!)
                                  : "من",
                              style: const TextStyle(fontSize: 12),
                            ),
                            onPressed: () => controller.selectStartDate(context),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.calendar_today, size: 18),
                            label: Text(
                              controller.endDate.value != null
                                  ? DateFormat('yyyy-MM-dd').format(controller.endDate.value!)
                                  : "إلى",
                              style: const TextStyle(fontSize: 12),
                            ),
                            onPressed: () => controller.selectEndDate(context),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return ElevatedButton.icon(
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        controller.selectedDate.value != null
                            ? DateFormat('yyyy-MM-dd').format(controller.selectedDate.value!)
                            : "اختر التاريخ",
                      ),
                      onPressed: () => controller.selectDate(context),
                    );
                  }
                }),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.search),
                  label: const Text("عرض التقرير"),
                  onPressed: () => controller.loadData(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    minimumSize: const Size(double.infinity, 45),
                  ),
                ),
              ],
            ),
          ),
          
          // Statistics
          Obx(() {
            if (controller.reviewList.isEmpty) return const SizedBox.shrink();
            
            final isSummary = controller.reviewList.first.containsKey('total_reviews');
            
            if (isSummary) {
              final totalReviews = controller.reviewList.fold(0, (sum, s) => 
                sum + (int.tryParse(s['total_reviews'].toString()) ?? 0));
              final avgMark = controller.reviewList.fold(0.0, (sum, s) => 
                sum + (double.tryParse(s['avg_mark'].toString()) ?? 0.0)) / controller.reviewList.length;
              
              return Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey.shade100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard("عدد المراجعات", totalReviews.toString(), Colors.orange),
                    _buildStatCard("متوسط الدرجات", avgMark.toStringAsFixed(1), Colors.green),
                    _buildStatCard("عدد الطلاب", controller.reviewList.length.toString(), Colors.blue),
                  ],
                ),
              );
            } else {
              return Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey.shade100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard("المراجعات", controller.reviewList.length.toString(), Colors.orange),
                  ],
                ),
              );
            }
          }),
          
          // Data List
          Expanded(
            child: Obx(() {
              if (controller.loading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.reviewList.isEmpty) {
                return const Center(
                  child: Text("لا توجد بيانات مراجعة"),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.reviewList.length,
                itemBuilder: (context, index) {
                  final item = controller.reviewList[index];
                  final isSummary = item.containsKey('total_reviews');
                  
                  if (isSummary) {
                    return _buildSummaryCard(item);
                  } else {
                    return _buildDetailCard(item);
                  }
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(Map<String, dynamic> item) {
    final totalReviews = int.tryParse(item['total_reviews'].toString()) ?? 0;
    final avgMark = double.tryParse(item['avg_mark'].toString()) ?? 0.0;
    final markColor = avgMark >= 80 ? Colors.green : avgMark >= 60 ? Colors.orange : Colors.red;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: markColor,
          child: Text(
            avgMark.toStringAsFixed(0),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          item['name_student'] ?? '',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: item['name_circle'] != null
            ? Text('الحلقة: ${item['name_circle']}')
            : null,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('المراجعات', totalReviews.toString(), Colors.orange),
                    _buildStatItem('متوسط الدرجة', avgMark.toStringAsFixed(1), markColor),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: avgMark / 100,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(markColor),
                  minHeight: 8,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(Map<String, dynamic> item) {
    final mark = int.tryParse(item['mark'].toString()) ?? 0;
    final markColor = mark >= 80 ? Colors.green : mark >= 60 ? Colors.orange : Colors.red;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: markColor,
          child: Text(
            mark.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          item['name_student'] ?? '',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item['name_circle'] != null)
              Text('الحلقة: ${item['name_circle']}'),
            Text('من: ${item['from_soura_name'] ?? ''} (${item['from_id_aya'] ?? ''})'),
            Text('إلى: ${item['to_soura_name'] ?? ''} (${item['to_id_aya'] ?? ''})'),
            if (item['evaluation_name'] != null)
              Text(
                'التقييم: ${item['evaluation_name']}',
                style: TextStyle(
                  color: Colors.orange.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
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
}

class ReviewRecitationReportController extends GetxController {
  var selectedDate = Rxn<DateTime>();
  var startDate = Rxn<DateTime>();
  var endDate = Rxn<DateTime>();
  var selectedCircle = Rxn<String>();
  var reviewList = <Map<String, dynamic>>[].obs;
  var circlesList = <Map<String, dynamic>>[].obs;
  var loading = false.obs;
  var dataArg;
  var useDateRange = false.obs;

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
      }
    } catch (e) {
      print("Error loading circles: $e");
    }
  }

  Future<void> selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      selectedDate.value = picked;
      useDateRange.value = false;
    }
  }
  
  Future<void> selectStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate.value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      startDate.value = picked;
      useDateRange.value = true;
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
      useDateRange.value = true;
    }
  }

  Future<void> loadData() async {
    if (!useDateRange.value && selectedDate.value == null) {
      mySnackbar("تنبيه", "الرجاء اختيار التاريخ");
      return;
    }
    
    if (useDateRange.value && (startDate.value == null || endDate.value == null)) {
      mySnackbar("تنبيه", "الرجاء اختيار تاريخ البداية والنهاية");
      return;
    }
    
    if (selectedCircle.value == null) {
      mySnackbar("تنبيه", "الرجاء اختيار الحلقة");
      return;
    }

    loading.value = true;
    try {
      Map<String, dynamic> requestData = {
        "id_circle": selectedCircle.value,
      };
      
      if (useDateRange.value) {
        requestData["start_date"] = DateFormat('yyyy-MM-dd').format(startDate.value!);
        requestData["end_date"] = DateFormat('yyyy-MM-dd').format(endDate.value!);
      } else {
        requestData["date"] = DateFormat('yyyy-MM-dd').format(selectedDate.value!);
      }
      
      final response = await postData(Linkapi.select_review_recitation_report, requestData);

      print("Review Recitation Response: $response");

      if (response == null) {
        mySnackbar("خطأ", "فشل الاتصال بالخادم");
        reviewList.clear();
        return;
      }

      if (response is! Map) {
        mySnackbar("خطأ", "استجابة غير صحيحة من الخادم");
        reviewList.clear();
        return;
      }
      
      if (response['stat'] == 'ok') {
        if (response['data'] != null && response['data'] is List) {
          reviewList.assignAll(List<Map<String, dynamic>>.from(response['data']));
          mySnackbar("نجح", "تم تحميل ${reviewList.length} سجل", type: "g");
        } else {
          reviewList.clear();
          mySnackbar("تنبيه", "لا توجد بيانات");
        }
      } else if (response['stat'] == 'no') {
        reviewList.clear();
        mySnackbar("تنبيه", "لا توجد بيانات مراجعة لهذه الفترة");
      } else {
        reviewList.clear();
        mySnackbar("خطأ", response['msg'] ?? "حدث خطأ");
      }
    } catch (e) {
      print("Error: $e");
      mySnackbar("خطأ", "حدث خطأ: $e");
      reviewList.clear();
    } finally {
      loading.value = false;
    }
  }
  
  Future<void> exportToPDF() async {
    if (reviewList.isEmpty) {
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
                  color: PdfColor.fromHex('#FF9800'),
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'تقرير المراجعة',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      'عدد السجلات: ${reviewList.length}',
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
                      color: PdfColor.fromHex('#FFE0B2'),
                    ),
                    children: [
                      _buildTableCell('الطالب', isHeader: true),
                      _buildTableCell('من', isHeader: true),
                      _buildTableCell('إلى', isHeader: true),
                      _buildTableCell('الدرجة', isHeader: true),
                    ],
                  ),
                  ...reviewList.map((item) {
                    return pw.TableRow(
                      children: [
                        _buildTableCell(item['name_student'] ?? '-'),
                        _buildTableCell('${item['from_soura_name'] ?? ''} (${item['from_id_aya'] ?? ''})'),
                        _buildTableCell('${item['to_soura_name'] ?? ''} (${item['to_id_aya'] ?? ''})'),
                        _buildTableCell(item['mark']?.toString() ?? '-'),
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
        name: 'تقرير_المراجعة.pdf',
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
          color: isHeader ? PdfColor.fromHex('#E65100') : PdfColors.black,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }
}
