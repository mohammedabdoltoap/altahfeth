import 'package:althfeth/constants/appButton.dart';
import 'package:althfeth/constants/color.dart';
import 'package:althfeth/constants/customTextField.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../constants/CustomDropdownField.dart';
import '../../../../controller/visitAndExamController/Add_VisitController.dart';
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

            CustomDropdownField(
              label: "الحلقه",
              items:controller.circles,
              value:controller.selectedIdCirle?.value == 0 ? null :controller.selectedIdCirle?.value,
              valueKey: "id_circle",
              displayKey: "name_circle",
              onChanged: (val) {
                controller.selectedIdCirle?.value=val;
                print("تم اختيار الحلقه رقم: ${controller.selectedIdCirle?.value}");
              },
              fillColor: Colors.teal.shade100,
            ),
            CustomDropdownField(
              label: "نوع الزيارة",
              items:controller.visits_type,
              value:controller.selectedIdVisitsType?.value == 0 ? null :controller.selectedIdVisitsType?.value,
              valueKey: "id_visit_type",
              displayKey: "name_visit_type",
              onChanged: (val) {
                controller.selectedIdVisitsType?.value=val;
                print("تم اختيار السنه رقم: ${controller.selectedIdVisitsType?.value}");
              },
              fillColor: Colors.teal.shade100,
            ),
            CustomDropdownField(
              label: "اختر السنة",
              items:controller.years,
              value:controller.selectedIdYears?.value == 0 ? null :controller.selectedIdYears?.value,
              valueKey: "id_year",
              displayKey: "name_year",
              onChanged: (val) {
                controller.selectedIdYears?.value=val;
                print("تم اختيار السنه رقم: ${controller.selectedIdYears?.value}");

                },
              icon: Icons.date_range,
              fillColor: Colors.teal.shade100,
              // )
            ),

            CustomDropdownField(
              label: "اختر الشهر",
              items:controller.months,
              value:controller.selectedIdMonths?.value == 0 ? null :controller.selectedIdMonths?.value,
              valueKey: "id_month",
              displayKey: "month_name",
              onChanged: (val) {
                controller.selectedIdMonths?.value=val;
                print("تم اختيار السنه رقم: ${controller.selectedIdMonths?.value}");
              },
              icon: Icons.date_range,
              fillColor: Colors.teal.shade100,

              // )
            ),
            CustomTextField(controller: controller.notes, label: "ملاحظات", hint: "ملاحظة ان وجد"),


            AppButton(text: "اضافة الزيارة", onPressed: () {
              controller.insert_visits();

            },),

            SizedBox(height: 10,),

            Divider(height: 3,thickness: 3,),
            SizedBox(height: 10,),
         Text("الزيارات السابقة ",style: TextStyle(fontSize:18,fontWeight: FontWeight.bold ),),
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
