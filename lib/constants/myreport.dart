import 'dart:io';

import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:printing/printing.dart';
Future<void> generateStandardPdfReport({
  required String title,
  required List<String> headers,
  required List<List<String>> rows,
  String? subTitle,
  PdfColor headerColor = PdfColors.teal200,
  List<double>? columnWidths,
}) async {
  final pdf = pw.Document();

  // تحميل الخط العربي مرة واحدة
  final ByteData bytes = await rootBundle.load('assets/fonts/Amiri-Bold.ttf');
  final ttf = pw.Font.ttf(bytes.buffer.asByteData());

  // تحميل شعار المؤسسة
  final ByteData logoData = await rootBundle.load('assets/icon/app_icon.png');
  final logoImage = pw.MemoryImage(logoData.buffer.asUint8List());

  const int rowsPerPage = 25; // عدد الصفوف لكل صفحة
  int totalPages = (rows.length / rowsPerPage).ceil();

  for (int pageIndex = 0; pageIndex < totalPages; pageIndex++) {
    final start = pageIndex * rowsPerPage;
    final end = ((pageIndex + 1) * rowsPerPage).clamp(0, rows.length);
    final currentRows = rows.sublist(start, end);
    final isFirstPage = pageIndex == 0;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        theme: pw.ThemeData.withFont(
          base: ttf,
          bold: ttf,
        ),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // رأس الصفحة - فقط في الصفحة الأولى
              if (isFirstPage) ...[
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 10),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // الجانب الأيمن: اسم التقرير + الطالب
                      pw.Directionality(
                        textDirection: pw.TextDirection.rtl,
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              title,
                              style: pw.TextStyle(
                                font: ttf,
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            if (subTitle != null)
                              pw.Text(
                                subTitle,
                                style: pw.TextStyle(
                                  font: ttf,
                                  fontSize: 11,
                                ),
                              ),
                          ],
                        ),
                      ),
                      // الجانب الأيسر: الشعار + المؤسسة
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
                                    font: ttf,
                                    fontSize: 12,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                                pw.Text(
                                  'للتنمية الإنسانية',
                                  style: pw.TextStyle(
                                    font: ttf,
                                    fontSize: 10,
                                  ),
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
                pw.SizedBox(height: 8),
              ],
              
              // رأس مصغر للصفحات التالية
              if (!isFirstPage) ...[
                pw.Directionality(
                  textDirection: pw.TextDirection.rtl,
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        title,
                        style: pw.TextStyle(
                          font: ttf,
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      if (subTitle != null)
                        pw.Text(
                          subTitle,
                          style: pw.TextStyle(font: ttf, fontSize: 11),
                        ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Divider(),
                pw.SizedBox(height: 5),
              ],

              // الجدول
              pw.Directionality(
                textDirection: pw.TextDirection.rtl,
                child: columnWidths != null
                    ? pw.Table(
                        border: pw.TableBorder.all(width: 0.5, color: headerColor.shade(0.3)),
                        columnWidths: Map.fromIterables(
                          List.generate(headers.length, (index) => index),
                          columnWidths.map((width) => pw.FixedColumnWidth(width)),
                        ),
                        children: [
                          // رأس الجدول
                          pw.TableRow(
                            decoration: pw.BoxDecoration(color: headerColor),
                            children: headers.map((header) => 
                              pw.Container(
                                height: 50,
                                padding: const pw.EdgeInsets.all(4),
                                alignment: pw.Alignment.center,
                                child: pw.Text(
                                  header,
                                  style: pw.TextStyle(
                                    font: ttf,
                                    fontSize: 10,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.white,
                                  ),
                                  textAlign: pw.TextAlign.center,
                                ),
                              )
                            ).toList(),
                          ),
                          // صفوف البيانات
                          ...currentRows.asMap().entries.map((entry) {
                            final rowIndex = entry.key;
                            final row = entry.value;
                            return pw.TableRow(
                              decoration: pw.BoxDecoration(
                                color: rowIndex % 2 == 0 
                                    ? PdfColors.white 
                                    : PdfColors.grey100,
                              ),
                              children: row.map((cell) => 
                                pw.Container(
                                  height: 35,
                                  padding: const pw.EdgeInsets.all(4),
                                  alignment: pw.Alignment.center,
                                  child: pw.Text(
                                    cell,
                                    style: pw.TextStyle(
                                      font: ttf,
                                      fontSize: 9,
                                      color: PdfColors.grey900,
                                    ),
                                    textAlign: pw.TextAlign.center,
                                  ),
                                )
                              ).toList(),
                            );
                          }).toList(),
                        ],
                      )
                    : pw.Table.fromTextArray(
                        headers: headers,
                        data: currentRows,
                        border: pw.TableBorder.all(width: 0.5, color: headerColor.shade(0.3)),
                        headerStyle: pw.TextStyle(
                          font: ttf,
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                        headerDecoration: pw.BoxDecoration(
                          color: headerColor,
                        ),
                        cellStyle: pw.TextStyle(
                          font: ttf,
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

              // تذييل
              pw.SizedBox(height: 10),
              pw.Divider(),
              pw.Directionality(
                textDirection: pw.TextDirection.rtl,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      "تاريخ الطباعة: ${DateTime.now().toLocal().toString().split(' ')[0]}",
                      style: pw.TextStyle(font: ttf, fontSize: 8),
                    ),
                    pw.Text(
                      "صفحة ${pageIndex + 1} من $totalPages",
                      style: pw.TextStyle(font: ttf, fontSize: 8),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
    name: "${title}_${subTitle != null ? subTitle : ""}_${DateTime.now().toLocal().toString().split(' ')[0]}",
  );
}

