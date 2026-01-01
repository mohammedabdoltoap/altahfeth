import 'package:althfeth/api/LinkApi.dart';
import 'package:althfeth/api/apiFunction.dart';
import 'package:althfeth/constants/customTextField.dart';
import 'package:althfeth/constants/function.dart';
import 'package:althfeth/constants/app_theme.dart';
import 'package:althfeth/view/widget/curriculum_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GharibQuran extends StatelessWidget {
  final GharibQuranController gharibQuranController = Get.put(GharibQuranController());

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
          'تحديد نطاق غريب القرآن',
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
          if (gharibQuranController.isLoading.value && gharibQuranController.souraList.isEmpty) {
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
                      'جاري تحميل سور القرآن...',
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
          if (gharibQuranController.souraList.isEmpty) {
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
                      'لا توجد سور متاحة',
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
                  studentName: gharibQuranController.studentData['name_student']?.toString() ?? 'غير محدد',
                ),
                
                SizedBox(height: AppTheme.spacingLarge),

                // آخر تسميع
                if (gharibQuranController.lastGharib.isNotEmpty)
                  LastRecordCard(
                    title: 'آخر تسميع',
                    date: gharibQuranController.lastGharib["date"]?.toString() ?? '-',
                    startItemName: gharibQuranController.lastGharib["start_soura_name"]?.toString() ?? '-',
                    endItemName: gharibQuranController.lastGharib["end_soura_name"]?.toString() ?? '-',
                    mark: gharibQuranController.lastGharib["mark"]?.toString() ?? '-',
                    onEdit: () => gharibQuranController.showEditDialog(),
                    accentColor: AppTheme.reportColors[0],
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
                            'أول تسميع غريب القرآن لهذا الطالب',
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
                  value: gharibQuranController.selectedStartSoura.value,
                  hint: 'اختر سورة البداية',
                  items: gharibQuranController.souraList,
                  idKey: 'id_soura',
                  nameKey: 'soura_name',
                  onChanged: (value) {
                    gharibQuranController.selectedStartSoura.value = value;
                    gharibQuranController.selectedStartAya.value = null;
                  },
                  accentColor: Colors.green[700]!,
                ),
                SizedBox(height: AppTheme.spacingMedium),
                Obx(() {
                  if (gharibQuranController.selectedStartSoura.value == null) {
                    return const SizedBox();
                  }
                  final ayatCount = int.tryParse(
                    gharibQuranController.selectedStartSoura.value?['ayat_count']?.toString() ?? "0"
                  ) ?? 0;
                  
                  final ayatItems = List.generate(
                    ayatCount,
                    (index) => {
                      'id': index + 1,
                      'name': (index + 1).toString(),
                    },
                  );
                  
                  return CustomDropdown(
                    value: gharibQuranController.selectedStartAya.value != null 
                      ? ayatItems.firstWhere(
                          (item) => item['id'] == gharibQuranController.selectedStartAya.value,
                          orElse: () => ayatItems.first,
                        )
                      : null,
                    hint: 'من الآية رقم',
                    items: ayatItems,
                    idKey: 'id',
                    nameKey: 'name',
                    onChanged: (value) {
                      gharibQuranController.selectedStartAya.value = value?['id'];
                    },
                    accentColor: Colors.green[700]!,
                  );
                }),
                
                SizedBox(height: AppTheme.spacingLarge),
                
                // قسم نطاق النهاية
                SectionHeader(
                  icon: Icons.stop_rounded,
                  title: 'نطاق النهاية',
                  color: Colors.red[700]!,
                ),
                SizedBox(height: AppTheme.spacingMedium),
                CustomDropdown(
                  value: gharibQuranController.selectedEndSoura.value,
                  hint: 'اختر سورة النهاية',
                  items: gharibQuranController.souraList,
                  idKey: 'id_soura',
                  nameKey: 'soura_name',
                  onChanged: (value) {
                    gharibQuranController.selectedEndSoura.value = value;
                    gharibQuranController.selectedEndAya.value = null;
                  },
                  accentColor: Colors.red[700]!,
                ),
                SizedBox(height: AppTheme.spacingMedium),
                Obx(() {
                  if (gharibQuranController.selectedEndSoura.value == null) {
                    return const SizedBox();
                  }
                  final ayatCount = int.tryParse(
                    gharibQuranController.selectedEndSoura.value?['ayat_count']?.toString() ?? "0"
                  ) ?? 0;
                  
                  final ayatItems = List.generate(
                    ayatCount,
                    (index) => {
                      'id': index + 1,
                      'name': (index + 1).toString(),
                    },
                  );
                  
                  return CustomDropdown(
                    value: gharibQuranController.selectedEndAya.value != null 
                      ? ayatItems.firstWhere(
                          (item) => item['id'] == gharibQuranController.selectedEndAya.value,
                          orElse: () => ayatItems.first,
                        )
                      : null,
                    hint: 'إلى الآية رقم',
                    items: ayatItems,
                    idKey: 'id',
                    nameKey: 'name',
                    onChanged: (value) {
                      gharibQuranController.selectedEndAya.value = value?['id'];
                    },
                    accentColor: Colors.red[700]!,
                  );
                }),
                
                SizedBox(height: AppTheme.spacingLarge),
                
                CustomTextField(
                  controller: gharibQuranController.controller_text,
                  label: "التقييم",
                  hint: "الدرجة (0-100)",
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.grade_rounded,
                ),
                
                SizedBox(height: AppTheme.spacingXXLarge),

                // زر الحفظ
                SaveButton(
                  isLoading: gharibQuranController.isSaving.value,
                  onPressed: () => gharibQuranController.saveGharibRange(),
                  label: 'حفظ نطاق غريب القرآن',
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class GharibQuranController extends GetxController {
  var souraList = <Map<String, dynamic>>[].obs;
  RxMap lastGharib = <String, dynamic>{}.obs;
  RxBool isLoading = false.obs;
  RxBool isSaving = false.obs;
  TextEditingController controller_text = TextEditingController();
  
  var studentData = <String, dynamic>{};
  
  Rx<Map<String, dynamic>?> selectedStartSoura = Rx<Map<String, dynamic>?>(null);
  Rx<Map<String, dynamic>?> selectedEndSoura = Rx<Map<String, dynamic>?>(null);
  Rx<int?> selectedStartAya = Rx<int?>(null);
  Rx<int?> selectedEndAya = Rx<int?>(null);
  
  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      studentData = Get.arguments;
    }
    selectSouraList();
    selectLastGharib();
  }
  
  Future selectSouraList() async {
    var res = await handleRequest(
      isLoading: isLoading,
      action: () async {
        return await postData(Linkapi.selectSouraForGharib, {
          "id_level": studentData['id_level'],
        });
      },
    );
    
    if (res == null) return;
    
    if (res["stat"] == "ok") {
      final data = List<Map<String, dynamic>>.from(res["data"]);
      souraList.assignAll(data);
    } else if (res["stat"] == "no") {
      souraList.clear();
      mySnackbar("تنبيه", "لا توجد سور متاحة");
    } else {
      mySnackbar("خطأ", res["msg"] ?? "خطأ في جلب سور القرآن");
    }
  }

  Future selectLastGharib() async {
    var res = await handleRequest(
      isLoading: RxBool(false),
      action: () async {
        return await postData(Linkapi.selectLastGharibQuran, {
          "id_student": studentData['id_student'],
        });
      },
    );

    if (res == null) return;

    if (res["stat"] == "ok") {
      final data = Map<String, dynamic>.from(res["data"]);
      lastGharib.assignAll(data);
    } else if (res["stat"] == "no") {
      lastGharib.clear();
    } else {
      mySnackbar("خطأ", res["msg"] ?? "خطأ في جلب آخر تسميع");
    }
  }
  
  Future<void> saveGharibRange() async {
    // التحقق من البيانات
    if (selectedStartSoura.value == null) {
      mySnackbar("تنبيه", "يجب اختيار سورة البداية");
      return;
    }
    if (selectedStartAya.value == null) {
      mySnackbar("تنبيه", "يجب اختيار رقم آية البداية");
      return;
    }
    if (selectedEndSoura.value == null) {
      mySnackbar("تنبيه", "يجب اختيار سورة النهاية");
      return;
    }
    if (selectedEndAya.value == null) {
      mySnackbar("تنبيه", "يجب اختيار رقم آية النهاية");
      return;
    }
    
    if (controller_text.text.isEmpty) {
      mySnackbar("خطأ", "يجب تحديد درجة للطالب");
      return;
    }

    if (int.tryParse(controller_text.text.isEmpty ? "0" : controller_text.text)! < 0 ||
        int.tryParse(controller_text.text.isEmpty ? "0" : controller_text.text)! > 100
    ) {
      mySnackbar("خطأ", "يجب تحديد درجة للطالب بين 0-100");
      return;
    }

    bool isEditing = lastGharib.isNotEmpty && lastGharib['id'] != null;
    
    final data = {
      "id_student": studentData["id_student"],
      "start_id_soura": selectedStartSoura.value!["id_soura"],
      "start_id_aya": selectedStartAya.value,
      "end_id_soura": selectedEndSoura.value!["id_soura"],
      "end_id_aya": selectedEndAya.value,
      "mark": controller_text.text.trim(),
    };
    
    if (isEditing) {
      data["id"] = lastGharib['id'];
    }

    var res = await handleRequest(
      isLoading: isSaving,
      action: () async {
        return await postData(
            isEditing ? Linkapi.updateGharibQuranRange : Linkapi.saveGharibQuranRange,
          data
        );
      },
    );

    if (res == null) return;

    if (res["stat"] == "ok") {
      mySnackbar("نجاح", "تم حفظ نطاق غريب القرآن بنجاح", type: "g");
      await selectLastGharib();
      selectedStartSoura.value = null;
      selectedEndSoura.value = null;
      selectedStartAya.value = null;
      selectedEndAya.value = null;
      controller_text.clear();
    } else {
      mySnackbar("خطأ", res["msg"] ?? "خطأ في حفظ النطاق");
    }
  }

  void showEditDialog() {
    if (lastGharib.isEmpty) return;
    
    Map<String, dynamic>? startItem;
    Map<String, dynamic>? endItem;
    try {
      startItem = souraList.firstWhere(
        (soura) => soura['id_soura'] == lastGharib['start_id_soura'],
      );
    } catch (_) {
      startItem = null;
    }
    try {
      endItem = souraList.firstWhere(
        (soura) => soura['id_soura'] == lastGharib['end_id_soura'],
      );
    } catch (_) {
      endItem = null;
    }

    selectedStartSoura.value = startItem;
    selectedEndSoura.value = endItem;
    selectedStartAya.value = lastGharib['start_id_aya'];
    selectedEndAya.value = lastGharib['end_id_aya'];
    controller_text.text = lastGharib['mark']?.toString() ?? '';
    
    Get.dialog(
      Obx(() => EditRecordDialog(
        title: 'تعديل آخر تسميع',
        date: lastGharib["date"]?.toString() ?? '-',
        startDropdown: Column(
          children: [
            CustomDropdown(
              value: selectedStartSoura.value,
              hint: 'اختر سورة البداية',
              items: souraList,
              idKey: 'id_soura',
              nameKey: 'soura_name',
              onChanged: (value) {
                selectedStartSoura.value = value;
                selectedStartAya.value = null;
              },
              accentColor: AppTheme.reportColors[0],
            ),
            Obx(() {
              if (selectedStartSoura.value == null) return SizedBox.shrink();
              return Column(
                children: [
                  SizedBox(height: AppTheme.spacingSmall),
                  Obx(() {
                    final ayatCount = int.tryParse(
                      selectedStartSoura.value?['ayat_count']?.toString() ?? "0"
                    ) ?? 0;
                    final ayatItems = List.generate(ayatCount, (index) => {
                      'id': index + 1,
                      'name': (index + 1).toString(),
                    });
                    return CustomDropdown(
                      value: selectedStartAya.value != null 
                        ? ayatItems.firstWhere(
                            (item) => item['id'] == selectedStartAya.value,
                            orElse: () => ayatItems.first,
                          )
                        : null,
                      hint: 'من الآية رقم',
                      items: ayatItems,
                      idKey: 'id',
                      nameKey: 'name',
                      onChanged: (value) {
                        selectedStartAya.value = value?['id'];
                      },
                      accentColor: AppTheme.reportColors[0],
                    );
                  }),
                ],
              );
            }),
          ],
        ),
        endDropdown: Column(
          children: [
            CustomDropdown(
              value: selectedEndSoura.value,
              hint: 'اختر سورة النهاية',
              items: souraList,
              idKey: 'id_soura',
              nameKey: 'soura_name',
              onChanged: (value) {
                selectedEndSoura.value = value;
                selectedEndAya.value = null;
              },
              accentColor: AppTheme.reportColors[0],
            ),
            Obx(() {
              if (selectedEndSoura.value == null) return SizedBox.shrink();
              return Column(
                children: [
                  SizedBox(height: AppTheme.spacingSmall),
                  Obx(() {
                    final ayatCount = int.tryParse(
                      selectedEndSoura.value?['ayat_count']?.toString() ?? "0"
                    ) ?? 0;
                    final ayatItems = List.generate(ayatCount, (index) => {
                      'id': index + 1,
                      'name': (index + 1).toString(),
                    });
                    return CustomDropdown(
                      value: selectedEndAya.value != null 
                        ? ayatItems.firstWhere(
                            (item) => item['id'] == selectedEndAya.value,
                            orElse: () => ayatItems.first,
                          )
                        : null,
                      hint: 'إلى الآية رقم',
                      items: ayatItems,
                      idKey: 'id',
                      nameKey: 'name',
                      onChanged: (value) {
                        selectedEndAya.value = value?['id'];
                      },
                      accentColor: AppTheme.reportColors[0],
                    );
                  }),
                ],
              );
            }),
          ],
        ),
        markController: controller_text,
        isSaving: isSaving.value,
        onSave: () async {
          await saveGharibRange();
          Get.back();
        },
        onCancel: () => Get.back(),
        accentColor: AppTheme.reportColors[0],
      )),
    );
  }
}
