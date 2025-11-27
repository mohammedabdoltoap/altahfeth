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
  Home_AdminController controller = Get.put(Home_AdminController());
  
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.exit_to_app, color: Colors.red),
                SizedBox(width: 8),
                Text('تأكيد الخروج'),
              ],
            ),
            content: const Text('هل أنت متأكد من الخروج من التطبيق؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('خروج', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
        
        if (shouldExit == true && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF667eea),
                Color(0xFF764ba2),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Header جذاب
                _buildHeader(),
                
                // المحتوى الرئيسي
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          
                          // عنوان الأقسام
                          const Text(
                            "الأقسام الرئيسية",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          // شبكة الكروت الجذابة
                          _buildMainCards(),
                          
                          const SizedBox(height: 30),
                          
                          // أدوات إضافية
                          _buildAdditionalTools(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // بناء الهيدر الجذاب
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // صف العلوي مع الترحيب والقائمة
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // أيقونة القائمة
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: PopupMenuButton<String>(
                  icon: const Icon(Icons.menu, color: Colors.white, size: 24),
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
              ),
              
              // الإشعارات
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 24),
              ),
            ],
          ),
          
          const SizedBox(height: 30),
          
          // الترحيب والوقت
          Column(
            children: [
              Text(
                "مرحباً ${controller.data_user?["username"] ?? "المدير"}",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "مدير المركز",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 20),
              
              // تاريخ اليوم
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // بناء الكروت الرئيسية
  Widget _buildMainCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // تحديد عدد الأعمدة حسب عرض الشاشة
        int crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
        double cardHeight = constraints.maxWidth > 600 ? 160 : 140;
        
        return Column(
          children: [
            // الصف الأول - الكروت الأساسية
            Row(
              children: [
                Expanded(
                  child: _buildResponsiveCard(
                    title: "الزيارات",
                    subtitle: "إدارة الزيارات الإدارية",
                    icon: Icons.calendar_today_rounded,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                    ),
                    height: cardHeight,
                    onTap: () => Get.to(() => Add_Visit(), arguments: controller.data_user),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildResponsiveCard(
                    title: "التقارير",
                    subtitle: "عرض جميع التقارير",
                    icon: Icons.assessment_rounded,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
                    ),
                    height: cardHeight,
                    onTap: () => Get.to(() => AdminReportsPage(), arguments: controller.data_user),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // بناء كارت متجاوب
  Widget _buildResponsiveCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Gradient gradient,
    required double height,
    required VoidCallback onTap,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // تحديد أحجام النصوص والأيقونات حسب عرض الكارت
        double iconSize = constraints.maxWidth > 150 ? 28 : 24;
        double titleSize = constraints.maxWidth > 150 ? 16 : 14;
        double subtitleSize = constraints.maxWidth > 150 ? 12 : 10;
        
        return Container(
          height: height,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, size: iconSize, color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: subtitleSize,
                        color: Colors.white.withOpacity(0.8),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }


  // بناء الأدوات الإضافية
  Widget _buildAdditionalTools() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "أدوات إضافية",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 16),
        _buildToolItem(
          title: "طلب استقالة",
          subtitle: "تقديم طلب استقالة جديد",
          icon: Icons.assignment_turned_in,
          color: Colors.red,
          onTap: _showResignationRequest,
        ),
        const SizedBox(height: 12),
        _buildToolItem(
          title: "تسجيل الخروج",
          subtitle: "الخروج من النظام",
          icon: Icons.logout,
          color: Colors.grey,
          onTap: _showLogoutDialog,
        ),
      ],
    );
  }

  // بناء عنصر أداة متجاوب
  Widget _buildToolItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // تحديد أحجام العناصر حسب عرض الشاشة
        double iconSize = constraints.maxWidth > 400 ? 24 : 20;
        double titleSize = constraints.maxWidth > 400 ? 16 : 14;
        double subtitleSize = constraints.maxWidth > 400 ? 14 : 12;
        double padding = constraints.maxWidth > 400 ? 16 : 12;
        
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onTap,
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(padding * 0.75),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: color, size: iconSize),
                    ),
                    SizedBox(width: padding),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: titleSize,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2D3748),
                            ),
                          ),
                          SizedBox(height: padding * 0.25),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: subtitleSize,
                              color: Colors.grey[600],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: Colors.grey[400],
                      size: iconSize,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showResignationRequest() {
    Get.to(() => ResignationRequestPage(), arguments: controller.data_user);
  }

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Text(
              "تسجيل الخروج",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: const Text(
          "هل أنت متأكد من رغبتك في تسجيل الخروج من النظام؟",
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              "إلغاء",
              style: TextStyle(fontSize: 16),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "تسجيل الخروج",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
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