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

class AppDrawer extends StatelessWidget {
  HomeCont homeCont = Get.find();

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
              // رأس Drawer
              DrawerHeader(
                decoration: BoxDecoration(color: theme.colorScheme.primary),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: theme.colorScheme.onPrimary,
                      child: Icon(Icons.person,
                          size: 40, color: theme.colorScheme.primary),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "أهلاً بك",
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      "الأستاذ ${homeCont.dataArg["username"]}",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onPrimary.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ),

              // عناصر Drawer
              drawerItem(
                icon: Icons.home,
                text: "الرئيسية",
                onTap: () {
                  Get.back(); // إغلاق Drawer
                  Get.to(() => Home());
                },
                context: context,
              ),

              drawerItem(
                icon: Icons.history,
                text: "الحضور والغياب للطلاب",
                onTap: () async {
                  await homeCont.check_attendance();
                  if (homeCont.statCheck_Attendance.value != null) {
                    if(holidayData["is_holiday"]!=null)
                      if (!holidayData["is_holiday"]) {
                      if (homeCont.statCheck_Attendance.value == 1) {
                        Get.to(() => Attendance(), arguments: homeCont.dataArg);
                        homeCont.statCheck_Attendance.value = null;
                      } else {
                        bool? confirm = await showConfirmDialog(
                            context: context,
                            message:
                                "لقد تم تحضير الطلاب لهذا اليوم هل تريد الغاءه واعاد التحضير");
                        if (confirm == true) {
                          Get.to(() => UpdateAttendance(),
                              arguments: homeCont.dataArg);
                        }
                      }
                    } else {
                      mySnackbar("تنبية", "اجازة${holidayData["reason"]}");
                    }
                  } else {
                    mySnackbar("تنبية", "تحقق من الاتصال ");
                  }
                },
                context: context,
              ),

              drawerItem(
                icon: Icons.history,
                text: "الحضور والانصراف",
                onTap: () async {
                  if (holidayData["is_holiday"] != null) {
                    if (!holidayData["is_holiday"]) {
                      Get.to(() => User_Attendance(),
                          arguments: homeCont.dataArg);
                    } else {
                      mySnackbar("تنبية", "اجازة${holidayData["reason"]}");
                    }
                  } else {
                    mySnackbar("تنبية", "تحقق من الاتصال ");
                  }
                },
                context: context,
              ),
              drawerItem(
                icon: Icons.assignment,
                text: "طلب استقالة",
                onTap: () async {
                  if (holidayData["is_holiday"] != null) {
                    if (!holidayData["is_holiday"]) {
                      Get.back(); // إغلاق الـ drawer
                      Get.to(() => TeacherResignationPage(), arguments: homeCont.dataArg);
                    } else {
                      mySnackbar("تنبيه", "إجازة بمناسبة ${holidayData["reason"]}");
                    }
                  } else {
                    mySnackbar("تنبيه", "تحقق من الاتصال");
                  }
                },
                context: context,
              ),
              drawerItem(
                icon: Icons.assignment,
                text: "طلب اجازة",
                onTap: () async {
                  if (holidayData["is_holiday"] != null) {
                    if (!holidayData["is_holiday"]) {
                      Get.to(() => LeaveRequestsPage(),
                          arguments: homeCont.dataArg);
                    } else {
                      mySnackbar("تنبية", "اجازة${holidayData["reason"]}");
                    }
                  } else {
                    mySnackbar("تنبية", "تحقق من الاتصال ");
                  }
                },
                context: context,
              ),

              drawerItem(
                icon: Icons.quiz,
                text: "المهارات  ",
                onTap: () {
                  if (holidayData["is_holiday"] != null) {
                    if (!holidayData["is_holiday"]) {
                      Get.back();
                      Get.to(() => StudentList_Skill(),
                          arguments: homeCont.dataArg);
                    } else {
                      mySnackbar("تنبية", "اجازة${holidayData["reason"]}");
                    }
                  } else {
                    mySnackbar("تنبية", "تحقق من الاتصال ");
                  }
                },
                context: context,
              ),

              drawerItem(
                icon: Icons.note_alt,
                text: "الملاحظات",
                onTap: () {
                  Get.back(); // إغلاق Drawer
                  Get.to(() => CirclesListScreen(), arguments: homeCont.dataArg);
                },
                context: context,
              ),

              drawerItem(
                icon: Icons.assessment,
                text: "نتائج الطلاب",
                onTap: () {
                  Get.back(); // إغلاق Drawer
                  Get.to(() => VisitResultsPage(), arguments: homeCont.dataArg);
                },
                context: context,
              ),

              drawerItem(
                icon: Icons.phone,
                text: "تواصل مع اولياء الامور",
                onTap: () {
                  Get.back(); // إغلاق Drawer
                  Get.to(() => ParentsContactsPage(), arguments: homeCont.dataArg);
                },
                context: context,
              ),
              Divider(color: theme.dividerColor, thickness: 1, height: 30),

              drawerItem(
                icon: Icons.logout,
                text: "تسجيل الخروج",
                onTap: () async {
                  bool? confirm = await showConfirmDialog(
                    context: context,
                    title: "تسجيل الخروج",
                    message: "هل أنت متأكد من رغبتك في تسجيل الخروج؟",
                    yesText: "تسجيل الخروج",
                    noText: "إلغاء",
                  );
                  
                  if (confirm == true) {
                    // مسح البيانات المحفوظة
                    data_user_globle.clear();
                    
                    // العودة لصفحة تسجيل الدخول
                    Get.offAll(() => Login());
                    
                    // عرض رسالة تأكيد
                    mySnackbar("تم بنجاح", "تم تسجيل الخروج بنجاح", type: "g");
                  }
                },
                context: context,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget drawerItem(
      {required IconData icon,
      required String text,
      required VoidCallback onTap,
      required BuildContext context}) {
    final theme = Theme.of(context);
    return ListTileTheme(
      iconColor: theme.colorScheme.primary,
      textColor: theme.textTheme.bodyLarge?.color,
      child: ListTile(
        leading: Icon(icon),
        title: Text(text, style: theme.textTheme.bodyLarge),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
