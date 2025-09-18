import 'package:althfeth/api/LinkApi.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../api/apiFunction.dart';
import '../constants/function.dart';


class AddstudentController extends GetxController{

  var dataArg;
  @override
  void onInit() {
    dataArg=Get.arguments;
    print("${dataArg}rrrrrrrrrrrrrrrr");

    select_level();

    // TODO: implement onInit
    super.onInit();
  }
   RxInt? selectedStageId = 0.obs;
   RxInt? selectedLevelId = 0.obs;
  TextEditingController name_student=TextEditingController();
   TextEditingController age_student=TextEditingController();
   TextEditingController address_student=TextEditingController();
   RxBool isLoading_addStudent=false.obs;
  List<Map<String, dynamic>>dataStageAndLevel=[];

  var stages = <Map<String, dynamic>>[].obs; // كل المراحل بدون تكرار
  var levels = <Map<String, dynamic>>[].obs; // المستويات حسب المرحلة المختارة

  Future addStudent() async {

     // تحقق من الاسم
     if (name_student.text.isEmpty) {
       mySnackbar("تحذير", "يرجى ادخال اسم الطالب");
       return;
     }
     else if (name_student.text.length < 9) {
       mySnackbar("تحذير", "يرجى ادخال اسم الطالب الرباعي");
       return;
     }

     // تحقق من العمر
     if (age_student.text.isEmpty) {
       mySnackbar("تحذير", "يرجى ادخال العمر");
       return;
     }

     int? age = int.tryParse(age_student.text);
     if (age == null || age < 3 || age > 100) {
       mySnackbar("تحذير", "يرجى ادخال عمر صحيح ");
       return;
     }

     if (address_student.text.isEmpty) {
       mySnackbar("تحذير", "يرجى ادخال العنوان");
       return;
     }

     if (selectedStageId!.value == 0) {
       mySnackbar("تحذير", "يرجى ادخال المرحلة");
       return;
     }

     if (selectedLevelId!.value == 0) {
       mySnackbar("تحذير", "يرجى ادخال المستوى");
       return;
     }
     var dataBody = {
       "name_student": name_student.text,
       "age_student": age,
       "address_student": address_student.text,
       "id_stages": selectedStageId!.value,
       "id_level": selectedLevelId!.value,
       "status": 0,
       "id_circle": dataArg["id_circle"],
     };
     isLoading_addStudent.value = true;
     await Future.delayed(Duration(seconds: 2));

     var data = await postData(Linkapi.insertStudents, dataBody);
     if (data["stat"] == "ok") {
       mySnackbar("نجاح", "تم الاضافة بنجاح", type: 1);
       name_student.text="";
       age_student.text="";
       address_student.text="";
       selectedLevelId!.value=0;
       selectedStageId!.value=0;
     } else {
       print("errrrrrrrrrooooooooorrrr===== ${data}");

       mySnackbar("تحقق من الانترنت", "حصل خطأ");
     }
     isLoading_addStudent.value = false;
   }

   Future select_level()async {

     var response=await postData(Linkapi.select_levels, {});
     if(response["stat"]=="ok"){
       dataStageAndLevel=List<Map<String,dynamic>>.from(response["data"]);
       var seen = <int>{};
       var uniqueStages = dataStageAndLevel
           .where((e) => seen.add(e["id_stages"])) // يحتفظ بأول ظهور فقط
           .map((e) => {"id": e["id_stages"], "name": e["name_stages"]})
           .toList();
       stages.assignAll(uniqueStages);
     }
     else{
       print("errrrrrrrrrooooooooorrrr===== ${response}");

     }

   }

  void filterLevels(int stageId) {
    selectedLevelId!.value = 0;
    // إعادة تعيين المستوى عند تغيير المرحلة
    var filteredLevels = dataStageAndLevel
        .where((e) => e["id_stages"] == stageId)
        .map((e) => {"id": e["id_level"], "name": e["name_level"]})
        .toList();
    levels.assignAll(filteredLevels);
  }
}




