import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../api/LinkApi.dart';
import '../api/apiFunction.dart';
import '../constants/function.dart';
import '../constants/loadingWidget.dart';
import '../constants/myreport.dart';
import '../globals.dart';
import '../utils/ConnectivityHelper.dart';
import '../utils/LocalDatabase.dart';
class User_AttendanceController extends GetxController {
  var dataArg;
  RxMap<String, dynamic> data_attendance_today = <String, dynamic>{}.obs;
  String todayArabic = '';
  RxBool isOnline = false.obs;
  RxString connectionStatus = ''.obs;


  @override
  void onInit() {
    super.onInit();
    dataArg = Get.arguments;
    setTodayArabic();
    select_users_attendance_today();
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
  String formattedDate = "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}";
  final attendanceDate = DateFormat('yyyy-MM-dd', "en").format(DateTime.now());

  Future select_users_attendance_today() async {

    if(connectivityHelper.hasConnection){
      await select_users_attendance_todayOnline();
    }else{

     List d= await db.rawQuery('''
      select * from users_attendance where id_user=${dataArg["id_user"]} and id_circle=${dataArg["id_circle"]} 
      and attendance_date ='${formattedDate}'
          '''
          );
     if(d.isNotEmpty)
      data_attendance_today.assignAll(d[0]);

    }

  }

Future select_users_attendance_todayOnline()async{
  // 📡 مع الاتصال: جلب من الخادم
  var res = await handleRequest(
    isLoading: lodingUsersAttendanceToday,
    immediateLoading: true,
    useDialog: false,
    action: ()async {
      return await postData(Linkapi.select_users_attendance_today, {
        "id_user": dataArg["id_user"],
        "attendance_date": formattedDate,
        "id_circle": dataArg["id_circle"]
      });
    },
  );

  if(res==null) {
    return;
  }

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
  final now = DateTime.now();
  final checkTime = DateFormat('HH:mm:ss', "en").format(DateTime.now());


  Future add_check_in_time_usersAttendanceOnline()async{

    final res =await handleRequest(
      loadingMessage: "جاري تسجيل التحضير ",
      useDialog: true,
      immediateLoading: true,
      isLoading: add_check_in, action: () async{
      return await postData(Linkapi.add_check_in_time_usersAttendance, {
          "id_user": dataArg["id_user"],
          "id_circle": dataArg["id_circle"],
          "check_in_time": checkTime,
          "attendance_date": attendanceDate,
        }
        );
    },);
    if(res["stat"]==null){
      return;
    }
    if (res is Map && res["stat"] == "ok") {

      Get.back();
      print(res["id"]);
      mySnackbar(
        "نجاح",
        "تم تسجيل الحضور ✅\n📡 جاري الإرسال للخادم...",
        type: "g",
      );
      saveChekInLocal(res["id"]);
    } else {
      mySnackbar(
        "فشل",
        "لم يتم تسجيل الحضور ✅\n📡 ",
      );
    }

  }

 Future saveChekInLocal(id)async{

    var res=await db.insert("users_attendance", {
        "id_server":id,
        "id_user": dataArg["id_user"],
        "id_circle": dataArg["id_circle"],
        "check_in_time": checkTime,
        "attendance_date": attendanceDate,
        "stat":"NoPending",
        "attendance_status":1
    });
    if(res>0){
      print("ok");
      print(await db.rawQuery("select * from users_attendance"));
    }else{
      print("no");
    }
  }


  Future add_check_in_time_usersAttendance() async {

      if (connectivityHelper.hasConnection) {
       await add_check_in_time_usersAttendanceOnline();
      } else {

       int res=await db.insert("users_attendance", {

          "id_user": dataArg["id_user"],
          "id_circle": dataArg["id_circle"],
          "check_in_time": checkTime,
          "attendance_date": attendanceDate,
          "stat":"Pending",
          "attendance_status":1,
        }
        );
       if(res>0){
         print(await db.query("users_attendance"));
         Get.back();
         mySnackbar("نجاح", "تم الحفظ محليا ..الرجاء الاتصال بالانترنت ب اقرب وقت لمزامنة البيانات",type: "g");
       }
       else{
         mySnackbar("فشل", "لم يتم حفظ الحضور..قم بتجربة تشغيل الانترنت ...");

       }

      }

  }

  RxBool add_check_out=false.obs;

  add_check_out_time_usersAttendanceOfline()async{
    final res = await handleRequest(isLoading: add_check_out, action: ()async {
      return await postData(Linkapi.add_check_out_time_usersAttendance, {
        "id": data_attendance_today["id"],
        "check_out_time": checkTime,

      }
      );

    },);
    if(res ==null) return;

    if(res is Map && res["stat"]=="ok"){

      saveChekOutLocal(data_attendance_today["id"]);
      Get.back();
      mySnackbar(
        "نجاح",
        "تم تسجيل الانصراف ✅\n📡 ",
        type: "g",
      );
    }

  }
  Future add_check_out_time_usersAttendance() async {

      if (connectivityHelper.hasConnection) {
        await add_check_out_time_usersAttendanceOfline();
      } else {
        var res=await db.update("users_attendance", {
          "check_out_time": checkTime,
          "stat":"Pending"
        },where: "id_local = ${data_attendance_today["id_local"]}",
        );
        if(res>0){
          Get.back();
          mySnackbar(
            "نجاح",
            "تم تسجيل الانصراف ✅\n📱 محفوظ محلياً (بدون نت)",
            type: "g",
          );

        }else{
          mySnackbar(
            "فشل",
            "لم يتم تسجيل الانصراف  (جرب شغل الانترنت)او المحاولة مرة اخرى ",
          );
        }



      }

  }
  Future saveChekOutLocal(id)async{

    var res=await db.update("users_attendance", {
      "check_out_time": checkTime,
    },where: "id_server = $id",
    );
    if(res>0){
      print("ok Update");
      print(await db.rawQuery("select * from users_attendance"));
    }else{
      print("no Update");
    }
  }

  RxBool addingSubstitute = false.obs;

  /// 🔹 تسجيل التغطية (بدون تحديد من يغطي)
  Future addSubstituteAttendance() async {
    var res = await handleRequest(
      isLoading: addingSubstitute,
      useDialog: false,
      action: () async {

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
