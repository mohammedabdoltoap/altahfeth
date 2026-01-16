import 'dart:async';
import 'package:flutter/material.dart';

import '../globals.dart';
import 'app_theme.dart';


class NewsToastWidget extends StatefulWidget {
  final VoidCallback? onDismiss;

  const NewsToastWidget({Key? key, this.onDismiss}) : super(key: key);

  @override
  State<NewsToastWidget> createState() => _NewsToastWidgetState();
}

class _NewsToastWidgetState extends State<NewsToastWidget> with SingleTickerProviderStateMixin {
  Timer? _dismissTimer;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    
    // إعداد الأنيميشن
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    // بدء أنيميشن الظهور
    _animationController.forward();

    // ضبط Timer للاختفاء بعد دقيقتين (120 ثانية)
    _dismissTimer = Timer(const Duration(minutes: 1), () {
      _hideToast();
    });
  }

  void _hideToast() async {
    if (!mounted) return;
    
    // إلغاء Timer إذا كان نشطاً
    _dismissTimer?.cancel();
    
    setState(() {
      _isVisible = false;
    });

    // أنيميشن الاختفاء
    await _animationController.reverse();
    
    // استدعاء callback الاختفاء
    if (mounted && widget.onDismiss != null) {
      widget.onDismiss!();
    }
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // إذا لم تكن هناك بيانات، لا تعرض شيء ولا تشغل مساحة
    if (dataNewsGloble.isEmpty) {
      return const SizedBox.shrink();
    }

    // إذا كان غير مرئي، لا تعرض شيء نهائياً
    if (!_isVisible) {
      return const SizedBox.shrink();
    }

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF667eea), // بنفسجي أنيق
                const Color(0xFF764ba2), // بنفسجي داكن
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF667eea).withOpacity(0.5),
                blurRadius: 15,
                offset: const Offset(0, 5),
                spreadRadius: 2,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(
              color: Colors.white.withOpacity(0.4),
              width: 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                // خلفية منقطة للتأثير البصري
                Positioned.fill(
                  child: CustomPaint(
                    painter: _DotPatternPainter(),
                  ),
                ),
                
                // المحتوى الرئيسي
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      // أيقونة الإشعار
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.4),
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.notifications_active,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      
                      const SizedBox(width: 12),
                      
                      // محتوى الأخبار
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // عنوان القسم
                            Row(
                              children: [
                                const Text(
                                  '📢 إشعارات مهمة',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${dataNewsGloble.length}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 8),
                            
                            // قائمة الأخبار
                            ...dataNewsGloble.map((news) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(top: 6),
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.white.withOpacity(0.5),
                                            blurRadius: 4,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        news['title_news'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w500,
                                          height: 1.4,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black26,
                                              offset: Offset(0, 1),
                                              blurRadius: 2,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                      
                      const SizedBox(width: 8),
                      
                      // زر الإغلاق المحسن
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _hideToast,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.4),
                                width: 1.5,
                              ),
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// فئة لرسم نمط النقاط الخلفية
class _DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    const dotRadius = 2.0;
    const spacing = 20.0;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
