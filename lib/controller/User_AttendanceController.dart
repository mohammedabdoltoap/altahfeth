import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../api/LinkApi.dart';
import '../api/apiFunction.dart';
import '../constants/function.dart';
import '../constants/loadingWidget.dart';
import '../constants/myreport.dart';
class User_AttendanceController extends GetxController {
  var dataArg;
  RxMap<String, dynamic> data_attendance_today = <String, dynamic>{}.obs;
  String todayArabic = '';

  @override
  void onInit() {
    super.onInit();
    dataArg = Get.arguments;
    setTodayArabic();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      select_users_attendance_today();
    });
  }

  /// 🔹 ضبط اليوم الحالي بالعربية
  void setTodayArabic() {
    final now = DateTime.now();
    final dayName = DateFormat('EEEE', 'ar').format(now);
    final date = DateFormat('yyyy-MM-dd').format(now);
    todayArabic = "$dayName - $date";
  }

  /// 🔹 جلب حالة الحضور اليوم
  RxBool lodingUsersAttendanceToday=false.obs;

  Future select_users_attendance_today() async {
    DateTime today = DateTime.now();
    String formattedDate =
        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    lodingUsersAttendanceToday.value=true;
    showLoading();
    await del();
    var res = await postData(Linkapi.select_users_attendance_today, {
      "id_user": dataArg["id_user"],
      "attendance_date": formattedDate,
      "id_circle": dataArg["id_circle"]
    });
    lodingUsersAttendanceToday.value=false;
    hideLoading();

    if (res["stat"] == "No_record_today") {
      data_attendance_today.clear();
    } else if (res["stat"] == "No_check_out_time") {
      data_attendance_today.assignAll(res["data"]);
    } else if (res["stat"] == "He_check_all") {
      data_attendance_today.assignAll(res["data"]);
    } else {
      mySnackbar("خطأ", "حصل خطأ أثناء تحميل البيانات");
    }
  }

  /// 🔹 تسجيل الحضور
  Future add_check_in_time_usersAttendance() async {
    showLoading();
    var res = await postData(Linkapi.add_check_in_time_usersAttendance, {
      "id_user": dataArg["id_user"],
      "id_circle": dataArg["id_circle"],
    });
    hideLoading();

    if (res["stat"] == "ok") {
      Get.back();
      mySnackbar("تم بنجاح", "تم تسجيل الحضور ✅", type: "g");


    } else {
      mySnackbar("فشل", "حدث خطأ أثناء تسجيل الحضور");
    }
  }

  /// 🔹 تسجيل الانصراف
  Future add_check_out_time_usersAttendance() async {
    String currentTime = DateFormat('HH:mm:ss').format(DateTime.now());

    showLoading();
    var res = await postData(Linkapi.add_check_out_time_usersAttendance, {
      "id": data_attendance_today["id"],
      "check_out_time": currentTime,
    });
    hideLoading();

    if (res["stat"] == "ok") {
      Get.back();
      mySnackbar("تم بنجاح", "تم تسجيل الانصراف ✅", type: "g");
    } else {
      mySnackbar("فشل", "حدث خطأ أثناء تسجيل الانصراف");
    }
  }
}
