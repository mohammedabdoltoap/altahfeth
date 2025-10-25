import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../api/LinkApi.dart';
import '../../../api/apiFunction.dart';
import '../../../constants/appButton.dart';
import '../../../constants/customTextField.dart';
import '../../../constants/function.dart';

class ResignationRequestPage extends StatelessWidget {
  final ResignationController controller = Get.put(ResignationController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("طلب استقالة"),
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
                          "معلومات الموظف",
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    _buildInfoRow("الاسم:", controller.userName),
                    _buildInfoRow("المنصب:", controller.userPosition),
                    _buildInfoRow("تاريخ التوظيف:", controller.hireDate),
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
              maxLines: 4,
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
                      "سيتم مراجعة طلب الاستقالة من قبل الإدارة وستتلقى رداً خلال 3-5 أيام عمل",
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

class ResignationController extends GetxController {
  var dataArg;
  
  final TextEditingController resignationDateController = TextEditingController();
  final TextEditingController additionalDetailsController = TextEditingController();
  
  var selectedReason = "ظروف شخصية".obs;
  var isLoading = false.obs;
  
  String get userName => dataArg?["username"] ?? "غير محدد";
  String get userPosition => "مدير مركز"; // يمكن تحديثه حسب نوع المستخدم
  String get hireDate => "2023-01-01"; // يمكن جلبه من البيانات

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
    // التحقق من البيانات
    if (resignationDateController.text.isEmpty) {
      mySnackbar("تنبيه", "يرجى اختيار تاريخ الاستقالة");
      return;
    }

    try {
      final res = await handleRequest<dynamic>(
        isLoading: isLoading,
        loadingMessage: "جاري تقديم طلب الاستقالة...",
        useDialog: true,
        immediateLoading: true,
        action: () async {
          return await postData(Linkapi.addResignation, {
            "id_user": dataArg["id_user"],
            "resignation_date": resignationDateController.text,
            "reason": selectedReason.value,
            "additional_details": additionalDetailsController.text.trim(),
            "request_date": DateTime.now().toIso8601String().split('T')[0],
          });
        },
      );

      if (res == null) return;
      if (res is! Map) {
        mySnackbar("خطأ", "فشل الاتصال بالخادم");
        return;
      }

      if (res["stat"] == "ok") {
        Get.back();
        mySnackbar("نجاح", "تم تقديم طلب الاستقالة بنجاح", type: "g");
        
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
              "تم تقديم طلب الاستقالة بنجاح. ستتلقى رداً من الإدارة خلال 3-5 أيام عمل.",
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text("موافق"),
              ),
            ],
          ),
        );
      } else {
        mySnackbar("تنبيه", res["msg"] ?? "فشل في تقديم الطلب");
      }
    } catch (e) {
      mySnackbar("خطأ", "حدث خطأ غير متوقع");
    }
  }
}
