
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../constants/appButton.dart';
import '../../constants/color.dart';
import '../../constants/function.dart';
import '../../controller/Monthly_PlanController.dart';
import '../widget/monthly_plan/souraSelector.dart';
class Monthly_Plan extends StatelessWidget {
  final Monthly_PlanController controller = Get.put(Monthly_PlanController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("التخطيط الشهري"),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: Container(
        color: Colors.grey.shade100,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // معلومات الطالب
                    Text(
                      "معلومات الطالب",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text("الاسم:   ${controller.dataArg["name_student"]}", style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    Text("المرحلة:   ${controller.dataArg["name_stages"]}", style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 4),
                    Text("المستوى:   ${controller.dataArg["name_level"]}", style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 16),

                    // Dropdown السنوات
                    Obx(() {
                      final years = controller.years;

                      Map<String, dynamic>? selectedYearMap;
                      if (controller.selectedYear.value != null) {
                        try {
                          selectedYearMap = years.firstWhere(
                                (y) => y['id_year'] == controller.selectedYear.value,
                          );
                        } catch (e) {
                          selectedYearMap = null;
                        }
                      }

                      return DropdownButtonFormField<Map<String, dynamic>>(
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.calendar_today, color: Colors.teal),
                          labelText: "اختر السنة",
                          labelStyle: TextStyle(color: Colors.teal.shade600),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        value: selectedYearMap,
                        items: years.map((year) {
                          return DropdownMenuItem<Map<String, dynamic>>(
                            value: year,
                            child: Text(
                              year['name_year'].toString(),
                              style: const TextStyle(fontSize: 16),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            controller.selectedYear.value = val['id_year'];
                            controller.selectedMonth.value = null;
                          }
                        },
                      );
                    }),

                    const SizedBox(height: 16),

                    // Dropdown الأشهر
                    Obx(() {
                      final months = controller.months;

                      Map<String, dynamic>? selectedMonthMap;
                      if (controller.selectedMonth.value != null) {
                        try {
                          selectedMonthMap = months.firstWhere(
                                (m) => m['id_month'] == controller.selectedMonth.value,
                          );
                        } catch (e) {
                          selectedMonthMap = null;
                        }
                      }

                      return DropdownButtonFormField<Map<String, dynamic>>(
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.date_range, color: Colors.teal),
                          labelText: "اختر الشهر",
                          labelStyle: TextStyle(color: Colors.teal.shade600),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        value: selectedMonthMap,
                        items: months.map((month) {
                          return DropdownMenuItem<Map<String, dynamic>>(
                            value: month,
                            child: Text(
                              "${month['name_month']}, الأيام الفعلية ${month["real_days"]}",
                              style: const TextStyle(fontSize: 16),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            controller.selectedMonth.value = val['id_month'];
                          }
                        },
                      );
                    }),


                    // اختيار نطاق السور
                    SouraSelector(),

                    const SizedBox(height: 24),

                    // زر الحفظ
                    Obx(() => AppButton(

                      text: "حفظ الخطة",
                      color: primaryGreen,
                      isLoading: controller.isLoding_addPlan.value,
                      onPressed: () {
                        // تحقق من الحقول الأساسية
                        if (controller.selectedYear.value == null || controller.selectedMonth.value == null) {
                          mySnackbar("تنبية", "يرجى اختيار السنة والشهر");
                          return;
                        }
                        if (controller.selectedDate.value == null) {
                          mySnackbar("تنبية", "يرجى اختيار تاريخ البداية");
                          return;
                        }
                        if (controller.fromSoura.value == null || controller.start_ayat.value == null) {
                          mySnackbar("تنبية", "يرجى اختيار نطاق السور للبداية ");
                          return;
                        }
                        if (controller.toSoura.value == null || controller.end_ayat.value == null) {
                          mySnackbar("تنبية", "يرجى اختيار نطاق السور للنهاية ");
                          return;
                        }

                        controller.addPlan();
                      },
                    )
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
