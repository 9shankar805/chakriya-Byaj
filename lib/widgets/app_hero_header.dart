import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/nepali_calendar.dart';

enum HeroScreen {
  compound, simple, emi, land, currency, history, report, widget, result, other
}

// ── 5-item strip visible in the screenshot ────────────────────────────────────
class _StripItem {
  final IconData   icon;
  final HeroScreen screen;
  final String     labelNP;
  final String     labelEN;
  const _StripItem(this.icon, this.screen, this.labelNP, this.labelEN);
}

const List<_StripItem> _kStripItems = [
  _StripItem(Icons.calculate_rounded,       HeroScreen.compound, 'चक्रिय',    'Compound'),
  _StripItem(Icons.percent_rounded,         HeroScreen.simple,   'साधारण',    'Simple'),
  _StripItem(Icons.account_balance_rounded, HeroScreen.emi,      'EMI Calc.', 'EMI Calc.'),
  _StripItem(Icons.terrain_rounded,         HeroScreen.land,     'जग्गा',     'Land Area'),
  _StripItem(Icons.history_rounded,         HeroScreen.history,  'इतिहास',    'History'),
];

class AppHeroHeader extends StatefulWidget {
  final bool isNepali;
  final String title;
  final HeroScreen activeScreen;
  final VoidCallback onLangToggle;
  final VoidCallback onGridTap;
  final VoidCallback? onBack;
  final Widget? trailing;
  final void Function(HeroScreen)? onQuickNav;
  final bool showLangToggle;
  final String? languageCode;

  const AppHeroHeader({
    super.key,
    bool? isNepali,
    String? languageCode,
    required this.title,
    required this.activeScreen,
    required this.onLangToggle,
    required this.onGridTap,
    this.onBack,
    this.trailing,
    this.onQuickNav,
    this.showLangToggle = true,
  }) : isNepali = isNepali ?? (languageCode == 'np' || languageCode == null),
       languageCode = languageCode;

  @override
  State<AppHeroHeader> createState() => _AppHeroHeaderState();
}

class _AppHeroHeaderState extends State<AppHeroHeader> {
  bool _collapsed = false;
  void _toggle() => setState(() => _collapsed = !_collapsed);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A3FCC),
        image: DecorationImage(
          image: const AssetImage('assets/Herobg.jpeg'),
          fit: BoxFit.cover,
          // Strong dark-blue tint so white text is fully legible
          colorFilter: ColorFilter.mode(
            const Color(0xFF0D2899).withValues(alpha: 0.72),
            BlendMode.srcOver,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row: logo | title+subtitle | lang | calendar | menu ─────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
            child: Row(children: [
              // App logo
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset('assets/app_logo.jpeg', fit: BoxFit.cover),
              ),
              const SizedBox(width: 12),
              // Title + subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    Text(
                      'Tech Procod PVT LTD',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.70),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.showLangToggle) ...[
                GestureDetector(
                  onTap: widget.onLangToggle,
                  child: Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.30), width: 1.5),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.language_rounded, color: Colors.white, size: 13),
                          Text(widget.isNepali ? 'ने' : 'EN',
                              style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700, height: 1.1)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 7),
              ],
              GestureDetector(
                onTap: _toggle,
                child: Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.30), width: 1.5),
                  ),
                  child: const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 18),
                ),
              ),
              const SizedBox(width: 7),
              GestureDetector(
                onTap: widget.onGridTap,
                child: Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.30), width: 1.5),
                  ),
                  child: const Icon(Icons.menu_rounded, color: Colors.white, size: 20),
                ),
              ),
            ]),
          ),

          // ── Date card ────────────────────────────────────────────────────
          if (!_collapsed)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: GestureDetector(
                onTap: _toggle,
                child: _DateCard(isNepali: widget.isNepali),
              ),
            ),
          if (_collapsed)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Center(
                child: GestureDetector(
                  onTap: _toggle,
                  child: Icon(Icons.keyboard_arrow_down_rounded,
                      color: Colors.white.withValues(alpha: 0.6), size: 20),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Date card — "9 Shrawan 2083 BS" / "25 Jul 2026, Saturday" ─────────────────
class _DateCard extends StatelessWidget {
  final bool isNepali;
  const _DateCard({required this.isNepali});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Row(children: [
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(9),
          ),
          child: const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(child: LiveNepaliDateWidget(isNepali: isNepali)),
        Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white.withValues(alpha: 0.75), size: 18),
      ]),
    );
  }
}

// ── Calculator strip — exactly 5 equal-width items ────────────────────────────
class HeroCalculatorStrip extends StatelessWidget {
  final HeroScreen activeScreen;
  final bool isNepali;
  final String? languageCode;
  final void Function(HeroScreen)? onTap;

  const HeroCalculatorStrip({
    super.key,
    required this.activeScreen,
    bool? isNepali,
    String? languageCode,
    this.onTap,
  }) : isNepali = isNepali ?? (languageCode == 'np' || languageCode == null),
       languageCode = languageCode;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Container(
      // Outer background — same as page background
      color: isDark ? const Color(0xFF0C1224) : const Color(0xFFF0F2FA),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Container(
        // White pill card
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF141E35) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.09),
              blurRadius: 14,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(_kStripItems.length, (i) {
              final item       = _kStripItems[i];
              final isActive   = item.screen == activeScreen;
              final label      = isNepali ? item.labelNP : item.labelEN;
              final iconColor  = isDark ? const Color(0xFF8892CC) : const Color(0xFF1E2C6E);
              final labelColor = isDark ? const Color(0xFF8892CC) : const Color(0xFF1E2C6E);

              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: isActive ? null : () => onTap?.call(item.screen),
                  child: isActive
                      ? Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1B4FE4),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1B4FE4).withValues(alpha: 0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(item.icon, color: Colors.white, size: 17),
                              const SizedBox(height: 2),
                              Text(
                                label,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  height: 1.1,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 36,
                                child: Center(
                                  child: Icon(item.icon, color: iconColor, size: 18),
                                ),
                              ),
                              Text(
                                label,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: labelColor,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w500,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
