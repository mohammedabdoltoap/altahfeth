import 'package:althfeth/api/LinkApi.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../api/apiFunction.dart';
import '../../constants/function.dart';


class AddstudentController extends GetxController{

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  var dataArg;
  @override
  void onInit() {
    dataArg=Get.arguments;

    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) async{
      select_level();
      select_reders();
      select_qualification();
    // },);

    // TODO: implement onInit
    super.onInit();
  }

  void resetForm(){
    name_student.clear();
    address_student.clear();
    surname.clear();
    place_of_birth.clear();
    date_of_birth.clear();
    phone.clear();
    school_name.clear();
    classroom.clear();
    guardian.clear();
    jop.clear();
    chronic_diseases.clear();
    password.clear();
    selectedLevelId?.value = 0;
    selectedStageId?.value = 0;
    selectedReaderId?.value = 0;
    qualification_selected?.value = 0;
    selectedGender.value = null;
    levels.clear();
  }
   RxInt? selectedStageId = 0.obs;
   RxInt? selectedLevelId = 0.obs;
  TextEditingController name_student=TextEditingController();
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


   // RxnString reder_selected=RxnString(null);

  final List<String> genders = ['ذكر', 'أنثى'];

  // RxBool isLoading_addStudent=false.obs;
  List<Map<String, dynamic>>dataStageAndLevel=[];

  var stages = <Map<String, dynamic>>[].obs; // كل المراحل بدون تكرار
  var levels = <Map<String, dynamic>>[].obs; // المستويات حسب المرحلة المختارة

  Future addStudent() async {
    // التحقق من صحة النموذج
    if (!formKey.currentState!.validate()) {
      mySnackbar("تحذير", "يرجى ملء جميع الحقول المطلوبة");
      return;
    }

    // التحقق من القوائم المنسدلة
    if (selectedStageId!.value == 0) {
      mySnackbar("تحذير", "يرجى اختيار المرحلة");
      return;
    }
    
    if (selectedLevelId!.value == 0) {
      mySnackbar("تحذير", "يرجى اختيار المستوى");
      return;
    }
    
    if (qualification_selected!.value == null) {
      mySnackbar("تحذير", "يرجى اختيار المؤهل القرآني");
      return;
    }
    
    if (selectedReaderId!.value == 0) {
      mySnackbar("تحذير", "يرجى اختيار القارئ");
      return;
    }
    
    if (selectedGender!.value == null) {
      mySnackbar("تحذير", "يرجى اختيار الجنس");
      return;
    }

     var dataBody = {
       "name_student": name_student.text.trim(),
       "address_student": address_student.text,
       "surname":surname.text,
       "place_of_birth":place_of_birth.text,
       "date_of_birth":date_of_birth.text,
       "phone":phone.text,
       "school_name":school_name.text,
       "classroom":classroom.text,
       "guardian":guardian.text.trim(),
       "jop":jop.text,
       "id_stages": selectedStageId!.value,
       "id_level": selectedLevelId!.value,
       "status": 0,
       "id_circle": dataArg["id_circle"],
       "sex":selectedGender.value,
       "id_qualification":qualification_selected?.value,
       "chronic_diseases":chronic_diseases.text,
       "id_reder":selectedReaderId?.value,
       "password":password.text.trim(),
     };

     final data = await handleRequest<dynamic>(
      isLoading: RxBool(false),
      loadingMessage: "جاري إرسال الطلب...",
      useDialog: true,
      immediateLoading: true,
      action: () async {
        return await postData(Linkapi.insertStudents, dataBody);
      },
    );

    if (data == null) return;
    if (data is! Map) {
      mySnackbar("خطأ", "فشل الاتصال بالخادم");
      return;
    }
    if (data["stat"] == "ok") {
      mySnackbar("نجاح", "تم تقديم طلب الإضافة بنجاح", type: "g");
      Get.focusScope?.unfocus();
      resetForm();
    } else {
      String errorMsg = data["msg"] ?? "لم يتم تقديم طلب الإضافة";
      mySnackbar("خطأ", errorMsg);
    }

  }

  RxBool isLodingLevel=false.obs;
  RxBool hasLevelData=false.obs; // للتحقق من وجود بيانات (تبدأ false)
  
  Future select_level()async {
    final response = await handleRequest<dynamic>(
      isLoading: isLodingLevel,
      loadingMessage: "جاري تحميل المراحل والمستويات...",
      useDialog: true,
      immediateLoading: true,
      action: () async {
        return await postData(Linkapi.select_levels, {});
      },
    );
    // var response=await postData(Linkapi.select_levels, {});
    print("dataStageAndLevel====${dataStageAndLevel}    ===response${response}           ");

    if(response==null) {
      hasLevelData.value = false;
      return;
    }
    if (response is! Map) {
      mySnackbar("خطأ", "فشل الاتصال بالخادم");
      hasLevelData.value = false;
      return;
    }
    if(response["stat"]=="ok"){
      dataStageAndLevel=List<Map<String,dynamic>>.from(response["data"]);
      var seen = <int>{};
      var uniqueStages = dataStageAndLevel
          .where((e) => seen.add(e["id_stages"])) // يحتفظ بأول ظهور فقط
          .map((e) => {"id": e["id_stages"], "name": e["name_stages"]})
          .toList();
      stages.assignAll(uniqueStages);
      hasLevelData.value = true;
    }
    else if(response["stat"]=="no"){
      // لا توجد مراحل أو مستويات في النظام
      mySnackbar("تنبيه", "لا توجد مراحل أو مستويات متاحة في النظام", type: "y");
      hasLevelData.value = false;
      stages.clear();
    }
    else{
      String errorMsg = response["msg"] ?? "تعذّر تحميل المراحل والمستويات";
      mySnackbar("خطأ", errorMsg);
      hasLevelData.value = false;
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

  RxBool hasReaderData=false.obs; // للتحقق من وجود قراء (تبدأ false)
  RxBool hasQualificationData=false.obs; // للتحقق من وجود قراء (تبدأ false)
  Future select_reders()async {
    final response = await handleRequest<dynamic>(
      isLoading: RxBool(false),
      loadingMessage: "جاري تحميل القرّاء...",
      useDialog: true,
      immediateLoading: true,
      action: () async {
        return await postData(Linkapi.select_reders, {});
      },
    );
    if(response==null) {
      hasReaderData.value = false;
      return;
    }
    if (response is! Map) {
      mySnackbar("خطأ", "فشل الاتصال بالخادم");
      hasReaderData.value = false;
      return;
    }
    if(response["stat"]=="ok"){
      reder.assignAll(RxList<Map<String, dynamic>>.from(response["data"]));
      hasReaderData.value = true;
    }
    else if(response["stat"]=="no"){
      // لا يوجد قراء في النظام
      mySnackbar("تنبيه", "لا يوجد قرّاء متاحون في النظام", type: "y");
      hasReaderData.value = false;
      reder.clear();
    }
    else{
      String errorMsg = response["msg"] ?? "تعذّر تحميل قائمة القرّاء";
      mySnackbar("خطأ", errorMsg);
      hasReaderData.value = false;
    }

  }


  RxInt? qualification_selected = RxInt(0);
  RxList<Map<String, dynamic>> qualification=<Map<String, dynamic>>[].obs;
  Future select_qualification()async {
    final response = await handleRequest<dynamic>(
      isLoading: hasQualificationData,
      loadingMessage: "جاري تحميل الموهلات...",
      useDialog: true,
      immediateLoading: true,
      action: () async {
        return await postData(Linkapi.select_qualification, {});
      },
    );
    if(response==null) {
      hasQualificationData.value = false;
      return;
    }
    if (response is! Map) {
      mySnackbar("خطأ", "فشل الاتصال بالخادم");
      hasQualificationData.value = false;
      return;
    }
    if(response["stat"]=="ok"){
      qualification.assignAll(RxList<Map<String, dynamic>>.from(response["data"]));
      hasQualificationData.value = true;
    }
    else if(response["stat"]=="no"){
      // لا يوجد قراء في النظام
      mySnackbar("تنبيه", "لا يوجد قرّاء متاحون في النظام", type: "y");
      hasQualificationData.value = false;
      qualification.clear();
    }
    else{
      String errorMsg = response["msg"] ?? "تعذّر تحميل الموهلات";
      mySnackbar("خطأ", errorMsg);
      hasQualificationData.value = false;
    }

  }


}




