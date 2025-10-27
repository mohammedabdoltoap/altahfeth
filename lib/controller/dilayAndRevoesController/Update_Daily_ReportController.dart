import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../api/LinkApi.dart';
import '../../api/apiFunction.dart';
import '../../constants/function.dart';

class Update_Daily_ReportController extends GetxController{
  @override
  void onInit() {
    dataArg_Student=Get.arguments["student"];
    dataArglastDailyReport=Get.arguments["lastDailyReport"];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // استدعاء منفصل للطلبين - يعملان بشكل متوازي
      select_evaluations();
      select_fromId_soura_with_to_soura();
      markController.text=dataArglastDailyReport.value?["mark"].toString() ?? "0";
    },);
  }
  var dataArg_Student;
  var dataArglastDailyReport = Rxn<Map<String, dynamic>>();

  TextEditingController markController=TextEditingController();



  var to_id_aya = Rx<int?>(null);
  var toSoura = Rxn<Map<String, dynamic>>();

  var datasoura = <Map<String, dynamic>>[].obs;
  Future select_fromId_soura_with_to_soura() async {
    final response = await handleRequest<dynamic>(
      isLoading: RxBool(false),
      loadingMessage: "جاري تحميل سور القرآن...",
      action: () async {
        return await postData(Linkapi.select_fromId_soura_with_to_soura, {
          "id_level": dataArg_Student["id_level"],
          "id_soura": dataArglastDailyReport.value!["from_id_soura"],
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
      toSoura.value = datasoura.firstWhere(
            (soura) => soura["id_soura"].toString() == dataArglastDailyReport.value?["to_id_soura"].toString(),
        orElse: () => {},
      );
      to_id_aya.value = int.tryParse(dataArglastDailyReport.value?["to_id_aya"].toString() ?? "");
    } else {
      String errorMsg = response["msg"] ?? "حصل خطأ في جلب البيانات";
      mySnackbar("خطأ", errorMsg);
    }
  }



  Future updateDailyReport() async {
    if (toSoura.value.isNull) {
      mySnackbar("تنبيه", "يجب تحديد نطاق النهاية");
      return;
    }
    if (to_id_aya.value.isNull) {
      mySnackbar("تنبيه", "يجب تحديد الآية النهائية");
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
      "id_daily_report": dataArglastDailyReport.value?["id_daily_report"],
      "to_id_soura": toSoura.value!["id_soura"],
      "to_id_aya": to_id_aya.value,
      "mark":markController.text,
      "id_evaluation":selectedEvaluations.value,
    };

    final res = await handleRequest<dynamic>(
      isLoading: RxBool(false),
      loadingMessage: "جاري حفظ التعديلات...",
      defaultErrorTitle: "لم يتم حفظ التعديلات",
      action: () async {
        await del();
        return await postData(Linkapi.updateDailyReport, data);
      },
    );

    if (res == null) return;
    if (res is! Map) {
      mySnackbar("خطأ", "فشل الاتصال بالخادم");
      return;
    }

    if (res["stat"] == "ok") {
      // 🔹 لو كانت نفس القيم القديمة
      if (res["msg"] == "no_changes") {
        Get.back();
        mySnackbar("تنبيه", "لم يحدث أي تغيير، البيانات كما هي", type: "y");
      } else {
        // 🔹 تم التعديل فعليًا
        Get.back();
        mySnackbar("نجاح", "تم التعديل بنجاح", type: "g");
      }
    } else {
      String errorMsg = res["msg"] ?? "حصل خطأ أثناء التعديل";
      mySnackbar("خطأ", errorMsg);
    }
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
      dataEvaluations.assignAll(List<Map<String, dynamic>>.from(res["data"]));
      selectedEvaluations.value = (dataEvaluations.firstWhere(
        (e) => e["id_evaluation"] == dataArglastDailyReport.value?["id_evaluation"],
        orElse: () => {},
      )["id_evaluation"]);
    } else {
      String errorMsg = res["msg"] ?? "خطأ في جلب التقييمات";
      mySnackbar("خطأ", errorMsg);
    }
  }
}