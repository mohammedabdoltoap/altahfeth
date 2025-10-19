import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:althfeth/api/LinkApi.dart';
import 'package:althfeth/api/apiFunction.dart';
import 'package:althfeth/constants/function.dart';
import '../../../../constants/appButton.dart';
import '../../../../constants/customTextField.dart';
import 'ExamScreen.dart';
import 'StudentsListUpdate.dart';

class UpdateExamScreen extends StatelessWidget {
  final UpdateExamController controller = Get.put(UpdateExamController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("تعديل بيانات الطالب"),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: Obx(() {
        if (!controller.isLoaded.value) {
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
              selectedSoura: controller.fromSouraMonthly,
              selectedAya: controller.fromAyaMonthly,
              datasoura: controller.datasoura,
              onSouraChanged: (val) {
                controller.fromSouraMonthly.value = val;
                controller.fromAyaMonthly.value = null;
              },
              onAyaChanged: (val) => controller.fromAyaMonthly.value = val,
            ),
            RangeCard(
              title: "نطاق النهاية",
              selectedSoura: controller.toSouraMonthly,
              selectedAya: controller.toAyaMonthly,
              datasoura: controller.datasoura,
              onSouraChanged: (val) {
                controller.toSouraMonthly.value = val;
                controller.toAyaMonthly.value = null;
              },
              onAyaChanged: (val) => controller.toAyaMonthly.value = val,
            ),
            CustomTextField(
              controller: controller.hifzMonthly,
              label: "درجة الحفظ",
              hint: "أدخل درجة الحفظ",
              keyboardType: TextInputType.number,
              onChanged: (_) => checkGrade(controller: controller.hifzMonthly, label: "درجة الحفظ"),
            ),

            CustomTextField(
              controller: controller.tilawaMonthly,
              label: "درجة التلاوة",
              hint: "أدخل درجة التلاوة",
              keyboardType: TextInputType.number,
              onChanged: (_) => checkGrade(controller: controller.tilawaMonthly, label: "درجة التلاوة"),
            ),

            const Divider(height: 30, thickness: 2),
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
              selectedSoura: controller.fromSouraRevision,
              selectedAya: controller.fromAyaRevision,
              datasoura: controller.datasoura,
              onSouraChanged: (val) {
                controller.fromSouraRevision.value = val;
                controller.fromAyaRevision.value = null;
              },
              onAyaChanged: (val) => controller.fromAyaRevision.value = val,
            ),
            RangeCard(
              title: "نطاق النهاية",
              selectedSoura: controller.toSouraRevision,
              selectedAya: controller.toAyaRevision,
              datasoura: controller.datasoura,
              onSouraChanged: (val) {
                controller.toSouraRevision.value = val;
                controller.toAyaRevision.value = null;
              },
              onAyaChanged: (val) => controller.toAyaRevision.value = val,
            ),
            CustomTextField(
              controller: controller.hifzRevision,
              label: "درجة الحفظ",
              hint: "أدخل درجة الحفظ",
              keyboardType: TextInputType.number,
              onChanged: (_) => checkGrade(controller: controller.hifzRevision, label: "درجة الحفظ"),
            ),

            CustomTextField(
              controller: controller.tilawaRevision,
              label: "درجة التلاوة",
              hint: "أدخل درجة التلاوة",
              keyboardType: TextInputType.number,
              onChanged: (_) => checkGrade(controller: controller.tilawaRevision, label: "درجة التلاوة"),
            ),
            Divider(height: 30, thickness: 2),

            CustomTextField(
              controller: controller.notes,
              label: "جوانب يجب اصلاحها في الحفظ والتلاوة",
              hint: "جوانب يجب اصلاحها في الحفظ والتلاوة",
            ),

            const SizedBox(height: 20),
            AppButton(
              text: "اعتماد التعديلات",
              onPressed: () => controller.saveVisitExamResult(),
            ),
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
class UpdateExamController extends GetxController {
  var studentData = <String, dynamic>{}.obs;
  var datasoura = <Map<String, dynamic>>[].obs;
  var isLoaded = false.obs;

  // الحفظ الشهري
  var fromAyaMonthly = Rx<int?>(null);
  var fromSouraMonthly = Rxn<Map<String, dynamic>>();
  var toAyaMonthly = Rx<int?>(null);
  var toSouraMonthly = Rxn<Map<String, dynamic>>();
  TextEditingController hifzMonthly = TextEditingController();
  TextEditingController tilawaMonthly = TextEditingController();

  // المراجعة الشهرية
  var fromAyaRevision = Rx<int?>(null);
  var fromSouraRevision = Rxn<Map<String, dynamic>>();
  var toAyaRevision = Rx<int?>(null);
  var toSouraRevision = Rxn<Map<String, dynamic>>();
  TextEditingController hifzRevision = TextEditingController();
  TextEditingController tilawaRevision = TextEditingController();
  TextEditingController notes = TextEditingController();

  var id_visit;
  @override
  void onInit() {
    var args = Get.arguments;
    studentData.assignAll(args["student"]);
    id_visit=args["id_visit"];

    fetchSourData().then((_) {
      fillStudentData();
      isLoaded.value = true;
    });

    super.onInit();
  }

  Future fetchSourData() async {
    var res = await postData(Linkapi.select_sour_quran, {});
    if (res["stat"] == "ok") {
      datasoura.assignAll(List<Map<String, dynamic>>.from(res["data"]));
    }
  }

  void fillStudentData() {
    var s = studentData;
    print("ss=======${s["hifz_monthly"].runtimeType}");
    // الحفظ الشهري
    fromSouraMonthly.value = findSoura(s["from_id_soura_monthly"]);
    toSouraMonthly.value = findSoura(s["to_id_soura_monthly"]);
    fromAyaMonthly.value = s["from_id_aya_monthly"];
    toAyaMonthly.value = s["to_id_aya_monthly"];
    hifzMonthly.text = (s["hifz_monthly"] == 0 ||s["hifz_monthly"]==null) ? "" : s["hifz_monthly"].toString();
    tilawaMonthly.text = (s["tilawa_monthly"] == 0  ||s["tilawa_monthly"]==null)  ? "" : s["tilawa_monthly"].toString();

    // المراجعة الشهرية
    fromSouraRevision.value = findSoura(s["from_id_soura_revision"]);
    toSouraRevision.value = findSoura(s["to_id_soura_revision"]);
    fromAyaRevision.value = s["from_id_aya_revision"];
    toAyaRevision.value = s["to_id_aya_revision"];
    hifzRevision.text = (s["hifz_revision"] == 0 ||s["hifz_revision"]==null ) ? "" : s["hifz_revision"].toString();
    tilawaRevision.text = (s["tilawa_revision"] == 0 || s["tilawa_revision"]==null) ? "" : s["tilawa_revision"].toString();
    notes.text = (s["notes"] == null) ? "" : s["notes"].toString();
  }

  Map<String, dynamic>? findSoura(int? id) {
    if (id == null) return null;
    return datasoura.firstWhereOrNull((e) => e["id_soura"] == id);
  }

  Future saveVisitExamResult() async {
    try {
      // ===== تحقق من ملء بيانات الحفظ =====
      bool monthlyFilled = fromSouraMonthly.value?["id_soura"] != null &&
          toSouraMonthly.value?["id_soura"] != null &&
          fromAyaMonthly.value != null &&
          toAyaMonthly.value != null &&
          hifzMonthly.text.trim().isNotEmpty &&
          tilawaMonthly.text.trim().isNotEmpty;

      // ===== تحقق من وجود أي بيانات جزئية للحفظ =====
      bool monthlyPartial = hifzMonthly.text.trim().isNotEmpty ||
          tilawaMonthly.text.trim().isNotEmpty ||
          fromSouraMonthly.value?["id_soura"] != null ||
          toSouraMonthly.value?["id_soura"] != null ||
          fromAyaMonthly.value != null ||
          toAyaMonthly.value != null;

      // ===== تحقق من ملء بيانات المراجعة =====
      bool revisionFilled = fromSouraRevision.value?["id_soura"] != null &&
          toSouraRevision.value?["id_soura"] != null &&
          fromAyaRevision.value != null &&
          toAyaRevision.value != null &&
          hifzRevision.text.trim().isNotEmpty &&
          tilawaRevision.text.trim().isNotEmpty;

      // ===== تحقق من وجود أي بيانات جزئية للمراجعة =====
      bool revisionPartial = hifzRevision.text.trim().isNotEmpty ||
          tilawaRevision.text.trim().isNotEmpty ||
          fromSouraRevision.value?["id_soura"] != null ||
          toSouraRevision.value?["id_soura"] != null ||
          fromAyaRevision.value != null ||
          toAyaRevision.value != null;

      // ===== تحقق من إدخال بيانات كاملة على الأقل =====
      if (!monthlyFilled && !revisionFilled) {
        mySnackbar("خطأ", "ادخل بيانات كاملة للحفظ الشهري أو المراجعة الشهرية على الأقل");
        return;
      }

      // ===== تحقق من إدخال بيانات جزئية بدون إكمال الحفظ =====
      if (monthlyPartial && !monthlyFilled) {
        mySnackbar("خطأ", "أكمل بيانات الحفظ كاملة أو اتركها فارغة");
        return;
      }

      // ===== تحقق من إدخال بيانات جزئية بدون إكمال المراجعة =====
      if (revisionPartial && !revisionFilled) {
        mySnackbar("خطأ", "أكمل بيانات المراجعة كاملة أو اتركها فارغة");
        return;
      }

      // ===== تحقق من نطاق الحفظ إذا أدخل المستخدم بياناته كاملة =====
      if (monthlyFilled) {
        if (toSouraMonthly.value!["id_soura"] < fromSouraMonthly.value!["id_soura"]) {
          mySnackbar("خطأ", "حدد نطاق السور لاختبار الحفظ بشكل صحيح");
          return;
        }
        if (toSouraMonthly.value!["id_soura"] == fromSouraMonthly.value!["id_soura"] &&
            (fromAyaMonthly.value ?? 0) >= (toAyaMonthly.value ?? 0)) {
          mySnackbar("خطأ", "حدد نطاق الآيات للحفظ بشكل صحيح");
          return;
        }
      }

      // ===== تحقق من نطاق المراجعة إذا أدخل المستخدم بياناته كاملة =====
      if (revisionFilled) {
        if (toSouraRevision.value!["id_soura"] < fromSouraRevision.value!["id_soura"]) {
          mySnackbar("خطأ", "حدد نطاق السور لاختبار المراجعة بشكل صحيح");
          return;
        }
        if (toSouraRevision.value!["id_soura"] == fromSouraRevision.value!["id_soura"] &&
            (fromAyaRevision.value ?? 0) >= (toAyaRevision.value ?? 0)) {
          mySnackbar("خطأ", "حدد نطاق الآيات للمراجعة بشكل صحيح");
          return;
        }
      }

      // ===== تجهيز البيانات للإرسال مع السماح بالقيم null =====
      Map<String, dynamic> data = {
        "id_result": studentData["id_result"],
        "id_visit": id_visit,
        "id_student": studentData["id_student"],
        "hifz_monthly": monthlyFilled ? hifzMonthly.text.trim() : null,
        "tilawa_monthly": monthlyFilled ? tilawaMonthly.text.trim() : null,
        "from_id_soura_monthly": fromSouraMonthly.value?["id_soura"],
        "to_id_soura_monthly": toSouraMonthly.value?["id_soura"],
        "from_id_aya_monthly": fromAyaMonthly.value,
        "to_id_aya_monthly": toAyaMonthly.value,
        "hifz_revision": revisionFilled ? hifzRevision.text.trim() : null,
        "tilawa_revision": revisionFilled ? tilawaRevision.text.trim() : null,
        "from_id_soura_revision": fromSouraRevision.value?["id_soura"],
        "to_id_soura_revision": toSouraRevision.value?["id_soura"],
        "from_id_aya_revision": fromAyaRevision.value,
        "to_id_aya_revision": toAyaRevision.value,
        "notes": notes.text.trim(),
      };

      // ===== إرسال البيانات =====
      var api = studentData["id_result"] == null
          ? Linkapi.insert_visit_exam_result
          : Linkapi.update_visit_exam_result;

      var res = await postData(api, data);

      if (res["stat"] == "ok") {
        StudentsListUpdateController controller = Get.find();
        await controller.select_data_visit_previous();
        Get.back();
        mySnackbar("نجاح", "${res["msg"]}", type: "g");
      } else if (res["stat"] == "no") {
        mySnackbar("تنبيه", "${res["msg"]}");
      } else if (res["stat"] == "error") {
        mySnackbar("خطأ", "${res["msg"]}");
      } else {
        mySnackbar("تنبيه", "تحقق من الاتصال بالإنترنت");
      }

    } catch (e, stackTrace) {
      print("Error in saveVisitExamResult: $e");
      print(stackTrace);
      mySnackbar("خطأ", "حدث خطأ غير متوقع، حاول مرة أخرى");
    }

  }



}
