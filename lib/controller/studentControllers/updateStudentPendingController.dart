import 'package:althfeth/api/LinkApi.dart';
import 'package:althfeth/controller/home_cont.dart';
import 'package:althfeth/controller/studentControllers/pendingStudentsController.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../api/apiFunction.dart';
import '../../constants/function.dart';


class UpdateStudentPendingController extends GetxController {

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  var dataArg;

  @override
  void onInit() {
    dataArg = Get.arguments;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await select_level();
       select_reders();
       select_qualification();
      showData();
    },);

    super.onInit();
  }

  void showData(){
    name_student.text = dataArg["name_student"] ?? "";
    address_student.text = dataArg["address_student"] ?? "";
    surname.text = dataArg["surname"] ?? "";
    place_of_birth.text = dataArg["place_of_birth"] ?? "";
    date_of_birth.text = dataArg["date_of_birth"] ?? "";
    phone.text = dataArg["phone"] ?? "";
    school_name.text = dataArg["school_name"] ?? "";
    classroom.text = dataArg["classroom"] ?? "";
    guardian.text = dataArg["guardian"] ?? "";
    jop.text = dataArg["jop"] ?? "";
    password.text = dataArg["password"] ?? "";
    chronic_diseases.text = dataArg["chronic_diseases"] ?? "";
    selectedGender.value = dataArg["sex"] == "ذكر" ? "ذكر" : "أنثى";
    selectedReaderId?.value = dataArg["id_reder"] ?? 0;
    qualification_selected?.value = dataArg["id_qualification"] ?? 0;
    
    print("DEBUG: id_stages = ${dataArg["id_stages"]}, id_level = ${dataArg["id_level"]}");
    print("DEBUG: stages count = ${stages.length}, dataStageAndLevel count = ${dataStageAndLevel.length}");
    
    selectedStageId?.value = dataArg["id_stages"] ?? 0;
    selectedLevelId?.value = dataArg["id_level"] ?? 0;
    canRead.value = (dataArg["can_read"] ?? 0) == 1;
    
    print("DEBUG: After setting - selectedStageId = ${selectedStageId?.value}, selectedLevelId = ${selectedLevelId?.value}");
    
    // فلترة المستويات بناءً على المرحلة المحفوظة (بدون إعادة تعيين المستوى)
    if(selectedStageId!.value != 0) {
      filterLevels(selectedStageId!.value, resetSelection: false);
      print("DEBUG: Filtered levels, count = ${levels.length}");
    }
    
    // تعيين flag لإشارة أن البيانات تم تحميلها
    isDataLoaded.value = true;
    print("DEBUG: isDataLoaded = true");
  }


  RxInt? selectedStageId = 0.obs;
  RxInt? selectedLevelId = 0.obs;
  RxBool isDataLoaded = false.obs;
  TextEditingController name_student = TextEditingController();
  TextEditingController address_student = TextEditingController();
  TextEditingController surname = TextEditingController();
  TextEditingController place_of_birth = TextEditingController();
  TextEditingController date_of_birth = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController school_name = TextEditingController();
  TextEditingController classroom = TextEditingController();
  TextEditingController guardian = TextEditingController();
  TextEditingController jop = TextEditingController();
  TextEditingController chronic_diseases = TextEditingController();
  TextEditingController password = TextEditingController();
  RxnString selectedGender = RxnString(null);
  RxBool canRead=false.obs; // هل الطالب يجيد القراءة

  final List<String> genders = ['ذكر', 'أنثى'];

  List<Map<String, dynamic>> dataStageAndLevel = [];

  var stages = <Map<String, dynamic>>[].obs;
  var levels = <Map<String, dynamic>>[].obs;

  Future updateStudentPending() async {
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
    
    if (qualification_selected!.value == null || qualification_selected!.value == 0) {
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
      "id_student": dataArg["id_student"],
      "name_student": name_student.text.trim(),
      "address_student": address_student.text,
      "surname": surname.text,
      "place_of_birth": place_of_birth.text,
      "date_of_birth": date_of_birth.text,
      "phone": phone.text,
      "school_name": school_name.text,
      "classroom": classroom.text,
      "guardian": guardian.text.trim(),
      "jop": jop.text,
      "id_stages": selectedStageId!.value,
      "id_level": selectedLevelId!.value,
      "sex": selectedGender.value,
      "id_qualification": qualification_selected?.value,
      "chronic_diseases": chronic_diseases.text,
      "id_reder": selectedReaderId?.value,
      "password": password.text.trim(),
      "can_read": canRead.value ? 1 : 0,
    };
    print("dataBody=====${dataBody}");
    final data = await handleRequest<dynamic>(
      isLoading: RxBool(false),
      loadingMessage: "جاري حفظ التعديلات...",
      useDialog: true,
      immediateLoading: true,
      action: () async {
        return await postData(Linkapi.update_StudentPendeng, dataBody);
      },
    );

    if (data == null) return;
    if (data is! Map) {
      mySnackbar("خطأ", "فشل الاتصال بالخادم");
      return;
    }
    if (data["stat"] == "ok") {
      Get.back();
      mySnackbar("نجاح", "تم حفظ التعديلات بنجاح", type: "g");
      PendingStudentsController pendingStudentsController=Get.put(PendingStudentsController());
      pendingStudentsController.getPendingStudents();

    } else {
      String errorMsg = data["msg"] ?? "لم يتم حفظ التعديلات";
      mySnackbar("خطأ", errorMsg);
    }
  }

  RxBool isLodingLevel = false.obs;
  RxBool hasLevelData = false.obs;
  
  Future select_level() async {
    final response = await handleRequest<dynamic>(
      isLoading: isLodingLevel,
      loadingMessage: "جاري تحميل المراحل والمستويات...",
      useDialog: true,
      immediateLoading: true,
      action: () async {
        return await postData(Linkapi.select_levels, {});
      },
    );

    if(response == null) {
      hasLevelData.value = false;
      return;
    }
    if (response is! Map) {
      mySnackbar("خطأ", "فشل الاتصال بالخادم");
      hasLevelData.value = false;
      return;
    }
    if(response["stat"] == "ok"){
      dataStageAndLevel = List<Map<String,dynamic>>.from(response["data"]);
      var seen = <int>{};
      var uniqueStages = dataStageAndLevel
          .where((e) => seen.add(e["id_stages"]))
          .map((e) => {"id": e["id_stages"], "name": e["name_stages"]})
          .toList();
      stages.assignAll(uniqueStages);
      hasLevelData.value = true;
    }
    else if(response["stat"] == "no"){
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

  void filterLevels(int stageId, {bool resetSelection = true}) {
    if(resetSelection) {
      selectedLevelId!.value = 0;
    }
    var filteredLevels = dataStageAndLevel
        .where((e) => e["id_stages"] == stageId)
        .map((e) => {"id": e["id_level"], "name": e["name_level"]})
        .toList();
    levels.assignAll(filteredLevels);
  }

  RxInt? selectedReaderId = RxInt(0);
  RxList<Map<String, dynamic>> reder = <Map<String, dynamic>>[].obs;

  RxBool hasReaderData = false.obs;
  RxBool hasQualificationData = false.obs;
  
  Future select_reders() async {
    final response = await handleRequest<dynamic>(
      isLoading: RxBool(false),
      loadingMessage: "جاري تحميل القرّاء...",
      useDialog: true,
      immediateLoading: true,
      action: () async {
        return await postData(Linkapi.select_reders, {});
      },
    );
    if(response == null) {
      hasReaderData.value = false;
      return;
    }
    if (response is! Map) {
      mySnackbar("خطأ", "فشل الاتصال بالخادم");
      hasReaderData.value = false;
      return;
    }
    if(response["stat"] == "ok"){
      reder.assignAll(RxList<Map<String, dynamic>>.from(response["data"]));
      hasReaderData.value = true;
    }
    else if(response["stat"] == "no"){
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
  RxList<Map<String, dynamic>> qualification = <Map<String, dynamic>>[].obs;
  
  Future select_qualification() async {
    final response = await handleRequest<dynamic>(
      isLoading: hasQualificationData,
      loadingMessage: "جاري تحميل الموهلات...",
      useDialog: true,
      immediateLoading: true,
      action: () async {
        return await postData(Linkapi.select_qualification, {});
      },
    );
    if(response == null) {
      hasQualificationData.value = false;
      return;
    }
    if (response is! Map) {
      mySnackbar("خطأ", "فشل الاتصال بالخادم");
      hasQualificationData.value = false;
      return;
    }
    if(response["stat"] == "ok"){
      qualification.assignAll(RxList<Map<String, dynamic>>.from(response["data"]));
      hasQualificationData.value = true;
    }
    else if(response["stat"] == "no"){
      mySnackbar("تنبيه", "لا يوجد موهلات متاحة في النظام", type: "y");
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
