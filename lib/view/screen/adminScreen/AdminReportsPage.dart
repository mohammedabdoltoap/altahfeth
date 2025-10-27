import 'package:althfeth/constants/color.dart';
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
      appBar: AppBar(
        title: const Text("التقارير الشاملة"),
        backgroundColor: Colors.orange[400],
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.orange.shade50, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // قسم تقارير الأساتذة
              _buildSectionHeader(
                "تقارير الأساتذة",
                Icons.person,
                Colors.blue,
              ),
              const SizedBox(height: 12),
              _buildReportGrid([
                ReportItem(
                  title: "حضور وانصراف الأساتذة",
                  icon: Icons.access_time,
                  color: Colors.blue,
                  onTap: () => controller.showTeacherAttendanceReport(),
                ),
                ReportItem(
                  title: "طلبات الإجازات",
                  icon: Icons.event_busy,
                  color: Colors.purple,
                  onTap: () => controller.showLeaveRequestsReport(),
                ),
                ReportItem(
                  title: "طلبات الاستقالة",
                  icon: Icons.exit_to_app,
                  color: Colors.red,
                  onTap: () => controller.showResignationReport(),
                ),
                ReportItem(
                  title: "أداء الأساتذة",
                  icon: Icons.trending_up,
                  color: Colors.green,
                  onTap: () => controller.showTeacherPerformanceReport(),
                ),
              ]),

              const SizedBox(height: 24),

              // قسم تقارير الطلاب
              _buildSectionHeader(
                "تقارير الطلاب",
                Icons.school,
                Colors.teal,
              ),
              const SizedBox(height: 12),
              _buildReportGrid([
                ReportItem(
                  title: "حضور وغياب الطلاب",
                  icon: Icons.how_to_reg,
                  color: Colors.teal,
                  onTap: () => controller.showStudentAttendanceReport(),
                ),
                ReportItem(
                  title: "تقرير التسميع اليومي",
                  icon: Icons.book,
                  color: Colors.indigo,
                  onTap: () => controller.showDailyRecitationReport(),
                ),
                ReportItem(
                  title: "تقرير المراجعة",
                  icon: Icons.refresh,
                  color: Colors.orange,
                  onTap: () => controller.showReviewReport(),
                ),
                ReportItem(
                  title: "تقرير الغياب",
                  icon: Icons.event_busy,
                  color: Colors.red,
                  onTap: () => controller.showAbsenceReport(),
                ),
                ReportItem(
                  title: "مهارات الطلاب",
                  icon: Icons.star,
                  color: Colors.amber,
                  onTap: () => controller.showStudentSkillsReport(),
                ),
                ReportItem(
                  title: "أداء الطلاب الشامل",
                  icon: Icons.assessment,
                  color: Colors.deepPurple,
                  onTap: () => controller.showStudentPerformanceReport(),
                ),
              ]),

              const SizedBox(height: 24),

              // قسم تقارير الزيارات
              _buildSectionHeader(
                "تقارير الزيارات الفنية",
                Icons.assignment,
                Colors.deepOrange,
              ),
              const SizedBox(height: 12),
              _buildReportGrid([
                ReportItem(
                  title: "نتائج الزيارات الفنية",
                  icon: Icons.grading,
                  color: Colors.deepOrange,
                  onTap: () => controller.showVisitResultsReport(),
                ),
                ReportItem(
                  title: "ملاحظات الزيارات",
                  icon: Icons.note_alt,
                  color: Colors.brown,
                  onTap: () => controller.showVisitNotesReport(),
                ),
                ReportItem(
                  title: "إحصائيات الزيارات",
                  icon: Icons.bar_chart,
                  color: Colors.cyan,
                  onTap: () => controller.showVisitStatisticsReport(),
                ),
              ]),

              const SizedBox(height: 24),

              // قسم تقارير الحلقات
              _buildSectionHeader(
                "تقارير الحلقات",
                Icons.groups,
                Colors.pink,
              ),
              const SizedBox(height: 12),
              _buildReportGrid([
                ReportItem(
                  title: "إحصائيات الحلقات",
                  icon: Icons.pie_chart,
                  color: Colors.pink,
                  onTap: () => controller.showCircleStatisticsReport(),
                ),
                ReportItem(
                  title: "تقرير شامل للحلقة",
                  icon: Icons.summarize,
                  color: Colors.lightBlue,
                  onTap: () => controller.showCircleComprehensiveReport(),
                ),
                ReportItem(
                  title: "مقارنة بين الحلقات",
                  icon: Icons.compare_arrows,
                  color: Colors.deepPurple,
                  onTap: () => controller.showCircleComparisonReport(),
                ),
              ]),

              const SizedBox(height: 24),

              // قسم تقارير عامة
              _buildSectionHeader(
                "تقارير عامة",
                Icons.dashboard,
                Colors.blueGrey,
              ),
              const SizedBox(height: 12),
              _buildReportGrid([
                ReportItem(
                  title: "التقرير الشهري الشامل",
                  icon: Icons.calendar_month,
                  color: Colors.blueGrey,
                  onTap: () => controller.showMonthlyComprehensiveReport(),
                ),
                ReportItem(
                  title: "التقرير السنوي",
                  icon: Icons.calendar_today,
                  color: Colors.green,
                  onTap: () => controller.showYearlyReport(),
                ),
                ReportItem(
                  title: "تقرير مخصص",
                  icon: Icons.tune,
                  color: Colors.purple,
                  onTap: () => controller.showCustomReport(),
                ),
                ReportItem(
                  title: "تصدير جميع البيانات",
                  icon: Icons.download,
                  color: Colors.teal,
                  onTap: () => controller.exportAllData(),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.7)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportGrid(List<ReportItem> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildReportCard(item);
      },
    );
  }

  Widget _buildReportCard(ReportItem item) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [item.color.withOpacity(0.1), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: item.color.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: item.onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: item.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    item.icon,
                    size: 36,
                    color: item.color,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  item.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: item.color.withOpacity(0.9),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ReportItem {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  ReportItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });
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
