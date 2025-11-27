import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../api/LinkApi.dart';
import '../../../api/apiFunction.dart';
import '../../../constants/appButton.dart';
import '../../../constants/customTextField.dart';
import '../../../constants/function.dart';
import '../../../constants/app_theme.dart';

class ResignationRequestPage extends StatelessWidget {
  final ResignationController controller = Get.put(ResignationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          "طلب استقالة - مدير المركز",
          style: AppTheme.headingMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryColor,
                AppTheme.primaryColor.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.backgroundColor,
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // معلومات المستخدم
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white,
                    Colors.grey.shade50,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                boxShadow: AppTheme.cardShadow,
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppTheme.spacingMedium),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                          ),
                          child: Icon(
                            Icons.person_outline,
                            color: AppTheme.primaryColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacingMedium),
                        Text(
                          "معلومات مدير المركز",
                          style: AppTheme.headingSmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingMedium),
                    _buildInfoRow("الاسم:", controller.userName),
                    _buildInfoRow("المنصب:", controller.userPosition),

                  ],
                ),
              ),
            ),
            
            const SizedBox(height: AppTheme.spacingLarge),
            
            // تاريخ الاستقالة المطلوب
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingLarge),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.reportColors[0].withOpacity(0.1),
                    AppTheme.reportColors[0].withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                border: Border.all(
                  color: AppTheme.reportColors[0].withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppTheme.spacingSmall),
                        decoration: BoxDecoration(
                          color: AppTheme.reportColors[0].withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                        ),
                        child: Icon(
                          Icons.calendar_today_outlined,
                          color: AppTheme.reportColors[0],
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingSmall),
                      Text(
                        "تاريخ الاستقالة المطلوب",
                        style: AppTheme.headingSmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.reportColors[0],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingMedium),
                  CustomTextField(
                    controller: controller.resignationDateController,
                    label: "تاريخ الاستقالة",
                    hint: "اختر التاريخ",
                    readOnly: true,
                    suffixIcon: Icons.calendar_today,
                    onTap: () => controller.selectResignationDate(context),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppTheme.spacingLarge),
            
            // سبب الاستقالة
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingLarge),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.reportColors[1].withOpacity(0.1),
                    AppTheme.reportColors[1].withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                border: Border.all(
                  color: AppTheme.reportColors[1].withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppTheme.spacingSmall),
                        decoration: BoxDecoration(
                          color: AppTheme.reportColors[1].withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                        ),
                        child: Icon(
                          Icons.help_outline,
                          color: AppTheme.reportColors[1],
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingSmall),
                      Text(
                        "سبب الاستقالة",
                        style: AppTheme.headingSmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.reportColors[1],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingMedium),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      border: Border.all(
                        color: AppTheme.reportColors[1].withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Obx(() => RadioListTile<String>(
                          title: const Text("ظروف شخصية"),
                          value: "ظروف شخصية",
                          groupValue: controller.selectedReason.value,
                          onChanged: (value) => controller.selectedReason.value = value!,
                          activeColor: AppTheme.reportColors[1],
                        )),
                        Obx(() => RadioListTile<String>(
                          title: const Text("فرصة إدارية أفضل"),
                          value: "فرصة إدارية أفضل",
                          groupValue: controller.selectedReason.value,
                          onChanged: (value) => controller.selectedReason.value = value!,
                          activeColor: AppTheme.reportColors[1],
                        )),
                        Obx(() => RadioListTile<String>(
                          title: const Text("ظروف صحية"),
                          value: "ظروف صحية",
                          groupValue: controller.selectedReason.value,
                          onChanged: (value) => controller.selectedReason.value = value!,
                          activeColor: AppTheme.reportColors[1],
                        )),
                        Obx(() => RadioListTile<String>(
                          title: const Text("انتقال لمدينة أخرى"),
                          value: "انتقال لمدينة أخرى",
                          groupValue: controller.selectedReason.value,
                          onChanged: (value) => controller.selectedReason.value = value!,
                          activeColor: AppTheme.reportColors[1],
                        )),
                        Obx(() => RadioListTile<String>(
                          title: const Text("أخرى"),
                          value: "أخرى",
                          groupValue: controller.selectedReason.value,
                          onChanged: (value) => controller.selectedReason.value = value!,
                          activeColor: AppTheme.reportColors[1],
                        )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppTheme.spacingLarge),
            
            // تفاصيل إضافية
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingLarge),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.reportColors[2].withOpacity(0.1),
                    AppTheme.reportColors[2].withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                border: Border.all(
                  color: AppTheme.reportColors[2].withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppTheme.spacingSmall),
                        decoration: BoxDecoration(
                          color: AppTheme.reportColors[2].withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                        ),
                        child: Icon(
                          Icons.note_outlined,
                          color: AppTheme.reportColors[2],
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingSmall),
                      Text(
                        "تفاصيل إضافية (اختياري)",
                        style: AppTheme.headingSmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.reportColors[2],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingMedium),
                  CustomTextField(
                    controller: controller.additionalDetailsController,
                    label: "تفاصيل إضافية",
                    hint: "اكتب أي تفاصيل إضافية تود إضافتها...",
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppTheme.spacingLarge),
            
            // ملاحظة مهمة
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingLarge),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.orange.shade50,
                    Colors.orange.shade100,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                border: Border.all(
                  color: Colors.orange.shade200,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacingSmall),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    ),
                    child: Icon(
                      Icons.info_outline,
                      color: Colors.orange.shade700,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingMedium),
                  Expanded(
                    child: Text(
                      "سيتم مراجعة طلب الاستقالة من قبل الإدارة العليا وستتلقى رداً خلال 5-7 أيام عمل",
                      style: AppTheme.bodyMedium.copyWith(
                        color: Colors.orange.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppTheme.spacingXXLarge),
            
            // أزرار الإجراءات
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                        onTap: () => Get.back(),
                        child: Padding(
                          padding: const EdgeInsets.all(AppTheme.spacingLarge),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.close,
                                color: Colors.grey.shade600,
                                size: 20,
                              ),
                              const SizedBox(width: AppTheme.spacingSmall),
                              Text(
                                "إلغاء",
                                style: AppTheme.bodyLarge.copyWith(
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMedium),
                Expanded(
                  flex: 2,
                  child: Obx(() => Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor,
                          AppTheme.primaryColor.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                        onTap: controller.isLoading.value ? null : controller.submitResignation,
                        child: Padding(
                          padding: const EdgeInsets.all(AppTheme.spacingLarge),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (controller.isLoading.value)
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    strokeWidth: 2,
                                  ),
                                )
                              else
                                Icon(
                                  Icons.send_outlined,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              const SizedBox(width: AppTheme.spacingSmall),
                              Text(
                                "تقديم طلب الاستقالة",
                                style: AppTheme.bodyLarge.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )),
                ),
              ],
            ),
            
            const SizedBox(height: AppTheme.spacingLarge),
          ],
        ),
      ),
    )
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingSmall),
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor.withOpacity(0.8),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
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
  String get userPosition => "مدير المركز"; 

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
              "تم تقديم طلب الاستقالة بنجاح. ستتلقى رداً من الإدارة العليا خلال 5-7 أيام عمل.",
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
