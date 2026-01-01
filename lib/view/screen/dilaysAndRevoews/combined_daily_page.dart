import 'package:althfeth/constants/CustomDropdownField.dart';
import 'package:althfeth/constants/customTextField.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/appButton.dart';
import '../../../constants/color.dart';
import '../../../constants/readOnlyTextField.dart';
import '../../../controller/dilayAndRevoesController/CombinedDailyController.dart';
import '../../widget/offline_indicator.dart';
import '../../widget/searchable_soura_dropdown.dart';

class CombinedDailyPage extends StatelessWidget {
  final CombinedDailyController controller = Get.put(CombinedDailyController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("التسميع والمراجعة اليومية"),
        backgroundColor: primaryGreen,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [primaryGreen.withOpacity(0.05), Colors.white],
          ),
        ),
        child: Column(
          children: [
            OfflineIndicator(),
            
            // رسالة تنبيه عندما يكون forceBoth = true
            Obx(() {
              if (controller.forceBoth.value) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.deepPurple.shade400, Colors.deepPurple.shade600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurple.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.info_outline,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "تنبيه مهم",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "يجب إدخال بيانات التسميع والمراجعة معاً قبل الخروج من الصفحة",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Obx(() => Row(
                              children: [
                                _buildStatusChip(
                                  "التسميع",
                                  controller.dailySaved.value,
                                ),
                                const SizedBox(width: 8),
                                _buildStatusChip(
                                  "المراجعة",
                                  controller.reviewSaved.value,
                                ),
                              ],
                            )),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
            
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // قسم التسميع اليومي
                      _buildDailyReportSection(),
                      
                      const SizedBox(height: 24),
                      
                      // فاصل بصري
                      Container(
                        height: 2,
                        margin: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.transparent, primaryGreen.withOpacity(0.3), Colors.transparent],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // قسم المراجعة اليومية
                      _buildReviewSection(),
                      
                      const SizedBox(height: 32),
                      
                      // زر الحفظ الموحد
                      Obx(() => AppButton(
                        text: controller.forceBoth.value 
                            ? "حفظ التسميع والمراجعة معاً"
                            : "حفظ البيانات",
                        onPressed: () => controller.saveBoth(),
                        height: 50,
                        color: Colors.deepPurple,
                        foregroundColor: Colors.white,
                      )),
                      
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildDailyReportSection() {
    return Column(
      children: [
        _buildStudentInfoCard(),
        const SizedBox(height: 20),
        _buildDailySouraSelector(),
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: CustomTextField(
            controller: controller.dailyMarkController,
            label: "الدرجة",
            hint: "أدخل الدرجة (الحد الأقصى 100)",
            keyboardType: TextInputType.number,
            maxValue: 100,
          ),
        ),
        Obx(() {
          final items = controller.dataEvaluations.toList();
          return CustomDropdownField(
            label: "التقييم",
            items: items,
            value: controller.daily_selectedEvaluations.value,
            onChanged: (val) {
              controller.daily_selectedEvaluations.value = val;
            },
            valueKey: "id_evaluation",
            displayKey: "name_evaluation",
          );
        }),
      ],
    );
  }

  Widget _buildReviewSection() {
    return Column(
      children: [
        _buildStudentInfoCard(),
        const SizedBox(height: 20),
        _buildReviewSouraSelector(),
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: CustomTextField(
            controller: controller.reviewMarkController,
            label: "الدرجة",
            hint: "أدخل الدرجة (الحد الأقصى 100)",
            keyboardType: TextInputType.number,
            maxValue: 100,
          ),
        ),
        Obx(() {
          final items = controller.dataEvaluations.toList();
          return CustomDropdownField(
            label: "التقييم",
            items: items,
            value: controller.review_selectedEvaluations.value,
            onChanged: (val) {
              controller.review_selectedEvaluations.value = val;
            },
            valueKey: "id_evaluation",
            displayKey: "name_evaluation",
          );
        }),
      ],
    );
  }

  Widget _buildStudentInfoCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryGreen.withOpacity(0.1), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryGreen.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person, color: primaryGreen, size: 28),
                const SizedBox(width: 10),
                Text(
                  "معلومات الطالب",
                  style: TextStyle(
                    fontSize: 20,
                    color: primaryGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            ReadOnlyTextField(
              label: "اسم الطالب",
              value: controller.dataArg_Student["name_student"],
              color_line: Colors.black,
            ),
            const SizedBox(height: 15),
            ReadOnlyTextField(
              label: "المرحلة",
              value: controller.dataArg_Student["name_stages"],
              color_line: Colors.black,
            ),
            const SizedBox(height: 15),
            ReadOnlyTextField(
              label: "المستوى",
              value: controller.dataArg_Student["name_level"],
              color_line: Colors.black,
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }

  Widget _buildDailySouraSelector() {
    return Obx(() {
      return Column(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade50, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: controller.dataArglastDailyReport.value?["date"] != null
                          ? Text(
                              "آخر تسميع بتاريخ: ${controller.dataArglastDailyReport.value?["date"]}",
                              style: TextStyle(
                                fontSize: 15,
                                color: primaryGreen,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          : Text(
                              "أول تسميع لهذا الطالب اليوم",
                              style: TextStyle(
                                fontSize: 15,
                                color: primaryGreen,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Icon(Icons.play_circle_filled, color: Colors.blue.shade700, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        "نطاق البداية",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ReadOnlyTextField(
                    value: controller.dataArglastDailyReport.value?["to_soura_name"],
                    label: "من سورة",
                    icon: Icons.play_arrow,
                    color: primaryGreen,
                  ),
                  const SizedBox(height: 10),
                  ReadOnlyTextField(
                    value: controller.dataArglastDailyReport.value?["to_id_aya"].toString(),
                    label: "من الآية",
                    icon: Icons.format_list_numbered,
                  ),
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade50, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.stop_circle, color: Colors.orange.shade700, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        "نطاق النهاية",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SearchableSouraDropdown(
                    souraList: controller.datasoura_d,
                    selectedSoura: controller.daily_toSoura.value,
                    onSelected: (selection) {
                      controller.daily_toSoura.value = selection;
                      controller.daily_to_id_aya.value = null;
                    },
                    labelText: "إلى سورة",
                    accentColor: primaryGreen,
                  ),
                  const SizedBox(height: 10),
                  Obx(() {
                    if (controller.daily_toSoura.value == null) {
                      return const SizedBox();
                    }

                    final ayatCount = int.tryParse(
                            controller.daily_toSoura.value?['ayat_count'].toString() ?? "0") ??
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
                        prefixIcon: Icon(Icons.format_list_numbered, color: primaryGreen),
                        labelText: "إلى الآية رقم",
                        labelStyle: TextStyle(color: primaryGreen),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      value: controller.daily_to_id_aya.value,
                      items: ayatItems,
                      onChanged: (val) {
                        controller.daily_to_id_aya.value = val;
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildReviewSouraSelector() {
    return Obx(() {
      return Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.teal.shade200),
            ),
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "ملاحظة:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.teal.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  controller.dataLastReview.value?["date"] != null
                      ? "آخر مراجعة للطالب كان إلى سورة ${controller.dataLastReview.value?["to_soura_name"]}، آية رقم ${controller.dataLastReview.value?["to_id_aya"].toString()}"
                      : "لا توجد مراجعة سابقة لهذا الطالب",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.teal.shade700,
                  ),
                ),
                if (controller.dataLastReview.value?["date"] != null)
                  Text(
                    "بتاريخ: ${controller.dataLastReview.value?["date"]}",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.teal.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                else
                  Text(
                    "أول مراجعة لهذا الطالب اليوم",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.teal.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
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
                    "نطاق البداية",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SearchableSouraDropdown(
                    souraList: controller.datasoura,
                    selectedSoura: controller.review_fromSoura.value,
                    onSelected: (selection) {
                      controller.review_fromSoura.value = selection;
                      controller.review_from_id_aya.value = null;
                    },
                    labelText: "من سورة",
                    accentColor: Colors.teal,
                  ),
                  const SizedBox(height: 10),
                  Obx(() {
                    if (controller.review_fromSoura.value == null) {
                      return const SizedBox();
                    }

                    final ayatCount = int.tryParse(
                            controller.review_fromSoura.value?['ayat_count'].toString() ?? "0") ??
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
                        prefixIcon: Icon(Icons.format_list_numbered, color: Colors.teal),
                        labelText: "من الآية رقم",
                        labelStyle: TextStyle(color: Colors.teal),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      value: controller.review_from_id_aya.value,
                      items: ayatItems,
                      onChanged: (val) {
                        controller.review_from_id_aya.value = val;
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
                    "نطاق النهاية",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SearchableSouraDropdown(
                    souraList: controller.datasoura,
                    selectedSoura: controller.review_toSoura.value,
                    onSelected: (selection) {
                      controller.review_toSoura.value = selection;
                      controller.review_to_id_aya.value = null;
                    },
                    labelText: "إلى سورة",
                    accentColor: Colors.teal,
                  ),
                  const SizedBox(height: 10),
                  Obx(() {
                    if (controller.review_toSoura.value == null) {
                      return const SizedBox();
                    }

                    final ayatCount = int.tryParse(
                            controller.review_toSoura.value?['ayat_count'].toString() ?? "0") ??
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
                        prefixIcon: const Icon(Icons.format_list_numbered, color: Colors.teal),
                        labelText: "إلى الآية رقم",
                        labelStyle: const TextStyle(color: Colors.teal),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      value: controller.review_to_id_aya.value,
                      items: ayatItems,
                      onChanged: (val) {
                        controller.review_to_id_aya.value = val;
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  // دالة لعرض حالة الحفظ (محفوظ أو لم يحفظ بعد)
  Widget _buildStatusChip(String label, bool isSaved) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isSaved 
            ? Colors.green.withOpacity(0.2) 
            : Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSaved ? Colors.green : Colors.white.withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSaved ? Icons.check_circle : Icons.pending,
            size: 16,
            color: isSaved ? Colors.green : Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: isSaved ? Colors.green : Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
