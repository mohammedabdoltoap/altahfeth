import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../api/LinkApi.dart';
import '../api/apiFunction.dart';
import '../constants/function.dart';

class UpdateAttendanceController extends GetxController {
  var dataArg;

  RxBool isLoading = false.obs; // تحميل الطلاب
  RxBool isSaving = false.obs;  // تحميل زر الحفظ

  RxList<Map<String, dynamic>> students = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> filteredStudents = <Map<String, dynamic>>[].obs;
  RxString searchQuery = ''.obs;

  final TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    dataArg = Get.arguments;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      selectAttendance();
    });
  }

  /// ✅ جلب الحضور
  Future<void> selectAttendance() async {
    final res = await handleRequest<dynamic>(
      isLoading: isLoading,
      loadingMessage: "جاري تحميل الطلاب...",
      useDialog: false,
      immediateLoading: true,
      action: () async {
        await del();
        DateTime selectedDate = DateTime.now();
        String formattedDate = "${selectedDate.year}-${selectedDate.month.toString().padLeft(2,'0')}-${selectedDate.day.toString().padLeft(2,'0')}";
        return await postData(Linkapi.select_attendance, {
          "date": formattedDate,
          "id_circle": dataArg["id_circle"],
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
      filteredStudents.assignAll(students);
    } else if (res["stat"] == "no") {
      mySnackbar("لا يوجد طلاب", "لا توجد بيانات لهذا اليوم");
    } else {
      mySnackbar("خطأ", "حدث خطأ أثناء جلب البيانات");
    }
  }

  /// ✅ فلترة الطلاب
  void filterStudents(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      filteredStudents.assignAll(students);
    } else {
      filteredStudents.assignAll(students.where((student) =>
          student['name_student']
              .toLowerCase()
              .contains(query.toLowerCase())));
    }
  }

  /// ✅ تعديل الحضور
  Future<void> updateAttendance() async {
    if (isSaving.value) return;

    for (int i = 0; i < students.length; i++) {
      students[i]["id_user"] = dataArg["id_user"];
      students[i]["id_circle"] = dataArg["id_circle"];
      
      // ✅ التعامل مع الحالات: 1 = حاضر، 0 = غائب، 2 = غائب بعذر
      if (students[i]["status"] is bool) {
        students[i]["status"] = students[i]["status"] == true ? 1 : 0;
      }
      // إذا كانت status رقم، نتركها كما هي (1, 0, أو 2)
    }

    final res = await handleRequest<dynamic>(
      isLoading: isSaving,
      loadingMessage: "جاري تعديل الحضور...",
      useDialog: false,
      immediateLoading: true,
      action: () async {
        await del();
        return await postData(Linkapi.updateAttendance, {"students": students});
      },
    );

    if (res == null) return;
    if (res is! Map) {
      mySnackbar("خطأ", "فشل الاتصال بالخادم");
      return;
    }

    if (res["stat"] == "ok") {
      Get.back();
      mySnackbar("تم التعديل بنجاح", "تم تعديل حضور الطلاب", type: "g");
    } else if (res["stat"] == "no") {
      Get.back();
      mySnackbar("حدث خطأ أثناء التعديل", "لم يتم تعديل بعض الطلاب");
    } else {
      mySnackbar("خطأ", "حدث خطأ أثناء التعديل");
    }
  }
}
