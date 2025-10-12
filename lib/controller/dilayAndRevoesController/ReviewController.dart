import 'package:get/get.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../api/LinkApi.dart';
import '../../api/apiFunction.dart';
import '../../constants/function.dart';
import '../../constants/loadingWidget.dart';


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
      select_fromId_soura_with_to_soura();
    },);
    super.onInit();
  }





  RxList<Map<String,dynamic>> dataEvaluations=<Map<String,dynamic>>[].obs;
  RxnInt selectedEvaluations=RxnInt(null);
  Future select_evaluations()async{
    var res=await postData(Linkapi.select_evaluations, {});
    dataEvaluations.assignAll(RxList<Map<String,dynamic>>.from(checkApi(res,massge: "خطا في جلب التقيميات")));

  }

  var datasoura = <Map<String, dynamic>>[].obs;

  Future select_fromId_soura_with_to_soura() async {

    showLoading();
    await del();
   await select_evaluations();
    var response = await postData(Linkapi.select_fromId_soura_with_to_soura, {
      "id_level":student["id_level"],
      "id_soura":dataLastReview.value!["to_id_soura"],
    });
    hideLoading();
    if (response["stat"] == "ok") {
      datasoura.assignAll(List<Map<String, dynamic>>.from(response["data"]));


    } else {
      mySnackbar("خطا اثناء جلب السور", "datasoura");

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
      "mark":markController.text,
      "id_evaluation":selectedEvaluations.value
    };
    showLoading();
    await del();


    var res=await postData(Linkapi.addReview, data);
    hideLoading();
    if(res["stat"]=="ok"){
      Get.back();
      mySnackbar("نجاح", "تم الاضافة بنجاح",type: "g");
    }
    else{
      mySnackbar("تحذير", "حصل خطا ");
    }





  }

}