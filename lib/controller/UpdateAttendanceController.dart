import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../api/LinkApi.dart';
import '../api/apiFunction.dart';
import '../constants/function.dart';
import '../globals.dart';

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
    if (connectivityHelper.hasConnection) {
      await selectAttendanceOnline();
    } else {
      await selectAttendanceOffline();
    }
  }

  Future<void> selectAttendanceOnline() async {
    print('\n📥 جلب حضور الطلاب من السيرفر...');
    
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
      List<Map<String, dynamic>> serverData = List<Map<String, dynamic>>.from(res["data"]);
      print('📊 تم جلب ${serverData.length} طالب من السيرفر');
      
      // طباعة عينة من البيانات للتحقق
      if (serverData.isNotEmpty) {
        print('📋 عينة من البيانات: ${serverData[0]}');
      }
      
      // حفظ البيانات محلياً
      await _saveAttendanceLocally(serverData);
      
      students.assignAll(serverData);
      filteredStudents.assignAll(students);
      
      print('✅ تم حفظ البيانات محلياً بنجاح\n');
    } else if (res["stat"] == "no") {
      mySnackbar("لا يوجد طلاب", "لا توجد بيانات لهذا اليوم");
    } else {
      mySnackbar("خطأ", "حدث خطأ أثناء جلب البيانات");
    }
  }

  Future<void> selectAttendanceOffline() async {
    try {
      final currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      
      List<Map<String, dynamic>> result = await db.rawQuery("""
        SELECT sa.*, s.name_student
        FROM student_attendance sa
        JOIN students s ON sa.id_student = s.id_student
        WHERE sa.date = ? AND sa.id_circle = ?
        ORDER BY s.name_student
      """, [currentDate, dataArg["id_circle"]]);

      if (result.isNotEmpty) {
        // تحويل QueryRow إلى Map قابل للتعديل
        List<Map<String, dynamic>> editableResult = result.map((row) {
          return Map<String, dynamic>.from(row);
        }).toList();
        
        students.assignAll(editableResult);
        filteredStudents.assignAll(students);
      } else {
        mySnackbar("لا يوجد حضور", "لا توجد بيانات محفوظة لهذا اليوم");
      }
    } catch (e) {
      print('❌ خطأ في جلب الحضور محلياً: $e');
      mySnackbar("خطأ", "حدث خطأ أثناء جلب البيانات المحلية");
    } finally {
      isLoading.value = false;
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

    // إعداد البيانات
    for (int i = 0; i < students.length; i++) {
      students[i]["id_user"] = dataArg["id_user"];
      students[i]["id_circle"] = dataArg["id_circle"];
      
      // ✅ التعامل مع الحالات: 1 = حاضر، 0 = غائب، 2 = غائب بعذر
      if (students[i]["status"] is bool) {
        students[i]["status"] = students[i]["status"] == true ? 1 : 0;
      }
    }

    if (connectivityHelper.hasConnection) {
      await updateAttendanceOnline();
    } else {
      await updateAttendanceOffline();
    }
  }

  Future<void> updateAttendanceOnline() async {
    final res = await handleRequest<dynamic>(
      isLoading: isSaving,
      loadingMessage: "جاري تعديل الحضور...",
      useDialog: false,
      immediateLoading: true,
      action: () async {
        // إرسال التعديلات مباشرة بدون حذف
        return await postData(Linkapi.updateAttendance, {"students": students});
      },
    );

    isSaving.value = false;

    if (res == null) return;
    if (res is! Map) {
      mySnackbar("خطأ", "فشل الاتصال بالخادم");
      return;
    }

    if (res["stat"] == "ok") {
      // تحديث محلياً
      await _updateAttendanceLocally(students);
      
      Get.back();
      mySnackbar("تم التعديل بنجاح", "تم تعديل حضور الطلاب", type: "g");
    } else if (res["stat"] == "no") {
      Get.back();
      mySnackbar("حدث خطأ أثناء التعديل", "لم يتم تعديل بعض الطلاب");
    } else {
      mySnackbar("خطأ", "حدث خطأ أثناء التعديل");
    }
  }

  Future<void> updateAttendanceOffline() async {
    try {
      print('\n📝 ========== تعديل حضور الطلاب محلياً (بدون نت) ==========');
      print('📊 عدد الطلاب المراد تعديلهم: ${students.length}');
      
      for (var student in students) {
        final idAttendance = student['id_attendance'];
        final idLocal = student['id_local'];

        if (idAttendance == null && idLocal == null) {
          print('⚠️ لا يوجد معرف للطالب - تخطي');
          continue;
        }

        String whereClause;
        List<dynamic> whereArgs;
        int newStat;

        if (idAttendance != null) {
          whereClause = 'id_attendance = ?';
          whereArgs = [idAttendance];
          newStat = 2;
          print('   📝 سيتم التعديل باستخدام id_attendance → stat=2 (معلق)');
        } else {
          whereClause = 'id_local = ?';
          whereArgs = [idLocal];
          newStat = 0;
          print('   📝 سيتم التعديل باستخدام id_local → stat=0 (معلق)');

        }

        int rowsAffected = await db.update(
          'student_attendance',
          {
            'status': student['status'] ?? 1,
            'notes': student['notes'] ?? '',
            'stat': newStat,
          },
          where: whereClause,
          whereArgs: whereArgs,
        );

        print('   ✅ تم التحديث - عدد الصفوف المتأثرة: ${rowsAffected} ');

      }

      print('✅ تم تعديل ${students.length} طالب محلياً - سيتم المزامنة عند توفر النت\n');
      
      isSaving.value = false;
      Get.back();
      mySnackbar("تم التعديل", "تم تعديل الحضور محلياً ... سيتم المزامنة عند الاتصال بالإنترنت", type: "g");
    } catch (e) {
      print('❌ خطأ في تعديل الحضور محلياً: $e');
      isSaving.value = false;
      mySnackbar("خطأ", "حدث خطأ أثناء التعديل");
    }
  }

  /// 💾 حفظ بيانات الحضور المجلوبة من السيرفر محلياً
  Future<void> _saveAttendanceLocally(List<Map<String, dynamic>> serverData) async {
    try {
      print('💾 حفظ ${serverData.length} سجل حضور محلياً...');
      
      final currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      
      // حذف السجلات القديمة لنفس اليوم فقط
      await db.delete(
        'student_attendance',
        where: 'date = ? AND id_circle = ?',
        whereArgs: [currentDate, dataArg["id_circle"]],
      );
      
      // إدراج البيانات الجديدة
      for (var student in serverData) {
        await db.insert(
          'student_attendance',
          {
            'id_attendance': student['id_attendance'],
            'id_student': student['id_student'],
            'id_circle': student['id_circle'],
            'id_user': student['id_user'],
            'status': student['status'] ?? 1,
            'notes': student['notes'] ?? '',
            'date': student['date'] ?? currentDate,
            'stat': 1, // متزامن
          },
        );
      }
      
      print('✅ تم حفظ جميع السجلات محلياً');
    } catch (e) {
      print('❌ خطأ في حفظ الحضور محلياً: $e');
    }
  }

  /// 💾 تحديث الحضور محلياً بعد نجاح المزامنة
  Future<void> _updateAttendanceLocally(List<Map<String, dynamic>> studentsList) async {
    try {
      print('\n💾 تحديث الحضور محلياً بعد نجاح المزامنة مع السيرفر...');
      print('📊 عدد الطلاب: ${studentsList.length}');
      
      for (var student in studentsList) {
        final idAttendance = student['id_attendance'];
        final idLocal = student['id_local'];
        
        // تحديد المعرف المناسب
        String whereClause;
        List<dynamic> whereArgs;
        
        if (idAttendance != null) {
          // السجل متزامن - استخدم id_attendance
          whereClause = 'id_attendance = ?';
          whereArgs = [idAttendance];
          print('   💾 تحديث: ${student['name_student']} (id_attendance=$idAttendance) → stat=1 (متزامن)');
        } else if (idLocal != null) {
          // السجل غير متزامن - استخدم id_local
          whereClause = 'id_local = ?';
          whereArgs = [idLocal];
          print('   💾 تحديث: ${student['name_student']} (id_local=$idLocal) → stat=1 (متزامن)');
        } else {
          print('⚠️ لا يوجد معرف للطالب: ${student['name_student']}');
          continue;
        }
        
        await db.update(
          'student_attendance',
          {
            'status': student['status'] ?? 1,
            'notes': student['notes'] ?? '',
            'stat': 1, // متزامن
          },
          where: whereClause,
          whereArgs: whereArgs,
        );
      }
      
      print('✅ تم تحديث ${studentsList.length} طالب محلياً - stat=1 (متزامن)\n');
    } catch (e) {
      print('❌ خطأ في تحديث الحضور محلياً: $e');
    }
  }
}
