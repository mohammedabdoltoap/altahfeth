import 'package:get/get.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../api/LinkApi.dart';
import '../api/apiFunction.dart';
import '../constants/function.dart';
import '../constants/loadingWidget.dart';

class ShowYearsController extends GetxController{

  var data_circle;
  @override
  void onInit() {
    data_circle=Get.arguments;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      select_years();
    },);
  }

  RxList<Map<String,dynamic>> dataYears=<Map<String,dynamic>>[].obs;
  RxList<Map<String,dynamic>> dataMonths=<Map<String,dynamic>>[].obs;

  Future select_years()async{
    var res=await postData(Linkapi.select_years, {});
    dataYears.assignAll(RxList<Map<String,dynamic>>.from(checkApi(res)));
  }
  Future select_visits(id_year)async{
    var res=await postData(Linkapi.select_visits, {"id_year":id_year});
    print("res=======${res}");
    dataMonths.assignAll(RxList<Map<String,dynamic>>.from(checkApi(res)));
  }




}

