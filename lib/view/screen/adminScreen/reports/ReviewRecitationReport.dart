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
                  return _buildStudentCard(item);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> item) {
    final totalReviews = int.tryParse(item['total_reviews'].toString()) ?? 0;
    final avgMark = double.tryParse(item['avg_mark'].toString()) ?? 0.0;
    final markColor = avgMark >= 80 ? Colors.green : avgMark >= 60 ? Colors.orange : Colors.red;
    final reviews = item['reviews'] as List<Map<String, dynamic>>? ?? [];
    
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
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الحلقة: ${item['name_circle'] ?? '-'}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildStatChip('مراجعات', totalReviews.toString(), Colors.orange),
                const SizedBox(width: 8),
                _buildStatChip('المتوسط', avgMark.toStringAsFixed(1), markColor),
              ],
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'تفاصيل المراجعات:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                ...reviews.map((review) => _buildReviewItem(review)).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(Map<String, dynamic> review) {
    final mark = double.tryParse(review['mark']?.toString() ?? '0') ?? 0.0;
    final markColor = mark >= 80 ? Colors.green : mark >= 60 ? Colors.orange : Colors.red;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  review['review_content'] ?? 'غير محدد',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: markColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  mark.toStringAsFixed(0),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'التقييم: ${review['evaluation_name'] ?? '-'}',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          Text(
            'التاريخ: ${review['date'] ?? '-'}',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
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
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
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
    } else if (res["stat"] == "no") {
      mySnackbar("تنبيه", "لا يوجد لديك حلقات");
    } else {
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
      loadingMessage: "جاري تحميل بيانات المراجعة...",
      action: () async {
        return await postData(Linkapi.getCircleReviews, requestData);
      }
    );
    
    if (res == null) {
      reviewList.clear();
      return;
    }
    
    if (res is! Map) {
      mySnackbar("خطأ", "فشل الاتصال بالخادم");
      reviewList.clear();
      return;
    }
    
    if (res["stat"] == "ok") {
      if (res['data'] != null && res['data'] is List) {
        final rawData = List<Map<String, dynamic>>.from(res['data']);
        
        // تجميع البيانات حسب الطالب (مثل DailyRecitationReport)
        final Map<String, List<Map<String, dynamic>>> groupedByStudent = {};
        
        for (var item in rawData) {
          final studentId = item['id_student'].toString();
          if (!groupedByStudent.containsKey(studentId)) {
            groupedByStudent[studentId] = [];
          }
          groupedByStudent[studentId]!.add(item);
        }
        
        // إنشاء قائمة جديدة مع ملخص لكل طالب
        final List<Map<String, dynamic>> processedData = [];
        
        groupedByStudent.forEach((studentId, studentReviews) {
          if (studentReviews.isNotEmpty) {
            final firstItem = studentReviews.first;
            
            // حساب المتوسط والإجمالي
            final totalReviews = studentReviews.length;
            final totalMarks = studentReviews.fold<double>(0.0, (sum, item) {
              return sum + (double.tryParse(item['mark']?.toString() ?? '0') ?? 0.0);
            });
            final avgMark = totalReviews > 0 ? totalMarks / totalReviews : 0.0;
            
            // إضافة كارت الملخص
            processedData.add({
              'id_student': firstItem['id_student'],
              'name_student': firstItem['name_student'],
              'name_circle': firstItem['name_circle'],
              'total_reviews': totalReviews,
              'avg_mark': avgMark,
              'reviews': studentReviews, // جميع المراجعات
            });
          }
        });
        
        reviewList.assignAll(processedData);
        mySnackbar("نجح", "تم تحميل ${processedData.length} طالب", type: "g");
      } else {
        reviewList.clear();
        mySnackbar("تنبيه", "لا توجد بيانات");
      }
    } else if (res["stat"] == "no") {
      reviewList.clear();
      mySnackbar("تنبيه", "لا توجد بيانات مراجعة لهذه الفترة");
    } else {
      reviewList.clear();
      mySnackbar("خطأ", res["msg"] ?? "حدث خطأ أثناء جلب البيانات");
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
      
      // تحميل الشعار
      final logoData = await rootBundle.load('assets/icon/app_icon.png');
      final logoImage = pw.MemoryImage(logoData.buffer.asUint8List());

      final dateStr = selectedDate.value != null 
          ? DateFormat('yyyy-MM-dd').format(selectedDate.value!)
          : useDateRange.value && startDate.value != null && endDate.value != null
              ? 'من ${DateFormat('yyyy-MM-dd').format(startDate.value!)} إلى ${DateFormat('yyyy-MM-dd').format(endDate.value!)}'
              : '';

      final circleName = circlesList.firstWhere(
        (circle) => circle['id_circle'].toString() == selectedCircle.value.toString(), 
        orElse: () => {'name_circle': 'غير محدد'}
      )['name_circle'];

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
                            'تقرير المراجعة',
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
                            'الحلقة: $circleName | إجمالي: ${reviewList.length}',
                            style: const pw.TextStyle(fontSize: 9),
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
                  headers: ['المتوسط', 'المراجعات', 'الحلقة', 'اسم الطالب', '#'],
                  data: reviewList.asMap().entries.map((entry) {
                    final index = entry.key + 1;
                    final item = entry.value;
                    final totalReviews = item['total_reviews'] ?? 0;
                    final avgMark = double.tryParse(item['avg_mark']?.toString() ?? '0') ?? 0.0;
                    
                    return [
                      avgMark.toStringAsFixed(1),
                      totalReviews.toString(),
                      item['name_circle'] ?? '-',
                      item['name_student'] ?? '-',
                      index.toString(),
                    ];
                  }).toList(),
                  border: pw.TableBorder.all(width: 0.5, color: PdfColors.orange300),
                  headerStyle: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                  headerDecoration: const pw.BoxDecoration(
                    color: PdfColors.orange,
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
        name: 'تقرير_المراجعة_$dateStr.pdf',
      );
    } catch (e) {
      print("Error generating PDF: $e");
      mySnackbar("خطأ", "حدث خطأ أثناء إنشاء التقرير");
    }
  }
}
