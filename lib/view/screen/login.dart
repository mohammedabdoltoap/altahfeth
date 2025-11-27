import 'package:althfeth/constants/color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;

import '../../constants/appButton.dart';
import '../../constants/customTextField.dart';
import '../../constants/app_theme.dart';
import '../../controller/loginController.dart';
import '../widget/login/isStudentCheke.dart';
import '../widget/common/promotional_footer.dart';
import 'test/ErrorTestPage.dart';

class Login extends StatefulWidget {
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with TickerProviderStateMixin {
  final LoginController loginController = Get.put(LoginController());
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _floatController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );
    
    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Stack(
        children: [
          // خلفية متدرجة محسنة
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.backgroundColor,
                    Colors.white,
                    AppTheme.backgroundColor.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          // تأثيرات هندسية هادئة
          Positioned.fill(
            child: CustomPaint(
              painter: GeometricBackgroundPainter(),
            ),
          ),
          
          // المحتوى الرئيسي
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // الأيقونة مع أنيميشن طفو
                        AnimatedBuilder(
                          animation: _floatController,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, math.sin(_floatController.value * 2 * math.pi) * 10),
                              child: child,
                            );
                          },
                          child: Align(
                            alignment: Alignment.center,
                            child: ScaleTransition(
                              scale: _scaleAnimation,
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 160),
                                child: Container(
                                  padding: const EdgeInsets.all(AppTheme.spacingLarge),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.white,
                                        Colors.grey.shade50,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.primaryColor.withOpacity(0.15),
                                        blurRadius: 30,
                                        spreadRadius: 5,
                                        offset: const Offset(0, 10),
                                      ),
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 15,
                                        offset: const Offset(0, 5),
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

                        // حقول الإدخال في حاوية محسنة
                        Container(
                          padding: const EdgeInsets.all(AppTheme.spacingLarge),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
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
                              // حقل اسم المستخدم
                              CustomTextField(
                                controller: loginController.usernameController,
                                label: "اسم المستخدم",
                                hint: "أدخل اسم المستخدم",
                                prefixIcon: Icons.person_outline,
                              ),

                              const SizedBox(height: AppTheme.spacingLarge),

                              // حقل كلمة المرور
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


                         PromotionalFooter(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter للخلفية الهندسية الهادئة
class GeometricBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // دوائر هادئة في الخلفية
    paint.color = AppTheme.primaryColor.withOpacity(0.03);
    canvas.drawCircle(
      Offset(size.width * 0.1, size.height * 0.2),
      100,
      paint,
    );
    
    canvas.drawCircle(
      Offset(size.width * 0.9, size.height * 0.7),
      120,
      paint,
    );
    
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.1),
      80,
      paint,
    );

    // خطوط منحنية هادئة
    paint.color = AppTheme.primaryColor.withOpacity(0.05);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;

    final path1 = Path();
    path1.moveTo(0, size.height * 0.3);
    path1.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.25,
      size.width * 0.5,
      size.height * 0.3,
    );
    path1.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.35,
      size.width,
      size.height * 0.3,
    );
    canvas.drawPath(path1, paint);

    final path2 = Path();
    path2.moveTo(0, size.height * 0.7);
    path2.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.65,
      size.width * 0.5,
      size.height * 0.7,
    );
    path2.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.75,
      size.width,
      size.height * 0.7,
    );
    canvas.drawPath(path2, paint);

    // نقاط صغيرة منتشرة
    paint.style = PaintingStyle.fill;
    paint.color = AppTheme.primaryColor.withOpacity(0.08);
    
    for (int i = 0; i < 20; i++) {
      final x = (size.width / 20) * i + (i % 3) * 30;
      final y = (size.height / 10) * (i % 10) + (i % 2) * 40;
      canvas.drawCircle(Offset(x, y), 3, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
