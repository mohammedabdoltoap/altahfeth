import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'color.dart';
import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final String message;
  final double size;

  const LoadingWidget({
    this.message = "جاري التحميل...",
    this.size = 140,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: size,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // مهم لمنع overflow
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.teal.shade400),
                strokeWidth: 6,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.teal.shade100,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.none,
              ),
            ),

          ],
        ),
      ),
    );
  }
}

void showLoading({String message = "تحميل..."}) {
  if (!(Get.isDialogOpen ?? false)) {
    Get.dialog(
      WillPopScope(
        onWillPop: () async => true, // 🔒 يمنع الإغلاق بزر الرجوع
        child: LoadingWidget(message: message),
      ),
      barrierDismissible: false, // يمنع الإغلاق بالضغط خارج المربع
    );
  }
}


void hideLoading() {
  if (Get.isDialogOpen ?? false) {
    Get.back();
  }
}
