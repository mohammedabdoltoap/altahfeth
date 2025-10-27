import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../../api/LinkApi.dart';
import '../../../api/apiFunction.dart';
import '../../../constants/CustomDropdownField.dart';
import '../../../constants/appButton.dart';
import '../../../constants/color.dart';
import '../../../constants/customTextField.dart';
import '../../../constants/function.dart';
import '../../../constants/loadingWidget.dart';
import '../../../constants/readOnlyTextField.dart';
import '../../../controller/dilayAndRevoesController/ReviewController.dart';



class Review extends StatelessWidget {
  ReviewController controller=Get.put(ReviewController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("المراجعة اليومية"),backgroundColor: primaryGreen,),
      body:  Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        child: SingleChildScrollView(
          child: Column(

            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text("معلومات الطالب ",
                      style: TextStyle(
                        fontSize: 17,
                        color: childyGreen,
                        fontWeight: FontWeight.w500,
                      )
                  ),
                ),
              ),
              const SizedBox(height: 15),
              ReadOnlyTextField(label: "اسم الطالب",value: controller.student["name_student"],color_line: Colors.black,),
              const SizedBox(height: 15),

              ReadOnlyTextField(label: "المرحلة",value: controller.student["name_stages"],color_line: Colors.black),
              const SizedBox(height: 15),
              ReadOnlyTextField(label: "المستوى",value: controller.student["name_level"],color_line: Colors.black),
              const SizedBox(height: 15),

              SouraSelector(),
              CustomTextField(controller: controller.markController, label: "الدرجة", hint: "الدرجة",keyboardType:TextInputType.number,),
              Obx(() {
                final items = controller.dataEvaluations.toList();
                return CustomDropdownField(
                  label: "التقييم", 
                  items: items,
                  value: controller.selectedEvaluations.value, 
                  onChanged: (val){
                    controller.selectedEvaluations.value=val;
                  }, 
                  valueKey: "id_evaluation", 
                  displayKey: "name_evaluation"
                );
              }),

              const SizedBox(height: 20),
              AppButton(
                text: "اعتماد المراجعة",
                onPressed: () {
                  controller.addReview();
                },
              ),
              const SizedBox(height: 20),

            ],
          ),
        ),
      ),
    );
  }
}





class SouraSelector extends StatelessWidget {
  // final Monthly_PlanController controller = Get.find();
  final   ReviewController controller=Get.put(ReviewController());

  @override
  Widget build(BuildContext context) {
    return
      Obx(() {
        return Column(
          children: [
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // التاريخ حق المراجعة
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: controller.dataLastReview.value?["date"]!=null?
                        Text(
                          "اخر مراجعة بتاريخ : ${controller.dataLastReview.value?["date"]}",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.teal.shade800,
                            fontWeight: FontWeight.w500,
                          ),
                        ): Text(
                          "اول مراجعة لهذا الطالب اليوم",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.teal.shade800,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      "نطاق البداية",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade700,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // عرض السورة
                    ReadOnlyTextField(
                      value: controller.dataLastReview.value?["to_soura_name"],
                      label: "من سورة",
                      icon: Icons.play_arrow,
                      color: primaryGreen,
                    ),


                    const SizedBox(height: 10),
                    ReadOnlyTextField(
                      value: controller.dataLastReview.value?["to_id_aya"].toString(),
                      label: "من الاية",
                      icon: Icons.format_list_numbered,
                    ),

                  ],
                ),
              ),
            ),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      "نطاق النهاية",
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
                          const Icon(Icons.play_arrow, color: Colors.teal),
                          labelText: "الي سورة",
                          labelStyle: TextStyle(color: Colors.teal),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        value: controller.toSoura.value,
                        items: controller.datasoura.map((soura) {
                          return DropdownMenuItem<Map<String, dynamic>>(
                            value: soura,
                            child: Text(
                              "${soura['soura_name']} (${soura['soura_no']})",
                              style: const TextStyle(fontSize: 18),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          controller.toSoura.value = val;
                          controller.to_id_aya.value = null;
                        },
                      );
                    }),
                    SizedBox(
                      height: 10,
                    ),
                    Obx(() {
                      // لو ما تم اختيار سورة ما نعرضش أي حاجة
                      if (controller.toSoura.value == null) {
                        return const SizedBox(); // أو ممكن ترجع Text("اختر سورة أولاً")
                      }

                      // نحصل على عدد الآيات من السورة المختارة
                      final ayatCount = int.tryParse(controller
                          .toSoura.value?['ayat_count']
                          .toString() ??
                          "0") ??
                          0;

                      // نبني القائمة من 0 إلى ayatCount
                      final ayatItems = List.generate(
                        ayatCount, // بدون +1 لأننا سنبدأ من 1
                            (index) => DropdownMenuItem<int>(
                          value: index + 1, // نخليها تبدأ من 1 بدل 0
                          child: Text((index + 1).toString()),
                        ),
                      );

                      return DropdownButtonFormField<int>(
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.format_list_numbered,
                              color: Colors.teal),
                          labelText: "الي الآية رقم",
                          labelStyle: TextStyle(color: Colors.teal),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        value: controller.to_id_aya.value,
                        items: ayatItems,
                        onChanged: (val) {
                          controller.to_id_aya.value = val;
                        },
                      );
                    }),
                  ],

                ),
              ),
            ),

          ],
        );},
      );

  }
}



