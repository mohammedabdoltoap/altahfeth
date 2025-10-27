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
    final theme = Theme.of(context);

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      shadowColor: theme.colorScheme.primary.withOpacity(0.3),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onAddGrades,
        splashColor: theme.colorScheme.primary.withOpacity(0.1),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.surface,
                theme.colorScheme.surfaceVariant.withOpacity(0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              // دائرة باسم الطالب أو أول حرف
              CircleAvatar(
                radius: 24,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                child: Text(
                  studentName.isNotEmpty ? studentName[0] : "",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // اسم الطالب
              Expanded(
                child: Text(
                  studentName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // زر إضافة الدرجات مع تأثير خفيف
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withOpacity(0.2),
                      theme.colorScheme.primary.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: IconButton(
                  onPressed: onAddGrades,
                  icon: Icon(
                    Icons.add_circle_outline,
                    color: theme.colorScheme.primary,
                    size: 28,
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
