import 'package:althfeth/constants/appButton.dart';
import 'package:althfeth/constants/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/CustomDropdownField.dart';
import '../../constants/myreport.dart';
import '../../controller/Add_VisitController.dart';
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
            AppButton(text: "اضافة الزيارة", onPressed: () {
              controller.insert_visits();

            },),
            SizedBox(height: 10,),
            AppButton(text: "تقرير الزيارات السابقة  ", onPressed: ()async {
              controller.showReport();
            },)

          ],
        ),
      ),
    );
  }
}

