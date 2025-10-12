import 'package:althfeth/api/LinkApi.dart';
import 'package:althfeth/api/apiFunction.dart';
import 'package:althfeth/constants/color.dart';
import 'package:althfeth/constants/loadingWidget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import '../../constants/function.dart';
class LeaveRequestsPage extends StatelessWidget {

  LeaveRequestsPageController controller=Get.put(LeaveRequestsPageController());
  @override
  Widget build(BuildContext context) {


    return Scaffold(
        appBar: AppBar(
          title: const Text("طلبات الإجازة"),
          backgroundColor: primaryGreen,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed:()=> controller.openAddLeaveSheet(context),
          backgroundColor: primaryGreen,
          child: const Icon(Icons.add,color: Colors.white,),
        ),
        body: Obx(() {
          return   controller. leaveRequests.isEmpty
              ? const Center(child: Text("لا توجد طلبات إجازة بعد"))
              : ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount:controller.leaveRequests.length,
            itemBuilder: (context, index) {
              final leave = controller.leaveRequests[index];
              return Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: Icon(Icons.event,
                      color: getStatusColor(leave["status"])),
                  title: Text("تاريخ الإجازة: ${leave["date_leave"]}"),
                  subtitle: Text("السبب: ${leave["reason_leave"]}"),
                  trailing: Text(
                    getStatusText(leave["status"]),
                    style: TextStyle(
                        color: getStatusColor(leave["status"]),
                        fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          );

        },
        )

    );


  }
  Color getStatusColor(int status) {
    switch (status) {
      case 0:
        return Colors.orange;
      case 1:
        return Colors.green;
      case 2:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String getStatusText(int status) {
    switch (status) {
      case 0:
        return "قيد المراجعة";
      case 1:
        return "تم القبول";
      case 2:
        return "مرفوض";
      default:
        return "غير معروف";
    }
  }


}
class LeaveRequestsPageController extends GetxController {
  var dataArg_user;
  RxList<Map<String, dynamic>> leaveRequests = <Map<String, dynamic>>[].obs;

  final TextEditingController reasonController = TextEditingController();
  DateTime? selectedDate;

  @override
  void onInit() {
    dataArg_user = Get.arguments;
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) => select_leave_requests());
  }

  Future select_leave_requests() async {
    showLoading();
    await del();
    var res = await postData(Linkapi.select_leave_requests, {
      "id_user": dataArg_user["id_user"]
    });
    hideLoading();

    leaveRequests.assignAll(RxList<Map<String, dynamic>>.from(checkApi(res)));

  }

  Future<void> openAddLeaveSheet(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 👈 ضروري حتى ما يغطي الكيبورد المحتوى
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          // 👇 علشان لما الكيبورد يظهر ما يغطي المحتوى
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const Text(
                  "🗓️ طلب إجازة جديدة",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF008080),
                  ),
                ),
                const SizedBox(height: 25),

                // حقل السبب
                TextField(
                  controller: reasonController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: "سبب الإجازة",
                    alignLabelWithHint: true,
                    prefixIcon: const Icon(Icons.edit_note, color: Color(0xFF008080)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Color(0xFF008080), width: 2),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // اختيار التاريخ
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: const Color(0xFF008080),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  icon: const Icon(Icons.calendar_month, color: Colors.white),
                  label: Text(
                    selectedDate == null
                        ? "اختر تاريخ الإجازة"
                        : DateFormat("yyyy-MM-dd").format(selectedDate!),
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  onPressed: () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: now.add(const Duration(days: 1)),
                      firstDate: now.add(const Duration(days: 1)),
                      lastDate: now.add(const Duration(days: 365)),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: Color(0xFF008080), // لون التقويم
                              onPrimary: Colors.white,
                              onSurface: Color(0xFF004D66),
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) selectedDate = picked;
                  },
                ),

                const SizedBox(height: 30),

                // زر الإرسال
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF004D66),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: ()async {
                    if (selectedDate == null || reasonController.text.isEmpty) {
                      mySnackbar("تنبية", "يرجى تحديد التاريخ وكتابة السبب");
                      return;
                    }
                   await insert_leave_requests();

                  },
                  child: const Text(
                    "إرسال الطلب",
                    style: TextStyle(fontSize: 17, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  Future insert_leave_requests() async {
    showLoading(); // 👈 افتح الـ loading
    await del();
    var res = await postData(Linkapi.insert_leave_requests, {
      "id_user": dataArg_user["id_user"],
      "date_leave": DateFormat("yyyy-MM-dd").format(selectedDate!),
      "reason_leave": reasonController.text,
    });

    hideLoading(); // 👈 أغلق الـ loading قبل أي شيء آخر

    if (res["stat"] == "ok") {
      leaveRequests.add({
        "date_leave": DateFormat("yyyy-MM-dd").format(selectedDate!),
        "reason_leave": reasonController.text,
        "status": 0,
      });

      reasonController.clear();
      selectedDate = null;

      Get.back(); // 👈 بعد ما يغلق الـ loading، اغلق الـ bottom sheet
      mySnackbar("نجاح", "تم الإضافة",type:"g");
    } else if(res["stat"]=="exist")
    {
      mySnackbar("تنبية", "${res["msg"]}");
    }
    else{
      mySnackbar("خطأ", "حدث خطأ أثناء الإضافة");
    }
  }

}
