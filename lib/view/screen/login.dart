import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/appButton.dart';
import '../../constants/loadingWidget.dart';
import '../../controller/loginController.dart';


class Login extends StatelessWidget {
  final LoginController loginController = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // الأيقونة
              Icon(Icons.menu_book, size: 100, color: Colors.green[700]),
              SizedBox(height: 20),
              Text(
                "تسجيل الدخول",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
              SizedBox(height: 30),

              // حقل اسم المستخدم
              TextField(
                controller: loginController.usernameController,
                decoration: InputDecoration(
                  labelText: "اسم المستخدم",
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 15),

              // حقل كلمة المرور
              TextField(
                controller: loginController.passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "كلمة المرور",
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              SizedBox(height: 20),

              Obx(() => AppButton(
                text: "تسجيل دخول",
                onPressed: () {
                  loginController.select_data_user();
                },
                isLoading: loginController.isLoading.value,
              )
        ),
              SizedBox(height: 15),

              TextButton(
                onPressed: () {
                  Get.snackbar("معلومة", "تواصل مع الإدارة لإعادة كلمة المرور");
                },
                child: Text(
                  "نسيت كلمة المرور؟",
                  style: TextStyle(color: Colors.green[700]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


