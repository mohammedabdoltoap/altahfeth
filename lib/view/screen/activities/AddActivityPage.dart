import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../controller/AddActivityController.dart';

class AddActivityPage extends StatelessWidget {
  final Color primaryColor = const Color(0xFF008080);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddActivityController());
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'إضافة نشاط',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: Obx(() {
        // مؤشر تحميل أثناء جلب البيانات
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: primaryColor),
                const SizedBox(height: 16),
                const Text(
                  'جاري تحميل البيانات...',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // بطاقة معلومات
              _buildInfoCard(theme),
              const SizedBox(height: 20),

              // نوع النشاط
              _buildSectionTitle('نوع النشاط *', theme),
              const SizedBox(height: 8),
              Obx(() => _buildActivityDropdown(controller, theme)),
              const SizedBox(height: 20),

              // الحلقة
              _buildSectionTitle('الحلقة', theme),
              const SizedBox(height: 8),
              _buildCircleInfoCard(controller, theme),
              const SizedBox(height: 20),

              // التاريخ
              _buildSectionTitle('تاريخ النشاط *', theme),
              const SizedBox(height: 8),
              Obx(() => _buildDatePicker(controller, context, theme)),
              const SizedBox(height: 20),

              // عدد المشاركين
              _buildSectionTitle('عدد المشاركين', theme),
              const SizedBox(height: 8),
              _buildTextField(
                controller: controller.participantsController,
                hint: 'أدخل عدد المشاركين',
                icon: Icons.people,
                keyboardType: TextInputType.number,
                theme: theme,
              ),
              const SizedBox(height: 20),

              // الهدف
              _buildSectionTitle('هدف النشاط', theme),
              const SizedBox(height: 8),
              _buildTextField(
                controller: controller.goalController,
                hint: 'أدخل هدف النشاط',
                icon: Icons.flag,
                maxLines: 2,
                theme: theme,
              ),
              const SizedBox(height: 20),

              // نسبة تحقيق الهدف
              _buildSectionTitle('نسبة تحقيق الهدف (%)', theme),
              const SizedBox(height: 8),
              _buildTextField(
                controller: controller.achievementController,
                hint: 'أدخل النسبة (0-100)',
                icon: Icons.percent,
                keyboardType: TextInputType.number,
                theme: theme,
              ),
              const SizedBox(height: 20),

              // ملاحظات
              _buildSectionTitle('ملاحظات', theme),
              const SizedBox(height: 8),
              _buildTextField(
                controller: controller.notesController,
                hint: 'أدخل ملاحظات إضافية',
                icon: Icons.note,
                maxLines: 4,
                theme: theme,
              ),
              const SizedBox(height: 30),

              // زر الحفظ
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: controller.isSaving.value
                      ? null
                      : controller.saveActivity,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  icon: const Icon(Icons.save, size: 24),
                  label: const Text(
                    'حفظ النشاط',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildInfoCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor.withOpacity(0.1), primaryColor.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.info_outline, color: primaryColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تسجيل نشاط جديد',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'قم بتعبئة البيانات المطلوبة لتسجيل النشاط',
                  style: TextStyle(
                    fontSize: 13,
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

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: Colors.grey[700],
      ),
    );
  }

  Widget _buildActivityDropdown(AddActivityController controller, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonFormField<int>(
        value: controller.selectedActivityId.value,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.category, color: primaryColor),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          hintText: 'اختر نوع النشاط',
        ),
        items: controller.activities.map((activity) {
          return DropdownMenuItem<int>(
            value: activity['id_activity'],
            child: Text(activity['name_activity']),
          );
        }).toList(),
        onChanged: (value) {
          controller.selectedActivityId.value = value;
        },
      ),
    );
  }

  Widget _buildCircleInfoCard(AddActivityController controller, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.group, color: primaryColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الحلقة المختارة',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  controller.circleName ?? 'غير محدد',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker(AddActivityController controller, BuildContext context, ThemeData theme) {
    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: controller.selectedDate.value ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: primaryColor,
                  onPrimary: Colors.white,
                  onSurface: Colors.black,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          controller.selectedDate.value = picked;
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: primaryColor),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                controller.selectedDate.value != null
                    ? DateFormat('yyyy-MM-dd', 'en').format(controller.selectedDate.value!)
                    : 'اختر التاريخ',
                style: TextStyle(
                  fontSize: 16,
                  color: controller.selectedDate.value != null
                      ? Colors.black87
                      : Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required ThemeData theme,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: primaryColor),
        hintText: hint,
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
