import 'package:althfeth/api/LinkApi.dart';
import 'package:althfeth/api/apiFunction.dart';
import 'package:althfeth/constants/color.dart';
import 'package:althfeth/constants/function.dart';
import 'package:althfeth/constants/loadingWidget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
            return StudentCard(
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






class StudentCard extends StatelessWidget {
  final String studentName;
  final VoidCallback onAddGrades;

  const StudentCard({
    Key? key,
    required this.studentName,
    required this.onAddGrades,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shadowColor: Colors.grey.withOpacity(0.3),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onAddGrades,
        splashColor: Colors.teal.withOpacity(0.2),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.teal.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // اسم الطالب
              Expanded(
                child: Text(
                  studentName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade800,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // زر إضافة الدرجات
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.teal.shade100,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.teal.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: onAddGrades,
                  icon: Icon(
                    Icons.add_circle_outline,
                    color: Colors.teal.shade700,
                    size: 32,
                  ),
                  tooltip: 'إضافة درجات',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}




class StudentsListController extends GetxController{
  Add_VisitController add_visitController=Get.put(Add_VisitController());

  var dataVisits;
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
    showLoading();
   await del() ;
    var res=await postData(Linkapi.getstudents, {"id_circle":dataVisits["id_circle"]});
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