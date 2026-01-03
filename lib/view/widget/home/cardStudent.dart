import 'package:flutter/material.dart';
import '../../../constants/appButton.dart';
import '../../../constants/color.dart';

class CardStudent extends StatelessWidget {
  final Map<String, dynamic> student;
  final VoidCallback? add_rep;
  final VoidCallback? review;
  // final VoidCallback? combinedDaily;
  final VoidCallback? updateData;
  final VoidCallback? dailyReports;
  final VoidCallback? reviewReports;
  final VoidCallback? showCurriculum;
  final VoidCallback? absence;
  final VoidCallback? viewPlan;

  const CardStudent({
    super.key,
    required this.student,
    this.add_rep,
    this.review,
    // this.combinedDaily,
    required this.updateData,
    required this.dailyReports,
    required this.reviewReports,
    required this.showCurriculum,
    required this.absence,
    this.viewPlan,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final onPrimary = theme.colorScheme.onPrimary;
    final secondary = theme.colorScheme.secondary;
    final onSecondary = theme.colorScheme.onSecondary;
    final tertiary = theme.colorScheme.tertiary;
    final onTertiary = theme.colorScheme.onTertiary;
    final primaryContainer = theme.colorScheme.primaryContainer;
    final onPrimaryContainer = theme.colorScheme.onPrimaryContainer;
    final secondaryContainer = theme.colorScheme.secondaryContainer;
    final onSecondaryContainer = theme.colorScheme.onSecondaryContainer;
    final error = theme.colorScheme.error;
    final onError = theme.colorScheme.onError;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary.withOpacity(0.9), primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Card(
        color: theme.cardColor.withOpacity(0.95),
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // العنوان واسم الطالب
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    student['name_student'],
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                    decoration: BoxDecoration(
                      color: primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      student['name_stages'],
                      style: theme.textTheme.bodySmall?.copyWith(color: onPrimary, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                "المستوى: ${student['name_level']}",
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Divider(thickness: 2, color: primary),
              const SizedBox(height: 12),

              // الأزرار (كل صف يحتوي على زرين)
              Column(
                children: [
                  // زر التسميع والمراجعة المدمج (يجبر على إدخال البيانات للاثنين)
                  // AppButton(
                  //   text: "التسميع والمراجعة معاً (إجباري)",
                  //   onPressed: combinedDaily,
                  //   height: 45,
                  //   color: Colors.deepPurple,
                  //   foregroundColor: Colors.white,
                  // ),
                  const SizedBox(height: 10),
                  // أزرار التسميع والمراجعة المنفصلة
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          text: "إضافة تسميع",
                          onPressed: add_rep,
                          height: 45,
                          color: primary,
                          foregroundColor: onPrimary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AppButton(
                          text: "إضافة مراجعة",
                          onPressed: review,
                          height: 45,
                          color: secondary,
                          foregroundColor: onSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          text: "تعديل البيانات",
                          onPressed: updateData,
                          height: 45,
                          color: tertiary,
                          foregroundColor: onTertiary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AppButton(
                          text: "تقرير التسميع",
                          onPressed: dailyReports,
                          height: 45,
                          color: primaryContainer,
                          foregroundColor: onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          text: "تقرير المراجعة",
                          onPressed: reviewReports,
                          height: 45,
                          color: secondaryContainer,
                          foregroundColor: onSecondaryContainer,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AppButton(
                          text: "تقرير الغياب",
                          onPressed: absence,
                          height: 45,
                          color: error,
                          foregroundColor: onError,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          text: " خطة الطالب",
                          onPressed: viewPlan,
                          height: 45,
                          color: Colors.purple,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),

                       Expanded(
                        child: AppButton(
                          text: "المنهج المصاحب",
                          onPressed: showCurriculum,
                          height: 45,
                          color: Colors.teal,
                          foregroundColor: Colors.white,
                        ),
                      ),


                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

}
