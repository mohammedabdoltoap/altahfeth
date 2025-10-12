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
}) async {
  final pdf = pw.Document();

  // تحميل الخط مرة واحدة
  final ByteData bytes = await rootBundle.load('assets/fonts/Amiri-Bold.ttf');
  final ttf = pw.Font.ttf(bytes.buffer.asByteData());

  const int rowsPerPage = 25;
  int totalPages = (rows.length / rowsPerPage).ceil();

  for (int pageIndex = 0; pageIndex < totalPages; pageIndex++) {
    final start = pageIndex * rowsPerPage;
    final end = ((pageIndex + 1) * rowsPerPage).clamp(0, rows.length);
    final currentRows = rows.sublist(start, end);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return [
            // العنوان الرئيسي
            pw.Directionality(
              textDirection: pw.TextDirection.rtl,
              child: pw.Center(
                child: pw.Text(
                  title,
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    decoration: pw.TextDecoration.underline,
                  ),
                ),
              ),
            ),
            if (subTitle != null)
              pw.Directionality(
                textDirection: pw.TextDirection.rtl,
                child: pw.Center(
                  child: pw.Text(
                    subTitle,
                    style: pw.TextStyle(font: ttf, fontSize: 14),
                  ),
                ),
              ),
            pw.SizedBox(height: 12),

            // الجدول
            pw.Directionality(
              textDirection: pw.TextDirection.rtl,
              child: pw.Table.fromTextArray(
                headers: headers,
                data: currentRows,
                border: pw.TableBorder.all(width: 0.5),
                headerStyle: pw.TextStyle(
                  font: ttf,
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
                headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
                cellStyle: pw.TextStyle(font: ttf, fontSize: 11),
                cellAlignment: pw.Alignment.center,
                columnWidths: {
                  for (int i = 0; i < headers.length; i++)
                      i:  pw.FlexColumnWidth(2),

                },
                headerCount: 1,
              ),
            ),

            pw.SizedBox(height: 12),

            // تاريخ الطباعة
            pw.Directionality(
              textDirection: pw.TextDirection.rtl,
              child: pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  "تاريخ الطباعة: ${DateTime.now().toLocal().toString().split(' ')[0]}",
                  style: pw.TextStyle(font: ttf, fontSize: 10),
                ),
              ),
            ),
          ];
        },
      ),
    );
  }

  await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save(),name: "${title}_${subTitle!=null?subTitle:""}_${DateTime.now().toLocal().toString().split(' ')[0]}");
}

