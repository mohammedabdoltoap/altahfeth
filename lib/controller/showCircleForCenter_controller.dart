import 'package:get/get.dart';
import '../api/LinkApi.dart';
import '../api/apiFunction.dart';
import '../constants/function.dart';

class ShowCircleForCenterController extends GetxController {
  var circles = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var centerData = <String, dynamic>{};

  @override
  void onInit() {
    super.onInit();
    centerData = Get.arguments ?? {};
    if (centerData.isNotEmpty) {
      getCirclesForCenter();
    }
  }

  Future<void> getCirclesForCenter() async {
    if (isLoading.value) return;
    
    isLoading.value = true;
    print("centerData===${centerData}");
    try {
      final res = await postData(Linkapi.select_circle_for_center, {
        "responsible_user_id": centerData["id_user"].toString(),
      });

      if (res == null) {
        mySnackbar("خطأ", "فشل الاتصال بالخادم");
        return;
      }

      if (res is! Map) {
        mySnackbar("خطأ", "رد غير صحيح من الخادم");
        return;
      }

      if (res["stat"] == "ok") {
        circles.value = List<Map<String, dynamic>>.from(res["data"]);
      } else if (res["stat"] == "no") {
        circles.clear();
        mySnackbar("تنبيه", "لا توجد حلقات لهذا المركز", type: "y");
      } else {
        mySnackbar("خطأ", res["msg"] ?? "حدث خطأ أثناء جلب الحلقات");
      }
    } catch (e) {
      print('❌ خطأ في جلب الحلقات: $e');
      mySnackbar("خطأ", "حدث خطأ أثناء جلب الحلقات");
    } finally {
      isLoading.value = false;
    }
  }
}
