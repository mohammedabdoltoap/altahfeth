import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import '../../api/LinkApi.dart';
import '../../api/apiFunction.dart';
import '../../constants/function.dart';
import '../../globals.dart';

class Update_Daily_ReportController extends GetxController{
  @override
  void onInit() {
    dataArg_Student=Get.arguments["student"];
    dataArglastDailyReport=Get.arguments["lastDailyReport"];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // استدعاء منفصل للطلبين - يعملان بشكل متوازي
      select_evaluations();
      select_fromId_soura_with_to_soura();
      markController.text=dataArglastDailyReport.value?["mark"].toString() ?? "0";
    },);
  }
  var dataArg_Student;
  var dataArglastDailyReport = Rxn<Map<String, dynamic>>();

  TextEditingController markController=TextEditingController();



  var to_id_aya = Rx<int?>(null);
  var toSoura = Rxn<Map<String, dynamic>>();

  var datasoura = <Map<String, dynamic>>[].obs;
  // Future select_fromId_soura_with_to_soura() async {
  //   final response = await handleRequest<dynamic>(
  //     isLoading: RxBool(false),
  //     loadingMessage: "جاري تحميل سور القرآن...",
  //     action: () async {
  //       return await postData(Linkapi.select_fromId_soura_with_to_soura, {
  //         "id_level": dataArg_Student["id_level"],
  //         "id_soura": dataArglastDailyReport.value!["from_id_soura"],
  //       });
  //     },
  //   );
  //
  //   if (response == null) return;
  //   if (response is! Map) {
  //     mySnackbar("خطأ", "فشل الاتصال بالخادم");
  //     return;
  //   }
  //
  //   if (response["stat"] == "ok") {
  //     datasoura.assignAll(List<Map<String, dynamic>>.from(response["data"]));
  //     toSoura.value = datasoura.firstWhere(
  //           (soura) => soura["id_soura"].toString() == dataArglastDailyReport.value?["to_id_soura"].toString(),
  //       orElse: () => {},
  //     );
  //     to_id_aya.value = int.tryParse(dataArglastDailyReport.value?["to_id_aya"].toString() ?? "");
  //
  //   } else {
  //     String errorMsg = response["msg"] ?? "حصل خطأ في جلب البيانات";
  //     mySnackbar("خطأ", errorMsg);
  //   }
  // }
  Future select_fromId_soura_with_to_soura() async {
    // 🌐 فحص الاتصال بالإنترنت
    if (connectivityHelper.hasConnection)
      await select_fromId_soura_with_to_souraOnline();
    else
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
          "id_soura":dataArglastDailyReport.value?["from_id_soura"] ?? 1,
        });
      },);

    if(res==null) return;

    if (res is! Map) {
      mySnackbar("خطأ", "فشل الاتصال بالخادم");
      return;
    }

    if (res["stat"] == "ok") {
      // final surahs = List<Map<String, dynamic>>.from(res["data"]);
      // datasoura.assignAll(surahs);

      datasoura.assignAll(List<Map<String, dynamic>>.from(res["data"]));


      toSoura.value = datasoura.firstWhereOrNull(
            (soura) => soura["id_soura"].toString() == dataArglastDailyReport.value?["to_id_soura"].toString(),
      );

      to_id_aya.value = int.tryParse(dataArglastDailyReport.value?["to_id_aya"].toString() ?? "");

    } else if(res["stat"]=="no") {
      String errorMsg = res["msg"] ?? "لايوجد سور";
      mySnackbar("لايوجد", errorMsg);
    } else {
      String errorMsg = res["msg"] ?? "خطأ في جلب السور";
      mySnackbar("خطأ", errorMsg);
    }


  }

  Future select_fromId_soura_with_to_souraOfline()async{

    final res = await selectFromIdSouraWithToSoura(
      db: db,
      idLevel: dataArg_Student["id_level"],
      idSoura: dataArglastDailyReport.value?["from_id_soura"] ?? 1,

    );

    if (res["stat"] == "ok") {
      // final surahs = List<Map<String, dynamic>>.from(res["data"]);
      // datasoura.assignAll(surahs);
      datasoura.assignAll(List<Map<String, dynamic>>.from(res["data"]));
      toSoura.value = datasoura.firstWhereOrNull(
            (soura) => soura["id_soura"].toString() == dataArglastDailyReport.value?["to_id_soura"].toString(),
      );
      to_id_aya.value = int.tryParse(dataArglastDailyReport.value?["to_id_aya"].toString() ?? "");


    } else if(res["stat"]=="no") {
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
      // ================================
      // 1) تنفيذ الاستعلام (JOIN + BETWEEN)
      // ================================
      List<Map<String, dynamic>> result = await db.rawQuery("""
      SELECT sq.*
      FROM level l
      JOIN sour_quran sq 
        ON sq.id_soura BETWEEN ? AND l.to_id_soura
      WHERE l.id_level = ?
    """, [idSoura, idLevel]);

      // ================================
      // 2) إذا فيه بيانات
      // ================================
      if (result.isNotEmpty) {
        return {
          "stat": "ok",
          "data": result,
        };
      }

      // ================================
      // 3) إذا لا يوجد بيانات
      // ================================
      return {
        "stat": "no",
      };

    } catch (e) {
      // ================================
      // 4) في حالة حدوث خطأ
      // ================================
      return {
        "stat": "error",
        "msg": "حدث خطأ أثناء تنفيذ الاستعلام: $e",
      };
    }
  }



  Future updateDailyReport() async {
    // التحقق من المدخلات
    if (toSoura.value.isNull) {
      mySnackbar("تنبيه", "يجب تحديد نطاق النهاية");
      return;
    }
    if (to_id_aya.value.isNull) {
      mySnackbar("تنبيه", "يجب تحديد الآية النهائية");
      return;
    }
    
    // التحقق من صحة النطاق (البداية والنهاية)
    // إذا كانت سورة النهاية نفس سورة البداية، يجب أن تكون آية النهاية أكبر من آية البداية
    if(dataArglastDailyReport.value?["from_id_soura"] == toSoura.value!["id_soura"] && 
       dataArglastDailyReport.value?["from_id_aya"] >= to_id_aya.value){
      mySnackbar("قم بتحديد نطاق الايات بشكل صحيح", "يجب ان يكون رقم آية النهاية أكبر من آية البداية (ترتيب الايات)");
      return;
    }
    
    if(markController.text.isEmpty){
      mySnackbar("تنبية", "قم بادخال الدرجة");
      return;
    }
    if(selectedEvaluations.value.isNull) {
      mySnackbar("تنبية", "قم بادخال التقييم");
      return;
    }

    // إعداد البيانات
    Map<String, dynamic> data = {
      "id_daily_report": dataArglastDailyReport.value?["id_daily_report"],
      "id_local": dataArglastDailyReport.value?["id_local"], // للتقارير المضافة offline
      "to_id_soura": toSoura.value!["id_soura"],
      "to_id_aya": to_id_aya.value,
      "mark":markController.text,
      "id_evaluation":selectedEvaluations.value,
    };


    if (connectivityHelper.hasConnection) {
      await updateDailyReportOnline(data);
    } else {
      await updateDailyReportOffline(data);
    }

  }

  /// 📡 تعديل التسميع مع الإنترنت
  Future updateDailyReportOnline(Map<String, dynamic> data) async {
    final idDailyReport = data["id_daily_report"];
    final idLocal = data["id_local"];
    
    // إذا كان التقرير مضاف offline (بدون id_daily_report)
    if (idDailyReport == null && idLocal != null) {
      await _syncOfflineReportToServer(data, idLocal);
      return;
    }
    
    // تعديل عادي لتقرير متزامن
    final res = await handleRequest<dynamic>(
      isLoading: RxBool(false),
      loadingMessage: "جاري حفظ التعديلات...",
      defaultErrorTitle: "لم يتم حفظ التعديلات",
      action: () async {
        await del();
        return await postData(Linkapi.updateDailyReport, data);
      },
    );

    if (res == null) return;
    if (res is! Map) {
      mySnackbar("خطأ", "فشل الاتصال بالخادم");
      return;
    }

    if (res["stat"] == "ok") {
      // حفظ التعديلات محلياً
      await _updateDailyReportLocally(data);

      // 🔹 لو كانت نفس القيم القديمة
      if (res["msg"] == "no_changes") {
        Get.back();
        mySnackbar("تنبيه", "لم يحدث أي تغيير، البيانات كما هي", type: "y");
      } else {
        // 🔹 تم التعديل فعليًا
        Get.back();
        mySnackbar("نجاح", "تم التعديل بنجاح", type: "g");
      }
    } else {
      String errorMsg = res["msg"] ?? "حصل خطأ أثناء التعديل";
      mySnackbar("خطأ", errorMsg);
    }
  }

  /// 🔄 مزامنة تقرير offline مع السيرفر (إضافة جديدة)
  Future _syncOfflineReportToServer(Map<String, dynamic> data, int idLocal) async {
    try {
      // تحضير بيانات الإضافة (بدون id_daily_report و id_local)
      Map<String, dynamic> addData = {
        "id_student": dataArg_Student["id_student"],
        "from_id_soura": dataArglastDailyReport.value?["from_id_soura"],
        "from_id_aya": dataArglastDailyReport.value?["from_id_aya"],
        "to_id_soura": data['to_id_soura'],
        "to_id_aya": data['to_id_aya'],
        "id_user": dataArg_Student["id_user"],
        "id_circle": dataArg_Student["id_circle"],
        "mark": data['mark'],
        "id_evaluation": data['id_evaluation'],
        "date": dataArglastDailyReport.value?["date"],
      };

      final res = await handleRequest<dynamic>(
        isLoading: RxBool(false),
        loadingMessage: "جاري مزامنة التقرير...",
        defaultErrorTitle: "فشلت المزامنة",
        action: () async {
          await del();
          return await postData(Linkapi.addDailyReport, addData);
        },
      );

      if (res == null) return;
      if (res is! Map) {
        mySnackbar("خطأ", "فشل الاتصال بالخادم");
        return;
      }

      if (res["stat"] == "ok") {
        // الحصول على id_daily_report من السيرفر
        final serverId = res["id"];
        int? idDailyReport;
        
        if (serverId is int) {
          idDailyReport = serverId;
        } else if (serverId is String) {
          idDailyReport = int.tryParse(serverId);
        }

        if (idDailyReport != null && idDailyReport > 0) {
          // تحديث التقرير المحلي بـ id_daily_report الجديد
          await db.update(
            'daily_report',
            {
              'id_daily_report': idDailyReport,
              'to_id_soura': data['to_id_soura'],
              'to_id_aya': data['to_id_aya'],
              'mark': data['mark'],
              'id_evaluation': data['id_evaluation'],
              'stat': 1, // متزامن
            },
            where: 'id_local = ?',
            whereArgs: [idLocal],
          );

          Get.back();
          mySnackbar("نجاح", "تم المزامنة والتعديل بنجاح", type: "g");
        }
      } else {
        String errorMsg = res["msg"] ?? "فشلت المزامنة";
        mySnackbar("خطأ", errorMsg);
      }
    } catch (e) {
      print('❌ خطأ في مزامنة التقرير: $e');
      mySnackbar("خطأ", "حدث خطأ أثناء المزامنة");
    }
  }

  /// 💾 تعديل التسميع بدون إنترنت
  Future updateDailyReportOffline(Map<String, dynamic> data) async {
    try {
      final idDailyReport = data["id_daily_report"];
      final idLocal = data["id_local"];
      
      // التحقق من وجود معرف (إما id_daily_report أو id_local)
      if (idDailyReport == null && idLocal == null) {
        mySnackbar("خطأ", "معرف التقرير غير موجود");
        return;
      }

      // تحديد WHERE clause حسب نوع المعرف
      String whereClause;
      List<dynamic> whereArgs;
      
      if (idDailyReport != null) {
        // تقرير متزامن مع السيرفر
        whereClause = 'id_daily_report = ?';
        whereArgs = [idDailyReport];
      } else {
        // تقرير مضاف offline (يستخدم id_local)
        whereClause = 'id_local = ?';
        whereArgs = [idLocal];
      }

      // تحديث في قاعدة البيانات المحلية
      int result = await db.update(
        'daily_report',
        {
          'to_id_soura': data['to_id_soura'],
          'to_id_aya': data['to_id_aya'],
          'mark': data['mark'],
          'id_evaluation': data['id_evaluation'],
          'stat': idDailyReport != null ? 2 : 0, // 2 = تعديل معلق، 0 = إضافة معلقة
        },
        where: whereClause,
        whereArgs: whereArgs,
      );

      if (result > 0) {
        Get.back();
        mySnackbar(
          "نجاح",
          "تم التعديل محلياً\n⚠️ سيتم المزامنة عند الاتصال بالإنترنت",
          type: "g",
        );
      } else {
        mySnackbar("خطأ", "فشل التعديل المحلي");
      }
    } catch (e) {
      print('❌ خطأ في تعديل التقرير محلياً: $e');
      mySnackbar("خطأ", "حدث خطأ أثناء التعديل المحلي");
    }
  }

  /// 💾 حفظ التعديلات محلياً بعد النجاح Online
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

  RxList<Map<String, dynamic>> dataEvaluations = <Map<String, dynamic>>[].obs;
  RxnInt selectedEvaluations = RxnInt(null);

  Future select_evaluations() async {
    // 🌐 فحص الاتصال بالإنترنت
    if (connectivityHelper.hasConnection) {
      await select_evaluationsOnline();
    }else{
      await select_evaluationsOfline();
    }

    selectedEvaluations.value = (dataEvaluations.firstWhere(
          (e) => e["id_evaluation"] == dataArglastDailyReport.value?["id_evaluation"],
      orElse: () => {},
    )["id_evaluation"]);



  }
  Future select_evaluationsOfline()async{

    List d= await db.rawQuery("select * from evaluations");
    if(d.isNotEmpty)
      dataEvaluations.assignAll(List.from(d));

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

}