import 'package:althfeth/constants/appButton.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/CustomDropdownField.dart';
import '../../../constants/color.dart';
import '../../../constants/customTextField.dart';
import '../../../constants/loadingWidget.dart';
import '../../../controller/studentControllers/addstudentController.dart';
import '../../../constants/function.dart';
import '../../../controller/studentControllers/update_StudentController.dart';

class UpdateStudent extends StatelessWidget {
  Update_StudentController update_studentController = Get.put(Update_StudentController());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("تعديل بيانات طالب"),
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
                    controller: update_studentController.name_student,
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
                                controller: update_studentController.guardian,
                                label: "رقم ولي الامر",
                                hint: "رقم ولي الامر",
                              ))),
                      Expanded(
                          child: Padding(
                              padding: const EdgeInsets.only(right: 5),
                              child: CustomTextField(
                                controller: update_studentController.surname,
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
                                controller: update_studentController.age_student,
                                label: "عمر الطالب",
                                hint: "العمر",
                                keyboardType: TextInputType.number,
                              ))),
                      Expanded(
                          child: Padding(
                              padding: const EdgeInsets.only(right: 5),
                              child: CustomTextField(
                                controller:
                                update_studentController.address_student,
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
                                controller: update_studentController.date_of_birth,
                                label: "تاريخ الميلاد",
                                hint: "التاريخ",
                              ))),
                      Expanded(
                          child: Padding(
                              padding: const EdgeInsets.only(right: 5),
                              child: CustomTextField(
                                controller: update_studentController.place_of_birth,
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
                                controller: update_studentController.school_name,
                                label: "اسم المدرسة",
                                hint: "المدرسة",
                              ))),
                      Expanded(
                          child: Padding(
                              padding: const EdgeInsets.only(right: 5),
                              child: CustomTextField(
                                controller: update_studentController.classroom,
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
                              controller: update_studentController.jop,
                              label: "الوظيفة",
                              hint: "الوظيفة",
                            ),
                          )),
                      Expanded(
                          child: Padding(
                              padding: const EdgeInsets.only(right: 5),
                              child: CustomTextField(
                                controller: update_studentController.phone,
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
                              controller: update_studentController.chronic_diseases,
                              label: "مرض مزمن",
                              hint: "مرض مزمن",
                            ),
                          )),
                      Expanded(
                          child: Padding(
                              padding: const EdgeInsets.only(right: 5),
                              child: CustomTextField(
                                controller: update_studentController.password,
                                label: "كلمة السر ",
                                hint: "كلمة السر",
                              ))),
                    ],
                  ),
               SizedBox(height: 15,),
               Obx(() =>
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
                            value: update_studentController.selectedGender.value,
                            items: update_studentController.genders.map((gender) {
                              return DropdownMenuItem<String>(
                                value: gender,
                                child: Text(gender),
                              );
                            }).toList(),
                            onChanged: (value) {
                              update_studentController.selectedGender.value = value;
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
                            value: update_studentController
                                .qualification_selected.value,
                            items: update_studentController.qualification
                                .map((gender) {
                              return DropdownMenuItem<String>(
                                value: gender,
                                child: Text(gender),
                              );
                            }).toList(),
                            onChanged: (value) {
                              update_studentController
                                  .qualification_selected.value = value;
                            },
                          ),
                        ),
                      )
                    ],
                  ),
               ),
                 SizedBox(height: 15),

                  Obx(() =>
                  CustomDropdownField(
                    label: "اختر القارئ",
                    items:update_studentController.reder,
                    value:update_studentController.selectedReaderId?.value == 0 ? null :update_studentController.selectedReaderId?.value,
                    valueKey: "id_reder",
                    displayKey: "name_reder",
                    onChanged: (val) {
                      update_studentController.selectedReaderId?.value = val;
                      print("تم اختيار القارئ رقم: ${update_studentController.selectedReaderId?.value}");
                    },
                    icon: Icons.person,
                    fillColor: Colors.teal.shade50,
                    // )
                  )),
                  SizedBox(height: 15),
                AppButton(text: "حفظ التعديلات", onPressed: (){
                  update_studentController.update_Student();
                }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
