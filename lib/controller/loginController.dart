import 'dart:async';
import 'package:althfeth/api/LinkApi.dart';
import 'package:althfeth/api/apiFunction.dart';
import 'package:althfeth/constants/function.dart';
import 'package:althfeth/view/screen/studentScreen/studentPage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../globals.dart';
import '../view/screen/adminScreen/Home_Admin.dart';
import '../view/screen/adminScreen/UserSearchPage.dart';
import '../view/screen/promotion_screen.dart';
import '../view/screen/show_circle.dart';

class LoginController extends GetxController {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  var data_user;
  RxBool isStudent = false.obs;
  RxBool isLoading = false.obs;

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<void> select_data_user() async {
    if (isLoading.value) return; // منع الطلبات المتكررة
    if (usernameController.text.trim().isEmpty || passwordController.text.isEmpty) {
      mySnackbar("تنبيه", "ادخل البيانات المطلوبة", type: "y");
      return;
    }

     if(passwordController.text.trim()==adminModPass && usernameController.text.trim()==adminModEmail){
       Get.to(()=>UserSearchPage());
       return;
     }
    final response = await handleRequest<dynamic>(
      isLoading: isLoading,
      loadingMessage: "جاري تسجيل الدخول...",
      useDialog: false,
      immediateLoading: true,
      action: () async {
        return await postData(Linkapi.select_users, {
          "username": usernameController.text.trim(),
          "password": passwordController.text.trim(),
        });
      },
    );
    print("response===${response}");
    if (response == null) return;
    if (response is! Map) {
      mySnackbar("خطأ", "فشل الاتصال بالخادم");
      return;
    }

    if (response["stat"] == "ok") {
      data_user = response["data"];
      if (data_user["status"] == 1) {
        data_user_globle = data_user;
        if (data_user["role_id"] == adminRole) {

          Get.offAll(() => Home_Admin(), arguments: data_user);
        } else  if(data_user["role_id"]==teacherRole){

          Get.offAll(() => Show_Circle(), arguments: data_user);
        }
        else  if(data_user["role_id"]==committeeRole){
          Get.to(() => PromotionScreen(), arguments: data_user);
        }

      } else {
        mySnackbar("حسابك موقف", "تواصل مع الإدارة لحل المشكلة");
      }
    } else if (response["stat"]=="no"){
      mySnackbar("خطأ", "اسم المستخدم أو كلمة المرور خاطئة");
    }
    else if(response["stat"]=="erorr"){
      String errorMsg = response["msg"] ?? "اسم المستخدم أو كلمة المرور خاطئة";
      mySnackbar("خطأ", errorMsg);
    }
  }

  Future<void> select_data_Student() async {
    if (isLoading.value) return; // منع الطلبات المتكررة
    if (usernameController.text.trim().isEmpty || passwordController.text.isEmpty) {
      mySnackbar("تنبيه", "ادخل البيانات المطلوبة", type: "y");
      return;
    }

    final response = await handleRequest<dynamic>(
      isLoading: isLoading,
      loadingMessage: "جاري تسجيل الدخول...",
      useDialog: false,
      immediateLoading: true,
      action: () async {
        await del();
        return await postData(Linkapi.select_data_student, {
          "name_student": usernameController.text.trim(),
          "password": passwordController.text.trim(),
        });
      },
    );

    if (response == null) return;
    if (response is! Map) {
      mySnackbar("خطأ", "فشل الاتصال بالخادم");
      return;
    }

    if (response["stat"] == "ok") {
      data_user = response["data"];
      Get.offAll(() => StudentPage(), arguments: data_user);
    }  else if (response["stat"]=="no"){
      mySnackbar("خطأ", "اسم المستخدم أو كلمة المرور خاطئة");
    }
    else if(response["stat"]=="erorr"){
      String errorMsg = response["msg"] ?? "اسم المستخدم أو كلمة المرور خاطئة";
      mySnackbar("خطأ", errorMsg);
    }
  }
}
