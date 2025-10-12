import 'dart:convert';

import 'package:althfeth/api/LinkApi.dart';
import 'package:althfeth/api/apiFunction.dart';
import 'package:althfeth/constants/function.dart';
import 'package:althfeth/constants/loadingWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../constants/myreport.dart';
import '../globals.dart';

class HomeCont extends GetxController {
  var dataArg;

  @override
  void onInit(){
    dataArg = Get.arguments;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getstudents();
    });
  }

  TextEditingController textEditingController = TextEditingController();

  DateTime? dbDate;
  DateTime? now;
  RxList<Map<String, dynamic>> students = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> filteredStudents = <Map<String, dynamic>>[].obs;
  RxString searchQuery = ''.obs;
  RxInt statLastDailyReport = 0.obs;
  RxInt statCheck_Attendance = 0.obs;

  var lastDailyReport = Rxn<Map<String, dynamic>>();
  RxBool loding_getLastDailyReport = false.obs;
  RxBool loding_get_circle_and_students = false.obs;

  Future getstudents() async {

    loding_get_circle_and_students.value=true;
    showLoading();
    await del();
    await select_Holiday_Days();
    var res = await postData(Linkapi.getstudents, {"id_circle": dataArg["id_circle"],});
    hideLoading();
    loding_get_circle_and_students.value=false;
    if (res["stat"] == "ok") {
      students.assignAll(RxList<Map<String, dynamic>>.from(res["data"]));
      filteredStudents.assignAll(students);
    }
  }

  void filterStudents(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      filteredStudents.assignAll(students);
    } else {
      filteredStudents.assignAll(students.where((student) =>
          student['name_student'].toLowerCase().contains(query.toLowerCase())));
    }
  }


  Future getLastDailyReport(id_student, id_level) async {
    loding_getLastDailyReport.value = true;
    showLoading();

    await del();
    var res = await postData(Linkapi.getLastDailyReport, {
      "id_student": id_student,
      "id_level": id_level
    });
    if (res["stat"] == "ok") {
      lastDailyReport.value = Map<String, dynamic>.from(res["data"]);
    }
    if (lastDailyReport.value?["date"] != null) {
      dbDate = DateTime.parse(lastDailyReport.value!["date"]);
      now = DateTime.now();

      if (onlyDate(dbDate!) == onlyDate(now!)) {
        print("قد دخلنا له اليوم");
        statLastDailyReport.value = 2;
      }
      else {
        statLastDailyReport.value = 1;
        print("نضيف جديد وقد معه من قبل ");
      }
    }
    else {
      statLastDailyReport.value = 1;
      print("اول مره نضيف لهذا الشخص");
    }
    loding_getLastDailyReport.value = false;
    hideLoading();
  }


  DateTime onlyDate(DateTime dt) => DateTime(dt.year, dt.month, dt.day);


  Future check_attendance() async {
    DateTime selectedDate = DateTime.now(); // أو التاريخ اللي تختاره
    String formattedDate = "${selectedDate.year}-${selectedDate.month.toString()
        .padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";

    print("formattedDate=${formattedDate}");
    showLoading();
    await del();

    var res = await postData(Linkapi.check_attendance, {
      "date": formattedDate,
      "id_circle": dataArg["id_circle"],
    });
    hideLoading();
    if (res["stat"] == "ok") {
      statCheck_Attendance.value = 1;
    }
    else if (res["stat"] == "no") {
      statCheck_Attendance.value = 0;
    }
    else {
      mySnackbar(
          "حصل خطا حاول لاحقا", "حصل خطا اثناء التحققstatCheck_Attendance  ");
    }
  }




  // Future select_users_attendance_today() async {
  //   DateTime selectedDate = DateTime.now(); // أو التاريخ اللي تختاره
  //   String formattedDate = "${selectedDate.year}-${selectedDate.month.toString()
  //       .padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
  //
  //   showLoading();
  //   await del();
  //   var res = await postData(Linkapi.select_users_attendance_today, {
  //     "attendance_date": formattedDate,
  //     "id_circle": dataArg["id_circle"],
  //     "id_user":dataArg["id_user"]
  //   });
  //   hideLoading();
  //   if (res["stat"] == "No_record_today") {
  //     print("خليو يسجل حضور وانصرف");
  //   }
  //   else if (res["stat"] == "No_check_out_time") {
  //     print("يسجل انصراف بس");
  //   }
  //   else if (res["stat"] == "He_check_all") {
  //     print("لاتخليو يسجل شي");
  //   }
  //   else {
  //     mySnackbar(
  //         "حصل خطا حاول لاحقا", "حصل خطا اثناء التحققstatCheck_Attendance  ");
  //   }
  // }

  Future addResignation() async {
    showLoading();
    await del();
    var res = await postData(Linkapi.addResignation, {
      "id_user": dataArg["id_user"],
    });
    hideLoading();
    if (res["stat"] == "ok") {
      mySnackbar("تم تقديم طلب الاستقاله ", "سيتم المراجعة قريبا", type: "g");
    }
    else if (res["stat"] == "no") {
      mySnackbar("حصل خطا  ", res["message"]);
    }
    else {
      mySnackbar("حصل خطا  ", "تواصل مع الادارة ");
    }
  }


  var dataLastReview = Rxn<Map<String, dynamic>>();
  int stat_getLastReview = 0;

  Future<void> getLastReview(id_student, id_level) async {
    try {
      showLoading();
      await del();

      final res = await postData(Linkapi.getLastReview, {
        "id_student": id_student,
        "id_level": id_level,
      });

      hideLoading();

      switch (res["stat"]) {
        case "NoBecauseNoDailyReport":
          stat_getLastReview = 3;
          print("لايمكن اضافة مراجعة قبل الحفظ");
          break;

        case "ok":
          final data = Map<String, dynamic>.from(res["data"]);
          dataLastReview.value = data;

          final dateStr = data["date"]?.toString();
          if (dateStr != null && dateStr.isNotEmpty) {
            dbDate = DateTime.parse(dateStr);
            now = DateTime.now();

            if (onlyDate(dbDate!) == onlyDate(now!)) {
              stat_getLastReview = 1;
              print("قد دخلنا له اليوم");
            } else {
              stat_getLastReview = 2;
              print("نضيف جديد وقد معه من قبل");
            }
          } else {
            stat_getLastReview = 2;
            print("اول مره نضيف لهذا الشخص");
          }
          break;

        default:
          stat_getLastReview = 0;
          print("خطأ في الاتصال");
      }
    } catch (e) {
      hideLoading();
      stat_getLastReview = 0;
      print("حدث استثناء: $e");
    }
  }




  Future select_Holiday_Days()async {
    print("holidayData====${holidayData["is_holiday"]}");

    await initializeDateFormatting('ar', null);
    Intl.defaultLocale = 'ar';
    DateTime today = DateTime.now();
    String todayDate = DateFormat('yyyy-MM-dd').format(today);
    String todayName = DateFormat.EEEE('ar').format(today);

    Map data={
      "region_id":dataArg["region_id"],
      "today_date":todayDate,
      "today_name":todayName,
    };
    var res=await postData(Linkapi.select_Holiday_Days, data);
    holidayData.clear();
    holidayData.assignAll(res);
    print("holidayData====${holidayData}");
  }








  List<Map<String,dynamic>> daily_report=<Map<String,dynamic>>[];
  List<Map<String,dynamic>> review_report=<Map<String,dynamic>>[];
  List<Map<String,dynamic>> absences=<Map<String,dynamic>>[];

  Future select_daily_report(id_student) async {

    showLoading();
   await del();
    var res = await postData(Linkapi.select_daily_report, {"id_student": id_student});
   hideLoading();
    if (res["stat"] == "ok") {
      daily_report.assignAll(List<Map<String, dynamic>>.from(res["daily_report"]));

     await showDaily_report();

    } else if (res["stat"] == "no") {
      mySnackbar("تنبيه", "لايوجد سجلات سابقة للطالب");
    } else {
      mySnackbar("تنبيه", "حصل خطأ تحقق من الاتصال ");
    }

  }
  Future select_review_report(id_student) async {

    showLoading();
   await del();
    var res = await postData(Linkapi.select_review_report, {"id_student": id_student});
   hideLoading();
    if (res["stat"] == "ok") {
      review_report.assignAll(List<Map<String, dynamic>>.from(res["reviews"]));
     await showReview_report();

    } else if (res["stat"] == "no") {
      mySnackbar("تنبيه", "لايوجد سجلات سابقة للطالب");
    } else {
      mySnackbar("تنبيه", "حصل خطأ تحقق من الاتصال ");
    }
  }
  Future select_absence_report(id_student,name_student) async {

    showLoading();
   await del();
    var res = await postData(Linkapi.select_absence_report, {"id_student": id_student});
   hideLoading();
    if (res["stat"] == "ok") {
      absences.assignAll(List<Map<String, dynamic>>.from(res["attendance"]));
     await showAbsencesReport(name_student);

    } else if (res["stat"] == "no") {
      mySnackbar("تنبيه", "لايوجد غيابات للطالب");
    } else {
      mySnackbar("تنبيه", "حصل خطأ تحقق من الاتصال ");
    }
  }



  Future showDaily_report()async{
    final headers =[
      'التاريخ',
      'المرحلة',
      'المستوى',
      'إلى آية',
      'من آية',
      'إلى سورة',
      'من سورة',
      'اسم استاذ الحلقة',
      'اسم الحلقة',
    ];
    final rows = daily_report.map((r) => [
      (r['date']?.split(' ')[0] ?? 'غير متوفر').toString(),
      (r['name_stages'] ?? 'غير متوفر').toString(),
      (r['name_level'] ?? 'غير متوفر').toString(),
      (r['to_id_aya'] ?? 'غير متوفر').toString(),
      (r['from_id_aya'] ?? 'غير متوفر').toString(),
      (r['to_soura_name'] ?? 'غير متوفر').toString(),
      (r['from_soura_name'] ?? 'غير متوفر').toString(),
      (r['username'] ?? 'غير متوفر').toString(),
      (r['name_circle'] ?? 'غير متوفر').toString(),
    ]).toList();
    await  generateStandardPdfReport(
      title: "تقرير التسميع",
      subTitle: "${daily_report.first['name_student']?? "غير متوفر"}",
      headers:headers,
      rows:rows,
    );

  }
  Future showReview_report()async{
    final headers =[
      'التاريخ',
      'المرحلة',
      'المستوى',
      'إلى آية',
      'من آية',
      'إلى سورة',
      'من سورة',
      'اسم استاذ الحلقة',
      'اسم الحلقة',
    ];
    final rows = review_report.map((r) => [
      (r['date']?.split(' ')[0] ?? 'غير متوفر').toString(),
      (r['name_stages'] ?? 'غير متوفر').toString(),
      (r['name_level'] ?? 'غير متوفر').toString(),
      (r['to_id_aya'] ?? 'غير متوفر').toString(),
      (r['from_id_aya'] ?? 'غير متوفر').toString(),
      (r['to_soura_name'] ?? 'غير متوفر').toString(),
      (r['from_soura_name'] ?? 'غير متوفر').toString(),
      (r['username'] ?? 'غير متوفر').toString(),
      (r['name_circle'] ?? 'غير متوفر').toString(),
    ]).toList();
    await  generateStandardPdfReport(
      title: "تقرير المراجعة",
      subTitle: "${review_report.first['name_student']}",
      headers:headers,
      rows:rows,
    );

  }
  Future showAbsencesReport(name_student)async{
    final headers = ["التاريخ", "سبب الغياب"];
    final  absencesRows = absences.map((a) => [
            (a["date"].split(' ')[0] ?? "غير متوفر ").toString(),
            (a["notes"] ?? "غير متوفر").toString(),
          ]).toList();

          // 🔹 نضيف صف إجمالي الغياب بشكل ديناميكي
          absencesRows.add([
            absences.length.toString(),
            "إجمالي الغياب",
          ]);

    await  generateStandardPdfReport(
      title: "تقرير الغياب",
      subTitle: "${name_student}",
      headers:headers,
      rows:absencesRows,
    );

  }









  // Future  showReportStudent()async{
  //   final  absencesRows = absences.map((a) => [
  //     (a["date"].split(' ')[0] ?? "غير متوفر ").toString(),
  //     (a["notes"] ?? "غير متوفر").toString(),
  //   ]).toList();
  //
  //   // 🔹 نضيف صف إجمالي الغياب بشكل ديناميكي
  //   absencesRows.add([
  //     absences.length.toString(),
  //     "إجمالي الغياب",
  //   ]);
  //
  //   await generateDynamicPdfMulite(
  //     [
  //       {
  //         "title": "تقرير التسميع اليومي",
  //         "headers": [
  //           'التاريخ',
  //           'المرحلة',
  //           'المستوى',
  //           'إلى آية',
  //           'من آية',
  //           'إلى سورة',
  //           'من سورة',
  //           'اسم استاذ الحلقة',
  //           'اسم الحلقة',
  //         ],
  //         "rows": reports.map((r) => [
  //           r['date']?.split(' ')[0] ?? 'غير متوفر',
  //           r['name_stages'] ?? 'غير متوفر',
  //           r['name_level'] ?? 'غير متوفر',
  //           r['to_id_aya']?.toString() ?? 'غير متوفر',
  //           r['from_id_aya']?.toString() ?? 'غير متوفر',
  //           r['to_soura_name'] ?? 'غير متوفر',
  //           r['from_soura_name'] ?? 'غير متوفر',
  //           r['username'] ?? 'غير متوفر',
  //           r['name_circle'] ?? 'غير متوفر',
  //         ]).toList(),
  //       },
  //       {
  //         "title": "تقرير المراجعة",
  //         "headers": [
  //           'التاريخ',
  //           'المرحلة',
  //           'المستوى',
  //           'إلى آية',
  //           'من آية',
  //           'إلى سورة',
  //           'من سورة',
  //           'اسم استاذ الحلقة',
  //           'اسم الحلقة',
  //         ],
  //         "rows": reviews.map((r) => [
  //           r['date']?.split(' ')[0] ?? 'غير متوفر',
  //           r['name_stages'] ?? 'غير متوفر',
  //           r['name_level'] ?? 'غير متوفر',
  //           r['to_id_aya']?.toString() ?? 'غير متوفر',
  //           r['from_id_aya']?.toString() ?? 'غير متوفر',
  //           r['to_soura_name'] ?? 'غير متوفر',
  //           r['from_soura_name'] ?? 'غير متوفر',
  //           r['username'] ?? 'غير متوفر',
  //           r['name_circle'] ?? 'غير متوفر',
  //         ]).toList(),
  //       },
  //
  //       {
  //         "title": "جدول الغياب",
  //         "headers": ["التاريخ", "سبب الغياب"],
  //         "rows": absencesRows,
  //       },
  //     ],
  //     mainTitle: "التقرير العام للطالب",
  //   );
  //
  // }


}