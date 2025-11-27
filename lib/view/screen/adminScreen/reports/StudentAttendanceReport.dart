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

class StudentAttendanceReport extends StatelessWidget {
  final StudentAttendanceReportController controller = Get.put(StudentAttendanceReportController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("تقرير حضور وغياب الطلاب"),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () => controller.exportToPDF(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Date Selection
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.teal.shade50,
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
                    backgroundColor: Colors.teal,
                    minimumSize: const Size(double.infinity, 45),
                  ),
                ),
              ],
            ),
          ),
          
          // Statistics
          Obx(() {
            if (controller.attendanceList.isEmpty) return const SizedBox.shrink();
            
            // تحقق من نوع البيانات
            final isSummary = controller.attendanceList.first.containsKey('present_count');
            
            int present, absent, total;
            
            if (isSummary) {
              // حساب من البيانات المجمعة
              present = controller.attendanceList.fold(0, (sum, s) => 
                sum + (int.tryParse(s['present_count'].toString()) ?? 0));
              absent = controller.attendanceList.fold(0, (sum, s) => 
                sum + (int.tryParse(s['absent_count'].toString()) ?? 0));
              total = present + absent;
            } else {
              // حساب من البيانات التفصيلية
              present = controller.attendanceList.where((s) => s['status'] == '1').length;
              absent = controller.attendanceList.where((s) => s['status'] == '0').length;
              total = controller.attendanceList.length;
            }
            
            return Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey.shade100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatCard("الحضور", present.toString(), Colors.green),
                  _buildStatCard("الغياب", absent.toString(), Colors.red),
                  _buildStatCard(isSummary ? "إجمالي الأيام" : "إجمالي الطلاب", total.toString(), Colors.blue),
                ],
              ),
            );
          }),
          
          // Data List
          Expanded(
            child: Obx(() {
              if (controller.loading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.attendanceList.isEmpty) {
                return const Center(
                  child: Text("لا توجد بيانات حضور"),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.attendanceList.length,
                itemBuilder: (context, index) {
                  final student = controller.attendanceList[index];
                  
                  // تحقق من نوع البيانات (مجمعة أو تفصيلية)
                  final isSummary = student.containsKey('present_count');
                  
                  if (isSummary) {
                    // عرض ملخص (للفترة)
                    final presentCount = int.tryParse(student['present_count'].toString()) ?? 0;
                    final absentCount = int.tryParse(student['absent_count'].toString()) ?? 0;
                    final totalDays = int.tryParse(student['total_days'].toString()) ?? 0;
                    final attendanceRate = totalDays > 0 ? (presentCount / totalDays * 100) : 0.0;
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: attendanceRate >= 80 ? Colors.green : 
                                          attendanceRate >= 60 ? Colors.orange : Colors.red,
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
                          student['name_student'] ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: student['name_circle'] != null
                            ? Text('الحلقة: ${student['name_circle']}')
                            : null,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildStatItem('الحضور', presentCount.toString(), Colors.green),
                                    _buildStatItem('الغياب', absentCount.toString(), Colors.red),
                                    _buildStatItem('الإجمالي', totalDays.toString(), Colors.blue),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                LinearProgressIndicator(
                                  value: attendanceRate / 100,
                                  backgroundColor: Colors.grey.shade200,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    attendanceRate >= 80 ? Colors.green : 
                                    attendanceRate >= 60 ? Colors.orange : Colors.red,
                                  ),
                                  minHeight: 8,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    // عرض تفصيلي (ليوم واحد)
                    final isPresent = student['status'] == '1';
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: CircleAvatar(
                          backgroundColor: isPresent ? Colors.green : Colors.red,
                          child: Icon(
                            isPresent ? Icons.check : Icons.close,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          student['name_student'] ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (student['name_circle'] != null)
                              Text(
                                'الحلقة: ${student['name_circle']}',
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 12,
                                ),
                              ),
                            Text(
                              isPresent ? 'حاضر' : 'غائب',
                              style: TextStyle(
                                color: isPresent ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        trailing: student['notes'] != null && student['notes'].toString().isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.note, color: Colors.orange),
                                onPressed: () {
                                  Get.dialog(
                                    AlertDialog(
                                      title: const Text("ملاحظات"),
                                      content: Text(student['notes'] ?? ''),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Get.back(),
                                          child: const Text("إغلاق"),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              )
                            : null,
                      ),
                    );
                  }
                },
              );
            }),
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

class StudentAttendanceReportController extends GetxController {
  var selectedDate = Rxn<DateTime>();
  var startDate = Rxn<DateTime>();
  var endDate = Rxn<DateTime>();
  var selectedCircle = Rxn<String>();
  var attendanceList = <Map<String, dynamic>>[].obs;
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
      }
      else if(res["stat"]=="no"){
        mySnackbar("تنبية", "لايوجد لديك حلقات");
      }
      else {
        mySnackbar("خطأ", res["msg"] ?? "حصل خطأ أثناء جلب البيانات");
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
    final now = DateTime.now();
    final initial = startDate.value ?? now;
    
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isAfter(now) ? now : initial,
      firstDate: DateTime(2020),
      lastDate: now,
    );
    if (picked != null) {
      startDate.value = picked;
      useDateRange.value = true;
      
      // إذا كان تاريخ النهاية موجود وأصبح أصغر من تاريخ البداية، امسحه
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
    
    // التأكد من أن initialDate ضمن النطاق المسموح
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
    
    // التحقق من أن تاريخ البداية أصغر من تاريخ النهاية
    if (useDateRange.value && startDate.value != null && endDate.value != null) {
      if (startDate.value!.isAfter(endDate.value!)) {
        mySnackbar("خطأ", "تاريخ البداية يجب أن يكون أصغر من تاريخ النهاية");
        return;
      }
    }
    
    if (selectedCircle.value == null) {
      mySnackbar("تنبيه", "الرجاء اختيار الحلقة");
      return;
    }

    Map<String, dynamic> requestData = {
      "id_circle": selectedCircle.value,
    };
    
    if (useDateRange.value) {
      requestData["start_date"] = DateFormat('yyyy-MM-dd').format(startDate.value!);
      requestData["end_date"] = DateFormat('yyyy-MM-dd').format(endDate.value!);
    } else {
      requestData["date"] = DateFormat('yyyy-MM-dd').format(selectedDate.value!);
    }

    var res = await handleRequest(
      isLoading: loading,
      useDialog: true,
      immediateLoading: true,
      loadingMessage: "جاري تحميل بيانات الحضور...",
      action: () async {
        return await postData(Linkapi.select_student_attendance, requestData);
      }
    );
    
    if (res == null) {
      attendanceList.clear();
      return;
    }
    
    if (res is! Map) {
      mySnackbar("خطأ", "فشل الاتصال بالخادم");
      attendanceList.clear();
      return;
    }
    
    if (res["stat"] == "ok") {
      if (res['data'] != null && res['data'] is List) {
        attendanceList.assignAll(List<Map<String, dynamic>>.from(res['data']));
        mySnackbar("نجح", "تم تحميل ${attendanceList.length} طالب", type: "g");
      } else {
        attendanceList.clear();
        mySnackbar("تنبيه", "لا توجد بيانات");
      }
    } else if (res["stat"] == "no") {
      attendanceList.clear();
      mySnackbar("تنبيه", "لا توجد بيانات حضور لهذا التاريخ");
    } else {
      attendanceList.clear();
      mySnackbar("خطأ", res["msg"] ?? "حدث خطأ أثناء جلب البيانات");
    }
  }
  
  Future<void> exportToPDF() async {
    if (attendanceList.isEmpty) {
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

      final dateStr = selectedDate.value != null 
          ? DateFormat('yyyy-MM-dd').format(selectedDate.value!)
          : useDateRange.value && startDate.value != null && endDate.value != null
              ? 'من ${DateFormat('yyyy-MM-dd').format(startDate.value!)} إلى ${DateFormat('yyyy-MM-dd').format(endDate.value!)}'
              : '';
      
      final present = attendanceList.where((s) => s['status'] == '1').length;
      final absent = attendanceList.where((s) => s['status'] == '0').length;

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
                            'تقرير حضور وغياب الطلاب',
                            style: pw.TextStyle(
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            'التاريخ: $dateStr',
                            style: const pw.TextStyle(fontSize: 11),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            'حضور: $present | غياب: $absent | إجمالي: ${attendanceList.length}',
                            style: const pw.TextStyle(fontSize: 9),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            'الحلقة: ${circlesList.firstWhere((circle) => circle['id_circle'].toString() == selectedCircle.value.toString(), orElse: () => {'name_circle': 'غير محدد'})['name_circle']}',
                            style: const pw.TextStyle(fontSize: 8),
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

              // Table
              pw.Directionality(
                textDirection: pw.TextDirection.rtl,
                child: pw.Table.fromTextArray(
                  headers: ['ملاحظات', 'الحالة', 'الحلقة', 'اسم الطالب', '#'],
                  data: () {
                    // ترتيب البيانات حسب اسم الحلقة
                    final sortedList = List<Map<String, dynamic>>.from(attendanceList);
                    sortedList.sort((a, b) {
                      final circleA = a['name_circle']?.toString() ?? '';
                      final circleB = b['name_circle']?.toString() ?? '';
                      return circleA.compareTo(circleB);
                    });
                    
                    return sortedList.asMap().entries.map((entry) {
                      final index = entry.key + 1;
                      final item = entry.value;
                      final isPresent = item['status'] == '1';
                      
                      return [
                        item['notes'] ?? '-',
                        isPresent ? 'حاضر' : 'غائب',
                        item['name_circle'] ?? "",
                        item['name_student'] ?? '-',
                        index.toString(),
                      ];
                    }).toList();
                  }(),
                  border: pw.TableBorder.all(width: 0.5, color: PdfColors.teal300),
                  headerStyle: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                  headerDecoration: const pw.BoxDecoration(
                    color: PdfColors.teal,
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

      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
        name: 'تقرير_حضور_الطلاب_$dateStr.pdf',
      );

      mySnackbar("نجح", "تم إنشاء التقرير بنجاح", type: "g");
    } catch (e) {
      print("PDF Error: $e");
      mySnackbar("خطأ", "حدث خطأ أثناء إنشاء التقرير: $e");
    }
  }

  pw.Widget _buildTableCell(String text, {bool isHeader = false, PdfColor? color}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 12 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: color ?? (isHeader ? PdfColor.fromHex('#00695C') : PdfColors.black),
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }
}
