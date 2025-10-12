import 'package:althfeth/api/LinkApi.dart';
import 'package:althfeth/constants/loadingWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../api/apiFunction.dart';
import '../../constants/function.dart';


class AddstudentController extends GetxController{

  var dataArg;
  @override
  void onInit() {
    dataArg=Get.arguments;
    print("${dataArg}rrrrrrrrrrrrrrrr");

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      select_level();
      select_reders();
    },);

    // TODO: implement onInit
    super.onInit();
  }
   RxInt? selectedStageId = 0.obs;
   RxInt? selectedLevelId = 0.obs;
  TextEditingController name_student=TextEditingController();
   TextEditingController age_student=TextEditingController();
   TextEditingController address_student=TextEditingController();
   TextEditingController surname=TextEditingController();
   TextEditingController place_of_birth=TextEditingController();
   TextEditingController date_of_birth=TextEditingController();
   TextEditingController phone=TextEditingController();
   TextEditingController school_name=TextEditingController();
   TextEditingController classroom=TextEditingController();
   TextEditingController guardian=TextEditingController();
   TextEditingController jop=TextEditingController();
   TextEditingController chronic_diseases=TextEditingController();
   TextEditingController password=TextEditingController();
   RxnString selectedGender=RxnString(null);
   RxnString qualification_selected=RxnString(null);
   // RxnString reder_selected=RxnString(null);

  final List<String> genders = ['ذكر', 'أنثى'];
  final List<String> qualification = ['اجازة', 'حفظ'];
  // final List<String> reder = ['حفص', 'شعبة'];

  // RxBool isLoading_addStudent=false.obs;
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

     if (password.text.isEmpty) {
       mySnackbar("تحذير", "يرجى ادخال كلمة المرور");
       return;
     }

     if (selectedStageId!.value == 0) {
       mySnackbar("تحذير", "يرجى ادخال المرحلة");
       return;
     }
     if (qualification_selected!.value.isNull) {
       mySnackbar("تحذير", "يرجى ادخال الموهل");
       return;
     }
if (selectedReaderId!.value==0) {
       mySnackbar("تحذير", "يرجى ادخال القارى");
       return;
     }
if (selectedGender!.value.isNull) {
       mySnackbar("تحذير", "يرجى ادخال الجنس");
       return;
     }

     if (selectedLevelId!.value == 0) {
       mySnackbar("تحذير", "يرجى ادخال المستوى");
       return;
     }

     var dataBody = {
       "name_student": name_student.text.trim(),
       "age_student": age,
       "address_student": address_student.text,
       "surname":surname.text,
       "place_of_birth":place_of_birth.text,
       "date_of_birth":date_of_birth.text,
       "phone":phone.text,
       "school_name":school_name.text,
       "classroom":classroom.text,
       "guardian":guardian.text,
       "jop":jop.text,
       "id_stages": selectedStageId!.value,
       "id_level": selectedLevelId!.value,
       "status": 0,
       "id_circle": dataArg["id_circle"],
       "sex":selectedGender.value,
       "qualification":qualification_selected.value,
       "chronic_diseases":chronic_diseases.text,
       "id_reder":selectedReaderId?.value,
       "password":password.text.trim(),
     };

     showLoading();
     await Future.delayed(Duration(seconds: 2));
     var data = await postData(Linkapi.insertStudents, dataBody);
     hideLoading();
     if (data["stat"] == "ok") {
       mySnackbar("نجاح", "تم تقديم طلب الاضافة بنجاح", type: 1);
       name_student.text="";
       age_student.text="";
       address_student.text="";
       selectedLevelId!.value=0;
       selectedStageId!.value=0;
       // reder_selected.value="";
       chronic_diseases.text="";
       qualification_selected.value="";
       selectedGender.value="";
       jop.text="";
       guardian.text="";
       classroom.text="";
       school_name.text="";
       phone.text="";
       date_of_birth.text="";
       place_of_birth.text="";
       surname.text="";

     } else {
       mySnackbar("تحقق من الانترنت", "حصل خطأ");
     }

   }

   Future select_level()async {

    showLoading();
    await del();
     var response=await postData(Linkapi.select_levels, {});
  hideLoading();
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


  RxInt? selectedReaderId = RxInt(0);
  RxList<Map<String, dynamic>> reder=<Map<String, dynamic>>[].obs;
  Future select_reders()async {

    showLoading();
    await del();
    var response=await postData(Linkapi.select_reders, {});
    hideLoading();
    if(response["stat"]=="ok"){
      // reder.assignAll(response["data"]);
    reder.assignAll(RxList<Map<String, dynamic>>.from(response["data"]));
    }
    else{
      print("errrrrrrrrrooooooooorrrr===== ${response}");

    }

  }

}




