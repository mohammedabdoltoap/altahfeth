import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../api/LinkApi.dart';
import '../api/apiFunction.dart';
import '../constants/function.dart';
import '../constants/loadingWidget.dart';
import '../constants/myreport.dart';

class Add_VisitController extends GetxController{

  var dataArg;
  @override
  void onInit() {
    dataArg=Get.arguments;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      print("dataArg====${dataArg}");
      select_visits_type_months_years();
    },);
  }

  RxInt selectedIdMonths = RxInt(0);
  RxInt selectedIdYears = RxInt(0);
  RxInt selectedIdVisitsType = RxInt(0);
  RxInt selectedIdCirle = RxInt(0);

  RxList<Map<String,dynamic>> months=<Map<String,dynamic>>[].obs;
  RxList<Map<String,dynamic>> years=<Map<String,dynamic>>[].obs;
  RxList<Map<String,dynamic>> visits_type=<Map<String,dynamic>>[].obs;
  RxList<Map<String,dynamic>> circles=<Map<String,dynamic>>[].obs;
  List<Map<String,dynamic>> visits=<Map<String,dynamic>>[];

  Future select_visits_type_months_years()async{
    showLoading();
    await del();
    var res=await postData(Linkapi.select_visits_type_months_years, {"id_user":dataArg["id_user"]});
    hideLoading();
    if(res["stat"]=="ok"){
      months.assignAll(List<Map<String, dynamic>>.from(res["months"]));
      years.assignAll(List<Map<String, dynamic>>.from(res["years"]));
      visits_type.assignAll(List<Map<String, dynamic>>.from(res["visits_type"]));
      circles.assignAll(List<Map<String, dynamic>>.from(res["circles"]));
      visits.assignAll(List<Map<String, dynamic>>.from(res["visits"]));
      print("visits======${visits}");

    }
    else {
      mySnackbar("تنبية", res["msg"]);
    }
  }

  Future insert_visits()async{


    if(selectedIdCirle?.value==0) {
      mySnackbar("تنبية","يرجى تحديد الحلقة" );
      return;
    }
    if(selectedIdMonths?.value==0) {
      mySnackbar("تنبية","يرجى تحديد الشهر" );
      return;
    }
    if(selectedIdYears?.value==0) {
      mySnackbar("تنبية","يرجى تحديد السنة" );
      return;
    }
    if(selectedIdVisitsType?.value==0) {
      mySnackbar("تنبية","يرجى تحديد نوع الزيارة" );
      return;
    }

    if(visits.isNotEmpty)
      for(int i=0;i<visits.length;i++){
        if(visits[i]["id_visit_type"]==selectedIdVisitsType.value &&
            visits[i]["id_month"]==selectedIdMonths.value &&
            visits[i]["id_year"]==selectedIdYears.value &&
            visits[i]["id_visit_type"]==1 &&
            visits[i]["id_circle"]==selectedIdCirle.value
        ){
          mySnackbar("قد تم الاضافة نفس البيانات مسبقا", "قد تم اضافة هذا في تاريخ ${visits[i]["date"]}");
          return;
        }
      }
    showLoading();
    await del();
    Map data={
      "id_user":dataArg["id_user"],
      "id_month":selectedIdMonths?.value,
      "id_year":selectedIdYears?.value,
      "id_visit_type":selectedIdVisitsType?.value,
      "id_circle":selectedIdCirle?.value,
    };
    var res=await postData(Linkapi.insert_visits, data);
    hideLoading();
    if(res["stat"]=="ok"){
      Get.back();
      mySnackbar("نجاح", "تم الاضافة بنجاح",type: "g");
    }
    else if(res["stat"]=="erorr"){
      mySnackbar("تنبية", "${res["msg"]}",);
    }
    else {
      mySnackbar("تنبية", "حصل خطا اثناء الاضافة",);

    }
  }


  // Future showReport()async{
  //   final headers = ["التاريخ", "السنة", "الشهر", "نوع الزيارة", "اسم مدير المركز"];
  //   final rows = visits.map((v) => [
  //     (v["date"] ?? "غير متوفر").toString(),
  //     (v["name_year"] ?? "غير متوفر").toString(),
  //     (v["month_name"] ?? "غير متوفر").toString(),
  //     (v["name_visit_type"] ?? "غير متوفر").toString(),
  //     (v["username"] ?? "غير متوفر").toString(),
  //   ]).toList();
  //
  //
  //   await generateStandardPdfReport(
  //     title: "تقرير الزيارات",
  //     // subTitle: "${date}",
  //     headers:headers,
  //     rows:rows,
  //   );
  //
  // }

}