import 'package:althfeth/constants/function.dart';
import 'package:althfeth/controller/home_cont.dart';
import 'package:althfeth/view/screen/dilaysAndRevoews/review.dart';
import 'package:althfeth/view/screen/studentScreen/update_Student.dart';
import 'package:althfeth/view/screen/user_attendance.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../globals.dart';
import '../widget/home/appDrawer.dart';
import '../widget/home/cardStudent.dart';
import '../widget/home/searchAndButtonAddStudent.dart';
import 'dilaysAndRevoews/daily_report.dart';
import 'dilaysAndRevoews/update_daily_report.dart';
import 'dilaysAndRevoews/update_review.dart';
import 'package:althfeth/constants/inline_loading.dart';
import 'studentScreen/StudentPlanReport.dart';


class Home extends StatelessWidget {
  HomeCont controller = Get.put(HomeCont());

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // منع الخروج المباشر
      onPopInvoked: (didPop) async {
        if (didPop) return;
        
        // عرض تنبيه التأكيد
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('تأكيد الخروج'),
            content: const Text('هل أنت متأكد من الخروج من التطبيق؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('خروج', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
        
        if (shouldExit == true && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        drawer: AppDrawer(),
        appBar: AppBar(
        centerTitle: true,
        toolbarHeight: 88,
        title: Column(
          children: [
            Text(
              controller.dataArg["name_circle"] ?? "",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "مرحباً ${controller.dataArg["username"] ?? ""}",
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            ),
          ],
        ),

      ),
      body:
        Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.grey[50]!,
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: RefreshIndicator(
                  onRefresh: () => controller.getstudents(),
                  child: Obx(() {
                  // حالة التحميل داخل الصفحة
                  if (controller.loding_get_circle_and_students.value && controller.filteredStudents.isEmpty) {
                    return const InlineLoading(message: "جاري تحميل الطلاب...");
                  }

                  return ListView.builder(
                    itemCount: controller.filteredStudents.length + 1,

                    itemBuilder: (context, index) {
                // أول عنصر = شريط البحث + حالة فارغة
                if (index == 0) {
                  if (controller.filteredStudents.isNotEmpty) {
                    return Column(
                      children: [
                        // إحصائيات سريعة
                        _buildQuickStats(),
                        const SizedBox(height: 16),
                        SearchAndButtonAddStudent(controller: controller.textEditingController),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                         SearchAndButtonAddStudent(controller: controller.textEditingController),
                         const SizedBox(height: 20),
                        if (controller.students.isEmpty) ...[
                          Center(
                            child: Column(
                              children: [
                                const Text("لا يوجد طلاب بالحلقة", style: TextStyle(fontSize: 18)),
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: 220,
                                  child: ElevatedButton(
                                    onPressed: () => controller.getstudents(),
                                    child: const Text("إعادة المحاولة"),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else if (controller.searchQuery.value.isNotEmpty) ...[
                          Center(
                            child: Column(
                              children: [
                                const Text("لا توجد نتائج مطابقة للبحث", style: TextStyle(fontSize: 18)),
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: 220,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      controller.textEditingController.clear();
                                      controller.filterStudents("");
                                      FocusScope.of(context).unfocus();
                                    },
                                    child: const Text("مسح البحث"),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    );
                  }
                }


                // بقية العناصر = الطلاب
                final student = controller.filteredStudents[index - 1];
                  return CardStudent(
                  student: student,
                  absence: (){
                    controller.select_absence_report(student["id_student"],student["name_student"]);

                  },
                  reviewReports: (){
                    controller.select_review_report(student["id_student"]);

                  },
                  dailyReports: (){
                    controller.select_daily_report(student["id_student"]);
                  },
                  add_rep: () async {
                    if(!holidayData["is_holiday"]) {

                      // التحقق من تسجيل حضور الأستاذ نفسه أولاً
                      await controller.check_teacher_attendance();
                      
                      if (controller.statTeacherAttendance.value == null) {
                        Navigator.pop(context); // إغلاق dialog
                        mySnackbar("تنبيه", "حدث خطأ في التحقق من حضورك");
                        return;
                      }
                      
                      if (controller.statTeacherAttendance.value == 0) {

                        // عرض dialog للانتقال لصفحة الحضور
                        bool? goToAttendance = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("تسجيل الحضور مطلوب"),
                            content: const Text("يجب عليك تسجيل حضورك أولاً قبل تسجيل التسميع.\n\nهل تريد الانتقال إلى صفحة تسجيل الحضور والانصراف؟"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("إلغاء"),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text("الانتقال"),
                              ),
                            ],
                          ),
                        );
                        
                        if (goToAttendance == true) {
                          Get.to(() => User_Attendance(), arguments: controller.dataArg);
                        }
                        return;
                      }
                      
                      // إذا تم تسجيل الحضور، تابع العملية
                      await controller.getLastDailyReport(student["id_student"], student["id_level"]);

                      final studentArgs = {
                        ...student,
                        "id_user": controller.dataArg["id_user"],
                      };
                      if (controller.statLastDailyReport.value == 1) {
                        Get.to(() => Daily_Report(), arguments: {
                          "student": studentArgs,
                          "lastDailyReport": controller.lastDailyReport,
                        });

                      }
                      if (controller.statLastDailyReport.value == 2) {
                        bool? confirm = await showConfirmDialog(
                          context: context,
                          title: "تنبيه",
                          message: "لقد تم اضافة تسميع لهذا الطالب اليوم ولايمكن اضافة اكثر من تسميع. هل تريد تعديل وتجاوز الاول؟",
                        );
                        if (confirm == true) {
                          Get.to(() => Update_Daily_Report(), arguments: {
                            "student": studentArgs,
                            "lastDailyReport": controller.lastDailyReport,
                          });
                        }
                      }
                    } else {
                      mySnackbar("تنبية", "اجازة بمناسبة${holidayData["reason"]}");
                    }
                  },
                  review: () async {
                    if(!holidayData["is_holiday"]) {
                      // التحقق من تسجيل حضور الأستاذ نفسه أولاً
                      await controller.check_teacher_attendance();
                      
                      if (controller.statTeacherAttendance.value == null) {
                        Navigator.pop(context); // إغلاق dialog
                        mySnackbar("تنبيه", "حدث خطأ في التحقق من حضورك");
                        return;
                      }
                      
                      if (controller.statTeacherAttendance.value == 0) {

                        // عرض dialog للانتقال لصفحة الحضور
                        bool? goToAttendance = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("تسجيل الحضور مطلوب"),
                            content: const Text("يجب عليك تسجيل حضورك أولاً قبل تسجيل المراجعة.\n\nهل تريد الانتقال إلى صفحة تسجيل الحضور والانصراف؟"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("إلغاء"),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text("الانتقال"),
                              ),
                            ],
                          ),
                        );
                        
                        if (goToAttendance == true) {
                          Get.to(() => User_Attendance(), arguments: controller.dataArg);
                        }
                        return;
                      }
                      
                      // إذا تم تسجيل الحضور، تابع العملية
                      await controller.getLastReview(student["id_student"],student["id_level"]);
                      
                      if (controller.stat_getLastReview == 1) {
                        bool? confirm = await showConfirmDialog(
                          context: context,
                          message: "لقد تمت إضافة مراجعة لهذا اليوم بالفعل، ولا يمكن إدخال أكثر من مراجعة في نفس اليوم. هل ترغب في تعديل المراجعة الحالية؟",
                        );
                        if (confirm == true) {
                          Get.to(() => Update_Review(), arguments: {
                            "dataLastReview": controller.dataLastReview,
                            "student": student,
                          });
                        }
                      } else if (controller.stat_getLastReview == 2) {
                        final studentArgs = {
                          ...student,
                          "id_user": controller.dataArg["id_user"],
                        };
                        Get.to(() => Review(), arguments: {
                          "dataLastReview": controller.dataLastReview,
                          "student": studentArgs,
                        });
                      } else if (controller.stat_getLastReview == 3) {
                        mySnackbar("تنبيه", "يجب ان يكون للطالب تسميع مسبق قبل اضافة مراجعة ");
                        return;
                      } else {
                        mySnackbar("تنبيه", "حصل خطأ في الاتصال");
                      }
                    } else {
                      mySnackbar("تنبية", "اجازة بمناسبة${holidayData["reason"]}");
                    }
                  },
                  updateData: (){

                    Get.to(()=>UpdateStudent(),arguments: student);

                  },
                  viewPlan: (){
                    Get.to(() => StudentPlanReport(), arguments: {
                      "id_student": student["id_student"],
                      "name_student": student["name_student"],
                      "current_level_id": student["id_level"],
                      "current_stage_id": student["id_stages"],
                    });
                  },
                );
              },
            );
          }),
        ),
      ),
            ),
          ],
        ),
      )
    ));
  }

  Widget _buildQuickStats() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              "إجمالي الطلاب",
              "${controller.students.length}",
              Icons.people,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              "نتائج البحث",
              "${controller.filteredStudents.length}",
              Icons.search,
              Colors.green,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              "الحلقة",
              controller.dataArg["name_circle"]?.toString() ?? "",
              Icons.school,
              Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
        // ✅ إغلاق PopScope
    ); // ✅ إغلاق build
  }
}




