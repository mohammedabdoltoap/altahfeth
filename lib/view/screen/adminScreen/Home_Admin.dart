import 'package:althfeth/constants/color.dart';
import 'package:althfeth/view/screen/adminScreen/visitsAndExam/add%20_Visit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'AdminReportsPage.dart';
import 'ResignationRequestPage.dart';
import '../login.dart';
import '../../../constants/function.dart';
import '../../../globals.dart';

class Home_Admin extends StatelessWidget {
  Home_AdminController controller =Get.put(Home_AdminController());
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            const Text(
              'الصفحة الرئيسية - مدير المركز',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "مرحباً ${controller.data_user?["username"] ?? ""}",
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        centerTitle: true,
        toolbarHeight: 88,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'resignation':
                  _showResignationRequest();
                  break;
                case 'logout':
                  _showLogoutDialog();
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'resignation',
                child: Row(
                  children: [
                    Icon(Icons.assignment, size: 20),
                    SizedBox(width: 8),
                    Text('طلب استقالة'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('تسجيل الخروج', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // كرت الزيارات
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 8,
              color: kPrimaryColor,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  Get.to(() => Add_Visit(),arguments: controller.data_user);

                },
                child: Container(
                  width: double.infinity, // العرض كامل
                  height: 180, // ارتفاع مناسب
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.calendar_today, size: 60, color: Colors.white),
                      SizedBox(height: 16),
                      Text(
                        "الزيارات",
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // كرت التقارير
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 8,
              color: Colors.orange[400],
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  Get.to(() => AdminReportsPage(), arguments: controller.data_user);
                },
                child: Container(
                  width: double.infinity,
                  height: 180,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.assessment, size: 60, color: Colors.white),
                      SizedBox(height: 16),
                      Text(
                        "التقارير",
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showResignationRequest() {
    Get.to(() => ResignationRequestPage(), arguments: controller.data_user);
  }

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.logout, color: Colors.red),
            SizedBox(width: 8),
            Text("تسجيل الخروج"),
          ],
        ),
        content: const Text(
          "هل أنت متأكد من رغبتك في تسجيل الخروج؟",
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("إلغاء"),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text("تسجيل الخروج"),
          ),
        ],
      ),
    );
  }

  void _logout() {
    // مسح البيانات المحفوظة
    data_user_globle.clear();
    
    // العودة لصفحة تسجيل الدخول
    Get.offAll(() => Login());
    
    // عرض رسالة تأكيد
    mySnackbar("تم بنجاح", "تم تسجيل الخروج بنجاح", type: "g");
  }
}


class Home_AdminController extends GetxController{

  var data_user;
  @override
  void onInit() {
    data_user=Get.arguments;
  }

}