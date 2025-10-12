import 'package:althfeth/constants/function.dart';
import 'package:althfeth/controller/home_cont.dart';
import 'package:althfeth/view/screen/dilaysAndRevoews/review.dart';
import 'package:althfeth/view/screen/studentScreen/update_Student.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../globals.dart';
import '../widget/home/appBarHome.dart';
import '../widget/home/appDrawer.dart';
import '../widget/home/cardStudent.dart';
import '../widget/home/searchAndButtonAddStudent.dart';
import 'attendance.dart';
import 'dilaysAndRevoews/daily_report.dart';
import 'dilaysAndRevoews/update_daily_report.dart';
import 'dilaysAndRevoews/update_review.dart';



class Home extends StatelessWidget {
  HomeCont controller = Get.put(HomeCont());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBarHome(),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: RefreshIndicator(
          onRefresh: () => controller.getstudents(),
          child: Obx(() {
            return controller.loding_get_circle_and_students.value?SizedBox():ListView.builder(
              itemCount: controller.filteredStudents.length + 1,

              itemBuilder: (context, index) {
                // أول عنصر = شريط البحث
                if (index == 0) {
                  return controller.filteredStudents.isNotEmpty? Column(
                    children: [
                      SearchAndButtonAddStudent(),
                    ],
                  ):Column(
                        children: [
                          SearchAndButtonAddStudent(),
                          SizedBox(height: 20),
                          Center(child: Text("لا يوجد طلاب بالحلقة",style: TextStyle(fontSize: 18),)),
                        ],
                      );
                }


                // بقية العناصر = الطلاب
                final student = controller.filteredStudents[index - 1];
                return CardStudent(
                  student: student,
                  absence: (){
                    print(student);
                    controller.select_absence_report(student["id_student"],student["name_student"]);

                  },
                  reviewReports: (){
                    controller.select_review_report(student["id_student"]);

                  },
                  dailyReports: (){
                    controller.select_daily_report(student["id_student"]);
                  },
                  add_rep: () async {

                    if(!holidayData["is_holiday"])
                   {
                     await controller.getLastDailyReport(student["id_student"], student["id_level"]);
                    student["id_user"] = controller.dataArg["id_user"];
                    if (controller.statLastDailyReport.value == 1) {
                      Get.to(() => Daily_Report(), arguments: {
                        "student": student,
                        "lastDailyReport": controller.lastDailyReport,
                      });
                    }
                    if (controller.statLastDailyReport.value == 2) {
                      bool? confirm = await showConfirmDialog(
                        context: context,
                        title: "تنبيه",
                        message:
                        "لقد تم اضافة تسميع لهذا الطالب اليوم ولايمكن اضافة اكثر من تسميع. هل تريد تعديل وتجاوز الاول؟",
                      );
                      if (confirm == true) {
                        Get.to(() => Update_Daily_Report(), arguments: {
                          "student": student,
                          "lastDailyReport": controller.lastDailyReport,
                        });
                      }
                    }
                   }else{
                      mySnackbar("تنبية", "اجازة بمناسبة${holidayData["reason"]}");
                    }
                  },
                  review: () async {

                    if(!holidayData["is_holiday"]){
                    await controller.getLastReview(student["id_student"],student["id_level"]);
                    if (controller.stat_getLastReview == 1) {
                      bool? confirm = await showConfirmDialog(
                        context: context,
                        message:
                        "لقد تمت إضافة مراجعة لهذا اليوم بالفعل، ولا يمكن إدخال أكثر من مراجعة في نفس اليوم. هل ترغب في تعديل المراجعة الحالية؟",
                      );
                      if (confirm == true) {
                        Get.to(() => Update_Review(), arguments: {
                          "dataLastReview": controller.dataLastReview,
                          "student": student
                        });
                      }
                    } else if (controller.stat_getLastReview == 2) {
                      student["id_user"] = controller.dataArg["id_user"];
                      Get.to(() => Review(),arguments: {
                        "dataLastReview": controller.dataLastReview,
                        "student": student
                      });
                    } else if (controller.stat_getLastReview == 3) {
                      mySnackbar("تنبيه",
                          "يجب ان يكون للطالب تسميع مسبق قبل اضافة مراجعة ");
                      return;
                    } else {
                      mySnackbar("تنبيه", "حصل خطأ في الاتصال");
                    }
                  }
                    else{
                      mySnackbar("تنبية", "اجازة بمناسبة${holidayData["reason"]}");
                    }

                    },
                  updateData: (){

                    Get.to(()=>UpdateStudent(),arguments: student);

                  },
                );
              },
            );
          }),
        ),
      ),
    );
  }




}








