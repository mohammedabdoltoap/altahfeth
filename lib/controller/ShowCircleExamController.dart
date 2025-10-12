import 'package:get/get.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../api/LinkApi.dart';
import '../api/apiFunction.dart';
import '../constants/function.dart';
import '../constants/loadingWidget.dart';


class ShowCircleExamController extends GetxController{

  var dataArg;
  @override
  void onInit() {
    dataArg=Get.arguments;
    print("dataArg=============${dataArg}");
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      select_circle_for_center();
    },);
  }


  RxList<Map<String, dynamic>> data_circle = <Map<String, dynamic>>[].obs;

  Future<void> select_circle_for_center() async {
    showLoading(message: " تحميل الحلقات.");
    await del();
    var res = await postData(Linkapi.select_circle_for_center, {"id_user": dataArg["id_user"]});
    hideLoading();
    if (res["stat"] == "ok") {
      data_circle.assignAll(List<Map<String, dynamic>>.from(res["data"]));

    } else if(res["stat"]=="no") {
      mySnackbar("حصل خطأ", "لايوجد لديك حلقات مسوول عنها");
    }
    else if(res["stat"]=="error"){
      mySnackbar("حصل خطأ", "${res["msg"]}");
    }
    else{
      mySnackbar("حصل خطأ", "حاول لاحقا");

    }

  }

}