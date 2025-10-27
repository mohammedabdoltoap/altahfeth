import 'package:flutter/material.dart';
import 'package:althfeth/constants/color.dart';

class InlineLoading extends StatelessWidget {
  final String message;
  final double indicatorSize;
  final double spacing;

  const InlineLoading({
    super.key,
    this.message = "جاري التحميل...",
    this.indicatorSize = 32,
    this.spacing = 14,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black.withOpacity(0.05), // خلفية شفافة خفيفة
      child: Center(
        child: AnimatedScale(
          scale: 1.0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutBack,
          child: AnimatedOpacity(
            opacity: 1.0,
            duration: const Duration(milliseconds: 500),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: indicatorSize,
                    height: indicatorSize,
                    child: CircularProgressIndicator(
                      strokeWidth: 3.2,
                      valueColor:
                      const AlwaysStoppedAnimation<Color>(kPrimaryColor),
                    ),
                  ),
                  SizedBox(height: spacing),
                  Text(
                    message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
