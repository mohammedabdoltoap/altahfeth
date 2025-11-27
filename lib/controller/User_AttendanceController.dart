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
    final date = DateFormat('yyyy-MM-dd',"en").format(now);
    todayArabic = "$dayName - $date";
  }

  /// 🔹 جلب حالة الحضور اليوم
  RxBool lodingUsersAttendanceToday=false.obs;
  RxBool isTodayNew=false.obs;

  Future select_users_attendance_today() async {
    DateTime today = DateTime.now();
    String formattedDate = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";


    var res = await handleRequest(
      isLoading: lodingUsersAttendanceToday,
      immediateLoading: true,  // تفعيل Loading فوراً
      useDialog: false,

      action: ()async {

      return await postData(Linkapi.select_users_attendance_today, {
        "id_user": dataArg["id_user"],
        "attendance_date": formattedDate,
        "id_circle": dataArg["id_circle"]
      });
    },) ;

    if(res==null) return;

    if (res is! Map) {
      mySnackbar("خطأ", "فشل الاتصال بالخادم");
      return;
    }



    if (res["stat"] == "No_record_today") {
      data_attendance_today.clear();
      isTodayNew.value=true;
    } else if (res["stat"] == "No_check_out_time") {
      data_attendance_today.assignAll(res["data"]);
    } else if (res["stat"] == "He_check_all") {
      data_attendance_today.assignAll(res["data"]);
    } else {
      mySnackbar("خطأ", "حصل خطأ أثناء تحميل البيانات");
    }
  }

  RxBool add_check_in=false.obs;

  /// 🔹 تسجيل الحضور
  Future add_check_in_time_usersAttendance() async {

    var res = await handleRequest(
      isLoading: add_check_in,
      useDialog: false,
      action: ()async {
       await del();
      return   await postData(Linkapi.add_check_in_time_usersAttendance, {
      "id_user": dataArg["id_user"],
      "id_circle": dataArg["id_circle"],
    });
    },) ;

    if(res==null)return;

    if (res is! Map) {
      mySnackbar("خطأ", "فشل الاتصال بالخادم");
      return;
    }
    if (res["stat"] == "ok") {
      Get.back();
      mySnackbar("تم بنجاح", "تم تسجيل الحضور ✅", type: "g");
    } else {
      mySnackbar("فشل", "حدث خطأ أثناء تسجيل الحضور");
    }
  }

  RxBool add_check_out=false.obs;
  /// 🔹 تسجيل الانصراف
  Future add_check_out_time_usersAttendance() async {
    String currentTime = DateFormat('HH:mm:ss',"en").format(DateTime.now());

    var res = await handleRequest(
      isLoading: add_check_out,
      useDialog: false,

      action: ()async {
       await del();
      return await postData(Linkapi.add_check_out_time_usersAttendance, {
      "id": data_attendance_today["id"],
      "check_out_time": currentTime,
    });
    },) ;
    if(res==null)return;

    if (res is! Map) {
      mySnackbar("خطأ", "فشل الاتصال بالخادم");
      return;
    }
    if (res["stat"] == "ok") {
      Get.back();
      mySnackbar("تم بنجاح", "تم تسجيل الانصراف ✅", type: "g");
    } else {
      mySnackbar("فشل", "حدث خطأ أثناء تسجيل الانصراف");
    }
  }

  RxBool addingSubstitute = false.obs;

  /// 🔹 تسجيل التغطية (بدون تحديد من يغطي)
  Future addSubstituteAttendance() async {
    var res = await handleRequest(
      isLoading: addingSubstitute,
      useDialog: false,
      action: () async {
        await del();
        return await postData(Linkapi.add_substitute_attendance, {
          "id_user": dataArg["id_user"],
          "id_circle": dataArg["id_circle"],
        });
      },
    );

    if (res == null) return;
    print(res);
    if (res is! Map) {
      mySnackbar("خطأ", "فشل الاتصال بالخادم");
      return;
    }

    if (res["stat"] == "ok") {
      Get.back();
      mySnackbar("تم بنجاح", "تم تسجيل التغطية ✅", type: "g");
      select_users_attendance_today();
    } else {
      mySnackbar("فشل", "حدث خطأ أثناء تسجيل التغطية");
    }
  }
}
