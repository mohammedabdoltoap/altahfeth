import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants/function.dart';
import '../../../controller/home_cont.dart';
import '../../../globals.dart';
import '../../screen/LeaveRequestsPage.dart';
import '../../screen/ShowCircleExam.dart';
import '../../screen/add _Visit.dart';
import '../../screen/attendance.dart';
import '../../screen/home.dart';
import '../../screen/login.dart';
import '../../screen/updateAttendance.dart';
import '../../screen/user_attendance.dart';
class AppDrawer extends StatelessWidget {
  HomeCont homeCont=Get.find();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.teal[50],
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // رأس Drawer
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.teal,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 40, color: Colors.teal),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "أهلاً بك",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "الأستاذ ${homeCont.dataArg["username"]}",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
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
            ),

            drawerItem(
              icon: Icons.history,
              text: "الحضور والغياب للطلاب",
              onTap: () async{
    if(!holidayData["is_holiday"]) {
                  await homeCont.check_attendance();
                if(homeCont.statCheck_Attendance.value==1){
                  Get.to(() => Attendance(),arguments:homeCont.dataArg );
                } else{
                  bool? confirm=await showConfirmDialog(context: context, message: "لقد تم تحضير الطلاب لهذا اليوم هل تريد الغاءه واعاد التحضير");
                  if(confirm==true){
                    Get.to(()=>UpdateAttendance(),arguments: homeCont.dataArg);

                  }
                }
                }else{
      mySnackbar("تنبية", "اجازة${holidayData["reason"]}");
    }

              },
            ),
            if(homeCont.dataArg["role"]==4)
            drawerItem(
              icon: Icons.history,
              text: "الحضور والانصراف",
              onTap: () async{
                if(!holidayData["is_holiday"]) {
                  Get.to(() => User_Attendance(),arguments:homeCont.dataArg );
                }else{
                  mySnackbar("تنبية", "اجازة${holidayData["reason"]}");
                }
              },
            ),
            if(homeCont.dataArg["role"]==4)
            drawerItem(
              icon: Icons.assignment,
              text: "طلب استقالة",
              onTap: () async{
    if(!holidayData["is_holiday"]) {
                bool? confirm=await showConfirmDialog(context: context, message: "هل انت متاكيد من طلب تقديم الاستقالة ؟");
                if(confirm==true){
                  homeCont.addResignation();
                }

              } else{
            mySnackbar("تنبية", "اجازة${holidayData["reason"]}");
            }
    },
            ),
            if(homeCont.dataArg["role"]==4)
            drawerItem(
              icon: Icons.assignment,
              text: "طلب اجازة",
              onTap: () async{
                if(!holidayData["is_holiday"]) {
                  Get.to(()=>LeaveRequestsPage(),arguments: homeCont.dataArg);

              } else{
            mySnackbar("تنبية", "اجازة${holidayData["reason"]}");
            }
    },
            ),
           if(homeCont.dataArg["role"]==2)
            drawerItem(
              icon: Icons.quiz,
              text: "الزيارات ",
              onTap: () {
                Get.back();
                Get.to(() => Add_Visit(),arguments: homeCont.dataArg);
              },
            ),
           if(homeCont.dataArg["role"]==2)
            drawerItem(
              icon: Icons.quiz,
              text: "الاختبارات الشهرية ",
              onTap: () {
                Get.back();
                Get.to(() => ShowCircleExam(),arguments: homeCont.dataArg);
              },
            ),

            Divider(color: Colors.teal[200], thickness: 1, height: 30),

            drawerItem(
              icon: Icons.logout,
              text: "تسجيل الخروج",
              onTap: () {
                Get.offAll(()=>Login());
                // Get.delete<Controller_Home>();
                // ضع هنا منطق تسجيل الخروج
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget drawerItem(
      {required IconData icon,
        required String text,
        required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.teal),
      title: Text(
        text,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
    );
  }
}
