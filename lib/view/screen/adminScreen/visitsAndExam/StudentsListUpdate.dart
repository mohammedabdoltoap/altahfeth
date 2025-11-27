import 'package:althfeth/constants/appButton.dart';
import 'package:althfeth/constants/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:althfeth/api/LinkApi.dart';
import 'package:althfeth/api/apiFunction.dart';
import 'package:althfeth/constants/function.dart';
import '../../../../globals.dart';
import 'Notes_For_Teacher.dart';
import 'UpdateExamScreen.dart';




class StudentsListUpdate extends StatelessWidget {
  final StudentsListUpdateController controller = Get.put(StudentsListUpdateController());

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppTheme.primaryColor,
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.primaryColor.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: Text(
            "بيانات الزيارة",
            style: AppTheme.headingMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: false,
          actions: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingSmall),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingMedium, 
                    vertical: AppTheme.spacingSmall
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  ),
                  elevation: 3,
                  shadowColor: Colors.black.withOpacity(0.2),
                ),
                onPressed: () {
                  Map data={
                    "id_user":data_user_globle["id_user"] ?? 4 ,
                    "id_visit":controller.dataArd["id_visit"],
                    "id_circle":controller.dataArd["id_circle"],
                  };
                  Get.to(()=>Notes_For_Teacher(),arguments: data);
                },
                icon: const Icon(Icons.assignment_outlined, size: 18),
                label: const Text(
                  "توجيهات المعلم",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor.withOpacity(0.9),
                    AppTheme.primaryColor,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const TabBar(
                isScrollable: true,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                labelStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                tabs: [
                  Tab(text: "لم يختبر"),
                  Tab(text: "اختبر الحفظ"),
                  Tab(text: "اختبر المراجعة"),
                  Tab(text: "الكل"),
                ],
              ),
            ),
          ),
        ),
        body: Obx(() {
          return TabBarView(
            children: [
              studentListByStatus(0),
              studentListByStatus(1),
              studentListByStatus(2),
              studentListByStatus(3),
            ],
          );
        }),
      ),
    );
  }

  Widget studentListByStatus(int status) {
    var filtered = controller.students.where((e) => e["test_status"] == status).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacingXXLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingXLarge),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.group_outlined,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: AppTheme.spacingLarge),
              Text(
                "لا يوجد طلاب",
                style: AppTheme.headingSmall.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.backgroundColor,
            Colors.white,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.all(AppTheme.spacingLarge),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          var student = filtered[index];
          return Container(
            margin: const EdgeInsets.only(bottom: AppTheme.spacingMedium),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  Colors.grey.shade50,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                  spreadRadius: 0,
                ),
              ],
              border: Border.all(
                color: AppTheme.primaryColor.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                onTap: () {
                  Get.to(
                        () => UpdateExamScreen(),
                    arguments: {
                      "student": student,
                      "id_visit": controller.dataArd["id_visit"],
                    },
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingLarge),
                  child: Row(
                    children: [
                      // رقم الطالب
                      Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primaryColor.withOpacity(0.1),
                              AppTheme.primaryColor.withOpacity(0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                          border: Border.all(
                            color: AppTheme.primaryColor.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            "${index + 1}",
                            style: AppTheme.bodyLarge.copyWith(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: AppTheme.spacingLarge),
                      
                      // اسم الطالب
                      Expanded(
                        child: Text(
                          student["name_student"] ?? "",
                          style: AppTheme.headingSmall.copyWith(
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                          softWrap: true,
                          overflow: TextOverflow.visible,
                        ),
                      ),
                      
                      // أيقونة السهم
                      Container(
                        padding: const EdgeInsets.all(AppTheme.spacingSmall),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: AppTheme.primaryColor,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}






class StudentsListUpdateController extends GetxController {
  var dataArd;
  @override
  void onInit() {
    dataArd = Get.arguments;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      select_data_visit_previous();
    });
  }

  RxList<Map<String, dynamic>> students = <Map<String, dynamic>>[].obs;

  RxBool isLoading = false.obs;

  Future select_data_visit_previous() async {
    try {
      final res = await handleRequest<dynamic>(
        isLoading: isLoading,
        loadingMessage: "جاري تحميل بيانات الطلاب...",
        useDialog: false,
        immediateLoading: true,
        action: () async {
          return await postData(Linkapi.select_data_visit_previous, {
            "id_visit": dataArd["id_visit"],
            "id_circle": dataArd["id_circle"],
          });
        },
      );

      if (res == null) return;
      if (res is! Map) {
        mySnackbar("خطأ", "فشل الاتصال بالخادم");
        return;
      }

      if (res["stat"] == "ok") {
        students.assignAll(List<Map<String, dynamic>>.from(res["data"]));
        print("students====${students}");
      } else if (res["stat"] == "no") {
        mySnackbar("تنبيه", "لا يوجد طلاب في هذه الحلقة");
      } else if (res["stat"] == "error") {
        mySnackbar("تنبيه", "${res["msg"]}");
      } else {
        mySnackbar("تنبيه", "خطأ غير متوقع");
      }
    } catch (e, stackTrace) {
      print("Error in select_data_visit_previous: $e");
      print(stackTrace);
      mySnackbar("خطأ", "حدث خطأ غير متوقع، حاول مرة أخرى");
    }
  }
}

