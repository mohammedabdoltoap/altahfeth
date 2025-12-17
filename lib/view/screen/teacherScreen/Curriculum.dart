import 'package:althfeth/view/screen/teacherScreen/curriculum_branch/Adab.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:althfeth/constants/app_theme.dart';
import 'curriculum_branch/Hadiths.dart';
import 'curriculum_branch/TuhfatAlAtfal.dart';
import 'curriculum_branch/Mathurat.dart';

class Curriculum extends StatelessWidget {
  final CurriculumController curriculumController = Get.put(CurriculumController());
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'المنهج المصاحب',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.backgroundColor,
              Colors.white,
            ],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.all(AppTheme.spacingLarge),
          children: [
            // عنوان القسم
            _buildSectionHeader(),
            SizedBox(height: AppTheme.spacingLarge),
            
            // كرت الأحاديث
            _buildCurriculumCard(
              title: 'الأحاديث النبوية',
              subtitle: 'أحاديث مختارة من السنة النبوية الشريفة',
              icon: Icons.menu_book,
              color: AppTheme.reportColors[0],
              onTap: () {
                Get.to(() => Hadiths(), arguments: curriculumController.data);
              },
            ),
            SizedBox(height: AppTheme.spacingMedium),
            
            // كرت تحفة الأطفال
            _buildCurriculumCard(
              title: 'تحفة الأطفال',
              subtitle: 'منظومة في أحكام التجويد',
              icon: Icons.auto_stories,
              color: AppTheme.reportColors[0],
              onTap: () {
                Get.to(() => TuhfatAlAtfal(), arguments: curriculumController.data);
              },
            ),
            SizedBox(height: AppTheme.spacingMedium),
            
            // كرت المأثورات
            _buildCurriculumCard(
              title: 'المأثورات',
              subtitle: 'الأذكار والأدعية المأثورة',
              icon: Icons.bookmark,
              color: AppTheme.reportColors[0],
              onTap: () {
                Get.to(() => Mathurat(), arguments: curriculumController.data);
              },
            ),
            SizedBox(height: AppTheme.spacingMedium),

            // كرت المأثورات
            _buildCurriculumCard(
              title: 'الاداب',
              subtitle: 'الاداب العامه ',
              icon: Icons.book,
              color: AppTheme.reportColors[0],
              onTap: () {
                Get.to(() => Adab(), arguments: curriculumController.data);
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSectionHeader() {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacingMedium),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withOpacity(0.1),
            AppTheme.primaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppTheme.spacingSmall),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: Icon(
              Icons.school,
              color: AppTheme.primaryColor,
              size: AppTheme.iconMedium,
            ),
          ),
          SizedBox(width: AppTheme.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'أقسام المنهج',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'اختر القسم المناسب للاطلاع على المحتوى',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCurriculumCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      child: Container(
        padding: EdgeInsets.all(AppTheme.spacingLarge),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey[50]!,
            ],
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // أيقونة القسم
            Container(
              padding: EdgeInsets.all(AppTheme.spacingMedium),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.2),
                    color.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                border: Border.all(
                  color: color.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                size: AppTheme.iconLarge,
                color: color,
              ),
            ),
            SizedBox(width: AppTheme.spacingLarge),
            
            // معلومات القسم
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  SizedBox(height: AppTheme.spacingXSmall),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            
            // سهم الانتقال
            Container(
              padding: EdgeInsets.all(AppTheme.spacingSmall),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CurriculumController extends GetxController{
  var data;
  @override
  void onInit() {
    data=Get.arguments;

  }


}