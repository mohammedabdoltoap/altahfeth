//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// import '../../../controller/Monthly_PlanController.dart';
// import '../../screen/test.dart';
//
// class DatePickerWidget extends StatelessWidget {
//   final Monthly_PlanController controller = Get.find();
//   // final Monthly_PlanController2 controller = Get.find();
//
//   DatePickerWidget({super.key});
//
//   Future<void> _pickDate(BuildContext context) async {
//     DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: controller.selectedDate.value,
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2100),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: const ColorScheme.light(
//               primary: Colors.teal, // لون الهيدر والأزرار
//               onPrimary: Colors.white, // لون النص فوق الهيدر
//               onSurface: Colors.black, // لون النصوص العادية
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//     if (picked != null && picked != controller.selectedDate.value) {
//       controller.setDate(picked);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Obx(() => Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           "تاريخ بداية الخطة",
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             color: Colors.teal.shade700,
//           ),
//         ),
//         const SizedBox(height: 10),
//         InkWell(
//           onTap: () => _pickDate(context),
//           borderRadius: BorderRadius.circular(12),
//           child: Container(
//             padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               border: Border.all(color: Colors.teal.shade300),
//               borderRadius: BorderRadius.circular(12),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.teal.withOpacity(0.1),
//                   blurRadius: 6,
//                   offset: const Offset(0, 3),
//                 )
//               ],
//             ),
//             child: Row(
//               children: [
//                 Icon(Icons.calendar_month, color: Colors.teal.shade600, size: 22),
//                 const SizedBox(width: 12),
//                 Text(
//                   "${controller.selectedDate.value.day} / ${controller.selectedDate.value.month} / ${controller.selectedDate.value.year}",
//                   style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//                 ),
//                 const Spacer(),
//                 Icon(Icons.edit_calendar, color: Colors.teal.shade400, size: 20),
//               ],
//             ),
//           ),
//         ),
//       ],
//     ));
//   }
// }
