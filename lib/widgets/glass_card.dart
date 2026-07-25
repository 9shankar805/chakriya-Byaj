import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'pro_widgets.dart';

// Re-export ProCard as AppCard for backward compatibility
typedef AppCard = ProCard;

// Keep old API usable — all new code should prefer ProCard directly
class LegacyAppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final Color? color;
  final Color? borderColor;
  final List<BoxShadow>? shadows;
  final Gradient? gradient;

  const LegacyAppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.radius = 16,
    this.color,
    this.borderColor,
    this.shadows,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? context.cSurface) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor ?? context.cBorder),
        boxShadow: shadows ?? context.cardShadow,
      ),
      child: child,
    );
  }
}
