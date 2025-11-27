import 'package:flutter/material.dart';
import 'color.dart';

class AppTheme {
  // ========== نظام الألوان المحسن ==========
  static const Color primaryColor = kPrimaryColor;
  static const Color secondaryColor = kSecondaryColor;
  static const Color accentColor = kAccentYellow;
  static const Color backgroundColor = kBackground;
  static const Color surfaceColor = kSurfaceWhite;
  
  // ألوان إضافية للتقارير والأقسام - ألوان رسمية هادئة
  static const Color teacherSectionColor = Color(0xFFF0F8F5); // أبيض مائل للأخضر قليلاً
  static const Color studentSectionColor = Color(0xFFF5F9F7); // أبيض مائل للأخضر أفتح
  static const Color visitSectionColor = Color(0xFFF0F8F5); // أبيض مائل للأخضر قليلاً
  static const Color circleSectionColor = Color(0xFFF5F9F7); // أبيض مائل للأخضر أفتح
  
  // ألوان التقارير الفرعية - ألوان رسمية هادئة
  static final List<Color> reportColors = [
    const Color(0xFF37474F), // رمادي مزرق داكن
    const Color(0xFF455A64), // رمادي أزرق
    const Color(0xFF546E7A), // رمادي فولاذي
    const Color(0xFF607D8B), // رمادي أزرق فاتح
    const Color(0xFF78909C), // رمادي متوسط
    const Color(0xFF90A4AE), // رمادي فاتح
  ];
  
  // ========== أنماط النصوص ==========
  static const TextStyle headingLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    height: 1.2,
  );
  
  static const TextStyle headingMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    height: 1.3,
  );
  
  static const TextStyle headingSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: primaryColor,
    height: 1.3,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Color(0xFF2C2C2C),
    height: 1.4,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Color(0xFF424242),
    height: 1.4,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: Color(0xFF616161),
    height: 1.3,
  );
  
  static const TextStyle cardTitle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.bold,
    height: 1.3,
  );
  
  // ========== الظلال والتأثيرات ==========
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 12,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 6,
      offset: const Offset(0, 2),
      spreadRadius: 0,
    ),
  ];
  
  static List<BoxShadow> get sectionHeaderShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      blurRadius: 8,
      offset: const Offset(0, 3),
      spreadRadius: 0,
    ),
  ];
  
  static List<BoxShadow> cardShadowWithColor(Color color) => [
    BoxShadow(
      color: color.withOpacity(0.2),
      blurRadius: 12,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: color.withOpacity(0.1),
      blurRadius: 6,
      offset: const Offset(0, 2),
      spreadRadius: 0,
    ),
  ];
  
  // ========== التدرجات اللونية ==========
  static LinearGradient get primaryGradient => LinearGradient(
    colors: [primaryColor, primaryColor.withOpacity(0.8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static LinearGradient get backgroundGradient => LinearGradient(
    colors: [
      primaryColor.withOpacity(0.05),
      backgroundColor,
      Colors.white,
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: const [0.0, 0.3, 1.0],
  );
  
  static LinearGradient sectionGradient(Color color) => LinearGradient(
    colors: [
      color,
      color.withOpacity(0.9),
      Colors.white.withOpacity(0.95),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: const [0.0, 0.6, 1.0],
  );
  
  static LinearGradient cardGradient(Color color) => LinearGradient(
    colors: [
      Colors.white,
      Colors.white,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // ========== أنصاف الأقطار ==========
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;
  
  // ========== المسافات ==========
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 12.0;
  static const double spacingLarge = 16.0;
  static const double spacingXLarge = 20.0;
  static const double spacingXXLarge = 24.0;
  
  // ========== أحجام الأيقونات ==========
  static const double iconSmall = 20.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
  static const double iconXLarge = 40.0;
  
  // ========== الحركات والانتقالات ==========
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
  
  static const Curve animationCurve = Curves.easeInOutCubic;
}

// ========== مكونات مخصصة للتصميم ==========
class AppDecorations {
  static BoxDecoration cardDecoration({
    required Color color,
    double radius = AppTheme.radiusLarge,
  }) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: AppTheme.cardShadow,
      border: Border.all(
        color: color.withOpacity(0.2),
        width: 1.5,
      ),
    );
  }
  
  static BoxDecoration sectionHeaderDecoration({
    required Color color,
    double radius = AppTheme.radiusMedium,
  }) {
    return BoxDecoration(
      gradient: AppTheme.sectionGradient(color),
      borderRadius: BorderRadius.circular(radius),
      boxShadow: AppTheme.sectionHeaderShadow,
    );
  }
  
  static BoxDecoration iconContainerDecoration({
    required Color color,
    double radius = AppTheme.radiusMedium,
  }) {
    return BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(radius),
    );
  }
}
