import 'package:althfeth/api/LinkApi.dart';
import 'package:althfeth/api/apiFunction.dart';
import 'package:althfeth/constants/color.dart';
import 'package:althfeth/constants/function.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class TeacherAttendanceReport extends StatelessWidget {
  final TeacherAttendanceReportController controller = Get.put(TeacherAttendanceReportController());

  @override
  Widget build(BuildContext context) {
    // تهيئة بيانات التاريخ للغة العربية

    return Scaffold(
      appBar: AppBar(
        title: const Text("تقرير حضور وانصراف الأساتذة"),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () => controller.exportToPDF(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Date Selection
            Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Column(
              children: [
                // اختيار نوع التاريخ
                Obx(() => Row(
                  children: [
                    Expanded(
                      child: RadioListTile<bool>(
                        title: const Text("يوم واحد"),
                        value: false,
                        groupValue: controller.useDateRange.value,
                        onChanged: (val) => controller.useDateRange.value = val!,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<bool>(
                        title: const Text("فترة"),
                        value: true,
                        groupValue: controller.useDateRange.value,
                        onChanged: (val) => controller.useDateRange.value = val!,
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
                  onPressed: () => controller.loadData(),
                  label: const Text("عرض التقرير"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: const Size(double.infinity, 45),
                  ),
                ),
              ],
            ),
          ),

          // Filters
          Obx(() {
            if (controller.attendanceList.isEmpty) return const SizedBox.shrink();

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.grey.shade100,
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.filter_list, size: 20),
                      const SizedBox(width: 8),
                      const Text("الفلاتر:", style: TextStyle(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      TextButton.icon(
                        icon: const Icon(Icons.clear, size: 18),
                        label: const Text("مسح"),
                        onPressed: () => controller.clearFilters(),
                      ),
                    ],
                  ),
                  Row(
                    children: [

                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: "الحلقة",
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          value: controller.selectedCircle.value,
                          items: [
                            const DropdownMenuItem(value: 'all', child: Text("الكل")),
                            ...controller.circlesList.map((circle) {
                              return DropdownMenuItem(
                                value: circle['id_circle'].toString(),
                                child: Text(circle['name_circle'] ?? ''),
                              );
                            }).toList(),
                          ],
                          onChanged: (val) {
                            controller.selectedCircle.value = val;
                            controller.applyFilters();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),

          // Data List
          Container(
            height: 400, // تحديد ارتفاع ثابت للقائمة
            child: Obx(() {
              if (controller.loading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.groupedAttendanceList.isEmpty) {
                return const Center(
                  child: Text("لا توجد بيانات"),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.groupedAttendanceList.length,
                itemBuilder: (context, index) {
                  final teacherGroup = controller.groupedAttendanceList[index];
                  final attendanceRecords = List<Map<String, dynamic>>.from(teacherGroup['attendance_records'] ?? []);
                  final completedDays = teacherGroup['completed_days'] ?? 0;
                  final incompleteDays = teacherGroup['incomplete_days'] ?? 0;
                  final totalDays = teacherGroup['total_days'] ?? 0;
                  final completionRate = totalDays > 0 ? (completedDays / totalDays * 100) : 0.0;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ExpansionTile(
                      leading: CircleAvatar(
                        backgroundColor: completionRate >= 80 ? Colors.green : 
                                        completionRate >= 60 ? Colors.orange : Colors.red,
                        child: Text(
                          '${completionRate.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      title: Text(
                        teacherGroup['teacher_name'] ?? 'غير محدد',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            _buildStatChip('مكتمل', completedDays.toString(), Colors.green),
                            const SizedBox(width: 8),
                            _buildStatChip('غير مكتمل', incompleteDays.toString(), Colors.orange),
                            const SizedBox(width: 8),
                            _buildStatChip('الإجمالي', totalDays.toString(), Colors.blue),
                          ],
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: attendanceRecords.map((record) {
                              final hasCheckOut = record['check_out_time'] != null;
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: hasCheckOut ? Colors.green.shade50 : Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: hasCheckOut ? Colors.green.shade200 : Colors.orange.shade200,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      hasCheckOut ? Icons.check_circle : Icons.pending,
                                      color: hasCheckOut ? Colors.green : Colors.orange,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            record['attendance_date'] ?? '',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Text(
                                                'دخول: ${record['check_in_time'] ?? '-'}',
                                                style: const TextStyle(fontSize: 12),
                                              ),
                                              const SizedBox(width: 16),
                                              Text(
                                                'خروج: ${record['check_out_time'] ?? 'لم يسجل'}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: hasCheckOut ? Colors.black : Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (record['name_circle'] != null)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 4),
                                              child: Text(
                                                'الحلقة: ${record['name_circle']}',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.blue.shade700,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
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
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class TeacherAttendanceReportController extends GetxController {
  var selectedDate = Rxn<DateTime>();
  var startDate = Rxn<DateTime>();
  var endDate = Rxn<DateTime>();
  var attendanceList = <Map<String, dynamic>>[].obs;
  var filteredAttendanceList = <Map<String, dynamic>>[].obs;
  var groupedAttendanceList = <Map<String, dynamic>>[].obs; // قائمة مجمعة حسب المعلم
  var loading = false.obs;
  var dataArg;
  
  // قوائم الفلاتر
  // var teachersList = <Map<String, dynamic>>[].obs;
  var circlesList = <Map<String, dynamic>>[].obs;
  
  // الفلاتر المختارة
  // var selectedTeacher = Rxn<String>();
  var selectedCircle = Rxn<String>();
  var useDateRange = false.obs;

  @override
  void onInit() {
    super.onInit();
    dataArg = Get.arguments;
    loadTeachersAndCircles();
  }
  
  Future<void> loadTeachersAndCircles() async {

      
      // جلب قائمة الحلقات
      final circlesResponse = await handleRequest(isLoading: RxBool(false), action: ()async {

        return postData(Linkapi.select_circle_for_center, {
          "responsible_user_id": dataArg?['id_user']?.toString(),
        }
        );

      },
      loadingMessage: "جلب قائمة الحلقات",
      immediateLoading: true
      );

      if (circlesResponse == null) {
        return;
      }

      if (circlesResponse is! Map) {
        mySnackbar("خطأ", "فشل الاتصال بالخادم");
        return;
      }
      
      if (circlesResponse['stat'] == 'ok') {
        circlesList.assignAll(List<Map<String, dynamic>>.from(circlesResponse['data']));
      }

  }
  
  void applyFilters() {
    if (attendanceList.isEmpty) {
      filteredAttendanceList.clear();
      groupedAttendanceList.clear();
      return;
    }
    
    var filtered = attendanceList.where((item) {
      // فلتر الأستاذ
      // if (selectedTeacher.value != null && selectedTeacher.value != 'all') {
      //   if (item['id_user'].toString() != selectedTeacher.value) {
      //     return false;
      //   }
      // }
      
      // فلتر الحلقة
      if (selectedCircle.value != null && selectedCircle.value != 'all') {
        if (item['id_circle'].toString() != selectedCircle.value) {
          return false;
        }
      }
      
      return true;
    }).toList();
    
    filteredAttendanceList.assignAll(filtered);
    _groupAttendanceByTeacher();
  }
  
  // دالة لتجميع البيانات حسب المعلم
  void _groupAttendanceByTeacher() {
    Map<String, Map<String, dynamic>> grouped = {};
    
    for (var item in filteredAttendanceList) {
      String teacherKey = item['username'] ?? 'غير محدد';
      
      if (!grouped.containsKey(teacherKey)) {
        grouped[teacherKey] = {
          'teacher_name': teacherKey,
          'teacher_id': item['id_user'],
          'attendance_records': <Map<String, dynamic>>[],
          'total_days': 0,
          'completed_days': 0,
          'incomplete_days': 0,
        };
      }
      
      grouped[teacherKey]!['attendance_records'].add(item);
      grouped[teacherKey]!['total_days']++;
      
      if (item['check_out_time'] != null) {
        grouped[teacherKey]!['completed_days']++;
      } else {
        grouped[teacherKey]!['incomplete_days']++;
      }
    }
    
    groupedAttendanceList.assignAll(grouped.values.toList());
  }
  
  void clearFilters() {
    selectedCircle.value = null;
    filteredAttendanceList.assignAll(attendanceList);
    _groupAttendanceByTeacher();
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

    Map<String, dynamic> requestData = {
      "id_user": dataArg?['id_user']?.toString(),
    };
    
    if (useDateRange.value) {
      requestData["start_date"] = DateFormat('yyyy-MM-dd').format(startDate.value!);
      requestData["end_date"] = DateFormat('yyyy-MM-dd').format(endDate.value!);
    } else {
      requestData["date"] = DateFormat('yyyy-MM-dd').format(selectedDate.value!);
    }

    var res = await handleRequest(
      isLoading: RxBool(false),
      useDialog: true,
      
      loadingMessage: "تحميل البيانات ..",
      immediateLoading: true,
      action: () async {
        return await postData(Linkapi.select_all_users_attendance_by_date, requestData);
      }
    );
    
    if (res == null) {
      attendanceList.clear();
      filteredAttendanceList.clear();
      groupedAttendanceList.clear();
      return;
    }
    
    if (res is! Map) {
      mySnackbar("خطأ", "فشل الاتصال بالخادم");
      attendanceList.clear();
      filteredAttendanceList.clear();
      groupedAttendanceList.clear();
      return;
    }
    
    if (res["stat"] == "ok") {
      if (res['data'] != null && res['data'] is List) {
        attendanceList.assignAll(List<Map<String, dynamic>>.from(res['data']));
        applyFilters();
        _groupAttendanceByTeacher();
      } else {
        attendanceList.clear();
        filteredAttendanceList.clear();
        groupedAttendanceList.clear();
        mySnackbar("تنبيه", "لا توجد بيانات حضور لهذا التاريخ");
      }
    } else if (res["stat"] != "no") {
      mySnackbar("خطأ", res["msg"] ?? "حدث خطأ أثناء جلب البيانات");
      attendanceList.clear();
      filteredAttendanceList.clear();
      groupedAttendanceList.clear();
    } else {
      attendanceList.clear();
      filteredAttendanceList.clear();
      groupedAttendanceList.clear();
      mySnackbar("تنبيه", "لا توجد بيانات حضور لهذا التاريخ");
    }
    selectedCircle.value="all";
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

      // تحميل شعار المؤسسة
      final ByteData logoData = await rootBundle.load('assets/icon/app_icon.png');
      final logoImage = pw.MemoryImage(logoData.buffer.asUint8List());

      final dateStr = selectedDate.value != null 
          ? DateFormat('yyyy-MM-dd').format(selectedDate.value!)
          : useDateRange.value && startDate.value != null && endDate.value != null
              ? 'من ${DateFormat('yyyy-MM-dd').format(startDate.value!)} إلى ${DateFormat('yyyy-MM-dd').format(endDate.value!)}'
              : '';

      // حساب الإحصائيات
      final completedAttendance = attendanceList.where((item) => item['check_out_time'] != null).length;
      final incompleteAttendance = attendanceList.length - completedAttendance;

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(20),
          textDirection: pw.TextDirection.rtl,
          theme: pw.ThemeData.withFont(base: arabicFont, bold: arabicFont),
          build: (context) {
            return [
              // رأس الصفحة مثل myreport.dart
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
                            'تقرير حضور وانصراف الأساتذة',
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
                            'مكتمل: $completedAttendance | غير مكتمل: $incompleteAttendance | الإجمالي: ${attendanceList.length}',
                            style: const pw.TextStyle(fontSize: 10),
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
                  headers: ['الحالة', 'وقت الخروج', 'وقت الدخول', 'الحلقة', 'الاسم'],
                  data: attendanceList.map((item) {
                    final hasCheckOut = item['check_out_time'] != null;
                    return [
                      hasCheckOut ? 'مكتمل' : 'غير مكتمل',
                      item['check_out_time'] ?? 'لم يسجل',
                      item['check_in_time'] ?? '-',
                      item['name_circle'] ?? '-',
                      item['username'] ?? '-',
                    ];
                  }).toList(),
                  border: pw.TableBorder.all(width: 0.5, color: PdfColors.blue300),
                  headerStyle: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                  headerDecoration: const pw.BoxDecoration(
                    color: PdfColors.blue,
                  ),
                  cellStyle: const pw.TextStyle(
                    fontSize: 9,
                    color: PdfColors.grey900,
                  ),
                  cellAlignment: pw.Alignment.center,
                  cellHeight: 25,
                  headerHeight: 30,
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
        name: 'تقرير_حضور_الأساتذة_$dateStr.pdf',
      );

      mySnackbar("نجح", "تم إنشاء التقرير بنجاح", type: "g");
    } catch (e) {
      print("PDF Error: $e");
      mySnackbar("خطأ", "حدث خطأ أثناء إنشاء التقرير: $e");
    }
  }

}
