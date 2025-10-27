import 'package:althfeth/constants/appButton.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/CustomDropdownField.dart';
import '../../../constants/customTextField.dart';
import '../../../constants/inline_loading.dart';
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
          centerTitle: true,
          toolbarHeight: 88,
          title: Text("تعديل بيانات طالب"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child:

        Obx(() {
          if(update_studentController.isLodeReder.value && update_studentController.reder.isEmpty)
            return InlineLoading( message: "تحميل القارى ",indicatorSize: 40,);

          if(update_studentController.reder.isEmpty)
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "لم يتم جلب البيانات بسبب الاتصال ",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 220,
                    child: ElevatedButton(
                      onPressed: () {
                        update_studentController.select_reders();

                      },
                      child: const Text("إعادة المحاولة"),
                    ),
                  ),
                ],
              ),
            );


          return   Stack(
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
                                keyboardType: TextInputType.phone,
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
                                controller:
                                update_studentController.address_student,
                                label: "السكن ",
                                hint: "العنوان",
                              )
                          )
                      ),
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
                                readOnly: true,
                                suffixIcon: Icons.calendar_today,
                                onTap: () async {
                                  final now = DateTime.now();
                                  final initial = DateTime(now.year - 10, now.month, now.day);
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: initial,
                                    firstDate: DateTime(1950),
                                    lastDate: now,
                                  );
                                  if (picked != null) {
                                    final dateStr = "${picked.year.toString().padLeft(4,'0')}-${picked.month.toString().padLeft(2,'0')}-${picked.day.toString().padLeft(2,'0')}";
                                    update_studentController.date_of_birth.text = dateStr;
                                  }
                                },
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
                                decoration: const InputDecoration(
                                  labelText: 'اختر الجنس',
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
                                decoration: const InputDecoration(
                                  labelText: 'الموهل القراني',
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

                  Obx(() {
                    final items = update_studentController.reder.toList();
                    return CustomDropdownField(
                      label: "اختر القارئ",
                      items: items,
                      value: update_studentController.selectedReaderId?.value,
                      valueKey: "id_reder",
                      displayKey: "name_reder",
                      onChanged: (val) {
                        update_studentController.selectedReaderId?.value = val ?? 0;
                      },
                      icon: Icons.person,
                    );
                  }),
                  SizedBox(height: 15),
                  AppButton(text: "حفظ التعديلات", onPressed: (){
                    update_studentController.update_Student();
                  }),
                ],
              ),
            ],
          );

        },)


        ),
      ),
    );
  }
}
