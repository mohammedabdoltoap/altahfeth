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

class LeaveRequestsReport extends StatelessWidget {
  final LeaveRequestsReportController controller = Get.put(LeaveRequestsReportController());

  @override
  Widget build(BuildContext context) {
    // تهيئة بيانات التاريخ للغة العربية
    initializeDateFormatting('ar', null);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("تقرير طلبات الإجازات"),
        backgroundColor: Colors.purple,
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
            color: Colors.purple.shade50,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: "الحالة",
                          border: OutlineInputBorder(),
                        ),
                        value: controller.selectedStatus.value ?? 'all',
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text("الكل")),
                          DropdownMenuItem(value: '0', child: Text("قيد المراجعة")),
                          DropdownMenuItem(value: '1', child: Text("مقبول")),
                          DropdownMenuItem(value: '2', child: Text("مرفوض")),
                        ],
                        onChanged: (val) {
                          controller.selectedStatus.value = val;
                          controller.applyFilters();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: "النوع",
                          border: OutlineInputBorder(),
                        ),
                        value: controller.selectedType.value ?? 'all',
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text("الكل")),
                          DropdownMenuItem(value: 'single', child: Text("يوم واحد")),
                          DropdownMenuItem(value: 'range', child: Text("فترة")),
                        ],
                        onChanged: (val) {
                          controller.selectedType.value = val;
                          controller.applyFilters();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text("تحديث"),
                        onPressed: () => controller.loadData(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.clear),
                        label: const Text("مسح الفلاتر"),
                        onPressed: () => controller.clearFilters(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Data List
          Expanded(
            child: Obx(() {
        if (controller.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }

              if (controller.groupedLeaveRequests.isEmpty) {
                return const Center(child: Text("لا توجد طلبات إجازة"));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.groupedLeaveRequests.length,
                itemBuilder: (context, index) {
                  final userGroup = controller.groupedLeaveRequests[index];
                  final leaveRequests = List<Map<String, dynamic>>.from(userGroup['leave_requests'] ?? []);
                  final approvedRequests = userGroup['approved_requests'] ?? 0;
                  final rejectedRequests = userGroup['rejected_requests'] ?? 0;
                  final pendingRequests = userGroup['pending_requests'] ?? 0;
                  final totalRequests = userGroup['total_requests'] ?? 0;
                  final approvalRate = totalRequests > 0 ? (approvedRequests / totalRequests * 100) : 0.0;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ExpansionTile(
                      leading: CircleAvatar(
                        backgroundColor: approvalRate >= 70 ? Colors.green : 
                                        approvalRate >= 40 ? Colors.orange : Colors.red,
                        child: Text(
                          '${approvalRate.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      title: Text(
                        userGroup['user_name'] ?? 'غير محدد',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            _buildStatChip('مقبول', approvedRequests.toString(), Colors.green),
                            const SizedBox(width: 8),
                            _buildStatChip('مرفوض', rejectedRequests.toString(), Colors.red),
                            const SizedBox(width: 8),
                            _buildStatChip('قيد المراجعة', pendingRequests.toString(), Colors.orange),
                          ],
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: leaveRequests.map((request) {
                              final status = int.tryParse(request['status'].toString()) ?? 0;
                              final statusColor = _getStatusColor(status);
                              
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: statusColor.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _getStatusIcon(status),
                                      color: statusColor,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // التاريخ
                                          if (request['leave_type'] == 'single')
                                            Text(
                                              'التاريخ: ${request['date_leave'] ?? '-'}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            )
                                          else
                                            Text(
                                              'من ${request['start_date'] ?? request['date_leave'] ?? '-'} إلى ${request['end_date'] ?? '-'}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          const SizedBox(height: 4),
                                          // السبب
                                          Text(
                                            'السبب: ${request['reason_leave'] ?? '-'}',
                                            style: const TextStyle(fontSize: 12),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          // النوع والحالة
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Colors.blue.withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  request['leave_type'] == 'single' ? 'يوم واحد' : 'فترة',
                                                  style: const TextStyle(fontSize: 10),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: statusColor.withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  _getStatusText(status),
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: statusColor,
                                                    fontWeight: FontWeight.bold,
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
    );
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 1: return Colors.green;
      case 2: return Colors.red;
      default: return Colors.orange;
    }
  }

  IconData _getStatusIcon(int status) {
    switch (status) {
      case 1: return Icons.check_circle;
      case 2: return Icons.cancel;
      default: return Icons.pending;
    }
  }

  String _getStatusText(int status) {
    switch (status) {
      case 1: return 'مقبول';
      case 2: return 'مرفوض';
      default: return 'قيد المراجعة';
    }
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

class LeaveRequestsReportController extends GetxController {
  var leaveRequests = <Map<String, dynamic>>[].obs;
  var filteredLeaveRequests = <Map<String, dynamic>>[].obs;
  var groupedLeaveRequests = <Map<String, dynamic>>[].obs; // قائمة مجمعة حسب المستخدم
  var loading = false.obs;
  var dataArg;
  
  // Filters
  var selectedStatus = Rxn<String>();
  var selectedType = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    dataArg = Get.arguments;
    // تهيئة القيم الافتراضية للفلاتر
    selectedStatus.value = 'all';
    selectedType.value = 'all';
    loadData();
  }
  
  void applyFilters() {
    if (leaveRequests.isEmpty) {
      filteredLeaveRequests.clear();
      groupedLeaveRequests.clear();
      return;
    }
    
    var filtered = leaveRequests.where((item) {
      // فلتر الحالة
      if (selectedStatus.value != null && selectedStatus.value != 'all') {
        if (item['status'].toString() != selectedStatus.value) {
          return false;
        }
      }
      
      // فلتر النوع
      if (selectedType.value != null && selectedType.value != 'all') {
        // طباعة القيم للتشخيص
        print("Filtering by type: ${selectedType.value}, Item type: ${item['leave_type']}");
        
        if (selectedType.value == 'range') {
          // للفترة: نتحقق من أن النوع ليس 'single'
          if (item['leave_type'] == 'single') {
            return false;
          }
        } else if (selectedType.value == 'single') {
          // لليوم الواحد: نتحقق من أن النوع هو 'single'
          if (item['leave_type'] != 'single') {
            return false;
          }
        }
      }
      
      return true;
    }).toList();
    
    filteredLeaveRequests.assignAll(filtered);
    _groupLeaveRequestsByUser();
  }
  
  // دالة لتجميع البيانات حسب المستخدم
  void _groupLeaveRequestsByUser() {
    Map<String, Map<String, dynamic>> grouped = {};
    
    for (var request in filteredLeaveRequests) {
      String userKey = request['username'] ?? 'غير محدد';
      
      if (!grouped.containsKey(userKey)) {
        grouped[userKey] = {
          'user_name': userKey,
          'user_id': request['id_user'],
          'leave_requests': <Map<String, dynamic>>[],
          'total_requests': 0,
          'approved_requests': 0,
          'rejected_requests': 0,
          'pending_requests': 0,
        };
      }
      
      grouped[userKey]!['leave_requests'].add(request);
      grouped[userKey]!['total_requests']++;
      
      int status = int.tryParse(request['status'].toString()) ?? 0;
      if (status == 1) {
        grouped[userKey]!['approved_requests']++;
      } else if (status == 2) {
        grouped[userKey]!['rejected_requests']++;
      } else {
        grouped[userKey]!['pending_requests']++;
      }
    }
    
    groupedLeaveRequests.assignAll(grouped.values.toList());
  }
  
  void clearFilters() {
    selectedStatus.value = 'all';
    selectedType.value = 'all';
    filteredLeaveRequests.assignAll(leaveRequests);
    _groupLeaveRequestsByUser();
  }

  Future<void> loadData() async {
    var res = await handleRequest(
      isLoading: loading,
      useDialog: true,
      immediateLoading: true,
      loadingMessage: "جميع لطلبات الاجازه",
      action: () async {
        return await postData(Linkapi.select_leave_requests, {
          "id_user": "all" // لجلب جميع الطلبات للأدمن
        });
      }
    );
    
    if (res == null) {
      leaveRequests.clear();
      filteredLeaveRequests.clear();
      groupedLeaveRequests.clear();
      return;
    }
    
    if (res is! Map) {
      mySnackbar("خطأ", "فشل الاتصال بالخادم");
      leaveRequests.clear();
      filteredLeaveRequests.clear();
      groupedLeaveRequests.clear();
      return;
    }
    
    if (res["stat"] == "ok") {
      if (res['data'] != null && res['data'] is List) {
        leaveRequests.assignAll(List<Map<String, dynamic>>.from(res['data']));

        for (var request in leaveRequests) {
          print("Type: ${request['leave_type']}, User: ${request['username']}");
        }
        
        filteredLeaveRequests.assignAll(leaveRequests);
        _groupLeaveRequestsByUser(); // تجم
      } else {
        leaveRequests.clear();
        filteredLeaveRequests.clear();
        groupedLeaveRequests.clear();
        mySnackbar("تنبيه", "لا توجد طلبات إجازة");
      }
    } else if (res["stat"] != "no") {
      mySnackbar("خطأ", res["msg"] ?? "حدث خطأ أثناء جلب البيانات");
      leaveRequests.clear();
      filteredLeaveRequests.clear();
      groupedLeaveRequests.clear();
    } else {
      leaveRequests.clear();
      filteredLeaveRequests.clear();
      groupedLeaveRequests.clear();
      mySnackbar("تنبيه", "لا توجد طلبات إجازة");
    }
  }
  
  Future<void> exportToPDF() async {
    if (filteredLeaveRequests.isEmpty) {
      mySnackbar("تنبيه", "لا توجد بيانات للتصدير");
      return;
    }


      final pdf = pw.Document();
      final fontData = await rootBundle.load('assets/fonts/Amiri-Bold.ttf');
      final arabicFont = pw.Font.ttf(fontData);

      // تحميل شعار المؤسسة
      final ByteData logoData = await rootBundle.load('assets/icon/app_icon.png');
      final logoImage = pw.MemoryImage(logoData.buffer.asUint8List());

      // حساب الإحصائيات
      final totalRequests = filteredLeaveRequests.length;
      final approvedRequests = filteredLeaveRequests.where((r) => r['status'].toString() == '1').length;
      final rejectedRequests = filteredLeaveRequests.where((r) => r['status'].toString() == '2').length;
      final pendingRequests = totalRequests - approvedRequests - rejectedRequests;

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
                            'تقرير طلبات الإجازات',
                            style: pw.TextStyle(
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            'التاريخ: ${DateTime.now().toLocal().toString().split(' ')[0]}',
                            style: const pw.TextStyle(fontSize: 11),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            'مقبول: $approvedRequests | مرفوض: $rejectedRequests | قيد المراجعة: $pendingRequests',
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
                  headers: ['الحالة', 'النوع', 'السبب', 'التاريخ', 'الحلقة', 'الاسم'],
                  data: filteredLeaveRequests.map((item) {
                    final status = int.tryParse(item['status'].toString()) ?? 0;
                    String statusText = status == 1 ? 'مقبول' : status == 2 ? 'مرفوض' : 'قيد المراجعة';
                    String typeText = item['leave_type'] == 'single' ? 'يوم واحد' : 'فترة';
                    
                    // تحديد التاريخ حسب النوع
                    String dateText;
                    if (item['leave_type'] == 'single') {
                      dateText = item['date_leave'] ?? '-';
                    } else {
                      String startDate = item['start_date'] ?? item['date_leave'] ?? '-';
                      String endDate = item['end_date'] ?? '-';
                      dateText = 'من $startDate إلى $endDate';
                    }
                    
                    return [
                      statusText,
                      typeText,
                      item['reason'] ?? '-',
                      dateText,
                      item['name_circle'] ?? '-',
                      item['username'] ?? '-',
                    ];
                  }).toList(),
                  border: pw.TableBorder.all(width: 0.5, color: PdfColors.purple300),
                  headerStyle: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                  headerDecoration: const pw.BoxDecoration(
                    color: PdfColors.purple,
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
        name: 'تقرير_طلبات_الإجازات_${DateTime.now().toLocal().toString().split(' ')[0]}.pdf',
      );

      mySnackbar("نجح", "تم إنشاء التقرير بنجاح", type: "g");

  }
}
