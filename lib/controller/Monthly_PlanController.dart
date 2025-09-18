
import 'package:althfeth/constants/function.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../api/LinkApi.dart';
import '../api/apiFunction.dart';

class Monthly_PlanController extends GetxController {
  var dataArg;
  // البيانات الأصلية من API
  var data = <Map<String, dynamic>>[].obs;

  // قائمة السنوات المخزنة كـ RxList
  var years = <Map<String, dynamic>>[].obs;

  // قائمة الأشهر المخزنة كـ RxList (مرافقة للسنة المختارة)
  var months = <Map<String, dynamic>>[].obs;

  // السنة المختارة (id)
  var selectedYear = Rxn<int>();

  // الشهر المختار (id)
  var selectedMonth = Rxn<int>();
  var datasoura = <Map<String, dynamic>>[].obs;
  @override
  void onInit() {
    super.onInit();
    dataArg = Get.arguments;
    print(dataArg);
    select_fromId_soura_with_to_soura();
    // تحميل البيانات مرة واحدة
    selectYearsWithMonths();
    select_ids_month();
    // عند تغيير السنة، نحدّث قائمة الأشهر تلقائيًا
    ever(selectedYear, (_) {
      _updateMonths();
    });
  }

  List dataMonth=[];
 Future select_ids_month()async{

    var res=await postData(Linkapi.select_ids_month, {"id_student":dataArg["id_student"]});
    if(res["stat"]=="ok") {
      dataMonth.addAll(res["data"]);

      }
  }

  // تحديث قائمة السنوات بعد تحميل البيانات
  void _updateYears() {
    final added = <int>{};
    years.value = data.where((e) {
      if (!added.contains(e['id_year'])) {
        added.add(e['id_year']);
        return true;
      }
      return false;
    }).map((e) => {
      'id_year': e['id_year'],
      'name_year': e['name_year'],
    }).toList();
  }

  // تحديث قائمة الأشهر حسب السنة المختارة
  void _updateMonths() {
    final y = selectedYear.value;
    if (y == null) {
      months.clear();
      return;
    }

    months.value = data
        .where((e) => e['id_year'] == y)
        .map((e) => {
      'id_month': e['id_month'],
      'name_month': e['name_month'],
      'real_days':e["real_days"],
    }).toList();
  }

  // تحميل البيانات من API
  Future<void> selectYearsWithMonths() async {
    try {
      var res = await postData(Linkapi.selectYearsWithMonths, {});
      if (res["stat"] == "ok") {
        data.value = List<Map<String, dynamic>>.from(res["data"]);

        // بعد تحميل البيانات نحدّث قائمة السنوات
        _updateYears();
        // لو هناك سنة مختارة مسبقًا، نحدّث الأشهر
        _updateMonths();

        print("تم تحميل البيانات: ${data.length} سجل");
      } else {
        print("خطأ في جلب البيانات من API");
      }
    } catch (e) {
      print("Exception while fetching data: $e");
    }
  }

  var selectedDate = DateTime.now().obs;
  // 🔹 المتغيرات لمتابعة السور المختارة
  var fromSoura = Rxn<Map<String, dynamic>>();
  var start_ayat = Rx<int?>(null);
  var end_ayat = Rx<int?>(null);

  var toSoura = Rxn<Map<String, dynamic>>();


  Future select_fromId_soura_with_to_soura() async {
    var response = await postData(Linkapi.select_fromId_soura_with_to_soura, {
      "id_level": dataArg["id_level"]
    });
    if (response["stat"] == "ok") {
      datasoura.assignAll(List<Map<String, dynamic>>.from(response["data"]));
    } else {
      print("erorrrrrrrrr");
    }
  }


  RxBool isLoding_addPlan=false.obs;
  Future addPlan()async{
    for(int i=0; i <dataMonth.length;i++){
      if(dataMonth[i]==selectedMonth.value) {
            mySnackbar("لايمكن اضافة اكثر من خطه بنفس الشهر", "قد تم اضافة خطة لهذا الطالب مسبقا لنفس هذا الشهر ");
          return;
      }


    }

    Map data={
      "id_student":dataArg["id_student"],
      "start_id_soura":fromSoura.value!["id_soura"],
      "start_ayat":start_ayat.value,
      "end_id_soura":toSoura.value!["id_soura"],
      "end_ayat":end_ayat.value,
      "amount_value":"0",
      "id_user":dataArg["id_user"],
      "id_month":selectedMonth.value,
    };
    isLoding_addPlan.value=true;
   await Future.delayed(Duration(seconds: 2));
    var res=await postData(Linkapi.addPlan, data);
    if(res["stat"]=="ok"){
      Get.back();
      mySnackbar("تم الاضاف","تم الاضافة بنجاح", type: "g");
    }
    else{
      mySnackbar("تنبية!","حصل خطا اثناء الاضافة");
    }
    isLoding_addPlan.value=false;

  }

}
