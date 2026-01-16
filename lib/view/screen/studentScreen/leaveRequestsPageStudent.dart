import 'package:althfeth/api/LinkApi.dart';
import 'package:althfeth/api/apiFunction.dart';
import 'package:althfeth/constants/appButton.dart';
import 'package:althfeth/constants/color.dart';
import 'package:althfeth/constants/inline_loading.dart';
import 'package:althfeth/constants/loadingWidget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

import '../../../constants/ErrorRetryWidget.dart';
import '../../../constants/function.dart';
class  LeaveRequestsPageStudent extends StatelessWidget {

  LeaveRequestsPageStudentController controller=Get.put(LeaveRequestsPageStudentController());
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

          if(controller.lodeleave_requests.value)
            return InlineLoading(message: "تحميل الاجازات السابقة",);

          if(controller.leaveRequests.isEmpty &&  controller.noHasLeaveRequests.value)
            return Center(child: Text("لا توجد طلبات إجازة بعد"));

          if(controller.leaveRequests.isEmpty &&  !controller.noHasLeaveRequests.value)
            return ErrorRetryWidget(
              onRetry: () => controller.select_leave_requests(),
            );



          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.leaveRequests.length, // 🔢 عدد طلبات الإجازة
                  itemBuilder: (context, index) {
                    // 📌 هنا نحصل على طلب الإجازة رقم index من القائمة
                    // مثل: leave = leaveRequests[i] في for loop عادية
                    final leave = controller.leaveRequests[index];
                    final isApproved = leave["status"] == 1;
                    final isPending = leave["status"] == 0;
                    final isRejected = leave["status"] == 2;
                    final isPeriod = leave["leave_type"] == "period";

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isPending
                              ? [Colors.orange.shade50, Colors.orange.shade100]
                              : isApproved
                              ? [Colors.green.shade50, Colors.green.shade100]
                              : [Colors.red.shade50, Colors.red.shade100],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: getStatusColor(leave["status"]).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header with icon and status
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: getStatusColor(leave["status"]).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    isPeriod ? Icons.date_range : Icons.event,
                                    color: getStatusColor(leave["status"]),
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        isPeriod ? "إجازة فترة" : "إجازة يوم واحد",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: getStatusColor(leave["status"]),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          getStatusText(leave["status"]),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Divider(height: 1),
                            const SizedBox(height: 12),
                            // Date info
                            Row(
                              children: [
                                Icon(Icons.calendar_today, size: 18, color: Colors.grey[600]),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    isPeriod && leave["end_date"] != null
                                        ? "من ${leave["date_leave"]} إلى ${leave["end_date"]}"
                                        : leave["date_leave"],
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey[800],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Reason
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.description, size: 18, color: Colors.grey[600]),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    leave["reason_leave"],
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

            ],
          );
        })
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


class LeaveRequestsPageStudentController extends GetxController {
  var dataArg_user;
  RxList<Map<String, dynamic>> leaveRequests = <Map<String, dynamic>>[].obs;

  final TextEditingController reasonController = TextEditingController();
  Rx<DateTime?> selectedDate = Rx<DateTime?>(null);
  Rx<DateTime?> selectedEndDate = Rx<DateTime?>(null);
  RxString leaveType = 'single'.obs; // single or period

  @override
  void onInit()async {
    dataArg_user = Get.arguments;
    super.onInit();
    await  select_leave_requests();
    // WidgetsBinding.instance.addPostFrameCallback((_) => select_leave_requests());
  }

  RxBool lodeleave_requests=false.obs;
  RxBool noHasLeaveRequests=false.obs;
  Future select_leave_requests() async {


    var res = await handleRequest(
        isLoading: lodeleave_requests,
        useDialog: false,
        immediateLoading: true,
        action:()async{
          return await postData(Linkapi.select_leave_requests_student, {
            "id_student": dataArg_user["id_student"]
          });
        });
    if(res==null)
      return;

    if (res is! Map) {
      mySnackbar("خطأ", "فشل الاتصال بالخادم");
      return;
    }
    if (res["stat"] == "ok") {
      leaveRequests.assignAll(RxList<Map<String, dynamic>>.from(res["data"]));
    }
    else if(res["stat"]=="no"){
      leaveRequests.clear();
      noHasLeaveRequests.value=true;
    }
    else if(res["stat"]=="erorr"){
      mySnackbar("تنبية", res["msg"] ?? "خطا في جلب الاجازات" );

    }

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
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF008080), Color(0xFF006666)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.event_available, color: Colors.white, size: 28),
                      SizedBox(width: 12),
                      Text(
                        "طلب إجازة جديدة",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                // اختيار نوع الإجازة
                Obx(() => Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFF008080)),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      RadioListTile<String>(
                        title: const Text("يوم واحد"),
                        value: 'single',
                        groupValue: leaveType.value,
                        activeColor: Color(0xFF008080),
                        onChanged: (value) {
                          leaveType.value = value!;
                          selectedEndDate.value = null;
                        },
                      ),
                      RadioListTile<String>(
                        title: const Text("فترة (من تاريخ إلى تاريخ)"),
                        value: 'period',
                        groupValue: leaveType.value,
                        activeColor: Color(0xFF008080),
                        onChanged: (value) {
                          leaveType.value = value!;
                        },
                      ),
                    ],
                  ),
                )),
                const SizedBox(height: 20),

                // حقل السبب
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Color(0xFF008080).withOpacity(0.3)),
                  ),
                  child: TextField(
                    controller: reasonController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: "سبب الإجازة",
                      labelStyle: const TextStyle(color: Color(0xFF008080)),
                      alignLabelWithHint: true,
                      prefixIcon: const Icon(Icons.description_outlined, color: Color(0xFF008080)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: Color(0xFF008080), width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // اختيار تاريخ البداية
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF008080), Color(0xFF006666)],
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF008080).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    icon: const Icon(Icons.calendar_today, color: Colors.white),
                    label: Obx(() => Text(
                      selectedDate.value == null
                          ? (leaveType.value == 'single' ? "اختر تاريخ الإجازة" : "اختر تاريخ البداية")
                          : DateFormat("yyyy-MM-dd","en").format(selectedDate.value!),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    )),
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
                      if (picked != null) {
                        selectedDate.value = picked;
                        if (leaveType.value == 'single') {
                          selectedEndDate.value = null;
                        }
                      }
                    },
                  ),
                ),

                // تاريخ النهاية (يظهر فقط إذا كان النوع فترة)
                Obx(() => leaveType.value == 'period'
                    ? Column(
                  children: [
                    const SizedBox(height: 15),
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF006666), Color(0xFF004D4D)],
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF006666).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        icon: const Icon(Icons.calendar_month, color: Colors.white),
                        label: Obx(() => Text(
                          selectedEndDate.value == null
                              ? "اختر تاريخ النهاية"
                              : DateFormat("yyyy-MM-dd","en").format(selectedEndDate.value!),
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        )),
                        onPressed: () async {
                          if (selectedDate.value == null) {
                            mySnackbar("تنبيه", "يرجى اختيار تاريخ البداية أولاً");
                            return;
                          }
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate.value!.add(const Duration(days: 1)),
                            firstDate: selectedDate.value!.add(const Duration(days: 1)),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: Color(0xFF006666),
                                    onPrimary: Colors.white,
                                    onSurface: Color(0xFF004D66),
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) selectedEndDate.value = picked;
                        },
                      ),
                    ),
                  ],
                )
                    : const SizedBox()),

                const SizedBox(height: 30),

                // زر الإرسال

                Obx(() => AppButton(text: "إرسال الطلب", onPressed: ()async {
                  if (selectedDate.value == null || reasonController.text.isEmpty) {
                    mySnackbar("تنبية", "يرجى تحديد التاريخ وكتابة السبب");
                    return;
                  }
                  if (leaveType.value == 'period' && selectedEndDate.value == null) {
                    mySnackbar("تنبية", "يرجى تحديد تاريخ النهاية للفترة");
                    return;
                  }
                  await insert_leave_requests();

                },
                  isLoading: isSaveInsert_leave.value,
                )
                  ,),

              ],
            ),
          ),
        );
      },
    );
  }
  RxBool isSaveInsert_leave=false.obs;
  Future insert_leave_requests() async {

    Map<String, dynamic> requestData = {
      "id_student": dataArg_user["id_student"],
      "date_leave": DateFormat("yyyy-MM-dd","en").format(selectedDate.value!),
      "reason_leave": reasonController.text,
      "leave_type": leaveType.value,
    };

    if (leaveType.value == 'period' && selectedEndDate.value != null) {
      requestData["end_date"] = DateFormat("yyyy-MM-dd","en").format(selectedEndDate.value!);
    }

    var res = await handleRequest(
        isLoading: isSaveInsert_leave,
        useDialog: false,
        action: ()async{
          await del();
          return await postData(Linkapi.insert_leave_requests_student, requestData);
        });
    if(res==null)return;

    if (res is! Map) {
      mySnackbar("خطأ", "فشل الاتصال بالخادم");
      return;
    }

    if (res["stat"] == "ok") {
      Map<String, dynamic> newLeave = {
        "date_leave": DateFormat("yyyy-MM-dd","en").format(selectedDate.value!),
        "reason_leave": reasonController.text,
        "status": 0,
        "leave_type": leaveType.value,
      };

      if (leaveType.value == 'period' && selectedEndDate.value != null) {
        newLeave["end_date"] = DateFormat("yyyy-MM-dd","en").format(selectedEndDate.value!);
      }

      leaveRequests.add(newLeave);

      reasonController.clear();
      selectedDate.value = null;
      selectedEndDate.value = null;
      leaveType.value = 'single';

      Get.back();
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
