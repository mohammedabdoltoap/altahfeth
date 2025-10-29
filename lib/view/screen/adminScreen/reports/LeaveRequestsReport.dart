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

class LeaveRequestsReport extends StatelessWidget {
  final LeaveRequestsReportController controller = Get.put(LeaveRequestsReportController());

  @override
  Widget build(BuildContext context) {
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
                        value: controller.selectedStatus.value,
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
                        value: controller.selectedType.value,
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

              if (controller.filteredLeaveRequests.isEmpty) {
                return const Center(child: Text("لا توجد طلبات إجازة"));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.filteredLeaveRequests.length,
                itemBuilder: (context, index) {
                  final request = controller.filteredLeaveRequests[index];
                  final status = int.tryParse(request['status'].toString()) ?? 0;
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: CircleAvatar(
                        backgroundColor: _getStatusColor(status),
                        child: Icon(
                          _getStatusIcon(status),
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        request['username'] ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          // عرض التاريخ حسب النوع
                          if (request['leave_type'] == 'single')
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text('التاريخ: ${request['date_leave'] ?? '-'}'),
                              ],
                            )
                          else
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 14, color: Colors.green),
                                    const SizedBox(width: 4),
                                    Text('من: ${request['start_date'] ?? request['date_leave'] ?? '-'}'),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    const Icon(Icons.event, size: 14, color: Colors.red),
                                    const SizedBox(width: 4),
                                    Text('إلى: ${request['end_date'] ?? '-'}'),
                                  ],
                                ),
                              ],
                            ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.description, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'السبب: ${request['reason_leave']}',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'النوع: ${request['leave_type'] == 'single' ? 'يوم واحد' : 'فترة'}',
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      trailing: Chip(
                        label: Text(
                          _getStatusText(status),
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: _getStatusColor(status).withOpacity(0.2),
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
}

class LeaveRequestsReportController extends GetxController {
  var leaveRequests = <Map<String, dynamic>>[].obs;
  var filteredLeaveRequests = <Map<String, dynamic>>[].obs;
  var loading = false.obs;
  var dataArg;
  
  // Filters
  var selectedStatus = Rxn<String>();
  var selectedType = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    dataArg = Get.arguments;
    loadData();
  }
  
  void applyFilters() {
    if (leaveRequests.isEmpty) {
      filteredLeaveRequests.clear();
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
        if (item['leave_type'] != selectedType.value) {
          return false;
        }
      }
      
      return true;
    }).toList();
    
    filteredLeaveRequests.assignAll(filtered);
  }
  
  void clearFilters() {
    selectedStatus.value = null;
    selectedType.value = null;
    filteredLeaveRequests.assignAll(leaveRequests);
  }

  Future<void> loadData() async {
    loading.value = true;
    try {
      // جلب جميع طلبات الإجازة
      final response = await postData(Linkapi.select_leave_requests, {
        "id_user": "all" // لجلب جميع الطلبات للأدمن
      });

      print("Leave Requests Response: $response");

      if (response == null) {
        mySnackbar("خطأ", "فشل الاتصال بالخادم");
        leaveRequests.clear();
        return;
      }

      if (response is! Map) {
        mySnackbar("خطأ", "استجابة غير صحيحة من الخادم");
        leaveRequests.clear();
        return;
      }
      
      if (response['stat'] == 'ok') {
        if (response['data'] != null && response['data'] is List) {
          leaveRequests.assignAll(List<Map<String, dynamic>>.from(response['data']));
          filteredLeaveRequests.assignAll(leaveRequests);
          mySnackbar("نجح", "تم تحميل ${leaveRequests.length} طلب", type: "g");
        } else {
          leaveRequests.clear();
          filteredLeaveRequests.clear();
          mySnackbar("تنبيه", "لا توجد بيانات");
        }
      } else if (response['stat'] == 'no') {
        leaveRequests.clear();
        filteredLeaveRequests.clear();
        mySnackbar("تنبيه", "لا توجد طلبات إجازة");
      } else {
        leaveRequests.clear();
        filteredLeaveRequests.clear();
        mySnackbar("خطأ", response['msg'] ?? "حدث خطأ");
      }
    } catch (e) {
      print("Error loading leave requests: $e");
      mySnackbar("خطأ", "حدث خطأ: $e");
      leaveRequests.clear();
      filteredLeaveRequests.clear();
    } finally {
      loading.value = false;
    }
  }
  
  Future<void> exportToPDF() async {
    if (filteredLeaveRequests.isEmpty) {
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

              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('#E1BEE7'),
                    ),
                    children: [
                      _buildTableCell('الاسم', isHeader: true),
                      _buildTableCell('التاريخ', isHeader: true),
                      _buildTableCell('السبب', isHeader: true),
                      _buildTableCell('النوع', isHeader: true),
                      _buildTableCell('الحالة', isHeader: true),
                    ],
                  ),
                  ...filteredLeaveRequests.map((item) {
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
                    
                    return pw.TableRow(
                      children: [
                        _buildTableCell(item['username'] ?? '-'),
                        _buildTableCell(dateText),
                        _buildTableCell(item['reason_leave'] ?? '-'),
                        _buildTableCell(typeText),
                        _buildTableCell(statusText),
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
        name: 'تقرير_طلبات_الإجازات.pdf',
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
          fontSize: isHeader ? 12 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? PdfColor.fromHex('#7B1FA2') : PdfColors.black,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }
}
