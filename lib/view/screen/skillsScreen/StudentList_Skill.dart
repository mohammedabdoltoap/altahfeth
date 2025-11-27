import 'package:althfeth/api/LinkApi.dart';
import 'package:althfeth/api/apiFunction.dart';
import 'package:althfeth/constants/function.dart';
import 'package:althfeth/constants/inline_loading.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../constants/SmolleStudentCard.dart';
import '../../../../controller/visitAndExamController/Add_VisitController.dart';
import '../../../constants/ErrorRetryWidget.dart';
import 'Student_Skills.dart';

class StudentList_Skill extends StatelessWidget {
  final StudentList_SkillController controller = Get.put(StudentList_SkillController());
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: () {
        // إزالة التركيز عند الضغط خارج TextField
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "إدارة المهارات",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => controller.getstudents(),
            tooltip: "تحديث",
          ),
        ],
      ),
      body: Obx(() {

        if (controller.isLodingStudent.value)
          return InlineLoading(message: "تحميل اسماء الطلاب",);



        if (controller.students.isEmpty) {
          if(controller.noHasStudent.value)
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline_rounded,
                    size: 100,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "لا يوجد طلاب في الحلقة",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );

          return ErrorRetryWidget(
            onRetry: () => controller.getstudents(),
          );
        }
        
        return Column(
          children: [
            // شريط البحث
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: controller.searchController,
                  focusNode: controller.searchFocusNode,
                  onChanged: (value) => controller.filterStudents(value),
                  decoration: InputDecoration(
                    hintText: "ابحث عن طالب...",
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: theme.colorScheme.primary,
                    ),
                    suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear_rounded,
                              color: Colors.grey.shade400,
                            ),
                            onPressed: () {
                              controller.searchController.clear();
                              controller.searchQuery.value = '';
                              controller.filterStudents('');
                              controller.searchFocusNode.unfocus();
                            },
                          )
                        : const SizedBox()),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ),
            
            // عداد الطلاب
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.people_rounded,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Obx(() => Text(
                    "عدد الطلاب: ${controller.filteredStudents.length}",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  )),
                ],
              ),
            ),
            
            // قائمة الطلاب
            Expanded(
              child: Obx(() {
                if (controller.filteredStudents.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 80,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "لا توجد نتائج للبحث",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "جرب البحث بكلمات مختلفة",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
                  itemCount: controller.filteredStudents.length,
                  itemBuilder: (context, index) {
                    final student = controller.filteredStudents[index];
                    return SmolleStudentCard(
                      studentName: student["name_student"],
                      onAddGrades: () {
                        Map data = {
                          "id_student": student["id_student"],
                          "id_user": controller.data["id_user"],
                          "name_student": student["name_student"],
                        };
                        Get.to(() => Student_Skills(), arguments: data);
                      },
                    );
                  },
                );
              }),
            ),
          ],
        );
      }),
      ),
    );
  }
}

class StudentList_SkillController extends GetxController{

  var data;
  
  // Controllers for search
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();
  
  @override
  void onInit() {
    data=Get.arguments;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp)async {
      getstudents();
    },);
  }
  
  @override
  void onClose() {
    searchController.dispose();
    searchFocusNode.dispose();
    super.onClose();
  }

  RxList<Map<String,dynamic>> students=<Map<String,dynamic>>[].obs;
  RxList<Map<String,dynamic>> filteredStudents=<Map<String,dynamic>>[].obs;
  RxString searchQuery = ''.obs;
  RxBool isLodingStudent=false.obs;
  RxBool noHasStudent=false.obs;
  Future getstudents()async{

    final res = await handleRequest<dynamic>(
      isLoading: isLodingStudent,
      loadingMessage: "جاري تحميل الطلاب...",
      useDialog: false,
      immediateLoading: true,

      action: () async {
    
        return await postData(Linkapi.getstudents, {"id_circle":data["id_circle"]});
      },
    );

    if(res==null)return;

    if(res is! Map )
      {
        mySnackbar("تنبية", "فشل الاتصال");
        return ;
      }
    if(res["stat"]=="ok"){
      students.assignAll(List<Map<String,dynamic>>.from(res["data"]));
      filteredStudents.assignAll(students);
    }else if(res["stat"]=="erorr"){
      mySnackbar("تنبية", "${res["msg"]}");
    }else if(res["stat"]=="no"){
      students.clear();
      noHasStudent.value=true;
      mySnackbar("تنبية", "لايوجد بيانات ");
    }else{
      mySnackbar("تنبية", "حصل خطا تاكد من الاتصال");
    }
  }

  void filterStudents(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      filteredStudents.assignAll(students);
    } else {
      filteredStudents.assignAll(
        students.where((student) =>
          student['name_student'].toString().toLowerCase().contains(query.toLowerCase())
        ).toList(),
      );
    }
  }
}