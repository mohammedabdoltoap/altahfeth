import 'package:althfeth/constants/function.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';

import '../../api/LinkApi.dart';
import '../../api/apiFunction.dart';
import '../../globals.dart';


class Daily_ReportController extends GetxController{
  var dataArg_Student;
  var dataArglastDailyReport = Rxn<Map<String, dynamic>>();
  TextEditingController markController=TextEditingController();
  String formattedDate = "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}";


  @override
  void onInit()async {
    dataArg_Student=Get.arguments["student"];
    dataArglastDailyReport=Get.arguments["lastDailyReport"];
    

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // استدعاء منفصل للطلبين - يعملان بشكل متوازي
      select_fromId_soura_with_to_soura();
      select_evaluations();
    },);
  }



  var to_id_aya = Rx<int?>(null);
  var toSoura = Rxn<Map<String, dynamic>>();
  var datasoura = <Map<String, dynamic>>[].obs;
  Future select_fromId_soura_with_to_soura() async {
    // 📱 الجلب من المحلي مباشرة (البيانات محفوظة عند التثبيت)
    await select_fromId_soura_with_to_souraOfline();
  }
  Future select_fromId_soura_with_to_souraOnline()async{
    // 📡 مع الاتصال: جلب من الخادم

    var res=await handleRequest(
      loadingMessage: "جاري تحميل سور القرآن...",
      isLoading: RxBool(false),
      action: ()async {
        return  await postData(Linkapi.select_fromId_soura_with_to_soura, {
          "id_level":dataArg_Student["id_level"],
          "id_soura":dataArglastDailyReport.value!["to_id_soura"],
        });
      },);
    if(res==null) return;

    if (res is! Map) {
      mySnackbar("خطأ", "فشل الاتصال بالخادم");
      return;
    }

    if (res["stat"] == "ok") {
      final surahs = List<Map<String, dynamic>>.from(res["data"]);
      datasoura.assignAll(surahs);

    } else if(res["stat"]=="no") {
      String errorMsg = res["msg"] ?? "لايوجد سور";
      mySnackbar("لايوجد", errorMsg);
    } else {
      String errorMsg = res["msg"] ?? "خطأ في جلب السور";
      mySnackbar("خطأ", errorMsg);
    }


  }

  Future select_fromId_soura_with_to_souraOfline() async {
    try {
      final res = await selectFromIdSouraWithToSoura(
        db: db,
        idLevel: dataArg_Student["id_level"],
        idSoura: dataArglastDailyReport.value!["to_id_soura"],
      );

      if (res["stat"] == "ok") {
        final surahs = List<Map<String, dynamic>>.from(res["data"]);
        datasoura.assignAll(surahs);
        print('✅ تم جلب ${surahs.length} سورة من المحلي');
      } else if (res["stat"] == "no") {
        String errorMsg = res["msg"] ?? "لايوجد سور";
        mySnackbar("لايوجد", errorMsg);
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
      // استعلام محسّن: جلب السور من idSoura إلى نهاية المستوى
      List<Map<String, dynamic>> result = await db.rawQuery("""
        SELECT sq.*
        FROM sour_quran sq
        WHERE sq.id_soura >= ? 
          AND sq.id_soura <= (
            SELECT l.to_id_soura 
            FROM level l 
            WHERE l.id_level = ?
          )
        ORDER BY sq.id_soura
      """, [idSoura, idLevel]);

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

  Future select_evaluations() async {
    // 📱 الجلب من المحلي مباشرة (البيانات محفوظة عند التثبيت)
    await select_evaluationsOfline();
  }
  Future select_evaluationsOfline() async {
    try {
      List<Map<String, dynamic>> d = await db.rawQuery("SELECT * FROM evaluations");
      
      if (d.isNotEmpty) {
        dataEvaluations.assignAll(d);
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
  Future select_evaluationsOnline()async{

    // 📡 مع الاتصال: جلب من الخادم
    final res = await handleRequest<dynamic>(
      isLoading: RxBool(false),
      // loadingMessage: "جاري تحميل التقييمات...",
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

  RxBool isaddDailyRepor=false.obs;


  //add
 Future addDailyRepor()async{

   // فحص المدخلات قبل البدء
   if(toSoura.value.isNull){
      mySnackbar("قم بتحيد نطاق النهاية", "حدد سورة النهاية");
      return;
    }
    if(to_id_aya.value.isNull){
      mySnackbar("قم بتحيد رثم ايه النهائية", "حدد رقم الاية ");
      return;
    }

   if(dataArglastDailyReport.value?["to_id_soura"]==toSoura.value!["id_soura"] && dataArglastDailyReport.value?["to_id_aya"]>=to_id_aya.value){
     mySnackbar("قم بتحديد نطاق الايات بشكل صحيح ", "يجب ان يكون رقم ايه النهائة اكبر من البداية(ترتيب الايات ) ");
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

   // إعداد البيانات
   Map<String, Object?> data = {
     "id_student": dataArg_Student["id_student"],
     "from_id_soura": dataArglastDailyReport.value?["to_id_soura"],
     "from_id_aya": dataArglastDailyReport.value?["to_id_aya"],
     "to_id_soura": toSoura.value!["id_soura"],
     "to_id_aya": to_id_aya.value,
     "id_user": dataArg_Student["id_user"],
     "id_circle": dataArg_Student["id_circle"],
     "mark":markController.text,
     "id_evaluation":selectedEvaluations.value,
     "date":formattedDate
   };

   if (connectivityHelper.hasConnection) {
     await addDailyReporOnline(data);
   }
   else{
     await addDailyReporOfline(data);
   }


 }
  Future addDailyReporOfline(data)async {

   data["stat"]=0;

   // print("data=======${data}");
   int res=await db.insert("daily_report", data);
   if(res>0){
     Get.back();
     mySnackbar("نجاح", "تم الاضافة بنجاح محليا ... يرجى الاتصال بالانترنت في اقرب وقت لمزامنة البيانات ", type: "g");
   }else{
     mySnackbar("فشل", "حصل خطا في حفظ البيانات حاول مجددا او قم بالاتصال بالانترنت ");
   }

  }
 Future addDailyReporOnline(data)async{

   // 📡 مع الاتصال: إرسال للخادم
   final res = await handleRequest(
     isLoading: RxBool(false),
     loadingMessage: "جاري حفظ التسميع...",
     defaultErrorTitle: "لم يتم حفظ التسميع",

     action: () async {
       return await postData(Linkapi.addDailyReport, data);
     },
   );

   if (res == null) return;

   // التحقق من نوع الاستجابة
   if (res is! Map) {
     mySnackbar("تحذير", "فشل الاتصال بالخادم");
     return;
   }

   if (res["stat"] == "ok") {
     try {
       // الحصول على id_daily_report من السيرفر
       final serverId = res["data"];
       
       if (serverId != null) {
         // تحويل إلى int
         int? idDailyReport;
         if (serverId is int) {
           idDailyReport = serverId;
         } else if (serverId is String) {
           idDailyReport = int.tryParse(serverId);
         }

         if (idDailyReport != null && idDailyReport > 0) {
           // تحديث البيانات للحفظ المحلي
           data["id_daily_report"] = idDailyReport;

           data["stat"] = 1; // 1 = متزامن

           // حفظ في قاعدة البيانات المحلية
           int result = await db.insert("daily_report", data);
           
           if (result > 0) {
             print('✅ تم حفظ التقرير محلياً بنجاح - id_local: $result, id_daily_report: $idDailyReport');
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
       print('❌ خطأ في حفظ التقرير محلياً: $e');
       print('📍 Stack trace: $stackTrace');
       Get.back();
       mySnackbar("نجاح", "تم الإضافة للخادم بنجاح (لم يتم الحفظ محلياً)", type: "g");
     }
   } else {
     // قراءة رسالة الخطأ التفصيلية من الـAPI
     String errorMsg = res["msg"] ?? "حصل خطأ غير محدد";
     mySnackbar("تحذير", errorMsg);
   }
 }


   RxList<Map<String,dynamic>> dataEvaluations=<Map<String,dynamic>>[].obs;
  RxnInt selectedEvaluations=RxnInt(null);


}









