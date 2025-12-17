
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';

import '../../constants/appButton.dart';
import '../../constants/customTextField.dart';
import '../../constants/app_theme.dart';
import '../../controller/loginController.dart';
import '../widget/login/isStudentCheke.dart';
import '../widget/common/promotional_footer.dart';
import '../widget/offline_indicator.dart';

class Login extends StatelessWidget {
  final LoginController loginController = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: AppTheme.backgroundColor,
      body: Stack(
        children: [
          // 🌐 مؤشر الاتصال بالإنترنت
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AdvancedOfflineIndicator(showDetails: false),
          ),

          // المحتوى الرئيسي
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // أيقونة التطبيق
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        padding: const EdgeInsets.all(AppTheme.spacingLarge),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.15),
                              blurRadius: 30,
                              spreadRadius: 5,
                              offset: const Offset(0, 10),
                            ),
                          ],
                          border: Border.all(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Image.asset(
                          'assets/icon/app_icon.png',
                          width: 90,
                          height: 90,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    const SizedBox(height: AppTheme.spacingLarge),

                    // نص ترحيبي
                    Text(
                      "مرحباً بك",
                      textAlign: TextAlign.center,
                      style: AppTheme.headingLarge.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: AppTheme.spacingSmall),

                    Text(
                      "سجل دخولك للمتابعة",
                      textAlign: TextAlign.center,
                      style: AppTheme.bodyLarge.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: AppTheme.spacingXXLarge),

                    // حقول الإدخال
                    Container(
                      padding: const EdgeInsets.all(AppTheme.spacingLarge),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                        border: Border.all(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          // اسم المستخدم
                          CustomTextField(
                            controller: loginController.usernameController,
                            label: "اسم المستخدم",
                            hint: "أدخل اسم المستخدم",
                            prefixIcon: Icons.person_outline,
                          ),

                          const SizedBox(height: AppTheme.spacingLarge),

                          // كلمة المرور
                          CustomTextField(
                            controller: loginController.passwordController,
                            label: "كلمة المرور",
                            hint: "********",
                            isPassword: true,
                            prefixIcon: Icons.lock_outline,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppTheme.spacingXLarge),

                    // زر تسجيل الدخول
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

                    const SizedBox(height: AppTheme.spacingMedium),

                    // اختيار الدخول كطالب
                    IsStudentCheke(),

                    const SizedBox(height: AppTheme.spacingMedium),

                    // رابط نسيان كلمة المرور
                    Align(
                      alignment: Alignment.center,
                      child: TextButton(
                        onPressed: () {
                          Get.snackbar(
                            "معلومة",
                            "تواصل مع الإدارة لإعادة كلمة المرور",
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.white,
                            colorText: AppTheme.primaryColor,
                          );
                        },
                        child: Text(
                          "نسيت كلمة المرور؟",
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppTheme.spacingXLarge),

                    // Footer ترويجي
                    PromotionalFooter(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}

