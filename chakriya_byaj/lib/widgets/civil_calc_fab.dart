import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../screens/civil_calc_screen.dart';

/// Small floating action button that opens the Civil Calculator from any screen.
class CivilCalcFab extends StatelessWidget {
  final String languageCode;
  const CivilCalcFab({super.key, required this.languageCode});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 320),
          pageBuilder: (_, __, ___) => CivilCalcScreen(languageCode: languageCode),
          transitionsBuilder: (_, anim, __, child) => FadeTransition(
            opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
            child: child,
          ),
        ),
      ),
      child: Container(
        width: 48, height: 48,
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.blue.withValues(alpha: 0.40),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Icon(Icons.calculate_rounded, color: Colors.white, size: 22),
      ),
    );
  }
}
