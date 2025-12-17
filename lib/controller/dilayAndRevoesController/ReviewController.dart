
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';

import '../../api/LinkApi.dart';
import '../../api/apiFunction.dart';
import '../../constants/function.dart';
import '../../globals.dart';

class ReviewController extends GetxController{

  var to_id_aya = Rx<int?>(null);
  var from_id_aya = Rx<int?>(null);
  var toSoura = Rxn<Map<String, dynamic>>();
  var fromSoura = Rxn<Map<String, dynamic>>();

  TextEditingController markController=TextEditingController();






  var student;
  var dataLastReview = Rxn<Map<String, dynamic>>();

  @override
  void onInit() {
    student=Get.arguments["student"];
    dataLastReview=Get.arguments["dataLastReview"];
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // استدعاء منفصل للطلبين - يعملان بشكل متوازي
      select_evaluations();
      select_fromId_soura_with_to_soura();
    },);
    super.onInit();
  }






  RxList<Map<String, dynamic>> dataEvaluations = <Map<String, dynamic>>[].obs;
  RxnInt selectedEvaluations = RxnInt(null);

  Future select_evaluations() async {
    if (connectivityHelper.hasConnection) {
      await select_evaluationsOnline();
    } else {
      await select_evaluationsOffline();
    }
  }

  Future select_evaluationsOffline() async {
    List d = await db.rawQuery("select * from evaluations");
    if (d.isNotEmpty) {
      dataEvaluations.assignAll(List.from(d));
    }
  }

  Future select_evaluationsOnline() async {
    final res = await handleRequest<dynamic>(
      isLoading: RxBool(false),
      useDialog: false,
      // loadingMessage: "جاري تحميل التقييمات...",
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
      dataEvaluations.assignAll(List<Map<String,dynamic>>.from(res["data"]));
    } else {
      String errorMsg = res["msg"] ?? "خطأ في جلب التقييمات";
      mySnackbar("خطأ", errorMsg);
    }
  }

  var datasoura = <Map<String, dynamic>>[].obs;
  var datasouraFrom = <Map<String, dynamic>>[].obs;

  Future select_fromId_soura_with_to_soura() async {
    if (connectivityHelper.hasConnection) {
      await select_fromId_soura_with_to_souraOnline();
    } else {
      await select_fromId_soura_with_to_souraOffline();
    }
  }

  Future select_fromId_soura_with_to_souraOffline() async {
    final res = await selectFromIdSouraWithToSoura(
      db: db,
      idLevel: student["id_level"],
      idSoura: dataLastReview.value!["to_id_soura"],
    );

    if (res["stat"] == "ok") {
      final surahs = List<Map<String, dynamic>>.from(res["data"]);
      datasoura.assignAll(surahs);
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
    """, [1, idLevel]);

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

  Future select_fromId_soura_with_to_souraOnline() async {
    final response = await handleRequest<dynamic>(
      isLoading: RxBool(false),
      loadingMessage: "جاري تحميل سور القرآن...",
      action: () async {
        return await postData(Linkapi.select_fromId_soura_with_to_soura, {
          "id_level": student["id_level"],
          "id_soura": dataLastReview.value!["to_id_soura"],
        });
      },
    );

    if (response == null) return;
    if (response is! Map) {
      mySnackbar("خطأ", "فشل الاتصال بالخادم");
      return;
    }

    if (response["stat"] == "ok") {
      datasoura.assignAll(List<Map<String, dynamic>>.from(response["data2"]));
      // datasouraFrom.assignAll(List<Map<String, dynamic>>.from(response["data2"]));

    } else if (response["stat"] == "no") {
      String errorMsg = response["msg"] ?? "لا يوجد سور";
      mySnackbar("تنبيه", errorMsg);
    } else {
      String errorMsg = response["msg"] ?? "خطأ في جلب السور";
      mySnackbar("خطأ", errorMsg);
    }
  }



  String formattedDate = "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}";

  Future addReview() async {
    // فحص المدخلات
    if (fromSoura.value.isNull) {
      mySnackbar("تنبية", "يجب تحديد سورة البداية ");
      return;
    }
    if (from_id_aya.value.isNull) {
      mySnackbar("تنبية", "يجب تحديد رقم الاية سورة البداية ");
      return;
    }
    if (toSoura.value.isNull) {
      mySnackbar("تنبية", "يجب تحديد سورة النهاية ");
      return;
    }
    if (to_id_aya.value.isNull) {
      mySnackbar("تنبية", "يجب تحديد رقم الاية سورة النهائية ");
      return;
    }
    if (fromSoura.value?["id_soura"] > toSoura.value!["id_soura"]) {
      mySnackbar("قم بتحديد نظاق السور بشكل صحيح ", "يجب ان يكون رقم سورة النهاية اكبر من رقم سورة البداية(ترتيب السور) ");
      return;
    }
    if (fromSoura.value?["id_soura"] == toSoura.value!["id_soura"] && ((from_id_aya.value ?? 0) >= (to_id_aya.value ?? 0))) {
      mySnackbar("قم بتحديد نظاق الايات بشكل صحيح ", "يجب ان يكون رقم ايه النهاية اكبر من البداية(ترتيب الايات ) ");
      return;
    }
    if (markController.text.isEmpty) {
      mySnackbar("تنبية", "قم بادخال الدرجة");
      return;
    }
    if ((int.tryParse(markController.text) ?? -1) < 0) {
      mySnackbar("تنبية", "قم بادخال التقييم بشكل صحيح بين 0 و 100 ");
      return;
    }
    if (selectedEvaluations.value.isNull) {
      mySnackbar("تنبية", "قم بادخال التقييم");
      return;
    }

    // إعداد البيانات
    Map<String, Object?> data = {
      "id_student": student["id_student"],
      "from_id_soura": fromSoura.value!["id_soura"],
      "from_id_aya": from_id_aya.value,
      "to_id_soura": toSoura.value!["id_soura"],
      "to_id_aya": to_id_aya.value,
      "id_user": student["id_user"],
      "id_circle": student["id_circle"],
      "mark": markController.text,
      "id_evaluation": selectedEvaluations.value,
      "date": formattedDate,
    };

    if (connectivityHelper.hasConnection) {
      await addReviewOnline(data);
    } else {
      await addReviewOffline(data);
    }
  }

  Future addReviewOffline(data) async {
    data["stat"] = 0; // معلق

    print("data (Review Offline) = $data");
    int res = await db.insert("review", data);
    if (res > 0) {
      Get.back();
      mySnackbar("نجاح", "تم الاضافة بنجاح محليا ... يرجى الاتصال بالانترنت في اقرب وقت لمزامنة البيانات ", type: "g");
    } else {
      mySnackbar("فشل", "حصل خطا في حفظ البيانات حاول مجددا او قم بالاتصال بالانترنت ");
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
        // الحصول على id_review من السيرفر
        final serverId = res["data"];
        
        if (serverId != null) {
          int? idReview;
          if (serverId is int) {
            idReview = serverId;
          } else if (serverId is String) {
            idReview = int.tryParse(serverId);
          }

          if (idReview != null && idReview > 0) {
            // تحديث البيانات للحفظ المحلي
            data["id_review"] = idReview;
            data["stat"] = 1; // متزامن

            // حفظ في قاعدة البيانات المحلية
            int result = await db.insert("review", data);
            
            if (result > 0) {
              print('✅ تم حفظ المراجعة محلياً بنجاح - id_local: $result, id_review: $idReview');
            } else {
              print('⚠️ فشل الحفظ المحلي - النتيجة: $result');
            }
          } else {
            print('⚠️ ID غير صالح من السيرفر: $serverId');
          }
        } else {
          print('⚠️ لم يتم إرجاع ID من السيرفر');
        }

        Get.back();
        mySnackbar("نجاح", "تم الاضافة بنجاح", type: "g");
      } catch (e, stackTrace) {
        print('❌ خطأ في حفظ المراجعة محلياً: $e');
        print('📍 Stack trace: $stackTrace');
        Get.back();
        mySnackbar("نجاح", "تم الإضافة للخادم بنجاح (لم يتم الحفظ محلياً)", type: "g");
      }
    } else {
      String errorMsg = res["msg"] ?? "حصل خطأ غير محدد";
      mySnackbar("تحذير", errorMsg);
    }
  }

}