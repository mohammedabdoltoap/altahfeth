import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../api/LinkApi.dart';
import '../api/apiFunction.dart';
import '../constants/function.dart';

class Show_CircleController extends GetxController {
  var dataArg;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    dataArg = Get.arguments;

    // نخلي استدعاء get_circle بعد ما يخلص build الأول
    WidgetsBinding.instance.addPostFrameCallback((_) {
      get_circle();
    });
  }

  RxList<Map<String, dynamic>> data_circle = <Map<String, dynamic>>[].obs;

  Future<void> get_circle() async {
    if (isLoading.value) return;
    final res = await handleRequest<dynamic>(
      isLoading: isLoading,
      loadingMessage: "تحميل الحلقات...",
      useDialog: false,
      immediateLoading: true,
      action: () async {

        return await postData(Linkapi.get_circle, {"id_user": dataArg["id_user"]});
      },
    );

    if (res == null) return;
    if (res is! Map) {
      mySnackbar("خطأ", "فشل الاتصال بالخادم");
      return;
    }

    if (res["stat"] == "ok") {
      data_circle.assignAll(List<Map<String, dynamic>>.from(res["data"]));
    } else if(res["stat"]=="no") {
      String errorMsg = res["msg"] ?? "لا يوجد لديك حلقات حالياً";
      mySnackbar("تنبيه", errorMsg, type: "y");
    } else {
      String errorMsg = res["msg"] ?? "تعضر جلب الحلقات";
      mySnackbar("خطأ", errorMsg);
    }
  }


}
