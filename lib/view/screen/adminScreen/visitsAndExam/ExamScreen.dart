import 'package:althfeth/api/LinkApi.dart';
import 'package:althfeth/api/apiFunction.dart';
import 'package:althfeth/constants/appButton.dart';
import 'package:althfeth/constants/customTextField.dart';
import 'package:althfeth/constants/loadingWidget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../constants/function.dart';
import '../../../../controller/visitAndExamController/Add_VisitController.dart';
import 'StudentsList.dart';



class ExamScreen extends StatelessWidget {
  final ExamScreenController controller = Get.put(ExamScreenController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("تحديد النطاق"),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.datasoura.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              "الحفظ الشهري",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            RangeCard(
              title: "نطاق البداية",
              selectedSoura: controller.fromSoura_monthly,
              selectedAya: controller.from_id_aya_monthly,
              datasoura: controller.datasoura,
              onSouraChanged: (val) {
                controller.fromSoura_monthly.value = val;
                controller.from_id_aya_monthly.value = null;
              },
              onAyaChanged: (val) => controller.from_id_aya_monthly.value = val,
            ),
            RangeCard(
              title: "نطاق النهاية",
              selectedSoura: controller.toSoura_monthly,
              selectedAya: controller.to_id_aya_monthly,
              datasoura: controller.datasoura,
              onSouraChanged: (val) {
                controller.toSoura_monthly.value = val;
                controller.to_id_aya_monthly.value = null;
              },
              onAyaChanged: (val) => controller.to_id_aya_monthly.value = val,
            ),
            CustomTextField(
              controller: controller.hifz_monthly,
              label: "درجة الحفظ",
              hint: "أدخل درجة الحفظ",
              keyboardType: TextInputType.number,
              onChanged: (_) => checkGrade(controller: controller.hifz_monthly, label: "درجة الحفظ"),
            ),

            CustomTextField(
              controller: controller.tilawa_monthly,
              label: "درجة التلاوة",
              hint: "أدخل درجة التلاوة",
              keyboardType: TextInputType.number,
              onChanged: (_) => checkGrade(controller: controller.tilawa_monthly, label: "درجة التلاوة"),
            ),
            Divider(height: 30, thickness: 2),
            Text(
              "المراجعة الشهرية",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            RangeCard(
              title: "نطاق البداية",
              selectedSoura: controller.fromSoura_revision,
              selectedAya: controller.from_id_aya_revision,
              datasoura: controller.datasoura,
              onSouraChanged: (val) {
                controller.fromSoura_revision.value = val;
                controller.from_id_aya_revision.value = null;
              },
              onAyaChanged: (val) => controller.from_id_aya_revision.value = val,
            ),
            RangeCard(
              title: "نطاق النهاية",
              selectedSoura: controller.toSoura_revision,
              selectedAya: controller.to_id_aya_revision,
              datasoura: controller.datasoura,
              onSouraChanged: (val) {
                controller.toSoura_revision.value = val;
                controller.to_id_aya_revision.value = null;
              },
              onAyaChanged: (val) => controller.to_id_aya_revision.value = val,
            ),
            CustomTextField(
              controller: controller.hifz_revision,
              label: "درجة الحفظ",
              hint: "أدخل درجة الحفظ",
              keyboardType: TextInputType.number,
              onChanged: (_) => checkGrade(controller: controller.hifz_revision, label: "درجة الحفظ"),
            ),

            CustomTextField(
              controller: controller.tilawa_revision,
              label: "درجة التلاوة",
              hint: "أدخل درجة التلاوة",
              keyboardType: TextInputType.number,
              onChanged: (_) => checkGrade(controller: controller.tilawa_revision, label: "درجة التلاوة"),
            ),
            Divider(height: 30, thickness: 2),

            CustomTextField(
              controller: controller.notes,
              label: "جوانب يجب اصلاحها في الحفظ والتلاوة",
              hint: "جوانب يجب اصلاحها في الحفظ والتلاوة",
            ),

            const SizedBox(height: 20),

          AppButton(text: "اعتماد الدرجات", onPressed:controller.insert_visit_exam_result),
            const SizedBox(height: 20),
          ],
        );
      }),
    );
  }


  void checkGrade({
    required TextEditingController controller,
    required String label,
  }) {
    final value = controller.text;
    if (value.isEmpty) return;

    final num? number = num.tryParse(value);
    if (number == null) {
      controller.text = "";
      return;
    }

    if (number < 0) {
      controller.text = "0";
      controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length),
      );
      Get.snackbar(
        "تنبيه",
        "$label لا يمكن أن تكون أقل من 0",
        backgroundColor: Colors.red.shade100,
        colorText: Colors.black87,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } else if (number > 100) {
      controller.text = "100";
      controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length),
      );
      Get.snackbar(
        "تنبيه",
        "$label لا يمكن أن تتجاوز 100",
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.black87,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }

}



class RangeCard extends StatelessWidget {
  final String title;
  final Rxn<Map<String, dynamic>> selectedSoura;
  final Rx<int?> selectedAya;
  final RxList<Map<String, dynamic>> datasoura;
  final void Function(Map<String, dynamic>?) onSouraChanged;
  final void Function(int?) onAyaChanged;

  const RangeCard({
    Key? key,
    required this.title,
    required this.selectedSoura,
    required this.selectedAya,
    required this.datasoura,
    required this.onSouraChanged,
    required this.onAyaChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade700,
              ),
            ),
            const SizedBox(height: 20),
            Obx(() {
              return DropdownButtonFormField<Map<String, dynamic>>(
                decoration: InputDecoration(
                  prefixIcon:
                  const Icon(Icons.menu_book_rounded, color: Colors.teal),
                  labelText: title.contains("بداية")
                      ? "من سورة"
                      : "إلى سورة",
                  labelStyle: const TextStyle(color: Colors.teal),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                value: selectedSoura.value,
                items: datasoura.map((soura) {
                  return DropdownMenuItem<Map<String, dynamic>>(
                    value: soura,
                    child: Text(
                      "${soura['soura_name']} (${soura['soura_no']})",
                      style: const TextStyle(fontSize: 18),
                    ),
                  );
                }).toList(),
                onChanged: onSouraChanged,
              );
            }),
            const SizedBox(height: 10),
            Obx(() {
              if (selectedSoura.value == null) return const SizedBox();

              final ayatCount = int.tryParse(
                  selectedSoura.value?['ayat_count'].toString() ?? "0") ??
                  0;

              final ayatItems = List.generate(
                ayatCount,
                    (index) => DropdownMenuItem<int>(
                  value: index + 1,
                  child: Text((index + 1).toString()),
                ),
              );

              return DropdownButtonFormField<int>(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.format_list_numbered,
                      color: Colors.teal),
                  labelText: title.contains("بداية")
                      ? "من آية رقم"
                      : "إلى آية رقم",
                  labelStyle: const TextStyle(color: Colors.teal),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                value: selectedAya.value,
                items: ayatItems,
                onChanged: onAyaChanged,
              );
            }),
          ],
        ),
      ),
    );
  }
}

class ExamScreenController extends GetxController {
  var dataVistAndStudent;

  // الحفظ الشهري
  var from_id_aya_monthly = Rx<int?>(null);
  var fromSoura_monthly = Rxn<Map<String, dynamic>>();
  var to_id_aya_monthly = Rx<int?>(null);
  var toSoura_monthly = Rxn<Map<String, dynamic>>();
  TextEditingController hifz_monthly = TextEditingController();
  TextEditingController tilawa_monthly = TextEditingController();

  // المراجعة الشهرية
  var from_id_aya_revision = Rx<int?>(null);
  var fromSoura_revision = Rxn<Map<String, dynamic>>();
  var to_id_aya_revision = Rx<int?>(null);
  var toSoura_revision = Rxn<Map<String, dynamic>>();

  TextEditingController hifz_revision = TextEditingController();
  TextEditingController tilawa_revision = TextEditingController();
  TextEditingController notes = TextEditingController();


  RxList<Map<String, dynamic>> datasoura = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    dataVistAndStudent = Get.arguments;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      select_sour_quran();
    });
    super.onInit();
  }

  Future select_sour_quran() async {

    showLoading();
    await del();
    var res = await postData(Linkapi.select_sour_quran, {});
    hideLoading();
    if (res["stat"] == "ok") {
      datasoura.assignAll(List<Map<String, dynamic>>.from(res["data"]));
    } else if (res["stat"] == "error") {
      mySnackbar("تنبيه", "${res["msg"]}");
    } else if (res["stat"] == "no") {
      mySnackbar("تنبيه", "لا يوجد بيانات");
    } else {
      mySnackbar("تنبيه", "خطأ غير متوقع");
    }
  }



  /// دالة التحقق من صحة البيانات وإرجاع Map جاهز للحفظ
  Future insert_visit_exam_result() async {
    try {
      // ===== فحص نطاق الحفظ الشهري =====
      if (fromSoura_monthly.value?["id_soura"] != null &&
          toSoura_monthly.value?["id_soura"] != null) {
        if (toSoura_monthly.value!["id_soura"] < fromSoura_monthly.value!["id_soura"]) {
          mySnackbar("خطأ", "حدد نطاق السور لاختبار الحفظ بشكل صحيح");
          return;
        }
        if (toSoura_monthly.value!["id_soura"] == fromSoura_monthly.value!["id_soura"] &&
            (from_id_aya_monthly.value ?? 0) >= (to_id_aya_monthly.value ?? 0)) {
          mySnackbar("خطأ", "حدد نطاق السور بشكل صحيح: لا يمكن أن تكون البداية والنهاية متساوية أو النهاية أقل");
          return;
        }
      }

      // ===== فحص نطاق المراجعة الشهرية =====
      if (fromSoura_revision.value?["id_soura"] != null &&
          toSoura_revision.value?["id_soura"] != null) {
        if (toSoura_revision.value!["id_soura"] < fromSoura_revision.value!["id_soura"]) {
          mySnackbar("خطأ", "حدد نطاق السور لاختبار المراجعة بشكل صحيح");
          return;
        }
        if (toSoura_revision.value!["id_soura"] == fromSoura_revision.value!["id_soura"] &&
            (from_id_aya_revision.value ?? 0) >= (to_id_aya_revision.value ?? 0)) {
          mySnackbar("خطأ", "حدد نطاق السور بشكل صحيح: لا يمكن أن تكون البداية والنهاية متساوية أو النهاية أقل");
          return;
        }
      }

      // ===== التحقق من ملء البيانات =====
      bool monthlyFilled = fromSoura_monthly.value?["id_soura"] != null &&
          toSoura_monthly.value?["id_soura"] != null &&
          from_id_aya_monthly.value != null &&
          to_id_aya_monthly.value != null &&
          hifz_monthly.text.trim().isNotEmpty &&
          tilawa_monthly.text.trim().isNotEmpty;

      bool revisionFilled = fromSoura_revision.value?["id_soura"] != null &&
          toSoura_revision.value?["id_soura"] != null &&
          from_id_aya_revision.value != null &&
          to_id_aya_revision.value != null &&
          hifz_revision.text.trim().isNotEmpty &&
          tilawa_revision.text.trim().isNotEmpty;

      if (!monthlyFilled && !revisionFilled) {
        mySnackbar("خطأ", "ادخل بيانات كاملة للحفظ الشهري أو المراجعة الشهرية على الأقل");
        return;
      }
      print("fromSoura_revision.value====${fromSoura_revision.value?["id_soura"]}");
      // ===== تجهيز البيانات للإرسال =====
      Map<String, dynamic> data = {
        "id_visit": dataVistAndStudent["id_visit"],
        "id_student": dataVistAndStudent["id_student"],
        "hifz_monthly": monthlyFilled ? hifz_monthly.text.trim() :null,
        "tilawa_monthly": monthlyFilled ? tilawa_monthly.text.trim() :null,
        "from_id_soura_monthly": fromSoura_monthly.value?["id_soura"] ,
        "to_id_soura_monthly": toSoura_monthly.value?["id_soura"],

        "from_id_aya_monthly": from_id_aya_monthly.value ,
        "to_id_aya_monthly":  to_id_aya_monthly.value ,
        "hifz_revision":  hifz_revision.text.trim() ,
        "tilawa_revision":  tilawa_revision.text.trim() ,
        "from_id_soura_revision":  fromSoura_revision.value?["id_soura"],
        "to_id_soura_revision": toSoura_revision.value?["id_soura"],

        "from_id_aya_revision":  from_id_aya_revision.value,
        "to_id_aya_revision":  to_id_aya_revision.value ,
        "notes":notes.text
      };
      print("data======${data}");
      // ===== إرسال البيانات =====
      var res = await postData(Linkapi.insert_visit_exam_result, data);

      // ===== التعامل مع النتيجة =====
      if (res["stat"] == "ok") {
        Get.back();
        mySnackbar("نجاح", "${res["msg"]}", type: "g");

        // حذف الطالب من قائمة الطلاب بعد الإضافة
        StudentsListController controller = Get.find();controller.students.removeWhere((student) => student["id_student"] == dataVistAndStudent["id_student"]);
        Add_VisitController add_visitController=Get.put(Add_VisitController());
        add_visitController.select_visitsed();
        add_visitController.select_previous_visits();

      } else if (res["stat"] == "no") {
        mySnackbar("تنبيه", "${res["msg"]}");
      } else if (res["stat"] == "error") {
        mySnackbar("خطأ", "${res["msg"]}");
      } else {
        mySnackbar("تنبيه", "تحقق من الاتصال بالإنترنت");
      }
    } catch (e, stackTrace) {
      // ===== التعامل مع أي خطأ غير متوقع =====
      print("Error in insert_visit_exam_result: $e");
      print(stackTrace);
      mySnackbar("خطأ", "حدث خطأ غير متوقع، حاول مرة أخرى");
    }
  }

}
