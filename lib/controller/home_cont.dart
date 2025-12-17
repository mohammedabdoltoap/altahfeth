import 'package:althfeth/api/LinkApi.dart';
import 'package:althfeth/api/apiFunction.dart';
import 'package:althfeth/constants/function.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

import '../constants/myreport.dart';
import '../globals.dart';

class HomeCont extends GetxController {
  var dataArg;
  RxBool isOfflineMode = false.obs;

  @override
  void onInit(){
    dataArg = Get.arguments;
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {


      await getstudents();
      
      if (connectivityHelper.hasConnection) {
        print('\n✅ يوجد اتصال بالإنترنت - بدء المزامنة في الخلفية');
        
        _syncInBackground();
      } else {
        print('\n⚠️ لا يوجد اتصال - العمل في الوضع المحلي فقط\n');
      }
    });
  }

  Future _showInitializationDialog()async {
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false, // منع الإغلاق
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 20),
              // أيقونة تحميل متحركة
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color(0xFF006B6B), // اللون الأساسي
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                "جاري تهيئة النظام",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "يرجى الانتظار...",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
      barrierDismissible: false, // منع الإغلاق بالضغط خارجه
    );

    await initialDataSync();

  }

  Future<void> _syncInBackground() async {
    try {
     await  _showInitializationDialog();
      // 2️⃣ رفع المعلق
      await users_attendancePending();
      await dailyReportsPending();
      await reviewsPending();
      await studentAttendancePending();

      // 3️⃣ المزامنة الذكية (رفع المعلق فقط)

      // 4️⃣ تنظيف السجلات القديمة
      await cleanupOldRecords();
      
      print('\n✅ اكتملت المزامنة في الخلفية بنجاح\n');
    } catch (e) {
      print('❌ خطأ في المزامنة الخلفية: $e');
    }
  }
  TextEditingController textEditingController = TextEditingController();
  final attendanceDate = DateFormat('yyyy-MM-dd', "en").format(DateTime.now());
  DateTime? dbDate;
  DateTime? now;
  RxList<Map<String, dynamic>> students = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> filteredStudents = <Map<String, dynamic>>[].obs;
  RxString searchQuery = ''.obs;
  RxnInt statCheck_Attendance = RxnInt(null);

  var lastDailyReport = Rxn<Map<String, dynamic>>();
  RxBool loding_get_circle_and_students = false.obs;



 Future users_attendancePending()async{

  if(connectivityHelper.hasConnection){

   var dataUsersAttendance=await db.rawQuery('''
   select * from users_attendance where id_user=${dataArg["id_user"]} 
   and id_circle=${dataArg["id_circle"]} and stat="Pending" 
   ''');

   if(dataUsersAttendance.isNotEmpty) {

     for (int i = 0; i < dataUsersAttendance.length; i++) {
       bool truePending = true;
       int idRes = 0;
       // ✅ حالة 1: سجل جديد (id_server = null)
       if (dataUsersAttendance[i]["id_server"] == null) {
         print("سجل تحضير لنفسه ومارفعه للسيرفر ابدا ");

         var res = await handleRequest(
           useDialog: false,
           loadingMessage: "جاري مزامنة تحضير المعلم",
           isLoading: RxBool(false),
           action: () async {
             return await postData(Linkapi.add_check_in_time_usersAttendance, {
               "id_user": dataUsersAttendance[i]["id_user"],
               "id_circle": dataUsersAttendance[i]["id_circle"],
               "check_in_time": dataUsersAttendance[i]["check_in_time"],
               "attendance_date": dataUsersAttendance[i]["attendance_date"],
             }
             );
           },
         );
         if (res["stat"] == "ok") {
           print('✅ تم تسجيل check_in بنجاح');
           print('   id من السيرفر: ${res["id"]}');
           // التعامل مع id_server سواء كان int أو String
           if (res["id"] is int) {
             idRes = res["id"];
           } else if (res["id"] is String) {
             idRes = int.tryParse(res["id"]) ?? 0;
           } else {
             idRes = 0;
           }
           // print("check_out_time=======${dataUsersAttendance[i]["check_out_time"]}");

           if (dataUsersAttendance[i]["check_out_time"] != null && idRes != 0) {

             var res = await handleRequest(
               isLoading: RxBool(false), action: () async {
               return await postData(
                   Linkapi.add_check_out_time_usersAttendance, {
                 "id": idRes,
                 "check_out_time": dataUsersAttendance[i]["check_out_time"],
               }
               );
             },
               immediateLoading: true,
               useDialog: false,
               loadingMessage: "جاري مزامنة تحضير المعلم",
             );
             if (res["stat"] == "ok") {
               print('✅ تم تسجيل check_out بنجاح');
             }
             else {
               print('❌ فشل تسجيل check_out');
               truePending = false;
             }
           }
         }
         else {
           print('❌ فشل تسجيل check_in');
           truePending = false;
         }

         if (truePending) {
           if (idRes != 0) {
             await db.update("users_attendance", {
               "id_server": "${idRes}",
               "stat": "NoPending"
             },
                 where: "id_local =${dataUsersAttendance[i]["id_local"]}"
             );
             print('✅ تم تحديث السجل المحلي - stat=NoPending');
           }
         }
       }
       // ✅ حالة 2: سجل موجود (id_server موجود) - تحديث check_out فقط
       else {

         var res = await handleRequest(
           isLoading: RxBool(false), action: () async {
           return await postData(Linkapi.add_check_out_time_usersAttendance, {
             "id": dataUsersAttendance[i]["id_server"],
             "check_out_time": dataUsersAttendance[i]["check_out_time"],
           }
           );
         },
           immediateLoading: true,
           loadingMessage: "جاري مزامنة تحضير المعلم",
         );

         if (res["stat"] == "ok") {
           await db.update("users_attendance", {
             "stat": "NoPending"
           },
               where: "id_local =${dataUsersAttendance[i]["id_local"]}"
           );
           print('✅ تم تحديث check_out بنجاح - stat=NoPending');
         } else {
           print('❌ فشل تحديث check_out');
         }
       }
     }
   }

  }
  
   // تنظيف السجلات القديمة
   int deleted = await db.delete("users_attendance",
     where: "attendance_date !='${attendanceDate}' and stat!='Pending' and id_circle=${dataArg["id_circle"]} "
   );
   if(deleted > 0) {
     print('🗑️ تم حذف $deleted سجل قديم من تحضير المعلم');
   }

 }

 /// 🔄 مزامنة التسميع اليومي المعلق
 Future dailyReportsPending() async {
   if (!connectivityHelper.hasConnection) {
     print('⚠️ لا يوجد اتصال بالإنترنت - تأجيل المزامنة');
     return;
   }

   try {
     // جلب التسميعات المعلقة (stat = 0 أو stat = 2)
     var pendingReports = await db.rawQuery('''
       SELECT * FROM daily_report 
       WHERE (stat = 0 OR stat = 2)
       AND id_circle = ${dataArg["id_circle"]}
     ''');

     print('📊 عدد التسميعات المعلقة: ${pendingReports.length}');

     for (int i = 0; i < pendingReports.length; i++) {
       var report = pendingReports[i];
       bool syncSuccess = false;

       // إذا كان stat = 0 (إضافة جديدة معلقة)
       if (report["stat"] == 0) {
         print('📤 مزامنة تسميع جديد - id_local: ${report["id_local"]}');
         
         var res = await handleRequest(
           useDialog: false,
           isLoading: RxBool(false),
           action: () async {
             return await postData(Linkapi.addDailyReport, {
               "id_student": report["id_student"],
               "from_id_soura": report["from_id_soura"],
               "from_id_aya": report["from_id_aya"],
               "to_id_soura": report["to_id_soura"],
               "to_id_aya": report["to_id_aya"],
               "id_user": report["id_user"],
               "id_circle": report["id_circle"],
               "mark": report["mark"],
               "id_evaluation": report["id_evaluation"],
               "date": report["date"],
             });
           },
         );

         if (res != null && res["stat"] == "ok") {

           int? serverId;
           if (res["data"] is int) {
             serverId = res["data"];
           } else if (res["data"] is String) {
             serverId = int.tryParse(res["data"]);
           }

           if (serverId != null && serverId > 0) {
             // تحديث السجل المحلي بالـ ID الجديد وتغيير stat إلى 1
             await db.update(
               'daily_report',
               {
                 'id_daily_report': serverId,
                 'stat': 1, // متزامن
               },
               where: 'id_local = ?',
               whereArgs: [report["id_local"]],
             );
             syncSuccess = true;
             print('✅ تم مزامنة التسميع الجديد - id_daily_report: $serverId');
           }
         } else {
           print('❌ فشلت مزامنة التسميع الجديد - id_local: ${report["id_local"]}');
         }
       }
       // إذا كان stat = 2 (تعديل معلق)
       else if (report["stat"] == 2 && report["id_daily_report"] != null) {
         print('📝 مزامنة تعديل تسميع - id_daily_report: ${report["id_daily_report"]}');
         
         var res = await handleRequest(
           useDialog: false,
           isLoading: RxBool(false),
           action: () async {
             return await postData(Linkapi.updateDailyReport, {
               "id_daily_report": report["id_daily_report"],
               "to_id_soura": report["to_id_soura"],
               "to_id_aya": report["to_id_aya"],
               "mark": report["mark"],
               "id_evaluation": report["id_evaluation"],
             });
           },
         );

         if (res != null && res["stat"] == "ok") {
           // تحديث stat إلى 1 (متزامن)
           await db.update(
             'daily_report',
             {'stat': 1},
             where: 'id_local = ?',
             whereArgs: [report["id_local"]],
           );
           syncSuccess = true;
           print('✅ تم مزامنة تعديل التسميع - id_daily_report: ${report["id_daily_report"]}');
         } else {
           print('❌ فشلت مزامنة تعديل التسميع - id_daily_report: ${report["id_daily_report"]}');
         }
       }
     }

     print('✅ اكتملت مزامنة التسميع اليومي');
   } catch (e) {
     print('❌ خطأ في مزامنة التسميع اليومي: $e');
   }
 }


  /// 🔄 مزامنة المراجعات المعلقة
 Future reviewsPending() async {
   if (!connectivityHelper.hasConnection) {
     print('⚠️ لا يوجد اتصال بالإنترنت - تأجيل مزامنة المراجعات');
     return;
   }

   try {
     // جلب المراجعات المعلقة (stat = 0 أو stat = 2)
     var pendingReviews = await db.rawQuery('''
       SELECT * FROM review 
       WHERE (stat = 0 OR stat = 2)
       AND id_circle = ${dataArg["id_circle"]}
     ''');

     print('📊 عدد المراجعات المعلقة: ${pendingReviews.length}');

     for (int i = 0; i < pendingReviews.length; i++) {
       var review = pendingReviews[i];
       bool syncSuccess = false;

       // إذا كان stat = 0 (إضافة جديدة معلقة)
       if (review["stat"] == 0) {
         print('📤 مزامنة مراجعة جديدة - id_local: ${review["id_local"]}');
         
         var res = await handleRequest(
           useDialog: false,
           isLoading: RxBool(false),
           action: () async {
             return await postData(Linkapi.addReview, {
               "id_student": review["id_student"],
               "from_id_soura": review["from_id_soura"],
               "from_id_aya": review["from_id_aya"],
               "to_id_soura": review["to_id_soura"],
               "to_id_aya": review["to_id_aya"],
               "id_user": review["id_user"],
               "id_circle": review["id_circle"],
               "mark": review["mark"],
               "id_evaluation": review["id_evaluation"],
               "date": review["date"],
             });
           },
         );

         if (res != null && res["stat"] == "ok") {
           int? serverId;
           if (res["data"] is int) {
             serverId = res["data"];
           } else if (res["data"] is String) {
             serverId = int.tryParse(res["data"]);
           }

           if (serverId != null && serverId > 0) {
             await db.update(
               'review',
               {
                 'id_review': serverId,
                 'stat': 1,
               },
               where: 'id_local = ?',
               whereArgs: [review["id_local"]],
             );
             syncSuccess = true;
             print('✅ تم مزامنة المراجعة الجديدة - id_review: $serverId');
           }
         } else {
           print('❌ فشلت مزامنة المراجعة الجديدة - id_local: ${review["id_local"]}');
         }
       }
       // إذا كان stat = 2 (تعديل معلق)
       else if (review["stat"] == 2 && review["id_review"] != null) {
         print('📝 مزامنة تعديل مراجعة - id_review: ${review["id_review"]}');
         
         var res = await handleRequest(
           useDialog: false,
           isLoading: RxBool(false),
           action: () async {
             return await postData(Linkapi.updateReview, {
               "id_review": review["id_review"],
               "from_id_soura": review["from_id_soura"],
               "from_id_aya": review["from_id_aya"],
               "to_id_soura": review["to_id_soura"],
               "to_id_aya": review["to_id_aya"],
               "mark": review["mark"],
               "id_evaluation": review["id_evaluation"],
             });
           },
         );

         if (res != null && res["stat"] == "ok") {
           await db.update(
             'review',
             {'stat': 1},
             where: 'id_local = ?',
             whereArgs: [review["id_local"]],
           );
           syncSuccess = true;
           print('✅ تم مزامنة تعديل المراجعة - id_review: ${review["id_review"]}');
         } else {
           print('❌ فشلت مزامنة تعديل المراجعة - id_review: ${review["id_review"]}');
         }
       }
     }

     print('✅ اكتملت مزامنة المراجعات');
   } catch (e) {
     print('❌ خطأ في مزامنة المراجعات: $e');
   }
 }

 /// � تحميل البيانات الأولية (أول مرة فقط)
 Future initialDataSync() async {
   if (!connectivityHelper.hasConnection) {
     print('⚠️ لا يوجد اتصال - تخطي التحميل الأولي');
     return;
   }

   try {

     var dailyCount = await db.rawQuery('SELECT COUNT(*) as count FROM daily_report WHERE id_circle = ${dataArg["id_circle"]}');
     var reviewCount = await db.rawQuery('SELECT COUNT(*) as count FROM review WHERE id_circle = ${dataArg["id_circle"]}');
     int totalRecords = (dailyCount[0]['count'] as int) + (reviewCount[0]['count'] as int);
     if (totalRecords > 0) {
       if (Get.isDialogOpen == true) {
         Get.back();
       }
       return;
     }

     print("بيجيب تسميعات ومراجعات من السيرفر لانه المحلي فاضي اول مره بحياة التطبيق فقطط");

     for (int i = 0; i < students.length; i++) {
       var student = students[i];
       int idStudent = student['id_student'];

       await _downloadLastDailyReport(idStudent);
       
       // تحميل آخر مراجعة
       await _downloadLastReview(idStudent);
       
       // تحميل آخر حضور
       await _downloadLastAttendance(idStudent);

     }
    await check_teacher_attendanceOne();
     if (Get.isDialogOpen == true) {


       Get.back();
     }
   } catch (e) {
     print('❌ خطأ في التحميل الأولي: $e');
   }
 }

 /// 📥 تحميل آخر تسميع لطالب
 Future _downloadLastDailyReport(int idStudent) async {
   try {
     print('  📤 إرسال طلب لجلب آخر تسميع - id_student: $idStudent');
     
     var res = await postData(Linkapi.getLastDailyReportByStudent, {
       "id_student": idStudent,
       "id_circle": dataArg["id_circle"]
     });
     
     print('  📥 رد السيرفر للتسميع: ${res?["stat"]}');
     
     if (res != null && res["stat"] == "ok") {
       var serverData = res["data"];
       print('  📊 بيانات التسميع: تاريخ=${serverData["date"]}, درجة=${serverData["mark"]}');
       
       await db.insert('daily_report', {
         'id_daily_report': serverData['id_daily_report'],
         'id_student': serverData['id_student'],
         'from_id_soura': serverData['from_id_soura'],
         'from_id_aya': serverData['from_id_aya'],
         'to_id_soura': serverData['to_id_soura'],
         'to_id_aya': serverData['to_id_aya'],
         'id_user': serverData['id_user'],
         'id_circle': serverData['id_circle'],
         'mark': serverData['mark'],
         'id_evaluation': serverData['id_evaluation'],
         'date': serverData['date'],
         'stat': 1,
       });
       print('  ✅ تم حفظ التسميع محلياً - تاريخ: ${serverData["date"]}');
     } else {
       print('  ℹ️ لا يوجد تسميع في السيرفر لهذا الطالب');
     }
   } catch (e) {
     print('  ❌ خطأ في تحميل التسميع: $e');
   }
 }

 /// 📥 تحميل آخر مراجعة لطالب
 Future _downloadLastReview(int idStudent) async {
   try {
     print('  📤 إرسال طلب لجلب آخر مراجعة - id_student: $idStudent');
     
     var res = await postData(Linkapi.getLastReviewByStudent, {
       "id_student": idStudent,
       "id_circle": dataArg["id_circle"]
     });
     
     print('  📥 رد السيرفر للمراجعة: ${res?["stat"]}');
     
     if (res != null && res["stat"] == "ok") {
       var serverData = res["data"];
       print('  📊 بيانات المراجعة: تاريخ=${serverData["date"]}, درجة=${serverData["mark"]}');
       
       await db.insert('review', {
         'id_review': serverData['id_review'],
         'id_student': serverData['id_student'],
         'from_id_soura': serverData['from_id_soura'],
         'from_id_aya': serverData['from_id_aya'],
         'to_id_soura': serverData['to_id_soura'],
         'to_id_aya': serverData['to_id_aya'],
         'id_user': serverData['id_user'],
         'id_circle': serverData['id_circle'],
         'mark': serverData['mark'],
         'id_evaluation': serverData['id_evaluation'],
         'date': serverData['date'],
         'stat': 1,
       });
       print('  ✅ تم حفظ المراجعة محلياً - تاريخ: ${serverData["date"]}');
     } else {
       print('  ℹ️ لا توجد مراجعة في السيرفر لهذا الطالب');
     }
   } catch (e) {
     print('  ❌ خطأ في تحميل المراجعة: $e');
   }
 }

 /// 📥 تحميل آخر حضور لطالب
 Future _downloadLastAttendance(int idStudent) async {
   try {
     print('  📤 إرسال طلب لجلب آخر حضور - id_student: $idStudent');
     
     var res = await postData(Linkapi.getLastAttendanceByStudent, {
       "id_student": idStudent,
       "id_circle": dataArg["id_circle"]
     });
     
     print('  📥 رد السيرفر للحضور: ${res?["stat"]}');
     
     if (res != null && res["stat"] == "ok") {
       var serverData = res["data"];
       print('  📊 بيانات الحضور: تاريخ=${serverData["date"]}, حالة=${serverData["status"]}');
       
       await db.insert('student_attendance', {
         'id_attendance': serverData['id_attendance'],
         'id_student': serverData['id_student'],
         'id_circle': serverData['id_circle'],
         'date': serverData['date'],
         'status': serverData['status'],
         'notes': serverData['notes'],
         'stat': 1,
       });
       print('  ✅ تم حفظ الحضور محلياً - تاريخ: ${serverData["date"]}');
     } else {
       print('  ℹ️ لا يوجد حضور في السيرفر لهذا الطالب');
     }
   } catch (e) {
     print('  ❌ خطأ في تحميل الحضور: $e');
   }
 }


 /// 🗑️ تنظيف السجلات القديمة - الاحتفاظ بآخر سجل فقط
 Future cleanupOldRecords() async {
   if (!connectivityHelper.hasConnection) {
     print('⚠️ لا يوجد اتصال - تخطي التنظيف');
     return;
   }

   try {
     int totalDeletedDaily = 0;
     int totalDeletedReview = 0;
     
     for (var student in students) {
       int idStudent = student['id_student'];
       
       // تنظيف التسميع اليومي
       // نحذف كل السجلات المتزامنة (stat=1) ماعدا الأحدث
       int deletedDaily = await db.rawDelete('''
         DELETE FROM daily_report 
         WHERE id_student = ? 
         AND stat = 1 
         AND id_local NOT IN (
           SELECT id_local FROM daily_report 
           WHERE id_student = ? AND stat = 1
           ORDER BY date DESC, id_local DESC 
           LIMIT 1
         )
       ''', [idStudent, idStudent]);
       
       if (deletedDaily > 0) {
         totalDeletedDaily += deletedDaily;
       }
       
       // تنظيف المراجعة
       int deletedReview = await db.rawDelete('''
         DELETE FROM review 
         WHERE id_student = ? 
         AND stat = 1 
         AND id_local NOT IN (
           SELECT id_local FROM review 
           WHERE id_student = ? AND stat = 1
           ORDER BY date DESC, id_local DESC 
           LIMIT 1
         )
       ''', [idStudent, idStudent]);
       
       if (deletedReview > 0) {
         totalDeletedReview += deletedReview;
       }
     }

     print('ℹ️ تم الاحتفاظ بآخر سجل لكل طالب + السجلات المعلقة');
     print('='*60 + '\n');
   } catch (e) {
     print('❌ خطأ في تنظيف السجلات: $e');
   }
 }

 /// 🔄 مزامنة حضور الطلاب المعلق
 Future studentAttendancePending() async {
   print('\n🔄 ========== بدء مزامنة حضور الطلاب ==========');
   
   if (!connectivityHelper.hasConnection) {
     print('⚠️ لا يوجد اتصال بالإنترنت - تأجيل مزامنة حضور الطلاب');
     return;
   }

   try {
     // جلب الحضور المعلق (stat = 0 أو stat = 2)
     print('📊 جلب السجلات المعلقة من قاعدة البيانات المحلية...');
     var pendingAttendance = await db.rawQuery('''
       SELECT * FROM student_attendance 
       WHERE (stat = 0 OR stat = 2)
       AND id_circle = ${dataArg["id_circle"]}
     ''');


     if (pendingAttendance.isEmpty) {
       print('✅ لا توجد سجلات معلقة للمزامنة');
       return;
     }



     // فصل السجلات حسب النوع
     var newRecords = pendingAttendance.where((r) => r["stat"] == 0).toList();
     var updateRecords = pendingAttendance.where((r) => r["stat"] == 2).toList();

     // ========== معالجة السجلات الجديدة ==========
     if (newRecords.isNotEmpty) {
       print('\n📤 رفع ${newRecords.length} سجل جديد للسيرفر...');

       // تحويل السجلات إلى صيغة students المطلوبة من API
       List<Map<String, dynamic>> studentsData = newRecords.map((record) => {
         'id_student': record['id_student'],
         'id_circle': record['id_circle'],
         'id_user': record['id_user'],
         'status': record['status'],
         'notes': record['notes'] ?? '',
       }).toList();


       var res = await handleRequest(
         useDialog: false,
         isLoading: RxBool(false),
         action: () async {
           return await postData(Linkapi.insertAttendance, {
             "students": studentsData,
           });
         },
       );


       if (res != null && res["stat"] == "ok") {
         List<int> attendanceIds = [];
         if (res["data"] is List) {
           attendanceIds = (res["data"] as List).map((e) => int.tryParse(e.toString()) ?? 0).toList();
         }

         // تحديث السجلات المحلية
         for (int i = 0; i < newRecords.length; i++) {
           var record = newRecords[i];
           int? serverId = i < attendanceIds.length ? attendanceIds[i] : null;

           if (serverId != null && serverId > 0) {
             await db.update(
               'student_attendance',
               {
                 'id_attendance': serverId,
                 'stat': 1,
               },
               where: 'id_local = ?',
               whereArgs: [record["id_local"]],
             );
             print('   ✅ تم تحديث السجل المحلي: id_local=${record["id_local"]} → id_attendance=$serverId');
           } else {
             print('   ⚠️ لم يتم استلام معرف للسجل: id_local=${record["id_local"]}');
           }
         }

         print('✅ تمت مزامنة ${newRecords.length} سجل جديد بنجاح');
       } else {
         print('❌ فشل رفع السجلات الجديدة - رد السيرفر: ${res?["stat"]}');
       }
     }

     // ========== معالجة السجلات المحدثة ==========
     if (updateRecords.isNotEmpty) {
       print('\n📝 رفع ${updateRecords.length} تعديل للسيرفر...');

       var res = await handleRequest(
         useDialog: false,
         isLoading: RxBool(false),
         action: () async {
           return await postData(Linkapi.updateAttendance, {
             "students":updateRecords
           });
         },
       );
       if (res != null && res["stat"] == "ok") {
         for (var record in updateRecords) {
           await db.update(
             'student_attendance',
             {'stat': 1},
             where: 'id_local = ?',
             whereArgs: [record["id_local"]],
           );

         }
       }

     }

     int deleted = await db.delete("student_attendance",
         where: " date !='${attendanceDate}' and (stat != 0 OR stat != 2)  and id_circle=${dataArg["id_circle"]} "
     );

     if(deleted > 0) {
       print('🗑️ تم حذف $deleted سجل قديم من تحضير المعلم');
     }
   } catch (e, stackTrace) {
     print('❌ خطأ في مزامنة حضور الطلاب: $e');
     print('📍 Stack trace: $stackTrace');
   }
 }


  Future getstudents() async {

      if (connectivityHelper.hasConnection) {
        await _getStudentsFromInternet();
      } else {
        students.assignAll(await db.rawQuery("select * from students where id_circle=${dataArg["id_circle"]}"));
        filteredStudents=students;
        loding_get_circle_and_students.value=false;
      }

    await select_Holiday_Days();

  }

  /// 🌐 جلب الطلاب من الخادم (عبر الإنترنت)
  Future<void> _getStudentsFromInternet() async {
    try {

      final res =await handleRequest(isLoading: loding_get_circle_and_students, action: ()async {
        return  await postData(Linkapi.getstudents, {
          "id_circle": dataArg["id_circle"]
        });
      },);

      // 3️⃣ التحقق من الرد
      if (res == null) {
        return;
      }

      if (res is! Map) {
        mySnackbar("خطأ", "رد غير صحيح من الخادم");
        return;
      }

      // 4️⃣ معالجة الرد
      if (res["stat"] == "ok") {
        final studentsList = List<Map<String, dynamic>>.from(res["data"]);
        students.assignAll(studentsList);
        filteredStudents.assignAll(students);
        await saveStudentLocal();
      } else if (res["stat"] == "no") {
        students.clear();
        filteredStudents.clear();
        String errorMsg = res["msg"] ?? "لا يوجد طلاب في هذه الحلقة حالياً";
        mySnackbar("تنبيه", errorMsg);
      } else {
        // ❌ خطأ من الخادم
        String errorMsg = res["msg"] ?? "تعذّر تحميل قائمة الطلاب";
        mySnackbar("خطأ", errorMsg);
      }
    } catch (e) {
      print('❌ خطأ في جلب الطلاب من الخادم: $e');
      mySnackbar("خطأ", "فشل الاتصال بالخادم");
    }
  }

  Future<void> saveStudentLocal() async {
    if (students.isEmpty) {
      print('⚠️ لا يوجد طلاب لحفظهم محليًا');
      return;
    }

    try {
      final database = await db.database;
      
      // استخدام Transaction لضمان تنفيذ العملية كاملة أو إلغائها
      await database.transaction((txn) async {
        // 1️⃣ حذف الطلاب القدامى للحلقة الحالية فقط (وليس كل الطلاب)
        await txn.delete(
          'students',
          where: 'id_circle = ?',
          whereArgs: [dataArg["id_circle"]],
        );

        // 2️⃣ إدراج الطلاب الجدد دفعة واحدة باستخدام Batch
        final batch = txn.batch();
        for (var student in students) {
          batch.insert(
            'students',
            {
              'id_student': student['id_student'],
              'name_student': student['name_student'],
              'surname': student['surname'],
              'address_student': student['address_student'],
              'place_of_birth': student['place_of_birth'],
              'date_of_birth': student['date_of_birth'],
              'phone': student['phone'],
              'school_name': student['school_name'],
              'classroom': student['classroom'],
              'guardian': student['guardian'],
              'id_circle': student['id_circle'],
              'jop': student['jop'],
              'id_stages': student['id_stages'],
              'id_level': student['id_level'],
              'status': student['status'],
              'date': student['date'],
              'sex': student['sex'],
              'id_qualification': student['id_qualification'],
              'chronic_diseases': student['chronic_diseases'],
              'id_reder': student['id_reder'],
              'password': student['password'],
              'name_level': student['name_level'],
              'name_stages': student['name_stages'],
              'can_read': student['can_read'], // 0 أو 1
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }

        // 3️⃣ تنفيذ جميع العمليات دفعة واحدة
        await batch.commit(noResult: true);
      });

      print('✅ تم حفظ ${students.length} طالب محليًا بنجاح');
    } catch (e) {
      print('❌ خطأ في حفظ الطلاب محليًا: $e');
      // في حالة الفشل، لن يتم حفظ أي شيء بفضل Transaction
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
    if (connectivityHelper.hasConnection)
    {
     await getLastDailyReportOnline(id_student,id_level);
    }
    else{
      final res = await getLastDailyReportLocal(
        db: db,
        idStudent: id_student,
        idLevel: id_level,
      );
      if (res["stat"] == "ok") {
        lastDailyReport.value = Map<String, dynamic>.from(res["data"]);
      }
      if (lastDailyReport.value?["date"] != null) {
        dbDate = DateTime.parse(lastDailyReport.value?["date"]);
        now = DateTime.now();
        if (dbDate != null)
          if (onlyDate(dbDate!) == onlyDate(now!)) {
            statLastDailyReport.value = 2;
          } else {
            statLastDailyReport.value = 1;
          }
      } else {
        statLastDailyReport.value = 1;
      }

    }

  }

  Future getLastDailyReportOnline(id_student,id_level)async{

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
    if(res == null) return;
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
      if (dbDate != null)
        if (onlyDate(dbDate!) == onlyDate(now!)) {
          statLastDailyReport.value = 2;
        } else {
          statLastDailyReport.value = 1;
        }
    } else {
      statLastDailyReport.value = 1;
    }
  }

  Future<Map<String, dynamic>> getLastDailyReportLocal({
    required Database db,
    required int idStudent,
    required int idLevel,
  }) async {
    // ======================================
    // 1) الحصول على آخر تقرير يومي للطالب
    // ======================================

    List<Map<String, dynamic>> firstQuery = await db.rawQuery("""
    SELECT dr.*,
           sq_from.soura_name AS from_soura_name,
           sq_to.soura_name   AS to_soura_name
    FROM daily_report dr
    JOIN sour_quran sq_from ON dr.from_id_soura = sq_from.id_soura
    JOIN sour_quran sq_to   ON dr.to_id_soura   = sq_to.id_soura
    WHERE dr.id_student = ?
    ORDER BY dr.id_local DESC
    LIMIT 1
  """, [idStudent]);

    if (firstQuery.isNotEmpty) {
      return {
        "stat": "ok",
        "data": firstQuery.first
      };
    }

    // ======================================
    // 2) لم يوجد تقرير → جلب بداية المستوى
    // ======================================
    List<Map<String, dynamic>> secondQuery = await db.rawQuery("""
    SELECT l.from_id_soura AS to_id_soura,
           l.from_id_aya   AS to_id_aya,
           sq.soura_name   AS to_soura_name
    FROM level AS l
    LEFT JOIN sour_quran AS sq ON l.from_id_soura = sq.id_soura
    WHERE l.id_level = ?
    LIMIT 1
  """, [idLevel]);

    if (secondQuery.isNotEmpty) {
      return {
        "stat": "ok",
        "data": secondQuery.first
      };
    }

    // ======================================
    // 3) لا يوجد أي بيانات
    // ======================================
    return {"stat": "no"};
  }

  DateTime? onlyDate(DateTime dt) => DateTime(dt.year  , dt.month, dt.day);


  Future check_attendance() async {
    if (connectivityHelper.hasConnection) {
      await check_attendanceOnline();
    } else {
      await check_attendanceOffline();
    }
  }

  Future check_attendanceOnline() async {
     statCheck_Attendance = RxnInt(null);

    DateTime selectedDate = DateTime.now();
    String formattedDate = "${selectedDate.year}-${selectedDate.month.toString()
        .padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";

    final res = await handleRequest<dynamic>(
      isLoading: RxBool(false),
      loadingMessage: "التحقق من الحضور...",
      useDialog: true,
      immediateLoading: true,
      action: () async {

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

  Future check_attendanceOffline() async {
    statCheck_Attendance = RxnInt(null);

    try {
      final currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      
      // التحقق من وجود حضور لهذا اليوم في قاعدة البيانات المحلية
      // نفس منطق API: SELECT id_attendance WHERE date = ? AND id_circle = ?
      List<Map<String, dynamic>> attendance = await db.rawQuery("""
        SELECT id_attendance
        FROM student_attendance
        WHERE DATE(date) = ? AND id_circle = ?
      """, [currentDate, dataArg["id_circle"]]);
      
      print("attendance result===${attendance}");

      // عكس منطق API لمطابقة check_attendanceOnline:
      // إذا وجد حضور → statCheck_Attendance = 0 (مثل stat="no" في API)
      // إذا لم يوجد حضور → statCheck_Attendance = 1 (مثل stat="ok" في API)
      if (attendance.isNotEmpty) {
        statCheck_Attendance.value = 0; // يوجد حضور
        print("✅ تم العثور على حضور محلي لتاريخ $currentDate");
      } else {
        statCheck_Attendance.value = 1; // لا يوجد حضور
        print("statCheck_Attendance===${statCheck_Attendance.value}");
        print("⚠️ لا يوجد حضور محلي لتاريخ $currentDate");
      }
    } catch (e) {
      print('❌ خطأ في التحقق من الحضور محلياً: $e');
      statCheck_Attendance.value = 0;
    }
  }

  // التحقق من حضور الأستاذ نفسه
  RxnInt statTeacherAttendance = RxnInt(null);
  String formattedDate = "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}";

  Future check_teacher_attendance() async {

    if(connectivityHelper.hasConnection)
      await check_teacher_attendanceOnline();
    else
      await check_teacher_attendanceOfline();



  }

  Future check_teacher_attendanceOfline()async{

    final res = await selectUsersAttendanceTodayOfline(
      db: db,
      idUser: dataArg["id_user"],
      attendanceDate: formattedDate,
      idCircle: dataArg["id_circle"],
    );

    if (res["stat"] == "No_record_today") {
      statTeacherAttendance.value = 0; // لم يسجل حضور
    } else if (res["stat"] == "No_check_out_time" || res["stat"] == "He_check_all") {
      statTeacherAttendance.value = 1; // سجل حضور
    } else {
      statTeacherAttendance.value = null;
    }

  }
  Future<Map<String, dynamic>> selectUsersAttendanceTodayOfline({
    required Database db,
    required int idUser,
    required String attendanceDate,
    required int idCircle,
  }) async {
    // ================================
    // 1) تنفيذ الاستعلام
    // ================================
    List<Map<String, dynamic>> attendanceToday = await db.query(
      "users_attendance",
      where: "id_user = ? AND attendance_date = ? AND id_circle = ?",
      whereArgs: [idUser, attendanceDate, idCircle],
    );

    // ================================
    // 2) لو ما في حضور اليوم
    // ================================
    if (attendanceToday.isEmpty) {
      return {
        "stat": "No_record_today",
      };
    }

    var row = attendanceToday.first;

    // ================================
    // 3) لو سجل دخول (check_in) لكن ما سجل خروج
    // ================================
    if (row["check_out_time"] == null) {
      return {
        "stat": "No_check_out_time",
        "data": row,
      };
    }

    // ================================
    // 4) لو مُسجّل دخول وخروج
    // ================================
    return {
      "stat": "He_check_all",
      "data": row,
    };
  }

  Future check_teacher_attendanceOne()async{

    final res = await handleRequest<dynamic>(
      isLoading: RxBool(false),
      loadingMessage: "التحقق من حضورك...",
      useDialog: true,
      immediateLoading: true,
      action: () async {

        return await postData(Linkapi.select_users_attendance_today, {
          "id_user": dataArg["id_user"],
          "attendance_date": formattedDate,
          "id_circle": dataArg["id_circle"],
        });
      },
    );

    if (res == null) {
      print('⚠️ لم يتم استلام رد من السيرفر');
      statTeacherAttendance.value = null;
      return;
    }

    if (res is! Map) {
      print('❌ رد السيرفر غير صحيح');
      mySnackbar("خطأ", "فشل الاتصال بالخادم");
      statTeacherAttendance.value = null;
      return;
    }


    if (res["stat"] == "No_record_today") {
      print('ℹ️ لا يوجد حضور مسجل اليوم');
      statTeacherAttendance.value = 0; // لم يسجل حضور
    } else if (res["stat"] == "No_check_out_time" || res["stat"] == "He_check_all") {
      statTeacherAttendance.value = 1; // سجل حضور

      // ========== مزامنة من السيرفر للمحلي ==========
      try {
        // التحقق من وجود البيانات في الرد
        if (res["data"] != null && res["data"] is Map) {
          var serverData = res["data"];

          print("serverData========${serverData}");
          int result = await db.insert('users_attendance', {
            'id_server': serverData['id'],
            'id_user': dataArg["id_user"],
            'id_circle': dataArg["id_circle"],
            'check_in_time': serverData['check_in_time'],
            'check_out_time': serverData['check_out_time'],
            'attendance_date': formattedDate,
            'stat': 'NoPending', // متزامن
            'attendance_status': 1,
          });

          if (result > 0) {
            print('✅ تم حفظ حضور المعلم محلياً بنجاح - id_local: $result');
          } else {
            print('❌ فشل حفظ حضور المعلم محلياً');
          }
        }
      } catch (e) {
        print('❌ خطأ في مزامنة حضور المعلم محلياً: $e');
      }
    } else {
      print('⚠️ حالة غير متوقعة: ${res["stat"]}');
      statTeacherAttendance.value = null;
    }

    print('✅ ========== انتهى التحقق من حضور المعلم ==========\n');
  }



  Future check_teacher_attendanceOnline()async{

    final res = await handleRequest<dynamic>(
      isLoading: RxBool(false),
      loadingMessage: "التحقق من حضورك...",
      useDialog: true,
      immediateLoading: true,
      action: () async {

        return await postData(Linkapi.select_users_attendance_today, {
          "id_user": dataArg["id_user"],
          "attendance_date": formattedDate,
          "id_circle": dataArg["id_circle"],
        });
      },
    );

    if (res == null) {
      print('⚠️ لم يتم استلام رد من السيرفر');
      statTeacherAttendance.value = null;
      return;
    }

    if (res is! Map) {
      print('❌ رد السيرفر غير صحيح');
      mySnackbar("خطأ", "فشل الاتصال بالخادم");
      statTeacherAttendance.value = null;
      return;
    }


    if (res["stat"] == "No_record_today") {
      print('ℹ️ لا يوجد حضور مسجل اليوم');
      statTeacherAttendance.value = 0; // لم يسجل حضور
    } else if (res["stat"] == "No_check_out_time" || res["stat"] == "He_check_all") {
      statTeacherAttendance.value = 1; // سجل حضور
      
      // ========== مزامنة من السيرفر للمحلي ==========
      // try {
      //   // التحقق من وجود البيانات في الرد
      //   if (res["data"] != null && res["data"] is Map) {
      //     var serverData = res["data"];
      //     print('📊 بيانات الحضور من السيرفر: $serverData');
      //
      //     // التحقق من وجود السجل محلياً
      //     List<Map<String, dynamic>> localRecord = await db.query(
      //       "users_attendance",
      //       where: "id_user = ? AND attendance_date = ? AND id_circle = ?",
      //       whereArgs: [dataArg["id_user"], formattedDate, dataArg["id_circle"]],
      //     );
      //
      //     if (localRecord.isEmpty) {
      //       print('📥 لا يوجد سجل محلي - حفظ البيانات من السيرفر...');
      //
      //       // حفظ السجل محلياً
      //       int result = await db.insert('users_attendance', {
      //         'id_server': serverData['id'],
      //         'id_user': dataArg["id_user"],
      //         'id_circle': dataArg["id_circle"],
      //         'check_in_time': serverData['check_in_time'],
      //         'check_out_time': serverData['check_out_time'],
      //         'attendance_date': formattedDate,
      //         'stat': 'NoPending', // متزامن
      //         'attendance_status': 1,
      //       });
      //
      //       if (result > 0) {
      //         print('✅ تم حفظ حضور المعلم محلياً بنجاح - id_local: $result');
      //       } else {
      //         print('❌ فشل حفظ حضور المعلم محلياً');
      //       }
      //     } else {
      //       print('ℹ️ السجل موجود محلياً بالفعل - id_local: ${localRecord.first["id_local"]}');
      //
      //       // تحديث السجل المحلي بالبيانات من السيرفر (في حال كان معلق)
      //       if (localRecord.first['stat'] == 'Pending') {
      //         print('🔄 تحديث السجل المحلي المعلق بالبيانات من السيرفر...');
      //         await db.update(
      //           'users_attendance',
      //           {
      //             'id_server': serverData['id'],
      //             'check_in_time': serverData['check_in_time'],
      //             'check_out_time': serverData['check_out_time'],
      //             'stat': 'NoPending',
      //           },
      //           where: 'id_local = ?',
      //           whereArgs: [localRecord.first['id_local']],
      //         );
      //         print('✅ تم تحديث السجل المحلي بنجاح');
      //       }
      //     }
      //   }
      //   else {
      //     print('⚠️ لا توجد بيانات تفصيلية في رد السيرفر');
      //   }
      //
      // } catch (e) {
      //   print('❌ خطأ في مزامنة حضور المعلم محلياً: $e');
      // }
    } else {
      print('⚠️ حالة غير متوقعة: ${res["stat"]}');
      statTeacherAttendance.value = null;
    }
    
    print('✅ ========== انتهى التحقق من حضور المعلم ==========\n');
  }



  var dataLastReview = Rxn<Map<String, dynamic>>();
  int stat_getLastReview = 0;

  Future<void> getLastReview(id_student, id_level) async {
    if (connectivityHelper.hasConnection) {
      await getLastReviewOnline(id_student, id_level);
    } else {
      await getLastReviewOffline(id_student, id_level);
    }
  }

  Future<void> getLastReviewOnline(id_student, id_level) async {
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

  Future<void> getLastReviewOffline(id_student, id_level) async {
    final res = await getLastReviewLocal(
      db: db,
      idStudent: id_student,
      idLevel: id_level,
    );

    if (res["stat"] == "ok") {
      dataLastReview.value = Map<String, dynamic>.from(res["data"]);
      
      final dateStr = res["data"]["date"]?.toString();
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
    } else if (res["stat"] == "NoBecauseNoDailyReport") {
      stat_getLastReview = 3;
    } else {
      stat_getLastReview = 0;
    }
  }

  Future<Map<String, dynamic>> getLastReviewLocal({
    required Database db,
    required int idStudent,
    required int idLevel,
  }) async {
    // ======================================
    // 1) التحقق من وجود تسميع يومي للطالب
    // ======================================
    List<Map<String, dynamic>> dailyReportCheck = await db.rawQuery("""
      SELECT * FROM daily_report 
      WHERE id_student = ?
      LIMIT 1
    """, [idStudent]);

    if (dailyReportCheck.isEmpty) {
      return {"stat": "NoBecauseNoDailyReport"};
    }

    // ======================================
    // 2) الحصول على آخر مراجعة للطالب
    // ======================================
    List<Map<String, dynamic>> reviewQuery = await db.rawQuery("""
      SELECT r.*,
             sq_from.soura_name AS from_soura_name,
             sq_to.soura_name   AS to_soura_name
      FROM review r
      JOIN sour_quran sq_from ON r.from_id_soura = sq_from.id_soura
      JOIN sour_quran sq_to   ON r.to_id_soura   = sq_to.id_soura
      WHERE r.id_student = ?
      ORDER BY r.id_local DESC
      LIMIT 1
    """, [idStudent]);

    if (reviewQuery.isNotEmpty) {
      return {
        "stat": "ok",
        "data": reviewQuery.first
      };
    }

    // ======================================
    // 3) لم يوجد مراجعة → جلب آخر تسميع يومي
    // ======================================
    List<Map<String, dynamic>> lastDailyReport = await db.rawQuery("""
      SELECT dr.to_id_soura,
             dr.to_id_aya,
             sq.soura_name AS to_soura_name
      FROM daily_report dr
      JOIN sour_quran sq ON dr.to_id_soura = sq.id_soura
      WHERE dr.id_student = ?
      ORDER BY dr.id_local DESC
      LIMIT 1
    """, [idStudent]);

    if (lastDailyReport.isNotEmpty) {
      return {
        "stat": "ok",
        "data": lastDailyReport.first
      };
    }

    // ======================================
    // 4) لا يوجد أي بيانات
    // ======================================
    return {"stat": "no"};
  }




  /// 🔄 جلب الإجازات الخاصة (Online/Offline)
  Future select_Holiday_Days() async {

    final dayName = DateFormat('EEEE', 'ar').format(DateTime.now());
    final date = DateFormat('yyyy-MM-dd',"en").format(DateTime.now());

    if (connectivityHelper.hasConnection) {
        await _getSpecialDaysFromInternet();
    }
    holidayData.value = await selectHolidayDays(
      db: db,
      regionId: dataArg["region_id"],
      todayDate: date,
      todayName: dayName,
    );

  }

  /// 🌐 جلب الإجازات (الخاصة والأسبوعية) من الخادم (عبر الإنترنت)
  var specialRes;
  var weekendRes;
  Future<void> _getSpecialDaysFromInternet() async {
    // try {
      // 1️⃣ جلب الإجازات الخاصة
       specialRes =  await postData(Linkapi.get_special_days, {
        "region_id": dataArg["region_id"]
      });

      if(specialRes["stat"]=="ok") {
      await update_region_special_days();
      }
      // 2️⃣ جلب الإجازات الأسبوعية
       weekendRes = await postData(Linkapi.get_weekend_days, {
        "region_id": dataArg["region_id"]}
      );
      if(weekendRes["stat"]=="ok"){
      await  update_weekendRes();
      }



  }



Future update_weekendRes()async{
  await db.delete("region_weekend_days");
  for(int i=0; i<weekendRes["data"].length;i++)
    await db.insert("region_weekend_days",weekendRes["data"][i]);


}
 Future update_region_special_days()async{

     await db.delete("region_special_days");
     for(int i=0; i<specialRes["data"].length;i++)
     await db.insert("region_special_days",specialRes["data"][i]);

     print(await db.rawQuery("select * from region_special_days"));
 }




  Future<Map<String, dynamic>> selectHolidayDays({
    required Database db,
    required int regionId,
    required String todayDate,
    required String todayName,
  }) async {
    // ================================
    // 1) التحقق من الإجازات الأسبوعية
    // ================================
    List<Map<String, dynamic>> weekendRows = await db.query(
      "region_weekend_days",
      columns: ["day_of_week"],
      where: "region_id = ?",
      whereArgs: [regionId],
    );

    // حولهم لقائمة من النصوص فقط مثل PHP
    List<String> weekendDays = weekendRows
        .map((item) => item["day_of_week"].toString())
        .toList();

    if (weekendDays.contains(todayName)) {
      return {
        "is_holiday": true,
        "reason": "إجازة أسبوعية ($todayName)",
        "source": "weekend"
      };
    }

    // ================================
    // 2) التحقق من الإجازات الخاصة / السنوية
    // ================================
    List<Map<String, dynamic>> special = await db.rawQuery("""
    SELECT *
    FROM region_special_days
    WHERE region_id = ?
      AND is_work_day = 0
      AND (? BETWEEN day_date AND IFNULL(EndDate, day_date))
    LIMIT 1
  """, [regionId, todayDate]);

    if (special.isNotEmpty) {
      var holiday = special.first;
      return {
        "is_holiday": true,
        "reason": holiday["description"],
        "type": holiday["type"],
        "source": "special_days"
      };
    }

    // ================================
    // 3) ليس إجازة
    // ================================
    return {"is_holiday": false};
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
    // ✅ الأعمدة الجديدة: نوع الغياب، سبب الغياب، التاريخ (مقلوبة)
    final headers = ["نوع الغياب", "سبب الغياب", "التاريخ"];
    final absencesRows = absences.map((a) {
      // تحديد نوع الغياب من absence_type أو من status
      String absenceType = a["absence_type"] ?? 
                          (a["status"] == 2 || a["status"] == "2" 
                            ? "غياب بعذر" 
                            : "غياب بدون عذر");
      
      return [
        absenceType,
        (a["notes"] ?? "—").toString(),
        (a["date"]?.toString().split(' ')[0] ?? "—").toString(),
      ];
    }).toList();

    // 🔹 حساب إجمالي الغياب بنوعيه
    int totalWithExcuse = absences.where((a) => 
      a["status"] == 2 || a["status"] == "2" || a["absence_type"] == "غياب بعذر"
    ).length;
    int totalWithoutExcuse = absences.where((a) => 
      a["status"] == 0 || a["status"] == "0" || a["absence_type"] == "غياب بدون عذر"
    ).length;
    
    // إضافة صفوف الإجمالي
    absencesRows.add([
      "إجمالي",
      "غياب بعذر: $totalWithExcuse | بدون عذر: $totalWithoutExcuse",
      "المجموع: ${absences.length}",
    ]);

    await generateStandardPdfReport(
      title: "تقرير الغياب",
      subTitle: "$name_student",
      headers: headers,
      rows: absencesRows,
    );
  }





  RxBool isSave=false.obs;
  Future insert_public_visits()async{

    var res=await handleRequest(isLoading: RxBool(false), action: ()async {

      return await postData(Linkapi.insert_public_visits, {

        "id_circle":dataArg["id_circle"],
        "id_user":dataArg["id_user"],
        "visitor_name":_nameController.text,
        "notes":_noteController.text
      });
    },
      immediateLoading: true
    );

    if (res == null) return;
    if (res is! Map) {
      mySnackbar("خطأ", "فشل الاتصال بالخادم");
      return;
    }
    if (res["stat"] == "ok") {
      isSave.value=true;
    } else if (res["stat"] == "no") {
      mySnackbar("تنبية", "لم يتم الاضافة ");
    } else {
      String errorMsg = res["msg"] ?? "حصل خطأ في جلب التقرير";
      mySnackbar("خطأ", errorMsg);
    }

  }


  final _nameController = TextEditingController();
  final _noteController = TextEditingController();

  Future showVisitorDialog({
    required BuildContext context,
    String title = "إضافة زيارة",
    String hintName = "اسم الزائر",
    String hintNote = "ملاحظة (اختياري)",
    String confirmText = "حفظ",
    String cancelText = "إلغاء",
  }) {
    final _formKey = GlobalKey<FormState>();

    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        final theme = Theme.of(ctx);

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person_add_alt_1, size: 60, color: theme.primaryColor),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  // اسم الزائر
                  TextFormField(
                    controller: _nameController,
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      hintText: hintName,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                    validator: (v) => v!.trim().isEmpty ? "الرجاء إدخال اسم الزائر" : null,
                  ),
                  const SizedBox(height: 12),

                  // ملاحظة
                  TextFormField(
                    controller: _noteController,
                    textAlign: TextAlign.right,
                    minLines: 3,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: hintNote,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      prefixIcon: const Icon(Icons.note_alt_outlined),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // الأزرار
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(ctx).pop(null),
                          child: Text(cancelText),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: ()async {
                            if (_formKey.currentState!.validate()) {
                              await insert_public_visits();
                              if(isSave.value)
                               {
                                 _nameController.clear();
                                 _noteController.clear();
                                 Get.back();
                                 mySnackbar("تم بنجاح", "تم الاضافة بنجاح ",type: "g");

                               }

                            }
                          },
                          child: Text(confirmText),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

}