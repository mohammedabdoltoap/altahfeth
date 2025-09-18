import 'dart:convert';

import 'package:althfeth/api/LinkApi.dart';
import 'package:althfeth/api/apiFunction.dart';
import 'package:get/get.dart';

class HomeCont extends GetxController {
  var dataArg;

  @override
  void onInit() {
    dataArg = Get.arguments;
    get_circle_and_students();
  }

  var data_circle;
  // var data_students;
  RxList<Map<String, dynamic>> students = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> filteredStudents = <Map<String, dynamic>>[].obs;
  RxString searchQuery = ''.obs;
  RxBool isLoding_get_circle_and_students=false.obs;
 Future get_circle_and_students() async {
   isLoding_get_circle_and_students.value=true;
   await Future.delayed(Duration(seconds: 2));

    var res=await postData(Linkapi.get_circle_and_students, {
      "id_user":dataArg["id_user"]
    });
    if(res["stat"]=="ok")
      {
        students=RxList<Map<String,dynamic>>.from(res["students"]);
        filteredStudents.assignAll(students);
        data_circle=res["circle"];

      }
    else{
     print("object");
    }
    isLoding_get_circle_and_students.value=false;

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

  void addStudent(Map<String, dynamic> student) {
    students.add(student);
    filterStudents(searchQuery.value);
  }

  void editStudent(int id, Map<String, dynamic> updatedStudent) {
    int index = students.indexWhere((s) => s['id_student'] == id);
    if (index != -1) {
      students[index] = updatedStudent;
      filterStudents(searchQuery.value);
    }
  }

  void deleteStudent(int id) {
    students.removeWhere((s) => s['id_student'] == id);
    filterStudents(searchQuery.value);
  }

  void addReport(int id) {
    print("إضافة تقرير للطالب: $id");
  }


}

