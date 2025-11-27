import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants/function.dart';
import '../../../constants/color.dart';
import '../../../controller/home_cont.dart';
import '../../../globals.dart';
import '../../screen/LeaveRequestsPage.dart';
import '../../screen/LogoutScreen.dart';
import '../../screen/studentScreen/ParentsContactsPage.dart';
import '../../screen/studentScreen/attendance.dart';
import '../../screen/home.dart';
import '../../screen/login.dart';
import '../../screen/studentScreen/updateAttendance.dart';
import '../../screen/teacherScreen/TeacherResignationPage.dart';
import '../../screen/teacherScreen/VisitResultsPage.dart';
import '../../screen/skillsScreen/StudentList_Skill.dart';
import '../../screen/user_attendance.dart';
import '../../screen/circlesScreen/CirclesListScreen.dart';
import '../../screen/UserGuide.dart';
import '../../screen/activities/AddActivityPage.dart';
import '../../screen/activities/ActivitiesListPage.dart';
import '../../screen/reportsScreen/ReportsMenu.dart';

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
                icon: Icons.fingerprint_rounded,
                text: "حضور وانصراف المعلم",
                onTap: () => _navigateIfNotHoliday(context, () => User_Attendance()),
                theme: theme,
              ),
              _drawerItem(
                icon: Icons.how_to_reg_rounded,
                text: "حضور وغياب الطلاب",
                onTap: () => _handleStudentAttendance(context),
                theme: theme,
              ),

              // القسم الثالث: إدارة الطلاب
              const SizedBox(height: 8),
              _buildSectionTitle("إدارة الطلاب", theme),
              _drawerItem(
                icon: Icons.auto_awesome_rounded,
                text: "إدارة مهارات الطلاب",
                onTap: () => _navigateIfNotHoliday(context, () => StudentList_Skill()),
                theme: theme,
              ),
              _drawerItem(
                icon: Icons.quiz_rounded,
                text: "نتائج الاختبارات الشهرية",
                onTap: () {
                  Get.back();
                  _navigateIfNotHoliday(context, () => VisitResultsPage());
                },
                theme: theme,
              ),
              _drawerItem(
                icon: Icons.description_rounded,
                text: "ملاحظات الاختبارات الشهرية",
                onTap: () async {
                  Get.back();

                  // التحقق من الإجازة
                  if (holidayData["is_holiday"] != null && holidayData["is_holiday"]) {
                    mySnackbar("تنبيه", "إجازة بمناسبة ${holidayData["reason"]}", type: "y");
                    return;
                  }
                  
                  // سجل حضور - انتقل للصفحة
                  Get.to(() => CirclesListScreen(), arguments: homeCont.dataArg);
                },
                theme: theme,
              ),

              // القسم الرابع: الأنشطة
              const SizedBox(height: 8),
              _buildSectionTitle("الأنشطة", theme),
              _drawerItem(
                icon: Icons.add_circle_outline_rounded,
                text: "إضافة نشاط",
                onTap: () {
                  Get.back();
                  _navigateIfNotHoliday(context, () => AddActivityPage());
                },
                theme: theme,
              ),
              _drawerItem(
                icon: Icons.event_available_rounded,
                text: "الأنشطة السابقة",
                onTap: () {
                  Get.back();
                  _navigateIfNotHoliday(context, () => ActivitiesListPage());
                },
                theme: theme,
              ),

              // القسم الخامس: الزيارات
              const SizedBox(height: 8),
              _buildSectionTitle("الزيارات", theme),
              _drawerItem(
                icon: Icons.location_on_rounded,
                text: "إضافة زيارة عامة",
                onTap: () async {
                  Get.back();
                  // التحقق من الإجازة
                  if (holidayData["is_holiday"] != null && holidayData["is_holiday"]) {
                    mySnackbar("تنبيه", "إجازة بمناسبة ${holidayData["reason"]}", type: "y");
                    return;
                  }
                  
                  // التحقق من حضور الأستاذ
                  await homeCont.check_teacher_attendance();
                  
                  if (homeCont.statTeacherAttendance.value == null) {
                    mySnackbar("تنبيه", "حدث خطأ في التحقق من حضورك");
                    return;
                  }
                  
                  if (homeCont.statTeacherAttendance.value == 0) {
                    // لم يسجل حضور
                    Get.defaultDialog(
                      title: "تسجيل الحضور مطلوب",
                      middleText: "يجب تسجيل حضورك قبل إضافة زيارة.\n\nهل تريد الانتقال إلى صفحة تسجيل الحضور والانصراف؟",
                      textConfirm: "الانتقال",
                      textCancel: "إلغاء",
                      confirmTextColor: Colors.white,
                      onConfirm: () {
                        Get.back();
                        Get.to(() => User_Attendance(), arguments: homeCont.dataArg);
                      },
                    );
                    return;
                  }
                  
                  // سجل حضور - اعرض dialog الزيارة
                  homeCont.showVisitorDialog(context: Get.context!);
                },
                theme: theme,
              ),

              // القسم السادس: التقارير
              const SizedBox(height: 8),
              _buildSectionTitle("التقارير", theme),
              _drawerItem(
                icon: Icons.assessment_rounded,
                text: "تقارير الحلقة",
                onTap: () {
                  Get.back();
                  Get.to(() => ReportsMenu(), arguments: homeCont.dataArg);
                },
                theme: theme,
              ),

              // القسم السابع: التواصل
              const SizedBox(height: 8),
              _buildSectionTitle("التواصل", theme),
              _drawerItem(
                icon: Icons.family_restroom_rounded,
                text: "تواصل مع أولياء الأمور",
                onTap: () {
                  Get.back();
                  _navigateIfNotHoliday(context, () => ParentsContactsPage());
                },
                theme: theme,
              ),

              // القسم الثامن: الطلبات
              const SizedBox(height: 8),
              _buildSectionTitle("الطلبات", theme),
              _drawerItem(
                icon: Icons.beach_access_rounded,
                text: "طلب إجازة",
                onTap: () => _navigateIfNotHoliday(context, () => LeaveRequestsPage()),
                theme: theme,
              ),
              _drawerItem(
                icon: Icons.logout_rounded,
                text: "طلب استقالة",
                onTap: () => _navigateIfNotHoliday(context, () => TeacherResignationPage()),
                theme: theme,
              ),

              // الفاصل
              const SizedBox(height: 16),
              Divider(color: theme.dividerColor, thickness: 1, height: 1),
              const SizedBox(height: 8),
              _buildSectionTitle("المساعدة", theme),
              _drawerItem(
                icon: Icons.help_outline_rounded,
                text: "دليل الاستخدام",
                onTap: () {
                  Get.back();
                  Get.to(() => const UserGuide());
                },
                theme: theme,
              ),

              const SizedBox(height: 8),

              // تبديل الحلقة (للأساتذة فقط)
              if (data_user_globle["type_user"] == "2") ...[
                _drawerItem(
                  icon: Icons.swap_horiz_rounded,
                  text: "تبديل الحلقة",
                  onTap: () => _handleSwitchCircle(context),
                  theme: theme,
                ),
                const SizedBox(height: 8),
              ],

              // تسجيل الخروج
              _drawerItem(
                icon: Icons.exit_to_app_rounded,
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

  // معالجة تبديل الحلقة
  Future<void> _handleSwitchCircle(BuildContext context) async {
    Get.back(); // إغلاق الـ Drawer
    
    // الحصول على قائمة الحلقات من البيانات المخزنة
    final circles = data_user_globle["circles"] as List?;
    
    if (circles == null || circles.isEmpty) {
      mySnackbar("تنبيه", "لا توجد حلقات متاحة", type: "y");
      return;
    }
    
    // عرض قائمة الحلقات للاختيار
    await Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.swap_horiz_rounded, color: primaryGreen),
            const SizedBox(width: 8),
            const Text("اختر الحلقة"),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: circles.length,
            itemBuilder: (context, index) {
              final circle = circles[index];
              final isCurrentCircle = circle["id_circle"] == data_user_globle["id_circle"];
              
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isCurrentCircle ? primaryGreen.withOpacity(0.1) : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isCurrentCircle ? primaryGreen : Colors.grey.shade300,
                    width: isCurrentCircle ? 2 : 1,
                  ),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isCurrentCircle ? primaryGreen : childyGreen,
                    child: Icon(
                      Icons.group_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    circle["name_circle"] ?? "حلقة",
                    style: TextStyle(
                      fontWeight: isCurrentCircle ? FontWeight.bold : FontWeight.normal,
                      color: isCurrentCircle ? primaryGreen : Colors.black87,
                    ),
                  ),
                  trailing: isCurrentCircle
                      ? Icon(Icons.check_circle, color: primaryGreen)
                      : Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: isCurrentCircle
                      ? null
                      : () {
                          _switchToCircle(circle);
                          Get.back();
                        },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("إلغاء", style: TextStyle(color: Colors.grey.shade600)),
          ),
        ],
      ),
    );
  }
  
  // تبديل إلى حلقة معينة
  void _switchToCircle(Map<String, dynamic> circle) {
    // تحديث بيانات الحلقة الحالية
    data_user_globle["id_circle"] = circle["id_circle"];
    data_user_globle["name_circle"] = circle["name_circle"];
    
    // إعادة تحميل الصفحة الرئيسية
    Get.offAll(() => Home());
    
    mySnackbar(
      "تم بنجاح",
      "تم التبديل إلى حلقة: ${circle["name_circle"]}",
      type: "g",
    );
  }

  // معالجة تسجيل الخروج
  Future<void> _handleLogout(BuildContext context) async {
    Get.to(
      () => LogoutScreen(),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 500),
    );
  }

  // التحقق من الحضور قبل الانتقال
  Future<void> _checkAttendanceAndNavigate(
    BuildContext context,
    Widget Function() pageBuilder,
    String message,
  ) async {
    // التحقق من الإجازة
    if (holidayData["is_holiday"] != null && holidayData["is_holiday"]) {
      mySnackbar("تنبيه", "إجازة بمناسبة ${holidayData["reason"]}", type: "y");
      return;
    }

    // التحقق من حضور الأستاذ
    await homeCont.check_teacher_attendance();
    
    if (homeCont.statTeacherAttendance.value == null) {
      mySnackbar("تنبيه", "حدث خطأ في التحقق من حضورك");
      return;
    }
    
    if (homeCont.statTeacherAttendance.value == 0) {
      // التحقق من صلاحية context
      if (!context.mounted) return;
      
      // عرض dialog للانتقال لصفحة الحضور
      bool? goToAttendance = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("تسجيل الحضور مطلوب"),
          content: Text("$message\n\nهل تريد الانتقال إلى صفحة تسجيل الحضور والانصراف؟"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("إلغاء"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("الانتقال"),
            ),
          ],
        ),
      );
      
      if (goToAttendance == true) {
        Get.to(() => User_Attendance(), arguments: homeCont.dataArg);
      }
      return;
    }
    
    // إذا سجل حضوره، انتقل للصفحة
    Get.to(pageBuilder, arguments: homeCont.dataArg);
  }

  // التحقق من الحضور قبل عرض dialog الزيارة
  Future<void> _checkAttendanceAndShowDialog(BuildContext context) async {
    // التحقق من الإجازة
    if (holidayData["is_holiday"] != null && holidayData["is_holiday"]) {
      mySnackbar("تنبيه", "إجازة بمناسبة ${holidayData["reason"]}", type: "y");
      return;
    }

    // التحقق من حضور الأستاذ
    await homeCont.check_teacher_attendance();
    
    if (homeCont.statTeacherAttendance.value == null) {
      mySnackbar("تنبيه", "حدث خطأ في التحقق من حضورك");
      return;
    }
    
    if (homeCont.statTeacherAttendance.value == 0) {
      // التحقق من صلاحية context
      if (!context.mounted) return;
      
      // عرض dialog للانتقال لصفحة الحضور
      bool? goToAttendance = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("تسجيل الحضور مطلوب"),
          content: const Text("يجب تسجيل حضورك قبل إضافة زيارة.\n\nهل تريد الانتقال إلى صفحة تسجيل الحضور والانصراف؟"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("إلغاء"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("الانتقال"),
            ),
          ],
        ),
      );
      
      if (goToAttendance == true) {
        Get.to(() => User_Attendance(), arguments: homeCont.dataArg);
      }
      return;
    }
    
    // التحقق من صلاحية context قبل عرض dialog الزيارة
    if (!context.mounted) return;
    
    // إذا سجل حضوره، اعرض dialog الزيارة
    homeCont.showVisitorDialog(context: context);
  }
}
