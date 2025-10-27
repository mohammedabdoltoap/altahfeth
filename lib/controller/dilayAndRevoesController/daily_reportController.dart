import 'package:althfeth/constants/function.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../api/LinkApi.dart';
import '../../api/apiFunction.dart';


class Daily_ReportController extends GetxController{
  var dataArg_Student;
  var dataArglastDailyReport = Rxn<Map<String, dynamic>>();
  TextEditingController markController=TextEditingController();

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
      datasoura.assignAll(List<Map<String, dynamic>>.from(res["data"]));
    } else if(res["stat"]=="no") {
      String errorMsg = res["msg"] ?? "لايوجد سور";
      mySnackbar("لايوجد", errorMsg);
    } else {
      String errorMsg = res["msg"] ?? "خطأ في جلب السور";
      mySnackbar("خطأ", errorMsg);
    }
  }
  Future select_evaluations() async {
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
      dataEvaluations.assignAll(List<Map<String, dynamic>>.from(res["data"]));
    } else {
      String errorMsg = res["msg"] ?? "خطأ في جلب التقييمات";
      mySnackbar("خطأ", errorMsg);
    }
  }


  RxBool isaddDailyRepor=false.obs;
 Future addDailyRepor()async{

   // فحص المدخلات قبل البدء
   if(toSoura.value.isNull){
      mySnackbar("قم بتحيد نظاق النهاية", "حدد سورة النهاية");
      return;
    }
    if(to_id_aya.value.isNull){
      mySnackbar("قم بتحيد رثم ايه النهائية", "حدد رقم الاية ");
      return;
    }

   if(dataArglastDailyReport.value?["to_id_soura"]==toSoura.value!["id_soura"] && dataArglastDailyReport.value?["to_id_aya"]>=to_id_aya.value){
     mySnackbar("قم بتحديد نظاق الايات بشكل صحيح ", "يجب ان يكون رقم ايه النهائة اكبر من البداية(ترتيب الايات ) ");
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
   Map data = {
     "id_student": dataArg_Student["id_student"],
     "from_id_soura": dataArglastDailyReport.value?["to_id_soura"],
     "from_id_aya": dataArglastDailyReport.value?["to_id_aya"],
     "to_id_soura": toSoura.value!["id_soura"],
     "to_id_aya": to_id_aya.value,
     "id_user": dataArg_Student["id_user"],
     "id_circle": dataArg_Student["id_circle"],
     "mark":markController.text,
     "id_evaluation":selectedEvaluations.value,
   };

   // استخدام handleRequest للإرسال
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
     Get.back();
     mySnackbar("نجاح", "تم الاضافة بنجاح", type: "g");
   } else {
     // قراءة رسالة الخطأ التفصيلية من الـAPI
     String errorMsg = res["msg"] ?? "حصل خطأ غير محدد";
     mySnackbar("تحذير", errorMsg);
   }
 }

   RxList<Map<String,dynamic>> dataEvaluations=<Map<String,dynamic>>[].obs;
  RxnInt selectedEvaluations=RxnInt(null);


}









