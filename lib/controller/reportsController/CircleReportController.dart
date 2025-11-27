import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../../api/LinkApi.dart';
import '../../api/apiFunction.dart';
import '../../constants/function.dart';

class CircleReportController extends GetxController {
  var data;
  
  // معلومات التقرير
  RxString reportType = ''.obs;
  RxString reportTitle = ''.obs;
  
  // التواريخ
  Rx<DateTime> startDate = DateTime.now().subtract(const Duration(days: 30)).obs;
  Rx<DateTime> endDate = DateTime.now().obs;
  
  // البيانات
  RxList<Map<String, dynamic>> reportData = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> groupedData = <Map<String, dynamic>>[].obs;
  RxBool isLoading = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    data = Get.arguments;
    
    if (data != null && data is Map) {
      reportType.value = data['report_type'] ?? '';
      reportTitle.value = data['report_title'] ?? 'التقرير';
    }
    
    print("onInit data=====${data}");
    
    // جلب التقرير تلقائياً
    fetchReport();
  }
  
  // اختيار تاريخ البداية
  Future<void> selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: startDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('en', 'US'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != startDate.value) {
      startDate.value = picked;
      
      // التأكد من أن تاريخ البداية قبل تاريخ النهاية
      if (startDate.value.isAfter(endDate.value)) {
        endDate.value = startDate.value;
      }
    }
  }
  
  // اختيار تاريخ النهاية
  Future<void> selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: endDate.value,
      firstDate: startDate.value,
      lastDate: DateTime.now(),
      locale: const Locale('en', 'US'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != endDate.value) {
      endDate.value = picked;
    }
  }
  
  // جلب التقرير من API
  Future<void> fetchReport() async {
    isLoading.value = true;
    reportData.clear();
    
    try {
      String apiEndpoint;
      Map<String, dynamic> requestData = {
        'start_date': DateFormat('yyyy-MM-dd', 'en').format(startDate.value),
        'end_date': DateFormat('yyyy-MM-dd', 'en').format(endDate.value),
      };
      
      // الحصول على id_circle من data
      String? idCircle = data?['id_circle']?.toString();
      
      if (idCircle == null || idCircle.isEmpty) {
        mySnackbar("خطأ", "لم يتم تحديد الحلقة");
        isLoading.value = false;
        return;
      }
      
      // تحديد الـ API حسب نوع التقرير
      if (reportType.value == 'daily_report') {
        apiEndpoint = Linkapi.getCircleDailyReports;
        requestData['id_circle'] = idCircle;
      } else if (reportType.value == 'review') {
        apiEndpoint = Linkapi.getCircleReviews;
        requestData['id_circle'] = idCircle;
      } else if (reportType.value == 'attendance') {
        apiEndpoint = Linkapi.getCircleAttendance;
        requestData['id_circle'] = idCircle;
      } else {
        mySnackbar("خطأ", "نوع التقرير غير معروف");
        isLoading.value = false;
        return;
      }
      
      print("requestData=====${requestData}");
      final res = await postData(apiEndpoint, requestData);
      print("res=====${res}");
      
      if (res != null && res is Map) {
        if (res["stat"] == "ok") {
          reportData.assignAll(List<Map<String, dynamic>>.from(res["data"] ?? []));
          
          if (reportData.isEmpty) {
            mySnackbar("تنبيه", "لا توجد بيانات للفترة المحددة");
          } else {
            // تجميع البيانات حسب الطالب
            _groupDataByStudent();
          }
        } else if (res["stat"] == "no") {
          mySnackbar("تنبيه", "لا توجد بيانات");
        } else if (res["stat"] == "error") {
          mySnackbar("خطأ", res["msg"] ?? "حدث خطأ");
        }
      } else {
        mySnackbar("خطأ", "فشل الاتصال بالخادم");
      }
    } catch (e) {
      print("e.toString()========${e.toString()}");
      mySnackbar("خطأ", "حدث خطأ: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }
  
  // إنشاء PDF
  Future<void> generatePDF() async {
    if (groupedData.isEmpty) {
      mySnackbar("تنبيه", "لا توجد بيانات لطباعتها");
      return;
    }
    
    try {
      final pdf = pw.Document();
      
      // تحميل خط عربي من assets
      final fontData = await rootBundle.load('assets/fonts/Amiri-Bold.ttf');
      final arabicFont = pw.Font.ttf(fontData);
      
      // تحديد لون حسب نوع التقرير
      PdfColor reportColor;
      if (reportType.value == 'daily_report') {
        reportColor = PdfColor.fromHex('#2196F3'); // أزرق
      } else if (reportType.value == 'review') {
        reportColor = PdfColor.fromHex('#4CAF50'); // أخضر
      } else {
        reportColor = PdfColor.fromHex('#FF9800'); // برتقالي
      }
      
      // تحميل شعار المؤسسة
      final ByteData logoData = await rootBundle.load('assets/icon/app_icon.png');
      final logoImage = pw.MemoryImage(logoData.buffer.asUint8List());
      
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(20),
          textDirection: pw.TextDirection.ltr,
          theme: pw.ThemeData.withFont(base: arabicFont, bold: arabicFont),
          build: (context) {
            return [
              // ترويسة مثل myreport.dart
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 10),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // الجانب الأيسر: اسم التقرير + التفاصيل
                    pw.Directionality(
                      textDirection: pw.TextDirection.rtl,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            reportTitle.value,
                            style: pw.TextStyle(
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            'من ${DateFormat('yyyy-MM-dd', 'en').format(startDate.value)} إلى ${DateFormat('yyyy-MM-dd', 'en').format(endDate.value)}',
                            style: const pw.TextStyle(fontSize: 11),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            'عدد الطلاب: ${groupedData.length} | إجمالي السجلات: ${reportData.length}',
                            style: const pw.TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                    // الجانب الأيمن: الشعار + المؤسسة
                    pw.Row(
                      children: [
                        pw.Directionality(
                          textDirection: pw.TextDirection.rtl,
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.end,
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
                        pw.SizedBox(width: 8),
                        pw.Container(
                          width: 45,
                          height: 45,
                          child: pw.Image(logoImage),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Divider(thickness: 1.5),
              pw.SizedBox(height: 15),
              
              // Table بنفس نسق AbsenceReport
              if (reportType.value == 'attendance') ...[
                // جدول خاص بتقرير الحضور - صف واحد لكل طالب
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300),
                  children: [
                    // Header Row
                    pw.TableRow(
                      decoration: pw.BoxDecoration(
                        color: reportColor.shade(0.8),
                      ),
                      children: [
                        _buildTableCell('الإجمالي', isHeader: true, color: reportColor),
                        _buildTableCell('غياب بعذر', isHeader: true, color: reportColor),
                        _buildTableCell('غياب بدون عذر', isHeader: true, color: reportColor),
                        _buildTableCell('الحضور', isHeader: true, color: reportColor),
                        _buildTableCell('الطالب', isHeader: true, color: reportColor),
                      ],
                    ),
                    
                    // Data Rows - صف واحد لكل طالب
                    ...groupedData.map((studentData) {
                      final records = List<Map<String, dynamic>>.from(studentData['records'] ?? []);
                      
                      // حساب الحضور والغياب
                      int present = 0;
                      int absent = 0;
                      int excused = 0;
                      
                      for (var record in records) {
                        final status = record['status'];
                        if (status == 1 || status == '1') {
                          present++;
                        } else if (status == 2 || status == '2') {
                          excused++;
                        } else {
                          absent++;
                        }
                      }
                      
                      final total = records.length;
                      
                      return pw.TableRow(
                        children: [
                          _buildTableCell(total.toString()),
                          _buildTableCell(excused.toString()),
                          _buildTableCell(absent.toString()),
                          _buildTableCell(present.toString()),
                          _buildTableCell(studentData['name_student'] ?? '-'),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ] else ...[
                // جدول التسميع والمراجعة
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300),
                  children: [
                    // Header Row
                    pw.TableRow(
                      decoration: pw.BoxDecoration(
                        color: reportColor.shade(0.8),
                      ),
                      children: [
                        _buildTableCell('التاريخ', isHeader: true, color: reportColor),
                        _buildTableCell('التقييم', isHeader: true, color: reportColor),
                        _buildTableCell(reportType.value == 'daily_report' ? 'التسميع' : 'المراجعة', isHeader: true, color: reportColor),
                        _buildTableCell('الطالب', isHeader: true, color: reportColor),
                      ],
                    ),
                    
                    // Data Rows - كل سجل في صف منفصل
                    ...groupedData.expand((studentData) {
                      final records = List<Map<String, dynamic>>.from(studentData['records'] ?? []);
                      return records.map((record) {
                        return pw.TableRow(
                          children: [
                            _buildTableCell(record['date'] ?? '-'),
                            _buildTableCell(record['evaluation_name'] != null 
                                ? '${record['evaluation_name']} (${record['mark'] ?? '-'})'
                                : record['mark']?.toString() ?? '-'),
                            _buildTableCell(record['recitation'] ?? record['review_content'] ?? '-'),
                            _buildTableCell(studentData['name_student'] ?? '-'),
                          ],
                        );
                      });
                    }).toList(),
                  ],
                ),
              ],
            ];
          },
        ),
      );
      
      // طباعة PDF
      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
        name: '${reportTitle.value}.pdf',
      );
      
      mySnackbar("نجح", "تم إنشاء التقرير بنجاح", type: "g");
    } catch (e) {
      mySnackbar("خطأ", "حدث خطأ أثناء إنشاء التقرير: $e");
    }
  }
  
  // بناء خلية الجدول بنفس نسق AbsenceReport
  pw.Widget _buildTableCell(String text, {bool isHeader = false, PdfColor? color}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Directionality(
        textDirection: pw.TextDirection.rtl,
        child: pw.Text(
          text,
          style: pw.TextStyle(
            fontSize: isHeader ? 11 : 9,
            fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: isHeader ? (color?.shade(0.2) ?? PdfColors.black) : PdfColors.black,
          ),
          textAlign: pw.TextAlign.center,
        ),
      ),
    );
  }
  
  // تجميع البيانات حسب الطالب
  void _groupDataByStudent() {
    Map<String, Map<String, dynamic>> studentsMap = {};
    
    for (var record in reportData) {
      String studentId = record['id_student'].toString();
      
      if (!studentsMap.containsKey(studentId)) {
        studentsMap[studentId] = {
          'id_student': record['id_student'],
          'name_student': record['name_student'],
          'records': <Map<String, dynamic>>[],
        };
      }
      
      studentsMap[studentId]!['records'].add(record);
    }
    
    groupedData.assignAll(studentsMap.values.toList());
    print("Grouped ${groupedData.length} students from ${reportData.length} records");
  }
}
