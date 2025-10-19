import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../api/LinkApi.dart';
import '../api/apiFunction.dart';
import '../constants/function.dart';
import '../constants/loadingWidget.dart';

class Show_CircleController extends GetxController {
  var dataArg;

  @override
  void onInit() {
    super.onInit();
    dataArg = Get.arguments;

    // نخلي استدعاء get_circle بعد ما يخلص build الأول
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if(dataArg["role"]==4) {
        get_circle();
      }
        if(dataArg["role"]==2) {
        select_circle_for_center();
      }
    });
  }

  RxList<Map<String, dynamic>> data_circle = <Map<String, dynamic>>[].obs;

  Future<void> get_circle() async {

    showLoading(message: " تحميل الحلقات.");
    await del();
    print("dataArg========${dataArg}");
    var res = await postData(Linkapi.get_circle, {"id_user": dataArg["id_user"]});
    hideLoading();
    if (res["stat"] == "ok") {
      data_circle.assignAll(List<Map<String, dynamic>>.from(res["data"]));

    } else {
      mySnackbar("حصل خطأ", "تواصل مع الادارة");
    }

  }

  Future<void> select_circle_for_center() async {

    showLoading(message: " تحميل الحلقات.");
    await del();
    var res = await postData(Linkapi.select_circle_for_center, {"responsible_user_id": dataArg["id_user"]});
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
