import 'package:althfeth/constants/appButton.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/CustomDropdownField.dart';
import '../../../constants/customTextField.dart';
import '../../../constants/inline_loading.dart';
import '../../../controller/studentControllers/addstudentController.dart';
import '../../../constants/function.dart';

class Addstudent extends StatelessWidget {
  AddstudentController addStudentController = Get.put(AddstudentController());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          toolbarHeight: 88,
          title: Text("إضافة طالب"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child:
          Obx(() {

            if(addStudentController.stages.isEmpty && !addStudentController.isLodingLevel.value)
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
                            addStudentController.select_level();
                            addStudentController.select_reders();

                          },
                          child: const Text("إعادة المحاولة"),
                        ),
                      ),
                    ],
                  ),
                );


            return Stack(
                children: [
                  Form(
                    key: addStudentController.formKey,
                    child: ListView(
                    children: [
                      // اسم الطالب
                      SizedBox(
                        height: 10,
                      ),
                      CustomTextField(
                        controller: addStudentController.name_student,
                        label: "اسم الطالب",
                        hint: "الاسم",
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'يرجى إدخال اسم الطالب';
                          }
                          if (value.length < 9) {
                            return 'يرجى إدخال الاسم الرباعي';
                          }
                          return null;
                        },
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
                                    keyboardType: TextInputType.phone,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'يرجى إدخال رقم ولي الأمر';
                                      }
                                      return null;
                                    },
                                  ))),
                          Expanded(
                              child: Padding(
                                  padding: const EdgeInsets.only(right: 5),
                                  child: CustomTextField(
                                    controller: addStudentController.surname,
                                    label: "لقب الطالب",
                                    hint: "اللقب",
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'يرجى إدخال لقب الطالب';
                                      }
                                      return null;
                                    },
                                  ))),
                        ],
                      ),
                      SizedBox(height: 15),

                      CustomTextField(
                        controller: addStudentController.address_student,
                        label: "السكن",
                        hint: "العنوان",
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'يرجى إدخال العنوان';
                          }
                          return null;
                        },
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
                                    readOnly: true,
                                    suffixIcon: Icons.calendar_today,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'يرجى اختيار تاريخ الميلاد';
                                      }
                                      return null;
                                    },
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
                                        addStudentController.date_of_birth.text = dateStr;
                                      }
                                    },
                                  ))),
                          Expanded(
                              child: Padding(
                                  padding: const EdgeInsets.only(right: 5),
                                  child: CustomTextField(
                                    controller: addStudentController.place_of_birth,
                                    label: "مكان الميلاد  ",
                                    hint: "مكان الميلاد",
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'يرجى إدخال مكان الميلاد';
                                      }
                                      return null;
                                    },
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
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'يرجى إدخال اسم المدرسة';
                                      }
                                      return null;
                                    },
                                  ))),
                          Expanded(
                              child: Padding(
                                  padding: const EdgeInsets.only(right: 5),
                                  child: CustomTextField(
                                    controller: addStudentController.classroom,
                                    label: "الصف ",
                                    hint: "الصف",
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'يرجى إدخال الصف';
                                      }
                                      return null;
                                    },
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
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'يرجى إدخال رقم الهاتف';
                                      }
                                      return null;
                                    },
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
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'يرجى إدخال كلمة المرور';
                                      }
                                      return null;
                                    },
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
                                  decoration: const InputDecoration(
                                    labelText: "المرحلة",
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
                                    decoration: const InputDecoration(
                                      labelText: "المستوى",
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
                                decoration: const InputDecoration(
                                  labelText: 'اختر الجنس',
                                ),
                                value: addStudentController.selectedGender.value == null ? null : addStudentController.selectedGender.value,
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
                                decoration: const InputDecoration(
                                  labelText: 'الموهل القراني',
                                ),
                                value: addStudentController.qualification_selected.value == null ? null : addStudentController.qualification_selected.value,
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

                      Obx(() {
                        final items = addStudentController.reder.toList();
                        return CustomDropdownField(
                          label: "اختر القارئ",
                          items: items,
                          value: addStudentController.selectedReaderId?.value,
                          valueKey: "id_reder",
                          displayKey: "name_reder",
                          onChanged: (val) {
                            addStudentController.selectedReaderId?.value = val ?? 0;
                          },
                          icon: Icons.person,
                        );
                      }),

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
                  ),
                ],
              );
          },)

        ),
      ),
    );
  }
}
