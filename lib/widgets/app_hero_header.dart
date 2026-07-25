import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/ms_grid.dart';
import '../widgets/nepali_calendar.dart';

enum HeroScreen {
  compound, simple, emi, land, currency, history, report, widget, result, other
}

class _QuickItem {
  final IconData   icon;
  final HeroScreen screen;
  final String     labelNP;
  final String     labelEN;
  final Color      color;
  const _QuickItem(this.icon, this.screen, this.labelNP, this.labelEN, this.color);
}

const List<_QuickItem> _kItems = [
  _QuickItem(Icons.calculate_rounded,         HeroScreen.compound, 'चक्रिय\nब्याज',   'Compound\nInterest', AppColors.blue),
  _QuickItem(Icons.percent_rounded,           HeroScreen.simple,   'साधारण\nब्याज',   'Simple\nInterest',   AppColors.indigo),
  _QuickItem(Icons.account_balance_rounded,   HeroScreen.emi,      'EMI\nक्याल्कु.',  'EMI\nCalc.',         AppColors.indigo),
  _QuickItem(Icons.show_chart_rounded,        HeroScreen.other,    'लाभ\nहानि',        'Profit\nLoss',       AppColors.indigo),
  _QuickItem(Icons.history_rounded,           HeroScreen.history,  'पुराना\nगणनाहरु', 'History',            AppColors.indigo),
  _QuickItem(Icons.terrain_rounded,           HeroScreen.land,     'जग्गा\nक्षेत्र',  'Land\nArea',         AppColors.purple),
  _QuickItem(Icons.currency_exchange_rounded, HeroScreen.currency, 'मुद्रा',           'Currency',           AppColors.amber),
  _QuickItem(Icons.widgets_rounded,           HeroScreen.widget,   'मिति\nविजेट',      'Date\nWidget',       AppColors.cyan),
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
  // Backward compat — if languageCode provided, derive isNepali from it
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
    final isDark = context.isDark;
    final gradient = isDark
        ? const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFF1A2540), Color(0xFF0B1120)])
        : const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFF2040D8), Color(0xFF3730A3)]);

    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      alignment: Alignment.topCenter,
      child: Container(
        decoration: BoxDecoration(gradient: gradient),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top row: logo + title + buttons ──────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Row(children: [
                // Logo — white rounded square
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset('assets/app_logo.jpeg', fit: BoxFit.cover),
                ),
                const SizedBox(width: 12),
                // Title + subtitle
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(widget.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        )),
                    Text('Tech Procod PVT LTD',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.65),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        )),
                  ]),
                ),
                if (widget.trailing != null) ...[widget.trailing!, const SizedBox(width: 8)],
                // Language button — 🌐 EN style
                if (widget.showLangToggle) ...[
                  GestureDetector(
                    onTap: widget.onLangToggle,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.language_rounded, color: Colors.white, size: 15),
                        const SizedBox(width: 5),
                        Text(widget.isNepali ? 'EN' : 'ने',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            )),
                      ]),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                // Grid button — square with dots
                GestureDetector(
                  onTap: widget.onGridTap,
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: MsGrid(color: Colors.white),
                    ),
                  ),
                ),
              ]),
            ),
            // ── Date + collapse ────────────────────────────────────────────
            if (!_collapsed)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
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
                        color: Colors.white.withValues(alpha: 0.5), size: 20),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Date card — matches screenshot exactly ────────────────────────────────────
class _DateCard extends StatelessWidget {
  final bool isNepali;
  const _DateCard({required this.isNepali});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(children: [
        // Calendar icon box
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        // Date text — wrapped in LiveNepaliDateWidget inline
        Expanded(child: LiveNepaliDateWidget(isNepali: isNepali)),
        // Chevron
        Icon(Icons.keyboard_arrow_down_rounded,
            color: Colors.white.withValues(alpha: 0.7), size: 20),
      ]),
    );
  }
}

// ── Calculator strip (on white body below header) ─────────────────────────────
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
    return Container(
      color: context.isDark ? const Color(0xFF111827) : const Color(0xFFF0F2FA),
      height: 94,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        itemCount: _kItems.length,
        itemBuilder: (ctx, i) {
          final item = _kItems[i];
          final isActive = item.screen == activeScreen;
          final label = isNepali ? item.labelNP : item.labelEN;
          return GestureDetector(
            onTap: isActive ? null : () => onTap?.call(item.screen),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 72,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF2040D8)
                    : context.isDark ? const Color(0xFF1E2740) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: isActive
                    ? null
                    : Border.all(
                        color: context.isDark
                            ? const Color(0xFF2A3655)
                            : const Color(0xFFDDE3F4),
                      ),
                boxShadow: isActive
                    ? [BoxShadow(
                        color: const Color(0xFF2040D8).withValues(alpha: 0.28),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )]
                    : [BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      )],
              ),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item.icon,
                      color: isActive ? Colors.white : item.color,
                      size: isActive ? 26 : 24),
                  const SizedBox(height: 5),
                  Text(label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isActive
                            ? Colors.white
                            : context.isDark
                                ? const Color(0xFF8892CC)
                                : const Color(0xFF3A4275),
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
