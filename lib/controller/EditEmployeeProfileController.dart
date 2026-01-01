import 'package:althfeth/controller/home_cont.dart';
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
  
  // var employeeData = <String, dynamic>{}.obs;
  
  @override
  void onInit() {
    super.onInit();
    dataArg = Get.arguments;
    WidgetsBinding.instance.addPostFrameCallback((_) => _loginWithInternet());
  }
  
  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.onClose();
  }

Map <String,dynamic> data_user={};

  Future<void> _loginWithInternet() async {
    print('🌐 محاولة تسجيل الدخول عبر الإنترنت...');

    try {

      // 1️⃣ استدعاء API (postData) لإرسال بيانات المستخدم للخادم
      // postData ترسل HTTP POST request مع JSON data و Bearer token
      var response =await handleRequest( useDialog: true,
          loadingMessage: "جاري تحميل البيانات الشخصية ",
          immediateLoading: true,
          isLoading: (false.obs), action: ()async {
        return   await postData(Linkapi.select_users_id_user, {
        "id_user": dataArg["id_user"],
        });

      },);

      if (response == null) {
        return;
      }

      if (response is! Map) {
        mySnackbar("خطأ", "رد غير صحيح من الخادم");
        return;
      }
      if (response["stat"] == "ok") {
        // ✅ تسجيل الدخول نجح
        data_user = response["data"];

        nameController.text = data_user["username"] ?? "";
        emailController.text = data_user["email"] ?? "";
        phoneController.text = data_user["phone"].toString() ?? "";
        password.text = data_user["password"] ?? "";


      } else if (response["stat"] == "no") {
        // ❌ البيانات خاطئة (username أو password غير صحيح)
        mySnackbar("خطأ", "اسم المستخدم أو كلمة المرور خاطئة");
      } else if (response["stat"] == "error") {
        // ❌ خطأ من الخادم
        String errorMsg = response["msg"] ?? "خطأ في الخادم";
        mySnackbar("خطأ", errorMsg);
      }
    } catch (e) {
      mySnackbar("خطأ", "فشل الاتصال بالخادم${e}");
    }
  }

  Future<void> updateProfile() async {
    if (!_validateInputs()) return;
    if(password.text.trim().isEmpty){
      mySnackbar("تنبيه", "يرجى إدخال كلمة سر");
      return;
    }
    if(phoneController.text.trim().isEmpty){
      mySnackbar("تنبيه", "يرجى إدخال email");
      return;
    }

    String phoneText = phoneController.text.trim();

    int? phone = int.tryParse(phoneText);

    if (phone == null) {
      // ❌ ليس رقم
      mySnackbar("تنبية","رقم الهاتف غير صحيح");
      return;
    }

    var res = await handleRequest(
      isLoading: isSaving,
      loadingMessage: "جاري حفظ التعديلات...",
      useDialog: true,
      action: () async {
        return await postData(Linkapi.update_employee_profile, {
          // "id_employee": employeeData["id_employee"],
          "id_user": dataArg["id_user"],
          "username": nameController.text.trim(),
          "email": emailController.text.trim(),
          "phone":phone,
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

       db.update("users", {
         "username": nameController.text.trim(),
         "email": emailController.text.trim(),
         "phone":phoneController.text.trim(),
         "password":password.text.trim(),


       },where: "id_user=${dataArg["id_user"]}");

      Get.back();
      mySnackbar("نجح", "تم تحديث البيانات بنجاح", type: "g");
      if(dataArg["role_id"]==4){
        HomeCont homeCont=Get.find();
        homeCont.nameUser.value=nameController.text.trim();
      }

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
