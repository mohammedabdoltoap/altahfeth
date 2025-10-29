import 'package:flutter/material.dart';

class TestVisitorDialogPage extends StatelessWidget {
  const TestVisitorDialogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("تجربة نافذة الزيارة"),
        centerTitle: true,
      ),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.person_add_alt_1_rounded),
          label: const Text("إضافة زيارة جديدة"),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            textStyle: const TextStyle(fontSize: 16),
          ),
          onPressed: () async {
            final result = await showVisitorDialog(context: context);

            if (result != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "تمت إضافة زيارة بواسطة: ${result.name}\nملاحظة: ${result.note.isEmpty ? 'لا توجد' : result.note}",
                    textDirection: TextDirection.rtl,
                  ),
                  duration: const Duration(seconds: 4),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "تم إلغاء العملية",
                    textDirection: TextDirection.rtl,
                  ),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
class VisitorResult {
  final String name;
  final String note;
  VisitorResult({required this.name, required this.note});
}

Future<VisitorResult?> showVisitorDialog({
  required BuildContext context,
  String title = "إضافة زيارة",
  String hintName = "اسم الزائر",
  String hintNote = "ملاحظة (اختياري)",
  String confirmText = "حفظ",
  String cancelText = "إلغاء",
}) {
  final _nameController = TextEditingController();
  final _noteController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  return showDialog<VisitorResult>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) {
      final theme = Theme.of(ctx);

      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person_add_alt_1, size: 60, color: theme.primaryColor),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // اسم الزائر
                TextFormField(
                  controller: _nameController,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    hintText: hintName,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                  validator: (v) => v!.trim().isEmpty ? "الرجاء إدخال اسم الزائر" : null,
                ),
                const SizedBox(height: 12),

                // ملاحظة
                TextFormField(
                  controller: _noteController,
                  textAlign: TextAlign.right,
                  minLines: 3,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: hintNote,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    prefixIcon: const Icon(Icons.note_alt_outlined),
                  ),
                ),
                const SizedBox(height: 24),

                // الأزرار
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(ctx).pop(null),
                        child: Text(cancelText),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            Navigator.of(ctx).pop(
                              VisitorResult(
                                name: _nameController.text.trim(),
                                note: _noteController.text.trim(),
                              ),
                            );
                          }
                        },
                        child: Text(confirmText),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
