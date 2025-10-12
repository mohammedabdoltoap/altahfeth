import 'package:althfeth/api/LinkApi.dart';
import 'package:althfeth/api/apiFunction.dart';
import 'package:althfeth/constants/function.dart';
import 'package:althfeth/view/screen/studentScreen/studentPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../constants/loadingWidget.dart';
import '../view/screen/home.dart';
import '../view/screen/show_circle.dart';
class LoginController extends GetxController {
  // var isLoading = false.obs;
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  var data_user;
  RxBool isStudent = false.obs;

    Future select_data_user()async {
      if (passwordController.text.isNotEmpty && usernameController.text.isNotEmpty) {

        showLoading();
       await del();
        var response = await postData(Linkapi.select_users, {
          "username": usernameController.text.trim(),
          "password": passwordController.text.trim(),
        });
        hideLoading();
        if (response["stat"] == "ok") {
          data_user = response["data"];
          if(data_user["status"]==1) { // Get.to(() => Home(),arguments: data_user);
            Get.to(() => Show_Circle(), arguments: data_user);
          }
          else{
          mySnackbar("حسابك موقف", "تواصل مع الادارة لحل المشكلة");
          }
        }
        else {
          mySnackbar("خطا", "الاسم او كلمة المرو خطا");
        }
      } else{
        mySnackbar("تنبية", "ادخل البيانات المطلوبه",type: "y");
      }

    }





  Future select_data_Student()async {
    if (passwordController.text.isNotEmpty && usernameController.text.isNotEmpty) {

      showLoading();
      await del();
      var response = await postData(Linkapi.select_data_student, {
        "name_student": usernameController.text,
        "password": passwordController.text,
      });
      hideLoading();
      if (response["stat"] == "ok") {
        data_user = response["data"];
        Get.to(()=>StudentPage(),arguments: data_user);

        }
      else {
        mySnackbar("خطا", "الاسم او كلمة المرو خطا");
      }
    } else{
      mySnackbar("تنبية", "ادخل البيانات المطلوبه",type: "y");
    }

  }


}
