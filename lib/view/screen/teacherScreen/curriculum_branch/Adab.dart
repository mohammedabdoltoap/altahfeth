import 'package:althfeth/api/LinkApi.dart';
import 'package:althfeth/api/apiFunction.dart';
import 'package:althfeth/constants/customTextField.dart';
import 'package:althfeth/constants/function.dart';
import 'package:althfeth/constants/app_theme.dart';
import 'package:althfeth/view/widget/curriculum_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Adab extends StatelessWidget {
  final AdabController adabController = Get.put(AdabController());

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
          'تحديد نطاق الآداب',
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
          if (adabController.isLoading.value && adabController.adabList.isEmpty) {
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
                      'جاري تحميل الآداب...',
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
          if (adabController.adabList.isEmpty) {
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
                    Icon(
                      Icons.menu_book_rounded,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: AppTheme.spacingLarge),
                    Text(
                      'لا توجد آداب متاحة',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: AppTheme.spacingSmall),
                    Text(
                      'يرجى المحاولة لاحقاً',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // المحتوى الرئيسي
          return SingleChildScrollView(
            padding: EdgeInsets.all(AppTheme.spacingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // معلومات الطالب
                StudentInfoCard(
                  studentName: adabController.studentData['name_student']?.toString() ?? 'غير محدد',
                ),
                
                SizedBox(height: AppTheme.spacingLarge),

                // آخر تسميع
                if (adabController.lastAdab.isNotEmpty)
                  LastRecordCard(
                    title: 'آخر تسميع',
                    date: adabController.lastAdab["date"]?.toString() ?? '-',
                    startItemName: adabController.lastAdab["start_item_name"]?.toString() ?? '-',
                    endItemName: adabController.lastAdab["end_item_name"]?.toString() ?? '-',
                    mark: adabController.lastAdab["mark"]?.toString() ?? '-',
                    onEdit: () => adabController.showEditDialog(),
                    accentColor: AppTheme.reportColors[3],
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
                            'أول تسميع آداب لهذا الطالب',
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
                  value: adabController.selectedStartAdab.value,
                  hint: 'اختر أدب البداية',
                  items: adabController.adabList,
                  idKey: 'id_Adab',
                  nameKey: 'name_Adab',
                  onChanged: (value) {
                    adabController.selectedStartAdab.value = value;
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
                  value: adabController.selectedEndAdab.value,
                  hint: 'اختر أدب النهاية',
                  items: adabController.adabList,
                  idKey: 'id_Adab',
                  nameKey: 'name_Adab',
                  onChanged: (value) {
                    adabController.selectedEndAdab.value = value;
                  },
                  accentColor: Colors.red[700]!,
                ),
                
                SizedBox(height: AppTheme.spacingLarge),
                
                CustomTextField(
                  controller: adabController.controller_text,
                  label: "التقييم",
                  hint: "الدرجة (0-100)",
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.grade_rounded,
                ),
                
                SizedBox(height: AppTheme.spacingXXLarge),

                // زر الحفظ
                SaveButton(
                  isLoading: adabController.isSaving.value,
                  onPressed: () => adabController.saveAdabRange(false),
                  label: 'حفظ نطاق الآداب',
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class AdabController extends GetxController {
  var adabList = <Map<String, dynamic>>[].obs;
  RxMap lastAdab = <String, dynamic>{}.obs;
  RxBool isLoading = false.obs;
  RxBool isSaving = false.obs;
  TextEditingController controller_text = TextEditingController();
  
  var studentData = <String, dynamic>{};
  
  Rx<Map<String, dynamic>?> selectedStartAdab = Rx<Map<String, dynamic>?>(null);
  Rx<Map<String, dynamic>?> selectedEndAdab = Rx<Map<String, dynamic>?>(null);
  
  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      studentData = Get.arguments;
    }
    selectAdab();
    selectLastAdab();
  }
  
  Future selectAdab() async {
    var res = await handleRequest(
      isLoading: isLoading,
      action: () async {
        return await postData(Linkapi.selectAdab, {});
      },
    );
    
    if (res == null) return;
    
    if (res["stat"] == "ok") {
      final data = List<Map<String, dynamic>>.from(res["data"]);
      adabList.assignAll(data);
    } else if (res["stat"] == "no") {
      adabList.clear();
      mySnackbar("تنبيه", "لا توجد آداب متاحة");
    } else {
      mySnackbar("خطأ", res["msg"] ?? "خطأ في جلب الآداب");
    }
  }

  Future selectLastAdab() async {
    var res = await handleRequest(
      isLoading: RxBool(false),
      action: () async {
        return await postData(Linkapi.selectLastAdab, {
          "id_student": studentData['id_student'],
        });
      },
    );

    if (res == null) return;

    if (res["stat"] == "ok") {
      final data = Map<String, dynamic>.from(res["data"]);
      lastAdab.assignAll(data);
    } else if (res["stat"] == "no") {
      lastAdab.clear();
    } else {
      mySnackbar("خطأ", res["msg"] ?? "خطأ في جلب آخر تسميع");
    }
  }
  
  Future<bool> saveAdabRange(isEdit) async {
    if (selectedStartAdab.value == null) {
      mySnackbar("تنبيه", "الرجاء اختيار أدب البداية");
      return false;
    }
    
    if (selectedEndAdab.value == null) {
      mySnackbar("تنبيه", "الرجاء اختيار أدب النهاية");
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

    bool isEditing = lastAdab.isNotEmpty && lastAdab['id'] != null;
    
    var data = {
      "id_student": studentData['id_student'],
      "start_adab_id": selectedStartAdab.value?['id_Adab'] ?? 1,
      "end_adab_id": selectedEndAdab.value?['id_Adab'] ?? 1,
      "mark": controller_text.text.trim(),
    };
    
    if (isEditing) {
      data["id"] = lastAdab['id'];
    }

    var res = await handleRequest(
      isLoading: isSaving,
      action: () async {
        return await postData(
            isEdit ? Linkapi.updateStudentAdabRange : Linkapi.saveStudentAdabRange,
          data
        );
      },
    );

    if (res == null) return false;

    if (res["stat"] == "ok") {
      mySnackbar("نجاح", "تم حفظ نطاق الآداب بنجاح", type: "g");
      await selectLastAdab();
      selectedStartAdab.value = null;
      selectedEndAdab.value = null;
      controller_text.clear();
      return true;
    } else {
      mySnackbar("خطأ", res["msg"] ?? "خطأ في حفظ النطاق");
      return false;
    }
  }

  void showEditDialog() {
    if (lastAdab.isEmpty) return;
    
    Map<String, dynamic>? startItem;
    Map<String, dynamic>? endItem;
    try {
      startItem = adabList.firstWhere(
        (adab) => adab['id_Adab'] == lastAdab['start_adab_id'],
      );
    } catch (_) {
      startItem = null;
    }
    try {
      endItem = adabList.firstWhere(
        (adab) => adab['id_Adab'] == lastAdab['end_adab_id'],
      );
    } catch (_) {
      endItem = null;
    }

    selectedStartAdab.value = startItem;
    selectedEndAdab.value = endItem;
    controller_text.text = lastAdab['mark']?.toString() ?? '';
    
    Get.dialog(
      Obx(() => EditRecordDialog(
        title: 'تعديل آخر تسميع',
        date: lastAdab["date"]?.toString() ?? '-',
        startDropdown: CustomDropdown(
          value: selectedStartAdab.value,
          hint: 'اختر أدب البداية',
          items: adabList,
          idKey: 'id_Adab',
          nameKey: 'name_Adab',
          onChanged: (value) {
            selectedStartAdab.value = value;
          },
          accentColor: AppTheme.reportColors[3],
        ),
        endDropdown: CustomDropdown(
          value: selectedEndAdab.value,
          hint: 'اختر أدب النهاية',
          items: adabList,
          idKey: 'id_Adab',
          nameKey: 'name_Adab',
          onChanged: (value) {
            selectedEndAdab.value = value;
          },
          accentColor: AppTheme.reportColors[3],
        ),
        markController: controller_text,
        isSaving: isSaving.value,
        onSave: () async {
          final success = await saveAdabRange(true);
          if (success) {
            Get.back();
          }
        },
        onCancel: () => Get.back(),
        accentColor: AppTheme.reportColors[3],
      )),
    );
  }
}
