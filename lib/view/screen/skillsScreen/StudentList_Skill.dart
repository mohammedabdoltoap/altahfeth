import 'package:althfeth/api/LinkApi.dart';
import 'package:althfeth/api/apiFunction.dart';
import 'package:althfeth/constants/function.dart';
import 'package:althfeth/constants/inline_loading.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../constants/SmolleStudentCard.dart';
import '../../../../controller/visitAndExamController/Add_VisitController.dart';
import '../../../constants/ErrorRetryWidget.dart';
import 'Student_Skills.dart';

class StudentList_Skill extends StatelessWidget {
  final StudentList_SkillController controller = Get.put(StudentList_SkillController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("المهارات "),
        centerTitle: true,
        toolbarHeight: 88,
      ),
      body: Obx(() {

        if (controller.isLodingStudent.value)
          return InlineLoading(message: "تحميل اسماء الطلاب",);



        if (controller.students.isEmpty) {

          if(controller.noHasStudent.value)
            return const Center(
            child: Text(
              "لايوجد طلاب في الحلقة ",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );

          return ErrorRetryWidget(
            onRetry: () => controller.getstudents(),
          );




        }

        // ════════════════════════════════════════════════════════════════
        // 🎓 مثال آخر لاستخدام ListView.builder (for loop ذكي)
        // ════════════════════════════════════════════════════════════════
        // هنا نعرض قائمة الطلاب باستخدام ListView.builder
        // 
        // 🔄 تخيل لو كتبناها بـ for عادية:
        //   List<Widget> studentCards = [];
        //   for(int i = 0; i < students.length; i++) {
        //     studentCards.add(SmolleStudentCard(...));
        //   }
        //   return ListView(children: studentCards);
        //
        // ⚡ المشكلة: لو عندك 500 طالب، راح يرسم 500 بطاقة مرة وحدة!
        // ✅ الحل: ListView.builder يرسم فقط البطاقات المرئية (Lazy Loading)
        // ════════════════════════════════════════════════════════════════
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: controller.students.length, // 🔢 عدد الطلاب
          itemBuilder: (context, index) {
            // 📌 نحصل على بيانات الطالب رقم index
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
  RxBool isLodingStudent=false.obs;
  RxBool noHasStudent=false.obs;
  Future getstudents()async{

    final res = await handleRequest<dynamic>(
      isLoading: isLodingStudent,
      loadingMessage: "جاري تحميل الطلاب...",
      useDialog: false,
      immediateLoading: true,

      action: () async {
    
        return await postData(Linkapi.getstudents, {"id_circle":data["id_circle"]});
      },
    );

    if(res==null)return;

    if(res is! Map )
      {
        mySnackbar("تنبية", "فشل الاتصال");
        return ;
      }
    if(res["stat"]=="ok"){
      students.assignAll(List<Map<String,dynamic>>.from(res["data"]));
    }else if(res["stat"]=="erorr"){
      mySnackbar("تنبية", "${res["msg"]}");
    }else if(res["stat"]=="no"){
      students.clear();
      noHasStudent.value=true;
      mySnackbar("تنبية", "لايوجد بيانات ");
    }else{
      mySnackbar("تنبية", "حصل خطا تاكد من الاتصال");
    }
  }


}