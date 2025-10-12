import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../../constants/CustomDropdownField.dart';
import '../../../constants/appButton.dart';
import '../../../constants/customTextField.dart';
import '../../../controller/dilayAndRevoesController/Update_ReviewController.dart';

class Update_Review extends StatelessWidget {
  Update_ReviewController controller=Get.put(Update_ReviewController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("تعديل المراجعة"),),
      body:Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  shadowColor: Colors.teal.shade100,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Text(
                            "الاسم: ${controller.dataArg_Student["name_student"]}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.teal.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "المرحلة: ${controller.dataArg_Student["name_stages"]}",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.teal.shade800,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.teal.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "المستوى: ${controller.dataArg_Student["name_level"]}",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.teal.shade800,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ويدجيت اختيار السورة
              SouraSelectorUpDate(),
              const SizedBox(height: 20),
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
            child:Column(
              crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text("التقييم",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade700,
                        ),
                      ),
                    const SizedBox(height: 20),
                    CustomTextField(controller: controller.markController, label: "الدرجة", hint: "الدرجة",keyboardType:TextInputType.number,),
                 Obx(() =>
                    CustomDropdownField(label: "التقييم", items: controller.dataEvaluations, value: controller.selectedEvaluations.value, onChanged: (val){
                      controller.selectedEvaluations.value=val;

                    }, valueKey: "id_evaluation", displayKey: "name_evaluation"),
                     ),
                    const SizedBox(height: 20),

                  ],
                ),
              )
          ),

              AppButton(
                text: "تعديل المراجعة",
                onPressed: () {
                  controller.updateReview();
                },
              )

            ],
          ),
        ),
      ),


    );
  }
}
class SouraSelectorUpDate extends StatelessWidget {
  // final Monthly_PlanController controller = Get.find();
  final Update_ReviewController controller = Get.find();

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
                    // التاريخ حق التسميع
                    Center(
                      child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.teal.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child:Text(
                            "تعديل المراجعة  : ${controller.dataLastReview.value?["date"]}",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.teal.shade800,
                              fontWeight: FontWeight.w500,
                            ),
                          )
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
                    TextFormField(
                      enabled: false,
                      initialValue:controller.dataLastReview.value?["from_soura_name"],
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.play_arrow, color: Colors.teal),
                        labelText: "من سورة",
                        labelStyle: const TextStyle(color: Colors.teal),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      style: const TextStyle(fontSize: 18),
                    ),


                    const SizedBox(height: 10),

                    TextFormField(
                      enabled: false,
                      initialValue: controller.dataLastReview.value?["from_id_aya"].toString(),

                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.format_list_numbered, color: Colors.teal),
                        labelText:"من الاية",
                        labelStyle: const TextStyle(color: Colors.teal),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      style: const TextStyle(fontSize: 18),
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
