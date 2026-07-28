import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'app_hero_header.dart';

class _NavItem {
  final IconData icon;
  final Color color;
  final String labelNP;
  final String labelEN;
  final String labelHI;
  final HeroScreen screen;
  const _NavItem(this.icon, this.color, this.labelNP, this.labelEN, this.labelHI, this.screen);
}

const _kNavItems = [
  _NavItem(Icons.calculate_rounded,         AppColors.blue,   'चक्रिय ब्याज',     'Compound Interest', 'चक्रवृद्धि ब्याज',  HeroScreen.compound),
  _NavItem(Icons.percent_rounded,           AppColors.indigo, 'साधारण ब्याज',     'Simple Interest',   'साधारण ब्याज',      HeroScreen.simple),
  _NavItem(Icons.account_balance_rounded,   AppColors.cyan,   'EMI क्याल्कुलेटर', 'EMI Calculator',    'ईएमआई कैलकुलेटर',  HeroScreen.emi),
  _NavItem(Icons.show_chart_rounded,        AppColors.green,  'नाफा नोक्सान',     'Profit & Loss',     'लाभ हानि',          HeroScreen.other),
  _NavItem(Icons.history_rounded,           AppColors.purple, 'हिसाब इतिहास',     'History',           'इतिहास',            HeroScreen.history),
  _NavItem(Icons.terrain_rounded,           AppColors.teal,   'जग्गा क्षेत्रफल',  'Land Area',         'भूमि क्षेत्रफल',   HeroScreen.land),
  _NavItem(Icons.currency_exchange_rounded, AppColors.amber,  'मुद्रा रूपान्तरण', 'Currency',          'मुद्रा विनिमय',     HeroScreen.currency),
  _NavItem(Icons.pie_chart_rounded,         AppColors.red,    'रिपोर्ट',           'Reports',           'रिपोर्ट',           HeroScreen.report),
  _NavItem(Icons.widgets_rounded,           AppColors.orange, 'मिति विजेट',        'Date Widget',       'दिनांक विजेट',      HeroScreen.widget),
];

/// Opens the right-side app drawer as an overlay.
void showAppDrawer({
  required BuildContext context,
  required String languageCode,
  required HeroScreen activeScreen,
  required void Function(HeroScreen) onNavigate,
}) {
  Navigator.of(context).push(_DrawerRoute(
    languageCode: languageCode,
    activeScreen: activeScreen,
    onNavigate: onNavigate,
  ));
}

// ── Custom page route — slides in from right ──────────────────────────────────
class _DrawerRoute extends PageRoute<void> {
  final String languageCode;
  final HeroScreen activeScreen;
  final void Function(HeroScreen) onNavigate;

  _DrawerRoute({
    required this.languageCode,
    required this.activeScreen,
    required this.onNavigate,
  });

  @override bool get opaque => false;
  @override bool get barrierDismissible => true;
  @override Color get barrierColor => Colors.black54;
  @override String? get barrierLabel => 'Dismiss';
  @override Duration get transitionDuration => const Duration(milliseconds: 260);
  @override bool get maintainState => true;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return _AppDrawer(
      animation: animation,
      languageCode: languageCode,
      activeScreen: activeScreen,
      onNavigate: (screen) {
        Navigator.of(context).pop();
        onNavigate(screen);
      },
      onClose: () => Navigator.of(context).pop(),
    );
  }
}

// ── Drawer widget ─────────────────────────────────────────────────────────────
class _AppDrawer extends StatelessWidget {
  final Animation<double> animation;
  final String languageCode;
  final HeroScreen activeScreen;
  final void Function(HeroScreen) onNavigate;
  final VoidCallback onClose;

  const _AppDrawer({
    required this.animation,
    required this.languageCode,
    required this.activeScreen,
    required this.onNavigate,
    required this.onClose,
  });

  bool get _isNepali => languageCode == 'np';
  bool get _isHindi  => languageCode == 'hi';

  String _label(_NavItem item) {
    if (_isNepali) return item.labelNP;
    if (_isHindi)  return item.labelHI;
    return item.labelEN;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final slideAnim = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

    return GestureDetector(
      onTap: onClose,
      behavior: HitTestBehavior.opaque,
      child: Align(
        alignment: Alignment.centerRight,
        child: GestureDetector(
          onTap: () {},
          child: SlideTransition(
            position: slideAnim,
            child: Material(
              color: isDark ? const Color(0xFF0F1629) : Colors.white,
              elevation: 16,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.72,
                height: double.infinity,
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Header ───────────────────────────────────────
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(20, 20, 16, 20),
                        decoration: const BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                        ),
                        child: Row(children: [
                          Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Image.asset('assets/app_logo.jpeg', fit: BoxFit.cover),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _isNepali ? 'चक्रिय ब्याज' : _isHindi ? 'चक्रवृद्धि ब्याज' : 'Chakriya Byaj',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  'Tech Procod PVT LTD',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.70),
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: onClose,
                            child: Container(
                              width: 32, height: 32,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
                            ),
                          ),
                        ]),
                      ),

                      // ── Nav items ─────────────────────────────────────
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          itemCount: _kNavItems.length,
                          itemBuilder: (ctx, i) {
                            final item     = _kNavItems[i];
                            final isActive = item.screen == activeScreen;
                            return _NavTile(
                              item: item,
                              label: _label(item),
                              isActive: isActive,
                              isDark: isDark,
                              onTap: () => onNavigate(item.screen),
                            );
                          },
                        ),
                      ),

                      // ── Footer ────────────────────────────────────────
                      Container(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: isDark
                                  ? const Color(0xFF1E2A45)
                                  : const Color(0xFFE8EDF8),
                            ),
                          ),
                        ),
                        child: Row(children: [
                          Icon(Icons.phone_outlined,
                              color: isDark ? AppColors.dText4 : AppColors.lText4,
                              size: 13),
                          const SizedBox(width: 6),
                          Text(
                            '+977 9805916598',
                            style: TextStyle(
                              color: isDark ? AppColors.dText3 : AppColors.lText3,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ]),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Single nav tile ───────────────────────────────────────────────────────────
class _NavTile extends StatelessWidget {
  final _NavItem item;
  final String label;
  final bool isActive;
  final bool isDark;
  final VoidCallback onTap;

  const _NavTile({
    required this.item,
    required this.label,
    required this.isActive,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? item.color.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: isActive
              ? Border.all(color: item.color.withValues(alpha: 0.30), width: 1.2)
              : null,
        ),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: isActive ? 0.18 : 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.icon, color: item.color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: isActive
                    ? item.color
                    : isDark ? AppColors.dText1 : AppColors.lText1,
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          if (isActive)
            Container(
              width: 6, height: 6,
              decoration: BoxDecoration(
                color: item.color,
                shape: BoxShape.circle,
              ),
            ),
        ]),
      ),
    );
  }
}
