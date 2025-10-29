import 'package:althfeth/constants/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/appButton.dart';
import '../../constants/customTextField.dart';
import '../../controller/loginController.dart';
import '../widget/login/isStudentCheke.dart';
import '../widget/common/promotional_footer.dart';

class Login extends StatelessWidget {
  final LoginController loginController = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480), // عرض مريح لكل الشاشات
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // الأيقونة في الوسط ضمن بطاقة صغيرة
                Align(
                  alignment: Alignment.center,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 160),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: whiteColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/icon/app_icon.png',
                        width: 90,
                        height: 90,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // حقل اسم المستخدم
                CustomTextField(
                  controller: loginController.usernameController,
                  label: "اسم المستخدم",
                  hint: "أدخل اسم المستخدم",
                  prefixIcon: Icons.person_outline,
                ),

                const SizedBox(height: 16),

                // حقل كلمة المرور
                CustomTextField(
                  controller: loginController.passwordController,
                  label: "كلمة المرور",
                  hint: "********",
                  isPassword: true,
                  prefixIcon: Icons.lock_outline,
                ),

                const SizedBox(height: 24),

                // زر تسجيل الدخول (يعتمد على isLoading فقط بدون Dialog)
                Obx(() => AppButton(
                  text: "تسجيل الدخول",
                  isLoading: loginController.isLoading.value,
                  onPressed: () {
                    if (loginController.isStudent.value) {
                      loginController.select_data_Student();
                    } else {
                      loginController.select_data_user();
                    }
                  },
                )),

                const SizedBox(height: 12),

                // اختيار الدخول كطالب
                IsStudentCheke(),

                const SizedBox(height: 12),

                // رابط نسيان كلمة المرور
                Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: () {
                      Get.snackbar(
                        "معلومة",
                        "تواصل مع الإدارة لإعادة كلمة المرور",
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: whiteColor,
                        colorText: primaryGreen,
                      );
                    },
                    child: Text(
                      "نسيت كلمة المرور؟",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: childyGreen, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // البصمة الترويجية
                const PromotionalFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
