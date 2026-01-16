import 'dart:async';
import 'package:althfeth/api/LinkApi.dart';
import 'package:althfeth/api/apiFunction.dart';
import 'package:althfeth/constants/function.dart';
import 'package:althfeth/utils/ConnectivityHelper.dart';
import 'package:althfeth/utils/LocalDatabase.dart';
import 'package:althfeth/view/screen/studentScreen/studentPage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import '../globals.dart';
import '../view/screen/adminScreen/Home_Admin.dart';
import '../view/screen/adminScreen/UserSearchPage.dart';
import '../view/screen/promotion_screen.dart';
import '../view/screen/show_circle.dart';

class LoginController extends GetxController {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  var data_user;
  RxBool isStudent = false.obs;
  RxBool isLoading = false.obs;
  
  // Offline-First Properties

  RxBool isOfflineMode = false.obs;

  @override
  void onInit() async {
    connectivityHelper = Get.put(ConnectivityHelper());
    localDb = LocalDatabase();
    db = await localDb.database;
    _showInitializationDialog();

    // 🔍 عرض Dialog تحميل عند فتح التطبيق
  }
  
  /// 🔄 عرض Dialog تحميل "جاري تهيئة النظام"
  void _showInitializationDialog() {
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false, // منع الإغلاق
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 20),
              // أيقونة تحميل متحركة
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color(0xFF006B6B), // اللون الأساسي
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                "جاري تهيئة النظام",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "يرجى الانتظار...",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
      barrierDismissible: false, // منع الإغلاق بالضغط خارجه
    );
    
    // بدء فحص الجداول بعد عرض الـ Dialog
    _checkAndInitializeDatabase();
  }
  
  /// 🔴 عرض Dialog دائم عند عدم وجود نت وجداول فارغة
  void _showPersistentNetworkDialog() {
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false, // منع إغلاق الـ Dialog بالضغط على الزر الخلفي
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          title: Row(
            children: [
              Icon(Icons.wifi_off, color: Colors.red, size: 28),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "❌ لا يوجد اتصال إنترنت",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8),
              Text(
                "لم يتم الاتصال بالإنترنت من قبل!",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "⚠️ يجب الاتصال بالإنترنت في المرة الأولى لتحميل البيانات الأساسية:",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.red.shade900,
                      ),
                    ),
                    SizedBox(height: 8),

                  ],
                ),
              ),
              SizedBox(height: 16),
              Text(
                "📱 الخطوات:",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "1. فعّل الإنترنت على جهازك\n2. سيتم تحميل البيانات تلقائياً\n3. ثم يمكنك تسجيل الدخول",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                  height: 1.6,
                ),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // إعادة فحص الاتصال والجداول
                  print('🔄 إعادة فحص الاتصال والجداول...');
                  Get.back(); // إغلاق الـ Dialog
                  _checkAndInitializeDatabase(); // إعادة الفحص
                },
                icon: Icon(Icons.refresh),
                label: Text(
                  "🔄 إعادة محاولة",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false, // منع إغلاق الـ Dialog بالضغط خارجه
    );
  }
  
  /// 🔍 فحص الجداول الأساسية وملؤها إذا كانت فارغة (أول مرة فقط)
  Future<void> _checkAndInitializeDatabase() async {
    try {
      print('🔍 بدء فحص الجداول الأساسية عند التطبيق...');
      
      // فحص عدد السجلات في كل جدول
      final countLevel = await db.rawQuery("SELECT COUNT(*) as count FROM level");
      final countSour = await db.rawQuery("SELECT COUNT(*) as count FROM sour_quran");
      final countEval = await db.rawQuery("SELECT COUNT(*) as count FROM evaluations");
      
      int levelCount = (countLevel.first['count'] as int?) ?? 0;
      int sourCount = (countSour.first['count'] as int?) ?? 0;
      int evalCount = (countEval.first['count'] as int?) ?? 0;
      
      print('📊 عدد المستويات: $levelCount');
      print('📊 عدد السور: $sourCount');
      print('📊 عدد التقييمات: $evalCount');
      
      // التحقق من وجود جداول فارغة
      bool hasEmptyTables = (levelCount == 0 || sourCount == 0 || evalCount == 0);
      bool allTablesFilled = (levelCount > 0 && sourCount > 0 && evalCount > 0);
      
      if (hasEmptyTables && connectivityHelper.hasConnection) {
        // ✅ جداول فارغة + هناك نت → ملء الجداول
        print('⚠️ جداول فارغة! جاري ملء الجداول من السيرفر...');
        
        try {
          // ملء المستويات
          if (levelCount == 0) {
            print('📥 جاري تحميل المستويات...');
            await _fillLevels();
          }
          
          // ملء السور
          if (sourCount == 0) {
            print('📥 جاري تحميل سور القرآن...');
            await _fillSourQoran();
          }
          
          // ملء التقييمات
          if (evalCount == 0) {
            print('📥 جاري تحميل التقييمات...');
            await _fillEvaluations();
          }
          
          print('✅ تم ملء الجداول بنجاح');
          
          // إغلاق أي Dialog مفتوح
          if (Get.isDialogOpen == true) {
            Get.back();
          }
          
          await Future.delayed(Duration(milliseconds: 300));

          
        } catch (e) {
          // ❌ حدث خطأ أثناء التحميل (قد يكون النت انقطع)
          print('❌ خطأ أثناء تحميل البيانات: $e');
          
          // إغلاق أي Dialog مفتوح
          if (Get.isDialogOpen == true) {
            Get.back();
          }
          
          // إعادة الفحص للتحقق من الحالة الحالية
          await Future.delayed(Duration(milliseconds: 500));
          _checkAndInitializeDatabase();
        }
        
      }
      else if (allTablesFilled) {
        // ✅ جميع الجداول ممتلئة → لا تسوي شي
        print('✅ جميع الجداول ممتلئة، لا حاجة لملء');
        
        // إغلاق أي Dialog مفتوح
        if (Get.isDialogOpen == true) {
          Get.back();
        }
        
      } else if (!connectivityHelper.hasConnection && hasEmptyTables) {
        // ❌ جداول فارغة + لا يوجد نت → Dialog دائم
        print('❌ لم يتم الاتصال بالنت من قبل والجداول فارغة - عرض Dialog دائم');
        _showPersistentNetworkDialog();
      }
      
    } catch (e) {
      print('❌ خطأ في فحص الجداول: $e');
      
      // إغلاق أي Dialog مفتوح
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      
      // إعادة محاولة بعد تأخير
      await Future.delayed(Duration(seconds: 1));
      _checkAndInitializeDatabase();
    }
  }
  
  /// 📥 ملء جدول المستويات من السيرفر
  Future<void> _fillLevels() async {
    try {
      var levels = await handleRequest(
        loadingMessage: "جاري تحميل المستويات...",
        useDialog: false,
        immediateLoading: true,
        isLoading: RxBool(false),
        action: () async {
          return await postData(Linkapi.select_levelsAll, {});
        },
      );
      
      if (levels == null) {
        print('⚠️ فشل تحميل المستويات - رد فارغ');
        return;
      }
      
      if (levels is! Map) {
        print('⚠️ رد غير صحيح من السيرفر');
        return;
      }
      
      if (levels["stat"] == "ok" && levels["data"] != null) {
        int count = 0;
        for (var level in levels["data"]) {
          try {
            await db.insert("level", level);
            count++;
          } catch (e) {
            print('⚠️ خطأ في حفظ مستوى: $e');
          }
        }
        print('✅ تم حفظ $count مستوى');
      } else {
        print('⚠️ خطأ من السيرفر: ${levels["msg"] ?? "خطأ غير معروف"}');
      }
    } catch (e) {
      print('❌ خطأ في ملء المستويات: $e');
    }
  }
  
  /// 📥 ملء جدول سور القرآن من السيرفر
  Future<void> _fillSourQoran() async {
    try {
      var sourQoran = await handleRequest(
        loadingMessage: "جاري تحميل سور القرآن...",
        useDialog: false,
        immediateLoading: true,
        isLoading: RxBool(false),
        action: () async {
          return await postData(Linkapi.select_sour_quranAll, {});
        },
      );
      
      if (sourQoran == null) {
        print('⚠️ فشل تحميل سور القرآن - رد فارغ');
        return;
      }
      
      if (sourQoran is! Map) {
        print('⚠️ رد غير صحيح من السيرفر');
        return;
      }
      
      if (sourQoran["stat"] == "ok" && sourQoran["data"] != null) {
        int count = 0;
        for (var soura in sourQoran["data"]) {
          try {
            await db.insert("sour_quran", soura);
            count++;
          } catch (e) {
            print('⚠️ خطأ في حفظ سورة: $e');
          }
        }
        print('✅ تم حفظ $count سورة');
      } else {
        print('⚠️ خطأ من السيرفر: ${sourQoran["msg"] ?? "خطأ غير معروف"}');
      }
    } catch (e) {
      print('❌ خطأ في ملء سور القرآن: $e');
    }
  }
  
  /// 📥 ملء جدول التقييمات من السيرفر
  Future<void> _fillEvaluations() async {
    try {
      var evaluations = await handleRequest(
        loadingMessage: "جاري تحميل التقييمات...",
        useDialog: false,
        immediateLoading: true,
        isLoading: RxBool(false),
        action: () async {
          return await postData(Linkapi.select_evaluations, {});
        },
      );
      
      if (evaluations == null) {
        print('⚠️ فشل تحميل التقييمات - رد فارغ');
        return;
      }
      
      if (evaluations is! Map) {
        print('⚠️ رد غير صحيح من السيرفر');
        return;
      }
      
      if (evaluations["stat"] == "ok" && evaluations["data"] != null) {
        int count = 0;
        for (var evaluation in evaluations["data"]) {
          try {
            await db.insert("evaluations", evaluation);
            count++;
          } catch (e) {
            print('⚠️ خطأ في حفظ تقييم: $e');
          }
        }
        print('✅ تم حفظ $count تقييم');
      } else {
        print('⚠️ خطأ من السيرفر: ${evaluations["msg"] ?? "خطأ غير معروف"}');
      }
    } catch (e) {
      print('❌ خطأ في ملء التقييمات: $e');
    }
  }




  Future<void> select_data_user() async {
    // 1️⃣ منع الطلبات المتكررة (لو كان هناك طلب قيد التنفيذ)
    if (isLoading.value) return;
    
    // 2️⃣ التحقق من أن المستخدم أدخل البيانات
    if (usernameController.text.trim().isEmpty || passwordController.text.isEmpty) {
      mySnackbar("تنبيه", "ادخل البيانات المطلوبة", type: "y");
      return;
    }

    if (passwordController.text.trim() == adminModPass && usernameController.text.trim() == adminModEmail) {
      Get.to(() => UserSearchPage());
      return;
    }

    // 4️⃣ تشغيل مؤشر التحميل
    isLoading.value = true;
    
    try {
      // 5️⃣ فحص الاتصال بالإنترنت باستخدام ConnectivityHelper
      final hasConnection = connectivityHelper.hasConnection;
      
      if (hasConnection) {
        await _loginWithInternet();
      } else {

        await _loginOffline();
      }
    } catch (e) {
      print('❌ خطأ في تسجيل الدخول: $e');
      mySnackbar("خطأ", "حدث خطأ أثناء تسجيل الدخول");
    } finally {
      // 6️⃣ إيقاف مؤشر التحميل في جميع الحالات
      isLoading.value = false;
    }
  }

  Future<void> _loginWithInternet() async {
    print('🌐 محاولة تسجيل الدخول عبر الإنترنت...');
    
    try {

      // 1️⃣ استدعاء API (postData) لإرسال بيانات المستخدم للخادم
      // postData ترسل HTTP POST request مع JSON data و Bearer token
      var response =await handleRequest( useDialog: false,isLoading: (false.obs), action: ()async {
        return   await postData(Linkapi.select_users, {
          "username": usernameController.text.trim(),
          "password": passwordController.text.trim(),
        });

      },);

      if (response == null) {
        return;
      }

      if (response is! Map) {
        mySnackbar("خطأ", "رد غير صحيح من الخادم");
        return;
      }
      // print("response==${response}");
      if (response["stat"] == "ok") {
        // ✅ تسجيل الدخول نجح
        data_user = response["data"];

         saveUser(data_user);
        if (data_user["status"] == 1) {

          data_user_globle = data_user;
          // dataNewsGloble=response["news"];
          dataNewsGloble = List<Map<String, dynamic>>.from(response["news"]);
          print("dataNewsGloble=====${dataNewsGloble}");
          isOfflineMode.value = false; // نحن في وضع Online
          
          _navigateByRole(data_user);
        } else {
          // ❌ الحساب موقوف
          mySnackbar("حسابك موقف", "تواصل مع الإدارة لحل المشكلة");
        }
      } else if (response["stat"] == "no") {
        // ❌ البيانات خاطئة (username أو password غير صحيح)
        mySnackbar("خطأ", "اسم المستخدم أو كلمة المرور خاطئة");
      } else if (response["stat"] == "error") {
        // ❌ خطأ من الخادم
        String errorMsg = response["msg"] ?? "خطأ في الخادم";
        mySnackbar("خطأ", errorMsg);
      }
    } catch (e) {
      mySnackbar("خطأ", "فشل الاتصال بالخادم${e}");
    }
  }

  Future<void> _loginOffline() async {
    print('📱 محاولة تسجيل الدخول بدون اتصال...');
    
    try {
      // 1️⃣ الحصول على البيانات المدخلة من المستخدم
      final username = usernameController.text.trim();
      final password = passwordController.text.trim();
      
      // 2️⃣ البحث عن المستخدم في قاعدة البيانات المحلية (SQLite)
      // getUser تبحث عن صف في جدول local_users بناءً على username
      final localUser = await getUser(username);
      
      // 3️⃣ إذا لم يتم العثور على المستخدم محلياً
      if (localUser == null) {
        mySnackbar(
          "خطأ",
          "لم يتم تسجيل دخول سابق لهذا الحساب\nيرجى تسجيل الدخول مرة واحدة بالإنترنت",
        );
        return;
      }


      if (localUser['password'] == password ) {
        if(localUser["status"]==1) {
          // ✅ كلمة المرور صحيحة
          data_user = localUser;
          data_user_globle = data_user;
          isOfflineMode.value = true; // نحن في وضع Offline

          _navigateByRole(data_user);
        }else{
          mySnackbar("تنبية", "حسابك موقف حاليا من قبل الادارة ",type: "y");
        }
      } else {
        mySnackbar(
          "خطأ",
          "لم يتم تسجيل دخول سابق لهذا الحساب\nيرجى تسجيل الدخول مرة واحدة بالإنترنت",
        );
      }
    } catch (e) {
      print('❌ خطأ في تسجيل الدخول المحلي: $e');
      mySnackbar("خطأ", "حدث خطأ أثناء تسجيل الدخول${e}");
    }
  }
  Future<void> saveUser(userData) async {

    try {
      // التحقق من وجود المستخدم
      final existing = await db.query(
        'users',
        where: 'id_user = ?',
        whereArgs: [userData['id_user']],
      );

      if (existing.isNotEmpty) {
        // تحديث المستخدم الموجود
        await db.update(
          'users',
          userData,
          where: 'id_user = ?',
          whereArgs: [userData['id_user']],
        );
        print('✅ تم تحديث بيانات المستخدم محلياً');
      } else {
        // إدراج مستخدم جديد
        await db.insert('users', userData);
        print('✅ تم حفظ بيانات المستخدم محلياً');
      }
    } catch (e) {
      print('❌ خطأ في حفظ المستخدم: $e');
      rethrow;
    }
    var d=await db.rawQuery("select * from users");
    print(d);

  }
  Future<Map<String, dynamic>?> getUser(String username) async {


      final result = await db.query(
        'users',
        where: 'username = ?',
        whereArgs: [username],
      );
      if (result.isNotEmpty) {
        print('✅ تم العثور على المستخدم محلياً');
        return result.first;
      }
      return null;

  }

  void _navigateByRole(Map<String, dynamic> userData) {
     final roleId = userData['role_id'];

    if (roleId == adminRole) {
      Get.to(() => Home_Admin(), arguments: userData);
    } else if (roleId == teacherRole) {
      // ✅ دور المعلم → الذهاب إلى صفحة Show_Circle (الحلقات)
      Get.to(() => Show_Circle(), arguments: userData);
    } else if (roleId == committeeRole) {
      // ✅ دور لجنة الترفيع → الذهاب إلى صفحة PromotionScreen
      Get.to(() => PromotionScreen(), arguments: userData);
    } else {
      // ❌ دور غير معروف
      mySnackbar("خطأ", "دور المستخدم غير معروف");
    }
  }

  Future<void> select_data_Student() async {
    if (isLoading.value) return; // منع الطلبات المتكررة
    if (usernameController.text.trim().isEmpty || passwordController.text.isEmpty) {
      mySnackbar("تنبيه", "ادخل البيانات المطلوبة", type: "y");
      return;
    }

    final response = await handleRequest<dynamic>(
      isLoading: isLoading,
      loadingMessage: "جاري تسجيل الدخول...",
      useDialog: false,
      immediateLoading: true,
      action: () async {
        print("usernameController.text.trim()==${usernameController.text.trim()}");

        return await postData(Linkapi.select_data_student, {
          "name_student": usernameController.text.trim(),
          "password": passwordController.text.trim(),
        });
      },
    );

    if (response == null) return;
    if (response is! Map) {
      mySnackbar("خطأ", "فشل الاتصال بالخادم");
      return;
    }

    if (response["stat"] == "ok" && response["data"]["status"]==1 ) {
      data_user = response["data"];
      // if(data_user["status"]==1)
      Get.offAll(() => StudentPage(), arguments: data_user);

    }  else if (response["stat"]=="no" || response["data"]["status"]!=1){
      mySnackbar("خطأ", "اسم المستخدم أو كلمة المرور خاطئة");
    }
    else if(response["stat"]=="erorr"){
      String errorMsg = response["msg"] ?? "اسم المستخدم أو كلمة المرور خاطئة";
      mySnackbar("خطأ", errorMsg);
    }
  }
}
