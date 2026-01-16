import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../api/LinkApi.dart';
import '../api/apiFunction.dart';
import '../constants/function.dart';
import '../globals.dart';

class AttendanceController extends GetxController {
  var dataArg;

  RxBool isLoading = false.obs; // تحميل الطلاب
  RxBool isSaving = false.obs;  // تحميل زر الحفظ فقط

  RxList<Map<String, dynamic>> filteredStudents = <Map<String, dynamic>>[].obs;
  RxString searchQuery = ''.obs;

  RxList<Map<String, dynamic>> students = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> leaves = <Map<String, dynamic>>[].obs;
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
    if (connectivityHelper.hasConnection) {
      await select_students_attendanceOnline();
    } else {
      await select_students_attendanceOffline();
    }
  }

  Future<void> select_students_attendanceOnline() async {
    final res = await handleRequest<dynamic>(
      isLoading: isLoading,
      loadingMessage: "جاري تحميل الطلاب...",
      useDialog: false,
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
      // students.assignAll(List<Map<String, dynamic>>.from(res["data"]));
      leaves.assignAll(List<Map<String, dynamic>>.from(res["leaves"]));
      students.assignAll(List<Map<String, dynamic>>.from(res["students"]));

      filteredStudents.assignAll(students);
    } else if (res["stat"] == "no") {
      mySnackbar("لا يوجد طلاب بالحَلقة", "لا توجد بيانات");
    } else {
      mySnackbar("خطأ", "حدث خطأ أثناء جلب البيانات");
    }
  }

  Future<void> select_students_attendanceOffline() async {
    try {
      List<Map<String, dynamic>> result = await db.rawQuery("""
        SELECT * FROM students 
        WHERE id_circle = ?
        ORDER BY name_student
      """, [dataArg["id_circle"]]);

      if (result.isNotEmpty) {
        // إضافة حقل status افتراضي لكل طالب (1 = حاضر)
        List<Map<String, dynamic>> studentsWithStatus = result.map((student) {
          return {
            ...student,
            'status': 1, // افتراضياً حاضر
            'notes': '', // ملاحظات فارغة
          };
        }).toList();
        
        students.assignAll(studentsWithStatus);
        filteredStudents.assignAll(students);
      } else {
        mySnackbar("لا يوجد طلاب", "لا توجد بيانات محفوظة");
      }
    } catch (e) {
      print('❌ خطأ في جلب الطلاب محلياً: $e');
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
      await insertAttendanceOnline();
    } else {
      await insertAttendanceOffline();
    }
  }

  Future<void> insertAttendanceOnline() async {
    // فصل الطلاب الجدد (بدون id_attendance) عن المحدثين (لديهم id_attendance)
    List<Map<String, dynamic>> newStudents = students.where((s) => s['id_attendance'] == null).toList();
    List<Map<String, dynamic>> existingStudents = students.where((s) => s['id_attendance'] != null).toList();
    
    // إذا كان هناك طلاب محدثين، نستخدم updateAttendance بدلاً من insertAttendance
    if (existingStudents.isNotEmpty && newStudents.isEmpty) {
      mySnackbar("تنبيه", "الحضور محفوظ مسبقاً. استخدم صفحة التعديل لتحديث الحضور", type: "y");
      isSaving.value = false;
      Get.back();
      return;
    }
    
    // إرسال الطلاب الجدد فقط
    if (newStudents.isEmpty) {
      mySnackbar("تنبيه", "لا يوجد طلاب جدد لحفظ حضورهم", type: "y");
      isSaving.value = false;
      return;
    }

    final res = await handleRequest<dynamic>(
      isLoading: isSaving,
      loadingMessage: "جاري حفظ الحضور...",
      useDialog: false,
      immediateLoading: true,
      action: () async {
        return await postData(Linkapi.insertAttendance, {
          "students": newStudents,
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
      print('📥 رد السيرفر الكامل: $res');
      
      // التحقق من وجود IDs في الرد
      if (res["data"] is List) {
        // حفظ محلياً بعد النجاح (الطلاب الجدد فقط)
        await _saveAttendanceLocally(newStudents, res["data"]);
      } else if (res["ids"] is List) {
        // بعض السيرفرات ترجع IDs في حقل منفصل
        await _saveAttendanceLocally(newStudents, res["ids"]);
      } else {
        print('⚠️ السيرفر لم يرجع IDs! حفظ محلياً بدون id_attendance');
        // حفظ بدون IDs - سيتم المزامنة لاحقاً
        await _saveAttendanceLocally(newStudents, null);
      }
      
      Get.back();
      mySnackbar("تم بنجاح", "تم حفظ حضور الطلاب", type: "g");
    } else {
      mySnackbar("خطأ", "حدث خطأ أثناء حفظ البيانات");
    }
  }

  Future<void> insertAttendanceOffline() async {
    try {
      final currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      
      for (var student in students) {
        await db.insert('student_attendance', {
          'id_student': student['id_student'],
          'date': currentDate,
          'id_circle': dataArg["id_circle"],
          'id_user': dataArg["id_user"],
          'status': student['status'] ?? 1,
          'notes': student['notes'] ?? '',
          'stat': 0, // معلق
        });
      }

      isSaving.value = false;
      Get.back();
      mySnackbar("تم بنجاح", "تم حفظ الحضور محلياً ... سيتم المزامنة عند الاتصال بالإنترنت", type: "g");
    } catch (e) {
      print('❌ خطأ في حفظ الحضور محلياً: $e');
      isSaving.value = false;
      mySnackbar("خطأ", "حدث خطأ أثناء حفظ البيانات");
    }
  }

  Future<void> _saveAttendanceLocally(List<Map<String, dynamic>> studentsList, dynamic serverData) async {
    try {
      final currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      
      print('📥 حفظ الحضور محلياً - serverData: $serverData');
      
      // إذا كان serverData قائمة من IDs
      List<int> attendanceIds = [];
      if (serverData is List) {
        attendanceIds = serverData.map((e) => int.tryParse(e.toString()) ?? 0).toList();
        print('📥 تم استخراج ${attendanceIds.length} معرف: $attendanceIds');
      } else {
        print('⚠️ serverData ليس قائمة!');
      }

      for (int i = 0; i < studentsList.length; i++) {
        var student = studentsList[i];
        int? idAttendance = i < attendanceIds.length ? attendanceIds[i] : null;

        // التحقق من وجود السجل
        List<Map<String, dynamic>> existing = await db.query(
          'student_attendance',
          where: 'id_student = ? AND date = ? AND id_circle = ?',
          whereArgs: [student['id_student'], currentDate, dataArg["id_circle"]],
        );

        Map<String, dynamic> attendanceData = {
          'id_attendance': idAttendance,
          'id_student': student['id_student'],
          'date': currentDate,
          'id_circle': dataArg["id_circle"],
          'id_user': dataArg["id_user"],
          'status': student['status'] ?? 1,
          'notes': student['notes'] ?? '',
          'stat': 1, // متزامن
        };

        if (existing.isNotEmpty) {
          // تحديث السجل الموجود
          print('🔄 تحديث سجل موجود - id_student: ${student['id_student']}, id_attendance: $idAttendance');
          await db.update(
            'student_attendance',
            attendanceData,
            where: 'id_local = ?',
            whereArgs: [existing.first['id_local']],
          );
        } else {
          // إضافة سجل جديد
          print('➕ إضافة سجل جديد - id_student: ${student['id_student']}, id_attendance: $idAttendance');
          await db.insert('student_attendance', attendanceData);
        }
      }
      
      print('✅ تم حفظ ${studentsList.length} سجل حضور محلياً');
    } catch (e) {
      print('❌ خطأ في حفظ الحضور محلياً: $e');
    }
  }
}
