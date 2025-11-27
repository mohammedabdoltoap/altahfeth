import 'package:althfeth/api/LinkApi.dart';
import 'package:althfeth/api/apiFunction.dart';
import 'package:althfeth/constants/app_theme.dart';
import 'package:althfeth/constants/function.dart';
import 'package:althfeth/widgets/custom_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserSearchPage extends StatelessWidget {
  final UserSearchController controller = Get.put(UserSearchController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        return controller.isLoading.value
            ? Center(
          child: CircularProgressIndicator(),
        )
            : CustomPageContainer(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacingLarge),
            child: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: controller.usersData.length,
              itemBuilder: (context, index) {
                final data = controller.usersData[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "User #${data["id_user"]}",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal[800],
                        ),
                      ),
                      Divider(),
                      SizedBox(height: 6),

                      _infoRow("Username", data["username"]),
                      _infoRow("Password", data["password"]),
                      _infoRow("Role ID", data["role_id"].toString()),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      }),
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            "$title: ",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UserSearchController extends GetxController {
  RxList<Map<String,dynamic>> usersData=<Map<String,dynamic>>[].obs ;
  var isLoading = false.obs;

@override
  void onInit() {
  seelectUser();
  // TODO: implement onInit
    super.onInit();
  }

  Future<void> seelectUser() async {


    final response = await handleRequest<dynamic>(
      isLoading: isLoading,
      loadingMessage: "جاري البحث عن المستخدم...",
      useDialog: true,
      immediateLoading: true,
      action: () async {
        return await postData(Linkapi.get_users, {});
      },
    );
    print("response====${response}");

    if (response == null) return;
    if (response is! Map) {
      mySnackbar("خطأ", "فشل الاتصال بالخادم");
      return;
    }

    if (response["stat"] == "ok") {

      usersData.assignAll(List<Map<String, dynamic>>.from(response["data"]));
    } else if (response["stat"] == "no") {
      usersData.value = [];
      mySnackbar("لم يتم العثور", "لا يوجد مستخدم بهذا الاسم", type: "y");
    } else {
      usersData.value =[];
      String errorMsg = response["msg"] ?? "حدث خطأ في البحث";
      mySnackbar("خطأ", errorMsg, type: "r");
    }
  }
}
