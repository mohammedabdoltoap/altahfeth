import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/color.dart';
import '../../constants/loadingWidget.dart';
import '../../controller/addstudentController.dart';
import '../../constants/function.dart';


class Addstudent extends StatelessWidget {
  AddstudentController addStudentController = Get.put(AddstudentController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("إضافة طالب"),
        backgroundColor: primaryGreen,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Stack(
          children: [
            ListView(
              children: [
                // اسم الطالب
                TextField(
                  controller: addStudentController.name_student,
                  decoration: InputDecoration(
                    labelText: 'اسم الطالب',
                    hintText: "ادخل اسم الطالب",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                SizedBox(height: 15),

                // العمر + السكن
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 5),
                      child: TextField(
                          controller: addStudentController.age_student,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'العمر',
                            hintText: "ادخل العمر",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: TextField(
                          controller: addStudentController.address_student,
                          decoration: InputDecoration(
                            labelText: 'السكن',
                            hintText: "ادخل مكان السكن",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(Icons.home),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),

                // المرحلة + المستوى
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child:

                        Obx(() => DropdownButtonFormField<int>(
                          decoration: InputDecoration(
                            labelText: "المرحلة",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          value: addStudentController.selectedStageId!.value == 0
                              ? null
                              : addStudentController.selectedStageId!.value,
                          items: addStudentController.stages.map((stage) {
                            return DropdownMenuItem<int>(
                              value: stage["id"] as int,
                              child: Text(stage["name"] as String),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              addStudentController.selectedStageId!.value = val;
                              addStudentController.filterLevels(val); // فلترة المستويات
                            }
                          },
                        ))

                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child:

                        Obx(() => InkWell(
                          onTap: (){
                            if (addStudentController.selectedStageId?.value == 0) {
                              // هنا تطلع رسالة
                              mySnackbar("تنبيه", "اختر المرحلة أولًا",type: "y");
                            }
                          },
                          child: DropdownButtonFormField<int>(
                            decoration: InputDecoration(
                              labelText: "المستوى",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            value: addStudentController.selectedLevelId!.value == 0
                                ? null
                                : addStudentController.selectedLevelId!.value,
                            items: addStudentController.levels.map((level) {
                              return DropdownMenuItem<int>(
                                value: level["id"] as int,
                                child: Text(level["name"] as String),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                addStudentController.selectedLevelId!.value = val;
                              }else{
                              }
                            },
                          ),
                        )
                        )

                      ),
                    ),
                  ],
                ),
                SizedBox(height: 25),

                // زر الحفظ
                ElevatedButton.icon(
                  onPressed: () {
                    addStudentController.addStudent();
                  },
                  icon: Icon(Icons.save),
                  label: Text("حفظ البيانات"),
                  style: ElevatedButton.styleFrom(
                    // primary: primaryGreen,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    textStyle:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),

            // 🔄 مؤشر التحميل
            Obx(() => addStudentController.isLoading_addStudent.value ?
                LoadingWidget(isLoading:addStudentController.isLoading_addStudent,message: "جاري الحفظ ",)
                  : SizedBox.shrink(),
            )

          ],
        ),
      ),
    );
  }
}
