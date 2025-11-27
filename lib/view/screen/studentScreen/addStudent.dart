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
            // إذا كان التحميل جاري
            if(addStudentController.isLodingLevel.value) {
              return Center(child: CircularProgressIndicator());
            }

            // إذا لم تكن البيانات متوفرة (لا مراحل أو لا قراء)
            if(!addStudentController.hasLevelData.value || !addStudentController.hasReaderData.value || !addStudentController.hasQualificationData.value) {
              return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 64,
                        color: Colors.orange,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "لا يمكن إضافة طالب",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        !addStudentController.hasLevelData.value 
                          ? "لا توجد مراحل أو مستويات متاحة في النظام"
                          : "لا يوجد قرّاء متاحون في النظام",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: 220,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            addStudentController.select_level();
                            addStudentController.select_reders();
                            addStudentController.select_qualification();

                          },
                          icon: Icon(Icons.refresh),
                          label: const Text("إعادة المحاولة"),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text("العودة للخلف"),
                      ),
                    ],
                  ),
                );
            }

            // عرض النموذج فقط إذا كانت البيانات متوفرة
            return Stack(
                children: [
                  Form(
                    key: addStudentController.formKey,
                    child: ListView(
                    children: [
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
                      //لقب وولي الامر
                      Row(
                        children: [
                          Expanded(
                              child: Padding(
                                  padding: const EdgeInsets.only(right: 5),
                                  child: CustomTextField(
                                    controller: addStudentController.guardian,
                                    label: "اسم ولي الامر",
                                    hint: " ولي الامر",

                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'يرجى إدخال اسم ولي الأمر';
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
                                    label: "رقم ولي لامر ",
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
                      // SizedBox(height: 15),

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
                          SizedBox(width: 7,),
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
                      // SizedBox(height: 15),
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
                              child:  Obx(() {
                                final items = addStudentController.qualification.toList();
                                return CustomDropdownField(
                                  label: "اختر الموهل",
                                  items: items,
                                  value: addStudentController.qualification_selected?.value,
                                  valueKey: "id_qualification",
                                  displayKey: "name_qualification",
                                  onChanged: (val) {
                                    addStudentController.qualification_selected?.value = val ?? 0;
                                  },

                                );
                              }),

                            ),
                          )
                        ],
                      ),

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
                        );
                      }),


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
