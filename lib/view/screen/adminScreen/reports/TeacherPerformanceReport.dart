import 'package:althfeth/api/LinkApi.dart';
import 'package:althfeth/api/apiFunction.dart';
import 'package:althfeth/constants/function.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
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
              if (controller.loadingDate.value || controller.loadingDate2.value ) {
                return const Center(child: CircularProgressIndicator());
              }

              // if (controller.groupedPerformanceList.isEmpty) {
              //   return const Center(
              //     child: Text("لا توجد بيانات أداء لهذه الفترة"),
              //   );
              // }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.groupedPerformanceList.length,
                itemBuilder: (context, index) {
                  final item = controller.groupedPerformanceList[index];
                  final recitationCount = int.tryParse(item['recitation_count']?.toString() ?? '0') ?? 0;
                  final reviewCount = int.tryParse(item['review_count']?.toString() ?? '0') ?? 0;
                  final studentCount = int.tryParse(item['student_count']?.toString() ?? '0') ?? 0;
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ExpansionTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        '${item['teacher_name'] ?? 'غير محدد'} - ${item['circle_name'] ?? '-'}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                _buildStatChip('طلاب', studentCount.toString(), Colors.blue),
                                const SizedBox(width: 8),
                                _buildStatChip('تسميع', recitationCount.toString(), Colors.purple),
                                const SizedBox(width: 8),
                                _buildStatChip('مراجعة', reviewCount.toString(), Colors.teal),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _buildStatChip('حضور', (int.tryParse(item['attendance_count']?.toString() ?? '0') ?? 0).toString(), Colors.green),
                                const SizedBox(width: 8),
                                _buildStatChip('إجازة', (int.tryParse(item['leave_count']?.toString() ?? '0') ?? 0).toString(), Colors.orange),
                              ],
                            ),
                          ],
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              
                              // إحصائيات الحضور
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'إحصائيات الحضور',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.green.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    _buildStatRow(
                                      Icons.check_circle,
                                      'أيام الحضور',
                                      (int.tryParse(item['attendance_count']?.toString() ?? '0') ?? 0).toString(),
                                      Colors.green,
                                    ),
                                    const Divider(height: 16),
                                    _buildStatRow(
                                      Icons.event_busy,
                                      'أيام الإجازة',
                                      (int.tryParse(item['leave_count']?.toString() ?? '0') ?? 0).toString(),
                                      Colors.orange,
                                    ),
                                  ],
                                ),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // إحصائيات التدريس
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.purple.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.purple.withOpacity(0.3)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'إحصائيات التدريس',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.purple.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    _buildStatRow(
                                      Icons.group,
                                      'عدد الطلاب بالحلقة',
                                      studentCount.toString(),
                                      Colors.blue,
                                    ),
                                    const Divider(height: 16),
                                    _buildStatRow(
                                      Icons.record_voice_over,
                                      'عدد التسميعات',
                                      recitationCount.toString(),
                                      Colors.purple,
                                    ),
                                    const Divider(height: 16),
                                    _buildStatRow(
                                      Icons.refresh,
                                      'عدد المراجعات',
                                      reviewCount.toString(),
                                      Colors.teal,
                                    ),
                                  ],
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

  String _getMonthName(int month) {
    const months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    return months[month - 1];
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

class TeacherPerformanceReportController extends GetxController {
  var performanceList = <Map<String, dynamic>>[].obs;
  var groupedPerformanceList = <Map<String, dynamic>>[].obs; // قائمة مجمعة حسب المعلم
  // var loading = false.obs;
  var dataArg;
  
  var selectedMonth = Rx<int?>(DateTime.now().month);
  var selectedYear = Rx<int?>(DateTime.now().year);
  
  // إحصائيات إضافية
  var recitationStats = <Map<String, dynamic>>[].obs; // إحصائيات التسميع
  var reviewStats = <Map<String, dynamic>>[].obs; // إحصائيات المراجعة
  var studentCounts = <Map<String, dynamic>>[].obs; // عدد الطلاب لكل معلم

  @override
  void onInit() {
    super.onInit();
    dataArg = Get.arguments;
    loadData();
  }

  Future<void> loadData() async {
    if (selectedMonth.value == null || selectedYear.value == null) {
      mySnackbar("تنبيه", "الرجاء اختيار الشهر والسنة");
      return;
    }


      // جلب بيانات الأداء الأساسية
       _loadPerformanceData();
      
      // جلب جميع الإحصائيات الإضافية في استدعاء واحد
       _loadCompleteStats();
      
      // تجميع جميع البيانات



  }

  RxBool loadingDate=false.obs;
  RxBool loadingDate2=false.obs;
  Future<void> _loadPerformanceData() async {
    print("loadData");
    var res = await handleRequest(
      isLoading: loadingDate,
      useDialog: true,
      loadingMessage: "جلب بيانات الأداء الأساسية",
      immediateLoading: true,
      action: () async {
        return await postData(Linkapi.select_teacher_performance, {
          "month": selectedMonth.value.toString(),
          "year": selectedYear.value.toString(),
          "id_user": dataArg?['id_user']?.toString(),
        });
      }
    );
    
    if (res == null) return;
    
    if (res is! Map) {
      mySnackbar("خطأ", "فشل الاتصال بالخادم");
      return;
    }
    
    if (res["stat"] == "ok") {
      if (res['data'] != null && res['data'] is List) {
        performanceList.assignAll(List<Map<String, dynamic>>.from(res['data']));
      }
    } else if (res["stat"] != "no") {
      mySnackbar("خطأ", res["msg"] ?? "خطأ في جلب بيانات الأداء");
    } else {
      performanceList.clear();
    }
  }

  Future<void> _loadCompleteStats() async {
    var res = await handleRequest(
      isLoading: loadingDate2,
      useDialog: true,
      immediateLoading: true,
      loadingMessage: "جلب جميع الإحصائيات",
      action: () async {
        return await postData(Linkapi.select_teacher_complete_stats, {
          "month": selectedMonth.value.toString(),
          "year": selectedYear.value.toString(),
          "id_user": dataArg?['id_user']?.toString(),
        });
      }
    );
    
    if (res == null) {
      recitationStats.clear();
      reviewStats.clear();
      studentCounts.clear();
      return;
    }
    
    if (res is! Map) {
      mySnackbar("خطأ", "فشل الاتصال بالخادم");
      recitationStats.clear();
      reviewStats.clear();
      studentCounts.clear();
      return;
    }
    
    if (res["stat"] == "ok") {
      if (res['data'] != null && res['data'] is List) {
        // تحويل البيانات الشاملة إلى القوائم المنفصلة للتوافق مع الكود الحالي
        final completeData = List<Map<String, dynamic>>.from(res['data']);
        
        recitationStats.assignAll(completeData.map((item) => {
          'id_user': item['id_user']?.toString(),
          'username': item['teacher_name']?.toString() ?? item['username']?.toString(),
          'name_circle': item['name_circle']?.toString(),
          'recitation_count': int.tryParse(item['recitation_count']?.toString() ?? '0') ?? 0,
        }).toList());
        
        reviewStats.assignAll(completeData.map((item) => {
          'id_user': item['id_user']?.toString(),
          'username': item['teacher_name']?.toString() ?? item['username']?.toString(),
          'name_circle': item['name_circle']?.toString(),
          'review_count': int.tryParse(item['review_count']?.toString() ?? '0') ?? 0,
        }).toList());
        
        studentCounts.assignAll(completeData.map((item) => {
          'id_user': item['id_user']?.toString(),
          'username': item['teacher_name']?.toString() ?? item['username']?.toString(),
          'name_circle': item['name_circle']?.toString(),
          'student_count': int.tryParse(item['student_count']?.toString() ?? '0') ?? 0,
        }).toList());
      }
      _groupPerformanceData();

    } else if (res["stat"] != "no") {
      mySnackbar("خطأ", res["msg"] ?? "خطأ في جلب الإحصائيات");
      recitationStats.clear();
      reviewStats.clear();
      studentCounts.clear();
    } else {
      recitationStats.clear();
      reviewStats.clear();
      studentCounts.clear();
    }
  }

  void _groupPerformanceData() {
    Map<String, Map<String, dynamic>> grouped = {};
    
    // تجميع بيانات الأداء الأساسية حسب الأستاذ + الحلقة
    for (var performance in performanceList) {
      String teacherId = performance['id_user']?.toString() ?? 'unknown';
      String circleName = performance['name_circle']?.toString() ?? 'unknown';
      String uniqueKey = '${teacherId}_${circleName}'; // مفتاح فريد للأستاذ + الحلقة
      
      if (!grouped.containsKey(uniqueKey)) {
        grouped[uniqueKey] = {
          'teacher_id': performance['id_user']?.toString(),
          'teacher_name': performance['username']?.toString() ?? 'غير محدد',
          'circle_name': performance['name_circle']?.toString() ?? '-',
          'attendance_count': int.tryParse(performance['attendance_count']?.toString() ?? '0') ?? 0,
          'leave_count': int.tryParse(performance['leave_count']?.toString() ?? '0') ?? 0,
          'absence_count': int.tryParse(performance['absence_count']?.toString() ?? '0') ?? 0,
          'total_days': int.tryParse(performance['total_days']?.toString() ?? '0') ?? 0,
          'recitation_count': 0,
          'review_count': 0,
          'student_count': 0,
        };
      }
    }
    
    // إضافة إحصائيات التسميع حسب الأستاذ + الحلقة
    for (var recitation in recitationStats) {
      String teacherId = recitation['id_user']?.toString() ?? 'unknown';
      String circleName = recitation['name_circle']?.toString() ?? 'unknown';
      String uniqueKey = '${teacherId}_${circleName}';
      
      if (grouped.containsKey(uniqueKey)) {
        grouped[uniqueKey]!['recitation_count'] = int.tryParse(recitation['recitation_count']?.toString() ?? '0') ?? 0;
      }
    }
    
    // إضافة إحصائيات المراجعة حسب الأستاذ + الحلقة
    for (var review in reviewStats) {
      String teacherId = review['id_user']?.toString() ?? 'unknown';
      String circleName = review['name_circle']?.toString() ?? 'unknown';
      String uniqueKey = '${teacherId}_${circleName}';
      
      if (grouped.containsKey(uniqueKey)) {
        grouped[uniqueKey]!['review_count'] = int.tryParse(review['review_count']?.toString() ?? '0') ?? 0;
      }
    }
    
    // إضافة عدد الطلاب حسب الأستاذ + الحلقة
    for (var studentCount in studentCounts) {
      String teacherId = studentCount['id_user']?.toString() ?? 'unknown';
      String circleName = studentCount['name_circle']?.toString() ?? 'unknown';
      String uniqueKey = '${teacherId}_${circleName}';
      
      if (grouped.containsKey(uniqueKey)) {
        grouped[uniqueKey]!['student_count'] = int.tryParse(studentCount['student_count']?.toString() ?? '0') ?? 0;
      }
    }
    
    // ترتيب النتائج حسب اسم الأستاذ ثم اسم الحلقة
    var sortedList = grouped.values.toList();
    sortedList.sort((a, b) {
      int teacherComparison = (a['teacher_name'] ?? '').compareTo(b['teacher_name'] ?? '');
      if (teacherComparison != 0) {
        return teacherComparison;
      }
      return (a['circle_name'] ?? '').compareTo(b['circle_name'] ?? '');
    });
    
    groupedPerformanceList.assignAll(sortedList);
  }


  double calculateRate(dynamic count, dynamic total) {
    final numCount = int.tryParse(count?.toString() ?? '0') ?? 0;
    final numTotal = int.tryParse(total?.toString() ?? '0') ?? 0;
    
    if (numTotal == 0) return 0.0;
    return (numCount / numTotal) * 100.0;
  }
  
  Future<void> exportToPDF() async {
    if (groupedPerformanceList.isEmpty) {
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

      // حساب الإحصائيات الإجمالية
      final totalTeachers = groupedPerformanceList.length;
      final totalRecitations = groupedPerformanceList.fold<int>(0, (sum, item) => sum + (int.tryParse(item['recitation_count']?.toString() ?? '0') ?? 0));
      final totalReviews = groupedPerformanceList.fold<int>(0, (sum, item) => sum + (int.tryParse(item['review_count']?.toString() ?? '0') ?? 0));
      final totalStudents = groupedPerformanceList.fold<int>(0, (sum, item) => sum + (int.tryParse(item['student_count']?.toString() ?? '0') ?? 0));

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
                            'تقرير أداء الأساتذة',
                            style: pw.TextStyle(
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            'الشهر: ${_getMonthName(selectedMonth.value!)} ${selectedYear.value}',
                            style: const pw.TextStyle(fontSize: 11),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            'أساتذة: $totalTeachers | تسميعات: $totalRecitations | مراجعات: $totalReviews | طلاب: $totalStudents',
                            style: const pw.TextStyle(fontSize: 9),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            'الحلقات: ${groupedPerformanceList.map((item) => item['circle_name']).toSet().join(', ')}',
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
                  headers: ['الطلاب', 'المراجعة', 'التسميع', 'الإجازة', 'الحضور', 'الحلقة', 'الاسم'],
                  data: groupedPerformanceList.map((item) {
                    return [
                      '${int.tryParse(item['student_count']?.toString() ?? '0') ?? 0}',
                      '${int.tryParse(item['review_count']?.toString() ?? '0') ?? 0}',
                      '${int.tryParse(item['recitation_count']?.toString() ?? '0') ?? 0}',
                      '${int.tryParse(item['leave_count']?.toString() ?? '0') ?? 0}',
                      '${int.tryParse(item['attendance_count']?.toString() ?? '0') ?? 0}',
                      item['circle_name'] ?? '-',
                      item['teacher_name'] ?? '-',
                    ];
                  }).toList(),
                  border: pw.TableBorder.all(width: 0.5, color: PdfColors.green300),
                  headerStyle: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                  headerDecoration: const pw.BoxDecoration(
                    color: PdfColors.green,
                  ),
                  cellStyle: const pw.TextStyle(
                    fontSize: 8,
                    color: PdfColors.grey900,
                  ),
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
        name: 'تقرير_أداء_الأساتذة_${_getMonthName(selectedMonth.value!)}_${selectedYear.value}.pdf',
      );

      mySnackbar("نجح", "تم إنشاء التقرير بنجاح", type: "g");
    } catch (e) {
      print("PDF Error: $e");
      mySnackbar("خطأ", "حدث خطأ أثناء إنشاء التقرير: $e");
    }
  }

  String _getMonthName(int month) {
    const months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    return months[month - 1];
  }
}
