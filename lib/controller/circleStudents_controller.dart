import 'package:get/get.dart';
import '../api/LinkApi.dart';
import '../api/apiFunction.dart';
import '../constants/function.dart';

class CircleStudentsController extends GetxController {
  var students = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var circleData = <String, dynamic>{};

  @override
  void onInit() {
    super.onInit();
    circleData = Get.arguments ?? {};
    if (circleData.isNotEmpty) {
      getStudentsForCircle();
    }
  }

  Future<void> getStudentsForCircle() async {
    if (isLoading.value) return;
    
    isLoading.value = true;
    
    try {
      final res = await postData(Linkapi.getstudents, {
        "id_circle": circleData["id_circle"],
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
        students.value = List<Map<String, dynamic>>.from(res["data"]);
      } else if (res["stat"] == "no") {
        students.clear();
        mySnackbar("تنبيه", "لا يوجد طلاب في هذه الحلقة", type: "y");
      } else {
        mySnackbar("خطأ", res["msg"] ?? "حدث خطأ أثناء جلب الطلاب");
      }
    } catch (e) {
      print('❌ خطأ في جلب الطلاب: $e');
      mySnackbar("خطأ", "حدث خطأ أثناء جلب الطلاب");
    } finally {
      isLoading.value = false;
    }
  }
}
