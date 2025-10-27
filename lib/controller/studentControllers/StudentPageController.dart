import 'package:get/get.dart';

import '../../api/LinkApi.dart';
import '../../api/apiFunction.dart';
import '../../constants/function.dart';
import '../../constants/myreport.dart';



class StudentPageController extends GetxController{

  var student;
  @override
  void onInit() {
    student=Get.arguments;

  }

  List<Map<String,dynamic>> daily_report=<Map<String,dynamic>>[];
  List<Map<String,dynamic>> review_report=<Map<String,dynamic>>[];
  List<Map<String,dynamic>> absences=<Map<String,dynamic>>[];

  Future select_daily_report() async {
    final res = await handleRequest<dynamic>(
      isLoading: RxBool(false),
      loadingMessage: "جاري جلب تقرير التسميع...",
      useDialog: true,
      immediateLoading: true,
      action: () async {
        return await postData(Linkapi.select_daily_report, {"id_student": student["id_student"]});
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
  Future select_review_report() async {
    final res = await handleRequest<dynamic>(
      isLoading: RxBool(false),
      loadingMessage: "جاري جلب تقرير المراجعة...",
      useDialog: true,
      immediateLoading: true,
      action: () async {
        return await postData(Linkapi.select_review_report, {"id_student": student["id_student"]});
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
  Future select_absence_report() async {
    final res = await handleRequest<dynamic>(
      isLoading: RxBool(false),
      loadingMessage: "جاري جلب تقرير الغياب...",
      useDialog: true,
      immediateLoading: true,
      action: () async {
        return await postData(Linkapi.select_absence_report, {"id_student": student["id_student"]});
      },
    );
    if (res == null) return;
    if (res is! Map) {
      mySnackbar("خطأ", "فشل الاتصال بالخادم");
      return;
    }
    if (res["stat"] == "ok") {
      absences.assignAll(List<Map<String, dynamic>>.from(res["attendance"]));
      await showAbsencesReport();
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
      subTitle: "${daily_report.first['name_student']}",
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
  Future showAbsencesReport()async{
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
      subTitle: "${student["name_student"]}",
      headers:headers,
      rows:absencesRows,
    );

  }



}