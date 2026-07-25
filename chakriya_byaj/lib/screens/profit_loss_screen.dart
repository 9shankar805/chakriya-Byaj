import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../widgets/app_hero_header.dart';
import '../widgets/features_sheet.dart';
import '../widgets/civil_calc_fab.dart';
import 'simple_interest_screen.dart';
import 'emi_screen.dart';
import 'land_screen.dart';
import 'currency_screen.dart';
import 'history_screen.dart';
import 'report_screen.dart';
import 'widget_settings_screen.dart';
import 'civil_calc_screen.dart';

// ── Calculation mode ────────────────────────────────────────────────────────
enum _PLMode { costSell, percentProfit, percentLoss, markup }

class ProfitLossScreen extends StatefulWidget {
  final String languageCode;
  const ProfitLossScreen({super.key, required this.languageCode});

  @override
  State<ProfitLossScreen> createState() => _ProfitLossScreenState();
}

class _ProfitLossScreenState extends State<ProfitLossScreen>
    with SingleTickerProviderStateMixin {
  late String _languageCode;
  bool get _isNepali => _languageCode == 'np';
  bool get _isHindi  => _languageCode == 'hi';

  String t(String np, String hi, String en) {
    if (_isNepali) return np;
    if (_isHindi)  return hi;
    return en;
  }

  _PLMode _mode = _PLMode.costSell;

  // Cost & Sell mode
  final _costCtrl = TextEditingController();
  final _sellCtrl = TextEditingController();

  // Cost + % profit/loss mode
  final _costPctCtrl = TextEditingController();
  final _pctCtrl     = TextEditingController();

  // Markup mode (cost + markup %)
  final _mkCostCtrl   = TextEditingController();
  final _mkPctCtrl    = TextEditingController();

  Map<String, String>? _result;
  String _errorMsg = '';

  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _languageCode = widget.languageCode;
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _scrollCtrl.dispose();
    for (final c in [_costCtrl, _sellCtrl, _costPctCtrl, _pctCtrl,
                     _mkCostCtrl, _mkPctCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  void _clearAll() {
    for (final c in [_costCtrl, _sellCtrl, _costPctCtrl, _pctCtrl,
                     _mkCostCtrl, _mkPctCtrl]) {
      c.clear();
    }
    setState(() { _result = null; _errorMsg = ''; });
  }

  double _v(TextEditingController c) =>
      double.tryParse(c.text.trim().replaceAll(',', '')) ?? 0;

  // ── Calculate ───────────────────────────────────────────────────────────
  void _calculate() {
    FocusScope.of(context).unfocus();
    setState(() { _errorMsg = ''; _result = null; });

    if (_mode == _PLMode.costSell) {
      final cost = _v(_costCtrl), sell = _v(_sellCtrl);
      if (cost <= 0 || sell <= 0) { _err(); return; }
      _buildResult(cost: cost, sell: sell);

    } else if (_mode == _PLMode.percentProfit) {
      final cost = _v(_costPctCtrl), pct = _v(_pctCtrl);
      if (cost <= 0 || pct <= 0) { _err(); return; }
      final sell = cost * (1 + pct / 100);
      _buildResult(cost: cost, sell: sell);

    } else if (_mode == _PLMode.percentLoss) {
      final cost = _v(_costPctCtrl), pct = _v(_pctCtrl);
      if (cost <= 0 || pct <= 0) { _err(); return; }
      final sell = cost * (1 - pct / 100);
      _buildResult(cost: cost, sell: sell);

    } else if (_mode == _PLMode.markup) {
      final cost = _v(_mkCostCtrl), pct = _v(_mkPctCtrl);
      if (cost <= 0 || pct <= 0) { _err(); return; }
      final sell = cost * (1 + pct / 100);
      _buildResult(cost: cost, sell: sell);
    }
  }

  void _err() => setState(() =>
      _errorMsg = t('कृपया सबै मान भर्नुहोस्', 'सभी मान भरें', 'Please fill all values'));

  void _buildResult({required double cost, required double sell}) {
    final diff = sell - cost;
    final isProfit = diff >= 0;
    final pct = (diff.abs() / cost) * 100;
    final markup = (diff / cost) * 100; // can be negative

    setState(() {
      _result = {
        'cost':      _fmt(cost),
        'sell':      _fmt(sell),
        'diff':      _fmt(diff.abs()),
        'pct':       pct.toStringAsFixed(2),
        'markup':    markup.toStringAsFixed(2),
        'isProfit':  isProfit ? '1' : '0',
        'rawDiff':   diff.toStringAsFixed(2),
      };
    });
  }

  String _fmt(double v) {
    final parts = v.toStringAsFixed(2).split('.');
    final intPart = parts[0].replaceAll('-', '');
    final sign = v < 0 ? '-' : '';
    String out = '';
    final len = intPart.length;
    for (int i = 0; i < len; i++) {
      if (i > 0 && (len - i) % 3 == 0) out += ',';
      out += intPart[i];
    }
    return '$sign$out.${parts[1]}';
  }

  // ── Build ───────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.cBg,
      floatingActionButton: CivilCalcFab(languageCode: _languageCode),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SafeArea(
          child: Column(children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollCtrl,
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const SizedBox(height: 20),
                  _modeTabs(),
                  const SizedBox(height: 20),
                  _modeGuide(),
                  const SizedBox(height: 20),
                  _buildInputs(),
                  const SizedBox(height: 24),
                  if (_errorMsg.isNotEmpty) ...[_errorBanner(), const SizedBox(height: 16)],
                  _calcButton(),
                  if (_result != null) ...[const SizedBox(height: 28), _buildResults()],
                  const SizedBox(height: 40),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return AppHeroHeader(
      languageCode: _languageCode,
      title: t('नाफा नोक्सान', 'लाभ हानि', 'Profit & Loss'),
      activeScreen: HeroScreen.other,
      onLangToggle: () {},
      showLangToggle: false,
      onBack: () => Navigator.pop(context),
      onGridTap: _showAppGrid,
      onQuickNav: _handleQuickNav,
      trailing: GestureDetector(
        onTap: _clearAll,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.refresh_rounded, color: Colors.white, size: 14),
            const SizedBox(width: 4),
            Text(t('रिसेट', 'रीसेट', 'Reset'),
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
          ]),
        ),
      ),
    );
  }

  void _showAppGrid() {
    showFeaturesSheet(
      context: context,
      languageCode: _languageCode,
      onNavigate: (icon) {
        void push(Widget w) {
          Navigator.pop(context);
          Navigator.pop(context);
          Navigator.push(context, PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 320),
            pageBuilder: (_, __, ___) => w,
            transitionsBuilder: (_, a, __, child) =>
                FadeTransition(opacity: CurvedAnimation(parent: a, curve: Curves.easeOut), child: child),
          ));
        }
        if (icon == Icons.calculate_rounded) {
          Navigator.pop(context); Navigator.pop(context);
        } else if (icon == Icons.history_rounded) {
          Navigator.pop(context); Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (_) => HistoryScreen(languageCode: _languageCode)));
        } else if (icon == Icons.percent_rounded) {
          push(SimpleInterestScreen(languageCode: _languageCode));
        } else if (icon == Icons.account_balance_rounded) {
          push(EmiScreen(languageCode: _languageCode));
        } else if (icon == Icons.currency_exchange_rounded) {
          push(CurrencyScreen(languageCode: _languageCode));
        } else if (icon == Icons.pie_chart_rounded) {
          push(ReportScreen(languageCode: _languageCode));
        } else if (icon == Icons.terrain_rounded) {
          push(LandScreen(languageCode: _languageCode));
        } else if (icon == Icons.widgets_rounded) {
          push(WidgetSettingsScreen(languageCode: _languageCode));
        } else if (icon == Icons.construction_rounded) {
          push(CivilCalcScreen(languageCode: _languageCode));
        }
      },
    );
  }

  void _handleQuickNav(HeroScreen screen) {
    void push(Widget w) {
      Navigator.pop(context);
      Navigator.push(context, PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 320),
        pageBuilder: (_, __, ___) => w,
        transitionsBuilder: (_, a, __, child) =>
            FadeTransition(opacity: CurvedAnimation(parent: a, curve: Curves.easeOut), child: child),
      ));
    }
    switch (screen) {
      case HeroScreen.compound: Navigator.pop(context); break;
      case HeroScreen.simple:   push(SimpleInterestScreen(languageCode: _languageCode)); break;
      case HeroScreen.emi:      push(EmiScreen(languageCode: _languageCode)); break;
      case HeroScreen.land:     push(LandScreen(languageCode: _languageCode)); break;
      case HeroScreen.currency: push(CurrencyScreen(languageCode: _languageCode)); break;
      case HeroScreen.history:
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (_) => HistoryScreen(languageCode: _languageCode)));
        break;
      case HeroScreen.report:   push(ReportScreen(languageCode: _languageCode)); break;
      case HeroScreen.widget:   push(WidgetSettingsScreen(languageCode: _languageCode)); break;
      default: break;
    }
  }

  // ── Mode tabs ────────────────────────────────────────────────────────────
  Widget _modeTabs() {
    final tabs = [
      {'mode': _PLMode.costSell,      'icon': Icons.swap_horiz_rounded,       'label': t('लागत\n÷ बिक्री', 'लागत ÷ बिक्री', 'Cost\n÷ Sell')},
      {'mode': _PLMode.percentProfit, 'icon': Icons.trending_up_rounded,       'label': t('नाफा\n%', 'लाभ %', 'Profit\n%')},
      {'mode': _PLMode.percentLoss,   'icon': Icons.trending_down_rounded,     'label': t('नोक्सान\n%', 'हानि %', 'Loss\n%')},
      {'mode': _PLMode.markup,        'icon': Icons.price_change_rounded,      'label': t('मार्कअप\n%', 'मार्कअप %', 'Markup\n%')},
    ];
    final colors = [AppColors.blue, AppColors.green, AppColors.red, AppColors.amber];

    return Row(children: List.generate(tabs.length, (i) {
      final m = tabs[i]['mode'] as _PLMode;
      final sel = _mode == m;
      final color = colors[i];
      return Expanded(child: GestureDetector(
        onTap: () => setState(() { _mode = m; _result = null; _errorMsg = ''; }),
        child: Container(
          margin: EdgeInsets.only(right: i < tabs.length - 1 ? 8 : 0),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: sel ? color.withValues(alpha: 0.1) : context.cSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: sel ? color.withValues(alpha: 0.5) : context.cBorder,
              width: sel ? 1.5 : 1,
            ),
          ),
          child: Column(children: [
            Icon(tabs[i]['icon'] as IconData,
                size: 20, color: sel ? color : context.cText3),
            const SizedBox(height: 4),
            Text(tabs[i]['label'] as String, textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                    color: sel ? color : context.cText3)),
          ]),
        ),
      ));
    }));
  }

  // ── Mode guide card ──────────────────────────────────────────────────────
  Widget _modeGuide() {
    String title, desc, formula;
    Color color;
    IconData icon;
    switch (_mode) {
      case _PLMode.costSell:
        color = AppColors.blue; icon = Icons.swap_horiz_rounded;
        title = t('लागत र बिक्री मूल्यबाट', 'लागत व बिक्री मूल्य से', 'From Cost & Selling Price');
        desc  = t('सामानको लागत र बिक्री मूल्य प्रविष्ट गर्नुहोस्',
                  'वस्तु की लागत और बिक्री मूल्य दर्ज करें',
                  'Enter the cost price and selling price of the item');
        formula = 'Profit/Loss = Sell − Cost';
        break;
      case _PLMode.percentProfit:
        color = AppColors.green; icon = Icons.trending_up_rounded;
        title = t('लागतमा नाफा % थपेर', 'लागत पर लाभ % जोड़कर', 'Cost + Profit %');
        desc  = t('लागत मूल्य र नाफाको प्रतिशत भर्नुहोस् — बिक्री मूल्य निकाल्छ',
                  'लागत मूल्य और लाभ % भरें — बिक्री मूल्य निकाला जाएगा',
                  'Enter cost price and desired profit % — calculates selling price');
        formula = 'Sell = Cost × (1 + Profit% / 100)';
        break;
      case _PLMode.percentLoss:
        color = AppColors.red; icon = Icons.trending_down_rounded;
        title = t('लागतमा नोक्सान % घटाएर', 'लागत पर हानि % घटाकर', 'Cost − Loss %');
        desc  = t('लागत मूल्य र नोक्सानको प्रतिशत भर्नुहोस् — बिक्री मूल्य निकाल्छ',
                  'लागत मूल्य और हानि % भरें — बिक्री मूल्य निकाला जाएगा',
                  'Enter cost price and loss % — calculates selling price');
        formula = 'Sell = Cost × (1 − Loss% / 100)';
        break;
      case _PLMode.markup:
        color = AppColors.amber; icon = Icons.price_change_rounded;
        title = t('मार्कअप (लागतमाथि मुनाफा)', 'मार्कअप (लागत पर मुनाफा)', 'Markup on Cost');
        desc  = t('लागत मूल्य र मार्कअप % प्रविष्ट गर्नुहोस् — नाफा र बिक्री मूल्य देखाउँछ',
                  'लागत मूल्य और मार्कअप % दर्ज करें — लाभ और बिक्री मूल्य दिखाएगा',
                  'Enter cost and markup % — shows profit amount and selling price');
        formula = 'Sell = Cost × (1 + Markup% / 100)';
        break;
    }
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Expanded(child: Text(title,
              style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w800))),
        ]),
        const SizedBox(height: 6),
        Text(desc, style: TextStyle(color: context.cText3, fontSize: 11)),
        const SizedBox(height: 6),
        Text(formula, style: TextStyle(color: color, fontSize: 11,
            fontWeight: FontWeight.w700, fontStyle: FontStyle.italic)),
      ]),
    );
  }

  // ── Input fields per mode ────────────────────────────────────────────────
  Widget _buildInputs() {
    switch (_mode) {
      case _PLMode.costSell:
        return Column(children: [
          _field(_costCtrl, t('लागत मूल्य (Cost Price)', 'लागत मूल्य', 'Cost Price'),
              AppColors.blue, 'रु.', Icons.shopping_cart_rounded),
          const SizedBox(height: 14),
          _field(_sellCtrl, t('बिक्री मूल्य (Selling Price)', 'बिक्री मूल्य', 'Selling Price'),
              AppColors.indigo, 'रु.', Icons.sell_rounded),
        ]);

      case _PLMode.percentProfit:
        return Column(children: [
          _field(_costPctCtrl, t('लागत मूल्य (Cost Price)', 'लागत मूल्य', 'Cost Price'),
              AppColors.blue, 'रु.', Icons.shopping_cart_rounded),
          const SizedBox(height: 14),
          _field(_pctCtrl, t('नाफाको प्रतिशत (Profit %)', 'लाभ प्रतिशत', 'Profit %'),
              AppColors.green, '%', Icons.trending_up_rounded, isSuffix: true),
        ]);

      case _PLMode.percentLoss:
        return Column(children: [
          _field(_costPctCtrl, t('लागत मूल्य (Cost Price)', 'लागत मूल्य', 'Cost Price'),
              AppColors.blue, 'रु.', Icons.shopping_cart_rounded),
          const SizedBox(height: 14),
          _field(_pctCtrl, t('नोक्सानको प्रतिशत (Loss %)', 'हानि प्रतिशत', 'Loss %'),
              AppColors.red, '%', Icons.trending_down_rounded, isSuffix: true),
        ]);

      case _PLMode.markup:
        return Column(children: [
          _field(_mkCostCtrl, t('लागत मूल्य (Cost Price)', 'लागत मूल्य', 'Cost Price'),
              AppColors.blue, 'रु.', Icons.shopping_cart_rounded),
          const SizedBox(height: 14),
          _field(_mkPctCtrl, t('मार्कअप प्रतिशत (Markup %)', 'मार्कअप %', 'Markup %'),
              AppColors.amber, '%', Icons.price_change_rounded, isSuffix: true),
        ]);
    }
  }

  Widget _field(TextEditingController ctrl, String label, Color color,
      String affix, IconData icon, {bool isSuffix = false}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700),
          overflow: TextOverflow.ellipsis),
      const SizedBox(height: 6),
      TextField(
        controller: ctrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
        style: TextStyle(color: context.cText1, fontSize: 17, fontWeight: FontWeight.w700),
        onChanged: (_) => setState(() => _result = null),
        decoration: InputDecoration(
          hintText: '0',
          hintStyle: TextStyle(color: context.cHint),
          prefixIcon: isSuffix ? null : Padding(
            padding: const EdgeInsets.only(left: 14, right: 8),
            child: Text(affix, style: TextStyle(color: context.cText4,
                fontSize: 14, fontWeight: FontWeight.w600)),
          ),
          prefixIconConstraints: isSuffix ? null : const BoxConstraints(minWidth: 0, minHeight: 0),
          suffixIcon: isSuffix
              ? Padding(padding: const EdgeInsets.only(right: 14),
                  child: Text(affix, style: TextStyle(color: context.cText4,
                      fontSize: 14, fontWeight: FontWeight.w600)))
              : Icon(icon, color: color.withValues(alpha: 0.6), size: 18),
          suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
          filled: true, fillColor: context.cSurface,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.cBorder)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.cBorder)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: color, width: 1.5)),
        ),
      ),
    ]);
  }

  // ── Shared UI ────────────────────────────────────────────────────────────
  Widget _errorBanner() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
    decoration: BoxDecoration(color: AppColors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.red.withValues(alpha: 0.3))),
    child: Row(children: [
      const Icon(Icons.error_outline_rounded, color: AppColors.red, size: 16),
      const SizedBox(width: 8),
      Expanded(child: Text(_errorMsg,
          style: const TextStyle(color: AppColors.red, fontSize: 13, fontWeight: FontWeight.w500))),
    ]),
  );

  Widget _calcButton() => SizedBox(
    width: double.infinity, height: 52,
    child: ElevatedButton.icon(
      onPressed: _calculate,
      icon: const Icon(Icons.calculate_rounded, size: 20),
      label: Text(t('नाफा/नोक्सान निकाल्नुहोस्', 'लाभ/हानि निकालें', 'Calculate Profit / Loss'),
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.blue, foregroundColor: Colors.white,
        elevation: 2, shadowColor: AppColors.blue.withValues(alpha: 0.35),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
  );

  // ── Results ──────────────────────────────────────────────────────────────
  Widget _buildResults() {
    final r = _result!;
    final isProfit = r['isProfit'] == '1';
    final diff = double.tryParse(r['rawDiff'] ?? '0') ?? 0;
    final pct = double.tryParse(r['pct'] ?? '0') ?? 0;
    final resultColor = isProfit ? AppColors.green : AppColors.red;
    final resultGradient = isProfit ? AppTheme.greenGradient : const LinearGradient(
      begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: [Color(0xFFDC2626), Color(0xFFEA580C)],
    );
    final resultIcon = isProfit ? Icons.trending_up_rounded : Icons.trending_down_rounded;
    final resultLabel = isProfit
        ? t('नाफा', 'लाभ', 'Profit')
        : t('नोक्सान', 'हानि', 'Loss');

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // ── Main result card (gradient) ───────────────────────────────────
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: resultGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(
            color: resultColor.withValues(alpha: 0.30),
            blurRadius: 16, offset: const Offset(0, 6),
          )],
        ),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(resultIcon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Text(resultLabel,
                style: const TextStyle(color: Colors.white70, fontSize: 14,
                    fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 12),
          Text('रु. ${r['diff']}',
              style: const TextStyle(color: Colors.white, fontSize: 32,
                  fontWeight: FontWeight.w900, letterSpacing: 0.5)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('${pct.toStringAsFixed(2)}%  $resultLabel',
                style: const TextStyle(color: Colors.white, fontSize: 13,
                    fontWeight: FontWeight.w700)),
          ),
        ]),
      ),

      const SizedBox(height: 16),

      // ── Breakdown card ────────────────────────────────────────────────
      Container(
        decoration: BoxDecoration(
          color: context.cSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.cBorder),
          boxShadow: context.cardShadow,
        ),
        child: Column(children: [
          _resultRow(Icons.shopping_cart_rounded, AppColors.blue,
              t('लागत मूल्य', 'लागत मूल्य', 'Cost Price'), 'रु. ${r['cost']}'),
          Divider(color: context.cBorder, height: 1),
          _resultRow(Icons.sell_rounded, AppColors.indigo,
              t('बिक्री मूल्य', 'बिक्री मूल्य', 'Selling Price'), 'रु. ${r['sell']}'),
          Divider(color: context.cBorder, height: 1),
          _resultRow(resultIcon, resultColor,
              '$resultLabel ${t('रकम', 'राशि', 'Amount')}',
              '${diff >= 0 ? '+' : '−'} रु. ${r['diff']}',
              valueColor: resultColor),
          Divider(color: context.cBorder, height: 1),
          _resultRow(Icons.percent_rounded, AppColors.amber,
              '$resultLabel %',
              '${diff >= 0 ? '+' : '−'}${pct.toStringAsFixed(2)}%',
              valueColor: resultColor),
          Divider(color: context.cBorder, height: 1),
          _resultRow(Icons.price_change_rounded, AppColors.purple,
              t('मार्कअप %', 'मार्कअप %', 'Markup %'),
              '${double.tryParse(r['markup'] ?? '0')! >= 0 ? '+' : ''}${r['markup']}%'),
        ]),
      ),

      const SizedBox(height: 20),

      // ── Break-even tip ────────────────────────────────────────────────
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.blue.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.blue.withValues(alpha: 0.15)),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.blue, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(t('जानकारी', 'जानकारी', 'Info'),
                style: const TextStyle(color: AppColors.blue, fontSize: 12,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(
              isProfit
                ? t('यस सामानमा तपाईंले लागतको ${pct.toStringAsFixed(2)}% नाफा कमाउनुभयो।',
                    'इस वस्तु पर आपने लागत का ${pct.toStringAsFixed(2)}% लाभ कमाया।',
                    'You earned ${pct.toStringAsFixed(2)}% profit on the cost of this item.')
                : t('यस सामानमा तपाईंले लागतको ${pct.toStringAsFixed(2)}% नोक्सान व्यहोर्नु भयो।',
                    'इस वस्तु पर आपको लागत का ${pct.toStringAsFixed(2)}% हानि हुई।',
                    'You incurred a ${pct.toStringAsFixed(2)}% loss on the cost of this item.'),
              style: TextStyle(color: context.cText3, fontSize: 11),
            ),
          ])),
        ]),
      ),
    ]);
  }

  Widget _resultRow(IconData icon, Color color, String label, String value,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(label,
            style: TextStyle(color: context.cText3, fontSize: 13))),
        Text(value, style: TextStyle(
            color: valueColor ?? context.cText1,
            fontSize: 14, fontWeight: FontWeight.w800)),
      ]),
    );
  }
}
