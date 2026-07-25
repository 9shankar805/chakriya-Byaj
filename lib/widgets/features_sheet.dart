import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/pro_widgets.dart';

/// Shows the full "All Features" modal bottom sheet.
void showFeaturesSheet({
  required BuildContext context,
  required String languageCode,
  required void Function(IconData icon) onNavigate,
}) {
  final isNepali = languageCode == 'np';
  final isHindi = languageCode == 'hi';

  String getLabel(String np, String hi, String en) {
    if (isNepali) return np;
    if (isHindi) return hi;
    return en;
  }

  final features = [
    _FItem(Icons.calculate_rounded,         AppColors.blue,    getLabel('चक्रिय ब्याज', 'चक्रवृद्धि ब्याज', 'Compound Interest')),
    _FItem(Icons.history_rounded,           AppColors.indigo,  getLabel('हिसाब इतिहास', 'इतिहास', 'History')),
    _FItem(Icons.percent_rounded,           AppColors.cyan,    getLabel('साधारण ब्याज', 'साधारण ब्याज', 'Simple Interest')),
    _FItem(Icons.account_balance_rounded,   AppColors.green,   getLabel('EMI क्याल्कुलेटर', 'ईएमआई कैलकुलेटर', 'EMI Calculator')),
    _FItem(Icons.currency_exchange_rounded, AppColors.amber,   getLabel('मुद्रा रूपान्तरण', 'मुद्रा विनिमय', 'Currency')),
    _FItem(Icons.pie_chart_rounded,         AppColors.red,     getLabel('रिपोर्ट', 'रिपोर्ट', 'Reports')),
    _FItem(Icons.terrain_rounded,           AppColors.purple,  getLabel('जग्गा क्षेत्रफल', 'भूमि क्षेत्रफल', 'Land Area')),
    _FItem(Icons.widgets_rounded,           AppColors.cyan,    getLabel('मिति विजेट', 'दिनांक विजेट', 'Date Widget')),
    _FItem(Icons.construction_rounded,      AppColors.red,     getLabel('सिभिल क्याल्कु.', 'सिविल कैलकुलेटर', 'Civil Calc')),
    _FItem(Icons.show_chart_rounded,        AppColors.green,   getLabel('नाफा नोक्सान', 'लाभ हानि', 'Profit & Loss')),
  ];

  showModalBottomSheet(
    context: context,
    backgroundColor: context.cBg,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SheetHandle(),
          const SizedBox(height: 18),
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.apps_rounded, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
            Text(
              getLabel('सबै सुविधाहरू', 'सभी सुविधाएं', 'All Features'),
              style: TextStyle(
                color: context.cText1,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ]),
          const SizedBox(height: 18),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.9,
            physics: const NeverScrollableScrollPhysics(),
            children: features.map((f) => GestureDetector(
              onTap: () {
                Navigator.pop(context);
                onNavigate(f.icon);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  color: context.cSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: f.color.withValues(alpha: 0.25)),
                  boxShadow: context.cardShadow,
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: f.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(f.icon, color: f.color, size: 22),
                  ),
                  const SizedBox(height: 8),
                  Text(f.title,
                      textAlign: TextAlign.center, maxLines: 2,
                      style: TextStyle(
                        color: context.cText1, fontSize: 11, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.green.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      getLabel('सक्रिय', 'सक्रिय', 'Active'),
                      style: const TextStyle(
                        color: AppColors.green,
                        fontSize: 9, fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ]),
              ),
            )).toList(),
          ),
        ]),
      ),
    ),
  );
}

class _FItem {
  final IconData icon;
  final Color color;
  final String title;
  const _FItem(this.icon, this.color, this.title);
}
