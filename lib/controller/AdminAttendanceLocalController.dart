import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../constants/function.dart';
import '../../../globals.dart';

class AdminAttendanceLocalController extends GetxController {
  var data_user;
  RxMap<String, dynamic> data_attendance_today = <String, dynamic>{}.obs;
  String todayArabic = '';
  RxBool loadingUsersAttendanceToday = false.obs;
  RxBool add_check_in = false.obs;
  RxBool add_check_out = false.obs;

  late final String checkTime;
  late final String attendanceDate;

  @override
  void onInit() {
    print("🟢 [AdminAttendanceLocalController] بدء التهيئة");
    data_user = Get.arguments;
    print("🟢 [AdminAttendanceLocalController] data_user: $data_user");

    setTodayArabic();
    checkTime = DateFormat('HH:mm:ss', "en").format(DateTime.now());
    attendanceDate = DateFormat('yyyy-MM-dd', "en").format(DateTime.now());

    print("🟢 [AdminAttendanceLocalController] checkTime: $checkTime");
    print("🟢 [AdminAttendanceLocalController] attendanceDate: $attendanceDate");

    select_admin_attendance_today_local();
  }

  /// 🔹 ضبط اليوم الحالي بالعربية
  void setTodayArabic() {
    final dayName = DateFormat('EEEE', 'ar').format(DateTime.now());
    final date = DateFormat('yyyy-MM-dd', "en").format(DateTime.now());
    todayArabic = "$dayName - $date";
    print("🟢 [setTodayArabic] todayArabic: $todayArabic");
  }

  /// 🔹 جلب حالة الحضور اليوم من قاعدة البيانات المحلية
  Future select_admin_attendance_today_local() async {
    print("🟡 [select_admin_attendance_today_local] بدء جلب البيانات المحلية");

    try {
      List d = await db.rawQuery('''
        select * from users_attendance 
        where id_user=${data_user["id_user"]} 
        and attendance_date ='$attendanceDate'
        and id_circle = 0
      ''');

      print("🟡 [select_admin_attendance_today_local] النتائج: $d");

      if (d.isNotEmpty) {
        data_attendance_today.assignAll(d[0]);
        print("🟡 [select_admin_attendance_today_local] تم تحديث البيانات: ${data_attendance_today.value}");
      } else {
        data_attendance_today.clear();
        print("🟡 [select_admin_attendance_today_local] لا توجد بيانات محلية");
      }
    } catch (e) {
      print("❌ [select_admin_attendance_today_local] خطأ: $e");
      mySnackbar("خطأ", "فشل جلب البيانات المحلية");
    }
  }

  /// 🔹 تسجيل الحضور محلياً
  Future add_admin_check_in_local() async {
    print("🟣 [add_admin_check_in_local] بدء تسجيل الحضور محلياً");
    print("🟣 [add_admin_check_in_local] id_user: ${data_user["id_user"]}");
    print("🟣 [add_admin_check_in_local] check_in_time: $checkTime");
    print("🟣 [add_admin_check_in_local] attendance_date: $attendanceDate");

    try {
      // البحث عن سجل موجود
      List existing = await db.rawQuery('''
        select id from users_attendance 
        where id_user=${data_user["id_user"]} 
        and attendance_date ='$attendanceDate'
        and id_circle = 0
      ''');

      print("🟣 [add_admin_check_in_local] البحث عن سجل موجود: ${existing.isNotEmpty ? "موجود" : "غير موجود"}");

      if (existing.isNotEmpty) {
        // تحديث السجل الموجود
        int res = await db.update(
          "users_attendance",
          {"check_in_time": checkTime},
          where: "id = ${existing[0]["id"]}",
        );

        if (res > 0) {
          print("✅ [add_admin_check_in_local] تم تحديث السجل");
          mySnackbar("نجاح", "تم تحديث وقت الحضور ✅", type: "g");
          select_admin_attendance_today_local();
        } else {
          print("❌ [add_admin_check_in_local] فشل التحديث");
          mySnackbar("فشل", "فشل تحديث الحضور");
        }
      } else {
        // إدراج سجل جديد
        int res = await db.insert("users_attendance", {
          "id_user": data_user["id_user"],
          "id_circle": 0,
          "check_in_time": checkTime,
          "attendance_date": attendanceDate,
          "stat": "Pendeing",
          "attendance_status": 1,
        });

        print("🟣 [add_admin_check_in_local] نتيجة الإدراج: $res");

        if (res > 0) {
          print("✅ [add_admin_check_in_local] تم الحفظ محلياً بنجاح");
          mySnackbar(
            "نجاح",
            "تم تسجيل الحضور ✅\n📱 محفوظ محلياً",
            type: "g",
          );
          select_admin_attendance_today_local();
        } else {
          print("❌ [add_admin_check_in_local] فشل الحفظ");
          mySnackbar("فشل", "فشل تسجيل الحضور");
        }
      }
    } catch (e) {
      print("❌ [add_admin_check_in_local] خطأ: $e");
      mySnackbar("خطأ", "حدث خطأ أثناء تسجيل الحضور");
    }
  }

  /// 🔹 تسجيل الانصراف محلياً
  Future add_admin_check_out_local() async {
    print("🟣 [add_admin_check_out_local] بدء تسجيل الانصراف محلياً");
    print("🟣 [add_admin_check_out_local] id: ${data_attendance_today["id"]}");
    print("🟣 [add_admin_check_out_local] check_out_time: $checkTime");

    try {
      if (data_attendance_today.isEmpty || data_attendance_today["id"] == null) {
        print("❌ [add_admin_check_out_local] لا يوجد سجل للتحديث");
        mySnackbar("خطأ", "لا يوجد سجل حضور لتسجيل الانصراف");
        return;
      }

      int res = await db.update(
        "users_attendance",
        {"check_out_time": checkTime},
        where: "id = ${data_attendance_today["id"]}",
      );

      print("🟣 [add_admin_check_out_local] نتيجة التحديث: $res");

      if (res > 0) {
        print("✅ [add_admin_check_out_local] تم تسجيل الانصراف بنجاح");
        mySnackbar(
          "نجاح",
          "تم تسجيل الانصراف ✅\n📱 محفوظ محلياً",
          type: "g",
        );
        select_admin_attendance_today_local();
      } else {
        print("❌ [add_admin_check_out_local] فشل التحديث");
        mySnackbar("فشل", "فشل تسجيل الانصراف");
      }
    } catch (e) {
      print("❌ [add_admin_check_out_local] خطأ: $e");
      mySnackbar("خطأ", "حدث خطأ أثناء تسجيل الانصراف");
    }
  }

  /// 🔹 حذف جميع السجلات القديمة (اختياري)
  Future delete_old_attendance_records() async {
    print("🟣 [delete_old_attendance_records] حذف السجلات القديمة");

    try {
      int res = await db.delete(
        "users_attendance",
        where: "attendance_date != '$attendanceDate' and id_user = ${data_user["id_user"]}",
      );

      print("✅ [delete_old_attendance_records] تم حذف $res سجل قديم");
    } catch (e) {
      print("❌ [delete_old_attendance_records] خطأ: $e");
    }
  }

  /// 🔹 الحصول على جميع سجلات الحضور للمدير
  Future<List<Map<String, dynamic>>> get_all_admin_attendance() async {
    print("🟡 [get_all_admin_attendance] جلب جميع السجلات");

    try {
      List<Map<String, dynamic>> results = await db.rawQuery('''
        select * from users_attendance 
        where id_user=${data_user["id_user"]} 
        and id_circle = 0
        order by attendance_date desc
      ''');

      print("🟡 [get_all_admin_attendance] عدد السجلات: ${results.length}");
      return results;
    } catch (e) {
      print("❌ [get_all_admin_attendance] خطأ: $e");
      return [];
    }
  }

  /// 🔹 الحصول على إحصائيات الحضور
  Future<Map<String, dynamic>> get_admin_attendance_stats() async {
    print("🟡 [get_admin_attendance_stats] جلب الإحصائيات");

    try {
      List<Map<String, dynamic>> results = await db.rawQuery('''
        select 
          count(*) as total,
          sum(case when check_in_time is not null then 1 else 0 end) as checked_in,
          sum(case when check_out_time is not null then 1 else 0 end) as checked_out
        from users_attendance 
        where id_user=${data_user["id_user"]} 
        and id_circle = 0
      ''');

      if (results.isNotEmpty) {
        print("🟡 [get_admin_attendance_stats] الإحصائيات: ${results[0]}");
        return results[0];
      }
      return {};
    } catch (e) {
      print("❌ [get_admin_attendance_stats] خطأ: $e");
      return {};
    }
  }
}
