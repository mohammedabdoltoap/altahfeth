import 'package:get/get.dart';

import '../api/LinkApi.dart';
import '../api/apiFunction.dart';
import '../constants/function.dart';

class FirstPageExamStudentController extends GetxController {
  var dataCircle;

  @override
  void onInit() {
    dataCircle = Get.arguments;
    select_data_exam();
  }



  RxList<Map<String, dynamic>> students = <Map<String, dynamic>>[].obs;
  Map<String, dynamic> marks = {};

  Future select_data_exam() async {
    var res = await postData(Linkapi.select_data_exam, {
      "circle_id": dataCircle["id_circle"],
      "visit_id": dataCircle["id_visit"],
    });
    students.assignAll(RxList<Map<String, dynamic>>.from(checkApi(res)));
  }
  Future select_student_exam(student_id)async{
    var res = await postData(Linkapi.select_student_exam, {
      "student_id": student_id,
      "visit_id": dataCircle["id_visit"],
    });
    if(res["stat"]=="ok")
      marks=res["data"];

    print("marks===========${marks}");
  }



}
