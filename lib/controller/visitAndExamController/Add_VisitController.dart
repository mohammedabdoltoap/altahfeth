import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../api/LinkApi.dart';
import '../../api/apiFunction.dart';
import '../../constants/function.dart';
import '../../constants/loadingWidget.dart';
import '../../constants/myreport.dart';
import '../../view/screen/adminScreen/visitsAndExam/StudentsList.dart';

class Add_VisitController extends GetxController{

  var dataArg;
  @override
  void onInit() {
    dataArg=Get.arguments;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp)async {
       select_visits_type_months_years();
      select_previous_visits();
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
  RxList<Map<String,dynamic>> visits=<Map<String,dynamic>>[].obs;
  TextEditingController notes=TextEditingController();
  RxBool loadingMetadata = false.obs;
  RxBool loadingVisitsList = false.obs;
  RxBool loadingInsertVisit = false.obs;
  RxBool loadingPreviousVisits = false.obs;

  Future select_visits_type_months_years()async{
    if (loadingMetadata.value) return;
    final res = await handleRequest<dynamic>(
      isLoading: loadingMetadata,
      loadingMessage: "جاري تحميل بيانات الزيارات...",
      useDialog: true,
      immediateLoading: true,
      action: () async {
        return await postData(Linkapi.select_visits_type_months_years, {"id_user": dataArg["id_user"]});
      },
    );

    if (res == null) return;
    if (res is! Map) {
      mySnackbar("خطأ", "فشل الاتصال بالخادم");
      return;
    }
    if (res["stat"] == "ok") {
      months.assignAll(List<Map<String, dynamic>>.from(res["months"]));
      years.assignAll(List<Map<String, dynamic>>.from(res["years"]));
      visits_type.assignAll(List<Map<String, dynamic>>.from(res["visits_type"]));
      circles.assignAll(List<Map<String, dynamic>>.from(res["circles"]));
      visits.assignAll(List<Map<String, dynamic>>.from(res["visits"]));

      print("circles======${circles}");
    } else if(res["stat"]=="erorr"){
      String errorMsg = res["msg"] ?? "تعذر تحميل بيانات الزيارات";
      mySnackbar("تنبيه", errorMsg);
    }else if(res["stat"]=="no"){
      if(circles.isEmpty){
        mySnackbar("تنبية ", "لايمكن اضافة زيارة في هذا المركز لانه لايوجد حلقات تابعة لهذا المركز ");
      }
    }
  }


  Future select_visitsed()async {
    if (loadingVisitsList.value) return;
    final res = await handleRequest<dynamic>(
      isLoading: loadingVisitsList,
      loadingMessage: "جاري تحديث قائمة الزيارات...",
      useDialog: false,
      immediateLoading: true,
      action: () async {
        return await postData(Linkapi.select_visitsed, {"id_user": dataArg["id_user"]});
      },
    );
    if (res == null) return;
    if (res is! Map) {
      mySnackbar("خطأ", "فشل الاتصال بالخادم");
      return;
    }
    if(res["stat"]=="ok") {
      visits.assignAll(List<Map<String, dynamic>>.from(res["visits"]));
      print("visits=====${visits}");
    } else {
      String errorMsg = res["msg"] ?? "تعذر تحميل الزيارات";
      mySnackbar("تنبيه", errorMsg);
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

    Map data={
      "id_user":dataArg["id_user"],
      "id_month":selectedIdMonths?.value,
      "id_year":selectedIdYears?.value,
      "id_visit_type":selectedIdVisitsType?.value,
      "id_circle":selectedIdCirle?.value,
      "notes":notes.text
    };


    if (loadingInsertVisit.value) return;
    final res = await handleRequest<dynamic>(
      isLoading: loadingInsertVisit,
      loadingMessage: "جاري إضافة الزيارة...",
      useDialog: true,
      immediateLoading: true,
      action: () async {
        return await postData(Linkapi.insert_visits, data);
      },
    );
    if (res == null) return;
    if (res is! Map) {
      mySnackbar("خطأ", "فشل الاتصال بالخادم");
      return;
    }
    if(res["stat"]=="ok"){
     var id_visit= int.tryParse(res["data"]);
     if(id_visit!=null){
       if(selectedIdVisitsType?.value==1){
         Map data_arg={
           "id_circle":selectedIdCirle?.value,
           "id_visit":id_visit,
           "id_user":dataArg["id_user"],

         };
         Get.to(()=>StudentsList(),arguments: data_arg);

       }
     }

    }
    else if(res["stat"]=="erorr"){
      mySnackbar("تنبية", "${res["msg"]}",);
    }
    else {
      mySnackbar("تنبية", "حصل خطا اثناء الاضافة",);
    }
  }


  RxList<Map<String, dynamic>> previous_visits = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> all_previous_visits = <Map<String, dynamic>>[].obs;
  
  // متغيرات الفلترة
  RxInt selectedFilterYear = RxInt(0);
  RxInt selectedFilterMonth = RxInt(0);
  Future select_previous_visits() async {
    if (loadingPreviousVisits.value) return;
    final res = await handleRequest<dynamic>(
      isLoading: loadingPreviousVisits,
      loadingMessage: "جاري تحميل الزيارات السابقة...",
      useDialog: false,
      immediateLoading: true,
      action: () async {
        return await postData(Linkapi.select_previous_visits, {
          "id_user":dataArg["id_user"]
        });
      },
    );
    if (res == null) return;
    if (res is! Map) {
      mySnackbar("خطأ", "فشل الاتصال بالخادم");
      return;
    }
    if (res["stat"] == "ok") {
      all_previous_visits.assignAll(List<Map<String, dynamic>>.from(res["data"]));
      
      // تطبيق الفلترة الافتراضية للسنة الحالية
      int currentYear = DateTime.now().year;
      var currentYearData = years.firstWhereOrNull((year) => 
        year["name_year"].toString().contains(currentYear.toString()));
      
      if (currentYearData != null) {
        selectedFilterYear.value = currentYearData["id_year"];
        filterPreviousVisits();
      } else {
        previous_visits.assignAll(all_previous_visits);
      }
      
      print("previous_visits=======${previous_visits}");
    } else if(res["stat"]=="erorr"){
      String errorMsg = res["msg"] ?? "تعذر تحميل الزيارات السابقة";
      mySnackbar("تنبيه", errorMsg);
    }
  }

  // دالة فلترة الزيارات السابقة
  void filterPreviousVisits() {
    List<Map<String, dynamic>> filteredVisits = all_previous_visits.where((visit) {
      bool yearMatch = selectedFilterYear.value == 0 || visit["id_year"] == selectedFilterYear.value;
      bool monthMatch = selectedFilterMonth.value == 0 || visit["id_month"] == selectedFilterMonth.value;
      return yearMatch && monthMatch;
    }).toList();
    
    previous_visits.assignAll(filteredVisits);
  }

  // إعادة تعيين الفلاتر
  void resetFilters() {
    selectedFilterYear.value = 0;
    selectedFilterMonth.value = 0;
    previous_visits.assignAll(all_previous_visits);
  }

  // تطبيق فلتر السنة الحالية
  void applyCurrentYearFilter() {
    int currentYear = DateTime.now().year;
    var currentYearData = years.firstWhereOrNull((year) => 
      year["name_year"].toString().contains(currentYear.toString()));
    
    if (currentYearData != null) {
      selectedFilterYear.value = currentYearData["id_year"];
      selectedFilterMonth.value = 0;
      filterPreviousVisits();
    }
  }
}