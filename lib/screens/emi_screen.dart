import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../widgets/app_hero_header.dart';
import '../widgets/app_drawer.dart';
import '../widgets/features_sheet.dart';
import '../widgets/pro_widgets.dart';
import 'history_screen.dart';
import 'simple_interest_screen.dart';
import 'land_screen.dart';
import 'currency_screen.dart';
import 'report_screen.dart';
import 'widget_settings_screen.dart';
import 'civil_calc_screen.dart';
import 'profit_loss_screen.dart';
import 'input_screen.dart';
import '../widgets/civil_calc_fab.dart';

class EmiScreen extends StatefulWidget {
  final bool? isNepali;
  final String? languageCode;
  const EmiScreen({super.key, this.isNepali, this.languageCode});

  @override
  State<EmiScreen> createState() => _EmiScreenState();
}

class _EmiScreenState extends State<EmiScreen>
    with SingleTickerProviderStateMixin {
  late String _languageCode;
  bool get _isNepali => _languageCode == 'np';
  bool get _isHindi => _languageCode == 'hi';
  bool get _isEnglish => _languageCode == 'en';

  String getTxt(String np, String hi, String en) {
    if (_isNepali) return np;
    if (_isHindi) return hi;
    return en;
  }

  final _principalCtrl = TextEditingController();
  final _rateCtrl      = TextEditingController();
  final _tenureCtrl    = TextEditingController();

  bool _tenureInMonths = true;
  double? _emi;
  double? _totalAmount;
  double? _totalInterest;
  String  _errorMsg = '';

  late final AnimationController _animCtrl;
  late final Animation<double>   _fadeAnim;

  @override
  void initState() {
    super.initState();
    _languageCode = widget.languageCode ?? (widget.isNepali == true ? 'np' : 'en');
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _principalCtrl.dispose();
    _rateCtrl.dispose();
    _tenureCtrl.dispose();
    super.dispose();
  }

  String _fmt(double v) {
    final raw = v.round().toString();
    String out = '';
    final len = raw.length;
    for (int i = 0; i < len; i++) {
      if (i > 0 && (len - i) % 3 == 0) out += ',';
      out += raw[i];
    }
    return out;
  }

  void _calculate() {
    setState(() => _errorMsg = '');
    FocusScope.of(context).unfocus();
    final p = double.tryParse(_principalCtrl.text.trim()) ?? 0;
    final annualRate = double.tryParse(_rateCtrl.text.trim()) ?? 0;
    final tenureInput = double.tryParse(_tenureCtrl.text.trim()) ?? 0;
    if (p <= 0) { setState(() => _errorMsg = _isNepali ? 'ऋण रकम राम्ररी भर्नुहोस्' : 'Please enter a valid Loan amount'); return; }
    if (annualRate <= 0) { setState(() => _errorMsg = _isNepali ? 'ब्याज दर राम्ररी भर्नुहोस्' : 'Please enter a valid Interest Rate'); return; }
    if (tenureInput <= 0) { setState(() => _errorMsg = _isNepali ? 'अवधि राम्ररी भर्नुहोस्' : 'Please enter a valid Tenure'); return; }
    final n = _tenureInMonths ? tenureInput : tenureInput * 12;
    final r = annualRate / 12.0 / 100.0;
    double emi;
    if (r == 0) {
      emi = p / n;
    } else {
      final pow = math.pow(1 + r, n);
      emi = p * r * pow / (pow - 1);
    }
    setState(() {
      _emi = emi;
      _totalAmount = emi * n;
      _totalInterest = (emi * n) - p;
    });
  }

  // ── Build ─────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.cBg,
      floatingActionButton: CivilCalcFab(languageCode: _languageCode),
      body: Container(
        decoration: BoxDecoration(
          gradient: context.isDark ? AppTheme.pageGradientDark : AppTheme.pageGradientLight,
        ),
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SafeArea(
            child: CustomScrollView(
              physics: const ClampingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildHeroHeader()),
                SliverToBoxAdapter(
                  child: HeroCalculatorStrip(
                    activeScreen: HeroScreen.emi,
                    languageCode: _languageCode,
                    onTap: _handleQuickNav,
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 24),
                      _buildInputSection(),
                      const SizedBox(height: 28),
                      if (_errorMsg.isNotEmpty) ...[ErrorBanner(message: _errorMsg), const SizedBox(height: 16)],
                      ProButton(
                        label: _isNepali ? 'EMI गणना गर्नुहोस्' : 'Calculate EMI',
                        icon: Icons.calculate_rounded,
                        gradient: AppTheme.primaryGradient,
                        onPressed: _calculate,
                      ),
                      if (_emi != null) ...[const SizedBox(height: 28), _buildResultSection()],
                      const SizedBox(height: 24),
                      _footer(),
                      const SizedBox(height: 24),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Hero header ────────────────────────────────────
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

  Widget _buildHeroHeader() {
    return AppHeroHeader(
      languageCode: _languageCode,
      title: getTxt('EMI क्याल्कुलेटर', 'ईएमआई कैलकुलेटर', 'EMI Calculator'),
      activeScreen: HeroScreen.emi,
      onLangToggle: _toggleLanguage,
      onGridTap: _showAppGrid,
      onQuickNav: _handleQuickNav,
    );
  }

  void _handleQuickNav(HeroScreen screen) {
    void push(Widget w) {
      // First pop back to main screen, then push the new screen
      Navigator.pop(context);
      Navigator.push(context, PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 320),
        pageBuilder: (_, __, ___) => w,
        transitionsBuilder: (_, a, __, child) =>
            FadeTransition(opacity: CurvedAnimation(parent: a, curve: Curves.easeOut), child: child),
      ));
    }
    switch (screen) {
      case HeroScreen.compound: push(const InputScreen()); break;
      case HeroScreen.simple:   push(SimpleInterestScreen(languageCode: _languageCode)); break;
      case HeroScreen.land:     push(LandScreen(languageCode: _languageCode)); break;
      case HeroScreen.currency: push(CurrencyScreen(languageCode: _languageCode)); break;
      case HeroScreen.history:  Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => HistoryScreen(languageCode: _languageCode))); break;
      case HeroScreen.report:   push(ReportScreen(languageCode: _languageCode)); break;
      case HeroScreen.widget:   push(WidgetSettingsScreen(languageCode: _languageCode)); break;
      case HeroScreen.other:    push(ProfitLossScreen(languageCode: _languageCode)); break;
      default: break;
    }
  }

  void _showAppGrid() {
    showAppDrawer(
      context: context,
      languageCode: _languageCode,
      activeScreen: HeroScreen.emi,
      onNavigate: _handleQuickNav,
    );
  }

  // ── Input section ──────────────────────────────────
  Widget _buildInputSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _group(_isNepali ? 'ऋण रकम' : 'Loan Amount', AppColors.blue,
        _inputField(controller: _principalCtrl,
            hint: _isNepali ? 'जस्तै: 500000' : 'e.g. 500000', prefix: 'रु')),
      const SizedBox(height: 20),
      _group(_isNepali ? 'वार्षिक ब्याज दर' : 'Annual Interest Rate', AppColors.amber,
        _inputField(controller: _rateCtrl,
            hint: _isNepali ? 'जस्तै: 12' : 'e.g. 12', suffix: '%'),
        sub: _isNepali ? '% प्रति वर्ष' : '% per year'),
      const SizedBox(height: 20),
      _buildTenureGroup(),
    ]);
  }

  Widget _buildTenureGroup() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(width: 3, height: 18,
            decoration: BoxDecoration(color: AppColors.indigo,
                borderRadius: BorderRadius.circular(3),
                boxShadow: [BoxShadow(color: AppColors.indigo.withValues(alpha: 0.4),
                    blurRadius: 6, offset: const Offset(0, 2))])),
        const SizedBox(width: 10),
        Text(_isNepali ? 'अवधि' : 'Tenure',
            style: const TextStyle(color: AppColors.indigo, fontSize: 14, fontWeight: FontWeight.w800)),
        const SizedBox(width: 10),
        _tenureToggle(true,  _isNepali ? 'महिना' : 'Months'),
        const SizedBox(width: 6),
        _tenureToggle(false, _isNepali ? 'वर्ष'   : 'Years'),
      ]),
      const SizedBox(height: 10),
      _inputField(
        controller: _tenureCtrl,
        hint: _tenureInMonths
            ? (_isNepali ? 'जस्तै: 36' : 'e.g. 36')
            : (_isNepali ? 'जस्तै: 3'  : 'e.g. 3'),
        suffix: _tenureInMonths
            ? (_isNepali ? 'महिना' : 'mo')
            : (_isNepali ? 'वर्ष'  : 'yr'),
      ),
    ]);
  }

  Widget _tenureToggle(bool isMonths, String label) {
    final selected = _tenureInMonths == isMonths;
    return GestureDetector(
      onTap: () => setState(() { _tenureInMonths = isMonths; _emi = null; }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? AppColors.indigo.withValues(alpha: 0.12) : context.cSurface2,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppColors.indigo.withValues(alpha: 0.4) : context.cBorder,
            width: selected ? 1.5 : 1.0,
          ),
        ),
        child: Text(label, style: TextStyle(
          color: selected ? AppColors.indigo : context.cText3,
          fontSize: 12, fontWeight: FontWeight.w700,
        )),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    String? prefix,
    String? suffix,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
      style: TextStyle(color: context.cText1, fontSize: 17, fontWeight: FontWeight.w700),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: context.cHint, fontSize: 15),
        prefixText: prefix != null ? '$prefix  ' : null,
        prefixStyle: TextStyle(color: context.cText3, fontSize: 16, fontWeight: FontWeight.w600),
        suffixText: suffix,
        suffixStyle: const TextStyle(color: AppColors.amber, fontSize: 16, fontWeight: FontWeight.w700),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
        filled: true, fillColor: context.cSurface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: context.cBorder)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: context.cBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.blue, width: 2)),
      ),
    );
  }

  Widget _group(String label, Color color, Widget child, {String? sub}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SectionHeader(label: label, color: color, sub: sub),
      const SizedBox(height: 10),
      child,
    ]);
  }

  // ── Result section ─────────────────────────────────
  Widget _buildResultSection() {
    final p = double.tryParse(_principalCtrl.text.trim()) ?? 0;
    final rate = double.tryParse(_rateCtrl.text.trim()) ?? 0;
    final tenureInput = double.tryParse(_tenureCtrl.text.trim()) ?? 0;
    final n = _tenureInMonths ? tenureInput : tenureInput * 12;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(_isNepali ? 'विवरण' : 'Details',
          style: TextStyle(color: context.cText4, fontSize: 11,
              fontWeight: FontWeight.w700, letterSpacing: 0.8)),
      const SizedBox(height: 12),
      ProCard(
        padding: EdgeInsets.zero,
        child: Column(children: [
          SummaryRow(icon: Icons.currency_rupee_rounded, color: AppColors.blue,
              label: _isNepali ? 'ऋण रकम' : 'Loan Amount', value: 'रु ${_fmt(p)}'),
          SummaryRow(icon: Icons.percent_rounded, color: AppColors.amber,
              label: _isNepali ? 'वार्षिक ब्याज दर' : 'Annual Interest Rate', value: '$rate%'),
          SummaryRow(icon: Icons.access_time_rounded, color: AppColors.indigo,
              label: _isNepali ? 'अवधि' : 'Tenure',
              value: '${n.toInt()} ${_isNepali ? "महिना" : "months"}', isLast: true),
        ]),
      ),
      const SizedBox(height: 24),
      Text(_isNepali ? 'नतिजा' : 'Result',
          style: TextStyle(color: context.cText4, fontSize: 11,
              fontWeight: FontWeight.w700, letterSpacing: 0.8)),
      const SizedBox(height: 12),
      HeroTotalCard(
        title: _isNepali ? 'मासिक EMI' : 'Monthly EMI',
        amount: 'रु ${_fmt(_emi!)}',
        subtitle: _isNepali ? 'प्रति महिना तिर्नुपर्ने रकम' : 'Amount payable per month',
        gradient: AppTheme.primaryGradient,
        shadows: AppTheme.blueShadow,
        icon: Icons.calendar_month_rounded,
      ),
      const SizedBox(height: 10),
      ResultTile(label: _isNepali ? 'जम्मा ब्याज' : 'Total Interest',
          value: 'रु ${_fmt(_totalInterest!)}', accent: AppColors.indigo),
      const SizedBox(height: 10),
      ResultTile(label: _isNepali ? 'जम्मा भुक्तानी' : 'Total Payment',
          value: 'रु ${_fmt(_totalAmount!)}', accent: AppColors.green),
      const SizedBox(height: 16),
      _breakdownBar(p, _totalInterest!),
    ]);
  }

  Widget _breakdownBar(double principal, double interest) {
    final total  = principal + interest;
    final pRatio = principal / total;
    return ProCard(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(_isNepali ? 'भुक्तानी विभाजन' : 'Payment Breakdown',
            style: TextStyle(color: context.cText1, fontSize: 14, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        ClipRRect(borderRadius: BorderRadius.circular(8),
          child: Row(children: [
            Expanded(flex: (pRatio * 100).round(),
                child: Container(height: 12, color: AppColors.blue)),
            Expanded(flex: 100 - (pRatio * 100).round(),
                child: Container(height: 12, color: AppColors.indigo)),
          ]),
        ),
        const SizedBox(height: 12),
        Row(children: [
          _dot(AppColors.blue), const SizedBox(width: 6),
          Text(_isNepali ? 'मूलधन' : 'Principal',
              style: TextStyle(color: context.cText3, fontSize: 12)),
          const SizedBox(width: 4),
          Text('${(pRatio * 100).toStringAsFixed(1)}%',
              style: TextStyle(color: context.cText1, fontSize: 12, fontWeight: FontWeight.w700)),
          const SizedBox(width: 16),
          _dot(AppColors.indigo), const SizedBox(width: 6),
          Text(_isNepali ? 'ब्याज' : 'Interest',
              style: TextStyle(color: context.cText3, fontSize: 12)),
          const SizedBox(width: 4),
          Text('${((1 - pRatio) * 100).toStringAsFixed(1)}%',
              style: TextStyle(color: context.cText1, fontSize: 12, fontWeight: FontWeight.w700)),
        ]),
      ]),
    );
  }

  Widget _dot(Color color) => Container(
      width: 10, height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle));

  Widget _footer() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Row(children: [
        Container(width: 30, height: 30,
            decoration: BoxDecoration(gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.business_rounded, color: Colors.white, size: 15)),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Tech Procod PVT LTD',
              style: TextStyle(color: context.cText2, fontSize: 12,
                  fontWeight: FontWeight.w700, letterSpacing: 0.2)),
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
