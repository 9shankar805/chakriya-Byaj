import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_strings.dart';
import '../models/calculation_model.dart';
import '../services/nepali_date.dart';
import '../theme/app_theme.dart';
import '../widgets/app_hero_header.dart';
import '../widgets/app_drawer.dart';
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
class _ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final clean = newValue.text.replaceAll(',', '').replaceAll(RegExp(r'[^0-9.]'), '');
    if (clean.isEmpty) return newValue.copyWith(text: '');
    final parts = clean.split('.');
    final intPart = parts[0];
    final decPart = parts.length > 1 ? '.${parts[1]}' : '';
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

class _InputScreenState extends State<InputScreen> with TickerProviderStateMixin {
  String _languageCode = 'np';
  bool get _isNepali => _languageCode == 'np';
  AppStrings get s => AppStrings(languageCode: _languageCode);

  // Date dropdowns — start date
  late int _lSal;
  late int _lMah;
  late int _lGat;
  // Date dropdowns — return date (defaults 3 years later)
  late int _bSal;
  late int _bMah;
  late int _bGat;

  final _mul = TextEditingController();
  final _dar = TextEditingController();

  String _errorMsg = '';

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;
  late final AnimationController _slideCtrl;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    // Default to today's BS date
    final today = NepaliDate.today();
    _lSal = today.year;
    _lMah = today.month;
    _lGat = today.day;
    _bSal = today.year + 3;
    _bMah = today.month;
    _bGat = today.day;

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
    _mul.dispose();
    _dar.dispose();
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
                    width: 64, height: 64,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.language_rounded, color: Colors.white, size: 36),
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
                  _languageOptionButton(ctx, title: 'नेपाली (Nepali)', subtitle: 'चक्रिय ब्याज क्याल्कुलेटर', choiceCode: 'np'),
                  const SizedBox(height: 10),
                  _languageOptionButton(ctx, title: 'हिंदी (Hindi)', subtitle: 'चक्रवृद्धि ब्याज कैलकुलेटर', choiceCode: 'hi'),
                  const SizedBox(height: 10),
                  _languageOptionButton(ctx, title: 'English (अंग्रेजी)', subtitle: 'Compound Interest Calculator', choiceCode: 'en'),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _languageOptionButton(BuildContext ctx, {required String title, required String subtitle, required String choiceCode}) {
    final isDark = Theme.of(ctx).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('has_chosen_lang', true);
        await prefs.setString('app_language_code', choiceCode);
        if (mounted) setState(() => _languageCode = choiceCode);
        if (ctx.mounted) Navigator.pop(ctx);
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
        child: Column(children: [
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFFEEF2FF) : const Color(0xFF0D1340))),
          const SizedBox(height: 3),
          Text(subtitle, style: TextStyle(fontSize: 10, color: isDark ? const Color(0xFF8892CC) : const Color(0xFF4A5280))),
        ]),
      ),
    );
  }


  void _calculate() {
    setState(() => _errorMsg = '');
    FocusScope.of(context).unfocus();
    if (_lSal == 0 || _lMah == 0 || _lGat == 0) { setState(() => _errorMsg = s.errLiekoMiti); return; }
    if (_bSal == 0 || _bMah == 0 || _bGat == 0) { setState(() => _errorMsg = s.errBhujaauneMiti); return; }
    final mul = double.tryParse(_mul.text.trim().replaceAll(',', '')) ?? 0;
    final dar = double.tryParse(_dar.text.trim()) ?? 0;
    if (mul <= 0) { setState(() => _errorMsg = s.errMulDhan); return; }
    if (dar <= 0) { setState(() => _errorMsg = s.errByajDar); return; }
    Navigator.push(context, PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (_, __, ___) => ResultScreen(
        model: CalculationModel(
          liekoSal: _lSal, liekoMahina: _lMah, liekoGate: _lGat,
          bhujaauneSal: _bSal, bhujaauneMahina: _bMah, bhujaaune_Gate: _bGat,
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
    final isDark = context.isDark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0C1224) : const Color(0xFFF0F2FA),
      floatingActionButton: CivilCalcFab(languageCode: _languageCode),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: SafeArea(
            child: Column(
              children: [
                // ── Blue header (gradient background) ──
                _buildHeroHeader(),
                // ── Calculator strip (white/light background) ──
                HeroCalculatorStrip(
                  activeScreen: HeroScreen.compound,
                  languageCode: _languageCode,
                  onTap: _handleQuickNav,
                ),
                // ── Scrollable body ──
                Expanded(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(14, 4, 14, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionCard(
                          icon: Icons.calendar_month_rounded,
                          iconColor: AppColors.blue,
                          title: s.liekoMiti,
                          child: _dateDropdownRow(
                            sal: _lSal, mah: _lMah, gat: _lGat,
                            onSalChanged: (v) => setState(() => _lSal = v),
                            onMahChanged: (v) => setState(() => _lMah = v),
                            onGatChanged: (v) => setState(() => _lGat = v),
                          ),
                        ),
                        const SizedBox(height: 6),
                        _sectionCard(
                          icon: Icons.event_rounded,
                          iconColor: AppColors.indigo,
                          title: s.bhujaaune,
                          child: _dateDropdownRow(
                            sal: _bSal, mah: _bMah, gat: _bGat,
                            onSalChanged: (v) => setState(() => _bSal = v),
                            onMahChanged: (v) => setState(() => _bMah = v),
                            onGatChanged: (v) => setState(() => _bGat = v),
                          ),
                        ),
                        const SizedBox(height: 6),
                        _sectionCard(
                          icon: Icons.currency_rupee_rounded,
                          iconColor: AppColors.green,
                          title: _isNepali ? 'मूलधन' : s.mulDhan,
                          child: AppInputField(
                            controller: _mul,
                            hint: _isNepali ? 'रकम लेख्नुहोस्' : 'Enter amount',
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [_ThousandsFormatter()],
                            prefix: 'Rs.',
                          ),
                        ),
                        const SizedBox(height: 6),
                        _sectionCard(
                          icon: Icons.percent_rounded,
                          iconColor: AppColors.amber,
                          title: '${s.byajDar} ${s.perMonth}',
                          child: AppInputField(
                            controller: _dar,
                            hint: 'e.g. 3.0',
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                            suffix: '%',
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_errorMsg.isNotEmpty) ...[
                          ErrorBanner(message: _errorMsg),
                          const SizedBox(height: 6),
                        ],
                        _calcButton(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _sectionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget child,
  }) {
    final isDark = context.isDark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F1629) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF1E2A45) : const Color(0xFFE8EDF8),
          width: 1.2,
        ),
        boxShadow: isDark
            ? [BoxShadow(color: Colors.black.withValues(alpha: 0.20), blurRadius: 12, offset: const Offset(0, 4))]
            : [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(children: [
            Container(
              width: 30, height: 30,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, color: iconColor, size: 16),
            ),
            const SizedBox(width: 9),
            Text(
              title,
              style: TextStyle(
                color: context.cText1,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.1,
              ),
            ),
          ]),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }


  // ── Date dropdown row — Year / Month / Day with chevron ───────────────────
  Widget _dateDropdownRow({
    required int sal,
    required int mah,
    required int gat,
    required ValueChanged<int> onSalChanged,
    required ValueChanged<int> onMahChanged,
    required ValueChanged<int> onGatChanged,
  }) {
    final isDark = context.isDark;

    // BS year range
    final years = List.generate(50, (i) => 2065 + i); // 2065–2114

    // Month names
    final monthNames = _isNepali
        ? NepaliDate.monthsNP
        : NepaliDate.monthsEN;

    // Days in selected month
    final maxDay = NepaliDate.daysInMonth(sal, mah);
    final days = List.generate(maxDay, (i) => i + 1);

    return Row(children: [
      // Year — narrower
      Expanded(
        flex: 3,
        child: _dropdownField<int>(
          label: s.sal,
          value: sal,
          items: years,
          display: (v) => v.toString(),
          onChanged: (v) {
            onSalChanged(v);
            final md = NepaliDate.daysInMonth(v, mah);
            if (gat > md) onGatChanged(md);
          },
          isDark: isDark,
        ),
      ),
      const SizedBox(width: 8),
      // Month — wider so name fits on one line
      Expanded(
        flex: 4,
        child: _dropdownField<int>(
          label: s.mahina,
          value: mah,
          items: List.generate(12, (i) => i + 1),
          display: (v) => monthNames[v - 1],
          onChanged: (v) {
            onMahChanged(v);
            final md = NepaliDate.daysInMonth(sal, v);
            if (gat > md) onGatChanged(md);
          },
          isDark: isDark,
        ),
      ),
      const SizedBox(width: 8),
      // Day — narrower
      Expanded(
        flex: 2,
        child: _dropdownField<int>(
          label: s.gate,
          value: gat.clamp(1, maxDay),
          items: days,
          display: (v) => v.toString().padLeft(2, '0'),
          onChanged: onGatChanged,
          isDark: isDark,
        ),
      ),
    ]);
  }

  Widget _dropdownField<T>({
    required String label,
    required T value,
    required List<T> items,
    required String Function(T) display,
    required ValueChanged<T> onChanged,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: context.cText4,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 42,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0C1224) : const Color(0xFFF7F9FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? const Color(0xFF1E2A45) : const Color(0xFFDDE3F4),
              width: 1.5,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: ButtonTheme(
              alignedDropdown: true,
              child: DropdownButton<T>(
                value: value,
                isExpanded: true,
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: context.cText4,
                  size: 18,
                ),
                style: TextStyle(
                  color: context.cText1,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
                dropdownColor: isDark ? const Color(0xFF0F1629) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                items: items.map((item) {
                  return DropdownMenuItem<T>(
                    value: item,
                    child: Text(
                      display(item),
                      style: TextStyle(
                        color: context.cText1,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (v) { if (v != null) onChanged(v); },
              ),
            ),
          ),
        ),
      ],
    );
  }


  // ── Calculate button — icon left, text centre-left, arrow right ──────────
  Widget _calcButton() {
    return GestureDetector(
      onTap: _calculate,
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFF1B4FE4), Color(0xFF1B4FE4)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.blue.withValues(alpha: 0.30),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(children: [
          const Icon(Icons.calculate_rounded, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _isNepali
                  ? 'चक्रिय ब्याज गणना गर्नुहोस्'
                  : 'Calculate Compound Interest',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.1,
              ),
            ),
          ),
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_forward_rounded,
                color: Colors.white, size: 17),
          ),
        ]),
      ),
    );
  }


  // ── Hero header ────────────────────────────────────────────────────────
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
    void push(Widget w) => Navigator.push(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 320),
          pageBuilder: (_, __, ___) => w,
          transitionsBuilder: (_, a, __, child) => FadeTransition(
              opacity: CurvedAnimation(parent: a, curve: Curves.easeOut),
              child: child),
        ));
    switch (screen) {
      case HeroScreen.simple:
        push(SimpleInterestScreen(languageCode: _languageCode));
        break;
      case HeroScreen.emi:
        push(EmiScreen(languageCode: _languageCode));
        break;
      case HeroScreen.land:
        push(LandScreen(languageCode: _languageCode));
        break;
      case HeroScreen.currency:
        push(CurrencyScreen(languageCode: _languageCode));
        break;
      case HeroScreen.history:
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) =>
                    HistoryScreen(languageCode: _languageCode)));
        break;
      case HeroScreen.report:
        push(ReportScreen(languageCode: _languageCode));
        break;
      case HeroScreen.widget:
        push(WidgetSettingsScreen(languageCode: _languageCode));
        break;
      case HeroScreen.other:
        push(ProfitLossScreen(languageCode: _languageCode));
        break;
      default:
        break;
    }
  }

  // ── Features drawer ───────────────────────────────────────────────────
  void _showFeatures() {
    showAppDrawer(
      context: context,
      languageCode: _languageCode,
      activeScreen: HeroScreen.compound,
      onNavigate: _handleQuickNav,
    );
  }


  // ── Footer ────────────────────────────────────────────────────────────
  Widget _footer() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: context.isDark
            ? const Color(0xFF0F1629)
            : Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: context.cBorder.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.business_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Tech Procod',
                  style: TextStyle(
                    color: context.cText1,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  )),
              Text('Software Solutions',
                  style: TextStyle(
                    color: context.cText4,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  )),
            ]),
          ]),
          Row(children: [
            Icon(Icons.phone_outlined, color: context.cText4, size: 14),
            const SizedBox(width: 6),
            Text('+977 9805916598',
                style: TextStyle(
                  color: context.cText3,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                )),
          ]),
        ],
      ),
    );
  }
}
