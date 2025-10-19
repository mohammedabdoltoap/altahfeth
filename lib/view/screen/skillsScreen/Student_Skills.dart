import 'package:althfeth/api/LinkApi.dart';
import 'package:althfeth/api/apiFunction.dart';
import 'package:althfeth/constants/CustomDropdownField.dart';
import 'package:althfeth/constants/customTextField.dart';
import 'package:althfeth/constants/loadingWidget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/function.dart';

class Student_Skills extends StatelessWidget {
  final Student_SkillsController controller = Get.put(Student_SkillsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "مهارات الطالب",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.teal.shade600,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "أضف مهارة جديدة للطالب:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            CustomDropdownField(
              label: "اختر المهارة",
              items: controller.availableSkills,
              value: controller.selectedIdSkile.value,
              onChanged: (val) => controller.selectedIdSkile.value = val,
              valueKey: "id_skill",
              displayKey: "name_skill",
            ),

            const SizedBox(height: 10),

            CustomTextField(controller: controller.evalController, label: "أدخل تقييم المهارة", hint: "(من 0 إلى 100)",
            keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: controller.selectedIdSkile.value == null
                    ? null
                    : ()async {
                  await controller.addSkillToStudent();

                  },
                icon: const Icon(Icons.add),
                label: const Text(
                  "إضافة المهارة",
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade600,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
            const Divider(thickness: 1),
            const SizedBox(height: 10),

            const Text(
              "مهارات الطالب الحالية:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: controller.skills_Sudent.isEmpty
                  ? Center(
                child: Text(
                  "لا توجد مهارات مضافة بعد",
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
              )
                  : ListView.separated(
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemCount: controller.skills_Sudent.length,
                itemBuilder: (context, index) {
                  final element = controller.skills_Sudent[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 3,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.teal.shade600,
                        child: Text(
                          element["name_skill"][0],
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        element["name_skill"],
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        "التقييم: ${element["avaluation"] ?? "غير محدد"}",
                        style: const TextStyle(color: Colors.black54),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blueAccent),
                            onPressed: () => controller.updateSkill(element),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () => controller.deleteSkill(element),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        )),
      ),
    );
  }
}

class Student_SkillsController extends GetxController {
  var data;
  RxList<Map<String, dynamic>> skills_Sudent = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> skills = <Map<String, dynamic>>[].obs;
  RxnInt selectedIdSkile = RxnInt(null);
  TextEditingController evalController = TextEditingController();

  RxList<Map<String, dynamic>> get availableSkills {
    final ownedIds = skills_Sudent.map((s) => s["id_skill"]).toSet();
    return RxList<Map<String, dynamic>>.from(
        skills.where((s) => !ownedIds.contains(s["id_skill"])));
  }

  @override
  void onInit() {
    super.onInit();
    data = Get.arguments;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await select_student_skill();
    });
  }

  Future select_student_skill() async {
    showLoading();
    await del();
    var res = await postData(Linkapi.select_student_skill, {"id_student": data["id_student"]});
    await select_skill();
    hideLoading();

    if (res["stat"] == "ok") {
      skills_Sudent.assignAll(List<Map<String, dynamic>>.from(res["data"]));
      print("skills_Sudent==${skills_Sudent}");
    } else if (res["stat"] == "error") {
      mySnackbar("تنبيه", res["msg"]);
    }
  }

  Future select_skill() async {
    var res = await postData(Linkapi.select_skill, {});
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
    print("data===${data2}");
    showLoading();
    await del();
    var res=await postData(Linkapi.insert_student_skills, data2);
    hideLoading();

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
          showLoading();
          try {
            var res = await postData(Linkapi.update_student_skill, {
              "id": skill["id"],
              "avaluation": val, // استخدام القيمة الجديدة
            });
            hideLoading();

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
          } catch (e) {
            hideLoading();
            mySnackbar("خطأ", "حدث خطأ غير متوقع: $e");
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
          Get.back(); // أغلق الديالوج أولًا
          showLoading(); // عرض شاشة التحميل
          try {
            var res = await postData(Linkapi.delet_student_skills, {
              "id": skill["id"],
            });

            hideLoading(); // إخفاء شاشة التحميل

            if (res["stat"] == "ok") {
              skills_Sudent.remove(skill);
              mySnackbar("تم", "تم حذف المهارة بنجاح", type: "g");
            } else if (res["stat"] == "no") {
              mySnackbar("تنبيه", "لم يتم حذف المهارة، حاول مرة أخرى");
            } else {
              mySnackbar("خطأ", "حدث خطأ، تحقق من الاتصال بالإنترنت");
            }
          } catch (e) {
            hideLoading();
            mySnackbar("خطأ", "حدث خطأ غير متوقع: $e");
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
