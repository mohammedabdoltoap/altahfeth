import 'package:flutter/material.dart';
import '../../../constants/appButton.dart';
import '../../../constants/color.dart';

class CardStudent extends StatelessWidget {
  final Map<String, dynamic> student;
  final VoidCallback? add_rep;
  final VoidCallback? review;
  final VoidCallback? updateData;
  final VoidCallback? dailyReports;
  final VoidCallback? reviewReports;
  final VoidCallback? absence;

  const CardStudent({
    super.key,
    required this.student,
    required this.add_rep,
    required this.review,
    required this.updateData,
    required this.dailyReports,
    required this.reviewReports,
    required this.absence,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF008080), // primaryTeal
            Color(0xFF66CCCC), // lightTeal
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Card(
        color: Colors.white.withOpacity(0.9),
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // العنوان واسم الطالب
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    student['name_student'],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF004D66), // deepBlue
                    ),
                  ),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF008080),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      student['name_stages'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                "المستوى: ${student['name_level']}",
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87),
              ),
              const SizedBox(height: 10),
              const Divider(thickness: 2, color: Color(0xFF008080)),
              const SizedBox(height: 12),

              // الأزرار (كل صف يحتوي على زرين)
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildButton("التسميع اليومي", add_rep, Colors.teal),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildButton("المراجعة اليومية", review, Colors.teal),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildButton("تعديل البيانات", updateData, Colors.blue),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildButton("تقرير التسميع", dailyReports, Colors.blue),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildButton("تقرير المراجعة", reviewReports, Colors.blue),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildButton("تقرير الغياب", absence, Colors.redAccent),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback? onPressed, Color color) {
    return SizedBox(
      height: 45,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

}
