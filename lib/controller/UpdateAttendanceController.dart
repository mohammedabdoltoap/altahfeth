import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../api/LinkApi.dart';
import '../api/apiFunction.dart';
import '../constants/function.dart';
import '../constants/loadingWidget.dart';
import '../constants/myreport.dart';


class UpdateAttendanceController extends GetxController{

  var data_Arg;
  @override
  void onInit() {
    data_Arg=Get.arguments;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      select_attendance();
    },);
  }
  RxList<Map<String,dynamic>> students=<Map<String,dynamic>>[].obs;
  RxList<Map<String, dynamic>> filteredStudents = <Map<String, dynamic>>[].obs;
  RxString searchQuery = ''.obs;

  Future select_attendance()async{

    DateTime selectedDate = DateTime.now(); // أو التاريخ اللي تختاره
    String formattedDate = "${selectedDate.year}-${selectedDate.month.toString().padLeft(2,'0')}-${selectedDate.day.toString().padLeft(2,'0')}";

    print("formattedDate=${formattedDate}");
    showLoading();
    await del();

    var res=await postData(Linkapi.select_attendance, {
      "date":formattedDate,
      "id_circle":data_Arg["id_circle"],
    });
    hideLoading();
    if(res["stat"]=="ok"){
      students.assignAll(List<Map<String,dynamic>>.from(res["data"]));
      filteredStudents.assignAll(students);

    }

  }

  void filterStudents(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      filteredStudents.assignAll(students);
    } else {
      filteredStudents.assignAll(students.where((student) =>
          student['name_student'].toLowerCase().contains(query.toLowerCase())));
    }
  }


  Future updateAttendance()async{


    for(int i=0; i<students.length;i++){
      students[i]["id_user"]=data_Arg["id_user"];
      students[i]["id_circle"]=data_Arg["id_circle"];
      if(students[i]["status"]==true)
        students[i]["status"]=1;
      else
        students[i]["status"]=0;
    }

    print("students==============${students}");
    showLoading();
    await del();
    var res=await postData(Linkapi.updateAttendance, {"students":students});
    hideLoading();
    if(res["stat"]=="ok"){
      Get.back();
      mySnackbar("تم التعديل بنجاح", "تم التعديل",type: "g");
    }
    else if(res["stat"]=="no"){
      Get.back();

      print(res["failed_students"]);
      mySnackbar("حدث خطا اثناء التعديل", "لم يتم التعديل");
    }

  }

}