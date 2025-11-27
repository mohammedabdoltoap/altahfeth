import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../api/LinkApi.dart';
import '../api/apiFunction.dart';
import '../constants/function.dart';
import '../globals.dart';

class PromotionController extends GetxController {
  // Steps
  RxInt currentStep = 0.obs;

  // Selections
  RxnInt selectedCenterId = RxnInt(null);
  RxnString selectedCenterName = RxnString(null);
  RxnInt selectedCircleId = RxnInt(null);
  RxnString selectedCircleName = RxnString(null);
  RxnInt selectedStudentId = RxnInt(null);
  RxnString selectedStudentName = RxnString(null);

  // Data lists
  RxList<Map<String, dynamic>> centers = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> circles = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> students = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> committeeMembers = <Map<String, dynamic>>[].obs; // {id_user, username}
  RxList<int> selectedCommitteeIds = <int>[].obs;
  RxString committeeQuery = ''.obs;
  String? currentUserName;

  // Subjects and grades
  RxList<Map<String, dynamic>> subjects = <Map<String, dynamic>>[].obs; // {SubjectID, SubjectName, MaxGrade}
  final Map<int, TextEditingController> gradeControllers = {}; // keyed by SubjectID

  RxBool isLoading = false.obs;
  
  // ✅ متغيرات للتعديل
  RxBool isEditMode = false.obs;
  RxnInt currentPromotionId = RxnInt(null);

  @override
  void onInit() {
    currentUserName = data_user_globle["username"]?.toString();
    super.onInit();
    // ✅ تحميل البيانات بشكل تسلسلي لتجنب التعليق
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadInitialData();
    });
  }

  // ✅ دالة لتحميل البيانات الأولية بشكل منظم
  Future<void> _loadInitialData() async {
    isLoading.value = true;
    try {
      // تحميل المراكز أولاً
      await fetchCenters();
      // تحميل اللجنة والمواد بالتوازي
      await Future.wait([
        fetchCommitteeMembers(),
        fetchSubjects(),
      ]);
    } finally {
      isLoading.value = false;
    }
  }
  Future<void> fetchSubjects() async {
    final res = await handleRequest<dynamic>(
      isLoading: RxBool(false),
      useDialog: false,
      immediateLoading: false,
      action: () async {
        return await postData(Linkapi.select_promotion_subjects, {});
      },
    );
    if (res == null) return;
    if (res is! Map) {
      mySnackbar('خطأ', 'فشل الاتصال بالخادم');
      return;
    }
    if (res['stat'] == 'ok') {
      subjects.assignAll(List<Map<String, dynamic>>.from(res['data']));
      // ensure controllers per subject
      for (final s in subjects) {
        final id = s['SubjectID'] as int;
        gradeControllers[id] ??= TextEditingController();
      }
    }
  }


  @override
  void onClose() {
    for (final c in gradeControllers.values) {
      c.dispose();
    }
    super.onClose();
  }

  // API methods
  Future<void> fetchCenters() async {
    final res = await handleRequest<dynamic>(
      isLoading: RxBool(false),
      useDialog: false,
      immediateLoading: false,
      action: () async {
        return await postData(Linkapi.select_centers, {});
      },
    );
    if (res == null) return;
    if (res is! Map) {
      mySnackbar('خطأ', 'فشل الاتصال بالخادم');
      return;
    }
    if (res['stat'] == 'ok') {
      centers.assignAll(List<Map<String, dynamic>>.from(res['data']));
    } else {
      centers.clear();
    }
  }

  Future<void> fetchCirclesForCenter(int idCenter) async {
    selectedCenterId.value = idCenter;
    selectedCenterName.value = centers.firstWhereOrNull((e) => e['center_id'] == idCenter)?['name']?.toString();
    selectedCircleId.value = null;
    selectedCircleName.value = null;
    selectedStudentId.value = null;
    selectedStudentName.value = null;
    circles.clear();
    students.clear();
    final res = await handleRequest<dynamic>(
      isLoading: isLoading,
      useDialog: false,
      immediateLoading: true,
      loadingMessage: 'جاري تحميل الحلقات...',
      action: () async {
        return await postData(Linkapi.select_circles_by_center, {"id_center": idCenter});
      },
    );
    if (res == null) return;
    if (res is! Map) {
      mySnackbar('خطأ', 'فشل الاتصال بالخادم');
      return;
    }
    if (res['stat'] == 'ok') {
      circles.assignAll(List<Map<String, dynamic>>.from(res['data']));
    } else {
      circles.clear();
    }
  }

  Future<void> selectCircle(Map<String, dynamic> circle) async {
    selectedCircleId.value = circle['id_circle'];
    selectedCircleName.value = circle['name_circle'];
    selectedStudentId.value = null;
    selectedStudentName.value = null;
    students.clear();
    await fetchStudentsForCircle(circle['id_circle']);
  }

  Future<void> fetchStudentsForCircle(int idCircle) async {
    final res = await handleRequest<dynamic>(
      isLoading: isLoading,
      useDialog: false,
      immediateLoading: true,
      loadingMessage: 'جاري تحميل الطلاب...',
      action: () async {
        return await postData(Linkapi.getstudents, {"id_circle": idCircle});
      },
    );
    if (res == null) return;
    if (res is! Map) {
      mySnackbar('خطأ', 'فشل الاتصال بالخادم');
      return;
    }
    if (res['stat'] == 'ok') {
      students.assignAll(List<Map<String, dynamic>>.from(res['data']));
    } else {
      students.clear();
    }
  }

  Future<void> fetchCommitteeMembers() async {
    final res = await handleRequest<dynamic>(
      isLoading: RxBool(false),
      useDialog: false,
      immediateLoading: false,
      action: () async {
        return await postData(Linkapi.select_promotion_committee, {});
      },
    );
    if (res == null) return;
    if (res is! Map) {
      mySnackbar('خطأ', 'فشل الاتصال بالخادم');
      return;
    }
    if (res['stat'] == 'ok') {
      final currentUserId = data_user_globle["id_user"];
      final all = List<Map<String, dynamic>>.from(res['data']);
      committeeMembers.assignAll(
        all.where((m) => m['id_user'] != currentUserId).toList(),
      );
    } else {
      mySnackbar('خطأ', res['msg'] ?? 'خطأ في جلب اللجنة');
    }
  }

  // Navigation
  bool canContinue(int step) {
    switch (step) {
      case 0:
        return selectedCenterId.value != null;
      case 1:
        return selectedCircleId.value != null;
      case 2:
        return selectedStudentId.value != null;
      case 3:
        return gradeControllers.values.every((c) => c.text.isNotEmpty);
      case 4:
        // يعتبر المنفذ الحالي عضوًا رئيسيًا ولا يجب ظهوره في القائمة
        return true;
      default:
        return false;
    }
  }

  void nextStep() {
    if (canContinue(currentStep.value) && currentStep.value < 5) {
      currentStep.value++;
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  // Calculations
  double calculateTotal() {
    double total = 0;
    gradeControllers.forEach((key, controller) {
      total += double.tryParse(controller.text) ?? 0;
    });
    return total;
  }

  double calculateAverage() {
    final total = calculateTotal();
    if (total == 0) return 0;
    final maxTotal = subjects.fold<int>(0, (sum, s) => sum + (s['MaxGrade'] as int));
    return (total / maxTotal) * 100;
  }

  String calculateGrade(double avg) {
    if (avg >= 90) return 'ممتاز';
    if (avg >= 75) return 'جيد جدًا';
    if (avg >= 60) return 'جيد';
    if(avg>=50) return 'مقبول';
     return 'راسب';

  }

  // Actions
  void toggleCommitteeMember(int memberId, bool? value) {
    if (value == true) {
      if (!selectedCommitteeIds.contains(memberId)) selectedCommitteeIds.add(memberId);
    } else {
      selectedCommitteeIds.remove(memberId);
    }
  }

  Future<void> saveGradesLocallySnack(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Expanded(child: Text('تم حفظ الدرجات بنجاح')),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> submitPromotion() async {
    // Build grades as array of {SubjectID, Grade}
    final grades = subjects.map((s) {
      final id = s['SubjectID'] as int;
      final val = int.tryParse(gradeControllers[id]?.text ?? '0') ?? 0;
      return {"SubjectID": id, "Grade": val};
    }).toList();

    final currentUserId = data_user_globle["id_user"];

    final payload = {
      "id_circle": selectedCircleId.value,
      "id_student": selectedStudentId.value,
      "id_level": students.firstWhereOrNull((e) => e['id_student'] == selectedStudentId.value)?['id_level'],
      "id_teacher": circles.firstWhereOrNull((e) => e['id_circle'] == selectedCircleId.value)?['id_user'],
      "id_committee": currentUserId, // منفذ العملية
      "committee": selectedCommitteeIds.toList(), // array of committee user IDs
      "grades": grades,
      "average": calculateAverage(),
    };

    // ✅ إضافة id_promotion في حالة التعديل
    if (isEditMode.value && currentPromotionId.value != null) {
      payload['id_promotion'] = currentPromotionId.value;
    }
    print("payload=====${payload}");
    // ✅ اختيار API المناسب (تعديل أو إضافة)
    final apiUrl = isEditMode.value ? Linkapi.update_promotion : Linkapi.insert_promotion;
    final loadingMsg = isEditMode.value ? 'جاري تحديث الترفيع...' : 'جاري حفظ الترفيع...';
    final successMsg = isEditMode.value ? 'تم تحديث الترفيع بنجاح' : 'تمت عملية الترفيع بنجاح';

    final res =  await handleRequest<dynamic>(
      isLoading: isLoading,
      loadingMessage: loadingMsg,
      useDialog: true,
      immediateLoading: true,

      action: () async {
        return await postData(apiUrl, payload);
      },
    );

    if (res == null) return;
    if (res is! Map) {
      mySnackbar('خطأ', 'فشل الاتصال بالخادم');
      return;
    }
    if (res['stat'] == 'ok') {
      mySnackbar('تم', successMsg, type: "g");
      resetForm();
    } else {
      mySnackbar('خطأ', res['msg'] ?? 'تعذر حفظ الترفيع');
    }
  }

  void resetForm() {
    selectedCenterId.value = null;
    selectedCenterName.value = null;
    selectedCircleId.value = null;
    selectedCircleName.value = null;
    selectedStudentId.value = null;
    selectedStudentName.value = null;
    circles.clear();
    students.clear();
    for (final c in gradeControllers.values) {
      c.clear();
    }
    selectedCommitteeIds.clear();
    committeeQuery.value = '';
    currentStep.value = 0;
    // ✅ إعادة تعيين وضع التعديل
    isEditMode.value = false;
    currentPromotionId.value = null;
  }

  // Helpers for UI binding
  String? get selectedStudentLevelName {
    final st = students.firstWhereOrNull((e) => e['id_student'] == selectedStudentId.value);
    return st != null ? st['name_level']?.toString() : null;
  }

  String? get selectedStudentStageName {
    final st = students.firstWhereOrNull((e) => e['id_student'] == selectedStudentId.value);
    return st != null ? st['name_stages']?.toString() : null;
  }

  List<String> get selectedCommitteeNames {
    final ids = selectedCommitteeIds.toSet();
    return committeeMembers
        .where((m) => ids.contains(m['id_user']))
        .map((m) => m['username']?.toString() ?? '')
        .where((n) => n.isNotEmpty)
        .toList();
  }

  // EDIT: load existing promotion and prefill
  Future<bool> loadPromotionForEdit(int idPromotion) async {
    final res = await handleRequest<dynamic>(
      isLoading: isLoading,
      useDialog: true,
      loadingMessage: 'جاري تحميل بيانات الترفيع...',
      immediateLoading: true,
      action: () async {
        return await postData(Linkapi.select_promotion_details, {
          'id_promotion': idPromotion,
        });
      },
    );
    if (res == null || res is! Map || res['stat'] != 'ok') return false;
    final data = res['data'] as Map<String, dynamic>;
    final p = Map<String, dynamic>.from(data['promotion']);
    final grades = List<Map<String, dynamic>>.from(data['grades'] ?? []);
    final committee = List<Map<String, dynamic>>.from(data['committee'] ?? []);

    // ✅ تفعيل وضع التعديل
    isEditMode.value = true;
    currentPromotionId.value = idPromotion;

    // Select center → circles → students sequentially
    final centerId = p['center_id'] as int;
    await fetchCenters();
    selectedCenterId.value = centerId;
    selectedCenterName.value = p['center_name']?.toString();
    await fetchCirclesForCenter(centerId);
    final circleId = p['id_circle'] as int;
    final circleMatch = circles.firstWhereOrNull((e) => e['id_circle'] == circleId);
    if (circleMatch != null) {
      await selectCircle(circleMatch);
    }

    // Select student
    final studentId = p['id_student'] as int;
    selectedStudentId.value = studentId;
    final studentMatch = students.firstWhereOrNull((e) => e['id_student'] == studentId);
    selectedStudentName.value = studentMatch != null ? studentMatch['name_student'] : null;

    // Subjects and grades
    await fetchSubjects();
    for (final g in grades) {
      final sid = g['SubjectID'] as int;
      final grade = g['Grade']?.toString() ?? '';
      if (gradeControllers.containsKey(sid)) {
        gradeControllers[sid]!.text = grade;
      }
    }

    // Committee (exclude current user)
    final currentUserId = data_user_globle['id_user'];
    selectedCommitteeIds.assignAll(
      committee.map<int>((m) => m['id_user'] as int).where((id) => id != currentUserId),
    );

    // Jump to review step
    currentStep.value = 3;
    return true;
  }
}


