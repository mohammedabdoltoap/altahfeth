import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../api/LinkApi.dart';
import '../../../api/apiFunction.dart';
import '../../../constants/appButton.dart';
import '../../../constants/customTextField.dart';
import '../../../constants/function.dart';

class TeacherResignationPage extends StatelessWidget {
  final TeacherResignationController controller = Get.put(TeacherResignationController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("طلب استقالة - الأستاذ"),
        centerTitle: true,
        backgroundColor: theme.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // معلومات المستخدم
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person, color: theme.primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          "معلومات ",
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    _buildInfoRow("الاسم:", controller.userName),

                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // تاريخ الاستقالة المطلوب
            Text(
              "تاريخ الاستقالة المطلوب",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            CustomTextField(
              controller: controller.resignationDateController,
              label: "تاريخ الاستقالة",
              hint: "اختر التاريخ",
              readOnly: true,
              suffixIcon: Icons.calendar_today,
              onTap: () => controller.selectResignationDate(context),
            ),
            
            const SizedBox(height: 20),
            
            // سبب الاستقالة
            Text(
              "سبب الاستقالة",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                children: [
                  Obx(() => RadioListTile<String>(
                    title: const Text("ظروف شخصية"),
                    value: "ظروف شخصية",
                    groupValue: controller.selectedReason.value,
                    onChanged: (value) => controller.selectedReason.value = value!,
                  )),
                  Obx(() => RadioListTile<String>(
                    title: const Text("فرصة عمل أفضل"),
                    value: "فرصة عمل أفضل",
                    groupValue: controller.selectedReason.value,
                    onChanged: (value) => controller.selectedReason.value = value!,
                  )),
                  Obx(() => RadioListTile<String>(
                    title: const Text("ظروف صحية"),
                    value: "ظروف صحية",
                    groupValue: controller.selectedReason.value,
                    onChanged: (value) => controller.selectedReason.value = value!,
                  )),
                  Obx(() => RadioListTile<String>(
                    title: const Text("انتقال لمدينة أخرى"),
                    value: "انتقال لمدينة أخرى",
                    groupValue: controller.selectedReason.value,
                    onChanged: (value) => controller.selectedReason.value = value!,
                  )),
                  Obx(() => RadioListTile<String>(
                    title: const Text("أخرى"),
                    value: "أخرى",
                    groupValue: controller.selectedReason.value,
                    onChanged: (value) => controller.selectedReason.value = value!,
                  )),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // تفاصيل إضافية
            CustomTextField(
              controller: controller.additionalDetailsController,
              label: "تفاصيل إضافية (اختياري)",
              hint: "اكتب أي تفاصيل إضافية تود إضافتها...",
            ),
            
            const SizedBox(height: 20),
            
            // ملاحظة مهمة
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "سيتم مراجعة طلب الاستقالة من قبل إدارة المركز وستتلقى رداً خلال 3-5 أيام عمل",
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // أزرار الإجراءات
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("إلغاء"),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Obx(() => AppButton(
                    text: "تقديم طلب الاستقالة",
                    isLoading: controller.isLoading.value,
                    onPressed: controller.submitResignation,
                  )),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TeacherResignationController extends GetxController {
  var dataArg;
  
  final TextEditingController resignationDateController = TextEditingController();
  final TextEditingController additionalDetailsController = TextEditingController();
  
  var selectedReason = "ظروف شخصية".obs;
  var isLoading = false.obs;
  
  String get userName => dataArg?["username"] ?? "غير محدد";

  @override
  void onInit() {
    super.onInit();
    dataArg = Get.arguments;
  }

  Future<void> selectResignationDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)), // شهر من الآن
      firstDate: DateTime.now().add(const Duration(days: 1)), // غداً على الأقل
      lastDate: DateTime.now().add(const Duration(days: 365)), // سنة من الآن
      helpText: "اختر تاريخ الاستقالة",
      cancelText: "إلغاء",
      confirmText: "تأكيد",
    );
    
    if (picked != null) {
      resignationDateController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  Future<void> submitResignation() async {
    // التحقق من إدخال التاريخ
    if (resignationDateController.text.isEmpty) {
      mySnackbar("تنبيه", "الرجاء اختيار تاريخ الاستقالة");
      return;
    }

    try {
      final res = await handleRequest<dynamic>(
        isLoading: isLoading,
        loadingMessage: "جاري تقديم طلب الاستقالة...",
        useDialog: true,
        immediateLoading: true,
        action: () async {
          // إرسال جميع البيانات المطلوبة إلى PHP
          Map<String, dynamic> requestData = {
            "id_user": dataArg["id_user"],
            "resignation_date": resignationDateController.text,
            "reason": selectedReason.value,
          };

          // إضافة التفاصيل الإضافية إذا كانت موجودة
          if (additionalDetailsController.text.isNotEmpty) {
            requestData["notes"] = additionalDetailsController.text;
          }

          // إضافة id_circle إذا كان موجوداً
          if (dataArg["id_circle"] != null) {
            requestData["id_circle"] = dataArg["id_circle"];
          }

          return await postData(Linkapi.addResignation, requestData);
        },
      );

      if (res == null) return;
      if (res is! Map) {
        mySnackbar("خطأ", "فشل الاتصال بالخادم");
        return;
      }

      if (res["stat"] == "ok") {
        Get.back();
        mySnackbar("تم تقديم طلب الاستقالة", "سيتم المراجعة قريباً", type: "g");
        
        // إظهار رسالة تأكيد
        Get.dialog(
          AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text("تم تقديم الطلب"),
              ],
            ),
            content: const Text(
              "تم تقديم طلب الاستقالة بنجاح. ستتلقى رداً من إدارة المركز خلال 3-5 أيام عمل.",
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text("موافق"),
              ),
            ],
          ),
        );
      } else if (res["stat"] == "no") {
        // حالة وجود استقالة مسبقة أو خطأ منطقي
        String errorMsg = res["message"] ?? res["msg"] ?? "لا يمكن تقديم الطلب";
        mySnackbar("تنبيه", errorMsg);
      } else {
        // حالة خطأ في الخادم
        String errorMsg = res["msg"] ?? res["message"] ?? "حصل خطأ أثناء تقديم الطلب";
        mySnackbar("خطأ", errorMsg);
      }
    } catch (e) {
      mySnackbar("خطأ", "حدث خطأ غير متوقع");
    }
  }
}
