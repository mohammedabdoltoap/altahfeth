import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/appButton.dart';
import '../../controller/UpdateAttendanceController.dart';
class UpdateAttendance extends StatelessWidget {
  UpdateAttendanceController controller=Get.put(UpdateAttendanceController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("تعديل تحضير الطلاب"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child:
        Obx(() {
          if(controller.students.isNotEmpty)
            return
              Column(
                children: [
                  TextField(
                    onChanged: controller.filterStudents,
                    decoration: InputDecoration(
                      hintText: "ابحث عن الطالب...",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount:controller.filteredStudents.length,
                      itemBuilder: (context, index) {
                        var student =controller.filteredStudents[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 6),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      student["name_student"],
                                      style: TextStyle(
                                          fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    Switch(
                                      value: student["status"],
                                      activeColor: Colors.teal,
                                      onChanged: (val) {

                                        student["status"] = val;
                                        if (val) student["notes"] = "";

                                        controller.filteredStudents.refresh();
                                      },
                                    ),
                                  ],
                                ),
                                if (!student["status"])
                                  TextFormField(
                                    initialValue: student["notes"],
                                    onChanged: (val) {
                                      student["notes"] = val;
                                      controller.filteredStudents.refresh();
                                    },
                                    decoration: InputDecoration(
                                      labelText: "سبب الغياب",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 12),
                  AppButton(text: "تعديل التحضير", onPressed: (){
                    controller.updateAttendance();
                  })
                ],
              );
          else{
            return Center(child: Text("لايوجد طلاب"),);
          }
        },),
      ),
    );
  }

}


