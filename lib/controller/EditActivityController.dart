import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../api/LinkApi.dart';
import '../api/apiFunction.dart';
import '../constants/function.dart';

class EditActivityController extends GetxController {
  var dataArg;
  Map<String, dynamic>? activity;

  RxBool isLoading = false.obs;
  RxBool isSaving = false.obs;

  // بيانات النشاط
  int? idLog;
  int? idActivity;
  String? activityName;
  int? circleId;
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
    activity = dataArg["activity"];
    
    _loadActivityData();
  }

  void _loadActivityData() {
    if (activity == null) return;

    idLog = activity!['id_log'];
    idActivity = activity!['id_activity'];
    activityName = activity!['name_activity'];
    circleId = activity!['id_circle'];

    // تحميل التاريخ
    try {
      selectedDate.value = DateTime.parse(activity!['activity_date']);
    } catch (e) {
      selectedDate.value = DateTime.now();
    }

    // تحميل الحقول
    participantsController.text = activity!['participants_count']?.toString() ?? '';
    goalController.text = activity!['goal'] ?? '';
    achievementController.text = activity!['goal_achievement_percentage']?.toString() ?? '';
    notesController.text = activity!['notes'] ?? '';
  }

  /// تحديث النشاط
  Future<void> updateActivity() async {
    // التحقق من البيانات
    if (idLog == null) {
      mySnackbar('خطأ', 'معرف النشاط غير موجود');
      return;
    }

    if (selectedDate.value == null) {
      mySnackbar('تنبيه', 'يرجى اختيار التاريخ');
      return;
    }

    final payload = {
      "id_log": idLog,
      "activity_date": "${selectedDate.value!.year}-${selectedDate.value!.month.toString().padLeft(2, '0')}-${selectedDate.value!.day.toString().padLeft(2, '0')}",
      "participants_count": int.tryParse(participantsController.text) ?? 0,
      "goal": goalController.text.trim(),
      "goal_achievement_percentage": double.tryParse(achievementController.text) ?? 0.0,
      "notes": notesController.text.trim(),
    };

    final res = await handleRequest<dynamic>(
      isLoading: isSaving,
      loadingMessage: 'جاري حفظ التعديلات...',
      useDialog: true,
      immediateLoading: true,
      action: () async {
        return await postData(Linkapi.update_activity, payload);
      },
    );

    if (res == null) return;
    if (res is! Map) {
      mySnackbar('خطأ', 'فشل الاتصال بالخادم');
      return;
    }

    if (res['stat'] == 'ok') {
      Get.back();
      mySnackbar('تم', 'تم تحديث النشاط بنجاح', type: "g");
    } else {
      mySnackbar('خطأ', res['msg'] ?? 'تعذر تحديث النشاط');
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
