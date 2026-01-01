import 'package:althfeth/api/LinkApi.dart';
import 'package:althfeth/api/apiFunction.dart';
import 'package:althfeth/constants/customTextField.dart';
import 'package:althfeth/constants/function.dart';
import 'package:althfeth/constants/app_theme.dart';
import 'package:althfeth/view/widget/curriculum_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NamesGod extends StatelessWidget {
  final NamesGodController namesGodController = Get.put(NamesGodController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.reportColors[2],
                AppTheme.reportColors[2].withOpacity(0.85),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            SizedBox(width: 12),
            Text(
              'أسماء الله الحسنى',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
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
              AppTheme.reportColors[2].withOpacity(0.05),
              Colors.white,
              AppTheme.backgroundColor.withOpacity(0.3),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Obx(() {
          // حالة التحميل
          if (namesGodController.isLoading.value && namesGodController.namesGodList.isEmpty) {
            return Center(
              child: Container(
                margin: EdgeInsets.all(AppTheme.spacingXLarge),
                padding: EdgeInsets.all(AppTheme.spacingXXLarge),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white,
                      AppTheme.reportColors[2].withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.reportColors[2].withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: Colors.white,
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.reportColors[2].withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: CircularProgressIndicator(
                        color: AppTheme.reportColors[2],
                        strokeWidth: 3,
                      ),
                    ),
                    SizedBox(height: AppTheme.spacingLarge),
                    Text(
                      'جاري تحميل أسماء الله الحسنى...',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.reportColors[2],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // حالة فارغة
          if (namesGodController.namesGodList.isEmpty) {
            return Center(
              child: Container(
                margin: EdgeInsets.all(AppTheme.spacingXLarge),
                padding: EdgeInsets.all(AppTheme.spacingXXLarge * 1.5),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      AppTheme.reportColors[2].withOpacity(0.05),
                      Colors.grey[50]!,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.reportColors[2].withOpacity(0.2),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                      spreadRadius: 3,
                    ),
                    BoxShadow(
                      color: Colors.white,
                      blurRadius: 15,
                      offset: const Offset(0, -5),
                    ),
                  ],
                  border: Border.all(
                    color: AppTheme.reportColors[2].withOpacity(0.1),
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.reportColors[2].withOpacity(0.15),
                            AppTheme.reportColors[2].withOpacity(0.05),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        size: 90,
                        color: AppTheme.reportColors[2].withOpacity(0.7),
                      ),
                    ),
                    SizedBox(height: AppTheme.spacingXLarge),
                    Text(
                      'لا توجد أسماء متاحة',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.reportColors[2],
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: AppTheme.spacingSmall),
                    Text(
                      'يرجى المحاولة لاحقاً',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
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
                  studentName: namesGodController.studentData['name_student']?.toString() ?? 'غير محدد',
                ),
                
                SizedBox(height: AppTheme.spacingLarge),

                // آخر تسميع
                if (namesGodController.lastNamesGod.isNotEmpty)
                  LastRecordCard(
                    title: 'آخر تسميع',
                    date: namesGodController.lastNamesGod["date"]?.toString() ?? '-',
                    startItemName: namesGodController.lastNamesGod["start_item_name"]?.toString() ?? '-',
                    endItemName: namesGodController.lastNamesGod["end_item_name"]?.toString() ?? '-',
                    mark: namesGodController.lastNamesGod["mark"]?.toString() ?? '-',
                    onEdit: () => namesGodController.showEditDialog(),
                    accentColor: AppTheme.reportColors[4],
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
                            'أول تسميع أسماء الله الحسنى لهذا الطالب',
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
                  value: namesGodController.selectedStartName.value,
                  hint: 'اختر اسم البداية',
                  items: namesGodController.namesGodList,
                  idKey: 'id_Names_God',
                  nameKey: 'name_Names_God',
                  onChanged: (value) {
                    print("id_Names_God==${value}");
                    namesGodController.selectedStartName.value = value;
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
                  value: namesGodController.selectedEndName.value,
                  hint: 'اختر اسم النهاية',
                  items: namesGodController.namesGodList,
                  idKey: 'id_Names_God',
                  nameKey: 'name_Names_God',
                  onChanged: (value) {
                    namesGodController.selectedEndName.value = value;
                  },
                  accentColor: Colors.red[700]!,
                ),
                
                SizedBox(height: AppTheme.spacingLarge),
                
                CustomTextField(
                  controller: namesGodController.controller_text,
                  label: "التقييم",
                  hint: "الدرجة (0-100)",
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.grade_rounded,
                ),
                
                SizedBox(height: AppTheme.spacingXXLarge),

                // زر الحفظ
                SaveButton(
                  isLoading: namesGodController.isSaving.value,
                  onPressed: () => namesGodController.saveNamesGodRange(false),
                  label: 'حفظ نطاق أسماء الله الحسنى',
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class NamesGodController extends GetxController {
  var namesGodList = <Map<String, dynamic>>[].obs;
  RxMap lastNamesGod = <String, dynamic>{}.obs;
  RxBool isLoading = false.obs;
  RxBool isSaving = false.obs;
  TextEditingController controller_text = TextEditingController();
  
  var studentData = <String, dynamic>{};
  
  Rx<Map<String, dynamic>?> selectedStartName = Rx<Map<String, dynamic>?>(null);
  Rx<Map<String, dynamic>?> selectedEndName = Rx<Map<String, dynamic>?>(null);
  
  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      studentData = Get.arguments;
    }
    selectNamesGod();
    selectLastNamesGod();
  }
  
  Future selectNamesGod() async {
    var res = await handleRequest(
      isLoading: isLoading,
      action: () async {
        return await postData(Linkapi.selectNamesGod, {});
      },
    );
    
    if (res == null) return;
    
    if (res["stat"] == "ok") {
      final data = List<Map<String, dynamic>>.from(res["data"]);
      namesGodList.assignAll(data);
      print("namesGodList====${namesGodList}");
    } else if (res["stat"] == "no") {
      namesGodList.clear();
      mySnackbar("تنبيه", "لا توجد أسماء متاحة");
    } else {
      mySnackbar("خطأ", res["msg"] ?? "خطأ في جلب أسماء الله الحسنى");
    }
  }

  Future selectLastNamesGod() async {
    var res = await handleRequest(
      isLoading: RxBool(false),
      action: () async {
        return await postData(Linkapi.selectLastNamesGod, {
          "id_student": studentData['id_student'],
        });
      },
    );

    if (res == null) return;

    if (res["stat"] == "ok") {
      final data = Map<String, dynamic>.from(res["data"]);
      lastNamesGod.assignAll(data);
    } else if (res["stat"] == "no") {
      lastNamesGod.clear();
    } else {
      mySnackbar("خطأ", res["msg"] ?? "خطأ في جلب آخر تسميع");
    }
  }
  
  Future<bool> saveNamesGodRange(isEdit) async {
    if (selectedStartName.value == null) {
      mySnackbar("تنبيه", "الرجاء اختيار اسم البداية");
      return false;
    }
    
    if (selectedEndName.value == null) {
      mySnackbar("تنبيه", "الرجاء اختيار اسم النهاية");
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


    bool isEditing = lastNamesGod.isNotEmpty && lastNamesGod['id'] != null;
    
    var data = {
      "id_student": studentData['id_student'],
      "start_item_name": selectedStartName.value?['id_Names_God'] ?? 1,
      "end_item_name": selectedEndName.value?['id_Names_God'] ?? 1,
      "mark": controller_text.text.trim(),
    };
    if (isEditing) {
      data["id"] = lastNamesGod['id'];
    }

    var res = await handleRequest(
      isLoading: isSaving,
      action: () async {
        return await postData(
            isEdit ? Linkapi.updateStudentNamesGodRange : Linkapi.saveStudentNamesGodRange,
          data
        );
      },
    );

    if (res == null) return false;

    if (res["stat"] == "ok") {
      mySnackbar("نجاح", "تم حفظ نطاق أسماء الله الحسنى بنجاح", type: "g");
      await selectLastNamesGod();
      selectedStartName.value = null;
      selectedEndName.value = null;
      controller_text.clear();
      return true;
    } else {
      mySnackbar("خطأ", res["msg"] ?? "خطأ في حفظ النطاق");
      return false;
    }
  }

  void showEditDialog() {
    print("lastNamesGod==${lastNamesGod}");
    print("namesGodList==${namesGodList}");
    if (lastNamesGod.isEmpty) return;

    Map<String, dynamic>? startItem;
    Map<String, dynamic>? endItem;
    try {
      startItem = namesGodList.firstWhere(
        (name) => name['name_Names_God'] == lastNamesGod['start_item_name'],
      );
    } catch (_) {
      startItem = null;
    }
    try {
      endItem = namesGodList.firstWhere(
        (name) => name['name_Names_God'] == lastNamesGod['end_item_name'],
      );
    } catch (_) {
      endItem = null;
    }

    selectedStartName.value = startItem;
    selectedEndName.value = endItem;
    controller_text.text = lastNamesGod['mark']?.toString() ?? '';
    
    Get.dialog(
      Obx(() => EditRecordDialog(
        title: 'تعديل آخر تسميع',
        date: lastNamesGod["date"]?.toString() ?? '-',
        startDropdown: CustomDropdown(
          value: selectedStartName.value,
          hint: 'اختر اسم البداية',
          items: namesGodList,
          idKey: 'id_Names_God',
          nameKey: 'name_Names_God',
          onChanged: (value) {
            selectedStartName.value = value;
          },
          accentColor: AppTheme.reportColors[4],
        ),
        endDropdown: CustomDropdown(
          value: selectedEndName.value,
          hint: 'اختر اسم النهاية',
          items: namesGodList,
          idKey: 'id_Names_God',
          nameKey: 'name_Names_God',
          onChanged: (value) {
            selectedEndName.value = value;
          },
          accentColor: AppTheme.reportColors[4],
        ),
        markController: controller_text,
        isSaving: isSaving.value,
        onSave: () async {
          final success = await saveNamesGodRange(true);
          if (success) {
            Get.back();
          }
        },
        onCancel: () => Get.back(),
        accentColor: AppTheme.reportColors[4],
      )),
    );
  }
}
