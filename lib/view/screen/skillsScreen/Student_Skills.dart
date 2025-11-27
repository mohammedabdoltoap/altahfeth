import 'package:althfeth/api/LinkApi.dart';
import 'package:althfeth/api/apiFunction.dart';
import 'package:althfeth/constants/CustomDropdownField.dart';
import 'package:althfeth/constants/customTextField.dart';
import 'package:althfeth/constants/appButton.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/function.dart';
import '../../../constants/loadingWidget.dart';

class Student_Skills extends StatelessWidget {
  final Student_SkillsController controller = Get.put(Student_SkillsController());

  Widget _buildStudentInfoCard(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.7),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person_rounded,
                  size: 32,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.studentName.value.isNotEmpty
                        ? controller.studentName.value
                        : 'الطالب',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.stars_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Obx(() => Text(
                          "${controller.skills_Sudent.length} مهارة",
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: const Text(
            "مهارات الطالب",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: theme.colorScheme.primary,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () {
                controller.select_student_skill();
                controller.select_skill();
              },
              tooltip: "تحديث",
            ),
          ],
        ),
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
          child: Column(
            children: [
              // بطاقة معلومات الطالب
              Obx(() => _buildStudentInfoCard(theme)),
              
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Obx(() => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                // قسم إضافة المهارة داخل Card
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: theme.colorScheme.primaryContainer,
                            child: Icon(Icons.stars, color: theme.colorScheme.onPrimaryContainer),
                          ),
                          title: Text(
                            "أضف مهارة جديدة للطالب",
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Obx(() {
                          // مراقبة التغييرات في القوائم
                          controller.skills.length;
                          controller.skills_Sudent.length;
                          final items = controller.availableSkills.toList();
                          return CustomDropdownField(
                            label: "اختر المهارة",
                            items: items,
                            value: controller.selectedIdSkile.value,
                            onChanged: (val) => controller.selectedIdSkile.value = val,
                            valueKey: "id_skill",
                            displayKey: "name_skill",
                          );
                        }),
                        const SizedBox(height: 10),
                        CustomTextField(
                          controller: controller.evalController,
                          label: "أدخل تقييم المهارة",
                          hint: "(من 0 إلى 100)",
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: Obx(() => AppButton(
                                text: "إضافة المهارة",
                                icon: Icons.add,
                                isLoading: controller.isAdding.value,
                                onPressed: (controller.selectedIdSkile.value == null || controller.isAdding.value)
                                    ? null
                                    : () async {
                                        await controller.addSkillToStudent();
                                      },
                                height: 48,
                                color: theme.colorScheme.primary,
                                foregroundColor: theme.colorScheme.onPrimary,
                              )),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // عنوان قسم المهارات الحالية
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.secondaryContainer,
                    child: Icon(Icons.list_alt, color: theme.colorScheme.onSecondaryContainer),
                  ),
                  title: Text(
                    "مهارات الطالب الحالية",
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),

                controller.skills_Sudent.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.school_outlined, size: 56, color: Colors.grey.shade500),
                              const SizedBox(height: 8),
                              Text(
                                "لا توجد مهارات مضافة بعد",
                                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemCount: controller.skills_Sudent.length,
                        itemBuilder: (context, index) {
                            final element = controller.skills_Sudent[index];
                            final int? score = int.tryParse("${element["avaluation"]}");
                            final bool hasScore = score != null;
                            final Color chipBg = hasScore
                                ? (score! >= 80
                                    ? theme.colorScheme.primaryContainer
                                    : score >= 50
                                        ? theme.colorScheme.tertiaryContainer
                                        : theme.colorScheme.errorContainer)
                                : theme.colorScheme.surfaceVariant;
                            final Color chipFg = hasScore
                                ? (score >= 80
                                    ? theme.colorScheme.onPrimaryContainer
                                    : score >= 50
                                        ? theme.colorScheme.onTertiaryContainer
                                        : theme.colorScheme.onErrorContainer)
                                : theme.colorScheme.onSurfaceVariant;

                            return Card(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 2,
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: theme.colorScheme.primary,
                                  child: Text(
                                    element["name_skill"][0],
                                    style: TextStyle(color: theme.colorScheme.onPrimary),
                                  ),
                                ),
                                title: Text(
                                  element["name_skill"],
                                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                                ),
                                subtitle: hasScore
                                    ? Padding(
                                        padding: const EdgeInsets.only(top: 6.0),
                                        child: Wrap(
                                          spacing: 6,
                                          children: [
                                            Chip(
                                              label: Text("التقييم: ${score}"),
                                              backgroundColor: chipBg,
                                              labelStyle: TextStyle(color: chipFg),
                                              visualDensity: VisualDensity.compact,
                                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            ),
                                          ],
                                        ),
                                      )
                                    : Text("التقييم: غير محدد", style: const TextStyle(color: Colors.black54)),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit, color: theme.colorScheme.primary),
                                      onPressed: () => controller.updateSkill(element),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete, color: theme.colorScheme.error),
                                      onPressed: () => controller.deleteSkill(element),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
              ],
            )),
          ),
        ]),
      ),
      ),
    );
  }
}

class Student_SkillsController extends GetxController {
  var data;
  RxString studentName = ''.obs;
  RxList<Map<String, dynamic>> skills_Sudent = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> skills = <Map<String, dynamic>>[].obs;
  RxnInt selectedIdSkile = RxnInt(null);
  TextEditingController evalController = TextEditingController();
  RxBool isAdding = false.obs;

  RxList<Map<String, dynamic>> get availableSkills {
    final ownedIds = skills_Sudent.map((s) => s["id_skill"]).toSet();
    return RxList<Map<String, dynamic>>.from(
        skills.where((s) => !ownedIds.contains(s["id_skill"])));
  }

  @override
  void onInit() {
    super.onInit();
    data = Get.arguments;
    
    // استخراج اسم الطالب
    if (data != null && data is Map) {
      studentName.value = data["name_student"] ?? '';
    }
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {
       select_student_skill();
        select_skill();
    });
  }

  @override
  void onClose() {
    // إغلاق أي لودينج متبقّي عند مغادرة الصفحة
    isAdding.value = false;
    super.onClose();
  }

  Future select_student_skill() async {
    final res = await handleRequest<dynamic>(
      isLoading: RxBool(false),
      loadingMessage: "جاري تحميل مهارات الطالب...",
      useDialog: true,
      immediateLoading: true,
      action: () async {
        return await postData(Linkapi.select_student_skill, {"id_student": data["id_student"]});
      },
    );
    if (res["stat"] == "ok") {
      skills_Sudent.assignAll(List<Map<String, dynamic>>.from(res["data"]));
    } else if (res["stat"] == "error") {
      mySnackbar("تنبيه", res["msg"]);
    }
  }

  Future select_skill() async {
    final res = await handleRequest<dynamic>(
      isLoading: RxBool(false),
      loadingMessage: "جاري تحميل قائمة المهارات...",
      useDialog: false,
      immediateLoading: false,
      action: () async {
        return await postData(Linkapi.select_skill, {});
      },
    );
    if (res["stat"] == "ok") {
      skills.assignAll(List<Map<String, dynamic>>.from(res["data"]));
    } else if (res["stat"] == "error") {
      mySnackbar("تنبيه", res["msg"]);
    }
  }

  Future addSkillToStudent() async {


    final selectedSkill = skills.firstWhereOrNull((s) => s["id_skill"] == selectedIdSkile.value);
    if (selectedSkill == null)
      return ;

    final evalText = evalController.text.trim();
    if (evalText.isEmpty || int.tryParse(evalText) == null) {
      mySnackbar("تنبيه", "يرجى إدخال تقييم صحيح");
      return;
    }

    final evalValue = int.parse(evalText);
    if (evalValue < 0 || evalValue > 100) {
      mySnackbar("تنبيه", "يجب أن يكون التقييم بين 0 و 100");
      return;
    }

    Map data2={
      "id_student":data["id_student"],
      "id_skill":selectedIdSkile.value,
      "avaluation":evalValue,
    };
    final res = await handleRequest<dynamic>(
      isLoading: isAdding,
      loadingMessage: "جاري إضافة المهارة...",
      useDialog: false,
      immediateLoading: true,
      action: () async {
        return await postData(Linkapi.insert_student_skills, data2);
      },
    );

    int idLast;
    if(res["stat"]=="ok") {
      idLast=int.parse(res["data"]);
      skills_Sudent.add({
        "id":idLast,
        "id_skill": selectedSkill["id_skill"],
        "name_skill": selectedSkill["name_skill"],
        "avaluation": evalValue,
      });
      mySnackbar("تم", "تمت إضافة المهارة بنجاح", type: "g");

    }
    else if(res["stat"]=="no"){
      mySnackbar("تنبية", "لم تتم الاضافة بنجاح");
    }
    else {
      mySnackbar("تنبية", "لم تتم الاضافة بنجاح...");
    }
    evalController.clear();
    selectedIdSkile.value = null;
  }

  // void updateSkill(Map<String, dynamic> skill) {
  //   final TextEditingController updateController = TextEditingController(text: skill["avaluation"].toString());
  //
  //   Get.defaultDialog(
  //     title: "تعديل التقييم",
  //     content: TextField(
  //       controller: updateController,
  //       keyboardType: TextInputType.number,
  //       decoration: const InputDecoration(labelText: "أدخل التقييم الجديد (0-100)"),
  //     ),
  //     confirm: ElevatedButton(
  //       onPressed: ()async {
  //         final val = int.tryParse(updateController.text.trim());
  //         if (val == null || val < 0 || val > 100) {
  //           mySnackbar("تنبيه", "الرجاء إدخال تقييم صحيح بين 0 و 100");
  //           return;
  //         }
  //
  //       var res=await  postData(Linkapi.update_student_skill, {
  //           "id":skill["id"],
  //           "avaluation":skill["avaluation"]
  //         });
  //         print("res=====${res}");
  //        if(res["stat"]=="ok"){
  //          skills_Sudent.refresh();
  //          Get.back();
  //          mySnackbar("تم", "تم تعديل التقييم بنجاح", type: "g");
  //        }else if(res["stat"]=="no"){
  //          mySnackbar("تنبية", "لم يتم التعديل بنجاح");
  //        }
  //        else if(res["stat"]=="erorr"){
  //          mySnackbar("تنبية", "${res["msg"]}");
  //        }
  //       },
  //       style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
  //       child: const Text("حفظ"),
  //     ),
  //     cancel: ElevatedButton(
  //       onPressed: () => Get.back(),
  //       style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
  //       child: const Text("إلغاء"),
  //     ),
  //   );
  // }

  void updateSkill(Map<String, dynamic> skill) {
    final TextEditingController updateController = TextEditingController(
      text: skill["avaluation"]?.toString() ?? "0",
    );

    Get.defaultDialog(
      title: "تعديل التقييم",
      content: TextField(
        controller: updateController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(labelText: "أدخل التقييم الجديد (0-100)"),
      ),
      confirm: ElevatedButton(
        onPressed: () async {
          final val = int.tryParse(updateController.text.trim());
          if (val == null || val < 0 || val > 100) {
            mySnackbar("تنبيه", "الرجاء إدخال تقييم صحيح بين 0 و 100");
            return;
          }
          final res = await handleRequest<dynamic>(
            isLoading: RxBool(false),
            loadingMessage: "جاري حفظ التعديل...",
            useDialog: true,
            immediateLoading: true,
            action: () async {
              return await postData(Linkapi.update_student_skill, {"id": skill["id"], "avaluation": val});
            },
          );

            if (res["stat"] == "ok") {
              skill["avaluation"] = val; // تحديث القيمة محليًا
              skills_Sudent.refresh();
              Get.back();
              mySnackbar("تم", "تم تعديل التقييم بنجاح", type: "g");
            } else if (res["stat"] == "no") {
              mySnackbar("تنبيه", "لم يتم التعديل بنجاح");
            } else if (res["stat"] == "error") {
              mySnackbar("خطأ", "${res["msg"]}");
            }
        },
        style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
        child: const Text("حفظ"),
      ),
      cancel: ElevatedButton(
        onPressed: () => Get.back(),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
        child: const Text("إلغاء"),
      ),
    );
  }


  void deleteSkill(Map<String, dynamic> skill) {
    Get.defaultDialog(
      title: "تأكيد الحذف",
      middleText: "هل تريد حذف هذه المهارة من الطالب؟",
      confirm: ElevatedButton(
        onPressed: () async {
          Get.back();
          final res = await handleRequest<dynamic>(
            isLoading: RxBool(false),
            loadingMessage: "جاري حذف المهارة...",
            useDialog: true,
            immediateLoading: true,
            action: () async {
              return await postData(Linkapi.delet_student_skills, {"id": skill["id"]});
            },
          );

            if (res["stat"] == "ok") {
              skills_Sudent.remove(skill);
              mySnackbar("تم", "تم حذف المهارة بنجاح", type: "g");
            } else if (res["stat"] == "no") {
              mySnackbar("تنبيه", "لم يتم حذف المهارة، حاول مرة أخرى");
            } else {
              mySnackbar("خطأ", "حدث خطأ، تحقق من الاتصال بالإنترنت");
            }
        },
        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
        child: const Text("نعم"),
      ),
      cancel: ElevatedButton(
        onPressed: () => Get.back(),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
        child: const Text("إلغاء"),
      ),
    );
  }

}
