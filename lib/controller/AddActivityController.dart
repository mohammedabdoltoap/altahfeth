import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../api/LinkApi.dart';
import '../api/apiFunction.dart';
import '../constants/function.dart';
import '../globals.dart';

class AddActivityController extends GetxController {
  var dataArg;

  RxBool isLoading = false.obs;
  RxBool isSaving = false.obs;

  // قوائم البيانات
  RxList<Map<String, dynamic>> activities = <Map<String, dynamic>>[].obs;

  // بيانات الحلقة من arguments
  int? circleId;
  String? circleName;

  // الاختيارات
  Rxn<int> selectedActivityId = Rxn<int>();
  Rxn<DateTime> selectedDate = Rxn<DateTime>();

  // حقول الإدخال
  final TextEditingController participantsController = TextEditingController();
  final TextEditingController goalController = TextEditingController();
  final TextEditingController achievementController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    dataArg = Get.arguments;
    
    // استخراج بيانات الحلقة من arguments
    circleId = dataArg["id_circle"];
    circleName = dataArg["name_circle"];
    
    selectedDate.value = DateTime.now();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    isLoading.value = true;
    try {
      await fetchActivities();
    } finally {
      isLoading.value = false;
    }
  }

  /// جلب أنواع الأنشطة
  Future<void> fetchActivities() async {
    final res = await handleRequest<dynamic>(
      isLoading: RxBool(false),
      useDialog: false,
      immediateLoading: false,
      action: () async {
        return await postData(Linkapi.select_activities, {});
      },
    );

    if (res == null) return;
    if (res is! Map) {
      mySnackbar('خطأ', 'فشل الاتصال بالخادم');
      return;
    }

    if (res['stat'] == 'ok') {
      activities.assignAll(List<Map<String, dynamic>>.from(res['data']));
    } else {
      activities.clear();
    }
  }

  /// حفظ النشاط
  Future<void> saveActivity() async {
    // التحقق من البيانات
    if (selectedActivityId.value == null) {
      mySnackbar('تنبيه', 'يرجى اختيار نوع النشاط');
      return;
    }

    if (circleId == null) {
      mySnackbar('خطأ', 'بيانات الحلقة غير موجودة');
      return;
    }

    if (selectedDate.value == null) {
      mySnackbar('تنبيه', 'يرجى اختيار التاريخ');
      return;
    }

    final payload = {
      "id_user": dataArg["id_user"],
      "id_activity": selectedActivityId.value,
      "id_circle": circleId,
      "activity_date": "${selectedDate.value!.year}-${selectedDate.value!.month.toString().padLeft(2, '0')}-${selectedDate.value!.day.toString().padLeft(2, '0')}",
      "participants_count": int.tryParse(participantsController.text) ?? 0,
      "goal": goalController.text.trim(),
      "goal_achievement_percentage": double.tryParse(achievementController.text) ?? 0.0,
      "notes": notesController.text.trim(),
    };

    final res = await handleRequest<dynamic>(
      isLoading: isSaving,
      loadingMessage: 'جاري حفظ النشاط...',
      useDialog: true,
      immediateLoading: true,
      action: () async {
        return await postData(Linkapi.insert_activity, payload);
      },
    );

    if (res == null) return;
    if (res is! Map) {
      mySnackbar('خطأ', 'فشل الاتصال بالخادم');
      return;
    }

    if (res['stat'] == 'ok') {
      Get.back();
      mySnackbar('تم', 'تم حفظ النشاط بنجاح', type: "g");
    } else {
      mySnackbar('خطأ', res['msg'] ?? 'تعذر حفظ النشاط');
    }
  }



  @override
  void onClose() {
    participantsController.dispose();
    goalController.dispose();
    achievementController.dispose();
    notesController.dispose();
    super.onClose();
  }
}
