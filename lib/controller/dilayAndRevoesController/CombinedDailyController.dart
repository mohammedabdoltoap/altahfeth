import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';

import '../../api/LinkApi.dart';
import '../../api/apiFunction.dart';
import '../../constants/function.dart';
import '../../globals.dart';

class CombinedDailyController extends GetxController {
  var dataArg_Student;
  var dataArglastDailyReport = Rxn<Map<String, dynamic>>();
  var dataLastReview = Rxn<Map<String, dynamic>>();

  // هل يجب إجبار المستخدم على إدخال البيانات للاثنين معاً؟
  RxBool forceBoth = false.obs;
  
  // تتبع ما إذا تم حفظ التسميع والمراجعة
  RxBool dailySaved = false.obs;
  RxBool reviewSaved = false.obs;

  // نوع النشاط الحالي (تسميع أو مراجعة)
  RxString currentType = "daily".obs; // "daily" أو "review"

  // التسميع اليومي
  TextEditingController dailyMarkController = TextEditingController();
  var daily_to_id_aya = Rx<int?>(null);
  var daily_toSoura = Rxn<Map<String, dynamic>>();

  // المراجعة اليومية
  TextEditingController reviewMarkController = TextEditingController();
  var review_from_id_aya = Rx<int?>(null);
  var review_to_id_aya = Rx<int?>(null);
  var review_fromSoura = Rxn<Map<String, dynamic>>();
  var review_toSoura = Rxn<Map<String, dynamic>>();

  var datasoura = <Map<String, dynamic>>[].obs;
  var datasoura_d = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> dataEvaluations = <Map<String, dynamic>>[].obs;
  RxnInt daily_selectedEvaluations = RxnInt(null);
  RxnInt review_selectedEvaluations = RxnInt(null);

  String formattedDate = "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}";

  @override
  void onInit() async {
    dataArg_Student = Get.arguments["student"];
    dataArglastDailyReport = Get.arguments["lastDailyReport"];
    dataLastReview = Get.arguments["dataLastReview"];
    forceBoth.value = Get.arguments["forceBoth"] ?? false;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      select_fromId_soura_with_to_soura();
      select_evaluations();
    });
  }

  // جلب السور
  Future select_fromId_soura_with_to_soura() async {
    if (connectivityHelper.hasConnection)
      await select_fromId_soura_with_to_souraOnline();
    else
      await select_fromId_soura_with_to_souraOfline();
  }

  Future select_fromId_soura_with_to_souraOnline() async {
    var res = await handleRequest(
      loadingMessage: "جاري تحميل سور القرآن...",
      isLoading: RxBool(false),
      action: () async {
        return await postData(Linkapi.select_fromId_soura_with_to_soura, {
          "id_level": dataArg_Student["id_level"],
          "id_soura": dataArglastDailyReport.value!["to_id_soura"],
        });
      },
    );
    if (res == null) return;

    if (res is! Map) {
      mySnackbar("خطأ", "فشل الاتصال بالخادم");
      return;
    }

    if (res["stat"] == "ok") {
      final surahs = List<Map<String, dynamic>>.from(res["data"]);
      datasoura.assignAll(surahs);
      datasoura_d.assignAll(
        datasoura.where(
              (e) => e["id_soura"] >= dataArglastDailyReport.value!["to_id_soura"],
        ),
      );

    } else if (res["stat"] == "no") {
      String errorMsg = res["msg"] ?? "لايوجد سور";
      mySnackbar("لايوجد", errorMsg);
    } else {
      String errorMsg = res["msg"] ?? "خطأ في جلب السور";
      mySnackbar("خطأ", errorMsg);
    }
  }

  Future select_fromId_soura_with_to_souraOfline() async {
    final res = await selectFromIdSouraWithToSoura(
      db: db,
      idLevel: dataArg_Student["id_level"],
      // idSoura: dataArglastDailyReport.value!["to_id_soura"],
      idSoura: 1,
    );
    print("dataArglastDailyReport=${dataArglastDailyReport}");
    if (res["stat"] == "ok") {
      final surahs = List<Map<String, dynamic>>.from(res["data"]);
      datasoura.assignAll(surahs);
      datasoura_d.assignAll(
        datasoura.where(
              (e) => e["id_soura"] >= dataArglastDailyReport.value!["to_id_soura"],
        ),
      );

      print("datasoura==${datasoura}");
    } else if (res["stat"] == "no") {
      String errorMsg = res["msg"] ?? "لايوجد سور";
      mySnackbar("لايوجد", errorMsg);
    } else {
      String errorMsg = res["msg"] ?? "خطأ في جلب السور";
      mySnackbar("خطأ", errorMsg);
    }
  }

  Future<Map<String, dynamic>> selectFromIdSouraWithToSoura({
    required Database db,
    required int idLevel,
    required int idSoura,
  }) async {
    try {
      List<Map<String, dynamic>> result = await db.rawQuery("""
      SELECT sq.*
      FROM level l
      JOIN sour_quran sq 
        ON sq.id_soura BETWEEN ? AND l.to_id_soura
      WHERE l.id_level = ?
    """, [idSoura, idLevel]);

      if (result.isNotEmpty) {
        return {
          "stat": "ok",
          "data": result,
        };
      }

      return {
        "stat": "no",
      };
    } catch (e) {
      return {
        "stat": "error",
        "msg": "حدث خطأ أثناء تنفيذ الاستعلام: $e",
      };
    }
  }

  // جلب التقييمات
  Future select_evaluations() async {
    if (connectivityHelper.hasConnection) {
      await select_evaluationsOnline();
    } else {
      await select_evaluationsOfline();
    }
  }

  Future select_evaluationsOfline() async {
    List d = await db.rawQuery("select * from evaluations");
    if (d.isNotEmpty) dataEvaluations.assignAll(List.from(d));
  }

  Future select_evaluationsOnline() async {
    final res = await handleRequest<dynamic>(
      isLoading: RxBool(false),
      useDialog: false,
      action: () async {
        return await postData(Linkapi.select_evaluations, {});
      },
    );

    if (res == null) return;
    if (res is! Map) {
      mySnackbar("خطأ", "فشل الاتصال بالخادم");
      return;
    }

    if (res["stat"] == "ok") {
      final evaluations = List<Map<String, dynamic>>.from(res["data"]);
      dataEvaluations.assignAll(evaluations);
    } else {
      String errorMsg = res["msg"] ?? "خطأ في جلب التقييمات";
      mySnackbar("خطأ", errorMsg);
    }
  }

  // حفظ التسميع والمراجعة معاً
  Future saveBoth() async {
    // التحقق من إدخال بيانات التسميع
    if (daily_toSoura.value == null) {
      mySnackbar("تنبيه", "يجب تحديد سورة النهاية للتسميع");
      return;
    }
    if (daily_to_id_aya.value == null) {
      mySnackbar("تنبيه", "يجب تحديد آية النهاية للتسميع");
      return;
    }
    if (dailyMarkController.text.isEmpty) {
      mySnackbar("تنبيه", "يجب إدخال درجة التسميع");
      return;
    }
    if (daily_selectedEvaluations.value == null) {
      mySnackbar("تنبيه", "يجب اختيار تقييم التسميع");
      return;
    }

    // التحقق من إدخال بيانات المراجعة
    if (review_fromSoura.value == null) {
      mySnackbar("تنبيه", "يجب تحديد سورة البداية للمراجعة");
      return;
    }
    if (review_from_id_aya.value == null) {
      mySnackbar("تنبيه", "يجب تحديد آية البداية للمراجعة");
      return;
    }
    if (review_toSoura.value == null) {
      mySnackbar("تنبيه", "يجب تحديد سورة النهاية للمراجعة");
      return;
    }
    if (review_to_id_aya.value == null) {
      mySnackbar("تنبيه", "يجب تحديد آية النهاية للمراجعة");
      return;
    }
    if (reviewMarkController.text.isEmpty) {
      mySnackbar("تنبيه", "يجب إدخال درجة المراجعة");
      return;
    }
    if (review_selectedEvaluations.value == null) {
      mySnackbar("تنبيه", "يجب اختيار تقييم المراجعة");
      return;
    }

    // التحقق من صحة نطاق المراجعة
    if (review_fromSoura.value!["id_soura"] > review_toSoura.value!["id_soura"]) {
      mySnackbar("تنبيه", "يجب أن يكون رقم سورة النهاية أكبر من رقم سورة البداية في المراجعة");
      return;
    }
    if (review_fromSoura.value!["id_soura"] == review_toSoura.value!["id_soura"] &&
        ((review_from_id_aya.value ?? 0) >= (review_to_id_aya.value ?? 0))) {
      mySnackbar("تنبيه", "يجب أن يكون رقم آية النهاية أكبر من البداية في المراجعة");
      return;
    }

    // حفظ التسميع أولاً
    await addDailyReport();
    
    // ثم حفظ المراجعة
    await addReview();
  }

  // حفظ التسميع اليومي (يستخدم داخلياً من saveBoth)
  Future addDailyReport() async {

    Map<String, Object?> data = {
      "id_student": dataArg_Student["id_student"],
      "from_id_soura": dataArglastDailyReport.value?["to_id_soura"],
      "from_id_aya": dataArglastDailyReport.value?["to_id_aya"],
      "to_id_soura": daily_toSoura.value!["id_soura"],
      "to_id_aya": daily_to_id_aya.value,
      "id_user": dataArg_Student["id_user"],
      "id_circle": dataArg_Student["id_circle"],
      "mark": dailyMarkController.text,
      "id_evaluation": daily_selectedEvaluations.value,
      "date": formattedDate
    };

    if (connectivityHelper.hasConnection) {
      await addDailyReportOnline(data);
    } else {
      await addDailyReportOffline(data);
    }
  }

  Future addDailyReportOffline(data) async {
    data["stat"] = 0;
    int res = await db.insert("daily_report", data);
    if (res > 0) {
      Get.back();
      mySnackbar("نجاح", "تم الإضافة بنجاح محلياً... يرجى الاتصال بالإنترنت في أقرب وقت لمزامنة البيانات", type: "g");
    } else {
      mySnackbar("فشل", "حصل خطأ في حفظ البيانات حاول مجدداً أو قم بالاتصال بالإنترنت");
    }
  }

  Future addDailyReportOnline(data) async {
    final res = await handleRequest(
      isLoading: RxBool(false),
      loadingMessage: "جاري حفظ التسميع...",
      defaultErrorTitle: "لم يتم حفظ التسميع",
      action: () async {
        return await postData(Linkapi.addDailyReport, data);
      },
    );

    if (res == null) return;

    if (res is! Map) {
      mySnackbar("تحذير", "فشل الاتصال بالخادم");
      return;
    }

    if (res["stat"] == "ok") {
      try {
        final serverId = res["data"];

        if (serverId != null) {
          int? idDailyReport;
          if (serverId is int) {
            idDailyReport = serverId;
          } else if (serverId is String) {
            idDailyReport = int.tryParse(serverId);
          }

          if (idDailyReport != null && idDailyReport > 0) {
            data["id_daily_report"] = idDailyReport;
            data["stat"] = 1;
            int result = await db.insert("daily_report", data);

            if (result > 0) {
              print('✅ تم حفظ التقرير محلياً بنجاح');
            }
          }
        }

        dailySaved.value = true;
        mySnackbar("نجاح", "تم حفظ التسميع بنجاح", type: "g");
        
        // إذا كان forceBoth = true وتم حفظ الاثنين، نرجع للصفحة السابقة
        if (forceBoth.value && reviewSaved.value) {
          Get.back();
          mySnackbar("نجاح", "تم حفظ التسميع والمراجعة بنجاح", type: "g");
        } else if (!forceBoth.value) {
          // إذا لم يكن إجباري، نرجع مباشرة
          Get.back();
        }
      } catch (e) {
        dailySaved.value = true;
        mySnackbar("نجاح", "تم حفظ التسميع للخادم بنجاح", type: "g");
        
        if (forceBoth.value && reviewSaved.value) {
          Get.back();
        } else if (!forceBoth.value) {
          Get.back();
        }
      }
    } else {
      String errorMsg = res["msg"] ?? "حصل خطأ غير محدد";
      mySnackbar("تحذير", errorMsg);
    }
  }

  // حفظ المراجعة اليومية (يستخدم داخلياً من saveBoth)
  Future addReview() async {

    Map<String, Object?> data = {
      "id_student": dataArg_Student["id_student"],
      "from_id_soura": review_fromSoura.value!["id_soura"],
      "from_id_aya": review_from_id_aya.value,
      "to_id_soura": review_toSoura.value!["id_soura"],
      "to_id_aya": review_to_id_aya.value,
      "id_user": dataArg_Student["id_user"],
      "id_circle": dataArg_Student["id_circle"],
      "mark": reviewMarkController.text,
      "id_evaluation": review_selectedEvaluations.value,
      "date": formattedDate,
    };

    if (connectivityHelper.hasConnection) {
      await addReviewOnline(data);
    } else {
      await addReviewOffline(data);
    }
  }

  Future addReviewOffline(data) async {
    data["stat"] = 0;
    int res = await db.insert("review", data);
    if (res > 0) {
      Get.back();
      mySnackbar("نجاح", "تم الإضافة بنجاح محلياً... يرجى الاتصال بالإنترنت في أقرب وقت لمزامنة البيانات", type: "g");
    } else {
      mySnackbar("فشل", "حصل خطأ في حفظ البيانات حاول مجدداً أو قم بالاتصال بالإنترنت");
    }
  }

  Future addReviewOnline(data) async {
    final res = await handleRequest(
      isLoading: RxBool(false),
      loadingMessage: "جاري حفظ المراجعة...",
      defaultErrorTitle: "لم يتم حفظ المراجعة",
      action: () async {
        return await postData(Linkapi.addReview, data);
      },
    );

    if (res == null) return;

    if (res is! Map) {
      mySnackbar("تحذير", "فشل الاتصال بالخادم");
      return;
    }

    if (res["stat"] == "ok") {
      try {
        final serverId = res["data"];

        if (serverId != null) {
          int? idReview;
          if (serverId is int) {
            idReview = serverId;
          } else if (serverId is String) {
            idReview = int.tryParse(serverId);
          }

          if (idReview != null && idReview > 0) {
            data["id_review"] = idReview;
            data["stat"] = 1;
            int result = await db.insert("review", data);

            if (result > 0) {
              print('✅ تم حفظ المراجعة محلياً بنجاح');
            }
          }
        }

        reviewSaved.value = true;

        // إذا كان forceBoth = true وتم حفظ الاثنين، نرجع للصفحة السابقة
        if (forceBoth.value && dailySaved.value) {
          Get.back();
          mySnackbar("نجاح", "تم حفظ التسميع والمراجعة بنجاح", type: "g");
        } else if (!forceBoth.value) {
          // إذا لم يكن إجباري، نرجع مباشرة
          Get.back();
        }
      } catch (e) {
        reviewSaved.value = true;
        mySnackbar("نجاح", "تم حفظ المراجعة للخادم بنجاح", type: "g");
        
        if (forceBoth.value && dailySaved.value) {
          Get.back();
        } else if (!forceBoth.value) {
          Get.back();
        }
      }
    } else {
      String errorMsg = res["msg"] ?? "حصل خطأ غير محدد";
      mySnackbar("تحذير", errorMsg);
    }
  }
}
