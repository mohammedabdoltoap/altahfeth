import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../api/LinkApi.dart';
import '../api/apiFunction.dart';
import '../constants/function.dart';
import '../constants/loadingWidget.dart';

class AttendanceController extends GetxController{

  var dataArg;
  @override
  void onInit() {
    dataArg=Get.arguments;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      select_students_attendance();
    },);
  }

  RxList<Map<String, dynamic>> filteredStudents = <Map<String, dynamic>>[].obs;
  RxString searchQuery = ''.obs;

  RxList<Map<String,dynamic>> students=<Map<String,dynamic>>[].obs;

  Future select_students_attendance()async{

    showLoading();
    await del();
    var res=await postData(Linkapi.select_students_attendance, {"id_circle":dataArg["id_circle"]});
    hideLoading();
    if(res["stat"]=="ok")
    {
      students.assignAll(List<Map<String,dynamic>>.from(res["data"]));
      filteredStudents.assignAll(students);

    }
    else if(res["stat"]=="no"){
      mySnackbar("لايوجد طلاب بالحلفة ", "لايوجد بيانات");
    }
    else{
      mySnackbar("حصل خطا ", "حاول لاحقا");
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
  Future insertAttendance()async{
    for(int i=0; i<students.length;i++){
      students[i]["id_user"]=dataArg["id_user"];
      students[i]["id_circle"]=dataArg["id_circle"];
      if(students[i]["status"]==true)
        students[i]["status"]=1;
      else
        students[i]["status"]=0;
    }

    showLoading();
    await del();
    var res=await postData(Linkapi.insertAttendance, {"students": students});
    hideLoading();
    if(res["stat"]=="ok"){
      Get.back();
      mySnackbar("تم بنجاح", "تم تحضير الطلاب",type: "g");
    }
    else{
      mySnackbar("حصل خطا", "حاول مره اخرى لاحقا");
    }



  }
}