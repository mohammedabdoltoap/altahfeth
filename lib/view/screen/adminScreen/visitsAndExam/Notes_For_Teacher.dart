import 'package:althfeth/api/LinkApi.dart';
import 'package:althfeth/api/apiFunction.dart';
import 'package:althfeth/constants/function.dart';
import 'package:althfeth/constants/loadingWidget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Notes_For_Teacher extends StatelessWidget {

  Notes_For_TeacherController controller=Get.put(Notes_For_TeacherController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.teal[700],
        title: const Text(
          "ملاحظات للمعلم",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // حقل النص
            Expanded(
              child: TextField(
                controller:controller.notesController,
                maxLines: null,
                expands: true, // يملأ المساحة المتاحة
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  hintText: "اكتب الملاحظات هنا...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.teal.shade300),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(16),
                ),
                style: const TextStyle(fontSize: 16),
              ),
            ),

            const SizedBox(height: 20),

            // زر الحفظ
            SizedBox(
              width: double.infinity, // يملأ العرض
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal[700],
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async{
                  String notes = controller.notesController.text.trim();
                  if (notes.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("الرجاء كتابة الملاحظات قبل الحفظ"),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                    return;
                  }
                 await controller.insert_notes_for_teacher();
                  // هنا ضع وظيفة حفظ الملاحظات (API أو قاعدة البيانات)

                  controller.notesController.clear();
                },
                child: const Text(
                  "حفظ الملاحظات",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class Notes_For_TeacherController extends GetxController{

  var dataVisitCircle;

  @override
  void onInit() {
    dataVisitCircle=Get.arguments;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      select_notes_for_teacher();
    },);
  }
  TextEditingController notesController = TextEditingController();

  RxBool isLoading = false.obs;

  Future insert_notes_for_teacher() async {
    try {
      if (data_notes.isNotEmpty) {
        final res = await handleRequest<dynamic>(
          isLoading: isLoading,
          loadingMessage: "جاري تحديث الملاحظات...",
          useDialog: true,
          immediateLoading: true,
          action: () async {
            return await postData(Linkapi.update_notes_for_teacher, {
              "notes": notesController.text,
              "id_notes": data_notes["id_notes"],
            });
          },
        );

        if (res == null) return;
        if (res is! Map) {
          mySnackbar("خطأ", "فشل الاتصال بالخادم");
          return;
        }

        if (res["stat"] == "ok") {
          Get.back();
          mySnackbar("نجاح", "${res["msg"]}", type: "g");
        } else {
          mySnackbar("تنبيه", "${res["msg"]}");
        }
      } else {
        final res = await handleRequest<dynamic>(
          isLoading: isLoading,
          loadingMessage: "جاري إضافة الملاحظات...",
          useDialog: true,
          immediateLoading: true,
          action: () async {
            return await postData(Linkapi.insert_notes_for_teacher, {
              "id_circle": dataVisitCircle["id_circle"],
              "id_visit": dataVisitCircle["id_visit"],
              "notes": notesController.text,
              "responsible_user_id": dataVisitCircle["id_user"]
            });
          },
        );

        if (res == null) return;
        if (res is! Map) {
          mySnackbar("خطأ", "فشل الاتصال بالخادم");
          return;
        }

        if (res["stat"] == "ok") {
          Get.back();
          mySnackbar("نجاح", "تم إضافة الملاحظات", type: "g");
        } else {
          mySnackbar("تنبيه", "حصل خطأ لم تتم الإضافة");
        }
      }
    } catch (e, stackTrace) {
      print("Error in insert_notes_for_teacher: $e");
      print(stackTrace);
      mySnackbar("خطأ", "حدث خطأ غير متوقع، حاول مرة أخرى");
    }
  }

  Map<String, dynamic> data_notes={};
  Future select_notes_for_teacher() async {
    try {
      var res = await postData(Linkapi.select_notes_for_teacher_by_circle, {
        "id_visit": dataVisitCircle["id_visit"],
      });
      
      if (res != null && res is Map) {
        if (res["stat"] == "ok") {
          data_notes = res["data"];
          notesController.text = data_notes["notes"] ?? "";
          print("data_notes.runtimeType====${data_notes.runtimeType}");
        }
      }
    } catch (e, stackTrace) {
      print("Error in select_notes_for_teacher: $e");
      print(stackTrace);
    }
  }


}