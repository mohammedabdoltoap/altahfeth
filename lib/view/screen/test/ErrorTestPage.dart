import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/app_theme.dart';
import '../../../constants/function.dart';

class ErrorTestPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اختبار حماية الأخطاء'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // معلومات النظام
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                children: [
                  Icon(Icons.security, color: Colors.green, size: 48),
                  const SizedBox(height: 8),
                  Text(
                    'نظام حماية الأخطاء مفعل',
                    style: AppTheme.headingMedium.copyWith(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'جميع الأخطاء محمية ولن تظهر الشاشة الحمراء',
                    style: AppTheme.bodyMedium.copyWith(
                      color: Colors.green.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // أزرار الاختبار
            Expanded(
              child: ListView(
                children: [
                  _buildTestButton(
                    title: 'اختبار خطأ Null',
                    description: 'محاولة الوصول لمتغير null',
                    icon: Icons.error_outline,
                    color: Colors.red,
                    onPressed: () => _testNullError(),
                  ),
                  
                  _buildTestButton(
                    title: 'اختبار خطأ JSON',
                    description: 'تحليل JSON غير صالح',
                    icon: Icons.code,
                    color: Colors.orange,
                    onPressed: () => _testJsonError(),
                  ),
                  
                  _buildTestButton(
                    title: 'اختبار خطأ List',
                    description: 'الوصول لفهرس غير موجود',
                    icon: Icons.list,
                    color: Colors.purple,
                    onPressed: () => _testListError(),
                  ),
                  
                  _buildTestButton(
                    title: 'اختبار خطأ مخصص',
                    description: 'رمي استثناء مخصص',
                    icon: Icons.warning,
                    color: Colors.amber,
                    onPressed: () => _testCustomError(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestButton({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: color,
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: color.withOpacity(0.3)),
          ),
          elevation: 2,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTheme.bodySmall.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.play_arrow, color: color),
          ],
        ),
      ),
    );
  }

  // اختبار خطأ null - محمي
  void _testNullError() {
    safeExecution(() async {
      String? nullString;
      int length = nullString!.length; // سيسبب خطأ
      print('Length: $length');
    }, errorMessage: 'تم اختبار خطأ Null بنجاح - النظام يعمل!');
  }

  // اختبار خطأ JSON - محمي
  void _testJsonError() {
    safeExecution(() async {
      String invalidJson = '{"name": "test", "age":}';
      var decoded = jsonDecode(invalidJson); // سيسبب خطأ
      print('Decoded: $decoded');
    }, errorMessage: 'تم اختبار خطأ JSON بنجاح - النظام يعمل!');
  }

  // اختبار خطأ List - محمي
  void _testListError() {
    safeSyncExecution(() {
      List<String> list = ['item1', 'item2'];
      String item = list[10]; // سيسبب خطأ
      print('Item: $item');
    }, errorMessage: 'تم اختبار خطأ List بنجاح - النظام يعمل!');
  }

  // اختبار خطأ مخصص - محمي
  void _testCustomError() {
    safeSyncExecution(() {
      throw Exception('خطأ مخصص للاختبار');
    }, errorMessage: 'تم اختبار الخطأ المخصص بنجاح - النظام يعمل!');
  }
}
