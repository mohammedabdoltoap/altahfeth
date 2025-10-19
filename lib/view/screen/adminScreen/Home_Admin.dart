import 'package:althfeth/view/screen/adminScreen/visitsAndExam/add%20_Visit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Home_Admin extends StatelessWidget {
  Home_AdminController controller =Get.put(Home_AdminController());
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الصفحة الرئيسية'),
        centerTitle: true,
        backgroundColor: Colors.teal,
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
              color: Colors.teal[400],
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
                  print("التقارير");
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
}


class Home_AdminController extends GetxController{

  var data_user;
  @override
  void onInit() {
    data_user=Get.arguments;
  }

}