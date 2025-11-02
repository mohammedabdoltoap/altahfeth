import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants/function.dart';
import '../../../controller/home_cont.dart';
import '../../../globals.dart';
import '../../screen/LeaveRequestsPage.dart';
import '../../screen/studentScreen/ParentsContactsPage.dart';
import '../../screen/attendance.dart';
import '../../screen/home.dart';
import '../../screen/login.dart';
import '../../screen/teacherScreen/TeacherResignationPage.dart';
import '../../screen/teacherScreen/VisitResultsPage.dart';
import '../../screen/skillsScreen/StudentList_Skill.dart';
import '../../screen/updateAttendance.dart';
import '../../screen/user_attendance.dart';
import '../../screen/circlesScreen/CirclesListScreen.dart';
import '../../screen/promotion_pending.dart';

class AppDrawer extends StatelessWidget {
  final HomeCont homeCont = Get.find();

  // دالة مساعدة للتحقق من الإجازة قبل التنقل
  void _navigateIfNotHoliday(BuildContext context, Widget Function() pageBuilder, {Map<String, dynamic>? arguments,}) {
    if (holidayData["is_holiday"] != null) {
      if (!holidayData["is_holiday"]) {
        // التنقل بشكل آمن بحيث يُنشئ الصفحة ديناميكيًا
        Get.to(pageBuilder, arguments: arguments ?? homeCont.dataArg);
      } else {
        mySnackbar("تنبيه", "إجازة بمناسبة ${holidayData["reason"]}", type: "y");
      }
    }
    // لا نعرض رسالة هنا لأن handleRequest يتولى عرض رسالة خطأ الشبكة
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Drawer(
      child: SafeArea(
        child: Container(
          color: theme.colorScheme.surface,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              // رأس Drawer محسّن
              _buildDrawerHeader(theme),
              const SizedBox(height: 8),

              // القسم الأول: التنقل الأساسي
              _buildSectionTitle("التنقل", theme),
              _drawerItem(
                icon: Icons.home_rounded,
                text: "الرئيسية",
                onTap: () {
                  Get.back();
                  Get.to(() => Home());
                },
                theme: theme,
              ),

              // القسم الثاني: الحضور والغياب
              const SizedBox(height: 8),
              _buildSectionTitle("الحضور والغياب", theme),
              _drawerItem(
                icon: Icons.how_to_reg_rounded,
                text: "حضور وغياب الطلاب",
                onTap: () => _handleStudentAttendance(context),
                theme: theme,
              ),
              _drawerItem(
                icon: Icons.login_rounded,
                text: "حضور وانصراف المعلم",
                onTap: () => _navigateIfNotHoliday(context, () => User_Attendance()),
                theme: theme,
              ),

              // القسم الثالث: الطلبات
              const SizedBox(height: 8),
              _buildSectionTitle("الطلبات", theme),
              _drawerItem(
                icon: Icons.event_available_rounded,
                text: "طلب إجازة",
                onTap: () => _navigateIfNotHoliday(context, () => LeaveRequestsPage()),
                theme: theme,
              ),
              _drawerItem(
                icon: Icons.exit_to_app_rounded,
                text: "طلب استقالة",
                onTap: () => _navigateIfNotHoliday(context, () => TeacherResignationPage()),
                theme: theme,
              ),
              _drawerItem(
                icon: Icons.history_rounded,
                text: "الترفيعات المعلقة",
                onTap: () {
                  Get.back();
                  Get.to(() => const PromotionPendingScreen());
                },
                theme: theme,
              ),

              // القسم الرابع: الأنشطة التعليمية
              const SizedBox(height: 8),
              _buildSectionTitle("الأنشطة التعليمية", theme),
              _drawerItem(
                icon: Icons.stars_rounded,
                text: "المهارات",
                onTap: () => _navigateIfNotHoliday(context, () => StudentList_Skill()),
                theme: theme,
              ),
              _drawerItem(
                icon: Icons.assignment_turned_in_rounded,
                text: "نتائج الطلاب",
                onTap: () {
                  Get.back();
                  Get.to(() => VisitResultsPage(), arguments: homeCont.dataArg);
                },
                theme: theme,
              ),
              _drawerItem(
                icon: Icons.note_alt_rounded,
                text: "الملاحظات",
                onTap: () {
                  Get.back();

                },
                theme: theme,
              ),

              _drawerItem(
                icon: Icons.note_alt_rounded,
                text: "اضافة زيارة",
                onTap: () {
                  Get.back();
         homeCont.showVisitorDialog(context: context);

                },
                theme: theme,
              ),

              // القسم الخامس: التواصل
              const SizedBox(height: 8),
              _buildSectionTitle("التواصل", theme),
              _drawerItem(
                icon: Icons.contacts_rounded,
                text: "تواصل مع أولياء الأمور",
                onTap: () {
                  Get.back();
                  Get.to(() => ParentsContactsPage(), arguments: homeCont.dataArg);
                },
                theme: theme,
              ),

              // الفاصل
              const SizedBox(height: 16),
              Divider(color: theme.dividerColor, thickness: 1, height: 1),
              const SizedBox(height: 8),

              // تسجيل الخروج
              _drawerItem(
                icon: Icons.logout_rounded,
                text: "تسجيل الخروج",
                onTap: () => _handleLogout(context),
                theme: theme,
                isDestructive: true,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // بناء رأس Drawer
  Widget _buildDrawerHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.8),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person_rounded,
              size: 45,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "أهلاً بك",
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "الأستاذ ${homeCont.dataArg["username"]}",
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // بناء عنوان القسم
  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        title,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // عنصر Drawer محسّن
  Widget _drawerItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    required ThemeData theme,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : theme.colorScheme.primary,
        size: 24,
      ),
      title: Text(
        text,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: isDestructive ? Colors.red : null,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.chevron_left_rounded,
        color: theme.colorScheme.onSurface.withOpacity(0.3),
        size: 20,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      hoverColor: theme.colorScheme.primary.withOpacity(0.05),
    );
  }

  // معالجة حضور الطلاب
  Future<void> _handleStudentAttendance(BuildContext context) async {
    await homeCont.check_attendance();
    
    // إذا كان null، فقد حدث خطأ في الشبكة (handleRequest عرض الرسالة بالفعل)
    if (homeCont.statCheck_Attendance.value == null) {
      return;
    }

    if (holidayData["is_holiday"] != null && holidayData["is_holiday"]) {
      mySnackbar("تنبيه", "إجازة بمناسبة ${holidayData["reason"]}", type: "y");
      return;
    }

    if (homeCont.statCheck_Attendance.value == 1) {
      Get.back();
      Get.to(() => Attendance(), arguments: homeCont.dataArg);
      homeCont.statCheck_Attendance.value = null;
    } else {
      bool? confirm = await showConfirmDialog(
        context: context,
        title: "تحديث الحضور",
        message: "لقد تم تحضير الطلاب لهذا اليوم. هل تريد إلغاءه وإعادة التحضير؟",
        yesText: "نعم، إعادة التحضير",
        noText: "إلغاء",
      );
      
      if (confirm == true) {
        Get.back();
        Get.to(() => UpdateAttendance(), arguments: homeCont.dataArg);
      }
    }
  }

  // معالجة تسجيل الخروج
  Future<void> _handleLogout(BuildContext context) async {
    bool? confirm = await showConfirmDialog(
      context: context,
      title: "تسجيل الخروج",
      message: "هل أنت متأكد من رغبتك في تسجيل الخروج؟",
      yesText: "تسجيل الخروج",
      noText: "إلغاء",
    );

    if (confirm == true) {
      data_user_globle.clear();
      Get.offAll(() => Login());
      mySnackbar("تم بنجاح", "تم تسجيل الخروج بنجاح", type: "g");
    }
  }








}
