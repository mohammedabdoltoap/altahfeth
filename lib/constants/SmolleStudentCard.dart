import 'package:flutter/material.dart';


class SmolleStudentCard extends StatelessWidget {
  final String studentName;
  final VoidCallback onAddGrades;

  const SmolleStudentCard({
    Key? key,
    required this.studentName,
    required this.onAddGrades,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shadowColor: Colors.grey.withOpacity(0.3),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onAddGrades,
        splashColor: Colors.teal.withOpacity(0.2),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.teal.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // اسم الطالب
              Expanded(
                child: Text(
                  studentName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade800,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // زر إضافة الدرجات
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.teal.shade100,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.teal.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: onAddGrades,
                  icon: Icon(
                    Icons.add_circle_outline,
                    color: Colors.teal.shade700,
                    size: 32,
                  ),
                  tooltip: 'إضافة درجات',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
