import 'package:get/get.dart';
import '../api/LinkApi.dart';
import '../api/apiFunction.dart';
import '../constants/function.dart';

class CirclesController extends GetxController {
  var circles = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var dataArg;

  @override
  void onInit() {
    super.onInit();
    dataArg = Get.arguments;
    fetchCircles();
  }

  Future<void> fetchCircles() async {
    final response = await handleRequest<dynamic>(
      isLoading: isLoading,
      loadingMessage: "جاري تحميل الحلقات...",
      useDialog: true,
      immediateLoading: true,
      action: () async {
        return await postData(Linkapi.get_circle, {
          "id_user": dataArg["id_user"]
        });
      },
    );

    if (response == null) return;
    
    if (response is! Map) {
      mySnackbar("خطأ", "فشل الاتصال بالخادم");
      return;
    }

    if (response["stat"] == "ok") {
      circles.assignAll(List<Map<String, dynamic>>.from(response["data"]));
    } else {
      String errorMsg = response["msg"] ?? "تعذّر تحميل الحلقات";
      mySnackbar("خطأ", errorMsg);
    }
  }

  void refreshCircles() {
    fetchCircles();
  }
}
