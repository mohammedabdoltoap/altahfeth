import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'color.dart';
class LoadingWidget extends StatelessWidget {
  final RxBool isLoading;
  final String message;
  final double size;
  const LoadingWidget({
    required this.isLoading,
    this.message = "تحميل",
    this.size = 120,
  });
  @override
  Widget build(BuildContext context) {
    return Obx(() => isLoading.value
        ? Center(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 4),
            )
          ],
        ),
        child:Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(secondaryGreen),
              strokeWidth: 6,
            ),
            SizedBox(height: 15),
            Text(
              message,
              style: TextStyle(
                color: primaryGreen,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    )
        : SizedBox.shrink()
    );
  }
}
