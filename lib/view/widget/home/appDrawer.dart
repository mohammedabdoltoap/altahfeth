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
import '../../screen/studentScreen/pendingStudentsManagement.dart';
import '../../screen/studentScreen/updateAttendance.dart';
import '../../screen/teacherScreen/Curriculum.dart';
import '../../screen/teacherScreen/TeacherResignationPage.dart';
import '../../screen/teacherScreen/VisitResultsPage.dart';
import '../../screen/teacherScreen/EditEmployeeProfile.dart';
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
  void _navigateIfNotHoliday(
    BuildContext context,
    Widget Function() pageBuilder, {
    Map<String, dynamic>? arguments,
  }) {
    // التحقق من إذا كان اليوم إجازة
    if (holidayData["is_holiday"] == true) {
      // اليوم إجازة
      mySnackbar("تنبيه", "إجازة بمناسبة ${holidayData["reason"] ?? 'إجازة'}",
          type: "y");
    } else {
      // اليوم ليس إجازة - التنقل بشكل آمن
      Get.to(pageBuilder, arguments: arguments ?? homeCont.dataArg);
    }
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
              
              const SizedBox(height: 4),
              Divider(color: theme.dividerColor.withOpacity(0.5), thickness: 1, height: 1),
              const SizedBox(height: 4),

              // القسم الأول: الرئيسية
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
              const SizedBox(height: 4),
              Divider(color: theme.dividerColor.withOpacity(0.3), thickness: 0.5, height: 1),
              _buildSectionTitle("الحضور والغياب", theme),
              _drawerItem(
                icon: Icons.fingerprint_rounded,
                text: "حضور وانصراف المعلم",
                onTap: () {
                  Get.back();
                  Get.to(() => User_Attendance(), arguments: homeCont.dataArg);
                },
                theme: theme,
              ),
              _drawerItem(
                icon: Icons.how_to_reg_rounded,
                text: "حضور وغياب الطلاب",
                onTap: () => _handleStudentAttendance(context),
                theme: theme,
              ),

              // القسم الثالث: إدارة الطلاب
              const SizedBox(height: 4),
              Divider(color: theme.dividerColor.withOpacity(0.3), thickness: 0.5, height: 1),
              _buildSectionTitle("إدارة الطلاب", theme),
              _drawerItem(
                icon: Icons.person_add_rounded,
                text: "إدارة الطلاب المعلقين",
                onTap: () {
                  if (connectivityHelper.hasConnection)
                    Get.to(() => PendingStudentsManagement(),
                        arguments: homeCont.dataArg);
                  else {
                    mySnackbar("تنبيه", "تحقق من الاتصال بالإنترنت");
                  }
                },
                theme: theme,
              ),
              _drawerItem(
                icon: Icons.auto_awesome_rounded,
                text: "إدارة مهارات الطلاب",
                onTap: () {
                  if (connectivityHelper.hasConnection)
                    _navigateIfNotHoliday(context, () => StudentList_Skill());
                  else {
                    mySnackbar("تنبيه",
                        "من الضروري الاتصال بالإنترنت لإجراء هذه العملية");
                  }
                },
                theme: theme,
              ),

              // القسم الرابع: الاختبارات والتقييم
              const SizedBox(height: 4),
              Divider(color: theme.dividerColor.withOpacity(0.3), thickness: 0.5, height: 1),
              _buildSectionTitle("الاختبارات والتقييم", theme),
              _drawerItem(
                icon: Icons.quiz_rounded,
                text: "نتائج الاختبارات الشهرية",
                onTap: () {
                  if (connectivityHelper.hasConnection)
                    _navigateIfNotHoliday(context, () => VisitResultsPage());
                  else {
                    mySnackbar("تنبيه",
                        "من الضروري الاتصال بالإنترنت لإجراء هذه العملية");
                  }
                },
                theme: theme,
              ),
              _drawerItem(
                icon: Icons.description_rounded,
                text: "ملاحظات الاختبارات",
                onTap: () async {
                  if (holidayData["is_holiday"] == true) {
                    mySnackbar("تنبيه",
                        "إجازة بمناسبة ${holidayData["reason"] ?? 'إجازة'}",
                        type: "y");
                    return;
                  }
                  if (connectivityHelper.hasConnection)
                    Get.to(() => CirclesListScreen(),
                        arguments: homeCont.dataArg);
                  else {
                    mySnackbar("تنبيه",
                        "من الضروري الاتصال بالإنترنت لإجراء هذه العملية");
                  }
                },
                theme: theme,
              ),

              // القسم الخامس: التقارير
              const SizedBox(height: 4),
              Divider(color: theme.dividerColor.withOpacity(0.3), thickness: 0.5, height: 1),
              _buildSectionTitle("التقارير", theme),
              _drawerItem(
                icon: Icons.assessment_rounded,
                text: "تقارير الحلقة",
                onTap: () {
                  if (connectivityHelper.hasConnection) {
                    _navigateIfNotHoliday(context, () => ReportsMenu());
                  } else {
                    mySnackbar("تنبيه",
                        "من الضروري الاتصال بالإنترنت لإجراء هذه العملية");
                  }
                },
                theme: theme,
              ),

              // القسم السادس: الزيارات
              const SizedBox(height: 4),
              Divider(color: theme.dividerColor.withOpacity(0.3), thickness: 0.5, height: 1),
              _buildSectionTitle("الزيارات", theme),
              _drawerItem(
                icon: Icons.location_on_rounded,
                text: "إضافة زيارة عامة",
                onTap: () async {
                  // التحقق من الإجازة
                  if (holidayData["is_holiday"] == true) {
                    mySnackbar("تنبيه",
                        "إجازة بمناسبة ${holidayData["reason"] ?? 'إجازة'}",
                        type: "y");
                    return;
                  }
                  if (connectivityHelper.hasConnection) {
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
                        middleText:
                            "يجب تسجيل حضورك قبل إضافة زيارة.\n\nهل تريد الانتقال إلى صفحة تسجيل الحضور والانصراف؟",
                        textConfirm: "الانتقال",
                        textCancel: "إلغاء",
                        confirmTextColor: Colors.white,
                        onConfirm: () {
                          Get.back();
                          Get.to(() => User_Attendance(),
                              arguments: homeCont.dataArg);
                        },
                      );
                      return;
                    }

                    // سجل حضور - اعرض dialog الزيارة
                    homeCont.showVisitorDialog(context: Get.context!);
                  } else {
                    mySnackbar("تنبية",
                        "من الضروري الاتصال الانترنت لاجراء هذه العملية");
                  }
                },
                theme: theme,
              ),

              // القسم السابع: الأنشطة
              const SizedBox(height: 4),
              Divider(color: theme.dividerColor.withOpacity(0.3), thickness: 0.5, height: 1),
              _buildSectionTitle("الأنشطة", theme),
              _drawerItem(
                icon: Icons.add_circle_outline_rounded,
                text: "إضافة نشاط",
                onTap: () {
                  if (connectivityHelper.hasConnection)
                    _navigateIfNotHoliday(context, () => AddActivityPage());
                  else {
                    mySnackbar("تنبيه",
                        "من الضروري الاتصال بالإنترنت لإجراء هذه العملية");
                  }
                },
                theme: theme,
              ),
              _drawerItem(
                icon: Icons.event_available_rounded,
                text: "الأنشطة السابقة",
                onTap: () {
                  if (connectivityHelper.hasConnection)
                    _navigateIfNotHoliday(context, () => ActivitiesListPage());
                  else {
                    mySnackbar("تنبيه",
                        "من الضروري الاتصال بالإنترنت لإجراء هذه العملية");
                  }
                },
                theme: theme,
              ),

              // القسم الثامن: التواصل
              const SizedBox(height: 4),
              Divider(color: theme.dividerColor.withOpacity(0.3), thickness: 0.5, height: 1),
              _buildSectionTitle("التواصل", theme),
              _drawerItem(
                icon: Icons.family_restroom_rounded,
                text: "تواصل مع أولياء الأمور",
                onTap: () {
                  if (connectivityHelper.hasConnection) {
                    _navigateIfNotHoliday(context, () => ParentsContactsPage());
                  } else {
                    mySnackbar("تنبيه",
                        "من الضروري الاتصال بالإنترنت لإجراء هذه العملية");
                  }
                },
                theme: theme,
              ),

              // القسم التاسع: الطلبات
              const SizedBox(height: 4),
              Divider(color: theme.dividerColor.withOpacity(0.3), thickness: 0.5, height: 1),
              _buildSectionTitle("الطلبات", theme),
              _drawerItem(
                icon: Icons.beach_access_rounded,
                text: "طلب إجازة",
                onTap: () {
                  if (connectivityHelper.hasConnection) {
                    _navigateIfNotHoliday(context, () => LeaveRequestsPage());
                  } else {
                    mySnackbar("تنبيه",
                        "من الضروري الاتصال بالإنترنت لإجراء هذه العملية");
                  }
                },
                theme: theme,
              ),
              _drawerItem(
                icon: Icons.logout_rounded,
                text: "طلب استقالة",
                onTap: () {
                  if (connectivityHelper.hasConnection) {
                    _navigateIfNotHoliday(
                        context, () => TeacherResignationPage());
                  } else {
                    mySnackbar("تنبيه",
                        "من الضروري الاتصال بالإنترنت لإجراء هذه العملية");
                  }
                },
                theme: theme,
              ),

              // القسم العاشر: المزامنة
              const SizedBox(height: 4),
              Divider(color: theme.dividerColor.withOpacity(0.3), thickness: 0.5, height: 1),
              _buildSectionTitle("المزامنة", theme),
              _drawerItem(
                icon: Icons.sync_rounded,
                text: "مزامنة البيانات",
                onTap: ()async {
                  if (connectivityHelper.hasConnection) {
                    print('\n✅ يوجد اتصال بالإنترنت - بدء المزامنة الشاملة');

                    // عرض dialog المزامنة
                    Get.dialog(
                      WillPopScope(
                        onWillPop: () async => false,
                        child: Dialog(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const CircularProgressIndicator(),
                                const SizedBox(height: 20),
                                const Text(
                                  'جاري التهئية...',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'يرجى الانتظار حتى اكتمال التحقق من المزامنة',
                                  style: TextStyle(fontSize: 14, color: Colors.grey),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      barrierDismissible: false,
                    );

                    try {

                      await homeCont.users_attendancePending();
                      await homeCont.dailyReportsPending();
                      await homeCont.reviewsPending();
                      await homeCont.studentAttendancePending();

                      // 4️⃣ تنظيف السجلات القديمة
                      await homeCont.cleanupOldRecords();

                      print('\n✅ اكتملت جميع عمليات المزامنة بنجاح\n');
                    } finally {
                      // إغلاق dialog المزامنة
                      if (Get.isDialogOpen ?? false) {
                        Get.back();
                      }
                    }
                  }


                  // if (connectivityHelper.hasConnection) {
                  //   homeCont.users_attendancePending();
                  //   homeCont.dailyReportsPending(); // مزامنة التسميع اليومي
                  //   homeCont.reviewsPending(); // مزامنة المراجعات
                  //   homeCont.studentAttendancePending(); // مزامنة حضور الطلاب
                  // }
                  //
                  else {
                    mySnackbar("تنبيه", "تحقق من الاتصال بالإنترنت");
                  }
                },
                theme: theme,
              ),

              // القسم الحادي عشر: الإعدادات
              const SizedBox(height: 4),
              Divider(color: theme.dividerColor.withOpacity(0.3), thickness: 0.5, height: 1),
              _buildSectionTitle("الإعدادات", theme),
              _drawerItem(
                icon: Icons.person_outline_rounded,
                text: "تعديل البيانات الشخصية",
                onTap: () {
                  Get.back();
                  Get.to(() => EditEmployeeProfile(), arguments: homeCont.dataArg);
                },
                theme: theme,
              ),
              _drawerItem(
                icon: Icons.help_outline_rounded,
                text: "دليل الاستخدام",
                onTap: () {
                  Get.back();
                  Get.to(() => const UserGuide());
                },
                theme: theme,
              ),

              // الفاصل النهائي
              const SizedBox(height: 8),
              Divider(color: theme.dividerColor, thickness: 1, height: 1),
              const SizedBox(height: 8),

              // تبديل الحلقة (للأساتذة فقط)
              // if (data_user_globle["role_id"] == 4) ...[
              //   _drawerItem(
              //     icon: Icons.swap_horiz_rounded,
              //     text: "تبديل الحلقة",
              //     onTap: () {
              //       if (connectivityHelper.hasConnection) {
              //         _handleSwitchCircle(context);
              //       } else {
              //         mySnackbar("تنبيه",
              //             "من الضروري الاتصال بالإنترنت لإجراء هذه العملية");
              //       }
              //     },
              //     theme: theme,
              //   ),
              //   const SizedBox(height: 8),
              // ],

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
      Obx(() => Text(
            "الأستاذ ${homeCont.nameUser.value}",
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),)
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

    if (holidayData["is_holiday"] == true) {
      mySnackbar("تنبيه", "إجازة بمناسبة ${holidayData["reason"] ?? 'إجازة'}",
          type: "y");
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
        message:
            "لقد تم تحضير الطلاب لهذا اليوم. هل تريد إلغاءه وإعادة التحضير؟",
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
  // Future<void> _handleSwitchCircle(BuildContext context) async {
  //   Get.back(); // إغلاق الـ Drawer
  //
  //   // الحصول على قائمة الحلقات من البيانات المخزنة
  //   final circles = homeCont.dataArg["circles"] as List?;
  //
  //   if (circles == null || circles.isEmpty) {
  //     mySnackbar("تنبيه", "لا توجد حلقات متاحة", type: "y");
  //     return;
  //   }
  //
  //   // عرض قائمة الحلقات للاختيار
  //   await Get.dialog(
  //     AlertDialog(
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  //       title: Row(
  //         children: [
  //           Icon(Icons.swap_horiz_rounded, color: primaryGreen),
  //           const SizedBox(width: 8),
  //           const Text("اختر الحلقة"),
  //         ],
  //       ),
  //       content: Container(
  //         width: double.maxFinite,
  //         child: ListView.builder(
  //           shrinkWrap: true,
  //           itemCount: circles.length,
  //           itemBuilder: (context, index) {
  //             final circle = circles[index];
  //             final isCurrentCircle = circle["id_circle"] == homeCont.dataArg["id_circle"];
  //
  //             return Container(
  //               margin: const EdgeInsets.only(bottom: 8),
  //               decoration: BoxDecoration(
  //                 color: isCurrentCircle
  //                     ? primaryGreen.withOpacity(0.1)
  //                     : Colors.grey.shade50,
  //                 borderRadius: BorderRadius.circular(12),
  //                 border: Border.all(
  //                   color:
  //                       isCurrentCircle ? primaryGreen : Colors.grey.shade300,
  //                   width: isCurrentCircle ? 2 : 1,
  //                 ),
  //               ),
  //               child: ListTile(
  //                 leading: CircleAvatar(
  //                   backgroundColor:
  //                       isCurrentCircle ? primaryGreen : childyGreen,
  //                   child: Icon(
  //                     Icons.group_rounded,
  //                     color: Colors.white,
  //                     size: 20,
  //                   ),
  //                 ),
  //                 title: Text(
  //                   circle["name_circle"] ?? "حلقة",
  //                   style: TextStyle(
  //                     fontWeight:
  //                         isCurrentCircle ? FontWeight.bold : FontWeight.normal,
  //                     color: isCurrentCircle ? primaryGreen : Colors.black87,
  //                   ),
  //                 ),
  //                 trailing: isCurrentCircle
  //                     ? Icon(Icons.check_circle, color: primaryGreen)
  //                     : Icon(Icons.arrow_forward_ios,
  //                         size: 16, color: Colors.grey),
  //                 onTap: isCurrentCircle
  //                     ? null
  //                     : () {
  //                         _switchToCircle(circle);
  //                         Get.back();
  //                       },
  //               ),
  //             );
  //           },
  //         ),
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Get.back(),
  //           child: Text("إلغاء", style: TextStyle(color: Colors.grey.shade600)),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // تبديل إلى حلقة معينة
  // void _switchToCircle(Map<String, dynamic> circle) {
  //   // تحديث بيانات الحلقة الحالية
  //   data_user_globle["id_circle"] = circle["id_circle"];
  //   data_user_globle["name_circle"] = circle["name_circle"];
  //
  //   final args = {
  //     // data_user_globle,
  //     // // ...dataCircle,
  //     "username": homeCont.dataArg["username"],
  //     "id_user": homeCont.dataArg["id_user"],
  //     "role": homeCont.dataArg["role"],
  //
  //   };
  //   holidayData.clear();
  //   Get.to(() => Home(), arguments: args);
  //
  //   mySnackbar(
  //     "تم بنجاح",
  //     "تم التبديل إلى حلقة: ${circle["name_circle"]}",
  //     type: "g",
  //   );
  // }

  // معالجة تسجيل الخروج
  Future<void> _handleLogout(BuildContext context) async {
    Get.to(
      () => LogoutScreen(),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 500),
    );
  }

}
