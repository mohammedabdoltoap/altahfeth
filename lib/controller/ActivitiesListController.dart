import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../api/LinkApi.dart';
import '../api/apiFunction.dart';
import '../constants/function.dart';

class ActivitiesListController extends GetxController {
  var dataArg;

  RxBool isLoading = false.obs;
  RxList<Map<String, dynamic>> activities = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    dataArg = Get.arguments;
    fetchActivities();
  }

  /// جلب الأنشطة السابقة
  Future<void> fetchActivities() async {
    final res = await handleRequest<dynamic>(
      isLoading: isLoading,
      useDialog: false,
      immediateLoading: true,
      loadingMessage: 'جاري تحميل الأنشطة...',
      action: () async {
        return await postData(Linkapi.select_user_activities, {
          "id_user": dataArg["id_user"],
          "id_circle": dataArg["id_circle"],
        });
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

  /// التحقق من إمكانية التعديل (خلال 3 أيام من تاريخ الإضافة)
  bool canEdit(String? createdDate) {
    if (createdDate == null || createdDate.isEmpty) return false;
    
    try {
      final date = DateTime.parse(createdDate);
      final now = DateTime.now();
      final difference = now.difference(date).inDays;
      return difference <= 3;
    } catch (e) {
      return false;
    }
  }

  /// حذف نشاط
  Future<void> deleteActivity(int idLog) async {
    bool? confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذا النشاط؟'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final res = await handleRequest<dynamic>(
      isLoading: isLoading,
      useDialog: true,
      immediateLoading: true,
      loadingMessage: 'جاري الحذف...',
      action: () async {
        return await postData(Linkapi.delete_activity, {"id_log": idLog});
      },
    );

    if (res == null) return;
    if (res is! Map) {
      mySnackbar('خطأ', 'فشل الاتصال بالخادم');
      return;
    }

    if (res['stat'] == 'ok') {
      mySnackbar('تم', 'تم حذف النشاط بنجاح', type: "g");
      fetchActivities(); // إعادة تحميل القائمة
    } else {
      mySnackbar('خطأ', res['msg'] ?? 'تعذر حذف النشاط');
    }
  }
}
