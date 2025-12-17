import 'package:althfeth/api/LinkApi.dart';
import 'package:althfeth/api/apiFunction.dart';
import 'package:althfeth/constants/customTextField.dart';
import 'package:althfeth/constants/function.dart';
import 'package:althfeth/constants/app_theme.dart';
import 'package:althfeth/view/widget/curriculum_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Mathurat extends StatelessWidget {
  final MathurController controller = Get.put(MathurController());
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'تحديد نطاق المأثورات',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.backgroundColor,
              Colors.white,
            ],
          ),
        ),
        child: Obx(() {
          // حالة التحميل
          if (controller.isLoading.value && controller.items.isEmpty) {
            return Center(
              child: Container(
                padding: EdgeInsets.all(AppTheme.spacingXLarge),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppTheme.primaryColor),
                    SizedBox(height: AppTheme.spacingLarge),
                    Text(
                      'جاري تحميل المأثورات...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          
          // حالة فارغة
          if (controller.items.isEmpty) {
            return Center(
              child: Container(
                margin: EdgeInsets.all(AppTheme.spacingXLarge),
                padding: EdgeInsets.all(AppTheme.spacingXXLarge),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.grey[50]!],
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(AppTheme.spacingLarge),
                      decoration: BoxDecoration(
                        color: AppTheme.reportColors[4].withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.bookmark,
                        size: 64,
                        color: AppTheme.reportColors[4],
                      ),
                    ),
                    SizedBox(height: AppTheme.spacingLarge),
                    Text(
                      'لا توجد مأثورات متاحة',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.reportColors[4],
                      ),
                    ),
                    SizedBox(height: AppTheme.spacingSmall),
                    Text(
                      'لم يتم العثور على أي مأثورات في قاعدة البيانات',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: AppTheme.spacingLarge),
                    ElevatedButton.icon(
                      onPressed: () => controller.loadData(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('إعادة المحاولة'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.reportColors[4],
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingXLarge,
                          vertical: AppTheme.spacingMedium,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          
          // صفحة اختيار النطاق
          return SingleChildScrollView(
            padding: EdgeInsets.all(AppTheme.spacingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // معلومات الطالب
                StudentInfoCard(
                  studentName: controller.studentData['name_student']?.toString() ?? 'غير محدد',
                ),
                
                SizedBox(height: AppTheme.spacingLarge),

                // آخر تسميع
                if (controller.lastMathurat.isNotEmpty)
                  LastRecordCard(
                    title: 'آخر تسميع',
                    date: controller.lastMathurat["date"]?.toString() ?? '-',
                    startItemName: controller.lastMathurat["start_item_name"]?.toString() ?? '-',
                    endItemName: controller.lastMathurat["end_item_name"]?.toString() ?? '-',
                    mark: controller.lastMathurat["mark"]?.toString() ?? '-',
                    onEdit: () => controller.showEditDialog(),
                    accentColor: AppTheme.reportColors[1],
                  )
                else
                  Container(
                    padding: EdgeInsets.all(AppTheme.spacingMedium),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                        SizedBox(width: AppTheme.spacingSmall),
                        Expanded(
                          child: Text(
                            'أول تسميع مأثورات لهذا الطالب',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                SizedBox(height: AppTheme.spacingLarge),

                // قسم نطاق البداية
                SectionHeader(
                  icon: Icons.play_arrow_rounded,
                  title: 'نطاق البداية',
                  color: Colors.green[700]!,
                ),
                SizedBox(height: AppTheme.spacingMedium),
                CustomDropdown(
                  value: controller.selectedStartItem.value,
                  hint: 'اختر مأثورة البداية',
                  items: controller.items,
                  idKey: 'id_Mathurat',
                  nameKey: 'name_Mathurat',
                  onChanged: (value) {
                    controller.selectedStartItem.value = value;
                  },
                  accentColor: Colors.green[700]!,
                ),
                
                SizedBox(height: AppTheme.spacingLarge),
                
                // قسم نطاق النهاية
                SectionHeader(
                  icon: Icons.stop_rounded,
                  title: 'نطاق النهاية',
                  color: Colors.red[700]!,
                ),
                SizedBox(height: AppTheme.spacingMedium),
                CustomDropdown(
                  value: controller.selectedEndItem.value,
                  hint: 'اختر مأثورة النهاية',
                  items: controller.items,
                  idKey: 'id_Mathurat',
                  nameKey: 'name_Mathurat',
                  onChanged: (value) {
                    controller.selectedEndItem.value = value;
                  },
                  accentColor: Colors.red[700]!,
                ),
                
                SizedBox(height: AppTheme.spacingLarge),
                
                CustomTextField(
                  controller: controller.controller_text,
                  label: "التقييم",
                  hint: "الدرجة (0-100)",
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.grade_rounded,
                ),
                
                SizedBox(height: AppTheme.spacingXXLarge),

                // زر الحفظ
                SaveButton(
                  isLoading: controller.isSaving.value,
                  onPressed: () => controller.saveMahuratRange(false),
                  label: 'حفظ نطاق المأثورات',
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
  
}

class MathurController extends GetxController {
  var items = <Map<String, dynamic>>[].obs;
  RxMap lastMathurat = <String, dynamic>{}.obs;
  RxBool isLoading = false.obs;
  RxBool isSaving = false.obs;
  TextEditingController controller_text = TextEditingController();
  
  // بيانات الطالب من الـ arguments
  var studentData = <String, dynamic>{};
  
  // المأثورات المختارة
  Rx<Map<String, dynamic>?> selectedStartItem = Rx<Map<String, dynamic>?>(null);
  Rx<Map<String, dynamic>?> selectedEndItem = Rx<Map<String, dynamic>?>(null);
  
  @override
  void onInit() {
    super.onInit();
    // استلام بيانات الطالب
    if (Get.arguments != null) {
      studentData = Get.arguments;
    }
    loadData();
    selectLastMathurat();
  }
  
  Future<void> loadData() async {
    var res = await handleRequest(
      isLoading: isLoading,
      action: () async {
        return await postData(Linkapi.selectMathurat, {});
      },
    );
    
    if (res == null) return;
    
    if (res["stat"] == "ok") {
      final data = List<Map<String, dynamic>>.from(res["data"]);
      items.assignAll(data);
    } else if (res["stat"] == "no") {
      items.clear();
      mySnackbar("تنبيه", "لا توجد مأثورات متاحة");
    } else {
      mySnackbar("خطأ", res["msg"] ?? "خطأ في جلب البيانات");
    }
  }

  Future selectLastMathurat() async {
    var res = await handleRequest(
      isLoading: RxBool(false),
      action: () async {
        return await postData(Linkapi.selectLastMathurat, {
          "id_student": studentData['id_student'],
        });
      },
    );

    if (res == null) return;

    if (res["stat"] == "ok") {
      final data = Map<String, dynamic>.from(res["data"]);
      lastMathurat.assignAll(data);
    } else if (res["stat"] == "no") {
      lastMathurat.clear();
    } else {
      mySnackbar("خطأ", res["msg"] ?? "خطأ في جلب آخر تسميع");
    }
  }

  // حفظ نطاق المأثورات للطالب
  Future<bool> saveMahuratRange(isEdit) async {
    // التحقق من اختيار النطاقين
    if (selectedStartItem.value == null) {
      mySnackbar("تنبيه", "الرجاء اختيار مأثورة البداية");
      return false;
    }
    
    if (selectedEndItem.value == null) {
      mySnackbar("تنبيه", "الرجاء اختيار مأثورة النهاية");
      return false;
    }
    
    // التحقق من أن البداية قبل النهاية
    int startNum = int.tryParse(selectedStartItem.value!['id_Mathurat']?.toString() ?? '0') ?? 0;
    int endNum = int.tryParse(selectedEndItem.value!['id_Mathurat']?.toString() ?? '0') ?? 0;
    
    if (startNum > endNum) {
      mySnackbar("خطأ", "مأثورة البداية يجب أن تكون قبل مأثورة النهاية");
      return false;
    }
    
    if (controller_text.text.isEmpty) {
      mySnackbar("خطأ", "يجب تحديد درجة للطالب");
      return false;
    }

    if (int.tryParse(controller_text.text.isEmpty ? "0" : controller_text.text)! < 0 ||
        int.tryParse(controller_text.text.isEmpty ? "0" : controller_text.text)! > 100
    ) {
      mySnackbar("خطأ", "يجب تحديد درجة للطالب بين 0-100");
      return false;
    }

    // التحقق من وجود سجل سابق للتعديل
    bool isEditing = lastMathurat.isNotEmpty && lastMathurat['id'] != null;

    var data = {
      "id_student": studentData['id_student'],
      "start_item_id": selectedStartItem.value?['id_Mathurat'] ?? 1,
      "end_item_id": selectedEndItem.value?['id_Mathurat'] ?? 1,
      "mark": controller_text.text.trim(),
    };
    
    // إضافة id إذا كان تعديل
    if (isEditing) {
      data["id"] = lastMathurat['id'];
    }

    var res = await handleRequest(
      isLoading: isSaving,
      action: () async {
        // استخدام API التعديل أو الإضافة حسب الحالة
        return await postData(
          isEdit ? Linkapi.updateStudentMathurRange : Linkapi.saveStudentMahuratRange,
          data
        );
      },
    );

    if (res == null) return false;

    if (res["stat"] == "ok") {
      mySnackbar("نجاح", "تم حفظ نطاق المأثورات بنجاح", type: "g");
      await selectLastMathurat();
      selectedStartItem.value = null;
      selectedEndItem.value = null;
      controller_text.clear();
      return true;
    } else {
      mySnackbar("خطأ", res["msg"] ?? "خطأ في حفظ النطاق");
      return false;
    }
  }

  // دالة عرض dialog التعديل
  void showEditDialog() {
    if (lastMathurat.isEmpty) return;
    
    // تعبئة الحقول بالبيانات الحالية
    Map<String, dynamic>? startItem;
    Map<String, dynamic>? endItem;
    try {
      startItem = items.firstWhere(
        (item) => item['id_Mathurat'] == lastMathurat['start_item_id'],
      );
    } catch (_) {
      startItem = null;
    }
    try {
      endItem = items.firstWhere(
        (item) => item['id_Mathurat'] == lastMathurat['end_item_id'],
      );
    } catch (_) {
      endItem = null;
    }

    selectedStartItem.value = startItem;
    selectedEndItem.value = endItem;
    controller_text.text = lastMathurat['mark']?.toString() ?? '';
    
    Get.dialog(
      Obx(() => EditRecordDialog(
        title: 'تعديل آخر تسميع',
        date: lastMathurat["date"]?.toString() ?? '-',
        startDropdown: CustomDropdown(
          value: selectedStartItem.value,
          hint: 'اختر مأثورة البداية',
          items: items,
          idKey: 'id_Mathurat',
          nameKey: 'name_Mathurat',
          onChanged: (value) {
            selectedStartItem.value = value;
          },
          accentColor: AppTheme.reportColors[1],
        ),
        endDropdown: CustomDropdown(
          value: selectedEndItem.value,
          hint: 'اختر مأثورة النهاية',
          items: items,
          idKey: 'id_Mathurat',
          nameKey: 'name_Mathurat',
          onChanged: (value) {
            selectedEndItem.value = value;
          },
          accentColor: AppTheme.reportColors[1],
        ),
        markController: controller_text,
        isSaving: isSaving.value,
        onSave: () async {
          final success = await saveMahuratRange(true);
          if (success) {
            Get.back();
          }
        },
        onCancel: () => Get.back(),
        accentColor: AppTheme.reportColors[1],
      )),
    );
  }
}
