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

class ResignationRequestsReport extends StatelessWidget {
  final ResignationRequestsReportController controller = Get.put(ResignationRequestsReportController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("تقرير طلبات الاستقالة"),
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
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text("تحديث"),
                        onPressed: () => controller.loadData(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.clear),
                  label: const Text("مسح الفلاتر"),
                  onPressed: () => controller.clearFilters(),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 45),
                  ),
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

              if (controller.filteredResignationRequests.isEmpty) {
                return const Center(child: Text("لا توجد طلبات استقالة"));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.filteredResignationRequests.length,
                itemBuilder: (context, index) {
                  final request = controller.filteredResignationRequests[index];
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
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'تاريخ الطلب: ${request['request_date'] ?? '-'}',
                                  style: const TextStyle(fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.event, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'تاريخ الاستقالة: ${request['resignation_date'] ?? '-'}',
                                  style: const TextStyle(fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // اسم الحلقة
                          if (request['name_circle'] != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              margin: const EdgeInsets.only(bottom: 4),
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
                                    'الحلقة: ${request['name_circle']}',
                                    style: TextStyle(
                                      color: Colors.blue.shade700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.description, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'السبب: ${request['reason'] ?? '-'}',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
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

class ResignationRequestsReportController extends GetxController {
  var resignationRequests = <Map<String, dynamic>>[].obs;
  var filteredResignationRequests = <Map<String, dynamic>>[].obs;
  var loading = false.obs;
  var dataArg;
  
  // Filters
  var selectedStatus = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    dataArg = Get.arguments;
    loadData();
  }
  
  void applyFilters() {
    if (resignationRequests.isEmpty) {
      filteredResignationRequests.clear();
      return;
    }
    
    var filtered = resignationRequests.where((item) {
      // فلتر الحالة
      if (selectedStatus.value != null && selectedStatus.value != 'all') {
        if (item['status'].toString() != selectedStatus.value) {
          return false;
        }
      }
      
      return true;
    }).toList();
    
    filteredResignationRequests.assignAll(filtered);
  }
  
  void clearFilters() {
    selectedStatus.value = null;
    filteredResignationRequests.assignAll(resignationRequests);
  }

  Future<void> loadData() async {
    loading.value = true;
    try {
      final response = await postData(Linkapi.select_resignation_requests, {
        "id_user": "all"
      });

      print("Resignation Requests Response: $response");

      if (response == null) {
        mySnackbar("خطأ", "فشل الاتصال بالخادم");
        resignationRequests.clear();
        filteredResignationRequests.clear();
        return;
      }

      if (response is! Map) {
        mySnackbar("خطأ", "استجابة غير صحيحة من الخادم");
        resignationRequests.clear();
        filteredResignationRequests.clear();
        return;
      }
      
      if (response['stat'] == 'ok') {
        if (response['data'] != null && response['data'] is List) {
          resignationRequests.assignAll(List<Map<String, dynamic>>.from(response['data']));
          filteredResignationRequests.assignAll(resignationRequests);
          mySnackbar("نجح", "تم تحميل ${resignationRequests.length} طلب", type: "g");
        } else {
          resignationRequests.clear();
          filteredResignationRequests.clear();
          mySnackbar("تنبيه", "لا توجد بيانات");
        }
      } else if (response['stat'] == 'no') {
        resignationRequests.clear();
        filteredResignationRequests.clear();
        mySnackbar("تنبيه", "لا توجد طلبات استقالة");
      } else {
        resignationRequests.clear();
        filteredResignationRequests.clear();
        mySnackbar("خطأ", response['msg'] ?? "حدث خطأ");
      }
    } catch (e) {
      print("Error loading resignation requests: $e");
      mySnackbar("خطأ", "حدث خطأ: $e");
      resignationRequests.clear();
      filteredResignationRequests.clear();
    } finally {
      loading.value = false;
    }
  }
  
  Future<void> exportToPDF() async {
    if (filteredResignationRequests.isEmpty) {
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
                      'تقرير طلبات الاستقالة',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      'عدد الطلبات: ${filteredResignationRequests.length}',
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
                      _buildTableCell('الاسم', isHeader: true),
                      _buildTableCell('تاريخ الطلب', isHeader: true),
                      _buildTableCell('تاريخ الاستقالة', isHeader: true),
                      _buildTableCell('السبب', isHeader: true),
                      _buildTableCell('الحالة', isHeader: true),
                    ],
                  ),
                  ...filteredResignationRequests.map((item) {
                    final status = int.tryParse(item['status'].toString()) ?? 0;
                    String statusText = status == 1 ? 'مقبول' : status == 2 ? 'مرفوض' : 'قيد المراجعة';
                    
                    return pw.TableRow(
                      children: [
                        _buildTableCell(item['username'] ?? '-'),
                        _buildTableCell(item['request_date'] ?? '-'),
                        _buildTableCell(item['resignation_date'] ?? '-'),
                        _buildTableCell(item['reason'] ?? '-'),
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
        name: 'تقرير_طلبات_الاستقالة.pdf',
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
          color: isHeader ? PdfColor.fromHex('#C62828') : PdfColors.black,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }
}
