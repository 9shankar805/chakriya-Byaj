import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../widgets/app_hero_header.dart';
import '../widgets/app_drawer.dart';
import '../widgets/features_sheet.dart';
import 'history_screen.dart';
import 'simple_interest_screen.dart';
import 'emi_screen.dart';
import 'land_screen.dart';
import 'report_screen.dart';
import 'widget_settings_screen.dart';
import 'civil_calc_screen.dart';
import 'profit_loss_screen.dart';
import 'input_screen.dart';
import '../widgets/civil_calc_fab.dart';

class CurrencyScreen extends StatefulWidget {
  final bool? isNepali;
  final String? languageCode;
  const CurrencyScreen({super.key, this.isNepali, this.languageCode});

  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen>
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

  static const List<Map<String, String>> _currencies = [
    {'code': 'NPR', 'name': 'Nepali Rupee',     'flag': '🇳🇵'},
    {'code': 'USD', 'name': 'US Dollar',         'flag': '🇺🇸'},
    {'code': 'EUR', 'name': 'Euro',              'flag': '🇪🇺'},
    {'code': 'GBP', 'name': 'British Pound',     'flag': '🇬🇧'},
    {'code': 'INR', 'name': 'Indian Rupee',      'flag': '🇮🇳'},
    {'code': 'AUD', 'name': 'Australian Dollar', 'flag': '🇦🇺'},
    {'code': 'CAD', 'name': 'Canadian Dollar',   'flag': '🇨🇦'},
    {'code': 'JPY', 'name': 'Japanese Yen',      'flag': '🇯🇵'},
    {'code': 'CNY', 'name': 'Chinese Yuan',      'flag': '🇨🇳'},
    {'code': 'SAR', 'name': 'Saudi Riyal',       'flag': '🇸🇦'},
    {'code': 'AED', 'name': 'UAE Dirham',        'flag': '🇦🇪'},
    {'code': 'KWD', 'name': 'Kuwaiti Dinar',     'flag': '🇰🇼'},
    {'code': 'QAR', 'name': 'Qatari Riyal',      'flag': '🇶🇦'},
    {'code': 'MYR', 'name': 'Malaysian Ringgit', 'flag': '🇲🇾'},
    {'code': 'SGD', 'name': 'Singapore Dollar',  'flag': '🇸🇬'},
  ];

  String _fromCode = 'NPR';
  String _toCode   = 'USD';
  final _amountCtrl = TextEditingController();

  Map<String, double> _rates = {};
  bool _loading = false;
  bool _fetched = false;
  String _errorMsg = '';
  double? _result;
  String _lastUpdated = '';

  late final AnimationController _animCtrl;
  late final Animation<double>   _fadeAnim;

  @override
  void initState() {
    super.initState();
    _languageCode = widget.languageCode ?? (widget.isNepali == true ? 'np' : 'en');
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
    _fetchRates();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchRates() async {
    setState(() { _loading = true; _errorMsg = ''; });
    try {
      final uri = Uri.parse('https://api.exchangerate-api.com/v4/latest/NPR');
      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final rawRates = Map<String, dynamic>.from(data['rates']);
        setState(() {
          _rates = rawRates.map((k, v) => MapEntry(k, (v as num).toDouble()));
          _fetched = true;
          _loading = false;
          _lastUpdated = data['date'] ?? '';
          _result = null;
        });
      } else {
        throw Exception('Bad response');
      }
    } catch (_) {
      setState(() {
        _loading = false;
        _errorMsg = _isNepali
            ? 'दर लोड गर्न सकिएन। इन्टरनेट जाँच गर्नुहोस्।'
            : 'Failed to load rates. Check internet connection.';
      });
    }
  }

  void _convert() {
    FocusScope.of(context).unfocus();
    setState(() => _errorMsg = '');
    final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0;
    if (amount <= 0) {
      setState(() => _errorMsg = _isNepali ? 'रकम राम्ररी भर्नुहोस्' : 'Please enter a valid amount');
      return;
    }
    if (_rates.isEmpty) { _fetchRates(); return; }
    final fromRate = _rates[_fromCode] ?? 1.0;
    final toRate   = _rates[_toCode]   ?? 1.0;
    final inNPR    = amount / fromRate;
    setState(() => _result = inNPR * toRate);
  }

  void _swap() {
    setState(() {
      final tmp = _fromCode;
      _fromCode = _toCode;
      _toCode = tmp;
      _result = null;
    });
  }

  String _fmt(double v) {
    if (v >= 1) {
      final s = v.toStringAsFixed(2);
      final parts = s.split('.');
      String out = '';
      final len = parts[0].length;
      for (int i = 0; i < len; i++) {
        if (i > 0 && (len - i) % 3 == 0) out += ',';
        out += parts[0][i];
      }
      return '$out.${parts[1]}';
    }
    return v.toStringAsFixed(6);
  }

  Map<String, String> _info(String code) =>
      _currencies.firstWhere((c) => c['code'] == code,
          orElse: () => {'code': code, 'name': code, 'flag': '🌐'});

  // ── Build ────────────────────────────────────────────
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
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 24),
                      _rateStatusBar(),
                      const SizedBox(height: 24),
                      _label(_isNepali ? 'कुन मुद्राबाट' : 'From Currency', AppColors.blue),
                      const SizedBox(height: 10),
                      _currencySelector(_fromCode, (v) => setState(() { _fromCode = v; _result = null; })),
                      const SizedBox(height: 20),
                      _label(_isNepali ? 'रकम' : 'Amount', AppColors.amber),
                      const SizedBox(height: 10),
                      _amountField(),
                      const SizedBox(height: 20),
                      Center(child: _swapButton()),
                      const SizedBox(height: 20),
                      _label(_isNepali ? 'कुन मुद्रामा' : 'To Currency', AppColors.indigo),
                      const SizedBox(height: 10),
                      _currencySelector(_toCode, (v) => setState(() { _toCode = v; _result = null; })),
                      const SizedBox(height: 28),
                      if (_errorMsg.isNotEmpty) ...[_errorBanner(), const SizedBox(height: 16)],
                      _convertButton(),
                      if (_result != null) ...[const SizedBox(height: 24), _resultCard()],
                      if (_fetched && _rates.isNotEmpty) ...[const SizedBox(height: 24), _quickRates()],
                      const SizedBox(height: 32),
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

  // ── Hero header ──────────────────────────────────────
  // ── Hero header ──────────────────────────────────────
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
      title: getTxt('मुद्रा रूपान्तरण', 'मुद्रा विनिमय', 'Currency Converter'),
      activeScreen: HeroScreen.currency,
      onLangToggle: _toggleLanguage,
      onBack: () => Navigator.pop(context),
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
      case HeroScreen.emi:      push(EmiScreen(languageCode: _languageCode)); break;
      case HeroScreen.land:     push(LandScreen(languageCode: _languageCode)); break;
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
      activeScreen: HeroScreen.currency,
      onNavigate: _handleQuickNav,
    );
  }

  // ── Rate status bar ──────────────────────────────────
  Widget _rateStatusBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _fetched ? AppColors.green.withValues(alpha: 0.08) : context.cSurface2,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _fetched ? AppColors.green.withValues(alpha: 0.2) : context.cBorder),
      ),
      child: Row(children: [
        _loading
            ? const SizedBox(width: 14, height: 14,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.blue))
            : Icon(_fetched ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                color: _fetched ? AppColors.green : context.cText4, size: 15),
        const SizedBox(width: 8),
        Expanded(child: Text(
          _loading
              ? (_isNepali ? 'दर लोड हुँदैछ...' : 'Loading rates...')
              : _fetched
                  ? (_isNepali ? 'लाइभ दर — अपडेट: $_lastUpdated' : 'Live rates — Updated: $_lastUpdated')
                  : (_isNepali ? 'दर उपलब्ध छैन' : 'Rates unavailable'),
          style: TextStyle(
              color: _fetched ? AppColors.green : context.cText3,
              fontSize: 12, fontWeight: FontWeight.w600),
        )),
        if (!_loading)
          GestureDetector(
            onTap: _fetchRates,
            child: const Icon(Icons.refresh_rounded, color: AppColors.blue, size: 18),
          ),
      ]),
    );
  }

  Widget _label(String text, Color color) {
    return Row(children: [
      Container(width: 3, height: 16,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
      const SizedBox(width: 8),
      Text(text, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w700)),
    ]);
  }

  Widget _currencySelector(String selected, ValueChanged<String> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: context.cSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.cBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selected,
          isExpanded: true,
          dropdownColor: context.cSurface,
          style: TextStyle(color: context.cText1, fontSize: 15, fontWeight: FontWeight.w700),
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: context.cText3),
          items: _currencies.map((c) => DropdownMenuItem(
            value: c['code'],
            child: Row(children: [
              Text(c['flag']!, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Text('${c['code']} — ${c['name']}',
                  style: TextStyle(color: context.cText1, fontSize: 14, fontWeight: FontWeight.w600)),
            ]),
          )).toList(),
          onChanged: (v) { if (v != null) onChanged(v); },
        ),
      ),
    );
  }

  Widget _amountField() {
    return TextField(
      controller: _amountCtrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
      style: TextStyle(color: context.cText1, fontSize: 17, fontWeight: FontWeight.w700),
      decoration: InputDecoration(
        hintText: _isNepali ? 'जस्तै: 10000' : 'e.g. 10000',
        hintStyle: TextStyle(color: context.cHint, fontSize: 15),
        prefixText: '${_info(_fromCode)['flag']}  ',
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 13, horizontal: 14),
        filled: true,
        fillColor: context.cSurface,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: context.cBorder)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: context.cBorder)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.blue, width: 1.5)),
      ),
    );
  }

  Widget _swapButton() {
    return GestureDetector(
      onTap: _swap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.amber.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.amber.withValues(alpha: 0.3)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.swap_vert_rounded, color: AppColors.amber, size: 18),
          const SizedBox(width: 8),
          Text(_isNepali ? 'मुद्रा अदलबदल' : 'Swap Currencies',
              style: const TextStyle(color: AppColors.amber, fontSize: 13, fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }

  Widget _errorBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.red.withValues(alpha: 0.3)),
      ),
      child: Row(children: [
        const Icon(Icons.error_outline_rounded, color: AppColors.red, size: 16),
        const SizedBox(width: 8),
        Expanded(child: Text(_errorMsg,
            style: const TextStyle(color: AppColors.red, fontSize: 13, fontWeight: FontWeight.w500))),
      ]),
    );
  }

  Widget _convertButton() {
    return SizedBox(
      width: double.infinity, height: 52,
      child: ElevatedButton.icon(
        onPressed: _loading ? null : _convert,
        icon: const Icon(Icons.currency_exchange_rounded, size: 20),
        label: Text(_isNepali ? 'रूपान्तरण गर्नुहोस्' : 'Convert',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.amber,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: AppColors.amber.withValues(alpha: 0.35),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  Widget _resultCard() {
    final from   = _info(_fromCode);
    final to     = _info(_toCode);
    final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(
            color: AppColors.blue.withValues(alpha: 0.28),
            blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('${from['flag']} ${_fmt(amount)} ${from['code']}',
            style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        const Icon(Icons.arrow_downward_rounded, color: Colors.white54, size: 18),
        const SizedBox(height: 4),
        Text('${to['flag']} ${_fmt(_result!)} ${to['code']}',
            style: const TextStyle(
                color: Colors.white, fontSize: 32,
                fontWeight: FontWeight.w900, letterSpacing: -0.5)),
        const SizedBox(height: 8),
        if (_rates.containsKey(_fromCode) && _rates.containsKey(_toCode))
          Text(
            '1 ${from['code']} = ${_fmt(_rates[_toCode]! / _rates[_fromCode]!)} ${to['code']}',
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
      ]),
    );
  }

  Widget _quickRates() {
    final common = ['USD', 'INR', 'EUR', 'GBP', 'AED', 'SAR', 'AUD'];
    final npr = _rates['NPR'] ?? 1.0;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(_isNepali ? 'आजको दर (NPR आधारमा)' : 'Today\'s Rates (NPR base)',
          style: TextStyle(color: context.cText4, fontSize: 11,
              fontWeight: FontWeight.w700, letterSpacing: 0.8)),
      const SizedBox(height: 12),
      Container(
        decoration: BoxDecoration(
          color: context.cSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.cBorder),
        ),
        child: Column(children: common.asMap().entries.map((e) {
          final code = e.value;
          final info = _info(code);
          final rate = _rates[code];
          if (rate == null) return const SizedBox.shrink();
          final nprPerOne = npr / rate;
          return Column(children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(children: [
                Text(info['flag']!, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Expanded(child: Text(code,
                    style: TextStyle(color: context.cText1, fontSize: 14, fontWeight: FontWeight.w700))),
                Text('1 $code = रु ${_fmt(nprPerOne)}',
                    style: TextStyle(color: context.cText2, fontSize: 13, fontWeight: FontWeight.w600)),
              ]),
            ),
            if (e.key < common.length - 1)
              Divider(color: context.cBorder, height: 1, indent: 16, endIndent: 16),
          ]);
        }).toList()),
      ),
    ]);
  }
}
