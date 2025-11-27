import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/customAppBar.dart';

class UserGuide extends StatelessWidget {
  const UserGuide({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: const CustomAppBar(
        title: "دليل الاستخدام",
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // مقدمة
          _buildIntroCard(theme),
          const SizedBox(height: 16),
          
          // خطوات البدء
          _buildSectionCard(
            theme: theme,
            icon: Icons.play_circle_outline,
            title: "خطوات البدء",
            color: Colors.blue,
            steps: [
              "سجل حضورك يومياً من خلال صفحة 'تسجيل الحضور والانصراف'",
              "ابدأ بتسجيل التسميع أو المراجعة للطلاب",
              "يمكنك تسجيل حضور الطلاب في أي وقت",
            ],
          ),
          const SizedBox(height: 16),
          
          // تسجيل الحضور
          _buildSectionCard(
            theme: theme,
            icon: Icons.login,
            title: "تسجيل الحضور والانصراف",
            color: Colors.green,
            steps: [
              "افتح القائمة الجانبية واختر 'تسجيل الحضور والانصراف'",
              "اضغط على 'تسجيل الحضور' عند وصولك",
              "اضغط على 'تسجيل الانصراف' عند المغادرة",
              "يمكنك تسجيل 'تغطية' إذا كنت تغطي حلقة أخرى",
            ],
          ),
          const SizedBox(height: 16),
          
          // حضور الطلاب
          _buildSectionCard(
            theme: theme,
            icon: Icons.how_to_reg,
            title: "تسجيل حضور الطلاب",
            color: Colors.orange,
            steps: [
              "من القائمة الجانبية اختر 'تحضير الطلاب'",
              "حدد الطلاب الحاضرين والغائبين",
              "اضغط 'حفظ الحضور'",
              "يمكنك تسجيل الحضور في أي وقت خلال اليوم",
            ],
          ),
          const SizedBox(height: 16),
          
          // التسميع اليومي
          _buildSectionCard(
            theme: theme,
            icon: Icons.book,
            title: "التسميع اليومي",
            color: Colors.purple,
            steps: [
              "اختر الطالب من الصفحة الرئيسية",
              "اضغط على 'التسميع اليومي'",
              "حدد نطاق الآيات (من - إلى)",
              "أدخل الدرجة والتقييم",
              "اضغط 'حفظ التسميع'",
            ],
          ),
          const SizedBox(height: 16),
          
          // المراجعة اليومية
          _buildSectionCard(
            theme: theme,
            icon: Icons.refresh,
            title: "المراجعة اليومية",
            color: Colors.teal,
            steps: [
              "اختر الطالب من الصفحة الرئيسية",
              "اضغط على 'المراجعة اليومية'",
              "حدد نطاق المراجعة",
              "أدخل الدرجة والتقييم",
              "اضغط 'اعتماد المراجعة'",
            ],
          ),
          const SizedBox(height: 16),
          
          // التقارير
          _buildSectionCard(
            theme: theme,
            icon: Icons.assessment,
            title: "التقارير",
            color: Colors.indigo,
            steps: [
              "يمكنك عرض تقرير التسميع لأي طالب",
              "يمكنك عرض تقرير المراجعة",
              "يمكنك عرض تقرير الغياب",
              "يمكنك عرض خطة الطالب",
              "جميع التقارير قابلة للطباعة بصيغة PDF",
            ],
          ),
          const SizedBox(height: 16),
          
          // نصائح مهمة
          _buildTipsCard(theme),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildIntroCard(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary.withOpacity(0.1),
              Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.menu_book,
              size: 60,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              "مرحباً بك في دليل الاستخدام",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              "هذا الدليل سيساعدك على استخدام النظام بكفاءة",
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required Color color,
    required List<String> steps,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...steps.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          "${entry.key + 1}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: const TextStyle(fontSize: 14, height: 1.5),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTipsCard(ThemeData theme) {
    return Card(
      elevation: 2,
      color: Colors.amber.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.amber.shade700, size: 28),
                const SizedBox(width: 12),
                Text(
                  "نصائح مهمة",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTipItem("يجب تسجيل حضورك قبل تسجيل أي تسميع أو مراجعة"),
            _buildTipItem("يمكنك تعديل التسميع أو المراجعة في نفس اليوم"),
            _buildTipItem("استخدم التقارير لمتابعة تقدم الطلاب"),
            _buildTipItem("سجل حضور الطلاب يومياً لمتابعة الغياب"),
            _buildTipItem("في حالة وجود مشكلة، تواصل مع الدعم الفني"),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: Colors.amber.shade700, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
