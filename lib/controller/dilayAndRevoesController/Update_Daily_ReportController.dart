import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../api/LinkApi.dart';
import '../../api/apiFunction.dart';
import '../../constants/function.dart';
import '../../constants/loadingWidget.dart';

class Update_Daily_ReportController extends GetxController{
  @override
  void onInit() {
    dataArg_Student=Get.arguments["student"];
    dataArglastDailyReport=Get.arguments["lastDailyReport"];

    WidgetsBinding.instance.addPostFrameCallback((_) {
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

showLoading();
  await  del();
   await select_evaluations();
    var response = await postData(Linkapi.select_fromId_soura_with_to_soura, {
      "id_level":dataArg_Student["id_level"],
      "id_soura":dataArglastDailyReport.value!["from_id_soura"],
    });
    hideLoading();
    if (response["stat"] == "ok") {
      datasoura.assignAll(List<Map<String, dynamic>>.from(response["data"]));
      toSoura.value = datasoura.firstWhere(
            (soura) => soura["id_soura"].toString() == dataArglastDailyReport.value?["to_id_soura"].toString(),
        orElse: () => {},
      );
      to_id_aya.value = int.tryParse(dataArglastDailyReport.value?["to_id_aya"].toString() ?? "");

    } else {
      mySnackbar("تنبية","حصل خطا اثناء جلب البيانات");
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

    showLoading();
    await del();
    var res = await postData(Linkapi.updateDailyReport, data);
    hideLoading();

    if (res["stat"] == "ok") {
      // 🔹 لو كانت نفس القيم القديمة
      if (res["msg"] == "no_changes") {
        Get.back();
        mySnackbar("تم التعديل", "لم يحدث أي تغيير، البيانات كما هي", type: "i");
      } else {
        // 🔹 تم التعديل فعليًا
        Get.back();
        mySnackbar("تم التعديل", "تم التعديل بنجاح", type: "g");
      }
    }
    else if (res["stat"] == "not_found") {
      mySnackbar("تنبيه", "السجل غير موجود، تحقق من البيانات");
    }
    else {
      mySnackbar("تنبيه", "حصل خطأ أثناء التعديل، حاول مرة أخرى");
    }
  }

  RxList<Map<String,dynamic>> dataEvaluations=<Map<String,dynamic>>[].obs;
  RxnInt selectedEvaluations=RxnInt(null);
  Future select_evaluations()async {
    var res = await postData(Linkapi.select_evaluations, {});
    dataEvaluations.assignAll(RxList<Map<String, dynamic>>.from(checkApi(res)));
    selectedEvaluations.value = (dataEvaluations.firstWhere((e) =>
          e["id_evaluation"] == dataArglastDailyReport.value?["id_evaluation"],
          orElse: () => {},
        )["id_evaluation"]);
  }



}