import 'package:althfeth/constants/appButton.dart';
import 'package:althfeth/constants/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/ErrorRetryWidget.dart';
import '../../constants/inline_loading.dart';
import '../../controller/User_AttendanceController.dart';
import '../widget/offline_indicator.dart';

class User_Attendance extends StatelessWidget {
  final User_AttendanceController controller = Get.put(User_AttendanceController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("تسجيل الحضور والانصراف", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: primaryGreen,
        elevation: 4,
      ),
      body: Obx(() {





        final data = controller.data_attendance_today;
        final hasCheckIn = data["check_in_time"] != null;
        final hasCheckOut = data["check_out_time"] != null;
         if(controller.lodingUsersAttendanceToday.value)
           return InlineLoading( message: "تحميل الحضور والانصراف",indicatorSize: 40,);

         // if(controller.data_attendance_today.isEmpty && !controller.isTodayNew.value)
         //   return ErrorRetryWidget(
         //     onRetry: () => controller.select_users_attendance_today(),
         //   );

        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child:Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                OfflineIndicator(),
                // 🔹 التاريخ واليوم الحالي بالعربية
                Text(
                  controller.todayArabic,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                ),

                const SizedBox(height: 30),

                // 🔹 الحالة الحالية (حضور / انصراف / مكتمل)
                if (!hasCheckIn && !hasCheckOut) ...[
                  Icon(Icons.login, color: Colors.blue, size: 80),
                  const SizedBox(height: 15),
                  const Text(
                    "لم تسجل حضورك بعد",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 25),
                  Obx(() =>
                      AppButton(
                        color: Colors.blue,
                        text: "تسجيل الحضور",
                        onPressed: controller.add_check_in_time_usersAttendance,
                        isLoading: controller.add_check_in.value,
                      )),
                  const SizedBox(height: 15),
                  const Divider(),
                  const SizedBox(height: 10),
                  const Text(
                    "أو",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  Obx(() =>
                      AppButton(
                        color: Colors.purple,
                        text: "تسجيل تغطية",
                        onPressed: controller.addSubstituteAttendance,
                        isLoading: controller.addingSubstitute.value,
                      )),
                ] else if (hasCheckIn && !hasCheckOut) ...[
                  Icon(Icons.logout, color: Colors.orange.shade600, size: 80),
                  const SizedBox(height: 15),
                  const Text(
                    "تم تسجيل الحضور، يمكنك الآن تسجيل الانصراف",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 25),
                  Obx(() =>
                      AppButton(
                        color: Colors.orange.shade600,
                        text: "تسجيل الانصراف",
                        onPressed: controller.add_check_out_time_usersAttendance,
                        isLoading: controller.add_check_out.value,
                      )),
                ] else ...[
                  Icon(Icons.check_circle, color: Colors.green, size: 80),
                  const SizedBox(height: 15),
                  const Text(
                    "تم تسجيل الحضور والانصراف لهذا اليوم ✅",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],

                const SizedBox(height: 35),

                // 🔹 بطاقات وقت الحضور والانصراف
                if (hasCheckIn) ...[
                  AttendanceCard(
                    title: "🕒 وقت الحضور",
                    time: data["check_in_time"] ?? "--:--:--",
                    color: Colors.blue,
                  ),
                ],
                if (hasCheckOut) ...[
                  AttendanceCard(
                    title: "🏁 وقت الانصراف",
                    time: data["check_out_time"] ?? "--:--:--",
                    color: Colors.orange,
                  ),
                ],
              ],
            ),

          ),
        );


      }),
    );
  }
}

// 🔸----------------------------- الكنترولر -----------------------------

// 🔸----------------------------- بطاقة عرض الوقت -----------------------------
class AttendanceCard extends StatelessWidget {
  final String title;
  final String time;
  final Color color;

  const AttendanceCard({required this.title, required this.time, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
            Row(
              children: [
                const Icon(Icons.access_time, size: 18, color: Colors.grey),
                const SizedBox(width: 5),
                Text(time, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

