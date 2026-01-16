import 'package:althfeth/view/screen/adminScreen/showCircleForCenter.dart';
import 'package:althfeth/view/screen/adminScreen/visitsAndExam/add%20_Visit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../widget/offline_indicator.dart';
import '../LeaveRequestsPage.dart';
import '../teacherScreen/EditEmployeeProfile.dart';
import '../user_attendance.dart';
import 'AdminReportsPage.dart';
import 'ResignationRequestPage.dart';
import '../login.dart';
import '../../../constants/function.dart';
import '../../../constants/NewsToastWidget.dart';
import '../../../globals.dart';
import '../../../api/LinkApi.dart';
import '../../../api/apiFunction.dart';

class Home_Admin extends StatelessWidget {
  Home_AdminController controller = Get.put(Home_AdminController());
  
  @override
  Widget build(BuildContext context) {

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
                OfflineIndicator(),
                
                // إشعارات الأخبار - تظهر فقط عند وجود بيانات
                if (dataNewsGloble.isNotEmpty)
                  NewsToastWidget(),

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
             Obx(() => Text(
                   " المركز:${controller.nameCenter.value}",
                   style: TextStyle(
                     fontSize: 16,
                     color: Colors.white70,
                   ),
                 ),),
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
                    onTap: ()
                        {
                          if(connectivityHelper.hasConnection){
                          if(controller.data_user["center_id"]!=null)
                        Get.to(() => Add_Visit(), arguments: controller.data_user);
                    else{
                      mySnackbar("تنبية", "لايوجد لديك مركز مسوول عنه حاليا");
                          }}else{
                            mySnackbar("تنبية", "تحقق من اتصالك بالانترنت اولا");
                          }
                        }

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
                    onTap: ()
                    {
                      if(controller.data_user["center_id"]!=null)
                        Get.to(() => AdminReportsPage(), arguments: controller.data_user);
                      else{
                        mySnackbar("تنبية", "لايوجد لديك مركز مسوول عنه حاليا");
                      }
                    }

                    // => Get.to(() => AdminReportsPage(), arguments: controller.data_user),
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
          icon: Icons.exit_to_app,
          color: Colors.red,
          onTap: _showResignationRequest,
        ),
        const SizedBox(height: 12),
        _buildToolItem(
          title: "طلب إجازة",
          subtitle: "تقديم طلب إجازة جديد",
          icon: Icons.beach_access,
          color: Colors.blue,
          onTap: _showLeaveRequestsPage,
        ),
        const SizedBox(height: 12),
        _buildToolItem(
          title: "خطط الطلاب",
          subtitle: "الاطلاع على الطلاب وخططهم",
          icon: Icons.school,
          color: Colors.green,
          onTap: _showshowCircleForCenter,
        ),
        const SizedBox(height: 12),
        Obx(() {
          final status = controller.attendanceStatus.value;
          
          if (status == "No_record_today") {
            return _buildToolItem(
              title: "تسجيل الحضور",
              subtitle: "سجل حضورك اليوم",
              icon: Icons.login,
              color: Colors.green,
              onTap: () => controller.add_admin_check_in(),
            );
          } else if (status == "No_check_out_time") {
            return _buildToolItem(
              title: "تسجيل الانصراف",
              subtitle: "سجل انصرافك",
              icon: Icons.logout,
              color: Colors.orange,
              onTap: () => controller.add_admin_check_out(),
            );
          } else {
            return _buildToolItem(
              title: "الحضور والانصراف",
              subtitle: "✅ تم تسجيل الحضور والانصراف",
              icon: Icons.check_circle,
              color: Colors.green,
              onTap: () {
                mySnackbar("تم", "تم تسجيل الحضور والانصراف بالفعل", type: "g");
              },
            );
          }
        }),
        const SizedBox(height: 12),
        _buildToolItem(
          title: "المزامنة",
          subtitle: "المزامنة مع السيرفر",
          icon: Icons.sync,
          color: Colors.blue,
          onTap: () => controller.admin_attendancePending(),
        ),
        const SizedBox(height: 12),
        _buildToolItem(
          title: "تعديل البيانات",
          subtitle: "تعديل البيانات الشخصية",
          icon: Icons.edit,
          color: Colors.teal,
          onTap: () {
            Get.to(() => EditEmployeeProfile(), arguments: controller.data_user);
          },
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

  // بناء عنصر أداة بسيط
  Widget _buildToolItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[400],
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showResignationRequest() {
    Get.to(() => ResignationRequestPage(), arguments: controller.data_user);
  }
  void _showLeaveRequestsPage() {
    Get.to(() => LeaveRequestsPage(), arguments: controller.data_user);
  }
  void _showshowCircleForCenter() {
    Get.to(() => showCircleForCenter(), arguments: controller.data_user);
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
  
  // Reactive variables for attendance
  RxString attendanceStatus = "No_record_today".obs;
  RxBool isLoading = false.obs;
  RxMap<String, dynamic> attendanceData = <String, dynamic>{}.obs;
  
  late final String formattedDate;
  
  @override
  void onInit() async{
    data_user = Get.arguments;
    
    // تحضير التاريخ
    final today = DateTime.now();
    formattedDate = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async{
     await selecDataCenter();
     await  admin_attendancePending();
     await check_admin_attendance();

    },);

  }
  RxString nameCenter="".obs;
  Future selecDataCenter()async{

    if(connectivityHelper.hasConnection) {
      var res = await handleRequest(isLoading: RxBool(false), action: () async {
        return await postData(Linkapi.selecDataCenter, {
          "id_user": data_user["id_user"],
        });
      },);
      if (res == null) return;
      if (res["stat"] == "ok") {
        data_user["center_id"] = res["data"]["center_id"];
        data_user["name"] = res["data"]["name"];
      }
      else if (res["stat"] == "no") {
        data_user["center_id"] = null;
        data_user["name"] = "لايوجد لديك مركز مسوول عنه نشط ";

        mySnackbar("تنبية", "لايوجد لديك مركز مسوول عنه نشط ");
      } else {
        mySnackbar("تنبية", "${res["msg"] ?? "خطا في جلب بيانات المركز"}");
      }
    }else{
      mySnackbar("تنبية", "لايوجد اتصال بالانترنت ولن تتمكن من اي عملية عدا تسجيل الحضور والانصراف");
    }
      nameCenter.value = data_user["name"] ?? "لايوجد";

  }
  Future check_admin_attendance() async {
    if(connectivityHelper.hasConnection)
      await check_admin_attendanceOnline();
    else
      await check_admin_attendanceOffline();
  }
  
  // ============================================
  // التحقق من الحضور محلياً
  // ============================================
  Future check_admin_attendanceOffline() async {
    print('\n🔍 ========== التحقق من حضور المدير (أوفلاين) ==========');
    
    try {
      List<Map<String, dynamic>> localRecord = await db.query(
        "users_attendance",
        where: "id_user = ? AND attendance_date = ? AND id_circle = 0",
        whereArgs: [data_user["id_user"], formattedDate],
      );
      
      if (localRecord.isEmpty) {
        print('ℹ️ لا يوجد حضور مسجل محلياً اليوم');
        attendanceStatus.value = "No_record_today";
      } else {
        var record = localRecord.first;
        attendanceData.assignAll(record);
        
        if (record["check_out_time"] == null) {
          print('✅ يوجد حضور محلي بدون انصراف');
          attendanceStatus.value = "No_check_out_time";
        } else {
          print('✅ يوجد حضور وانصراف محلي');
          attendanceStatus.value = "He_check_all";
        }
      }
    } catch (e) {
      print('❌ خطأ في التحقق من الحضور محلياً: $e');
      attendanceStatus.value = "No_record_today";
    }
    
    print('✅ ========== انتهى التحقق من حضور المدير (أوفلاين) ==========\n');
  }
  
  // ============================================
  // التحقق من الحضور أونلاين
  // ============================================
  Future check_admin_attendanceOnline() async {
    try {
      isLoading.value = true;
      
      final today = DateTime.now();
      final formattedDate = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

      final response =await handleRequest(isLoading: RxBool(false), action: ()async {
       return await postData(
        Linkapi.select_admin_attendance_today,
        {
          "id_user": data_user["id_user"],
          "attendance_date": formattedDate,
          "id_circle": 0,
        },
        );
      },
        loadingMessage: "معالجة التحضير ...",
        immediateLoading: true,
        useDialog: true
      );

      if (response == null) {
        print('⚠️ لم يتم استلام رد من السيرفر');
        attendanceStatus.value = "No_record_today";
        return;
      }

      if (response is! Map) {
        print('❌ رد السيرفر غير صحيح');
        attendanceStatus.value = "No_record_today";
        return;
      }

      print('📥 رد السيرفر: stat=${response["stat"]}');
      
      String status = response["stat"] ?? "error";
      
      if (status == "No_record_today") {
        print('ℹ️ لا يوجد حضور مسجل اليوم');
        attendanceStatus.value = "No_record_today";
      } else if (status == "No_check_out_time" || status == "He_check_all") {
        print('✅ يوجد حضور مسجل - بدء المزامنة المحلية...');
        attendanceStatus.value = status == "No_check_out_time" ? "No_check_out_time" : "He_check_all";
        
        // ========== مزامنة من السيرفر للمحلي ==========
        try {
          if (response["data"] != null && response["data"] is Map) {
            var serverData = response["data"];
            attendanceData.assignAll(serverData);
            print('📊 بيانات الحضور من السيرفر: $serverData');
            
            // التحقق من وجود السجل محلياً
            List<Map<String, dynamic>> localRecord = await db.query(
              "users_attendance",
              where: "id_user = ? AND attendance_date = ? AND id_circle = 0",
              whereArgs: [data_user["id_user"], formattedDate],
            );
            
            if (localRecord.isEmpty) {
              print('📥 لا يوجد سجل محلي - حفظ البيانات من السيرفر...');
              
              int result = await db.insert('users_attendance', {
                'id_server': serverData['id'],
                'id_user': data_user["id_user"],
                'id_circle': 0,
                'check_in_time': serverData['check_in_time'],
                'check_out_time': serverData['check_out_time'],
                'attendance_date': formattedDate,
                'stat': 'NoPending',
                'attendance_status': 1,
              });
              
              if (result > 0) {
                print('✅ تم حفظ حضور المدير محلياً بنجاح - id_local: $result');
              } else {
                print('❌ فشل حفظ حضور المدير محلياً');
              }
            } else {
              print('ℹ️ السجل موجود محلياً بالفعل - id_local: ${localRecord.first["id_local"]}');
              
              if (localRecord.first['stat'] == 'Pending') {
                print('🔄 تحديث السجل المحلي المعلق بالبيانات من السيرفر...');
                await db.update(
                  'users_attendance',
                  {
                    'id_server': serverData['id'],
                    'check_in_time': serverData['check_in_time'],
                    'check_out_time': serverData['check_out_time'],
                    'stat': 'NoPending',
                  },
                  where: 'id_local = ?',
                  whereArgs: [localRecord.first['id_local']],
                );
                print('✅ تم تحديث السجل المحلي بنجاح');
              }
            }
          } else {
            print('⚠️ لا توجد بيانات تفصيلية في رد السيرفر');
          }
        } catch (e) {
          print('❌ خطأ في مزامنة حضور المدير محلياً: $e');
        }
      } else {
        attendanceStatus.value = "No_record_today";
        print('⚠️ ${response["msg"] ?? "خطأ في جلب البيانات"}');
      }
    } catch (e) {
      print('❌ خطأ في التحقق من حضور المدير: $e');
      attendanceStatus.value = "No_record_today";
    } finally {
      isLoading.value = false;
    }
    
    print('✅ ========== انتهى التحقق من حضور المدير (أونلاين) ==========\n');
  }

  // ============================================
  // تسجيل الحضور (أونلاين/أوفلاين)
  // ============================================
  Future<void> add_admin_check_in() async {
    if(connectivityHelper.hasConnection)
      await add_admin_check_in_online();
    else
      await add_admin_check_in_offline();
  }
  
  // ============================================
  // تسجيل الحضور أونلاين
  // ============================================
  Future<void> add_admin_check_in_online() async {
    print('\n📤 ========== تسجيل حضور المدير (أونلاين) ==========');
    try {
      isLoading.value = true;
      
      final now = DateTime.now();
      final checkInTime = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
      final attendanceDate = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      
      print('⏰ وقت الحضور: $checkInTime');
      
      final response = await postData(
        Linkapi.add_admin_check_in,
        {
          "id_user": data_user["id_user"],
          "check_in_time": checkInTime,
          "attendance_date": attendanceDate,
          "id_circle": 0, // Admin has id_circle = 0
        },
      );

      if (response == null) {
        print('❌ فشل الاتصال بالخادم');
        mySnackbar("خطأ", "فشل الاتصال بالخادم");
        return;
      }

      if (response is! Map) {
        print('❌ رد غير صحيح من الخادم');
        mySnackbar("خطأ", "رد غير صحيح من الخادم");
        return;
      }

      if (response["stat"] == "ok") {
        print('✅ تم تسجيل الحضور بنجاح');
        
        // حفظ محلياً
        try {
          int result = await db.insert('users_attendance', {
            'id_server': response['id'],
            'id_user': data_user["id_user"],
            'id_circle': 0,
            'check_in_time': checkInTime,
            'attendance_date': attendanceDate,
            'stat': 'NoPending',
            'attendance_status': 1,
          });
          
          if (result > 0) {
            print('✅ تم حفظ الحضور محلياً - id_local: $result');
          }
        } catch (e) {
          print('❌ خطأ في الحفظ المحلي: $e');
        }
        
        attendanceStatus.value = "No_check_out_time";
        mySnackbar("نجاح", "تم تسجيل الحضور بنجاح ✅", type: "g");
        await check_admin_attendance();
      } else {
        print('❌ فشل التسجيل: ${response["msg"]}');
        mySnackbar("خطأ", response["msg"] ?? "فشل تسجيل الحضور");
      }
    } catch (e) {
      print('❌ خطأ: $e');
      mySnackbar("خطأ", "حدث خطأ أثناء تسجيل الحضور");
    } finally {
      isLoading.value = false;
    }
    
    print('✅ ========== انتهى تسجيل حضور المدير (أونلاين) ==========\n');
  }
  
  // ============================================
  // تسجيل الحضور أوفلاين
  // ============================================
  Future<void> add_admin_check_in_offline() async {

    try {
      isLoading.value = true;
      
      final now = DateTime.now();
      final checkInTime = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
      
      print('⏰ وقت الحضور: $checkInTime');
      
      int result = await db.insert('users_attendance', {
        'id_user': data_user["id_user"],
        'id_circle': 0,
        'check_in_time': checkInTime,
        'attendance_date': formattedDate,
        'stat': 'Pending',
        'attendance_status': 1,
      });
      
      if (result > 0) {
        print('✅ تم حفظ الحضور محلياً - id_local: $result');
        attendanceStatus.value = "No_check_out_time";
        mySnackbar("نجاح", "تم تسجيل الحضور ✅\n📱 محفوظ محلياً (بدون نت)", type: "g");
        await check_admin_attendance();
      } else {
        print('❌ فشل الحفظ المحلي');
        mySnackbar("فشل", "لم يتم حفظ الحضور");
      }
    } catch (e) {
      print('❌ خطأ: $e');
      mySnackbar("خطأ", "حدث خطأ أثناء تسجيل الحضور");
    } finally {
      isLoading.value = false;
    }
    
    print('✅ ========== انتهى تسجيل حضور المدير (أوفلاين) ==========\n');
  }

  // ============================================
  // تسجيل الانصراف (أونلاين/أوفلاين)
  // ============================================
  Future<void> add_admin_check_out() async {
    if(connectivityHelper.hasConnection)
      await add_admin_check_out_online();
    else
      await add_admin_check_out_offline();
  }
  
  // ============================================
  // تسجيل الانصراف أونلاين
  // ============================================
  Future<void> add_admin_check_out_online() async {
    print('\n📤 ========== تسجيل انصراف المدير (أونلاين) ==========');
    try {
      isLoading.value = true;
      
      final now = DateTime.now();
      final checkOutTime = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
      
      final attendanceId = attendanceData["id"] ?? attendanceData["id_server"];
      
      if (attendanceId == null) {
        print('❌ لم يتم العثور على سجل الحضور');
        mySnackbar("خطأ", "لم يتم العثور على سجل الحضور");
        return;
      }
      
      print('⏰ وقت الانصراف: $checkOutTime');
      print('🆔 معرف السجل: $attendanceId');
      
      final response = await postData(
        Linkapi.add_admin_check_out,
        {
          "id": attendanceId,
          "check_out_time": checkOutTime,
        },
      );

      if (response == null) {
        print('❌ فشل الاتصال بالخادم');
        mySnackbar("خطأ", "فشل الاتصال بالخادم");
        return;
      }

      if (response is! Map) {
        print('❌ رد غير صحيح من الخادم');
        mySnackbar("خطأ", "رد غير صحيح من الخادم");
        return;
      }

      if (response["stat"] == "ok") {
        print('✅ تم تسجيل الانصراف بنجاح');
        
        // تحديث محلياً
        try {
          List<Map<String, dynamic>> localRecord = await db.query(
            "users_attendance",
            where: "id_user = ? AND attendance_date = ? AND id_circle = 0",
            whereArgs: [data_user["id_user"], formattedDate],
          );
          
          if (localRecord.isNotEmpty) {
            await db.update(
              'users_attendance',
              {'check_out_time': checkOutTime, 'stat': 'NoPending'},
              where: 'id_local = ?',
              whereArgs: [localRecord.first['id_local']],
            );
            print('✅ تم تحديث الانصراف محلياً');
          }
        } catch (e) {
          print('❌ خطأ في التحديث المحلي: $e');
        }
        
        attendanceStatus.value = "He_check_all";
        mySnackbar("نجاح", "تم تسجيل الانصراف بنجاح ✅", type: "g");
        await check_admin_attendance();
      } else {
        print('❌ فشل التسجيل: ${response["msg"]}');
        mySnackbar("خطأ", response["msg"] ?? "فشل تسجيل الانصراف");
      }
    } catch (e) {
      print('❌ خطأ: $e');
      mySnackbar("خطأ", "حدث خطأ أثناء تسجيل الانصراف");
    } finally {
      isLoading.value = false;
    }
    
    print('✅ ========== انتهى تسجيل انصراف المدير (أونلاين) ==========\n');
  }
  
  // ============================================
  // تسجيل الانصراف أوفلاين
  // ============================================
  Future<void> add_admin_check_out_offline() async {
    print('\n📱 ========== تسجيل انصراف المدير (أوفلاين) ==========');
    
    try {
      isLoading.value = true;
      
      final now = DateTime.now();
      final checkOutTime = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
      
      print('⏰ وقت الانصراف: $checkOutTime');
      
      // جلب السجل المحلي
      List<Map<String, dynamic>> localRecord = await db.query(
        "users_attendance",
        where: "id_user = ? AND attendance_date = ? AND id_circle = 0",
        whereArgs: [data_user["id_user"], formattedDate],
      );
      
      if (localRecord.isEmpty) {
        print('❌ لا يوجد سجل حضور لتسجيل الانصراف');
        mySnackbar("خطأ", "لا يوجد سجل حضور لتسجيل الانصراف");
        return;
      }
      
      int result = await db.update(
        'users_attendance',
        {'check_out_time': checkOutTime, 'stat': 'Pending'},
        where: 'id_local = ?',
        whereArgs: [localRecord.first['id_local']],
      );
      
      if (result > 0) {
        print('✅ تم حفظ الانصراف محلياً');
        attendanceStatus.value = "He_check_all";
        mySnackbar("نجاح", "تم تسجيل الانصراف ✅\n📱 محفوظ محلياً (بدون نت)", type: "g");
        await check_admin_attendance();
      } else {
        print('❌ فشل الحفظ المحلي');
        mySnackbar("فشل", "لم يتم حفظ الانصراف");
      }
    } catch (e) {
      print('❌ خطأ: $e');
      mySnackbar("خطأ", "حدث خطأ أثناء تسجيل الانصراف");
    } finally {
      isLoading.value = false;
    }
    
    print('✅ ========== انتهى تسجيل انصراف المدير (أوفلاين) ==========\n');
  }
  
  // ============================================
  // مزامنة حضور المدير المعلق
  // ============================================
  Future admin_attendancePending() async {

    if (!connectivityHelper.hasConnection) {

      return;
    }

    try {
      var pendingAttendance = await db.rawQuery('''
        SELECT * FROM users_attendance 
        WHERE stat = "Pending"
        AND id_user = ${data_user["id_user"]}
        AND id_circle = 0
      ''');

      if (pendingAttendance.isEmpty) {
        mySnackbar("نجاح", "لقد تم المزامنة  بنجاح",type: "g");
        return;
      }


      for (int i = 0; i < pendingAttendance.length; i++) {
        var attendance = pendingAttendance[i];
        bool syncSuccess = false;

        // إذا لم يكن لديه id_server (إضافة جديدة)
        if (attendance["id_server"] == null) {
          print('📤 مزامنة حضور جديد - id_local: ${attendance["id_local"]}');
          
          var res = await handleRequest(
            useDialog: false,
            isLoading: RxBool(false),
            action: () async {
              return await postData(Linkapi.add_admin_check_in, {
                "id_user": attendance["id_user"],
                "id_circle": 0,
                "check_in_time": attendance["check_in_time"],
                "attendance_date": attendance["attendance_date"],
              });
            },
          );

          if (res != null && res["stat"] == "ok") {
            int? serverId;
            if (res["id"] is int) {
              serverId = res["id"];
            } else if (res["id"] is String) {
              serverId = int.tryParse(res["id"]);
            }

            if (serverId != null && serverId > 0) {
              await db.update(
                'users_attendance',
                {
                  'id_server': serverId,
                  'stat': 'NoPending',
                },
                where: 'id_local = ?',
                whereArgs: [attendance["id_local"]],
              );
              syncSuccess = true;
              print('   ✅ تم مزامنة الحضور الجديد - id_server: $serverId');
              
              // إذا كان هناك انصراف، نرسله أيضاً
              if (attendance["check_out_time"] != null) {
                print('   📤 مزامنة الانصراف...');
                var resOut = await handleRequest(
                  useDialog: false,
                  isLoading: RxBool(false),
                  action: () async {
                    return await postData(Linkapi.add_admin_check_out, {
                      "id": serverId,
                      "check_out_time": attendance["check_out_time"],
                    });
                  },
                );
                
                if (resOut != null && resOut["stat"] == "ok") {
                  print('   ✅ تم مزامنة الانصراف');
                } else {
                  print('   ❌ فشلت مزامنة الانصراف');
                }
              }
            }
          } else {
            print('   ❌ فشلت مزامنة الحضور الجديد');
          }
        }
        // إذا كان لديه id_server (تحديث انصراف)
        else if (attendance["check_out_time"] != null) {
          print('📝 مزامنة انصراف - id_server: ${attendance["id_server"]}');
          
          var res = await handleRequest(
            useDialog: false,
            isLoading: RxBool(false),
            action: () async {
              return await postData(Linkapi.add_admin_check_out, {
                "id": attendance["id_server"],
                "check_out_time": attendance["check_out_time"],
              });
            },
          );

          if (res != null && res["stat"] == "ok") {
            await db.update(
              'users_attendance',
              {'stat': 'NoPending'},
              where: 'id_local = ?',
              whereArgs: [attendance["id_local"]],
            );
            syncSuccess = true;
            print('   ✅ تم مزامنة الانصراف');
          } else {
            print('   ❌ فشلت مزامنة الانصراف');
          }
          final attendanceDate = DateFormat('yyyy-MM-dd', "en").format(DateTime.now());

           await db.delete("users_attendance",
              where: "attendance_date !='${attendanceDate}' and stat!='Pending' and id_circle=0 "
          );
        }
      }
      check_admin_attendance();
    } catch (e, stackTrace) {
      print('❌ خطأ في مزامنة حضور المدير: $e');
      print('📍 Stack trace: $stackTrace');
    }
  }

}