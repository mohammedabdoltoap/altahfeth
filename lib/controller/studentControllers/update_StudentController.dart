import 'package:althfeth/api/LinkApi.dart';
import 'package:althfeth/controller/home_cont.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../api/apiFunction.dart';
import '../../constants/function.dart';


class Update_StudentController extends GetxController {

  var dataArg;

  @override
  void onInit() {
    dataArg = Get.arguments;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      select_reders();
      shwoData();
    },);

    // TODO: implement onInit
    super.onInit();
  }


  shwoData(){
    name_student.text=dataArg["name_student"];
    address_student.text=dataArg["address_student"];
    surname.text=dataArg["surname"];
    place_of_birth.text=dataArg["place_of_birth"];
    date_of_birth.text=dataArg["date_of_birth"];
    phone.text=dataArg["phone"];
    school_name.text=dataArg["school_name"];
    classroom.text=dataArg["classroom"];
    guardian.text=dataArg["guardian"];
    jop.text=dataArg["jop"];
    date_of_birth.text=dataArg["date_of_birth"];
    password.text=dataArg["password"];
    chronic_diseases.text=dataArg["chronic_diseases"];
    selectedGender.value= dataArg["sex"]=="ذكر"? "ذكر":"أنثى";
    selectedReaderId.value=dataArg["id_reder"];
    qualification_selected.value=dataArg["qualification"]=="اجازة"?"اجازة":"حفظ";
  }
  // RxInt? selectedStageId = 0.obs;
  // RxInt? selectedLevelId = 0.obs;
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
  RxnString qualification_selected = RxnString(null);


  final List<String> genders = ['ذكر', 'أنثى'];
  final List<String> qualification = ['اجازة', 'حفظ'];

  // RxBool isLoading_addStudent=false.obs;


  Future update_Student() async {
    // تحقق من الاسم
    if (name_student.text.isEmpty) {
      mySnackbar("تحذير", "يرجى ادخال اسم الطالب");
      return;
    }
    else if (name_student.text.length < 9) {
      mySnackbar("تحذير", "يرجى ادخال اسم الطالب الرباعي");
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

    // if (selectedStageId!.value == 0) {
    //   mySnackbar("تحذير", "يرجى ادخال المرحلة");
    //   return;
    // }
    if (qualification_selected!.value.isNull) {
      mySnackbar("تحذير", "يرجى ادخال الموهل");
      return;
    }
    if (selectedReaderId.value==0) {
      mySnackbar("تحذير", "يرجى ادخال القارى");
      return;
    }
    if (selectedGender!.value.isNull) {
      mySnackbar("تحذير", "يرجى ادخال الجنس");
      return;
    }



    var dataBody = {
      "id_student":dataArg["id_student"],
      "name_student": name_student.text.trim(),
      "address_student": address_student.text,
      "surname": surname.text,
      "place_of_birth": place_of_birth.text,
      "date_of_birth": date_of_birth.text,
      "phone": phone.text,
      "school_name": school_name.text,
      "classroom": classroom.text,
      "guardian": guardian.text,
      "jop": jop.text,
      "sex": selectedGender.value,
      "qualification": qualification_selected.value,
      "chronic_diseases": chronic_diseases.text,
      "id_reder": selectedReaderId.value,
      "password": password.text.trim(),
    };

    final data = await handleRequest<dynamic>(
      isLoading: RxBool(false),
      loadingMessage: "جاري حفظ التعديلات...",
      useDialog: true,
      immediateLoading: true,
      action: () async {
        return await postData(Linkapi.update_Student, dataBody);
      },
    );
    if (data == null) return;
    if (data is! Map) {
      mySnackbar("خطأ", "فشل الاتصال بالخادم");
      return;
    }
    if (data["stat"] == "ok") {
      HomeCont homeCont=Get.put(HomeCont());
     await homeCont.getstudents();
      Get.back();
      mySnackbar("نجاح", "تم التعديل بنجاح", type: "g");
    } else {
      String errorMsg = data["msg"] ?? "لم يتم حفظ التعديلات";
      mySnackbar("خطأ", errorMsg);
    }
    //
  }

  RxInt selectedReaderId = RxInt(0);
  RxList<Map<String, dynamic>> reder=<Map<String, dynamic>>[].obs;
  RxBool isLodeReder=false.obs;
  Future select_reders()async {
    final response = await handleRequest<dynamic>(
      isLoading: isLodeReder,
      loadingMessage: "جاري تحميل القرّاء...",
      useDialog: false,
      immediateLoading: false,
      action: () async {
        return await postData(Linkapi.select_reders, {});
      },
    );
    if(response==null) return;
    if (response is! Map) {
      mySnackbar("خطأ", "فشل الاتصال بالخادم");
      return;
    }
    if(response["stat"]=="ok"){
      reder.assignAll(RxList<Map<String, dynamic>>.from(response["data"]));
    }
    else{
      String errorMsg = response["msg"] ?? "تعذر تحميل قائمة القرّاء";
      mySnackbar("خطأ", errorMsg);
    }


  }
}





