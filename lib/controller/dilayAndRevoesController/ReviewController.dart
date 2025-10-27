import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../api/LinkApi.dart';
import '../../api/apiFunction.dart';
import '../../constants/function.dart';

class ReviewController extends GetxController{

  var to_id_aya = Rx<int?>(null);
  var toSoura = Rxn<Map<String, dynamic>>();

  TextEditingController markController=TextEditingController();



  var student;
  var dataLastReview = Rxn<Map<String, dynamic>>();

  @override
  void onInit() {
    student=Get.arguments["student"];
    dataLastReview=Get.arguments["dataLastReview"];
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // استدعاء منفصل للطلبين - يعملان بشكل متوازي
      select_evaluations();
      select_fromId_soura_with_to_soura();
    },);
    super.onInit();
  }





  RxList<Map<String, dynamic>> dataEvaluations = <Map<String, dynamic>>[].obs;
  RxnInt selectedEvaluations = RxnInt(null);

  Future select_evaluations() async {
    final res = await handleRequest<dynamic>(
      isLoading: RxBool(false),
      useDialog: false,
      // loadingMessage: "جاري تحميل التقييمات...",
      action: () async {
        return await postData(Linkapi.select_evaluations, {});
      },
    );

    if (res == null) return;
    if (res is! Map) {
      mySnackbar("خطأ", "فشل الاتصال بالخادم");
      return;
    }

    if (res["stat"] == "ok") {
      dataEvaluations.assignAll(List<Map<String,dynamic>>.from(res["data"]));
    } else {
      String errorMsg = res["msg"] ?? "خطأ في جلب التقييمات";
      mySnackbar("خطأ", errorMsg);
    }
  }

  var datasoura = <Map<String, dynamic>>[].obs;

  Future select_fromId_soura_with_to_soura() async {
    final response = await handleRequest<dynamic>(
      isLoading: RxBool(false),
      loadingMessage: "جاري تحميل سور القرآن...",
      action: () async {
        return await postData(Linkapi.select_fromId_soura_with_to_soura, {
          "id_level": student["id_level"],
          "id_soura": dataLastReview.value!["to_id_soura"],
        });
      },
    );

    if (response == null) return;
    if (response is! Map) {
      mySnackbar("خطأ", "فشل الاتصال بالخادم");
      return;
    }

    if (response["stat"] == "ok") {
      datasoura.assignAll(List<Map<String, dynamic>>.from(response["data"]));
    } else if (response["stat"] == "no") {
      String errorMsg = response["msg"] ?? "لا يوجد سور";
      mySnackbar("تنبيه", errorMsg);
    } else {
      String errorMsg = response["msg"] ?? "خطأ في جلب السور";
      mySnackbar("خطأ", errorMsg);
    }
  }



  Future addReview()async{

    if(toSoura.value.isNull){
      mySnackbar("تنبية", "يجب تحديد سورة النهاية ");
      return;
    }
    if(to_id_aya.value.isNull){
      mySnackbar("تنبية", "يجب تحديد رقم  الاية سورة النهائية ");
      return;
    }

    if(dataLastReview.value?["to_id_soura"]==toSoura.value!["id_soura"] && dataLastReview.value?["to_id_aya"]>=to_id_aya.value){
      mySnackbar("قم بتحديد نظاق الايات بشكل صحيح ", "يجب ان يكون رقم ايه النهائة اكبر من البداية(ترتيب الايات ) ");
      return;
    }
    if(markController.text.isEmpty){
      mySnackbar("تنبية", "قم بادخال الدرجة");
      return;
    }
    if(selectedEvaluations.value.isNull) {
      mySnackbar("تنبية", "قم بادخال التقييم");
      return;
    }

    Map data = {
      "id_student": student["id_student"],
      "from_id_soura": dataLastReview.value?["to_id_soura"],
      "from_id_aya": dataLastReview.value?["to_id_aya"],
      "to_id_soura": toSoura.value!["id_soura"],
      "to_id_aya": to_id_aya.value,
      "id_user": student["id_user"],
      "id_circle": student["id_circle"],
      "mark": markController.text,
      "id_evaluation": selectedEvaluations.value,
    };

    final res = await handleRequest<dynamic>(
      isLoading: RxBool(false),
      loadingMessage: "جاري حفظ المراجعة...",
      defaultErrorTitle: "لم يتم حفظ المراجعة",
      action: () async {
        await del();
        return await postData(Linkapi.addReview, data);
      },
    );

    if (res == null) return;
    if (res is! Map) {
      mySnackbar("خطأ", "فشل الاتصال بالخادم");
      return;
    }

    if (res["stat"] == "ok") {
      Get.back();
      mySnackbar("نجاح", "تم الإضافة بنجاح", type: "g");
    } else {
      String errorMsg = res["msg"] ?? "حصل خطأ أثناء الحفظ";
      mySnackbar("خطأ", errorMsg);
    }
  }

}