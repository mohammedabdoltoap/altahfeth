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

class AbsenceReport extends StatelessWidget {
  final AbsenceReportController controller = Get.put(AbsenceReportController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("تقرير الغياب"),
        backgroundColor: Colors.red,
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
            color: Colors.red.shade50,
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
                    backgroundColor: Colors.red,
                    minimumSize: const Size(double.infinity, 45),
                  ),
                ),
              ],
            ),
          ),
          
          // Statistics
          Obx(() {
            if (controller.absenceList.isEmpty) return const SizedBox.shrink();
            
            final isSummary = controller.absenceList.first.containsKey('absent_count');
            
            if (isSummary) {
              final totalAbsences = controller.absenceList.fold(0, (sum, s) => 
                sum + (int.tryParse(s['absent_count'].toString()) ?? 0));
              
              return Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey.shade100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard("إجمالي الغياب", totalAbsences.toString(), Colors.red),
                    _buildStatCard("عدد الطلاب", controller.absenceList.length.toString(), Colors.blue),
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
                    _buildStatCard("الغياب اليوم", controller.absenceList.length.toString(), Colors.red),
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

              if (controller.absenceList.isEmpty) {
                return const Center(
                  child: Text("لا توجد بيانات غياب"),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.absenceList.length,
                itemBuilder: (context, index) {
                  final item = controller.absenceList[index];
                  final isSummary = item.containsKey('absent_count');
                  
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
    final absentCount = int.tryParse(item['absent_count'].toString()) ?? 0;
    final totalDays = int.tryParse(item['total_days'].toString()) ?? 0;
    final attendanceRate = totalDays > 0 ? ((totalDays - absentCount) / totalDays * 100) : 0.0;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Colors.red,
          child: Text(
            absentCount.toString(),
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
                    _buildStatItem('أيام الغياب', absentCount.toString(), Colors.red),
                    _buildStatItem('إجمالي الأيام', totalDays.toString(), Colors.blue),
                    _buildStatItem('نسبة الحضور', '${attendanceRate.toStringAsFixed(0)}%', Colors.green),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: attendanceRate / 100,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    attendanceRate >= 80 ? Colors.green : attendanceRate >= 60 ? Colors.orange : Colors.red
                  ),
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
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: const CircleAvatar(
          backgroundColor: Colors.red,
          child: Icon(Icons.person_off, color: Colors.white),
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
            if (item['notes'] != null && item['notes'].toString().isNotEmpty)
              Text(
                'ملاحظات: ${item['notes']}',
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontStyle: FontStyle.italic,
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

class AbsenceReportController extends GetxController {
  var selectedDate = Rxn<DateTime>();
  var startDate = Rxn<DateTime>();
  var endDate = Rxn<DateTime>();
  var selectedCircle = Rxn<String>();
  var absenceList = <Map<String, dynamic>>[].obs;
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
      
      final response = await postData(Linkapi.select_absence_report, requestData);

      if (response == null) {
        mySnackbar("خطأ", "فشل الاتصال بالخادم");
        absenceList.clear();
        return;
      }

      if (response is! Map) {
        mySnackbar("خطأ", "استجابة غير صحيحة من الخادم");
        absenceList.clear();
        return;
      }
      
      if (response['stat'] == 'ok') {
        if (response['data'] != null && response['data'] is List) {
          absenceList.assignAll(List<Map<String, dynamic>>.from(response['data']));
          mySnackbar("نجح", "تم تحميل ${absenceList.length} سجل", type: "g");
        } else {
          absenceList.clear();
          mySnackbar("تنبيه", "لا توجد بيانات");
        }
      } else if (response['stat'] == 'no') {
        absenceList.clear();
        mySnackbar("تنبيه", "لا توجد بيانات غياب لهذه الفترة");
      } else {
        absenceList.clear();
        mySnackbar("خطأ", response['msg'] ?? "حدث خطأ");
      }
    } catch (e) {
      print("Error: $e");
      mySnackbar("خطأ", "حدث خطأ: $e");
      absenceList.clear();
    } finally {
      loading.value = false;
    }
  }
  
  Future<void> exportToPDF() async {
    if (absenceList.isEmpty) {
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
                  color: PdfColor.fromHex('#F44336'),
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'تقرير الغياب',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      'عدد السجلات: ${absenceList.length}',
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
                      color: PdfColor.fromHex('#FFCDD2'),
                    ),
                    children: [
                      _buildTableCell('الطالب', isHeader: true),
                      _buildTableCell('الحلقة', isHeader: true),
                      _buildTableCell('الغياب', isHeader: true),
                    ],
                  ),
                  ...absenceList.map((item) {
                    return pw.TableRow(
                      children: [
                        _buildTableCell(item['name_student'] ?? '-'),
                        _buildTableCell(item['name_circle'] ?? '-'),
                        _buildTableCell(item['absent_count']?.toString() ?? '1'),
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
        name: 'تقرير_الغياب.pdf',
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
          color: isHeader ? PdfColor.fromHex('#C62828') : PdfColors.black,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }
}
