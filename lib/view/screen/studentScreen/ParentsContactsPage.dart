import 'package:althfeth/constants/function.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../api/LinkApi.dart';
import '../../../api/apiFunction.dart';
import '../../../constants/ErrorRetryWidget.dart';

class ParentsContactsPage extends StatelessWidget {
  final ParentsContactsController controller = Get.put(ParentsContactsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("أرقام أولياء الأمور", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green.shade700,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => controller.loadParentsContacts(),
            tooltip: "تحديث",
          ),
        ],
      ),
      body: Obx(() {
        if (controller.loading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.green.shade700),
                const SizedBox(height: 16),
                const Text("جاري التحميل...", style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        if (controller.parentsList.isEmpty) {

          if(controller.noHasStudent.value)
            return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.contacts_outlined, size: 80, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  "لا توجد جهات اتصال",
                  style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                ),
              ],
            ),
          );

          return ErrorRetryWidget(
            onRetry: () => controller.loadParentsContacts(),
          );

        }

        return Column(
          children: [
            // Header مع عدد الأولياء
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade700, Colors.green.shade900],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Icon(Icons.groups_rounded, size: 50, color: Colors.white.withOpacity(0.9)),
                  const SizedBox(height: 12),
                  Text(
                    "${controller.parentsList.length} ولي أمر",
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.phone_android, color: Colors.white, size: 16),
                        SizedBox(width: 8),
                        Text(
                          "انقر للتواصل عبر واتساب",
                          style: TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // قائمة الأولياء
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.parentsList.length,
                itemBuilder: (context, index) {
                  final parent = controller.parentsList[index];
                  return _buildParentCard(parent);
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildParentCard(Map<String, dynamic> parent) {
    final studentName = parent['student_name'] ?? 'غير محدد';
    final parentPhone = parent['parent_phone'] ?? '';
    final circleName = parent['circle_name'] ?? '';
    final hasPhone = parentPhone.isNotEmpty && parentPhone != 'null';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: hasPhone ? () => _openWhatsApp(parentPhone) : null,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // أيقونة الطالب
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.blue.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.person_rounded, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),

              // معلومات الطالب
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      studentName,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (circleName.isNotEmpty)
                      Row(
                        children: [
                          Icon(Icons.school, size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              circleName,
                              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 6),
                    if (hasPhone)
                      Row(
                        children: [
                          Icon(Icons.phone, size: 14, color: Colors.green.shade700),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              parentPhone,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        "لا يوجد رقم",
                        style: TextStyle(fontSize: 13, color: Colors.red.shade400),
                      ),
                  ],
                ),
              ),

              // زر الواتساب
              if (hasPhone)
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green.shade400, Colors.green.shade600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.chat_rounded, color: Colors.white, size: 24),
                    onPressed: () => _openWhatsApp(parentPhone),
                    tooltip: "فتح واتساب",
                  ),
                )
              else
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.phone_disabled, color: Colors.grey.shade400, size: 24),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // void _openWhatsApp(String phoneNumber) async {
  //   // تنظيف رقم الهاتف
  //   String cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
  //
  //   // ✅ رمز الدولة اليمني +967
  //   if (!cleanPhone.startsWith('+')) {
  //     if (cleanPhone.startsWith('0')) {
  //       cleanPhone = '+967${cleanPhone.substring(1)}'; // اليمن
  //     } else if (!cleanPhone.startsWith('967')) {
  //       print("cleanPhone===${cleanPhone}");
  //       cleanPhone = '+967$cleanPhone';
  //     } else {
  //       cleanPhone = '+$cleanPhone';
  //     }
  //   }
  //
  //   final whatsappUrl = Uri.parse('https://wa.me/$cleanPhone');
  //
  //   try {
  //     if (await canLaunchUrl(whatsappUrl)) {
  //       await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
  //     } else {
  //       Get.snackbar(
  //         "خطأ",
  //         "لا يمكن فتح واتساب. تأكد من تثبيت التطبيق",
  //         backgroundColor: Colors.red.shade100,
  //         colorText: Colors.red.shade900,
  //       );
  //     }
  //   } catch (e) {
  //     Get.snackbar(
  //       "خطأ",
  //       "حدث خطأ: $e",
  //       backgroundColor: Colors.red.shade100,
  //       colorText: Colors.red.shade900,
  //     );
  //   }
  // }
  void _openWhatsApp(String phoneNumber) async {
    // تنظيف الرقم
    String cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    // ✅ إضافة رمز الدولة اليمني +967
    if (!cleanPhone.startsWith('+')) {
      if (cleanPhone.startsWith('0')) {
        cleanPhone = '+967${cleanPhone.substring(1)}';
      } else if (!cleanPhone.startsWith('967')) {
        cleanPhone = '+967$cleanPhone';
      } else {
        cleanPhone = '+$cleanPhone';
      }
    }

    // 🔗 رابط تطبيق واتساب المباشر
    final whatsappUri = Uri.parse('whatsapp://send?phone=$cleanPhone');

    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else {
        // fallback إلى wa.me لو فشل البروتوكول (احتمال نادر)
        final fallbackUri = Uri.parse('https://wa.me/$cleanPhone');
        if (await canLaunchUrl(fallbackUri)) {
          await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
        } else {
          Get.snackbar(
            "خطأ",
            "لا يمكن فتح واتساب. تأكد من تثبيت التطبيق",
            backgroundColor: Colors.red.shade100,
            colorText: Colors.red.shade900,
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        "خطأ",
        "حدث خطأ: $e",
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    }
  }

}


class ParentsContactsController extends GetxController {
  var dataArg;
  var loading = false.obs;
  var noHasStudent = false.obs;

  var parentsList = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    dataArg = Get.arguments;
    super.onInit();
    loadParentsContacts();
  }

  Future<void> loadParentsContacts() async {

      // 📨 إرسال الطلب إلى الـ API مع id_circle
      final response =await handleRequest(
          useDialog: false,
          immediateLoading: true,
          isLoading: loading, action: ()async {
        return await postData(Linkapi.select_parents_contacts, {
          "id_circle": dataArg?["id_circle"]?.toString(),
      },)  ;
      });

      // ✅ التحقق من النتيجة
      if (response["stat"] == "ok") {
        parentsList.assignAll(List<Map<String, dynamic>>.from(response["data"]));
      } else if(response["stat"]=="no"){
        noHasStudent.value=true;
        parentsList.clear();
      }else {
        mySnackbar("تنبية", response["msg"]?? "حصل خطا في تحميل البيانات ");
      }

  }
}
