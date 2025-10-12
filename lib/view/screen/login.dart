import 'package:althfeth/constants/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/appButton.dart';
import '../../constants/customTextField.dart';
import '../../controller/loginController.dart';
import '../../globals.dart';
import '../widget/login/isStudentCheke.dart';

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
              Icon(Icons.menu_book, size: 100, color: primaryGreen),
              SizedBox(height: 20),
              Text(
                "تسجيل الدخول",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryGreen,
                ),
              ),
              SizedBox(height: 30),

              CustomTextField(
                controller: loginController.usernameController,
                label: "اسم المستخدم",
                hint: "أدخل اسمك هنا",
                prefixIcon: Icons.person,
              ),
              SizedBox(height: 15),

              // حقل كلمة المرور
              CustomTextField(
                controller: loginController.passwordController,
                label: "كلمة المرور",
                hint: "********",
                isPassword: true,
                prefixIcon: Icons.lock,
              ),
              SizedBox(height: 20),
              AppButton(
                text: "تسجيل دخول",
                onPressed: () {
                  if(loginController.isStudent.value)
                    loginController.select_data_Student();
                    else
                  loginController.select_data_user();
                },
              ),
              IsStudentCheke(),
              SizedBox(height: 15),

              TextButton(
                onPressed: () {
                  Get.snackbar("معلومة", "تواصل مع الإدارة لإعادة كلمة المرور");
                },
                child: Text(
                  "نسيت كلمة المرور؟",
                  style: TextStyle(color: primaryGreen),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


