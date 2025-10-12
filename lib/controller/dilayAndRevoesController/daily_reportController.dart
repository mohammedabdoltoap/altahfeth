
import 'package:althfeth/constants/color.dart';
import 'package:althfeth/constants/function.dart';
import 'package:althfeth/constants/loadingWidget.dart';
import 'package:althfeth/view/screen/dilaysAndRevoews/daily_report.dart';
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
      select_fromId_soura_with_to_soura();
    },);
  }



  var to_id_aya = Rx<int?>(null);
  var toSoura = Rxn<Map<String, dynamic>>();

  var datasoura = <Map<String, dynamic>>[].obs;
  Future select_fromId_soura_with_to_soura() async {

    showLoading();
    await del();
    await  select_evaluations();
    var response = await postData(Linkapi.select_fromId_soura_with_to_soura, {
      "id_level":dataArg_Student["id_level"],
      "id_soura":dataArglastDailyReport.value!["to_id_soura"],
    });
    hideLoading();
    if (response["stat"] == "ok") {
      datasoura.assignAll(List<Map<String, dynamic>>.from(response["data"]));

    } else {
      mySnackbar("خطا اثناء جلب السور", "datasoura");

    }
  }


 Future addDailyRepor()async{


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
    showLoading();
    await del();

     var res=await postData(Linkapi.addDailyReport, data);
    hideLoading();
     if(res["stat"]=="ok"){
       Get.back();
       mySnackbar("نجاح", "تم الاضافة بنجاح",type: "g");
     }
     else{
       mySnackbar("تحذير", "حصل خطا ");
     }
   }

   RxList<Map<String,dynamic>> dataEvaluations=<Map<String,dynamic>>[].obs;
  RxnInt selectedEvaluations=RxnInt(null);
  Future select_evaluations()async{
    var res=await postData(Linkapi.select_evaluations, {});
    dataEvaluations.assignAll(RxList<Map<String,dynamic>>.from(checkApi(res)));

  }

}









