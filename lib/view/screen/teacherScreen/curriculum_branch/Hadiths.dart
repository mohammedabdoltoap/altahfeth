import 'package:althfeth/api/LinkApi.dart';
import 'package:althfeth/api/apiFunction.dart';
import 'package:althfeth/constants/customTextField.dart';
import 'package:althfeth/constants/function.dart';
import 'package:althfeth/constants/app_theme.dart';
import 'package:althfeth/view/widget/curriculum_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Hadiths extends StatelessWidget {
  final HadithsController hadithsController = Get.put(HadithsController());

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
          'تحديد نطاق الأحاديث',
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
          if (hadithsController.lodeing_hadiths.value && hadithsController.hadiths.isEmpty) {
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
                      'جاري تحميل الأحاديث...',
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
          if (hadithsController.hadiths.isEmpty) {
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
                        color: AppTheme.reportColors[0].withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.menu_book,
                        size: 64,
                        color: AppTheme.reportColors[0],
                      ),
                    ),
                    SizedBox(height: AppTheme.spacingLarge),
                    Text(
                      'لا توجد أحاديث متاحة',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.reportColors[0],
                      ),
                    ),
                    SizedBox(height: AppTheme.spacingSmall),
                    Text(
                      'لم يتم العثور على أي أحاديث في قاعدة البيانات',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: AppTheme.spacingLarge),
                    ElevatedButton.icon(
                      onPressed: () => hadithsController.selectHadiths(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('إعادة المحاولة'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.reportColors[0],
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
                  studentName: hadithsController.studentData['name_student']?.toString() ?? 'غير محدد',
                ),
                
                SizedBox(height: AppTheme.spacingLarge),

                // آخر تسميع
                if (hadithsController.lastHadiths.isNotEmpty)
                  LastRecordCard(
                    title: 'آخر تسميع',
                    date: hadithsController.lastHadiths["date"]?.toString() ?? '-',
                    startItemName: hadithsController.lastHadiths["start_hadith_name"]?.toString() ?? '-',
                    endItemName: hadithsController.lastHadiths["end_hadith_name"]?.toString() ?? '-',
                    mark: hadithsController.lastHadiths["mark"]?.toString() ?? '-',
                    onEdit: () => hadithsController.showEditDialog(),
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
                            'أول تسميع حديث لهذا الطالب',
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
                  value: hadithsController.selectedStartHadith.value,
                  hint: 'اختر حديث البداية',
                  items: hadithsController.hadiths,
                  idKey: 'id_Hadiths',
                  nameKey: 'name_Hadiths',
                  onChanged: (value) {
                    hadithsController.selectedStartHadith.value = value;
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
                  value: hadithsController.selectedEndHadith.value,
                  hint: 'اختر حديث النهاية',
                  items: hadithsController.hadiths,
                  idKey: 'id_Hadiths',
                  nameKey: 'name_Hadiths',
                  onChanged: (value) {
                    hadithsController.selectedEndHadith.value = value;
                  },
                  accentColor: Colors.red[700]!,
                ),
                
                SizedBox(height: AppTheme.spacingLarge),
                
                CustomTextField(
                  controller: hadithsController.controller_text,
                  label: "التقييم",
                  hint: "الدرجة (0-100)",
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.grade_rounded,
                ),
                
                SizedBox(height: AppTheme.spacingXXLarge),

                // زر الحفظ
                SaveButton(
                  isLoading: hadithsController.isSaving.value,
                  onPressed: () => hadithsController.saveHadithRange(false),
                  label: 'حفظ نطاق الأحاديث',
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class HadithsController extends GetxController {
  var hadiths = <Map<String, dynamic>>[].obs;
  RxMap lastHadiths = <String, dynamic>{}.obs;
  RxBool lodeing_hadiths = false.obs;
  RxBool isSaving = false.obs;
  RxInt isSave=0.obs;
  TextEditingController controller_text=TextEditingController();
  // بيانات الطالب من الـ arguments
  var studentData = <String, dynamic>{};
  
  // الأحاديث المختارة
  Rx<Map<String, dynamic>?> selectedStartHadith = Rx<Map<String, dynamic>?>(null);
  Rx<Map<String, dynamic>?> selectedEndHadith = Rx<Map<String, dynamic>?>(null);
  
  @override
  void onInit() {
    super.onInit();
    // استلام بيانات الطالب
    if (Get.arguments != null) {
      studentData = Get.arguments;
    }
    selectHadiths();
    selectLastHadith();
  }
  
  Future selectHadiths() async {
    var res = await handleRequest(
      isLoading: lodeing_hadiths,
      action: () async {
        return await postData(Linkapi.selectHadiths, {});
      },
    );
    
    if (res == null) return;
    

    if (res["stat"] == "ok") {
      final data = List<Map<String, dynamic>>.from(res["data"]);
      hadiths.assignAll(data);
    } else if (res["stat"] == "no") {
      hadiths.clear();
      mySnackbar("تنبية", "لايوجد احاديث متاحة");
    } else {
      mySnackbar("خطأ", res["msg"] ?? "خطأ في جلب الأحاديث");
    }
  }

  Future selectLastHadith()async{
    var res = await handleRequest(
      isLoading: RxBool(false),
      action: () async {
        return await postData(Linkapi.selectLastHadith, {
          "id_student": studentData['id_student'],
        });
      },
    );

    if (res == null) return;

    if (res["stat"] == "ok") {
      final data = Map<String, dynamic>.from(res["data"]);
      lastHadiths.assignAll(data);
    } else if (res["stat"] == "no") {
      lastHadiths.clear();
    } else {
      mySnackbar("خطأ", res["msg"] ?? "خطأ في جلب اخر تسميع ");
    }

  }
  
  // حفظ نطاق الأحاديث للطالب
  Future<bool> saveHadithRange(isUpDate) async {
    // التحقق من اختيار النطاقين
    if (selectedStartHadith.value == null) {
      mySnackbar("تنبيه", "الرجاء اختيار حديث البداية");
      return false;
    }
    
    if (selectedEndHadith.value == null) {
      mySnackbar("تنبيه", "الرجاء اختيار حديث النهاية");
      return false;
    }
    
    // التحقق من أن البداية قبل النهاية
    int startNum = int.tryParse(selectedStartHadith.value!['hadith_number']?.toString() ?? '0') ?? 0;
    int endNum = int.tryParse(selectedEndHadith.value!['hadith_number']?.toString() ?? '0') ?? 0;
    
    if (startNum > endNum) {
      mySnackbar("خطأ", "حديث البداية يجب أن يكون قبل حديث النهاية");
      return false;
    }
    if(controller_text.text.isEmpty){
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
    bool isEditing = lastHadiths.isNotEmpty && lastHadiths['id'] != null;

    var data = {
      "id_student": studentData['id_student'],
      "start_hadith_id": selectedStartHadith.value?['id_Hadiths'] ?? 1,
      "end_hadith_id": selectedEndHadith.value?['id_Hadiths']?? 1,
      "mark": controller_text.text.trim(),
    };
    
    // إضافة id_hadith_record إذا كان تعديل
    if (isEditing) {
      data["id"] = lastHadiths['id'];
    }
    
    var res = await handleRequest(
      isLoading: isSaving,
      action: () async {
        // استخدام API التعديل أو الإضافة حسب الحالة
        return await postData(
            isUpDate ? Linkapi.updateStudentHadithRange : Linkapi.saveStudentHadithRange,
          data
        );
      },
    );

    if (res == null) return false;

    if (res["stat"] == "ok") {
      mySnackbar("نجاح", "تم حفظ نطاق الأحاديث بنجاح",type: "g");
      await selectLastHadith();
      selectedStartHadith.value = null;
      selectedEndHadith.value = null;
      controller_text.clear();
      return true;
    } else {
      mySnackbar("خطأ", res["msg"] ?? "خطأ في حفظ النطاق");
      return false;
    }
  }

  // دالة عرض dialog التعديل
  void showEditDialog() {
    if (lastHadiths.isEmpty) return;
    
    // تعبئة الحقول بالبيانات الحالية
    Map<String, dynamic>? startItem;
    Map<String, dynamic>? endItem;
    try {
      startItem = hadiths.firstWhere(
        (hadith) => hadith['id_Hadiths'] == lastHadiths['start_hadith_id'],
      );
    } catch (_) {
      startItem = null;
    }
    try {
      endItem = hadiths.firstWhere(
        (hadith) => hadith['id_Hadiths'] == lastHadiths['end_hadith_id'],
      );
    } catch (_) {
      endItem = null;
    }

    selectedStartHadith.value = startItem;
    selectedEndHadith.value = endItem;
    controller_text.text = lastHadiths['mark']?.toString() ?? '';
    
    Get.dialog(
      Obx(() => EditRecordDialog(
        title: 'تعديل آخر تسميع',
        date: lastHadiths["date"]?.toString() ?? '-',
        startDropdown: CustomDropdown(
          value: selectedStartHadith.value,
          hint: 'اختر حديث البداية',
          items: hadiths,
          idKey: 'id_Hadiths',
          nameKey: 'name_Hadiths',
          onChanged: (value) {
            selectedStartHadith.value = value;
          },
          accentColor: AppTheme.reportColors[0],
        ),
        endDropdown: CustomDropdown(
          value: selectedEndHadith.value,
          hint: 'اختر حديث النهاية',
          items: hadiths,
          idKey: 'id_Hadiths',
          nameKey: 'name_Hadiths',
          onChanged: (value) {
            selectedEndHadith.value = value;
          },
          accentColor: AppTheme.reportColors[0],
        ),
        markController: controller_text,
        isSaving: isSaving.value,
        onSave: () async {
          final success = await saveHadithRange(true);
          if (success) {
            Get.back();
          }
        },
        onCancel: () => Get.back(),
        accentColor: AppTheme.reportColors[0],
      )),
    );
  }
}