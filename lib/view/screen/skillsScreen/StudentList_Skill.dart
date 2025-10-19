import 'package:althfeth/api/LinkApi.dart';
import 'package:althfeth/api/apiFunction.dart';
import 'package:althfeth/constants/color.dart';
import 'package:althfeth/constants/function.dart';
import 'package:althfeth/constants/loadingWidget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../constants/SmolleStudentCard.dart';
import '../../../../controller/visitAndExamController/Add_VisitController.dart';
import 'Student_Skills.dart';

class StudentList_Skill extends StatelessWidget {
  final StudentList_SkillController controller = Get.put(StudentList_SkillController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("المهارات "),
        centerTitle: true,
        backgroundColor: primaryGreen, // primaryTeal
      ),
      body: Obx(() {
        if (controller.students.isEmpty) {
          return const Center(
            child: Text(
              "لا يوجد بيانات",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: controller.students.length,
          itemBuilder: (context, index) {
            final student = controller.students[index];
            return SmolleStudentCard(
              studentName: student["name_student"],
              onAddGrades: () {
                Map data={
                  "id_student":student["id_student"],
                  "id_user":controller.data["id_user"],
                };
                Get.to(()=>Student_Skills(),arguments: data);
              },
            );
          },
        );
      }),
    );
  }
}










class StudentList_SkillController extends GetxController{

  var data;
  @override
  void onInit() {
    data=Get.arguments;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp)async {
      getstudents();
    },);

  }

  RxList<Map<String,dynamic>> students=<Map<String,dynamic>>[].obs;
  Future getstudents()async{
    showLoading();
    await del() ;
    var res=await postData(Linkapi.getstudents, {"id_circle":data["id_circle"]});
    hideLoading();
    if(res["stat"]=="ok"){
      students.assignAll(List<Map<String,dynamic>>.from(res["data"]));
    }else if(res["stat"]=="erorr"){
      mySnackbar("تنبية", "${res["msg"]}");
    }else if(res["stat"]=="no"){
      mySnackbar("تنبية", "لايوجد بيانات ");
    }else{
      mySnackbar("تنبية", "حصل خطا تاكد من الاتصال");
    }


  }


}