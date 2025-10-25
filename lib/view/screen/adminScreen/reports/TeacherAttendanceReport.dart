import 'package:althfeth/api/LinkApi.dart';
import 'package:althfeth/api/apiFunction.dart';
import 'package:althfeth/constants/color.dart';
import 'package:althfeth/constants/function.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class TeacherAttendanceReport extends StatelessWidget {
  final TeacherAttendanceReportController controller = Get.put(TeacherAttendanceReportController());

  @override
  Widget build(BuildContext context) {
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
      body: Column(
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
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: "الأستاذ",
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          value: controller.selectedTeacher.value,
                          items: [
                            const DropdownMenuItem(value: 'all', child: Text("الكل")),
                            ...controller.teachersList.map((teacher) {
                              return DropdownMenuItem(
                                value: teacher['id_user'].toString(),
                                child: Text(teacher['username'] ?? ''),
                              );
                            }).toList(),
                          ],
                          onChanged: (val) {
                            controller.selectedTeacher.value = val;
                            controller.applyFilters();
                          },
                        ),
                      ),
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
          Expanded(
            child: Obx(() {
              if (controller.loading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (controller.filteredAttendanceList.isEmpty) {
                return const Center(
                  child: Text("لا توجد بيانات"),
                );
              }
              
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.filteredAttendanceList.length,
                itemBuilder: (context, index) {
                  final item = controller.filteredAttendanceList[index];
                  final hasCheckOut = item['check_out_time'] != null;
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: CircleAvatar(
                        backgroundColor: hasCheckOut ? Colors.green : Colors.orange,
                        child: Icon(
                          hasCheckOut ? Icons.check_circle : Icons.pending,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        item['username'] ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          // اسم الحلقة
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.group, size: 14, color: Colors.blue),
                                const SizedBox(width: 4),
                                Text(
                                  item['name_circle'] ?? 'غير محدد',
                                  style: TextStyle(
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          // وقت الدخول
                          Row(
                            children: [
                              const Icon(Icons.login, size: 16, color: Colors.green),
                              const SizedBox(width: 4),
                              Text(
                                'دخول: ${item['check_in_time'] ?? '-'}',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // وقت الخروج
                          Row(
                            children: [
                              Icon(
                                Icons.logout,
                                size: 16,
                                color: hasCheckOut ? Colors.red : Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'خروج: ${item['check_out_time'] ?? 'لم يسجل خروج'}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: hasCheckOut ? Colors.black : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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
}

class TeacherAttendanceReportController extends GetxController {
  var selectedDate = Rxn<DateTime>();
  var startDate = Rxn<DateTime>();
  var endDate = Rxn<DateTime>();
  var attendanceList = <Map<String, dynamic>>[].obs;
  var filteredAttendanceList = <Map<String, dynamic>>[].obs;
  var loading = false.obs;
  var dataArg;
  
  // قوائم الفلاتر
  var teachersList = <Map<String, dynamic>>[].obs;
  var circlesList = <Map<String, dynamic>>[].obs;
  
  // الفلاتر المختارة
  var selectedTeacher = Rxn<String>();
  var selectedCircle = Rxn<String>();
  var useDateRange = false.obs;

  @override
  void onInit() {
    super.onInit();
    dataArg = Get.arguments;
    loadTeachersAndCircles();
  }
  
  Future<void> loadTeachersAndCircles() async {
    try {
      // جلب قائمة الأساتذة
      final teachersResponse = await postData(Linkapi.select_users, {
        "id_user": dataArg?['id_user']?.toString(),
      });
      
      if (teachersResponse['stat'] == 'ok') {
        teachersList.assignAll(List<Map<String, dynamic>>.from(teachersResponse['data']));
      }
      
      // جلب قائمة الحلقات
      final circlesResponse = await postData(Linkapi.select_circle_for_center, {
        "responsible_user_id": dataArg?['id_user']?.toString(),
      });
      
      if (circlesResponse['stat'] == 'ok') {
        circlesList.assignAll(List<Map<String, dynamic>>.from(circlesResponse['data']));
      }
    } catch (e) {
      print("Error loading filters: $e");
    }
  }
  
  void applyFilters() {
    if (attendanceList.isEmpty) {
      filteredAttendanceList.clear();
      return;
    }
    
    var filtered = attendanceList.where((item) {
      // فلتر الأستاذ
      if (selectedTeacher.value != null && selectedTeacher.value != 'all') {
        if (item['id_user'].toString() != selectedTeacher.value) {
          return false;
        }
      }
      
      // فلتر الحلقة
      if (selectedCircle.value != null && selectedCircle.value != 'all') {
        if (item['id_circle'].toString() != selectedCircle.value) {
          return false;
        }
      }
      
      return true;
    }).toList();
    
    filteredAttendanceList.assignAll(filtered);
  }
  
  void clearFilters() {
    selectedTeacher.value = null;
    selectedCircle.value = null;
    filteredAttendanceList.assignAll(attendanceList);
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

    loading.value = true;
    try {
      print("Sending id_user: ${dataArg?['id_user']}");
      
      Map<String, dynamic> requestData = {
        "id_user": dataArg?['id_user']?.toString(),
      };
      
      if (useDateRange.value) {
        requestData["start_date"] = DateFormat('yyyy-MM-dd').format(startDate.value!);
        requestData["end_date"] = DateFormat('yyyy-MM-dd').format(endDate.value!);
      } else {
        requestData["date"] = DateFormat('yyyy-MM-dd').format(selectedDate.value!);
      }
      
      final response = await postData(Linkapi.select_all_users_attendance_by_date, requestData);

      print("Response: $response"); // للتأكد من الاستجابة

      if (response == null) {
        mySnackbar("خطأ", "فشل الاتصال بالخادم");
        attendanceList.clear();
        return;
      }

      if (response is! Map) {
        mySnackbar("خطأ", "استجابة غير صحيحة من الخادم");
        attendanceList.clear();
        return;
      }

      if (response['stat'] == 'ok') {
        if (response['data'] != null && response['data'] is List) {
          attendanceList.assignAll(List<Map<String, dynamic>>.from(response['data']));
          
          filteredAttendanceList.assignAll(attendanceList);
          mySnackbar("نجح", "تم تحميل ${attendanceList.length} سجل", type: "g");
        } else {
          attendanceList.clear();
          mySnackbar("تنبيه", "لا توجد بيانات");
        }
      } else if (response['stat'] == 'no' || response['stat'] == 'No_record_today') {
        attendanceList.clear();
        mySnackbar("تنبيه", "لا توجد سجلات حضور لهذا التاريخ");
      } else {
        attendanceList.clear();
        mySnackbar("خطأ", response['msg'] ?? "حدث خطأ");
      }
    } catch (e) {
      print("Error: $e");
      mySnackbar("خطأ", "حدث خطأ: $e");
      attendanceList.clear();
    } finally {
      loading.value = false;
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

      final dateStr = selectedDate.value != null 
          ? DateFormat('yyyy-MM-dd').format(selectedDate.value!)
          : '';

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          textDirection: pw.TextDirection.rtl,
          theme: pw.ThemeData.withFont(base: arabicFont, bold: arabicFont),
          build: (context) {
            return [
              // Header
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#2196F3'),
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'تقرير حضور وانصراف الأساتذة',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      'التاريخ: $dateStr',
                      style: const pw.TextStyle(fontSize: 16, color: PdfColors.white),
                    ),
                    pw.Text(
                      'عدد السجلات: ${attendanceList.length}',
                      style: const pw.TextStyle(fontSize: 14, color: PdfColors.white),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Table
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                children: [
                  // Header Row
                  pw.TableRow(
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('#E3F2FD'),
                    ),
                    children: [
                      _buildTableCell('الاسم', isHeader: true),
                      _buildTableCell('الحلقة', isHeader: true),
                      _buildTableCell('وقت الدخول', isHeader: true),
                      _buildTableCell('وقت الخروج', isHeader: true),
                      _buildTableCell('الحالة', isHeader: true),
                    ],
                  ),
                  // Data Rows
                  ...attendanceList.map((item) {
                    final hasCheckOut = item['check_out_time'] != null;
                    return pw.TableRow(
                      children: [
                        _buildTableCell(item['username'] ?? '-'),
                        _buildTableCell(item['name_circle'] ?? '-'),
                        _buildTableCell(item['check_in_time'] ?? '-'),
                        _buildTableCell(item['check_out_time'] ?? 'لم يسجل'),
                        _buildTableCell(
                          hasCheckOut ? 'مكتمل' : 'غير مكتمل',
                          color: hasCheckOut ? PdfColors.green : PdfColors.orange,
                        ),
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
        name: 'تقرير_حضور_الأساتذة_$dateStr.pdf',
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
          color: color ?? (isHeader ? PdfColor.fromHex('#1976D2') : PdfColors.black),
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }
}
