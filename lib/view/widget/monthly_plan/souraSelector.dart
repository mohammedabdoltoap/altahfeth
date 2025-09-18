import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/Monthly_PlanController.dart';
import '../../screen/test.dart';

class SouraSelector extends StatelessWidget {
  // final Monthly_PlanController controller = Get.find();
  final Monthly_PlanController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return
      Column(
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

              Text(
                "اختر نطاق البداية",
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
                    labelText: "من سورة",
                    labelStyle: TextStyle(color: Colors.teal),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  value: controller.fromSoura.value,
                  items: controller.datasoura.map((soura) {
                    return DropdownMenuItem<Map<String, dynamic>>(
                      value: soura,
                      child: Text(
                        "${soura['soura_name']}",
                        style: const TextStyle(fontSize: 18),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    controller.fromSoura.value = val;
                    controller.start_ayat.value =
                    null; // إعادة تعيين بداية الآية لما يختار سورة جديدة
                  },
                );
              }),
              SizedBox(
                height: 10,
              ),
              Obx(() {
                // لو ما تم اختيار سورة ما نعرضش أي حاجة
                if (controller.fromSoura.value == null) {
                  return const SizedBox(); // أو ممكن ترجع Text("اختر سورة أولاً")
                }

                // نحصل على عدد الآيات من السورة المختارة
                final ayatCount = int.tryParse(controller
                    .fromSoura.value?['ayat_count']
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
                    labelText: "من الآية رقم",
                    labelStyle: TextStyle(color: Colors.teal),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  value: controller.start_ayat.value,
                  items: ayatItems,
                  onChanged: (val) {
                    controller.start_ayat.value = val;
                  },
                );
              }),

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
                      "اختر نطاق النهاية",
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
                              "${soura['soura_name']}",
                              style: const TextStyle(fontSize: 18),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          controller.toSoura.value = val;
                          controller.end_ayat.value = null;
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
                        value: controller.end_ayat.value,
                        items: ayatItems,
                        onChanged: (val) {
                          controller.end_ayat.value = val;
                        },
                      );
                    }),
                  ],

            ),
          ),
              ),
        ],
      );

  }
}
