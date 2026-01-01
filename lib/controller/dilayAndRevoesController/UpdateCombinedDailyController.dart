import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';

import '../../api/LinkApi.dart';
import '../../api/apiFunction.dart';
import '../../constants/function.dart';
import '../../globals.dart';

class UpdateCombinedDailyController extends GetxController {
  var dataArg_Student;
  var dataArglastDailyReport = Rxn<Map<String, dynamic>>();
  var dataLastReview = Rxn<Map<String, dynamic>>();

  // التسميع اليومي
  TextEditingController dailyMarkController = TextEditingController();
  var daily_from_id_aya = Rx<int?>(null);
  var daily_to_id_aya = Rx<int?>(null);
  var daily_fromSoura = Rxn<Map<String, dynamic>>();
  var daily_toSoura = Rxn<Map<String, dynamic>>();

  // المراجعة اليومية
  TextEditingController reviewMarkController = TextEditingController();
  var review_from_id_aya = Rx<int?>(null);
  var review_to_id_aya = Rx<int?>(null);
  var review_fromSoura = Rxn<Map<String, dynamic>>();
  var review_toSoura = Rxn<Map<String, dynamic>>();

  var datasoura = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> dataEvaluations = <Map<String, dynamic>>[].obs;
  RxnInt daily_selectedEvaluations = RxnInt(null);
  RxnInt review_selectedEvaluations = RxnInt(null);

  String formattedDate = "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}";

  @override
  void onInit() async {
    dataArg_Student = Get.arguments["student"];
    dataArglastDailyReport = Get.arguments["lastDailyReport"];
    dataLastReview = Get.arguments["dataLastReview"];
    print("dataArglastDailyReport====${dataArglastDailyReport}");
    print("dataLastReview====${dataLastReview}");
    // تعبئة البيانات الحالية للتسميع
    if (dataArglastDailyReport.value != null) {
      dailyMarkController.text = dataArglastDailyReport.value!["mark"].toString();
      daily_selectedEvaluations.value = dataArglastDailyReport.value!["id_evaluation"];
      daily_from_id_aya.value = dataArglastDailyReport.value!["from_id_aya"];
      daily_to_id_aya.value = dataArglastDailyReport.value!["to_id_aya"];
    }

    // تعبئة البيانات الحالية للمراجعة
    if (dataLastReview.value != null) {
      reviewMarkController.text = dataLastReview.value!["mark"].toString();
      review_selectedEvaluations.value = dataLastReview.value!["id_evaluation"];
      review_from_id_aya.value = dataLastReview.value!["from_id_aya"];
      review_to_id_aya.value = dataLastReview.value!["to_id_aya"];
    }

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
          "id_soura": 1, // نبدأ من أول سورة للمراجعة
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
      
      // تعيين السور الحالية بعد تحميل البيانات
      if (dataArglastDailyReport.value != null) {
        daily_fromSoura.value = surahs.firstWhereOrNull(
          (s) => s["id_soura"] == dataArglastDailyReport.value!["from_id_soura"],
        );
        print("dataArglastDailyReport====${dataArglastDailyReport}");
        daily_toSoura.value = surahs.firstWhereOrNull(
          (s) => s["id_soura"] == dataArglastDailyReport.value!["to_id_soura"],
        );
      }
      
      if (dataLastReview.value != null) {
        review_fromSoura.value = surahs.firstWhereOrNull(
          (s) => s["id_soura"] == dataLastReview.value!["from_id_soura"],
        );
        review_toSoura.value = surahs.firstWhereOrNull(
          (s) => s["id_soura"] == dataLastReview.value!["to_id_soura"],
        );
      }
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
      idSoura: 1,
    );

    if (res["stat"] == "ok") {
      final surahs = List<Map<String, dynamic>>.from(res["data"]);
      datasoura.assignAll(surahs);
      
      // تعيين السور الحالية
      if (dataArglastDailyReport.value != null) {
        daily_fromSoura.value = surahs.firstWhereOrNull(
          (s) => s["id_soura"] == dataArglastDailyReport.value!["from_id_soura"],
        );
        daily_toSoura.value = surahs.firstWhereOrNull(
          (s) => s["id_soura"] == dataArglastDailyReport.value!["to_id_soura"],
        );
      }
      
      if (dataLastReview.value != null) {
        review_fromSoura.value = surahs.firstWhereOrNull(
          (s) => s["id_soura"] == dataLastReview.value!["from_id_soura"],
        );
        review_toSoura.value = surahs.firstWhereOrNull(
          (s) => s["id_soura"] == dataLastReview.value!["to_id_soura"],
        );
      }
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

  // تحديث التسميع والمراجعة معاً
  Future updateBoth() async {
    // التحقق من إدخال بيانات التسميع
    if (daily_fromSoura.value == null) {
      mySnackbar("تنبيه", "يجب تحديد سورة البداية للتسميع");
      return;
    }
    if (daily_from_id_aya.value == null) {
      mySnackbar("تنبيه", "يجب تحديد آية البداية للتسميع");
      return;
    }
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

    // تحديث التسميع أولاً
    await updateDailyReport();
    
    // ثم تحديث المراجعة
    await updateReview();
  }

  // تحديث التسميع اليومي
  Future updateDailyReport() async {
    Map<String, Object?> data = {
      "id_daily_report": dataArglastDailyReport.value!["id_daily_report"],
      "id_student": dataArg_Student["id_student"],
      "from_id_soura": daily_fromSoura.value!["id_soura"],
      "from_id_aya": daily_from_id_aya.value,
      "to_id_soura": daily_toSoura.value!["id_soura"],
      "to_id_aya": daily_to_id_aya.value,
      "id_user": dataArg_Student["id_user"],
      "id_circle": dataArg_Student["id_circle"],
      "mark": dailyMarkController.text,
      "id_evaluation": daily_selectedEvaluations.value,
      "date": formattedDate
    };
    // print("updateDailyReport======${data}");
    if (connectivityHelper.hasConnection) {
      await updateDailyReportOnline(data);
    } else {
      await updateDailyReportOffline(data);
    }
  }

  Future updateDailyReportOffline(data) async {
    data["stat"] = 0;
    int res = await db.update(
      "daily_report",
      data,
      where: "id_daily_report = ?",
      whereArgs: [data["id_daily_report"]],
    );
    if (res > 0) {
      mySnackbar("نجاح", "تم تحديث التسميع محلياً... يرجى الاتصال بالإنترنت لمزامنة البيانات", type: "g");
    } else {
      mySnackbar("فشل", "حصل خطأ في تحديث البيانات");
    }
  }

  Future updateDailyReportOnline(data) async {
    final res = await handleRequest(
      isLoading: RxBool(false),
      loadingMessage: "جاري تحديث التسميع...",
      defaultErrorTitle: "لم يتم تحديث التسميع",
      action: () async {
        return await postData(Linkapi.updateDailyReport, data);
      },
    );

    if (res == null) return;

    if (res is! Map) {
      mySnackbar("تحذير", "فشل الاتصال بالخادم");
      return;
    }

    if (res["stat"] == "ok") {
      await _updateDailyReportLocally(data);
    } else {
      String errorMsg = res["msg"] ?? "حصل خطأ غير محدد";
      mySnackbar("تحذير", errorMsg);
    }
  }
  Future _updateDailyReportLocally(Map<String, dynamic> data) async {
    try {
      final idDailyReport = data["id_daily_report"];

      if (idDailyReport == null) return;

      await db.update(
        'daily_report',
        {
          'to_id_soura': data['to_id_soura'],
          'to_id_aya': data['to_id_aya'],
          'mark': data['mark'],
          'id_evaluation': data['id_evaluation'],
          'stat': 1, // 1 = متزامن
        },
        where: 'id_daily_report = ?',
        whereArgs: [idDailyReport],
      );

      print('✅ تم تحديث التقرير محلياً');
    } catch (e) {
      print('❌ خطأ في حفظ التعديلات محلياً: $e');
    }
  }

  // تحديث المراجعة اليومية
  Future updateReview() async {
    Map<String, Object?> data = {
      "id_review": dataLastReview.value!["id_review"],
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

    // print("updateReview====${updateReview}");
    if (connectivityHelper.hasConnection) {
      await updateReviewOnline(data);
    } else {
      await updateReviewOffline(data);
    }

  }

  Future updateReviewOffline(data) async {
    data["stat"] = 0;
    int res = await db.update(
      "review",
      data,
      where: "id_review = ?",
      whereArgs: [data["id_review"]],
    );
    if (res > 0) {
      mySnackbar("نجاح", "تم تحديث المراجعة محلياً... يرجى الاتصال بالإنترنت لمزامنة البيانات", type: "g");
    } else {
      mySnackbar("فشل", "حصل خطأ في تحديث البيانات");
    }
  }

  Future updateReviewOnline(data) async {
    final idReview = data["id_review"];

    final res = await handleRequest(
      isLoading: RxBool(false),
      loadingMessage: "جاري تحديث المراجعة...",
      defaultErrorTitle: "لم يتم تحديث المراجعة",
      action: () async {
        return await postData(Linkapi.updateReview, data);
      },
    );

    if (res == null) return;

    if (res is! Map) {
      mySnackbar("تحذير", "فشل الاتصال بالخادم");
      return;
    }

    if (res["stat"] == "ok") {
      await db.update(
        'review',
        {
          'from_id_soura': data['from_id_soura'],
          'from_id_aya': data['from_id_aya'],
          'to_id_soura': data['to_id_soura'],
          'to_id_aya': data['to_id_aya'],
          'mark': data['mark'],
          'id_evaluation': data['id_evaluation'],
          'stat': 1,
        },
        where: 'id_review = ?',
        whereArgs: [idReview],
      );

      Get.back();
      mySnackbar("نجاح", "تم تحديث التسميع والمراجعة بنجاح", type: "g");
    } else {
      String errorMsg = res["msg"] ?? "حصل خطأ غير محدد";
      mySnackbar("تحذير", errorMsg);
    }
  }
}
