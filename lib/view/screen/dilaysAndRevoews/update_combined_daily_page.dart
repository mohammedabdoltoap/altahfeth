import 'package:althfeth/constants/CustomDropdownField.dart';
import 'package:althfeth/constants/customTextField.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/appButton.dart';
import '../../../constants/color.dart';
import '../../../constants/readOnlyTextField.dart';
import '../../../controller/dilayAndRevoesController/UpdateCombinedDailyController.dart';
import '../../widget/offline_indicator.dart';
import '../../widget/searchable_soura_dropdown.dart';

class UpdateCombinedDailyPage extends StatelessWidget {
  final UpdateCombinedDailyController controller = Get.put(UpdateCombinedDailyController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("تعديل التسميع والمراجعة"),
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
                      
                      // زر التحديث الموحد
                      AppButton(
                        text: "تحديث التسميع والمراجعة معاً",
                        onPressed: () => controller.updateBoth(),
                        height: 50,
                        color: Colors.deepPurple,
                        foregroundColor: Colors.white,
                      ),
                      
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
        // عنوان قسم التسميع
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryGreen, primaryGreen.withOpacity(0.8)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.book, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Text(
                "التسميع اليومي",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
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
        // عنوان قسم المراجعة
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal, Colors.teal.withOpacity(0.8)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.refresh, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Text(
                "المراجعة اليومية",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
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
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: primaryGreen.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person, color: primaryGreen, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "الطالب",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  controller.dataArg_Student["name_student"] ?? "",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailySouraSelector() {
    return Column(
      children: [
        // نطاق البداية
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
                    color: primaryGreen,
                  ),
                ),
                const SizedBox(height: 15),
                Obx(() {
                  final items = controller.datasoura.toList();
                  return ReadOnlyTextField(
                      value: controller.dataArglastDailyReport.value?["from_soura_name"],
                      label: "من سورة",
                      icon: Icons.play_arrow,
                      color: primaryGreen,
                    );


                }),
                SizedBox(height: 10,),
                Obx(() {
                  if (controller.daily_fromSoura.value == null) {
                    return const SizedBox.shrink();
                  }

                return  ReadOnlyTextField(
                    value: controller.dataArglastDailyReport.value?["from_id_aya"].toString(),
                    label: "من الاية",
                    icon: Icons.format_list_numbered,
                  );
                }),
              ],
            ),
          ),
        ),
        
        // نطاق النهاية
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
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 15),
                SearchableSouraDropdown(
                  souraList: controller.datasoura,
                  selectedSoura: controller.daily_toSoura.value,
                  onSelected: (selection) {
                    controller.daily_toSoura.value = selection;
                    controller.daily_to_id_aya.value = null;
                  },
                  labelText: "السورة",
                  accentColor: primaryGreen,
                ),
                SizedBox(height: 10,),

                Obx(() {
                  if (controller.daily_toSoura.value == null) {
                    return const SizedBox.shrink();
                  }

                  final ayatCount = int.tryParse(controller.daily_toSoura.value!['ayat_count'].toString()) ?? 0;
                  final ayatItems = List.generate(
                    ayatCount,
                    (index) => DropdownMenuItem<int>(
                      value: index + 1,
                      child: Text((index + 1).toString()),
                    ),
                  );

                  return DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.format_list_numbered, color: Colors.red),
                      labelText: "إلى الآية رقم",
                      labelStyle: const TextStyle(color: Colors.red),
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
  }

  Widget _buildReviewSouraSelector() {
    return Column(
      children: [
        // نطاق البداية
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
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 15),
                SearchableSouraDropdown(
                  souraList: controller.datasoura,
                  selectedSoura: controller.review_fromSoura.value,
                  onSelected: (selection) {
                    controller.review_fromSoura.value = selection;
                    controller.review_from_id_aya.value = null;
                  },
                  labelText: "السورة",
                  accentColor: Colors.teal,
                ),
                const SizedBox(height: 10),
                Obx(() {
                  if (controller.review_fromSoura.value == null) {
                    return const SizedBox.shrink();
                  }

                  final ayatCount = int.tryParse(controller.review_fromSoura.value!['ayat_count'].toString()) ?? 0;
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
        
        // نطاق النهاية
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
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 15),
                SearchableSouraDropdown(
                  souraList: controller.datasoura,
                  selectedSoura: controller.review_toSoura.value,
                  onSelected: (selection) {
                    controller.review_toSoura.value = selection;
                    controller.review_to_id_aya.value = null;
                  },
                  labelText: "السورة",
                  accentColor: Colors.red,
                ),
                const SizedBox(height: 10),
                Obx(() {
                  if (controller.review_toSoura.value == null) {
                    return const SizedBox.shrink();
                  }

                  final ayatCount = int.tryParse(controller.review_toSoura.value!['ayat_count'].toString()) ?? 0;
                  final ayatItems = List.generate(
                    ayatCount,
                    (index) => DropdownMenuItem<int>(
                      value: index + 1,
                      child: Text((index + 1).toString()),
                    ),
                  );

                  return DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.format_list_numbered, color: Colors.red),
                      labelText: "إلى الآية رقم",
                      labelStyle: TextStyle(color: Colors.red),
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
  }
}
