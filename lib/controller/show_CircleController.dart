import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../api/LinkApi.dart';
import '../api/apiFunction.dart';
import '../constants/function.dart';
import '../globals.dart';
import '../utils/ConnectivityHelper.dart';
import '../utils/LocalDatabase.dart';

class Show_CircleController extends GetxController {
  var dataArg;
  RxBool isLoading = false.obs;


  @override
  void onInit() {
    super.onInit();
    dataArg = Get.arguments;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      get_circle();
    });
  }

  RxList<Map<String, dynamic>> data_circle = <Map<String, dynamic>>[].obs;

  /// 🔄 الدالة الرئيسية لجلب الحلقات (Online/Offline)
  Future<void> get_circle() async {

    if (isLoading.value) return;
    isLoading.value = true;
    
    try {
      // 1️⃣ فحص الاتصال بالإنترنت
      final hasConnection = connectivityHelper.hasConnection;
      
      if (hasConnection) {
        // ✅ إذا كان هناك نت: جلب من API
        print('📡 الاتصال موجود، محاولة جلب الحلقات من الخادم...');
        await _getCirclesFromInternet();
      } else {
        print('📵 لا يوجد اتصال، محاولة جلب الحلقات محلياً...');

        await _getCirclesOffline();
      }
    } catch (e) {
      print('❌ خطأ في جلب الحلقات: $e');
      mySnackbar("خطأ", "حدث خطأ أثناء جلب الحلقات");
    } finally {
      isLoading.value = false;
    }
  }

  /// 🌐 جلب الحلقات من الخادم (عبر الإنترنت)
  Future<void> _getCirclesFromInternet() async {
    try {
      // 1️⃣ استدعاء API مباشرة
      final res = await handleRequest(isLoading: RxBool(false), useDialog: false,action: ()async {
    return  await postData(Linkapi.get_circle, {
      "id_user": dataArg["id_user"]
    });

      },);


      // 2️⃣ التحقق من الرد
      if (res == null) {
        return;
      }

      if (res is! Map) {
        mySnackbar("خطأ", "رد غير صحيح من الخادم");
        return;
      }

      // 3️⃣ معالجة الرد
      if (res["stat"] == "ok") {
        // ✅ نجح: تحديث البيانات وحفظ محلياً
        final circles = List<Map<String, dynamic>>.from(res["data"]);
        data_circle.assignAll(circles);


         _saveCirclesLocally(circles);

      } else if (res["stat"] == "no") {
        // ⚠️ لا توجد حلقات
        String errorMsg = res["msg"] ?? "لا يوجد لديك حلقات حالياً";
        mySnackbar("تنبيه", errorMsg, type: "y");
      } else {
        // ❌ خطأ من الخادم
        String errorMsg = res["msg"] ?? "تعضر جلب الحلقات";
        mySnackbar("خطأ", errorMsg);
      }
    } catch (e) {
      print('❌ خطأ في جلب الحلقات من الخادم: $e');
      mySnackbar("خطأ", "فشل الاتصال بالخادم");
    }
  }

  Future _getCirclesOffline() async {

    try {
      final circles = await db.query(
          'circles',
          where: "id_user =${dataArg["id_user"]}"
      );
      print('✅ تم جلب ${circles.length} حلقة محلياً');
      data_circle.assignAll(circles);

    } catch (e) {
      print('❌ خطأ في جلب الحلقات: $e');
      data_circle.clear();
    }
  }

  Future<void> _saveCirclesLocally(List<Map<String, dynamic>> circles) async {
    try {
      for (var circle in circles) {
        // إضافة معرف المستخدم والتاريخ
        final circleToSave = {
          ...circle,
        };
        // حفظ كل حلقة
         saveCircle(circleToSave);
      }
      print('✅ تم حفظ ${circles.length} حلقة محلياً');
    } catch (e) {
      print('❌ خطأ في حفظ الحلقات: $e');
    }
  }
  Future<void> saveCircle(Map<String, dynamic> circleData) async {
    // final db=await _localDb.database;
    try {
      // التحقق من وجود الحلقة
      final existing = await db.query(
        'circles',
        where: 'id_circle = ?',
        whereArgs: [circleData['id_circle']],
      );

      if (existing.isNotEmpty) {
        // تحديث الحلقة الموجودة
        await db.update(
          'circles',
          circleData,
          where: 'id_circle = ?',
          whereArgs: [circleData['id_circle']],
        );
        print('✅ تم تحديث الحلقة محلياً: ${circleData['name_circle']}');
      } else {
        // إدراج حلقة جديدة
        await db.insert('circles', circleData);
        print('✅ تم حفظ الحلقة محلياً: ${circleData['name_circle']}');
      }
    } catch (e) {
      print('❌ خطأ في حفظ الحلقة: $e');
      rethrow;
    }
  }


}

