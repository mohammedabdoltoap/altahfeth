import 'package:althfeth/constants/appButton.dart';
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
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.teal[700],
          title: const Text(
            "بيانات الزيارة",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: false, // نترك العنوان من اليسار قليلاً
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.teal[300],
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Map data={
                    "id_user":data_user_globle["id_user"] ?? 4 ,
                    "id_visit":controller.dataArd["id_visit"],
                    "id_circle":controller.dataArd["id_circle"],
                  };
                  Get.to(()=>Notes_For_Teacher(),arguments: data);
                },
                child: const Text(
                  "توجيهات لمعلم الحلقة",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            tabs: [
              Tab(text: "لم يختبر"),
              Tab(text: "اختبر الحفظ"),
              Tab(text: "اختبر المراجعة"),
              Tab(text: "اختبر الاثنين"),
            ],
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
      return const Center(
        child: Text(
          "لا يوجد طلاب",
          style: TextStyle(fontSize: 17, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        var student = filtered[index];
        return Card(
          color: Colors.white,
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            title: Text(
              student["name_student"] ?? "",
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey.shade600,
              size: 18,
            ),
            onTap: () {
              Get.to(
                    () => UpdateExamScreen(),
                arguments: {
                  "student": student,
                  "id_visit": controller.dataArd["id_visit"],
                },
              );
            },
          ),
        );
      },
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

