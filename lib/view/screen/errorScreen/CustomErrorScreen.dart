import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomErrorScreen extends StatelessWidget {
  final String? errorMessage;
  final String? errorDetails;
  final VoidCallback? onRetry;

  const CustomErrorScreen({
    Key? key,
    this.errorMessage,
    this.errorDetails,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // أيقونة الخطأ
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline,
                    size: 80,
                    color: Colors.red.shade400,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // عنوان الخطأ
                Text(
                  "حدث خطأ غير متوقع",
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 16),
                
                // رسالة الخطأ
                Text(
                  errorMessage ?? "نعتذر، حدث خطأ أثناء تشغيل التطبيق",
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
                
                if (errorDetails != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "تفاصيل الخطأ:",
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          errorDetails!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                const SizedBox(height: 32),
                
                // الأزرار
                Row(
                  children: [
                    // زر العودة للصفحة السابقة
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (Get.canPop()) {
                            Get.back();
                          } else {
                            // إذا لم تكن هناك صفحة سابقة، اذهب للصفحة الرئيسية
                            Get.offAllNamed('/home');
                          }
                        },
                        icon: const Icon(Icons.arrow_back),
                        label: const Text("العودة"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    
                    if (onRetry != null) ...[
                      const SizedBox(width: 16),
                      // زر إعادة المحاولة
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onRetry,
                          icon: const Icon(Icons.refresh),
                          label: const Text("إعادة المحاولة"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // زر الإبلاغ عن المشكلة
                TextButton.icon(
                  onPressed: () {
                    _showReportDialog(context);
                  },
                  icon: const Icon(Icons.bug_report),
                  label: const Text("الإبلاغ عن المشكلة"),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.bug_report, color: Colors.orange),
              SizedBox(width: 8),
              Text("الإبلاغ عن المشكلة"),
            ],
          ),
          content: const Text(
            "شكراً لك على الإبلاغ عن هذه المشكلة. سيتم إرسال تقرير الخطأ إلى فريق التطوير لحل المشكلة في أقرب وقت ممكن.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("إلغاء"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // هنا يمكن إضافة كود إرسال التقرير
                Get.snackbar(
                  "تم الإرسال",
                  "تم إرسال تقرير الخطأ بنجاح",
                  backgroundColor: Colors.green.shade100,
                  colorText: Colors.green.shade800,
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
              child: const Text("إرسال التقرير"),
            ),
          ],
        );
      },
    );
  }
}

// دالة مساعدة لعرض صفحة الخطأ
void showCustomError({
  String? message,
  String? details,
  VoidCallback? onRetry,
}) {
  Get.to(() => CustomErrorScreen(
    errorMessage: message,
    errorDetails: details,
    onRetry: onRetry,
  ));
}
