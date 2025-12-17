import 'package:althfeth/constants/appButton.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../constants/CustomDropdownField.dart';
import '../../../../constants/customTextField.dart';
import '../../../../constants/inline_loading.dart';
import '../../../../controller/studentControllers/updateStudentPendingController.dart';
import '../../../../constants/function.dart';

class UpdateStudentPending extends StatelessWidget {
  UpdateStudentPendingController updateStudentPendingController = Get.put(UpdateStudentPendingController());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          toolbarHeight: 88,
          title: Text("تعديل طالب قيد الانتظار"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Obx(() {
            // إذا كان التحميل جاري
            if(updateStudentPendingController.isLodingLevel.value) {
              return Center(child: CircularProgressIndicator());
            }

            // إذا لم تكن البيانات متوفرة
            if(!updateStudentPendingController.hasLevelData.value || !updateStudentPendingController.hasReaderData.value || !updateStudentPendingController.hasQualificationData.value) {
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
                        "لا يمكن تعديل بيانات الطالب",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        !updateStudentPendingController.hasLevelData.value 
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
                            updateStudentPendingController.select_level();
                            updateStudentPendingController.select_reders();
                            updateStudentPendingController.select_qualification();
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
                    key: updateStudentPendingController.formKey,
                    child: ListView(
                    children: [
                      CustomTextField(
                        controller: updateStudentPendingController.name_student,
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
                                    controller: updateStudentPendingController.guardian,
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
                                    controller: updateStudentPendingController.surname,
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
                        controller: updateStudentPendingController.address_student,
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
                                    controller: updateStudentPendingController.date_of_birth,
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
                                        updateStudentPendingController.date_of_birth.text = dateStr;
                                      }
                                    },
                                  ))),
                          Expanded(
                              child: Padding(
                                  padding: const EdgeInsets.only(right: 5),
                                  child: CustomTextField(
                                    controller: updateStudentPendingController.place_of_birth,
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
                                    controller: updateStudentPendingController.school_name,
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
                                    controller: updateStudentPendingController.classroom,
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
                                  controller: updateStudentPendingController.jop,
                                  label: "الوظيفة",
                                  hint: "الوظيفة",
                                ),
                              )),
                          Expanded(
                              child: Padding(
                                  padding: const EdgeInsets.only(right: 5),
                                  child: CustomTextField(
                                    controller: updateStudentPendingController.phone,
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
                                  controller: updateStudentPendingController.chronic_diseases,
                                  label: "مرض مزمن",
                                  hint: "مرض مزمن",
                                ),
                              )),
                          Expanded(
                              child: Padding(
                                  padding: const EdgeInsets.only(right: 5),
                                  child: CustomTextField(
                                    controller: updateStudentPendingController.password,
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

                      // هل الطالب يجيد القراءة
                      Obx(() => Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: CheckboxListTile(
                          title: const Text("هل الطالب يجيد القراءة؟"),
                          value: updateStudentPendingController.canRead.value,
                          onChanged: (value) {
                            updateStudentPendingController.canRead.value = value ?? false;
                          },
                          controlAffinity: ListTileControlAffinity.trailing,
                        ),
                      )),

                      // المرحلة + المستوى
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                                padding: const EdgeInsets.only(right: 5),
                                child: Obx(() {
                                  final stagesList = updateStudentPendingController.stages.toList();
                                  final isLoaded = updateStudentPendingController.isDataLoaded.value;
                                  final selectedValue = updateStudentPendingController.selectedStageId?.value ?? 0;
                                  print("DEBUG UI: stages list = $stagesList, selectedStageId = $selectedValue, isDataLoaded = $isLoaded");
                                  return DropdownButtonFormField<int>(
                                    decoration: const InputDecoration(
                                      labelText: "المرحلة",
                                    ),
                                    value: selectedValue == 0 ? null : selectedValue,
                                    items:
                                    stagesList.map((stage) {
                                      return DropdownMenuItem<int>(
                                        value: stage["id"] as int,
                                        child: Text(stage["name"] as String),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        updateStudentPendingController
                                            .selectedStageId!.value = val;
                                        updateStudentPendingController
                                            .filterLevels(val);
                                      }
                                    },
                                  );
                                }),
                          )
                          ),
                          SizedBox(width: 7,),
                          Expanded(
                            child: Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Obx(() {
                                  final levelsList = updateStudentPendingController.levels.toList();
                                  final isLoaded = updateStudentPendingController.isDataLoaded.value;
                                  final selectedValue = updateStudentPendingController.selectedLevelId?.value ?? 0;
                                  print("DEBUG UI: levels list = $levelsList, selectedLevelId = $selectedValue, isDataLoaded = $isLoaded");
                                  return InkWell(
                                    onTap: () {
                                      if (updateStudentPendingController.selectedStageId?.value ==
                                          0) {
                                        mySnackbar("تنبيه", "اختر المرحلة أولًا",
                                            type: "y");
                                      }
                                    },
                                    child: DropdownButtonFormField<int>(
                                      decoration: const InputDecoration(
                                        labelText: "المستوى",
                                      ),
                                      value: selectedValue == 0 ? null : selectedValue,
                                      items: levelsList
                                          .map((level) {
                                        return DropdownMenuItem<int>(
                                          value: level["id"] as int,
                                          child: Text(level["name"] as String),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        if (val != null) {
                                          updateStudentPendingController
                                              .selectedLevelId!.value = val;
                                        }
                                      },
                                    ),
                                  );
                                }),
                          )
                          ),
                        ],
                      ),

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
                                value: updateStudentPendingController.selectedGender.value == null ? null : updateStudentPendingController.selectedGender.value,
                                items: updateStudentPendingController.genders.map((gender) {
                                  return DropdownMenuItem<String>(
                                    value: gender,
                                    child: Text(gender),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  updateStudentPendingController.selectedGender.value = value;
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
                              child: Obx(() {
                                final items = updateStudentPendingController.qualification.toList();
                                return CustomDropdownField(
                                  label: "اختر الموهل",
                                  items: items,
                                  value: updateStudentPendingController.qualification_selected?.value,
                                  valueKey: "id_qualification",
                                  displayKey: "name_qualification",
                                  onChanged: (val) {
                                    updateStudentPendingController.qualification_selected?.value = val ?? 0;
                                  },
                                );
                              }),
                            ),
                          )
                        ],
                      ),

                      Obx(() {
                        final items = updateStudentPendingController.reder.toList();
                        return CustomDropdownField(
                          label: "اختر القارئ",
                          items: items,
                          value: updateStudentPendingController.selectedReaderId?.value,
                          valueKey: "id_reder",
                          displayKey: "name_reder",
                          onChanged: (val) {
                            updateStudentPendingController.selectedReaderId?.value = val ?? 0;
                          },
                        );
                      }),

                      // زر الحفظ
                      AppButton(
                          text: "حفظ التعديلات",
                          onPressed: () {
                            updateStudentPendingController.updateStudentPending();
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
