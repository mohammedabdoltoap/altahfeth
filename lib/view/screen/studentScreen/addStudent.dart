import 'package:althfeth/constants/appButton.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/CustomDropdownField.dart';
import '../../../constants/color.dart';
import '../../../constants/customTextField.dart';
import '../../../constants/loadingWidget.dart';
import '../../../controller/studentControllers/addstudentController.dart';
import '../../../constants/function.dart';

class Addstudent extends StatelessWidget {
  AddstudentController addStudentController = Get.put(AddstudentController());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
                  SizedBox(
                    height: 10,
                  ),
                  CustomTextField(
                    controller: addStudentController.name_student,
                    label: "اسم الطالب",
                    hint: "الاسم",
                  ),
                  SizedBox(height: 15),

                  //لقب وولي الامر
                  Row(
                    children: [
                      Expanded(
                          child: Padding(
                              padding: const EdgeInsets.only(right: 5),
                              child: CustomTextField(
                                controller: addStudentController.guardian,
                                label: "رقم ولي الامر",
                                hint: "رقم ولي الامر",
                              ))),
                      Expanded(
                          child: Padding(
                              padding: const EdgeInsets.only(right: 5),
                              child: CustomTextField(
                                controller: addStudentController.surname,
                                label: "لقب الطالب",
                                hint: "اللقب",
                              ))),
                    ],
                  ),
                  SizedBox(height: 15),

                  Row(
                    children: [
                      Expanded(
                          child: Padding(
                              padding: const EdgeInsets.only(right: 5),
                              child: CustomTextField(
                                controller: addStudentController.age_student,
                                label: "عمر الطالب",
                                hint: "العمر",
                                keyboardType: TextInputType.number,
                              ))),
                      Expanded(
                          child: Padding(
                              padding: const EdgeInsets.only(right: 5),
                              child: CustomTextField(
                                controller:
                                    addStudentController.address_student,
                                label: "السكن ",
                                hint: "العنوان",
                              ))),
                    ],
                  ),
                  SizedBox(height: 15),

                  Row(
                    children: [
                      Expanded(
                          child: Padding(
                              padding: const EdgeInsets.only(right: 5),
                              child: CustomTextField(
                                controller: addStudentController.date_of_birth,
                                label: "تاريخ الميلاد",
                                hint: "التاريخ",
                              ))),
                      Expanded(
                          child: Padding(
                              padding: const EdgeInsets.only(right: 5),
                              child: CustomTextField(
                                controller: addStudentController.place_of_birth,
                                label: "مكان الميلاد  ",
                                hint: "مكان الميلاد",
                              ))),
                    ],
                  ),
                  SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                          child: Padding(
                              padding: const EdgeInsets.only(right: 5),
                              child: CustomTextField(
                                controller: addStudentController.school_name,
                                label: "اسم المدرسة",
                                hint: "المدرسة",
                              ))),
                      Expanded(
                          child: Padding(
                              padding: const EdgeInsets.only(right: 5),
                              child: CustomTextField(
                                controller: addStudentController.classroom,
                                label: "الصف ",
                                hint: "الصفد",
                              ))),
                    ],
                  ),
                  SizedBox(height: 15),

                  Row(
                    children: [
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: CustomTextField(
                          controller: addStudentController.jop,
                          label: "الوظيفة",
                          hint: "الوظيفة",
                        ),
                      )),
                      Expanded(
                          child: Padding(
                              padding: const EdgeInsets.only(right: 5),
                              child: CustomTextField(
                                controller: addStudentController.phone,
                                label: "رقم الهاتف ",
                                hint: "الهاتف",
                                keyboardType: TextInputType.phone,
                              ))),
                    ],
                  ),
                  SizedBox(height: 15),

                  Row(
                    children: [
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: CustomTextField(
                          controller: addStudentController.chronic_diseases,
                          label: "مرض مزمن",
                          hint: "مرض مزمن",
                        ),
                      )),
                      Expanded(
                          child: Padding(
                              padding: const EdgeInsets.only(right: 5),
                              child: CustomTextField(
                                controller: addStudentController.password,
                                label: "كلمة السر ",
                                hint: "كلمة السر",
                              ))),
                    ],
                  ),
                  SizedBox(height: 15),

                  // المرحلة + المستوى
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: Obx(() => DropdownButtonFormField<int>(
                                  decoration: InputDecoration(
                                    labelText: "المرحلة",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  value: addStudentController
                                              .selectedStageId!.value ==
                                          0
                                      ? null
                                      : addStudentController
                                          .selectedStageId!.value,
                                  items:
                                      addStudentController.stages.map((stage) {
                                    return DropdownMenuItem<int>(
                                      value: stage["id"] as int,
                                      child: Text(stage["name"] as String),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      addStudentController
                                          .selectedStageId!.value = val;
                                      addStudentController
                                          .filterLevels(val); // فلترة المستويات
                                    }
                                  },
                                ))),
                      ),
                      Expanded(
                        child: Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: Obx(() => InkWell(
                                  onTap: () {
                                    if (addStudentController.selectedStageId?.value ==
                                        0) {
                                      // هنا تطلع رسالة
                                      mySnackbar("تنبيه", "اختر المرحلة أولًا",
                                          type: "y");
                                    }
                                  },
                                  child: DropdownButtonFormField<int>(
                                    decoration: InputDecoration(
                                      labelText: "المستوى",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    value: addStudentController
                                                .selectedLevelId!.value ==
                                            0
                                        ? null
                                        : addStudentController
                                            .selectedLevelId!.value,
                                    items: addStudentController.levels
                                        .map((level) {
                                      return DropdownMenuItem<int>(
                                        value: level["id"] as int,
                                        child: Text(level["name"] as String),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        addStudentController
                                            .selectedLevelId!.value = val;
                                      } else {}
                                    },
                                  ),
                                ))),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  //الجنس و الموهل
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'اختر الجنس',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                            value: addStudentController.selectedGender.value,
                            items: addStudentController.genders.map((gender) {
                              return DropdownMenuItem<String>(
                                value: gender,
                                child: Text(gender),
                              );
                            }).toList(),
                            onChanged: (value) {
                              addStudentController.selectedGender.value = value;
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'الرجاء اختيار الجنس';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'الموهل القراني',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                            value: addStudentController
                                .qualification_selected.value,
                            items: addStudentController.qualification
                                .map((gender) {
                              return DropdownMenuItem<String>(
                                value: gender,
                                child: Text(gender),
                              );
                            }).toList(),
                            onChanged: (value) {
                              addStudentController
                                  .qualification_selected.value = value;
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 15),

                  CustomDropdownField(
                    label: "اختر القارئ",
                    items:addStudentController.reder,
                    value:addStudentController.selectedReaderId?.value == 0 ? null :addStudentController.selectedReaderId?.value,
                    valueKey: "id_reder",
                    displayKey: "name_reder",
                    onChanged: (val) {
                      addStudentController.selectedReaderId?.value = val;
                      print("تم اختيار القارئ رقم: ${addStudentController.selectedReaderId?.value}");
                    },
                    icon: Icons.person,
                    fillColor: Colors.teal.shade50,
                  // )
        ),

                  SizedBox(height: 15),

                  // زر الحفظ
                  AppButton(
                      text: "تقديم طلب الاضافة",
                      onPressed: () {
                        addStudentController.addStudent();
                      }),

                  SizedBox(height: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
