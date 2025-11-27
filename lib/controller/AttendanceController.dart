import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../api/LinkApi.dart';
import '../api/apiFunction.dart';
import '../constants/function.dart';

class AttendanceController extends GetxController {
  var dataArg;

  RxBool isLoading = false.obs; // تحميل الطلاب
  RxBool isSaving = false.obs;  // تحميل زر الحفظ فقط

  RxList<Map<String, dynamic>> filteredStudents = <Map<String, dynamic>>[].obs;
  RxString searchQuery = ''.obs;
  RxList<Map<String, dynamic>> students = <Map<String, dynamic>>[].obs;

  final TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    dataArg = Get.arguments;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      select_students_attendance();
    });
  }

  /// ✅ جلب الطلاب
  Future<void> select_students_attendance() async {

    final res = await handleRequest<dynamic>(
      isLoading: isLoading,
      loadingMessage: "جاري تحميل الطلاب...",
      useDialog: false, // ❌ بدون دايلوج
      immediateLoading: true,
      action: () async {

        return await postData(Linkapi.select_students_attendance, {
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
      mySnackbar("لا يوجد طلاب بالحَلقة", "لا توجد بيانات");
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
      filteredStudents.assignAll(
        students.where((student) =>
            student['name_student']
                .toLowerCase()
                .contains(query.toLowerCase())),
      );
    }
  }

  /// ✅ إدخال الحضور
  Future<void> insertAttendance() async {
    if(isSaving.value)return;


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
      isLoading: isSaving, // ✅ استخدم isSaving بدل isLoading
      loadingMessage: "جاري حفظ الحضور...",
      useDialog: false, // ❌ بدون دايلوج
      immediateLoading: true,
      action: () async {
        await del();
        return await postData(Linkapi.insertAttendance, {
          "students": students,
        });
      },
    );

    isSaving.value = false;

    if (res == null) return;
    if (res is! Map) {
      mySnackbar("خطأ", "فشل الاتصال بالخادم");
      return;
    }

    if (res["stat"] == "ok") {
      Get.back();
      mySnackbar("تم بنجاح", "تم حفظ حضور الطلاب", type: "g");
    } else {
      mySnackbar("خطأ", "حدث خطأ أثناء حفظ البيانات");
    }
  }
}
