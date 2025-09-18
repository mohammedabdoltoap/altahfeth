import 'package:althfeth/api/LinkApi.dart';
import 'package:althfeth/api/apiFunction.dart';
import 'package:althfeth/constants/function.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../view/screen/home.dart';
class LoginController extends GetxController {
  var isLoading = false.obs;
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  var data_user;


    Future select_data_user()async {
      if (passwordController.text.isNotEmpty &&
          usernameController.text.isNotEmpty) {
        isLoading.value = true;
        // await Future.delayed(Duration(seconds: 2));
        var response = await postData(Linkapi.select_users, {
          "username": usernameController.text,
          "password": passwordController.text,
        });
        if (response["stat"] == "ok") {
          data_user = response["data"];
          // print(data_user);
        Get.to(() => Home(),arguments: data_user);
        }
        else {
          mySnackbar("تحذير", " اعد ادخال البياتات  خطا");
        }
      } else{
        mySnackbar("تنبية", "ادخل البيانات المطلوبه",type: "y");
      }
      isLoading.value = false;

    }
}
