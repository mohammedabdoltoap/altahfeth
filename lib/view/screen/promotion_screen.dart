import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/promotion_controller.dart';
import 'package:althfeth/constants/function.dart';
import 'package:althfeth/globals.dart';
import 'package:althfeth/view/screen/login.dart';
import 'package:althfeth/view/screen/teacherScreen/TeacherResignationPage.dart';
import 'promotion_pending.dart';

class PromotionScreen extends StatelessWidget {
  final Color primaryTeal = const Color(0xFF008080);
  final Color lightTeal = const Color(0xFF66CCCC);


  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PromotionController());
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'نموذج الترفيع الإلكتروني',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryTeal,
        elevation: 0,
      ),
      drawer: _PromotionDrawer(),
      body: Obx(() => Stepper(
              type: StepperType.vertical,
              currentStep: controller.currentStep.value,
              onStepContinue: controller.canContinue(controller.currentStep.value)
                  ? controller.nextStep
                  : null,
              onStepCancel:
                  controller.currentStep.value > 0 ? controller.previousStep : null,
              controlsBuilder: (context, details) {
                return Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Row(
                    children: [
                      if (details.stepIndex > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: details.onStepCancel,
                            style: OutlinedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('السابق'),
                          ),
                        ),
                      if (details.stepIndex > 0) const SizedBox(width: 12),
                      if (details.stepIndex < 5)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: controller
                                    .canContinue(controller.currentStep.value)
                                ? details.onStepContinue
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryTeal,
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                              disabledBackgroundColor: Colors.grey[300],
                            ),
                            child: const Text('التالي'),
                          ),
                        ),
                    ],
                  ),
                );
              },
              steps: [
                Step(
                  title: const Text(
                    'اختيار المركز',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: controller.selectedCenterName.value != null
                      ? Text(
                          'المحدد: ${controller.selectedCenterName.value}',
                          style: TextStyle(
                              color: primaryTeal,
                              fontWeight: FontWeight.w600),
                        )
                      : null,
                  content: _SearchableSelector(
                    label: 'المركز',
                    valueText: controller.selectedCenterName.value ?? '',
                    color: primaryTeal,
                    onSelect: () async {
                      final selected = await _openSearchPicker(
                        context: context,
                        title: 'اختر مركز',
                        color: primaryTeal,
                        items: controller.centers
                            .map((e) => {
                                  'id': e['center_id'] as int,
                                  'label': e['name']?.toString() ?? ''
                                })
                            .toList(),
                        selectedId: controller.selectedCenterId.value,
                      );
                      if (selected != null) {
                        controller.fetchCirclesForCenter(selected['id'] as int);
                      }
                    },
                  ),
                  isActive: controller.currentStep.value >= 0,
                  state: controller.currentStep.value > 0
                      ? StepState.complete
                      : (controller.currentStep.value == 0
                          ? StepState.indexed
                          : StepState.disabled),
                ),
                Step(
                  title: const Text(
                    'اختيار الحلقة',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: controller.selectedCircleName.value != null
                      ? Text(
                          'المحددة: ${controller.selectedCircleName.value}',
                          style: TextStyle(
                              color: primaryTeal,
                              fontWeight: FontWeight.w600),
                        )
                      : null,
                  content: _SearchableSelector(
                    label: 'الحلقة',
                    valueText: controller.selectedCircleName.value ?? '',
                    color: primaryTeal,
                    onSelect: () async {
                      final selected = await _openSearchPicker(
                        context: context,
                        title: 'اختر حلقة',
                        color: primaryTeal,
                        items: controller.circles
                            .map((e) => {
                                  'id': e['id_circle'] as int,
                                  'label': e['name_circle']?.toString() ?? ''
                                })
                            .toList(),
                        selectedId: controller.selectedCircleId.value,
                      );
                      if (selected != null) {
                        final circle = controller.circles.firstWhere(
                            (e) => e['id_circle'] == selected['id']);
                        controller.selectCircle(circle);
                      }
                    },
                  ),
                  isActive: controller.currentStep.value >= 1,
                  state: controller.currentStep.value > 1
                      ? StepState.complete
                      : (controller.currentStep.value == 1
                          ? StepState.indexed
                          : StepState.disabled),
                ),
                Step(
                  title: const Text(
                    'اختيار الطالب',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: controller.selectedStudentName.value != null
                      ? Text(
                          'المحدد: ${controller.selectedStudentName.value}',
                          style: TextStyle(
                              color: primaryTeal,
                              fontWeight: FontWeight.w600),
                        )
                      : null,
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _SearchableSelector(
                        label: 'الطالب',
                        valueText: controller.selectedStudentName.value ?? '',
                        color: primaryTeal,
                        onSelect: () async {
                          final selected = await _openSearchPicker(
                            context: context,
                            title: 'اختر طالب',
                            color: primaryTeal,
                            items: controller.students
                                .map((e) => {
                                      'id': e['id_student'] as int,
                                      'label': e['name_student']?.toString() ?? ''
                                    })
                                .toList(),
                            selectedId: controller.selectedStudentId.value,
                          );
                          if (selected != null) {
                            final id = selected['id'] as int;
                            controller.selectedStudentId.value = id;
                            final match = controller.students
                                .firstWhereOrNull((e) => e['id_student'] == id);
                            controller.selectedStudentName.value =
                                match != null ? match['name_student'] : null;
                          }
                        },
                      ),
                      if (controller.selectedStudentId.value != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: primaryTeal.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: primaryTeal.withOpacity(0.2)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.info_outline, color: primaryTeal, size: 20),
                                  const SizedBox(width: 8),
                                  Text('معلومات الطالب', style: TextStyle(color: primaryTeal, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _buildSummaryRow('المرحلة', controller.selectedStudentStageName ?? '-'),
                              _buildSummaryRow('المستوى', controller.selectedStudentLevelName ?? '-'),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  isActive: controller.currentStep.value >= 2,
                  state: controller.currentStep.value > 2
                      ? StepState.complete
                      : (controller.currentStep.value == 2
                          ? StepState.indexed
                          : StepState.disabled),
                ),
                Step(
                  title: const Text(
                    'إدخال الدرجات',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: controller.gradeControllers.values
                          .any((c) => c.text.isNotEmpty)
                      ? Text(
                          'المجموع: ${controller.calculateTotal()} / ${controller.subjects.fold<int>(0, (sum, s) => sum + (s['MaxGrade'] as int))}',
                          style: TextStyle(
                              color: primaryTeal,
                              fontWeight: FontWeight.w600),
                        )
                      : null,
                  content: Column(
                    children: [
                      ...controller.subjects.map((subject) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: TextFormField(
                              controller:
                                  controller.gradeControllers[subject['SubjectID'] as int],
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              decoration: _decoration(subject['SubjectName']?.toString() ?? '', primaryTeal).copyWith(
                                hintText:
                                    'أدخل الدرجة (حد أقصى ${subject['MaxGrade']})',
                                prefixIcon:
                                    Icon(Icons.grade, color: primaryTeal),
                                suffixText:
                                    '/ ${subject['MaxGrade']}',
                              ),
                              onChanged: (val) {
                                final value = double.tryParse(val);
                                if (value != null &&
                                    value > (subject['MaxGrade'] as num).toDouble()) {
                                  controller.gradeControllers[subject['SubjectID'] as int]!.text =
                                      (subject['MaxGrade'] as int).toString();
                                }
                                controller.currentStep.refresh();
                              },
                            ),
                          )),
                      if (controller.gradeControllers.values
                          .any((c) => c.text.isNotEmpty)) ...[
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                primaryTeal.withOpacity(0.1),
                                lightTeal.withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: primaryTeal.withOpacity(0.3)),
                          ),
                          child: Column(
                            children: [
                              _buildStatCard(
                                'المجموع',
                                '${controller.calculateTotal()}',
                                'من ${controller.subjects.fold<int>(0, (sum, s) => sum + (s['MaxGrade'] as int))}',
                                Icons.summarize,
                                primaryTeal,
                              ),
                              const SizedBox(height: 16),
                              _buildStatCard(
                                'المعدل',
                                '${controller.calculateAverage().toStringAsFixed(2)}%',
                                controller.calculateGrade(
                                    controller.calculateAverage()),
                                Icons.percent,
                                _getGradeColor(controller.calculateAverage()),
                              ),
                            ],
                          ),
                        ),
                       
                      ],
                    ],
                  ),
                  isActive: controller.currentStep.value >= 3,
                  state: controller.currentStep.value > 3
                      ? StepState.complete
                      : (controller.currentStep.value == 3
                          ? StepState.indexed
                          : StepState.disabled),
                ),
                Step(
                  title: const Text(
                    'لجنة الترفيع',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: (controller.selectedCommitteeIds.length + 1) > 0
                      ? Text(
                          '${controller.selectedCommitteeIds.length + 1} عضو محدد',
                          style: TextStyle(
                              color: primaryTeal,
                              fontWeight: FontWeight.w600),
                        )
                      : null,
                  content: _MultiSelectSelector(
                    label: 'أعضاء اللجنة',
                    valueText: controller.selectedCommitteeIds.isEmpty
                        ? ''
                        : '${controller.selectedCommitteeIds.length} مختار',
                    color: primaryTeal,
                    onSelect: () async {
                      final selected = await _openMultiSelectPicker(
                        context: context,
                        title: 'اختر أعضاء اللجنة',
                        color: primaryTeal,
                        items: controller.committeeMembers
                            .map((e) => {
                                  'id': e['id_user'] as int,
                                  'label': e['username']?.toString() ?? ''
                                })
                            .toList(),
                        selectedIds: controller.selectedCommitteeIds.toSet(),
                      );
                      if (selected != null) {
                        controller.selectedCommitteeIds.assignAll(selected);
                      }
                    },
                  ),
                  isActive: controller.currentStep.value >= 4,
                  state: controller.currentStep.value > 4
                      ? StepState.complete
                      : (controller.currentStep.value == 4
                          ? StepState.indexed
                          : StepState.disabled),
                ),
                Step(
                  title: const Text(
                    'تأكيد الترفيع',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  content: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: primaryTeal.withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ملخص البيانات',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: primaryTeal,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildSummaryRow('الحلقة',
                                controller.selectedCircleName.value ?? '-'),
                            _buildSummaryRow('الطالب',
                                controller.selectedStudentName.value ?? '-'),
                            _buildSummaryRow('رئيس اللجنة', controller.currentUserName ?? '-'),
                            _buildSummaryRow('أعضاء اللجنة', (controller.selectedCommitteeNames.isEmpty
                                    ? '-'
                                    : controller.selectedCommitteeNames.join('، '))),
                            _buildSummaryRow(
                                'المعدل',
                                '${controller.calculateAverage().toStringAsFixed(2)}%'),
                            _buildSummaryRow(
                                'التقدير',
                                controller.calculateGrade(
                                    controller.calculateAverage())),
                            _buildSummaryRow('عدد أعضاء اللجنة',
                                '${controller.selectedCommitteeIds.length + 1}'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed:
                              controller.canContinue(4) ? controller.submitPromotion : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryTeal,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey[300],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          icon: const Icon(Icons.save, size: 24),
                          label: const Text(
                            'تأكيد الترفيع',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                  isActive: controller.currentStep.value >= 5,
                  state: StepState.complete,
                ),
              ],
            )),
    );
  }

  InputDecoration _decoration(String label, Color color) {
    return InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: 2),
      ),
      labelText: label,
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Color _getGradeColor(double avg) {
    if (avg >= 90) return Colors.green;
    if (avg >= 75) return Colors.blue;
    if (avg >= 60) return Colors.orange;
    return Colors.red;
  }

  Widget _buildStatCard(
      String title, String value, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
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

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 7,
            child: Text(
              value,
              softWrap: true,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: primaryTeal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _PromotionDrawer extends StatelessWidget {
  final PromotionController controller =Get.find();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Drawer(
      child: SafeArea(
        child: Container(
          color: theme.colorScheme.surface,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _buildDrawerHeader(theme),
              const SizedBox(height: 8),

              _buildSectionTitle("الإجراءات", theme),
              _drawerItem(
                icon: Icons.history_rounded,
                text: "الترفيعات المعلقة",
                onTap: () {
                  Get.back();
                  Get.to(() =>  PromotionPendingScreen() );
                },
                theme: theme,
              ),
              _drawerItem(
                icon: Icons.exit_to_app_rounded,
                text: "طلب استقالة",
                onTap: () => _navigateIfNotHoliday(context, () => TeacherResignationPage()),
                theme: theme,
              ),

              const SizedBox(height: 16),
              Divider(color: theme.dividerColor, thickness: 1, height: 1),
              const SizedBox(height: 8),

              _drawerItem(
                icon: Icons.logout_rounded,
                text: "تسجيل الخروج",
                onTap: () => _handleLogout(context),
                theme: theme,
                isDestructive: true,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.8),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person_rounded,
              size: 45,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "أهلاً بك",
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "${data_user_globle["username"] ?? ''}",
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        title,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    required ThemeData theme,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : theme.colorScheme.primary,
        size: 24,
      ),
      title: Text(
        text,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: isDestructive ? Colors.red : null,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.chevron_left_rounded,
        color: theme.colorScheme.onSurface.withOpacity(0.3),
        size: 20,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      hoverColor: theme.colorScheme.primary.withOpacity(0.05),
    );
  }

  void _navigateIfNotHoliday(BuildContext context, Widget Function() pageBuilder) {
    if (holidayData["is_holiday"] == true) {
      mySnackbar("تنبيه", "إجازة بمناسبة ${holidayData["reason"]}", type: "y");
      return;
    }
    Get.back();
    Get.to(pageBuilder,arguments: data_user_globle);
  }

  Future<void> _handleLogout(BuildContext context) async {
    bool? confirm = await showConfirmDialog(
      context: context,
      title: "تسجيل الخروج",
      message: "هل أنت متأكد من رغبتك في تسجيل الخروج؟",
      yesText: "تسجيل الخروج",
      noText: "إلغاء",
    );

    if (confirm == true) {
      data_user_globle.clear();
      Get.offAll(() => Login());
      mySnackbar("تم بنجاح", "تم تسجيل الخروج بنجاح", type: "g");
    }
  }
}


class _SearchableSelector extends StatelessWidget {
  final String label;
  final String valueText;
  final Color color;
  final Future<void> Function() onSelect;

  const _SearchableSelector({
    required this.label,
    required this.valueText,
    required this.color,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey[700], fontWeight: FontWeight.w600),
          ),
        ),
        InkWell(
          onTap: onSelect,
          child: InputDecorator(
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: color, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              suffixIcon: Icon(Icons.search, color: color),
            ),
            child: Text(
              valueText.isEmpty ? 'اختر $label' : valueText,
              style: TextStyle(
                color: valueText.isEmpty ? Colors.grey[500] : Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

Future<Map<String, Object>?> _openSearchPicker({
  required BuildContext context,
  required String title,
  required Color color,
  required List<Map<String, Object>> items, // {id, label}
  int? selectedId,
}) async {
  return await showModalBottomSheet<Map<String, Object>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      String query = '';
      final controller = TextEditingController();
      final ValueNotifier<List<Map<String, Object>>> filtered =
          ValueNotifier<List<Map<String, Object>>>(items);

      void applyFilter(String q) {
        query = q.toLowerCase();
        filtered.value = items
            .where((e) => (e['label'] as String)
                .toLowerCase()
                .contains(query))
            .toList();
      }

      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: SizedBox(
          height: MediaQuery.of(ctx).size.height * 0.7,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  children: [
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
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(ctx).pop(),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    hintText: 'ابحث...',
                    prefixIcon: Icon(Icons.search, color: color),
                  ),
                  onChanged: applyFilter,
                ),
              ),
              Expanded(
                child: ValueListenableBuilder<List<Map<String, Object>>>(
                  valueListenable: filtered,
                  builder: (context, data, _) {
                    return ListView.separated(
                      itemCount: data.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = data[index];
                        final id = item['id'] as int;
                        final label = item['label'] as String;
                        final isSelected = selectedId != null && selectedId == id;
                        return ListTile(
                          title: Text(label),
                          trailing: isSelected
                              ? Icon(Icons.check, color: color)
                              : null,
                          onTap: () => Navigator.of(context).pop(item),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _MultiSelectSelector extends StatelessWidget {
  final String label;
  final String valueText;
  final Color color;
  final Future<void> Function() onSelect;

  const _MultiSelectSelector({
    required this.label,
    required this.valueText,
    required this.color,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey[700], fontWeight: FontWeight.w600),
          ),
        ),
        InkWell(
          onTap: onSelect,
          child: InputDecorator(
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: color, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              suffixIcon: Icon(Icons.group_add, color: color),
            ),
            child: Text(
              valueText.isEmpty ? 'اختر $label' : valueText,
              style: TextStyle(
                color: valueText.isEmpty ? Colors.grey[500] : Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

Future<Set<int>?> _openMultiSelectPicker({
  required BuildContext context,
  required String title,
  required Color color,
  required List<Map<String, Object>> items, // {id, label}
  required Set<int> selectedIds,
}) async {
  final currentSelected = Set<int>.from(selectedIds);
  return await showModalBottomSheet<Set<int>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      String query = '';
      final searchController = TextEditingController();
      final ValueNotifier<List<Map<String, Object>>> filtered =
          ValueNotifier<List<Map<String, Object>>>(items);

      void applyFilter(String q) {
        query = q.toLowerCase();
        filtered.value = items
            .where((e) => (e['label'] as String)
                .toLowerCase()
                .contains(query))
            .toList();
      }

      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: SizedBox(
          height: MediaQuery.of(ctx).size.height * 0.8,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  children: [
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
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(ctx).pop(),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    hintText: 'ابحث...',
                    prefixIcon: Icon(Icons.search, color: color),
                  ),
                  onChanged: applyFilter,
                ),
              ),
              Expanded(
                child: ValueListenableBuilder<List<Map<String, Object>>>(
                  valueListenable: filtered,
                  builder: (context, data, _) {
                    return ListView.separated(
                      itemCount: data.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = data[index];
                        final id = item['id'] as int;
                        final label = item['label'] as String;
                        final isSelected = currentSelected.contains(id);
                        return CheckboxListTile(
                          title: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          value: isSelected,
                          activeColor: color,
                          onChanged: (val) {
                            if (val == true) {
                              currentSelected.add(id);
                            } else {
                              currentSelected.remove(id);
                            }
                            // trigger rebuild
                            filtered.value = List<Map<String, Object>>.from(filtered.value);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => Navigator.of(context).pop(currentSelected),
                    child: const Text('تم'),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

