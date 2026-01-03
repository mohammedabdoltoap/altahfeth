// import 'package:flutter/cupertino.dart';
// import 'package:get/get.dart';
//
// import '../../api/LinkApi.dart';
// import '../../api/apiFunction.dart';
// import '../../constants/function.dart';
//
// class Update_ReviewController extends GetxController{
//
//   @override
//   void onInit() {
//     dataArg_Student=Get.arguments["student"];
//     dataLastReview=Get.arguments["dataLastReview"];
//
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       // استدعاء منفصل للطلبين - يعملان بشكل متوازي
//       select_fromId_soura_with_to_soura();
//       select_evaluations();
//       markController.text=dataLastReview.value?["mark"].toString() ?? "0";
//     },);
//   }
//   var dataArg_Student;
//   var dataLastReview = Rxn<Map<String, dynamic>>();
//   TextEditingController markController=TextEditingController();
//
//   RxList<Map<String, dynamic>> dataEvaluations = <Map<String, dynamic>>[].obs;
//   RxnInt selectedEvaluations = RxnInt(null);
//
//   Future select_evaluations() async {
//     final res = await handleRequest<dynamic>(
//       isLoading: RxBool(false),
//       useDialog: false,
//       // loadingMessage: "جاري تحميل التقييمات...",
//       action: () async {
//         return await postData(Linkapi.select_evaluations, {});
//       },
//     );
//
//     if (res == null) return;
//     if (res is! Map) {
//       mySnackbar("خطأ", "فشل الاتصال بالخادم");
//       return;
//     }
//
//     if (res["stat"] == "ok") {
//       dataEvaluations.assignAll(List<Map<String, dynamic>>.from(res["data"]));
//       selectedEvaluations.value = (dataEvaluations.firstWhere(
//         (e) => e["id_evaluation"] == dataLastReview.value?["id_evaluation"],
//         orElse: () => {},
//       )["id_evaluation"]);
//     } else {
//       String errorMsg = res["msg"] ?? "خطأ في جلب التقييمات";
//       mySnackbar("خطأ", errorMsg);
//     }
//   }
//
//
//   var to_id_aya = Rx<int?>(null);
//   var toSoura = Rxn<Map<String, dynamic>>();
//
//   var datasoura = <Map<String, dynamic>>[].obs;
//
//   Future select_fromId_soura_with_to_soura() async {
//     final response = await handleRequest<dynamic>(
//       isLoading: RxBool(false),
//       loadingMessage: "جاري تحميل سور القرآن...",
//       action: () async {
//         return await postData(Linkapi.select_fromId_soura_with_to_soura, {
//           "id_level": dataArg_Student["id_level"],
//           "id_soura": dataLastReview.value!["from_id_soura"],
//         });
//       },
//     );
//
//     if (response == null) return;
//     if (response is! Map) {
//       mySnackbar("خطأ", "فشل الاتصال بالخادم");
//       return;
//     }
//
//     if (response["stat"] == "ok") {
//       datasoura.assignAll(List<Map<String, dynamic>>.from(response["data"]));
//       toSoura.value = datasoura.firstWhere(
//         (soura) => soura["id_soura"].toString() == dataLastReview.value?["to_id_soura"].toString(),
//         orElse: () => {},
//       );
//       to_id_aya.value = int.tryParse(dataLastReview.value?["to_id_aya"].toString() ?? "");
//     } else if (response["stat"] == "no") {
//       String errorMsg = response["msg"] ?? "لا يوجد سور";
//       mySnackbar("تنبيه", errorMsg);
//     } else {
//       String errorMsg = response["msg"] ?? "خطأ في جلب السور";
//       mySnackbar("خطأ", errorMsg);
//     }
//   }
//
//
//
//   Future updateReview() async {
//     if (toSoura.value.isNull) {
//       mySnackbar("تنبيه", "يجب تحديد نطاق النهاية");
//       return;
//     }
//     if (to_id_aya.value.isNull) {
//       mySnackbar("تنبيه", "يجب تحديد الآية النهائية");
//       return;
//     }
//     if(markController.text.isEmpty){
//       mySnackbar("تنبية", "قم بادخال الدرجة");
//       return;
//     }
//     if(selectedEvaluations.value.isNull) {
//       mySnackbar("تنبية", "قم بادخال التقييم");
//       return;
//     }
//
//     Map data = {
//       "id_review": dataLastReview.value?["id_review"],
//       "to_id_soura": toSoura.value!["id_soura"],
//       "to_id_aya": to_id_aya.value,
//       "mark": markController.text,
//       "id_evaluation": selectedEvaluations.value,
//     };
//
//     final res = await handleRequest<dynamic>(
//       isLoading: RxBool(false),
//       loadingMessage: "جاري حفظ التعديلات...",
//       defaultErrorTitle: "لم يتم حفظ التعديلات",
//       action: () async {
//         await del();
//         return await postData(Linkapi.updateReview, data);
//       },
//     );
//
//     if (res == null) return;
//     if (res is! Map) {
//       mySnackbar("خطأ", "فشل الاتصال بالخادم");
//       return;
//     }
//
//     if (res["stat"] == "ok") {
//       // 🔹 لو كانت نفس القيم القديمة
//       if (res["msg"] == "no_changes") {
//         Get.back();
//         mySnackbar("تنبيه", "لم يحدث أي تغيير، البيانات كما هي", type: "y");
//       } else {
//         // 🔹 تم التعديل فعليًا
//         Get.back();
//         mySnackbar("نجاح", "تم التعديل بنجاح", type: "g");
//       }
//     } else {
//       String errorMsg = res["msg"] ?? "حصل خطأ أثناء التعديل";
//       mySnackbar("خطأ", errorMsg);
//     }
//   }
// }

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';

import '../../api/LinkApi.dart';
import '../../api/apiFunction.dart';
import '../../constants/function.dart';
import '../../globals.dart';

class Update_ReviewController extends GetxController{

  @override
  void onInit() {
    dataArg_Student=Get.arguments["student"];
    dataLastReview=Get.arguments["dataLastReview"];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // استدعاء منفصل للطلبين - يعملان بشكل متوازي
      select_fromId_soura_with_to_soura();
      select_evaluations();
      markController.text=dataLastReview.value?["mark"].toString() ?? "0";
    },);
  }
  var dataArg_Student;
  var dataLastReview = Rxn<Map<String, dynamic>>();
  TextEditingController markController=TextEditingController();

  RxList<Map<String, dynamic>> dataEvaluations = <Map<String, dynamic>>[].obs;
  RxnInt selectedEvaluations = RxnInt(null);

  Future select_evaluations() async {
    // 📱 الجلب من المحلي مباشرة (البيانات محفوظة عند التثبيت)
    await select_evaluationsOffline();
  }

  Future select_evaluationsOffline() async {
    try {
      List<Map<String, dynamic>> d = await db.rawQuery("SELECT * FROM evaluations");
      
      if (d.isNotEmpty) {
        dataEvaluations.assignAll(d);
        selectedEvaluations.value = (dataEvaluations.firstWhere(
          (e) => e["id_evaluation"] == dataLastReview.value?["id_evaluation"],
          orElse: () => {},
        )["id_evaluation"]);
        print('✅ تم جلب ${d.length} تقييم من المحلي');
      } else {
        print('⚠️ لا توجد تقييمات محلية');
        mySnackbar("تنبيه", "لا توجد تقييمات محفوظة", type: "y");
      }
    } catch (e) {
      print('❌ خطأ في جلب التقييمات محلياً: $e');
      mySnackbar("خطأ", "حدث خطأ أثناء جلب التقييمات");
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
      dataEvaluations.assignAll(List<Map<String, dynamic>>.from(res["data"]));
      selectedEvaluations.value = (dataEvaluations.firstWhere(
            (e) => e["id_evaluation"] == dataLastReview.value?["id_evaluation"],
        orElse: () => {},
      )["id_evaluation"]);
    } else {
      String errorMsg = res["msg"] ?? "خطأ في جلب التقييمات";
      mySnackbar("خطأ", errorMsg);
    }
  }


  var to_id_aya = Rx<int?>(null);
  var from_id_aya = Rx<int?>(null);
  var toSoura = Rxn<Map<String, dynamic>>();
  var fromSoura = Rxn<Map<String, dynamic>>();

  var datasoura = <Map<String, dynamic>>[].obs;

  Future select_fromId_soura_with_to_soura() async {
    // 📱 الجلب من المحلي مباشرة (البيانات محفوظة عند التثبيت)
    await select_fromId_soura_with_to_souraOffline();
  }

  Future select_fromId_soura_with_to_souraOffline() async {
    try {
      final res = await selectFromIdSouraWithToSoura(
        db: db,
        idLevel: dataArg_Student["id_level"],
        idSoura: dataLastReview.value!["from_id_soura"],
      );

      if (res["stat"] == "ok") {
        final surahs = List<Map<String, dynamic>>.from(res["data"]);
        datasoura.assignAll(surahs);

        fromSoura.value = datasoura.firstWhere(
          (soura) => soura["id_soura"].toString() == dataLastReview.value?["from_id_soura"].toString(),
          orElse: () => {},
        );
        from_id_aya.value = int.tryParse(dataLastReview.value?["from_id_aya"].toString() ?? "");

        toSoura.value = datasoura.firstWhere(
          (soura) => soura["id_soura"].toString() == dataLastReview.value?["to_id_soura"].toString(),
          orElse: () => {},
        );
        to_id_aya.value = int.tryParse(dataLastReview.value?["to_id_aya"].toString() ?? "");
        print('✅ تم جلب ${surahs.length} سورة من المحلي');
      } else if (res["stat"] == "no") {
        String errorMsg = res["msg"] ?? "لا يوجد سور";
        mySnackbar("تنبيه", errorMsg);
      } else {
        String errorMsg = res["msg"] ?? "خطأ في جلب السور";
        mySnackbar("خطأ", errorMsg);
      }
    } catch (e) {
      print('❌ خطأ في جلب السور محلياً: $e');
      mySnackbar("خطأ", "حدث خطأ أثناء جلب السور");
    }
  }

  Future<Map<String, dynamic>> selectFromIdSouraWithToSoura({
    required Database db,
    required int idLevel,
    required int idSoura,
  }) async {
    try {
      // استعلام محسّن: جلب جميع السور من البداية إلى نهاية المستوى
      List<Map<String, dynamic>> result = await db.rawQuery("""
        SELECT sq.*
        FROM sour_quran sq
        WHERE sq.id_soura >= 1
          AND sq.id_soura <= (
            SELECT l.to_id_soura 
            FROM level l 
            WHERE l.id_level = ?
          )
        ORDER BY sq.id_soura
      """, [idLevel]);

      if (result.isNotEmpty) {
        return {
          "stat": "ok",
          "data": result,
        };
      }

      return {
        "stat": "no",
        "msg": "لا توجد سور متاحة",
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
          "id_level": dataArg_Student["id_level"],
          "id_soura": dataLastReview.value!["from_id_soura"],
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

      fromSoura.value = datasoura.firstWhere(
            (soura) => soura["id_soura"].toString() == dataLastReview.value?["from_id_soura"].toString(),
        orElse: () => {},
      );
      from_id_aya.value = int.tryParse(dataLastReview.value?["from_id_aya"].toString() ?? "");

      toSoura.value = datasoura.firstWhere(
            (soura) => soura["id_soura"].toString() == dataLastReview.value?["to_id_soura"].toString(),
        orElse: () => {},
      );
      to_id_aya.value = int.tryParse(dataLastReview.value?["to_id_aya"].toString() ?? "");
    } else if (response["stat"] == "no") {
      String errorMsg = response["msg"] ?? "لا يوجد سور";
      mySnackbar("تنبيه", errorMsg);
    } else {
      String errorMsg = response["msg"] ?? "خطأ في جلب السور";
      mySnackbar("خطأ", errorMsg);
    }
  }



  Future updateReview() async {

    if(fromSoura.value.isNull){
      mySnackbar("تنبية", "يجب تحديد سورة البداية ");
      return;
    }
    if(from_id_aya.value.isNull){
      mySnackbar("تنبية", "يجب تحديد رقم  الاية سورة البداية ");
      return;
    }

    if(toSoura.value.isNull){
      mySnackbar("تنبية", "يجب تحديد سورة النهاية ");
      return;
    }
    if(to_id_aya.value.isNull){
      mySnackbar("تنبية", "يجب تحديد رقم  الاية سورة النهائية ");
      return;
    }
    if(fromSoura.value?["id_soura"] > toSoura.value!["id_soura"]){
      mySnackbar("قم بتحديد نظاق السور بشكل صحيح ", "يجب ان يكون رقم سورة النهاية اكبر من رقم سورة البداية(ترتيب السور) ");
      return;

    }
    if (fromSoura.value?["id_soura"] == toSoura.value!["id_soura"] && ((from_id_aya.value ?? 0) >= (to_id_aya.value ?? 0))) {
      mySnackbar("قم بتحديد نظاق الايات بشكل صحيح ", "يجب ان يكون رقم ايه النهاية اكبر من البداية(ترتيب الايات ) ");
      return;

    }
    if(markController.text.isEmpty){
      mySnackbar("تنبية", "قم بادخال الدرجة");
      return;
    }
    if((int.tryParse(markController.text) ?? -1) <0){
      mySnackbar("تنبية", "قم بادخال التقييم بشكل صحيح بين 0 و 100 ");
      return;
    }
    if(selectedEvaluations.value.isNull) {
      mySnackbar("تنبية", "قم بادخال التقييم");
      return;
    }

    Map<String, dynamic> data = {
      "id_review": dataLastReview.value?["id_review"],
      "id_local": dataLastReview.value?["id_local"],
      "from_id_soura": fromSoura.value!["id_soura"],
      "from_id_aya": from_id_aya.value,
      "to_id_soura": toSoura.value!["id_soura"],
      "to_id_aya": to_id_aya.value,
      "mark": markController.text,
      "id_evaluation": selectedEvaluations.value,
    };

    if (connectivityHelper.hasConnection) {
      await updateReviewOnline(data);
    } else {
      await updateReviewOffline(data);
    }
  }

  Future updateReviewOnline(Map<String, dynamic> data) async {
    final idReview = data["id_review"];
    final idLocal = data["id_local"];
    
    // إذا كانت المراجعة مضافة offline (بدون id_review)
    if (idReview == null && idLocal != null) {
      await _syncOfflineReviewToServer(data, idLocal);
      return;
    }
    
    // تعديل عادي لمراجعة متزامنة
    final res = await handleRequest<dynamic>(
      isLoading: RxBool(false),
      loadingMessage: "جاري حفظ التعديلات...",
      defaultErrorTitle: "لم يتم حفظ التعديلات",
      action: () async {
        return await postData(Linkapi.updateReview, data);
      },
    );

    if (res == null) return;

    if (res is! Map) {
      mySnackbar("خطأ", "فشل الاتصال بالخادم");
      return;
    }

    if (res["stat"] == "ok") {
      // تحديث محلياً
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
      if (res["msg"] == "no_changes") {
        mySnackbar("تنبيه", "لم يحدث أي تغيير، البيانات كما هي", type: "y");
      } else {
        mySnackbar("نجاح", "تم التعديل بنجاح", type: "g");
      }
    } else {
      String errorMsg = res["msg"] ?? "حصل خطأ أثناء التعديل";
      mySnackbar("خطأ", errorMsg);
    }
  }

  Future _syncOfflineReviewToServer(Map<String, dynamic> data, int idLocal) async {
    try {
      Map<String, dynamic> addData = {
        "id_student": dataArg_Student["id_student"],
        "from_id_soura": data['from_id_soura'],
        "from_id_aya": data['from_id_aya'],
        "to_id_soura": data['to_id_soura'],
        "to_id_aya": data['to_id_aya'],
        "id_user": dataArg_Student["id_user"],
        "id_circle": dataArg_Student["id_circle"],
        "mark": data['mark'],
        "id_evaluation": data['id_evaluation'],
        "date": dataLastReview.value?["date"],
      };

      final res = await handleRequest<dynamic>(
        isLoading: RxBool(false),
        loadingMessage: "جاري مزامنة المراجعة...",
        defaultErrorTitle: "فشلت المزامنة",
        action: () async {
          return await postData(Linkapi.addReview, addData);
        },
      );

      if (res != null && res["stat"] == "ok") {
        final serverId = res["data"];
        int? idReview;
        if (serverId is int) {
          idReview = serverId;
        } else if (serverId is String) {
          idReview = int.tryParse(serverId);
        }

        if (idReview != null && idReview > 0) {
          await db.update(
            'review',
            {
              'id_review': idReview,
              'from_id_soura': data['from_id_soura'],
              'from_id_aya': data['from_id_aya'],
              'to_id_soura': data['to_id_soura'],
              'to_id_aya': data['to_id_aya'],
              'mark': data['mark'],
              'id_evaluation': data['id_evaluation'],
              'stat': 1,
            },
            where: 'id_local = ?',
            whereArgs: [idLocal],
          );

          Get.back();
          mySnackbar("نجاح", "تم مزامنة المراجعة بنجاح", type: "g");
        }
      }
    } catch (e) {
      print('❌ خطأ في مزامنة المراجعة: $e');
      mySnackbar("خطأ", "حدث خطأ أثناء المزامنة");
    }
  }

  Future updateReviewOffline(Map<String, dynamic> data) async {
    try {
      final idReview = data["id_review"];
      final idLocal = data["id_local"];
      
      if (idReview == null && idLocal == null) {
        mySnackbar("خطأ", "معرف المراجعة غير موجود");
        return;
      }

      String whereClause;
      List<dynamic> whereArgs;
      
      if (idReview != null) {
        whereClause = 'id_review = ?';
        whereArgs = [idReview];
      } else {
        whereClause = 'id_local = ?';
        whereArgs = [idLocal];
      }

      int result = await db.update(
        'review',
        {
          'from_id_soura': data['from_id_soura'],
          'from_id_aya': data['from_id_aya'],
          'to_id_soura': data['to_id_soura'],
          'to_id_aya': data['to_id_aya'],
          'mark': data['mark'],
          'id_evaluation': data['id_evaluation'],
          'stat': idReview != null ? 2 : 0,
        },
        where: whereClause,
        whereArgs: whereArgs,
      );

      if (result > 0) {
        Get.back();
        mySnackbar("نجاح", "تم التعديل محلياً ... سيتم المزامنة عند الاتصال بالإنترنت", type: "g");
      } else {
        mySnackbar("خطأ", "فشل التعديل المحلي");
      }
    } catch (e) {
      print('❌ خطأ في تعديل المراجعة محلياً: $e');
      mySnackbar("خطأ", "حدث خطأ أثناء التعديل المحلي");
    }
  }
}