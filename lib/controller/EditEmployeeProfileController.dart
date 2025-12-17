import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../api/LinkApi.dart';
import '../api/apiFunction.dart';
import '../constants/function.dart';
import '../globals.dart';

class EditEmployeeProfileController extends GetxController {
  var dataArg;
  
  final TextEditingController nameController = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  
  RxBool isLoading = false.obs;
  RxBool isSaving = false.obs;
  
  var employeeData = <String, dynamic>{}.obs;
  
  @override
  void onInit() {
    super.onInit();
    dataArg = Get.arguments;
    WidgetsBinding.instance.addPostFrameCallback((_) => loadEmployeeData());
  }
  
  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.onClose();
  }
  
  Future<void> loadEmployeeData() async {
    var res = await handleRequest(
      isLoading: isLoading,
      useDialog: false,
      immediateLoading: true,
      action: () async {
        return await postData(Linkapi.select_employee_by_user, {
          "id_user": dataArg["id_user"],
        });
      },
    );
    
    if (res == null) return;
    
    if (res is! Map) {
      mySnackbar("خطأ", "فشل الاتصال بالخادم");
      return;
    }
    
    if (res["stat"] == "ok") {
      if (res["data"] != null && res["data"] is List && res["data"].isNotEmpty) {
        employeeData.value = res["data"][0];
        nameController.text = employeeData["name"] ?? "";
        emailController.text = employeeData["email"] ?? "";
        phoneController.text = employeeData["phone"] ?? "";
        password.text = employeeData["password"] ?? "";
      }
    } else if (res["stat"] == "no") {
      Get.back();
      mySnackbar("تنبيه", "تواصل مع الادارة بحيث يتم اضافتك كموظف اولا");
    } else {
      mySnackbar("خطأ", res["msg"] ?? "حدث خطأ أثناء جلب البيانات");
    }
  }
  
  Future<void> updateProfile() async {
    if (!_validateInputs()) return;
    if(password.text.trim().isEmpty){
      mySnackbar("تنبيه", "يرجى إدخال كلمة سر");
      return;
    }
    if(emailController.text.trim().isEmpty){
      mySnackbar("تنبيه", "يرجى إدخال email");
      return;

    }

    var res = await handleRequest(
      isLoading: isSaving,
      loadingMessage: "جاري حفظ التعديلات...",
      useDialog: true,
      action: () async {
        return await postData(Linkapi.update_employee_profile, {
          "id_employee": employeeData["id_employee"],
          "id_user": employeeData["id_user"],
          "name": nameController.text.trim(),
          "email": emailController.text.trim(),
          "phone":phoneController.text.trim(),
          "password":password.text.trim(),
        });
      },
    );
    
    if (res == null) return;
    
    if (res is! Map) {
      mySnackbar("خطأ", "فشل الاتصال بالخادم");
      return;
    }
    
    if (res["stat"] == "ok") {

       db.update("users", {"password":password.text.trim()},where: "id_user=${employeeData["id_user"]}");

      Get.back();
      mySnackbar("نجح", "تم تحديث البيانات بنجاح", type: "g");

    } else if (res["stat"] == "no") {
      mySnackbar("تنبيه", res["msg"] ?? "فشل التحديث", type: "y");
    } else {
      mySnackbar("خطأ", res["msg"] ?? "حدث خطأ أثناء التحديث");
    }
  }
  
  bool _validateInputs() {
    if (nameController.text.trim().isEmpty) {
      mySnackbar("تنبيه", "يرجى إدخال الاسم", type: "y");
      return false;
    }
    
    if (emailController.text.trim().isEmpty) {
      // final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      // if (!emailRegex.hasMatch(emailController.text.trim())) {
        mySnackbar("تنبيه", "يرجى إدخال بريد إلكتروني صحيح", type: "y");
        return false;
      // }
    }
    
    return true;
  }
}
