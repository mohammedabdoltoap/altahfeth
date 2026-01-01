import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/color.dart';
import '../../../controller/circleStudents_controller.dart';
import '../studentScreen/StudentPlanReport.dart';

class CircleStudentsPage extends StatelessWidget {
  const CircleStudentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CircleStudentsController());

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [kPrimaryColor, kPrimaryColor.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'طلاب الحلقة',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (controller.circleData['name_circle'] != null)
              Text(
                controller.circleData['name_circle'],
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
          ],
        ),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              kBackground,
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.6],
          ),
        ),
        child: Obx(() {
          if (controller.isLoading.value) {
            return Center(
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'جاري تحميل الطلاب...',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (controller.students.isEmpty) {
            return Center(
              child: Container(
                margin: EdgeInsets.all(20),
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.grey[50]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: Offset(0, 5),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: kPrimaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.people_outline,
                        size: 64,
                        color: kPrimaryColor,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'لا يوجد طلاب',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'لم يتم العثور على طلاب في هذه الحلقة',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: controller.getStudentsForCircle,
            color: kPrimaryColor,
            child: ListView.builder(
              padding: EdgeInsets.all(12),
              itemCount: controller.students.length,
              itemBuilder: (context, index) {
                final student = controller.students[index];
                return _buildStudentCard(context, student, index + 1);
              },
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStudentCard(BuildContext context, Map<String, dynamic> student, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: kPrimaryColor.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '$index',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: kPrimaryColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student['name_student'] ?? 'طالب',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      if (student['id_level'] != null || student['id_stages'] != null)
                        Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              if (student['id_level'] != null) ...[
                                Icon(
                                  Icons.school,
                                  size: 14,
                                  color: Colors.grey[600],
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'المستوى ${student['id_level']}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                              if (student['id_level'] != null && student['id_stages'] != null)
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  child: Text('•', style: TextStyle(color: Colors.grey[400])),
                                ),
                              if (student['id_stages'] != null) ...[
                                Icon(
                                  Icons.stairs,
                                  size: 14,
                                  color: Colors.grey[600],
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'المرحلة ${student['id_stages']}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    kPrimaryColor,
                    kPrimaryColor.withOpacity(0.8),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: kPrimaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Get.to(() => StudentPlanReport(), arguments: {
                      "id_student": student["id_student"],
                      "name_student": student["name_student"],
                      "current_level_id": student["id_level"],
                      "current_stage_id": student["id_stages"],
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.assignment,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'عرض خطة الطالب',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
