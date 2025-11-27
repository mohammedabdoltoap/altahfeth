import 'package:althfeth/constants/color.dart';
import 'package:althfeth/constants/app_theme.dart';
import 'package:althfeth/widgets/custom_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/function.dart';
import 'reports/TeacherAttendanceReport.dart';
import 'reports/LeaveRequestsReport.dart';
import 'reports/ResignationRequestsReport.dart';
import 'reports/TeacherPerformanceReport.dart';
import 'reports/StudentAttendanceReport.dart';
import 'reports/DailyRecitationReport.dart';
import 'reports/ReviewRecitationReport.dart';
import 'reports/AbsenceReport.dart';
import 'reports/ComprehensiveStudentPerformance.dart';
import 'reports/CircleStatisticsReport.dart';
import 'reports/ComprehensiveCircleReport.dart';
import 'reports/CircleComparisonReport.dart';
import 'reports/VisitStatisticsReport.dart';
import 'reports/VisitResultsReport.dart';
import 'reports/VisitNotesReport.dart';

class AdminReportsPage extends StatelessWidget {
  final AdminReportsController controller = Get.put(AdminReportsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: "التقارير الشاملة",
      ),
      body: CustomPageContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              // قسم تقارير الأساتذة
              CustomSectionHeader(
                title: "تقارير الأساتذة",
                icon: Icons.person_outline,
                color: AppTheme.teacherSectionColor,
                subtitle: "إدارة وتتبع بيانات الأساتذة",
              ),
              const SizedBox(height: AppTheme.spacingLarge),
              CustomReportGrid(
                cards: [
                  CustomReportCard(
                    title: "حضور وانصراف الأساتذة",
                    icon: Icons.access_time_outlined,
                    color: AppTheme.reportColors[0],
                    onTap: () => controller.showTeacherAttendanceReport(),
                    subtitle: "تتبع يومي",
                  ),
                  CustomReportCard(
                    title: "طلبات الإجازات",
                    icon: Icons.event_busy_outlined,
                    color: AppTheme.reportColors[1],
                    onTap: () => controller.showLeaveRequestsReport(),
                    subtitle: "إدارة الإجازات",
                  ),
                  CustomReportCard(
                    title: "طلبات الاستقالة",
                    icon: Icons.exit_to_app_outlined,
                    color: AppTheme.reportColors[2],
                    onTap: () => controller.showResignationReport(),
                    subtitle: "معالجة الطلبات",
                  ),
                  CustomReportCard(
                    title: "أداء الأساتذة",
                    icon: Icons.trending_up_outlined,
                    color: AppTheme.reportColors[3],
                    onTap: () => controller.showTeacherPerformanceReport(),
                    subtitle: "تقييم شامل",
                  ),
                ],
              ),

              const SizedBox(height: AppTheme.spacingXXLarge),

              // قسم تقارير الطلاب
              CustomSectionHeader(
                title: "تقارير الطلاب",
                icon: Icons.school_outlined,
                color: AppTheme.studentSectionColor,
                subtitle: "متابعة تقدم وأداء الطلاب",
              ),
              const SizedBox(height: AppTheme.spacingLarge),
              CustomReportGrid(
                cards: [
                  CustomReportCard(
                    title: "حضور وغياب الطلاب",
                    icon: Icons.how_to_reg_outlined,
                    color: AppTheme.reportColors[4],
                    onTap: () => controller.showStudentAttendanceReport(),
                    subtitle: "متابعة يومية",
                  ),
                  CustomReportCard(
                    title: "تقرير التسميع اليومي",
                    icon: Icons.book_outlined,
                    color: AppTheme.reportColors[5],
                    onTap: () => controller.showDailyRecitationReport(),
                    subtitle: "تسميع القرآن",
                  ),
                  CustomReportCard(
                    title: "تقرير المراجعة",
                    icon: Icons.refresh_outlined,
                    color: AppTheme.reportColors[0],
                    onTap: () => controller.showReviewReport(),
                    subtitle: "مراجعة المحفوظ",
                  ),
                  CustomReportCard(
                    title: "تقرير الغياب",
                    icon: Icons.event_busy_outlined,
                    color: AppTheme.reportColors[1],
                    onTap: () => controller.showAbsenceReport(),
                    subtitle: "تحليل الغياب",
                  ),
                  CustomReportCard(
                    title: "أداء الطلاب الشامل",
                    icon: Icons.assessment_outlined,
                    color: AppTheme.reportColors[2],
                    onTap: () => controller.showStudentPerformanceReport(),
                    subtitle: "تقييم متكامل",
                  ),
                ],
              ),

              const SizedBox(height: AppTheme.spacingXXLarge),

              // قسم تقارير الزيارات
              // CustomSectionHeader(
              //   title: "تقارير الزيارات الفنية",
              //   icon: Icons.assignment_outlined,
              //   color: AppTheme.visitSectionColor,
              //   subtitle: "متابعة وتقييم الزيارات الفنية",
              // ),
              // const SizedBox(height: AppTheme.spacingLarge),
              // CustomReportGrid(
              //   cards: [
              //     CustomReportCard(
              //       title: "نتائج الزيارات الفنية",
              //       icon: Icons.grading_outlined,
              //       color: AppTheme.reportColors[3],
              //       onTap: () => mySnackbar("قريبا..", "قيد التطوير", type: "g"),
              //       subtitle: "تقييم الأداء",
              //       isEnabled: false,
              //       badge: const CustomBadge(
              //         text: "قريباً",
              //         color: Colors.orange,
              //       ),
              //     ),
              //     CustomReportCard(
              //       title: "ملاحظات الزيارات",
              //       icon: Icons.note_alt_outlined,
              //       color: AppTheme.reportColors[4],
              //       onTap: () => mySnackbar("قريبا..", "قيد التطوير", type: "g"),
              //       subtitle: "توثيق الملاحظات",
              //       isEnabled: false,
              //       badge: const CustomBadge(
              //         text: "قريباً",
              //         color: Colors.orange,
              //       ),
              //     ),
              //     CustomReportCard(
              //       title: "إحصائيات الزيارات",
              //       icon: Icons.bar_chart_outlined,
              //       color: AppTheme.reportColors[5],
              //       onTap: () => mySnackbar("قريبا..", "قيد التطوير", type: "g"),
              //       subtitle: "تحليل البيانات",
              //       isEnabled: false,
              //       badge: const CustomBadge(
              //         text: "قريباً",
              //         color: Colors.orange,
              //       ),
              //     ),
              //   ],
              // ),

              // const SizedBox(height: AppTheme.spacingXXLarge),

              // قسم تقارير الحلقات
              // CustomSectionHeader(
              //   title: "تقارير الحلقات",
              //   icon: Icons.groups_outlined,
              //   color: AppTheme.circleSectionColor,
              //   subtitle: "إدارة ومتابعة أداء الحلقات",
              // ),
              // const SizedBox(height: AppTheme.spacingLarge),
              // CustomReportGrid(
              //   cards: [
              //     CustomReportCard(
              //       title: "إحصائيات الحلقات",
              //       icon: Icons.pie_chart,
              //       color: AppTheme.reportColors[0],
              //       onTap: () => mySnackbar("قريبا..", "قيد التطوير", type: "g"),
              //       subtitle: "تحليل شامل",
              //       isEnabled: false,
              //       badge: const CustomBadge(
              //         text: "قريباً",
              //         color: Colors.orange,
              //       ),
              //     ),
              //     CustomReportCard(
              //       title: "تقرير شامل للحلقة",
              //       icon: Icons.summarize_outlined,
              //       color: AppTheme.reportColors[1],
              //       onTap: () => mySnackbar("قريبا..", "قيد التطوير", type: "g"),
              //       subtitle: "تقرير مفصل",
              //       isEnabled: false,
              //       badge: const CustomBadge(
              //         text: "قريباً",
              //         color: Colors.orange,
              //       ),
              //     ),
              //     CustomReportCard(
              //       title: "مقارنة بين الحلقات",
              //       icon: Icons.compare_arrows_outlined,
              //       color: AppTheme.reportColors[2],
              //       onTap: () => mySnackbar("قريبا..", "قيد التطوير", type: "g"),
              //       subtitle: "تحليل مقارن",
              //       isEnabled: false,
              //       badge: const CustomBadge(
              //         text: "قريباً",
              //         color: Colors.orange,
              //       ),
              //     ),
              //   ],
              // ),


              // قسم تقارير عامة
              // _buildSectionHeader(
              //   "تقارير عامة",
              //   Icons.dashboard,
              //   Colors.blueGrey,
              // ),
              // const SizedBox(height: 12),
              // _buildReportGrid([
              //   ReportItem(
              //     title: "التقرير الشهري الشامل",
              //     icon: Icons.calendar_month,
              //     color: Colors.blueGrey,
              //     onTap: () => controller.showMonthlyComprehensiveReport(),
              //   ),
              //   ReportItem(
              //     title: "التقرير السنوي",
              //     icon: Icons.calendar_today,
              //     color: Colors.green,
              //     onTap: () => controller.showYearlyReport(),
              //   ),
              //   ReportItem(
              //     title: "تقرير مخصص",
              //     icon: Icons.tune,
              //     color: Colors.purple,
              //     onTap: () => controller.showCustomReport(),
              //   ),
              //   ReportItem(
              //     title: "تصدير جميع البيانات",
              //     icon: Icons.download,
              //     color: Colors.teal,
              //     onTap: () => controller.exportAllData(),
              //   ),
              // ]
              // ),
            ],
          ),
        ),

    );
  }
}

class AdminReportsController extends GetxController {
  var dataArg;

  @override
  void onInit() {
    super.onInit();
    dataArg = Get.arguments;
  }

  // تقارير الأساتذة
  void showTeacherAttendanceReport() {
    Get.to(() => TeacherAttendanceReport(), arguments: dataArg);
  }

  void showLeaveRequestsReport() {
    Get.to(() => LeaveRequestsReport(), arguments: dataArg);
  }

  void showResignationReport() {
    Get.to(() => ResignationRequestsReport(), arguments: dataArg);
  }

  void showTeacherPerformanceReport() {
    Get.to(() => TeacherPerformanceReport(), arguments: dataArg);
  }

  // تقارير الطلاب
  void showStudentAttendanceReport() {
    Get.to(() => StudentAttendanceReport(), arguments: dataArg);
  }

  void showDailyRecitationReport() {
    Get.to(() => DailyRecitationReport(), arguments: dataArg);
  }

  void showReviewReport() {
    Get.to(() => ReviewRecitationReport(), arguments: dataArg);
  }

  void showAbsenceReport() {
    Get.to(() => AbsenceReport(), arguments: dataArg);
  }

  void showStudentSkillsReport() {
    Get.snackbar("قريباً", "تقرير مهارات الطلاب");
  }

  void showStudentPerformanceReport() {
    Get.to(() => ComprehensiveStudentPerformance(), arguments: dataArg);
  }

  // تقارير الزيارات
  void showVisitResultsReport() {
    Get.to(() => VisitResultsReport(), arguments: dataArg);
  }

  void showVisitNotesReport() {
    Get.to(() => VisitNotesReport(), arguments: dataArg);
  }

  void showVisitStatisticsReport() {
    Get.to(() => VisitStatisticsReport(), arguments: dataArg);
  }

  // تقارير الحلقات
  void showCircleStatisticsReport() {
    Get.to(() => CircleStatisticsReport(), arguments: dataArg);
  }

  void showCircleComprehensiveReport() {
    Get.to(() => ComprehensiveCircleReport(), arguments: dataArg);
  }

  void showCircleComparisonReport() {
    Get.to(() => CircleComparisonReport(), arguments: dataArg);
  }

  // تقارير عامة
  void showMonthlyComprehensiveReport() {
    Get.snackbar("قريباً", "التقرير الشهري الشامل");
  }

  void showYearlyReport() {
    Get.snackbar("قريباً", "التقرير السنوي");
  }

  void showCustomReport() {
    Get.snackbar("قريباً", "تقرير مخصص");
  }

  void exportAllData() {
    Get.snackbar("قريباً", "تصدير جميع البيانات");
  }
}
