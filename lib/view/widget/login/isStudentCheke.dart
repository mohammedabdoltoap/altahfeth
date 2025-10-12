import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../../controller/loginController.dart';

class IsStudentCheke extends StatelessWidget {
  LoginController loginController=Get.find();

  @override
  Widget build(BuildContext context) {
    return
      Obx(
            () => GestureDetector(
          onTap: () {
            // لما يضغط على أي مكان في الصف نغيّر القيمة
            loginController.isStudent.value = !loginController.isStudent.value;
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: loginController.isStudent.value
                  ? Colors.green.shade50
                  : Colors.grey.shade200, // خلفية خفيفة عند التفعيل
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: loginController.isStudent.value
                    ? Colors.green.shade700
                    : Colors.grey.shade400, // لون الحدود عند التفعيل
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: loginController.isStudent.value
                        ? Colors.green.shade700
                        : Colors.transparent,
                    border: Border.all(
                      color: loginController.isStudent.value
                          ? Colors.green.shade700
                          : Colors.grey.shade500,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  width: 24,
                  height: 24,
                  child: loginController.isStudent.value
                      ? const Icon(Icons.check, color: Colors.white, size: 20)
                      : null,
                ),
                const SizedBox(width: 12),
                Text(
                  "الدخول كطالب",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: loginController.isStudent.value
                        ? Colors.green.shade700
                        : Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }
}
