import 'package:flutter/material.dart';
import 'package:althfeth/constants/color.dart';

class InlineLoading extends StatelessWidget {
  final String message;
  final double indicatorSize;
  final double spacing;

  const InlineLoading({
    super.key,
    this.message = "جاري التحميل...",
    this.indicatorSize = 28,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: indicatorSize,
            height: indicatorSize,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: const AlwaysStoppedAnimation<Color>(kPrimaryColor),
            ),
          ),
          SizedBox(height: spacing),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
