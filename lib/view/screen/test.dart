// import 'package:althfeth/constants/function.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import '../api/LinkApi.dart';
// import '../api/apiFunction.dart';
//
// class Monthly_PlanController extends GetxController {
//   var dataArg;
//   TextEditingController daysRealTimeController=TextEditingController();
//
//   var selectedDate = DateTime.now().obs;
//   var end_date = DateTime.now().obs;
//   var datasoura = <Map<String, dynamic>>[].obs;
//   // 🔹 المتغيرات لمتابعة السور المختارة
//   var fromSoura = Rxn<Map<String, dynamic>>();
//   var toSoura = Rxn<Map<String, dynamic>>();
//   RxDouble amount_value=0.0.obs;
//
//   @override
//   void onInit() {
//     dataArg = Get.arguments;
//     print(dataArg);
//     select_fromId_soura_with_to_soura();
//     super.onInit();
//   }
//
//   void setDate(DateTime date) {
//     selectedDate.value = date;
//   }
//
//   Future select_fromId_soura_with_to_soura() async {
//     var response = await postData(Linkapi.select_fromId_soura_with_to_soura, {
//       "id_level": dataArg["id_level"]
//     });
//
//     if (response["stat"] == "ok") {
//       datasoura.assignAll(List<Map<String, dynamic>>.from(response["data"]));
//     } else {
//       print("erorrrrrrrrr");
//     }
//   }
//
//   RxBool isLoding_addPlan=false.obs;
//  Future addPlan()async{
//     Map data={
//       "id_student":dataArg["id_student"],
//       "start_date":DateFormat('yyyy-MM-dd').format(selectedDate.value),
//       "end_date":DateFormat('yyyy-MM-dd').format(end_date.value),
//       "start_id_soura":fromSoura.value!["id_soura"],
//       "end_id_soura":toSoura.value!["id_soura"],
//       "amount_value":amount_value.value.toStringAsFixed(3),
//       "id_user":dataArg["id_user"],
//     };
//     print(data);
//
//     isLoding_addPlan.value=true;
//    await Future.delayed(Duration(seconds: 2));
//     var response=await postData(Linkapi.addPlan, data);
//     if(response["stat"]=="ok"){
//       Get.back();
//       mySnackbar("تم اضافة الخطة بنجاح", "تم الاضافة",type: "g");
//       // selectedDate.value=DateTime.now();
//       // end_date.value=DateTime.now();
//       // fromSoura=Rxn<Map<String, dynamic>>();
//       // toSoura=Rxn<Map<String, dynamic>>();
//
//     }else{
//       mySnackbar("حصل خطا", "لم تتم الاضافة",type: "g");
//     }
//     isLoding_addPlan.value=false;
//
//   }
//
//   chengNull(){
//
//     if(fromSoura.value!=null && toSoura.value!=null&& daysRealTimeController.text.isNotEmpty) {
//       if(fromSoura.value!["id_soura"]==toSoura.value!["id_soura"]){
//         amount_value.value= (fromSoura.value!["to_page"] - toSoura.value!["from_page"]) / int.tryParse(daysRealTimeController.text);
//         return ;
//       }
//       amount_value.value= (fromSoura.value!["from_page"] - toSoura.value!["to_page"]) / int.tryParse(daysRealTimeController.text);
//     }
//     else{
//       amount_value.value=0.0;
//
//     }
//   }
// }
// import 'package:althfeth/api/LinkApi.dart';
// import 'package:althfeth/api/apiFunction.dart';
// import 'package:althfeth/constants/appButton.dart';
// import 'package:althfeth/constants/color.dart';
// import 'package:althfeth/constants/function.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import '../../controller/Monthly_PlanController.dart';
// import '../widget/monthly_plan/datePickerWidget.dart';
// import '../widget/monthly_plan/souraSelector.dart';
//
// class Monthly_Plan extends StatelessWidget {
//   final Monthly_PlanController controller = Get.put(Monthly_PlanController());
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("التخطيط الشهري"),
//         backgroundColor: Colors.teal, // لون موحد للهيدر
//         elevation: 0,
//       ),
//       body: Container(
//         color: Colors.grey.shade100, // خلفية ناعمة
//         child: ListView(
//           padding: const EdgeInsets.all(16),
//           children: [
//             Card(
//               elevation: 3,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "معلومات الطالب",
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.teal.shade700,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text("الاسم:   ${controller.dataArg["name_student"]}",
//                         style: const TextStyle(fontSize: 16)),
//
//                     const SizedBox(height: 8),
//                     Text("المرحلة:   ${controller.dataArg["name_stages"]}",
//                         style: const TextStyle(fontSize: 16)),
//
//                     const SizedBox(height: 4),
//                     Text("المستوى:   ${controller.dataArg["name_level"]}",
//                         style: const TextStyle(fontSize: 16)),
//                     const SizedBox(height: 4),
//                     DatePickerWidget(),
//                     const SizedBox(height: 10),
//
//                     TextFormField(
//                       controller: controller.daysRealTimeController,
//                       keyboardType: TextInputType.number,
//                       inputFormatters: [
//                         FilteringTextInputFormatter.digitsOnly,
//                         LengthLimitingTextInputFormatter(2),
//                         TextInputFormatter.withFunction((oldValue, newValue) {
//                           if (newValue.text.isEmpty) return newValue;
//                           int value = int.parse(newValue.text);
//                           if (value > 30) {
//                             // اظهار رسالة تحذير
//                             Get.snackbar(
//                               "تحذير",
//                               "لا يمكن إدخال رقم أكبر من 30",
//                               backgroundColor: Colors.red.shade400,
//                               colorText: Colors.white,
//                               snackPosition: SnackPosition.BOTTOM,
//                               margin: const EdgeInsets.all(16),
//                             );
//                             return oldValue; // يمنع الرقم الأكبر من 30
//                           }
//                           return newValue;
//                         }),
//                       ],
//                       onChanged: (val) {
//                         controller.chengNull();
//                       },
//                       decoration: InputDecoration(
//                         labelText: "الأيام الفعلية في الشهر",
//                         filled: true,
//                         fillColor: Colors.white,
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide(color: Colors.teal.shade300, width: 1.5),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: const BorderSide(color: Colors.teal, width: 2),
//                         ),
//                       ),
//                       style: const TextStyle(fontSize: 16),
//                     )
//
//
//                   ],
//
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 20),
//             SouraSelector(),
//             const SizedBox(height: 30),
//          Obx(() =>
//             AppButton(
//               text: "حفظ الخطة",
//               onPressed: () {
//                 // التحقق من اختيار التاريخ
//                 if (controller.selectedDate.value == null) {
//                   mySnackbar("حصل خطأ", "يرجى اختيار تاريخ البداية");
//                   return;
//                 }
//
//                 // التحقق من إدخال الأيام الفعلية
//                 int days = int.tryParse(controller.daysRealTimeController.text) ?? 0;
//                 if (days <= 0) {
//                   mySnackbar("حصل خطأ", "يرجى إدخال عدد أيام صحيح أكبر من صفر");
//                   return;
//                 }
//
//                 // حساب التاريخ النهائي
//                 controller.end_date.value =
//                     controller.selectedDate.value.add(Duration(days: days));
//
//                 // التحقق من اختيار نطاق السور
//                 if (controller.fromSoura.value == null || controller.toSoura.value == null) {
//                   mySnackbar("حصل خطأ", "يرجى اختيار نطاق السور (بداية ونهاية)");
//                   return;
//                 }
//
//                 // التحقق من أن عدد الصفحات > 0
//                 if (controller.amount_value.value < 0.0) {
//                   mySnackbar("حصل خطأ", "عدد الصفحات للحفظ باليوم يجب أن يكون أكبر من صفر");
//                   return;
//                 }
//
//                 // كل الشروط صحيحة → إضافة الخطة
//                 controller.addPlan();
//               },
//               color: primaryGreen,
//               isLoading: controller.isLoding_addPlan.value,
//             ),
//          )
//           ],
//         ),
//       ),
//     );
//   }
// }
//