import 'package:althfeth/constants/appButton.dart';
import 'package:althfeth/constants/color.dart';
import 'package:althfeth/constants/app_theme.dart';
import 'package:althfeth/widgets/custom_widgets.dart';
import 'package:althfeth/constants/customTextField.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../constants/CustomDropdownField.dart';
import '../../../../constants/function.dart';
import '../../../../controller/visitAndExamController/Add_VisitController.dart';
import '../AddAdministrativeVisit.dart';
import 'StudentsListUpdate.dart';
class Add_Visit extends StatelessWidget {
  Add_VisitController controller =Get.put(Add_VisitController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: "إدارة الزيارات",
      ),
      body: CustomPageContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // قسم إضافة زيارة جديدة
            CustomSectionHeader(
              title: "إضافة زيارة جديدة",
              icon: Icons.add_task_outlined,
              color: AppTheme.visitSectionColor,
              subtitle: "إنشاء زيارة فنية أو إدارية جديدة",
            ),
            const SizedBox(height: AppTheme.spacingLarge),
            
            // نموذج إضافة الزيارة
            _buildAddVisitForm(),
            
            const SizedBox(height: AppTheme.spacingXXLarge),
            
            // قسم الزيارات السابقة
            CustomSectionHeader(
              title: "الزيارات السابقة",
              icon: Icons.history_outlined,
              color: AppTheme.teacherSectionColor,
              subtitle: "عرض وإدارة الزيارات المسجلة",
              trailing: _buildFilterButton(),
            ),
            const SizedBox(height: AppTheme.spacingLarge),
            
            // عرض الفلاتر المطبقة
            _buildAppliedFilters(),
            
            // قائمة الزيارات السابقة
            _buildPreviousVisitsList(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAddVisitForm() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(
          color: AppTheme.visitSectionColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [

          Obx(() {
            final items = controller.circles.toList();
            return CustomDropdownField(
              label: "الحلقة",
              items: items,
              value: controller.selectedIdCirle.value,
              valueKey: "id_circle",
              displayKey: "name_circle",
              onChanged: (val) {
                controller.selectedIdCirle.value = val ?? 0;
              },
            );
          }),
          const SizedBox(height: AppTheme.spacingMedium),
          
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
          const SizedBox(height: AppTheme.spacingMedium),
          
          Row(
            children: [
              Expanded(
                child: Obx(() {
                  final items = controller.years.toList();
                  return CustomDropdownField(
                    label: "السنة",
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
              ),
              const SizedBox(width: AppTheme.spacingMedium),
              Expanded(
                child: Obx(() {
                  final items = controller.months.toList();
                  return CustomDropdownField(
                    label: "الشهر",
                    items: items,
                    value: controller.selectedIdMonths.value,
                    valueKey: "id_month",
                    displayKey: "month_name",
                    onChanged: (val) {
                      controller.selectedIdMonths.value = val ?? 0;
                    },
                    icon: Icons.calendar_month,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          
          CustomTextField(
            controller: controller.notes, 
            label: "ملاحظات", 
            hint: "ملاحظة إن وجدت"
          ),
          const SizedBox(height: AppTheme.spacingLarge),
          
          SizedBox(
            width: double.infinity,
            child: AppButton(
              text: "إضافة الزيارة", 
              onPressed: () {
                if (controller.selectedIdVisitsType.value == 2) {
                  if (controller.selectedIdCirle.value == 0) {
                    Get.snackbar("تنبيه", "الرجاء اختيار الحلقة أولاً");
                    return;
                  }
                  if(controller.selectedIdMonths?.value==0) {
                    mySnackbar("تنبيه","يرجى تحديد الشهر" );
                    return;
                  }
                  if(controller.selectedIdYears?.value==0) {
                    mySnackbar("تنبيه","يرجى تحديد السنة" );
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
                  controller.insert_visits();
                }
              }
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFilterButton() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      ),
      child: PopupMenuButton<String>(
        icon: Icon(Icons.filter_list, color: AppTheme.primaryColor),
        onSelected: (value) {
          switch (value) {
            case 'current_year':
              controller.applyCurrentYearFilter();
              break;
            case 'all':
              controller.resetFilters();
              break;
            case 'custom':
              _showFilterDialog(Get.context!);
              break;
          }
        },
        itemBuilder: (BuildContext context) => [
          const PopupMenuItem<String>(
            value: 'current_year',
            child: Row(
              children: [
                Icon(Icons.today, size: 20),
                SizedBox(width: 8),
                Text('السنة الحالية'),
              ],
            ),
          ),
          const PopupMenuItem<String>(
            value: 'all',
            child: Row(
              children: [
                Icon(Icons.all_inclusive, size: 20),
                SizedBox(width: 8),
                Text('جميع السنوات'),
              ],
            ),
          ),
          const PopupMenuItem<String>(
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
    );
  }
  
  Widget _buildAppliedFilters() {
    return Obx(() {
      if (controller.selectedFilterYear.value != 0 || controller.selectedFilterMonth.value != 0) {
        return Container(
          margin: const EdgeInsets.only(bottom: AppTheme.spacingLarge),
          padding: const EdgeInsets.all(AppTheme.spacingMedium),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(
              color: AppTheme.primaryColor.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.filter_alt, 
                color: AppTheme.primaryColor, 
                size: 20
              ),
              const SizedBox(width: AppTheme.spacingSmall),
              Expanded(
                child: Text(
                  _getFilterText(),
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.clear, 
                  color: AppTheme.primaryColor, 
                  size: 20
                ),
                onPressed: () => controller.resetFilters(),
                tooltip: "إلغاء الفلترة",
              ),
            ],
          ),
        );
      }
      return const SizedBox.shrink();
    });
  }
  
  Widget _buildPreviousVisitsList() {
    return Obx(() {
      return controller.previous_visits.isNotEmpty
          ? Column(
              children: controller.previous_visits.map((element) {
                return VisitCard(
                  visitData: element,
                  onEdit: () {
                    Map data = {
                      "id_visit": element["id_visit"],
                      "id_circle": element["id_circle"]
                    };
                    Get.to(() => StudentsListUpdate(), arguments: data);
                  },
                  onDelete: () {
                    // controller.deleteVisit(element["id_visit"]);
                  },
                );
              }).toList(),
            )
          : Center(
              child: Container(
                padding: const EdgeInsets.all(AppTheme.spacingXLarge),
                child: Column(
                  children: [
                    Icon(
                      Icons.assignment_outlined,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: AppTheme.spacingMedium),
                    Text(
                      "لا يوجد زيارات سابقة",
                      style: AppTheme.bodyLarge.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            );
    });
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingSmall),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Icon(
                  Icons.tune, 
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppTheme.spacingSmall),
              Text(
                "فلترة الزيارات",
                style: AppTheme.headingSmall,
              ),
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
              const SizedBox(height: AppTheme.spacingLarge),
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
              child: Text(
                "إعادة تعيين", 
                style: AppTheme.bodyMedium.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "إلغاء", 
                style: AppTheme.bodyMedium.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                controller.filterPreviousVisits();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
              ),
              child: Text(
                "تطبيق الفلتر", 
                style: AppTheme.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
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
    if (status is! int) return AppTheme.reportColors[3];
    switch (status) {
      case 0:
        return AppTheme.reportColors[2]; // لم تبدأ
      case 1:
        return AppTheme.reportColors[4]; // غير مكتملة
      case 2:
        return AppTheme.reportColors[0]; // مكتملة
      default:
        return AppTheme.reportColors[3]; // غير فنية
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

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
          color: _getStatusColor(visitData["visit_status"]).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // العنوان وشارة الحالة
            Row(
              children: [
                Expanded(
                  child: Text(
                    "${visitData["name_circle"]}",
                    style: AppTheme.headingSmall.copyWith(
                      color: AppTheme.primaryColor,
                      fontSize: 17,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppTheme.spacingXSmall,
                    horizontal: AppTheme.spacingSmall,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: Text(
                    _getStatusText(status),
                    style: AppTheme.bodySmall.copyWith(
                      color: _getStatusColor(status),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingSmall),
            
            // معلومات الزيارة في صفين
            Row(
              children: [
                Expanded(
                  child: _buildCompactInfo(Icons.category_outlined, "النوع", visitData["name_visit_type"]),
                ),
                const SizedBox(width: AppTheme.spacingSmall),
                Expanded(
                  child: _buildCompactInfo(Icons.calendar_today_outlined, "السنة", visitData["name_year"]),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingXSmall),
            Row(
              children: [
                Expanded(
                  child: _buildCompactInfo(Icons.date_range_outlined, "الشهر", visitData["month_name"]),
                ),
                const SizedBox(width: AppTheme.spacingSmall),
                Expanded(
                  child: _buildCompactInfo(Icons.access_time_outlined, "التاريخ", visitData["date"]),
                ),
              ],
            ),
            
            if (visitData["notes"] != null && visitData["notes"].toString().isNotEmpty) ...[
              const SizedBox(height: AppTheme.spacingXSmall),
              _buildCompactInfo(Icons.note_outlined, "ملاحظات", visitData["notes"], isNote: true),
            ],
            
            const SizedBox(height: AppTheme.spacingSmall),
            
            // زر التعديل
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    onTap: onEdit,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingSmall,
                        vertical: AppTheme.spacingXSmall,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.edit_outlined, 
                            color: AppTheme.primaryColor,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "تعديل",
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCompactInfo(IconData icon, String label, String value, {bool isNote = false}) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingSmall),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 12,
            color: AppTheme.primaryColor.withOpacity(0.7),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTheme.bodySmall.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor.withOpacity(0.8),
                  ),
                ),
                Text(
                  value,
                  style: AppTheme.bodySmall.copyWith(
                    fontSize: 13,
                    fontStyle: isNote ? FontStyle.italic : FontStyle.normal,
                    color: isNote ? Colors.grey.shade700 : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: isNote ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
