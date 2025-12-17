import 'package:althfeth/api/LinkApi.dart';
import 'package:althfeth/api/apiFunction.dart';
import 'package:althfeth/constants/function.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../view/screen/studentScreen/updateStudentPending.dart';
import '../home_cont.dart';

class PendingStudentsController extends GetxController {
  var dataArg;
  
  RxList<Map<String, dynamic>> pendingStudents = <Map<String, dynamic>>[].obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    dataArg = Get.arguments;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getPendingStudents();
    });
    super.onInit();
  }

  Future<void> getPendingStudents() async {
    final response = await handleRequest<dynamic>(
      isLoading: isLoading,
      loadingMessage: "جاري تحميل الطلاب المعلقين...",
      useDialog: false,
      immediateLoading: true,
      action: () async {
        return await postData(Linkapi.get_pending_students, {
          "id_circle": dataArg["id_circle"],
        });
      },
    );

    if (response == null) return;
    if (response is! Map) {
      mySnackbar("خطأ", "فشل الاتصال بالخادم");
      return;
    }

    if (response["stat"] == "ok") {
      pendingStudents.assignAll(List<Map<String, dynamic>>.from(response["data"]));
    } else if (response["stat"] == "no") {
      pendingStudents.clear();
    } else {
      String errorMsg = response["msg"] ?? "تعذّر تحميل الطلاب المعلقين";
      mySnackbar("خطأ", errorMsg);
    }
  }


  Future<void> deleteStudent(int studentId, int index) async {
    final response = await handleRequest<dynamic>(
      isLoading: RxBool(false),
      loadingMessage: "جاري حذف الطالب...",
      useDialog: true,
      immediateLoading: true,
      action: () async {
        return await postData(Linkapi.delete_pending_student, {
          "id_student": studentId,
        });
      },
    );

    if (response == null) return;
    if (response is! Map) {
      mySnackbar("خطأ", "فشل الاتصال بالخادم");
      return;
    }

    if (response["stat"] == "ok") {
      pendingStudents.removeAt(index);
      mySnackbar("نجاح", "تم حذف الطالب بنجاح", type: "g");
    } else {
      String errorMsg = response["msg"] ?? "فشل حذف الطالب";
      mySnackbar("خطأ", errorMsg);
    }
  }

  void editStudent(Map<String, dynamic> student) {
    Get.to(()=>UpdateStudentPending(),arguments: student);
  }
}
