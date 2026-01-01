import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/app_theme.dart';
import '../../../constants/function.dart';
import '../../../constants/inline_loading.dart';
import '../../../controller/EditEmployeeProfileController.dart';

class EditEmployeeProfile extends StatelessWidget {
  final EditEmployeeProfileController controller = Get.put(EditEmployeeProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "تعديل البيانات الشخصية",
          style: AppTheme.headingMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryColor,
                AppTheme.primaryColor.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.backgroundColor,
              Colors.white,
              AppTheme.backgroundColor.withOpacity(0.3),
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
        child: Obx(() {
          if (controller.isLoading.value) {
            return const InlineLoading(message: "جاري تحميل البيانات...");
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // بطاقة معلومات المستخدم
                _buildUserInfoCard(),
                
                const SizedBox(height: AppTheme.spacingLarge),
                
                // نموذج التعديل
                _buildEditForm(),
                
                const SizedBox(height: AppTheme.spacingXLarge),
                
                // زر الحفظ
                _buildSaveButton(),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildUserInfoCard() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withOpacity(0.1),
            AppTheme.primaryColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: AppTheme.spacingLarge),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "تعديل بياناتك الشخصية",
                  style: AppTheme.headingMedium.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXSmall),
                Text(
                  "يمكنك تحديث الاسم والبريد الإلكتروني",
                  style: AppTheme.bodyMedium.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان القسم
          _buildSectionHeader(
            "البيانات الشخصية",
            Icons.edit_outlined,
            AppTheme.reportColors[0],
          ),
          
          const SizedBox(height: AppTheme.spacingLarge),
          
          // حقل الاسم
          _buildTextField(
            label: "الاسم الكامل",
            icon: Icons.person_outline,
            controller: controller.nameController,
            hint: "أدخل اسمك الكامل",
          ),
          const SizedBox(height: AppTheme.spacingLarge),

          _buildTextField(
            label: "كلمة السر",
            icon: Icons.password,
            controller: controller.password,
            hint: "أدخل كلمة السر",
          ),

          const SizedBox(height: AppTheme.spacingLarge),
          
          // حقل البريد الإلكتروني
          _buildTextField(
            label: "البريد الإلكتروني",
            icon: Icons.email_outlined,
            controller: controller.emailController,
            hint: "أدخل بريدك الإلكتروني",
            keyboardType: TextInputType.emailAddress,
          ),
          
          const SizedBox(height: AppTheme.spacingLarge),
          
          // حقل رقم الهاتف (للقراءة فقط)
          _buildTextField(
            label: "رقم الهاتف",
            icon: Icons.phone_outlined,
            controller: controller.phoneController,
            hint: "رقم الهاتف",
            keyboardType: TextInputType.number,
            // readOnly: true,
            // enabled: false,
            //
          ),
          
          const SizedBox(height: AppTheme.spacingMedium),
          

        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppTheme.spacingMedium),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(width: AppTheme.spacingMedium),
        Text(
          title,
          style: AppTheme.headingMedium.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(width: AppTheme.spacingSmall),
            Text(
              label,
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingSmall),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          enabled: enabled,
          style: AppTheme.bodyMedium.copyWith(
            color: enabled ? Colors.black87 : Colors.grey.shade600,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            filled: true,
            fillColor: enabled ? Colors.grey.shade50 : Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              borderSide: BorderSide(
                color: AppTheme.primaryColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              borderSide: BorderSide(
                color: AppTheme.primaryColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              borderSide: BorderSide(
                color: AppTheme.primaryColor,
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
                width: 1,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingLarge,
              vertical: AppTheme.spacingMedium,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Obx(() => Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          onTap: controller.isSaving.value ? null : () => controller.updateProfile(),
          child: Center(
            child: controller.isSaving.value
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: AppTheme.spacingSmall),
                      Text(
                        "حفظ التعديلات",
                        style: AppTheme.headingMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    ));
  }
}
