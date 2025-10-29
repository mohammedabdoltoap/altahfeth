import 'package:althfeth/constants/appButton.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ErrorRetryWidget extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onRetry;
  final Color iconColor;
  final IconData icon;

  const ErrorRetryWidget({

    required this.onRetry,
    this.title = "فشل تحميل البيانات",
    this.message = "تحقق من اتصالك بالإنترنت وحاول مرة أخرى",
    this.icon = Icons.wifi_off_rounded,
    this.iconColor = const Color(0xFFFFA726), // لون برتقالي افتراضي

  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 100,
            color: iconColor,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text("إعادة المحاولة"),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
