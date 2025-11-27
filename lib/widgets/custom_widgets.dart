import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

// ========== عنوان القسم المحسن ==========
class CustomSectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String? subtitle;
  final Widget? trailing;

  const CustomSectionHeader({
    Key? key,
    required this.title,
    required this.icon,
    required this.color,
    this.subtitle,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLarge),
      decoration: AppDecorations.sectionHeaderDecoration(color: color),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingMedium),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryColor,
              size: AppTheme.iconLarge,
            ),
          ),
          const SizedBox(width: AppTheme.spacingLarge),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title, 
                  style: AppTheme.headingMedium.copyWith(
                    color: AppTheme.primaryColor,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.primaryColor.withOpacity(0.8),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// ========== بطاقة التقرير المحسنة ==========
class CustomReportCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String? subtitle;
  final bool isEnabled;
  final Widget? badge;

  const CustomReportCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
    this.subtitle,
    this.isEnabled = true,
    this.badge,
  }) : super(key: key);

  @override
  State<CustomReportCard> createState() => _CustomReportCardState();
}

class _CustomReportCardState extends State<CustomReportCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppTheme.animationFast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: AppTheme.animationCurve,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.isEnabled) {
      setState(() => _isPressed = true);
      _animationController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.isEnabled) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.isEnabled) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            onTap: widget.isEnabled ? widget.onTap : null,
            child: Container(
              decoration: AppDecorations.cardDecoration(
                color: widget.isEnabled ? widget.color : Colors.grey,
              ),
              child: Stack(
                children: [
                  // محتوى البطاقة
                  Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingLarge),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // حاوية الأيقونة
                        Container(
                          padding: const EdgeInsets.all(AppTheme.spacingMedium),
                          decoration: AppDecorations.iconContainerDecoration(
                            color: widget.isEnabled ? widget.color : Colors.grey,
                          ),
                          child: Icon(
                            widget.icon,
                            size: AppTheme.iconXLarge,
                            color: widget.isEnabled ? widget.color : Colors.grey.shade600,
                          ),
                        ),
                        
                        const SizedBox(height: AppTheme.spacingMedium),
                        
                        // العنوان
                        Text(
                          widget.title,
                          textAlign: TextAlign.center,
                          style: AppTheme.cardTitle.copyWith(
                            color: widget.isEnabled 
                                ? widget.color.withOpacity(0.9) 
                                : Colors.grey.shade600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        // العنوان الفرعي
                        if (widget.subtitle != null) ...[
                          const SizedBox(height: AppTheme.spacingXSmall),
                          Text(
                            widget.subtitle!,
                            textAlign: TextAlign.center,
                            style: AppTheme.bodySmall.copyWith(
                              color: widget.isEnabled 
                                  ? widget.color.withOpacity(0.7) 
                                  : Colors.grey.shade500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // الشارة (إذا وجدت)
                  if (widget.badge != null)
                    Positioned(
                      top: AppTheme.spacingSmall,
                      right: AppTheme.spacingSmall,
                      child: widget.badge!,
                    ),
                  
                  // تأثير عدم التفعيل
                  if (!widget.isEnabled)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ========== شبكة التقارير المحسنة ==========
class CustomReportGrid extends StatelessWidget {
  final List<CustomReportCard> cards;
  final int crossAxisCount;
  final double childAspectRatio;

  const CustomReportGrid({
    Key? key,
    required this.cards,
    this.crossAxisCount = 2,
    this.childAspectRatio = 1.1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: AppTheme.spacingMedium,
        mainAxisSpacing: AppTheme.spacingMedium,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) => cards[index],
    );
  }
}

// ========== شارة مخصصة ==========
class CustomBadge extends StatelessWidget {
  final String text;
  final Color color;
  final Color? textColor;

  const CustomBadge({
    Key? key,
    required this.text,
    required this.color,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingSmall,
        vertical: AppTheme.spacingXSmall,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      ),
      child: Text(
        text,
        style: AppTheme.bodySmall.copyWith(
          color: textColor ?? Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ========== حاوية الصفحة المحسنة ==========
class CustomPageContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const CustomPageContainer({
    Key? key,
    required this.child,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.backgroundGradient,
      ),
      child: SingleChildScrollView(
        padding: padding ?? const EdgeInsets.all(AppTheme.spacingLarge),
        child: child,
      ),
    );
  }
}

// ========== شريط التطبيق المخصص ==========
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color? backgroundColor;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.backgroundColor,
    this.actions,
    this.leading,
    this.centerTitle = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: AppBar(
        title: Text(
          title,
          style: AppTheme.headingMedium,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: centerTitle,
        actions: actions,
        leading: leading,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
