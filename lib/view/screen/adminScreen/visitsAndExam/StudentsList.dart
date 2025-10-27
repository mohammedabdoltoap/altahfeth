import 'package:althfeth/api/LinkApi.dart';
import 'package:althfeth/api/apiFunction.dart';
import 'package:althfeth/constants/color.dart';
import 'package:althfeth/constants/function.dart';
import 'package:althfeth/constants/loadingWidget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../constants/SmolleStudentCard.dart';
import '../../../../constants/inline_loading.dart';
import '../../../../controller/visitAndExamController/Add_VisitController.dart';
import 'ExamScreen.dart';

class StudentsList extends StatelessWidget {
  final StudentsListController controller = Get.put(StudentsListController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("قائمة الطلاب"),
        centerTitle: true,
        backgroundColor: primaryGreen, // primaryTeal
      ),
      body: Obx(() {
        if (controller.loadingStudents.value && controller.students.isEmpty) {
          return const InlineLoading(message: "جاري تحميل الطلاب...");
        }

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
                Map dataVistAndStudent={
                  "id_visit":controller.dataVisits["id_visit"],
                  "id_student":student["id_student"],
                  "id_user":controller.dataVisits["id_user"],
                };
                Get.to(()=>ExamScreen(),arguments: dataVistAndStudent);

              },
            );
          },
        );
      }),
    );
  }
}






class StudentsListController extends GetxController{
  Add_VisitController add_visitController=Get.put(Add_VisitController());

  var dataVisits;
  RxBool loadingStudents = false.obs;
  @override
  void onInit() {
    dataVisits=Get.arguments;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp)async {
      getstudents();

      add_visitController.select_visitsed();
      add_visitController.select_previous_visits();
    },);

  }

RxList<Map<String,dynamic>> students=<Map<String,dynamic>>[].obs;
  Future getstudents()async{
    if (loadingStudents.value) return;
    final res = await handleRequest<dynamic>(
      isLoading: loadingStudents,
      loadingMessage: "جاري تحميل الطلاب...",
      useDialog: true,
      immediateLoading: true,
      action: () async {
        await del();
        return await postData(Linkapi.getstudents, {"id_circle":dataVisits["id_circle"]});
      },
    );
    if (res == null) return;
    if (res is! Map) {
      mySnackbar("خطأ", "فشل الاتصال بالخادم");
      return;
    }
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