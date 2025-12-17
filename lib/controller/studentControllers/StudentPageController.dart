import 'package:althfeth/view/screen/login.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';

import '../../api/LinkApi.dart';
import '../../api/apiFunction.dart';
import '../../constants/function.dart';
import '../../constants/myreport.dart';



class StudentPageController extends GetxController{

  var student;
  @override
  void onInit() {
    student=Get.arguments;

  }

  List<Map<String,dynamic>> daily_report=<Map<String,dynamic>>[];
  List<Map<String,dynamic>> review_report=<Map<String,dynamic>>[];
  List<Map<String,dynamic>> absences=<Map<String,dynamic>>[];
  List<Map<String,dynamic>> exam_results=<Map<String,dynamic>>[];

  // ✅ دالة عامة لاختيار الفترة الزمنية
  Future<Map<String, DateTime?>?> showDateRangeDialog() async {
    DateTime? startDate;
    DateTime? endDate;
    
    final result = await Get.dialog<bool>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: StatefulBuilder(
          builder: (context, setState) {
            // ✅ حساب العرض المناسب حسب حجم الشاشة
            final screenWidth = MediaQuery.of(context).size.width;
            final dialogWidth = screenWidth > 600 ? 500.0 : screenWidth * 0.9;
            final theme = Theme.of(context);
            final primaryColor = theme.colorScheme.primary;
            
            return Container(
              width: dialogWidth,
              constraints: const BoxConstraints(maxWidth: 500),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    primaryColor.withOpacity(0.05),
                  ],
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ✅ Header فخم
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            primaryColor,
                            primaryColor.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.date_range,
                            color: Colors.white,
                            size: 40,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "اختر الفترة الزمنية",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "حدد نطاق التواريخ لتصفية التقرير",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // ✅ Content
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          // تاريخ البداية
                          _buildDateCard(
                            context: context,
                            icon: Icons.calendar_today,
                            iconColor: primaryColor,
                            title: "من تاريخ",
                            date: startDate,
                            hint: "اختر تاريخ البداية",
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: startDate ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                setState(() => startDate = picked);
                              }
                            },
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // تاريخ النهاية
                          _buildDateCard(
                            context: context,
                            icon: Icons.event,
                            iconColor: theme.colorScheme.secondary,
                            title: "إلى تاريخ",
                            date: endDate,
                            hint: "اختر تاريخ النهاية",
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: endDate ?? startDate ?? DateTime.now(),
                                firstDate: startDate ?? DateTime(2020),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                setState(() => endDate = picked);
                              }
                            },
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // زر إلغاء الفلترة
                          OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                startDate = null;
                                endDate = null;
                              });
                            },
                            icon: const Icon(Icons.clear_all, size: 20),
                            label: const Text("إلغاء الفلترة (عرض الكل)"),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.orange,
                              side: const BorderSide(color: Colors.orange),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // ✅ أزرار الإجراءات
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Get.back(result: false),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.grey.shade700,
                                    side: BorderSide(color: Colors.grey.shade300),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    "إلغاء",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => Get.back(result: true),
                                  icon: const Icon(Icons.picture_as_pdf, size: 20),
                                  label: const Text(
                                    "عرض التقرير",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      barrierDismissible: true,
    );
    
    if (result == true) {
      return {'startDate': startDate, 'endDate': endDate};
    }
    return null;
  }

  // ✅ دالة مساعدة لبناء كارت التاريخ
  Widget _buildDateCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required DateTime? date,
    required String hint,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: date != null ? iconColor.withOpacity(0.5) : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date != null
                        ? "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}"
                        : hint,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: date != null ? Colors.black87 : Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  // ✅ دالة لفلترة البيانات حسب التاريخ
  List<Map<String, dynamic>> filterByDateRange(
    List<Map<String, dynamic>> data,
    DateTime? startDate,
    DateTime? endDate,
  ) {
    if (startDate == null && endDate == null) {
      return data; // لا فلترة
    }
    
    return data.where((item) {
      if (item['date'] == null) return false;
      
      try {
        final itemDate = DateTime.parse(item['date'].toString().split(' ')[0]);
        
        if (startDate != null && itemDate.isBefore(startDate)) {
          return false;
        }
        
        if (endDate != null && itemDate.isAfter(endDate.add(const Duration(days: 1)))) {
          return false;
        }
        
        return true;
      } catch (e) {
        return false;
      }
    }).toList();
  }

  Future select_daily_report() async {
    final res = await handleRequest<dynamic>(
      isLoading: RxBool(false),
      loadingMessage: "جاري جلب تقرير التسميع...",
      useDialog: true,
      immediateLoading: true,
      action: () async {
        return await postData(Linkapi.select_daily_report, {"id_student": student["id_student"]});
      },
    );
    if (res == null) return;
    if (res is! Map) {
      mySnackbar("خطأ", "فشل الاتصال بالخادم");
      return;
    }
    if (res["stat"] == "ok") {
      daily_report.assignAll(List<Map<String, dynamic>>.from(res["daily_report"]));
      await showDaily_report();
    } else if (res["stat"] == "no") {
      String errorMsg = res["msg"] ?? "لا يوجد سجلات سابقة للطالب";
      mySnackbar("تنبيه", errorMsg);
    } else {
      String errorMsg = res["msg"] ?? "حصل خطأ في جلب التقرير";
      mySnackbar("خطأ", errorMsg);
    }

  }
  Future select_review_report() async {
    final res = await handleRequest<dynamic>(
      isLoading: RxBool(false),
      loadingMessage: "جاري جلب تقرير المراجعة...",
      useDialog: true,
      immediateLoading: true,
      action: () async {
        return await postData(Linkapi.select_review_report, {"id_student": student["id_student"]});
      },
    );
    if (res == null) return;
    if (res is! Map) {
      mySnackbar("خطأ", "فشل الاتصال بالخادم");
      return;
    }
    if (res["stat"] == "ok") {
      review_report.assignAll(List<Map<String, dynamic>>.from(res["reviews"]));
      await showReview_report();
    } else if (res["stat"] == "no") {
      String errorMsg = res["msg"] ?? "لا يوجد سجلات سابقة للطالب";
      mySnackbar("تنبيه", errorMsg);
    } else {
      String errorMsg = res["msg"] ?? "حصل خطأ في جلب التقرير";
      mySnackbar("خطأ", errorMsg);
    }
  }
  Future select_absence_report() async {
    final res = await handleRequest<dynamic>(
      isLoading: RxBool(false),
      loadingMessage: "جاري جلب تقرير الغياب...",
      useDialog: true,
      immediateLoading: true,
      action: () async {
        return await postData(Linkapi.select_absence_report, {"id_student": student["id_student"]});
      },
    );
    if (res == null) return;
    if (res is! Map) {
      mySnackbar("خطأ", "فشل الاتصال بالخادم");
      return;
    }
    if (res["stat"] == "ok") {
      absences.assignAll(List<Map<String, dynamic>>.from(res["attendance"]));
      await showAbsencesReport();
    } else if (res["stat"] == "no") {
      String errorMsg = res["msg"] ?? "لا يوجد غيابات للطالب";
      mySnackbar("تنبيه", errorMsg);
    } else {
      String errorMsg = res["msg"] ?? "حصل خطأ في جلب التقرير";
      mySnackbar("خطأ", errorMsg);
    }
  }



  Future showDaily_report()async{
    // ✅ عرض dialog اختيار الفترة
    final dateRange = await showDateRangeDialog();
    if (dateRange == null) return; // المستخدم ألغى
    
    // ✅ فلترة البيانات
    final filteredData = filterByDateRange(
      daily_report,
      dateRange['startDate'],
      dateRange['endDate'],
    );
    
    if (filteredData.isEmpty) {
      mySnackbar("تنبيه", "لا توجد بيانات في الفترة المحددة");
      return;
    }
    
    final headers =[
      'التاريخ',
      'المرحلة',
      'المستوى',
      'إلى سورة',
      'من سورة',
      'اسم استاذ الحلقة',
      'اسم الحلقة',
    ];
    final rows = filteredData.map((r) => [
      (r['date']?.split(' ')[0] ?? 'غير متوفر').toString(),
      (r['name_stages'] ?? 'غير متوفر').toString(),
      (r['name_level'] ?? 'غير متوفر').toString(),
      // ✅ دمج السورة والآية في عمود واحد
      r['to_soura_name'] != null 
          ? '${r['to_soura_name']} (${r['to_id_aya']?.toString() ?? '0'})'
          : 'غير متوفر',
      r['from_soura_name'] != null 
          ? '${r['from_soura_name']} (${r['from_id_aya']?.toString() ?? '0'})'
          : 'غير متوفر',
      (r['username'] ?? 'غير متوفر').toString(),
      (r['name_circle'] ?? 'غير متوفر').toString(),
    ]).toList();
    await  generateStandardPdfReport(
      title: "تقرير التسميع",
      subTitle: "${daily_report.first['name_student']}",
      headers:headers,
      rows: rows,
    );

  }
  Future showReview_report()async{
    // ✅ عرض dialog اختيار الفترة
    final dateRange = await showDateRangeDialog();
    if (dateRange == null) return; // المستخدم ألغى
    
    // ✅ فلترة البيانات
    final filteredData = filterByDateRange(
      review_report,
      dateRange['startDate'],
      dateRange['endDate'],
    );
    
    if (filteredData.isEmpty) {
      mySnackbar("تنبيه", "لا توجد بيانات في الفترة المحددة");
      return;
    }
    
    final headers =[
      'التاريخ',
      'المرحلة',
      'المستوى',
      'إلى سورة',
      'من سورة',
      'اسم استاذ الحلقة',
      'اسم الحلقة',
    ];
    final rows = filteredData.map((r) => [
      (r['date']?.split(' ')[0] ?? 'غير متوفر').toString(),
      (r['name_stages'] ?? 'غير متوفر').toString(),
      (r['name_level'] ?? 'غير متوفر').toString(),
      // ✅ دمج السورة والآية في عمود واحد
      r['to_soura_name'] != null 
          ? '${r['to_soura_name']} (${r['to_id_aya']?.toString() ?? '0'})'
          : 'غير متوفر',
      r['from_soura_name'] != null 
          ? '${r['from_soura_name']} (${r['from_id_aya']?.toString() ?? '0'})'
          : 'غير متوفر',
      (r['username'] ?? 'غير متوفر').toString(),
      (r['name_circle'] ?? 'غير متوفر').toString(),
    ]).toList();
    await  generateStandardPdfReport(
      title: "تقرير المراجعة",
      subTitle: "${review_report.first['name_student']}",
      headers:headers,
      rows: rows,
    );

  }
  Future showAbsencesReport()async{
    // ✅ عرض dialog اختيار الفترة
    final dateRange = await showDateRangeDialog();
    if (dateRange == null) return; // المستخدم ألغى
    
    // ✅ فلترة البيانات
    final filteredData = filterByDateRange(
      absences,
      dateRange['startDate'],
      dateRange['endDate'],
    );
    
    if (filteredData.isEmpty) {
      mySnackbar("تنبيه", "لا توجد بيانات في الفترة المحددة");
      return;
    }
    
    // ✅ الأعمدة الجديدة: نوع الغياب، سبب الغياب، التاريخ (مقلوبة)
    final headers = ["نوع الغياب", "سبب الغياب", "التاريخ"];
    final absencesRows = filteredData.map((a) {
      // تحديد نوع الغياب من absence_type أو من status
      String absenceType = a["absence_type"] ?? 
                          (a["status"] == 2 || a["status"] == "2" 
                            ? "غياب بعذر" 
                            : "غياب بدون عذر");
      
      return [
        absenceType,
        (a["notes"] ?? "—").toString(),
        (a["date"]?.toString().split(' ')[0] ?? "—").toString(),
      ];
    }).toList();

    // 🔹 حساب إجمالي الغياب بنوعيه
    int totalWithExcuse = filteredData.where((a) => 
      a["status"] == 2 || a["status"] == "2" || a["absence_type"] == "غياب بعذر"
    ).length;
    int totalWithoutExcuse = filteredData.where((a) => 
      a["status"] == 0 || a["status"] == "0" || a["absence_type"] == "غياب بدون عذر"
    ).length;
    
    // إضافة صفوف الإجمالي
    absencesRows.add([
      "إجمالي",
      "غياب بعذر: $totalWithExcuse | بدون عذر: $totalWithoutExcuse",
      "المجموع: ${filteredData.length}",
    ]);
    
    await generateStandardPdfReport(
      title: "تقرير الغياب",
      subTitle: "${student["name_student"]}",
      headers: headers,
      rows: absencesRows,
    );
  }

  // دالة لجلب نتائج الاختبارات من الزيارات الفنية
  Future select_exam_results() async {
    final res = await handleRequest<dynamic>(
      isLoading: RxBool(false),
      loadingMessage: "جاري جلب نتائج الاختبارات...",
      useDialog: true,
      immediateLoading: true,
      action: () async {
        return await postData(Linkapi.select_student_exam_results, {
          "id_student": student["id_student"],
        });
      },
    );
    
    if (res == null) return;
    if (res is! Map) {
      mySnackbar("خطأ", "فشل الاتصال بالخادم");
      return;
    }
    
    if (res["stat"] == "ok") {
      exam_results.assignAll(List<Map<String, dynamic>>.from(res["data"]));
      await showExamResults();
    } else if (res["stat"] == "no") {
      String errorMsg = res["msg"] ?? "لا توجد نتائج اختبارات للطالب";
      mySnackbar("تنبيه", errorMsg);
    } else {
      String errorMsg = res["msg"] ?? "حصل خطأ في جلب النتائج";
      mySnackbar("خطأ", errorMsg);
    }
  }

  Future showExamResults() async {
    if (exam_results.isEmpty) {
      mySnackbar("تنبيه", "لا توجد نتائج لعرضها");
      return;
    }

    // ✅ عرض dialog اختيار الفترة
    final dateRange = await showDateRangeDialog();
    if (dateRange == null) return; // المستخدم ألغى
    
    // ✅ فلترة البيانات
    final filteredData = filterByDateRange(
      exam_results,
      dateRange['startDate'],
      dateRange['endDate'],
    );
    
    if (filteredData.isEmpty) {
      mySnackbar("تنبيه", "لا توجد بيانات في الفترة المحددة");
      return;
    }

    // ✅ قلب ترتيب الأعمدة + إضافة نطاق الاختبار + توضيح التسميات
    final headers = [
      'المراجعة (التلاوة)',
      'المراجعة (الحفظ)',
      'نطاق المراجعة',
      'الحفظ (التلاوة)',
      'الحفظ (الحفظ)',
      'نطاق الحفظ',
      'المنهج المصاحب',
      'الحلقة',
      'الشهر',
      'السنة',
      'التاريخ',

    ];

    final rows = filteredData.map((r) {
      return [
        (r['tilawa_revision']?.toString() ?? '—').toString(),
        (r['hifz_revision']?.toString() ?? '—').toString(),
        // ✅ نطاق المراجعة
        (r['from_soura_revision_name'] != null && r['to_soura_revision_name'] != null)
            ? '${r['from_soura_revision_name']} (${r['from_id_aya_revision']?.toString() ?? '0'}) -- ${r['to_soura_revision_name']} (${r['to_id_aya_revision']?.toString() ?? '0'})'
            : '—',
        (r['tilawa_monthly']?.toString() ?? '—').toString(),
        (r['hifz_monthly']?.toString() ?? '—').toString(),
        // ✅ نطاق الحفظ الشهري
        (r['from_soura_monthly_name'] != null && r['to_soura_monthly_name'] != null)
            ? '${r['from_soura_monthly_name']} (${r['from_id_aya_monthly']?.toString() ?? '0'}) -- ${r['to_soura_monthly_name']} (${r['to_id_aya_monthly']?.toString() ?? '0'})'
            : '—',
        (r['markManhage'] ?? '—').toString(),

        (r['name_circle'] ?? '—').toString(),
        (r['month_name'] ?? '—').toString(),
        (r['name_year'] ?? '—').toString(),
        (r['date']?.toString().split(' ')[0] ?? '—').toString(),

      ];
    }).toList();

    // تحديد عرض الأعمدة بناءً على محتواها
    final columnWidths = [
      60.0,  // المراجعة (التلاوة) - صغير
      60.0,  // المراجعة (الحفظ) - صغير  
      120.0, // نطاق المراجعة - كبير للنصوص الطويلة
      60.0,  // الحفظ (التلاوة) - صغير
      60.0,  // الحفظ (الحفظ) - صغير
      120.0, // نطاق الحفظ - كبير للنصوص الطويلة
      80.0,  // الحلقة - متوسط
      80.0,  // الحلقة - متوسط
      60.0,  // الشهر - صغير
      50.0,  // السنة - صغير
      70.0,  // التاريخ - متوسط
    ];

    await generateStandardPdfReport(
      title: "تقرير نتائج الاختبارات من الزيارات الفنية",
      subTitle: "الطالب: ${student["name_student"]}",
      headers: headers,
      rows: rows,
      columnWidths: columnWidths,
    );
  }

  // دالة تسجيل الخروج
  Future<void> logout() async {
    try {

      Get.offAll(() => Login()); // العودة لشاشة تسجيل الدخول
      mySnackbar("تم", "تم تسجيل الخروج بنجاح", type: "s");
    } catch (e) {
      mySnackbar("خطأ", "حدث خطأ أثناء تسجيل الخروج");
    }
  }

}