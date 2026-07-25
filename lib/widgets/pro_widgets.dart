/// Professional shared UI components
library;

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PRO CARD — elevated card with optional gradient and border accent
// ─────────────────────────────────────────────────────────────────────────────
class ProCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final Color? color;
  final Gradient? gradient;
  final Color? borderColor;
  final double borderWidth;
  final List<BoxShadow>? shadows;

  const ProCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.radius = 16,
    this.color,
    this.gradient,
    this.borderColor,
    this.borderWidth = 1.0,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? context.cSurface) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: borderColor ?? context.cBorder,
          width: borderWidth,
        ),
        boxShadow: shadows ?? context.cardShadow,
      ),
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STAT TILE — icon + value + label in a card
// ─────────────────────────────────────────────────────────────────────────────
class StatTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  const StatTile({
    super.key,
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return ProCard(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: TextStyle(
            color: context.cText1,
            fontSize: 19,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: context.cText4,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION HEADER — coloured left bar + label
// ─────────────────────────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String label;
  final Color color;
  final String? sub;
  final Widget? trailing;

  const SectionHeader({
    super.key,
    required this.label,
    required this.color,
    this.sub,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 3, height: 18,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
      ),
      const SizedBox(width: 10),
      Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.1,
        ),
      ),
      if (sub != null) ...[
        const SizedBox(width: 6),
        Text(sub!, style: TextStyle(color: context.cText4, fontSize: 12)),
      ],
      if (trailing != null) ...[const Spacer(), trailing!],
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SUMMARY ROW — icon chip + label + value inside a card
// ─────────────────────────────────────────────────────────────────────────────
class SummaryRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final bool isLast;

  const SummaryRow({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: color, size: 17),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: context.cText3, fontSize: 13),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: context.cText1,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ]),
      ),
      if (!isLast)
        Divider(color: context.cBorder, height: 1, indent: 16, endIndent: 16),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RESULT TILE — accent-coloured tinted box for secondary results
// ─────────────────────────────────────────────────────────────────────────────
class ResultTile extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;

  const ResultTile({
    super.key,
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: accent,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: context.cText1,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HERO TOTAL CARD — full-width gradient card with large amount
// ─────────────────────────────────────────────────────────────────────────────
class HeroTotalCard extends StatelessWidget {
  final String title;
  final String amount;
  final String subtitle;
  final Gradient gradient;
  final List<BoxShadow>? shadows;
  final IconData? icon;

  const HeroTotalCard({
    super.key,
    required this.title,
    required this.amount,
    required this.subtitle,
    required this.gradient,
    this.shadows,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: shadows ?? AppTheme.greenShadow,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(
            icon ?? Icons.account_balance_rounded,
            color: Colors.white70, size: 15,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ]),
        const SizedBox(height: 10),
        Text(
          amount,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 38,
            fontWeight: FontWeight.w900,
            letterSpacing: -1.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(color: Colors.white60, fontSize: 12),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PRO BUTTON — pill-shaped action button
// ─────────────────────────────────────────────────────────────────────────────
class ProButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback? onPressed;
  final double height;

  const ProButton({
    super.key,
    required this.label,
    required this.icon,
    required this.gradient,
    this.onPressed,
    this.height = 54,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: onPressed == null
              ? const LinearGradient(colors: [Color(0xFF94A3B8), Color(0xFF64748B)])
              : gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: onPressed == null
              ? []
              : [
                  BoxShadow(
                    color: (gradient as LinearGradient).colors.first.withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 21),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ERROR BANNER — styled error box
// ─────────────────────────────────────────────────────────────────────────────
class ErrorBanner extends StatelessWidget {
  final String message;

  const ErrorBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.red.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.red, size: 17),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.red,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BOTTOM SHEET HANDLE — drag indicator pill
// ─────────────────────────────────────────────────────────────────────────────
class SheetHandle extends StatelessWidget {
  const SheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40, height: 4,
        decoration: BoxDecoration(
          color: context.cBorderMid,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CHIP BADGE — small tinted label
// ─────────────────────────────────────────────────────────────────────────────
class ChipBadge extends StatelessWidget {
  final String label;
  final Color color;

  const ChipBadge({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ICON BUTTON PILL — small pill-shaped icon button
// ─────────────────────────────────────────────────────────────────────────────
class IconPillButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  const IconPillButton({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: context.cSurface2,
          borderRadius: BorderRadius.circular(20),
        ),
        child: child,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SQUARE ICON BUTTON — small square icon button
// ─────────────────────────────────────────────────────────────────────────────
class SquareIconButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double size;

  const SquareIconButton({
    super.key,
    required this.child,
    this.onTap,
    this.size = 38,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(
          color: context.cSurface2,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(child: child),
      ),
    );
  }
}
