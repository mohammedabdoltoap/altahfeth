import 'package:flutter/material.dart';
import 'package:althfeth/constants/color.dart';

class ForLoopExamplePage extends StatelessWidget {


   List<String> studentNames = [
    "مالك محمد",
    "فاطمة علي",
    "خالد سعيد",
    "نورة عبدالله",
    "عمر حسن",
  ];
  


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("مثال"),
        backgroundColor: primaryGreen,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            ...() {
              List<Widget> cards = [];

              for(int i = 0; i < 4; i++) {
                cards.add(_buildStudentCard(
                  studentNames[i],
                  i + 1,
                )
                );
              }
              
              return cards;
            }(),
            

          ],
        ),
      ),
    );
  }


  // 🎯 بطاقة الطالب - النسخة المفصلة
  Widget _buildStudentCard(String name, int number) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade50, Colors.green.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // رقم الطالب
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: primaryGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                "$number",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // بيانات الطالب
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,  // 📝 اسم الطالب من المعامل
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),

              ],
            ),
          ),
          // أيقونة
          Icon(
            Icons.person,
            color: primaryGreen,
            size: 32,
          ),
        ],
      ),
    );
  }

}
