import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_strings.dart';
import '../models/calculation_model.dart';
import '../theme/app_theme.dart';
import '../widgets/app_hero_header.dart';
import '../widgets/features_sheet.dart';
import '../widgets/glass_input_field.dart';
import '../widgets/pro_widgets.dart';
import 'result_screen.dart';
import 'history_screen.dart';
import 'simple_interest_screen.dart';
import 'emi_screen.dart';
import 'report_screen.dart';
import 'currency_screen.dart';
import 'land_screen.dart';
import 'civil_calc_screen.dart';
import 'widget_settings_screen.dart';
import 'profit_loss_screen.dart';
import '../widgets/civil_calc_fab.dart';

/// Formats integer input with comma grouping (e.g. 100000 → 100,000).
/// Strips commas before parsing so the raw numeric value is unaffected.
class _ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Strip any existing commas and non-digit/period characters
    final clean = newValue.text.replaceAll(',', '').replaceAll(RegExp(r'[^0-9.]'), '');
    if (clean.isEmpty) return newValue.copyWith(text: '');

    // Split on decimal point
    final parts = clean.split('.');
    final intPart = parts[0];
    final decPart = parts.length > 1 ? '.${parts[1]}' : '';

    // Apply comma grouping to integer part
    final buf = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) buf.write(',');
      buf.write(intPart[i]);
    }
    final formatted = buf.toString() + decPart;
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}


class InputScreen extends StatefulWidget {
  const InputScreen({super.key});
  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen>
    with TickerProviderStateMixin {
  String _languageCode = 'np';
  bool get _isNepali => _languageCode == 'np';
  bool get _isHindi => _languageCode == 'hi';
  bool get _isEnglish => _languageCode == 'en';
  AppStrings get s => AppStrings(languageCode: _languageCode);

  final _lSal = TextEditingController();
  final _lMah = TextEditingController();
  final _lGat = TextEditingController();
  final _bSal = TextEditingController();
  final _bMah = TextEditingController();
  final _bGat = TextEditingController();
  final _mul  = TextEditingController();
  final _dar  = TextEditingController();

  String _errorMsg = '';

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;
  late final AnimationController _slideCtrl;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _slideCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));
    _fadeCtrl.forward();
    _slideCtrl.forward();
    _loadLanguagePreference();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _slideCtrl.dispose();
    for (final c in [_lSal,_lMah,_lGat,_bSal,_bMah,_bGat,_mul,_dar]) { c.dispose(); }
    super.dispose();
  }

  Future<void> _loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final hasChosen = prefs.getBool('has_chosen_lang') ?? false;
    if (hasChosen) {
      if (mounted) {
        setState(() {
          _languageCode = prefs.getString('app_language_code') ?? 'np';
        });
      }
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showLanguageSelectionDialog();
      });
    }
  }

  Future<void> _toggleLanguage() async {
    setState(() {
      if (_languageCode == 'np') {
        _languageCode = 'en';
      } else if (_languageCode == 'en') {
        _languageCode = 'hi';
      } else {
        _languageCode = 'np';
      }
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language_code', _languageCode);
  }

  void _showLanguageSelectionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F1629) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? const Color(0xFF1E2A45) : const Color(0xFFDDE3F4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.language_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'भाषा चयन गर्नुहोस् / भाषा चुनें',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isDark ? const Color(0xFFEEF2FF) : const Color(0xFF0D1340),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Select Language',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFF8892CC) : const Color(0xFF4A5280),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _languageOptionButton(
                    ctx,
                    title: 'नेपाली (Nepali)',
                    subtitle: 'चक्रिय ब्याज क्याल्कुलेटर',
                    choiceCode: 'np',
                  ),
                  const SizedBox(height: 10),
                  _languageOptionButton(
                    ctx,
                    title: 'हिंदी (Hindi)',
                    subtitle: 'चक्रवृद्धि ब्याज कैलकुलेटर',
                    choiceCode: 'hi',
                  ),
                  const SizedBox(height: 10),
                  _languageOptionButton(
                    ctx,
                    title: 'English (अंग्रेजी)',
                    subtitle: 'Compound Interest Calculator',
                    choiceCode: 'en',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _languageOptionButton(
    BuildContext ctx, {
    required String title,
    required String subtitle,
    required String choiceCode,
  }) {
    final isDark = Theme.of(ctx).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('has_chosen_lang', true);
        await prefs.setString('app_language_code', choiceCode);

        if (mounted) {
          setState(() {
            _languageCode = choiceCode;
          });
        }

        if (ctx.mounted) {
          Navigator.pop(ctx);
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161F38) : const Color(0xFFF0F3FF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF293857) : const Color(0xFFC3CCEB),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? const Color(0xFFEEF2FF) : const Color(0xFF0D1340),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: isDark ? const Color(0xFF8892CC) : const Color(0xFF4A5280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _calculate() {
    setState(() => _errorMsg = '');
    FocusScope.of(context).unfocus();
    final lSal = int.tryParse(_lSal.text.trim()) ?? 0;
    final lMah = int.tryParse(_lMah.text.trim()) ?? 0;
    final lGat = int.tryParse(_lGat.text.trim()) ?? 0;
    final bSal = int.tryParse(_bSal.text.trim()) ?? 0;
    final bMah = int.tryParse(_bMah.text.trim()) ?? 0;
    final bGat = int.tryParse(_bGat.text.trim()) ?? 0;
    final mul  = double.tryParse(_mul.text.trim().replaceAll(',', '')) ?? 0;
    final dar  = double.tryParse(_dar.text.trim()) ?? 0;
    if (lSal == 0 || lMah == 0 || lGat == 0) { setState(() => _errorMsg = s.errLiekoMiti); return; }
    if (bSal == 0 || bMah == 0 || bGat == 0) { setState(() => _errorMsg = s.errBhujaauneMiti); return; }
    if (mul <= 0) { setState(() => _errorMsg = s.errMulDhan); return; }
    if (dar <= 0) { setState(() => _errorMsg = s.errByajDar); return; }
    Navigator.push(context, PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (_, __, ___) => ResultScreen(
        model: CalculationModel(
          liekoSal: lSal, liekoMahina: lMah, liekoGate: lGat,
          bhujaauneSal: bSal, bhujaauneMahina: bMah, bhujaaune_Gate: bGat,
          mulDhan: mul, byajDar: dar,
        ),
        languageCode: _languageCode,
      ),
      transitionsBuilder: (_, anim, __, child) => FadeTransition(
        opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut), child: child),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.isDark ? context.cBg : const Color(0xFFF0F2FA),
      floatingActionButton: CivilCalcFab(languageCode: _languageCode),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: SafeArea(
            child: CustomScrollView(
              physics: const ClampingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildHeroHeader()),
                SliverToBoxAdapter(child: HeroCalculatorStrip(
                  activeScreen: HeroScreen.compound,
                  languageCode: _languageCode,
                  onTap: _handleQuickNav,
                )),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(delegate: SliverChildListDelegate([
                    const SizedBox(height: 20),
                    // ── Section 1: रकम लिएको मिति ──────────────────────
                    _sectionCard(
                      icon: Icons.calendar_month_rounded,
                      iconColor: AppColors.blue,
                      title: s.liekoMiti,
                      child: _dateRow(_lSal, _lMah, _lGat),
                    ),
                    const SizedBox(height: 14),
                    // ── Section 2: रकम भुझाउने मिति ────────────────────
                    _sectionCard(
                      icon: Icons.event_rounded,
                      iconColor: AppColors.indigo,
                      title: s.bhujaaune,
                      child: _dateRow(_bSal, _bMah, _bGat),
                    ),
                    const SizedBox(height: 14),
                    // ── Section 3: मूलधన ───────────────────────────────
                    _sectionCard(
                      icon: Icons.monetization_on_rounded,
                      iconColor: AppColors.green,
                      title: s.mulDhan,
                      child: AppInputField(
                        controller: _mul,
                        hint: _isNepali ? 'जस्तै: 20,000' : 'e.g. 20,000',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [_ThousandsFormatter()],
                        prefix: 'रु.',
                        suffix: 'रु',
                      ),
                    ),
                    const SizedBox(height: 14),
                    // ── Section 4: ब्याज दर ────────────────────────────
                    _sectionCard(
                      icon: Icons.percent_rounded,
                      iconColor: AppColors.amber,
                      title: '${s.byajDar} ${s.perMonth}',
                      child: AppInputField(
                        controller: _dar,
                        hint: _isNepali ? 'जस्तै: 3.0' : 'e.g. 3.0',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                        suffix: '%',
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_errorMsg.isNotEmpty) ...[ErrorBanner(message: _errorMsg), const SizedBox(height: 14)],
                    // ── Calculate button ────────────────────────────────
                    _calcButton(),
                    const SizedBox(height: 20),
                    _footer(),
                    const SizedBox(height: 90),
                  ])),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Section card wrapper (matches screenshot exactly) ─────────────────
  Widget _sectionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: context.cSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.cBorder),
        boxShadow: context.cardShadow,
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header row: icon chip + title
        Row(children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 15),
          ),
          const SizedBox(width: 8),
          Text(title,
              style: TextStyle(
                color: context.cText2,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              )),
        ]),
        const SizedBox(height: 10),
        child,
      ]),
    );
  }

  // ── Calculate button (matches screenshot: icon + label + arrow) ────────
  Widget _calcButton() {
    return GestureDetector(
      onTap: _calculate,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.blueShadow,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calculate_rounded, color: Colors.white, size: 22),
            const SizedBox(width: 10),
            Text(s.calculate,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                )),
            const Spacer(),
            Container(
              margin: const EdgeInsets.only(right: 14),
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
            ),
          ],
        ),
      ),
    );
  }



  // ── Hero header ───────────────────────────────
  Widget _buildHeroHeader() {
    return AppHeroHeader(
      languageCode: _languageCode,
      title: s.appTitle,
      activeScreen: HeroScreen.compound,
      onLangToggle: _toggleLanguage,
      onGridTap: _showFeatures,
      onQuickNav: _handleQuickNav,
    );
  }

  void _handleQuickNav(HeroScreen screen) {
    void push(Widget w) => Navigator.push(context, PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (_, __, ___) => w,
      transitionsBuilder: (_, a, __, child) =>
          FadeTransition(opacity: CurvedAnimation(parent: a, curve: Curves.easeOut), child: child),
    ));
    switch (screen) {
      case HeroScreen.simple:   push(SimpleInterestScreen(languageCode: _languageCode)); break;
      case HeroScreen.emi:      push(EmiScreen(languageCode: _languageCode)); break;
      case HeroScreen.land:     push(LandScreen(languageCode: _languageCode)); break;
      case HeroScreen.currency: push(CurrencyScreen(languageCode: _languageCode)); break;
      case HeroScreen.history:  Navigator.push(context, MaterialPageRoute(builder: (_) => HistoryScreen(languageCode: _languageCode))); break;
      case HeroScreen.report:   push(ReportScreen(languageCode: _languageCode)); break;
      case HeroScreen.widget:   push(WidgetSettingsScreen(languageCode: _languageCode)); break;
      case HeroScreen.other:    push(ProfitLossScreen(languageCode: _languageCode)); break;
      default: break;
    }
  }



  // ── Features grid ──────────────────────────────
  void _showFeatures() {
    showFeaturesSheet(
      context: context,
      languageCode: _languageCode,
      onNavigate: (icon) {
        void push(Widget screen) => Navigator.push(context, PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 320),
          pageBuilder: (_, __, ___) => screen,
          transitionsBuilder: (_, anim, __, child) => FadeTransition(
            opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut), child: child),
        ));
        if (icon == Icons.history_rounded) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => HistoryScreen(languageCode: _languageCode)));
        } else if (icon == Icons.percent_rounded) {
          push(SimpleInterestScreen(languageCode: _languageCode));
        } else if (icon == Icons.account_balance_rounded) {
          push(EmiScreen(languageCode: _languageCode));
        } else if (icon == Icons.pie_chart_rounded) {
          push(ReportScreen(languageCode: _languageCode));
        } else if (icon == Icons.currency_exchange_rounded) {
          push(CurrencyScreen(languageCode: _languageCode));
        } else if (icon == Icons.terrain_rounded) {
          push(LandScreen(languageCode: _languageCode));
        } else if (icon == Icons.widgets_rounded) {
          push(WidgetSettingsScreen(languageCode: _languageCode));
        } else if (icon == Icons.construction_rounded) {
          push(CivilCalcScreen(languageCode: _languageCode));
        } else if (icon == Icons.show_chart_rounded) {
          push(ProfitLossScreen(languageCode: _languageCode));
        }
        // Icons.calculate_rounded = already here, do nothing
      },
    );
  }

  // ── Date row ──────────────────────────────────
  Widget _dateRow(TextEditingController sal, TextEditingController mah, TextEditingController gat) {
    return Row(children: [
      Expanded(child: _dateFieldStyled(controller: sal, label: s.sal,    hint: '2080', suffixIcon: Icons.calendar_today_rounded)),
      const SizedBox(width: 10),
      Expanded(child: _dateFieldStyled(controller: mah, label: s.mahina, hint: '5',    suffixIcon: Icons.keyboard_arrow_down_rounded)),
      const SizedBox(width: 10),
      Expanded(child: _dateFieldStyled(controller: gat, label: s.gate,   hint: '1',    suffixIcon: Icons.keyboard_arrow_down_rounded)),
    ]);
  }

  Widget _dateFieldStyled({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData suffixIcon,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: TextStyle(
            color: context.cText4,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          )),
      const SizedBox(height: 5),
      TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: TextStyle(
          color: context.cText1,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: context.cHint, fontSize: 13),
          suffixIcon: Icon(suffixIcon, color: context.cText4, size: 16),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          filled: true,
          fillColor: context.cBg,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: context.cBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: context.cBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.blue, width: 1.5),
          ),
        ),
      ),
    ]);
  }

  // ── Footer ────────────────────────────────────
  Widget _footer() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Row(children: [
        Container(
          width: 30, height: 30,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.business_rounded, color: Colors.white, size: 15),
        ),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Tech Procod PVT LTD',
              style: TextStyle(
                color: context.cText2, fontSize: 12,
                fontWeight: FontWeight.w700, letterSpacing: 0.2,
              )),
          Text(_isNepali ? 'सफ्टवेयर समाधान' : 'Software Solutions',
              style: TextStyle(color: context.cText4, fontSize: 9, fontWeight: FontWeight.w500)),
        ]),
      ]),
      Row(children: [
        Icon(Icons.phone_outlined, color: context.cText4, size: 13),
        const SizedBox(width: 5),
        Text('+977 9805916598', style: TextStyle(color: context.cText3, fontSize: 12)),
      ]),
    ]);
  }
}
