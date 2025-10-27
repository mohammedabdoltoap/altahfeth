import 'package:althfeth/constants/appButton.dart';
import 'package:althfeth/constants/color.dart';
import 'package:althfeth/constants/customTextField.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../constants/CustomDropdownField.dart';
import '../../../../controller/visitAndExamController/Add_VisitController.dart';
import '../AddAdministrativeVisit.dart';
import 'StudentsListUpdate.dart';
class Add_Visit extends StatelessWidget {
  Add_VisitController controller =Get.put(Add_VisitController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: primaryGreen,title: Text("الزيارات"),),
      body: Padding(
        padding:const EdgeInsets.all(20.0),
        child:
        ListView(
          children: [

            Obx(() {
              // مراقبة تحميل البيانات
              final items = controller.circles.toList();
              return CustomDropdownField(
                label: "الحلقه",
                items: items,
                value: controller.selectedIdCirle.value,
                valueKey: "id_circle",
                displayKey: "name_circle",
                onChanged: (val) {
                  controller.selectedIdCirle.value = val ?? 0;
                },
              );
            }),
            Obx(() {
              final items = controller.visits_type.toList();
              return CustomDropdownField(
                label: "نوع الزيارة",
                items: items,
                value: controller.selectedIdVisitsType.value,
                valueKey: "id_visit_type",
                displayKey: "name_visit_type",
                onChanged: (val) {
                  controller.selectedIdVisitsType.value = val ?? 0;
                },
              );
            }),
            Obx(() {
              final items = controller.years.toList();
              return CustomDropdownField(
                label: "اختر السنة",
                items: items,
                value: controller.selectedIdYears.value,
                valueKey: "id_year",
                displayKey: "name_year",
                onChanged: (val) {
                  controller.selectedIdYears.value = val ?? 0;
                },
                icon: Icons.date_range,
              );
            }),

            Obx(() {
              final items = controller.months.toList();
              return CustomDropdownField(
                label: "اختر الشهر",
                items: items,
                value: controller.selectedIdMonths.value,
                valueKey: "id_month",
                displayKey: "month_name",
                onChanged: (val) {
                  controller.selectedIdMonths.value = val ?? 0;
                },
                icon: Icons.date_range,
              );
            }),
            CustomTextField(controller: controller.notes, label: "ملاحظات", hint: "ملاحظة ان وجد"),


            AppButton(text: "اضافة الزيارة", onPressed: () {
              // التحقق من نوع الزيارة
              // إذا كان نوع الزيارة = 2 (إدارية)، انتقل إلى صفحة الزيارة الإدارية
              if (controller.selectedIdVisitsType.value == 2) {
                // التحقق من اختيار الحلقة
                if (controller.selectedIdCirle.value == 0) {
                  Get.snackbar("تنبيه", "الرجاء اختيار الحلقة أولاً");
                  return;
                }
                Get.to(() => AddAdministrativeVisit(), arguments: {
                  'id_user': controller.dataArg?['id_user'],
                  'id_center': controller.dataArg?['id_center'],
                  'id_circle': controller.selectedIdCirle.value,
                  'id_year': controller.selectedIdYears.value,
                  'id_month': controller.selectedIdMonths.value,
                });
              } else {
                // للزيارات الأخرى، استخدم الطريقة العادية
                controller.insert_visits();
              }
            },),

            SizedBox(height: 10,),

            Divider(height: 3,thickness: 3,),
            SizedBox(height: 10,),
            
            // عنوان وفلاتر الزيارات السابقة
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("الزيارات السابقة", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                PopupMenuButton<String>(
                  icon: Icon(Icons.filter_list, color: primaryGreen),
                  onSelected: (value) {
                    switch (value) {
                      case 'current_year':
                        controller.applyCurrentYearFilter();
                        break;
                      case 'all':
                        controller.resetFilters();
                        break;
                      case 'custom':
                        _showFilterDialog(context);
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem<String>(
                      value: 'current_year',
                      child: Row(
                        children: [
                          Icon(Icons.today, size: 20),
                          SizedBox(width: 8),
                          Text('السنة الحالية'),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'all',
                      child: Row(
                        children: [
                          Icon(Icons.all_inclusive, size: 20),
                          SizedBox(width: 8),
                          Text('جميع السنوات'),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'custom',
                      child: Row(
                        children: [
                          Icon(Icons.tune, size: 20),
                          SizedBox(width: 8),
                          Text('فلترة مخصصة'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            // عرض الفلاتر المطبقة
            Obx(() {
              if (controller.selectedFilterYear.value != 0 || controller.selectedFilterMonth.value != 0) {
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: primaryGreen.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.filter_alt, color: primaryGreen, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _getFilterText(),
                          style: TextStyle(color: primaryGreen, fontWeight: FontWeight.w500),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.clear, color: primaryGreen, size: 20),
                        onPressed: () => controller.resetFilters(),
                        tooltip: "إلغاء الفلترة",
                      ),
                    ],
                  ),
                );
              }
              return SizedBox.shrink();
            }),
            Obx(() {
              return controller.previous_visits.isNotEmpty
                  ? Column(
                children: controller.previous_visits.map((element) {
                  return VisitCard(
                    visitData: element,
                    onEdit: () {
                      Map data={
                        "id_visit":element["id_visit"],
                        "id_circle":element["id_circle"]
                      };
                      Get.to(()=>StudentsListUpdate(),arguments: data);
                    },
                    onDelete: () {
                      // controller.deleteVisit(element["id_visit"]);
                    },
                  );
                }).toList(),
              )
                  : const Center(
                child: Text(
                  "لا يوجد زيارات سابقة",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }),

          ],
        ),
      ),
    );
  }

  // دالة لعرض نص الفلتر المطبق
  String _getFilterText() {
    String filterText = "مفلتر حسب: ";
    
    if (controller.selectedFilterYear.value != 0) {
      var yearData = controller.years.firstWhereOrNull((year) => 
        year["id_year"] == controller.selectedFilterYear.value);
      if (yearData != null) {
        filterText += "السنة: ${yearData["name_year"]}";
      }
    }
    
    if (controller.selectedFilterMonth.value != 0) {
      var monthData = controller.months.firstWhereOrNull((month) => 
        month["id_month"] == controller.selectedFilterMonth.value);
      if (monthData != null) {
        if (controller.selectedFilterYear.value != 0) {
          filterText += " - ";
        }
        filterText += "الشهر: ${monthData["month_name"]}";
      }
    }
    
    return filterText;
  }

  // دالة لعرض نافذة الفلترة المخصصة
  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.tune, color: primaryGreen),
              SizedBox(width: 8),
              Text("فلترة الزيارات"),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // فلتر السنة
              Obx(() {
                final items = controller.years.toList();
                return CustomDropdownField(
                  label: "اختر السنة",
                  items: items,
                  value: controller.selectedFilterYear.value,
                  valueKey: "id_year",
                  displayKey: "name_year",
                  onChanged: (val) {
                    controller.selectedFilterYear.value = val ?? 0;
                    controller.filterPreviousVisits();
                  },
                  icon: Icons.date_range,
                );
              }),
              SizedBox(height: 16),
              // فلتر الشهر
              Obx(() {
                final items = controller.months.toList();
                return CustomDropdownField(
                  label: "اختر الشهر",
                  items: items,
                  value: controller.selectedFilterMonth.value,
                  valueKey: "id_month",
                  displayKey: "month_name",
                  onChanged: (val) {
                    controller.selectedFilterMonth.value = val ?? 0;
                    controller.filterPreviousVisits();
                  },
                  icon: Icons.calendar_month,
                );
              }),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                controller.resetFilters();
                Navigator.of(context).pop();
              },
              child: Text("إعادة تعيين", style: TextStyle(color: Colors.grey[600])),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("إلغاء", style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () {
                controller.filterPreviousVisits();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(backgroundColor: primaryGreen),
              child: Text("تطبيق الفلتر", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}


class VisitCard extends StatelessWidget {
  final Map<String, dynamic> visitData;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const VisitCard({
    Key? key,
    required this.visitData,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  Color _getStatusColor(dynamic status) {
    if (status is! int) return Colors.grey;
    switch (status) {
      case 0:
        return Colors.orangeAccent; // لم تبدأ
      case 1:
        return Colors.orangeAccent; // غير مكتملة
      case 2:
        return Colors.green; // مكتملة
      default:
        return Colors.grey; // غير فنية
    }
  }

  String _getStatusText(dynamic status) {
    if (status is! int) return "ادارية";
    switch (status) {
      case 0:
        return "غير مكتملة";
      case 1:
        return "غير مكتملة";
      case 2:
        return "مكتملة";
      default:
        return "ادارية";
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = visitData["visit_status"];

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // الجانب الأيسر (البيانات)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "${visitData["name_circle"]}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                      ),
                      // شارة الحالة
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 10),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getStatusText(status),
                          style: TextStyle(
                            color: _getStatusColor(status),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text("نوع الزيارة: ${visitData["name_visit_type"]}",
                      style: const TextStyle(fontSize: 15)),
                  Text("السنة: ${visitData["name_year"]}",
                      style: const TextStyle(fontSize: 15)),
                  Text("الشهر: ${visitData["month_name"]}",
                      style: const TextStyle(fontSize: 15)),
                  Text("التاريخ: ${visitData["date"]}",
                      style: const TextStyle(fontSize: 15)),
                  if (visitData["notes"] != null &&
                      visitData["notes"].toString().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(
                        "ملاحظات: ${visitData["notes"]}",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // أزرار التحكم
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.teal),
                  onPressed: onEdit,
                  tooltip: "تعديل الزيارة",
                ),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: onDelete,
                    tooltip: "حذف الزيارة",
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
