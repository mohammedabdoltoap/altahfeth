import 'package:althfeth/controller/home_cont.dart';
import 'package:althfeth/view/screen/test.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/loadingWidget.dart';
import 'addStudent.dart';
import 'monthly_plan.dart';

class Home extends StatelessWidget {
   HomeCont controller = Get.put(HomeCont());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
    if( controller.isLoding_get_circle_and_students.value)
    return Scaffold(
      body:Center(
        child: LoadingWidget(isLoading: controller.isLoding_get_circle_and_students),
      ) ,
    );
  return  Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        centerTitle: true,
        toolbarHeight: 120, // طول أكبر للـ AppBar
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // اسم الحلقة كبير وواضح
            Text(
              "${controller.data_circle["name_circle"]}",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 6),
            // خط فاصل صغير
            Container(
              width: 80,
              height: 3,
              color: Colors.white70,
            ),
            SizedBox(height: 6),
            // اسم الأستاذ
            Text(
              "الأستاذ: ${controller.dataArg["username"]}",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // شريط البحث + زر إضافة طالب
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: controller.filterStudents,
                    decoration: InputDecoration(
                      hintText: "ابحث عن الطالب...",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    Get.to(()=>Addstudent(),arguments: controller.data_circle);
                  },
                  icon: Icon(Icons.person_add),
                  label: Text("إضافة طالب"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding:
                    EdgeInsets.symmetric(vertical: 15, horizontal: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),

            // قائمة الطلاب
            Expanded(
              child: Obx(() {
                if (controller.filteredStudents.isEmpty) {
                  return Center(child: Text("لا يوجد طلاب مطابقون"));
                }
                return ListView.builder(
                  itemCount: controller.filteredStudents.length,
                  itemBuilder: (context, index) {
                    final student = controller.filteredStudents[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // اسم الطالب + المرحلة
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(student['name_student'],
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 4, horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.teal[100],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(student['name_stages'],
                                      style: TextStyle(
                                          color: Colors.teal[800],
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            SizedBox(height: 6),
                            Text("العمر: ${student['age_student']}"),
                            Text("العنوان: ${student['address_student']}"),
                            Text("المستوى: ${student['name_level']}"),
                            SizedBox(height: 10),

                            // الأزرار
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          controller.addReport(student['id_student']);
                                        },
                                        icon: Icon(Icons.note_add, size: 18),
                                        label: Text("تقرير"),
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green),
                                      ),
                                    ),
                                    SizedBox(width: 8,),
                                    Expanded(
                                      child:
                                      ElevatedButton.icon(
                                        onPressed: () {

                                          student["id_user"]= controller.dataArg["id_user"];
                                          Get.to(()=>Monthly_Plan(),arguments: student);

                                        },
                                        icon: Icon(Icons.next_plan, size: 18),
                                        label: Text("الخطة الشهرية"),
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(

                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          controller.editStudent(student['id_student'],
                                              student); // مثال
                                        },
                                        icon: Icon(Icons.edit, size: 18),
                                        label: Text("تعديل"),
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          controller.deleteStudent(
                                              student['id_student']);
                                        },
                                        icon: Icon(Icons.delete, size: 18),
                                        label: Text("حذف"),
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );

                  },
                );
              }),
            ),
          ],
        ),
      ),

    );

  },);

  }

}
