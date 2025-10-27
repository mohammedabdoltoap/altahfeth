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
  RxnInt statCheck_Attendance = RxnInt(null);

  var lastDailyReport = Rxn<Map<String, dynamic>>();
  RxBool loding_get_circle_and_students = false.obs;

  Future getstudents() async {
    if (loding_get_circle_and_students.value) return;
    final res = await handleRequest<dynamic>(
      isLoading: loding_get_circle_and_students,
      loadingMessage: "جاري تحميل الطلاب...",
      useDialog: false,
      immediateLoading: true,
      action: () async {
        await select_Holiday_Days();
        return await postData(Linkapi.getstudents, {"id_circle": dataArg["id_circle"]});
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
      students.clear();
      filteredStudents.clear();
      String errorMsg = res["msg"] ?? "لا يوجد طلاب في هذه الحلقة حالياً";
      mySnackbar("تنبيه", errorMsg);
    } else {
      String errorMsg = res["msg"] ?? "تعذّر تحميل قائمة الطلاب";
      mySnackbar("خطأ", errorMsg);
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

  // RxBool loding_getLastDailyReport = false.obs;
  RxInt statLastDailyReport = 0.obs;

  Future getLastDailyReport(id_student, id_level) async {
    final res = await handleRequest<dynamic>(
      isLoading: RxBool(false),
      loadingMessage: "جاري التحقق من آخر تسميع...",
      action: () async {
        return await postData(Linkapi.getLastDailyReport, {
          "id_student": id_student,
          "id_level": id_level,
        });
      },
    );

    if (res == null) return;
    if (res is! Map) {
      mySnackbar("خطأ", "فشل الاتصال بالخادم");
      return;
    }
    if (res["stat"] == "ok") {
      lastDailyReport.value = Map<String, dynamic>.from(res["data"]);
    }
    if (lastDailyReport.value?["date"] != null) {
      dbDate = DateTime.parse(lastDailyReport.value?["date"]);
      now = DateTime.now();
      if(dbDate!=null)
      if (onlyDate(dbDate!) == onlyDate(now!)) {
        statLastDailyReport.value = 2;
      } else {
        statLastDailyReport.value = 1;
      }
    } else {
      statLastDailyReport.value = 1;
    }
  }


  DateTime? onlyDate(DateTime dt) => DateTime(dt.year  , dt.month, dt.day);


  Future check_attendance() async {
    DateTime selectedDate = DateTime.now(); // أو التاريخ اللي تختاره
    String formattedDate = "${selectedDate.year}-${selectedDate.month.toString()
        .padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";

    print("formattedDate=${formattedDate}");
    final res = await handleRequest<dynamic>(
      isLoading: RxBool(false),
      loadingMessage: "التحقق من الحضور...",
      useDialog: true,
      immediateLoading: true,
      action: () async {
        await del();
        return await postData(Linkapi.check_attendance, {
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
      statCheck_Attendance.value = 1;
    } else if (res["stat"] == "no") {
      statCheck_Attendance.value = 0;
    } else {
      String errorMsg = res["msg"] ?? "حصل خطأ أثناء التحقق من الحضور";
      mySnackbar("خطأ", errorMsg);
    }
  }




  // تم تعطيل هذه الدالة واستبدالها بصفحة طلب الاستقالة الجديدة
  // Future addResignation() async {
  //   final res = await handleRequest<dynamic>(
  //     isLoading: RxBool(false),
  //     loadingMessage: "إرسال طلب الاستقالة...",
  //     useDialog: true,
  //     immediateLoading: true,
  //     action: () async {
  //       await del();
  //       return await postData(Linkapi.addResignation, {
  //         "id_user": dataArg["id_user"],
  //       });
  //     },
  //   );

  //   if (res == null) return;
  //   if (res is! Map) {
  //     mySnackbar("خطأ", "فشل الاتصال بالخادم");
  //     return;
  //   }
  //   if (res["stat"] == "ok") {
  //     mySnackbar("تم تقديم طلب الاستقالة", "سيتم المراجعة قريباً", type: "g");
  //   } else {
  //     String errorMsg = res["msg"] ?? res["message"] ?? "حصل خطأ أثناء تقديم الطلب";
  //     mySnackbar("خطأ", errorMsg);
  //   }
  // }


  var dataLastReview = Rxn<Map<String, dynamic>>();
  int stat_getLastReview = 0;

  Future<void> getLastReview(id_student, id_level) async {
    final res = await handleRequest<dynamic>(
      isLoading: RxBool(false),
      loadingMessage: "جاري التحقق من آخر مراجعة...",
      useDialog: true,
      immediateLoading: true,
      action: () async {
        await del();
        return await postData(Linkapi.getLastReview, {
          "id_student": id_student,
          "id_level": id_level,
        });
      },
    );

    if (res == null) {
      stat_getLastReview = 0;
      return;
    }
    if (res is! Map) {
      mySnackbar("خطأ", "فشل الاتصال بالخادم");
      stat_getLastReview = 0;
      return;
    }

    switch (res["stat"]) {
      case "NoBecauseNoDailyReport":
        stat_getLastReview = 3;
        break;
      case "ok":
        print("res=====${res}");
        final data = Map<String, dynamic>.from(res["data"]);
        dataLastReview.value = data;
        final dateStr = data["date"]?.toString();
        if (dateStr != null && dateStr.isNotEmpty) {
          dbDate = DateTime.parse(dateStr);
          now = DateTime.now();
          if (onlyDate(dbDate!) == onlyDate(now!)) {
            stat_getLastReview = 1;
          } else {
            stat_getLastReview = 2;
          }
        } else {
          stat_getLastReview = 2;
        }
        break;
      default:
        stat_getLastReview = 0;
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
    final res = await handleRequest<dynamic>(
      isLoading: RxBool(false),
      loadingMessage: "جاري جلب تقرير التسميع...",
      useDialog: true,
      immediateLoading: true,
      action: () async {
        await del();
        return await postData(Linkapi.select_daily_report, {"id_student": id_student});
      },
    );
    if (res == null) return;
    if (res is! Map) {
      mySnackbar("خطأ", "فشل الاتصال بالخادم");
      return;
    }
    if (res["stat"] == "ok") {
      daily_report.assignAll(List<Map<String, dynamic>>.from(res["daily_report"]));
      await showDaily_report();
    } else if (res["stat"] == "no") {
      String errorMsg = res["msg"] ?? "لا يوجد سجلات سابقة للطالب";
      mySnackbar("تنبيه", errorMsg);
    } else {
      String errorMsg = res["msg"] ?? "حصل خطأ في جلب التقرير";
      mySnackbar("خطأ", errorMsg);
    }
  }

  Future select_review_report(id_student) async {
    final res = await handleRequest<dynamic>(
      isLoading: RxBool(false),
      loadingMessage: "جاري جلب تقرير المراجعة...",
      useDialog: true,
      immediateLoading: true,
      action: () async {
        await del();
        return await postData(Linkapi.select_review_report, {"id_student": id_student});
      },
    );
    if (res == null) return;
    if (res is! Map) {
      mySnackbar("خطأ", "فشل الاتصال بالخادم");
      return;
    }
    if (res["stat"] == "ok") {
      review_report.assignAll(List<Map<String, dynamic>>.from(res["reviews"]));
      await showReview_report();
    } else if (res["stat"] == "no") {
      String errorMsg = res["msg"] ?? "لا يوجد سجلات سابقة للطالب";
      mySnackbar("تنبيه", errorMsg);
    } else {
      String errorMsg = res["msg"] ?? "حصل خطأ في جلب التقرير";
      mySnackbar("خطأ", errorMsg);
    }
  }

  Future select_absence_report(id_student,name_student) async {
    final res = await handleRequest<dynamic>(
      isLoading: RxBool(false),
      loadingMessage: "جاري جلب تقرير الغياب...",
      useDialog: true,
      immediateLoading: true,
      action: () async {

        return await postData(Linkapi.select_absence_report, {"id_student": id_student});
      },
    );
    if (res == null) return;
    if (res is! Map) {
      mySnackbar("خطأ", "فشل الاتصال بالخادم");
      return;
    }
    if (res["stat"] == "ok") {
      absences.assignAll(List<Map<String, dynamic>>.from(res["attendance"]));
      await showAbsencesReport(name_student);
    } else if (res["stat"] == "no") {
      String errorMsg = res["msg"] ?? "لا يوجد غيابات للطالب";
      mySnackbar("تنبيه", errorMsg);
    } else {
      String errorMsg = res["msg"] ?? "حصل خطأ في جلب التقرير";
      mySnackbar("خطأ", errorMsg);
    }
  }



  Future showDaily_report()async{
    final headers =[
      'التاريخ',
      'المرحلة',
      'المستوى',
      'إلى سورة ',
      'من سورة ',
      'اسم استاذ الحلقة',
      'اسم الحلقة',
    ];
    final rows = daily_report.map((r) => [
      (r['date']?.split(' ')[0] ?? 'غير متوفر').toString(),
      (r['name_stages'] ?? 'غير متوفر').toString(),
      (r['name_level'] ?? 'غير متوفر').toString(),
      "${r['to_soura_name'] ?? 'غير متوفر'} (${r['to_id_aya'] ?? 'غير متوفر'})",
      "${r['from_soura_name'] ?? 'غير متوفر'} (${r['from_id_aya'] ?? 'غير متوفر'})",
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
      'إلى سورة ',
      'من سورة ',
      'اسم استاذ الحلقة',
      'اسم الحلقة',
    ];
    final rows = review_report.map((r) => [
      (r['date']?.split(' ')[0] ?? 'غير متوفر').toString(),
      (r['name_stages'] ?? 'غير متوفر').toString(),
      (r['name_level'] ?? 'غير متوفر').toString(),
      "${r['to_soura_name'] ?? 'غير متوفر'} (${r['to_id_aya'] ?? 'غير متوفر'})",
      "${r['from_soura_name'] ?? 'غير متوفر'} (${r['from_id_aya'] ?? 'غير متوفر'})",
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