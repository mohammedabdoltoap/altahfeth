import 'package:althfeth/constants/function.dart';
import 'package:althfeth/controller/home_cont.dart';
import 'package:althfeth/view/screen/dilaysAndRevoews/review.dart';
import 'package:althfeth/view/screen/studentScreen/update_Student.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../globals.dart';
import '../widget/home/appDrawer.dart';
import '../widget/home/cardStudent.dart';
import '../widget/home/searchAndButtonAddStudent.dart';
import 'attendance.dart';
import 'dilaysAndRevoews/daily_report.dart';
import 'dilaysAndRevoews/update_daily_report.dart';
import 'dilaysAndRevoews/update_review.dart';
import 'package:althfeth/constants/inline_loading.dart';
import 'adminScreen/ResignationRequestPage.dart';
import 'login.dart';



class Home extends StatelessWidget {
  HomeCont controller = Get.put(HomeCont());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        actions: [
          // زر طلب الاستقالة (للمدراء فقط)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'resignation':
                  _showResignationRequest();
                  break;
                case 'logout':
                  _showLogoutDialog();
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'resignation',
                child: Row(
                  children: [
                    Icon(Icons.assignment, size: 20),
                    SizedBox(width: 8),
                    Text('طلب استقالة'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('تسجيل الخروج', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
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
                    if(!holidayData["is_holiday"]) {
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
                );
              },
            );
          }),
        ),
      ),
    )
    );
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
              controller.dataArg["name_circle"]?.toString().split(' ').first ?? "",
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
    );
  }

  void _showResignationRequest() {
    Get.to(() => ResignationRequestPage(), arguments: controller.dataArg);
  }

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.logout, color: Colors.red),
            SizedBox(width: 8),
            Text("تسجيل الخروج"),
          ],
        ),
        content: const Text(
          "هل أنت متأكد من رغبتك في تسجيل الخروج؟",
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("إلغاء"),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text("تسجيل الخروج"),
          ),
        ],
      ),
    );
  }

  void _logout() {
    // مسح البيانات المحفوظة
    data_user_globle.clear();
    
    // العودة لصفحة تسجيل الدخول
    Get.offAll(() => Login());
    
    // عرض رسالة تأكيد
    mySnackbar("تم بنجاح", "تم تسجيل الخروج بنجاح", type: "g");
  }
}








