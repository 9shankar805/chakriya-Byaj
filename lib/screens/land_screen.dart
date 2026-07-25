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
import 'emi_screen.dart';
import 'currency_screen.dart';
import 'report_screen.dart';
import 'widget_settings_screen.dart';
import 'civil_calc_screen.dart';
import 'profit_loss_screen.dart';
import 'input_screen.dart';
import '../widgets/civil_calc_fab.dart';

// ── Exact conversion constants (source: lalpurjanepal.com.np) ──
class _LC {
  static const double damSqFt    = 21.390625;
  static const double paisaSqFt  = 85.5625;
  static const double aanaSqFt   = 342.25;
  static const double ropaniSqFt = 5476.0;
  static const double dhurSqFt   = 182.25;
  static const double katthaSqFt = 3645.0;
  static const double bighaSqFt  = 72900.0;
  static const double sqMToSqFt  = 10.7639;
  static const double acreToSqFt = 43560.0;
  static const double haToSqFt   = 107639.1;
}

enum _Shape { rectangle, irregular, triangle, trapezoid }
// top-level mode
enum _Mode  { regular, irregular }

class LandScreen extends StatefulWidget {
  final bool? isNepali;
  final String? languageCode;
  const LandScreen({super.key, this.isNepali, this.languageCode});
  @override
  State<LandScreen> createState() => _LandScreenState();
}

class _LandScreenState extends State<LandScreen>
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

  _Mode  _mode  = _Mode.regular;
  _Shape _shape = _Shape.rectangle;
  int _inputUnit = 0; // 0=feet 1=meters

  // Rectangle — dynamic lists
  List<TextEditingController> _lenCtrls = [TextEditingController()];
  List<TextEditingController> _widCtrls = [TextEditingController()];
  List<FocusNode> _lenFocus = [FocusNode()];
  List<FocusNode> _widFocus = [FocusNode()];

  // Irregular 4-sided (A,B,C,D sides + diagonal d1) — dynamic lists
  List<TextEditingController> _sACtrls = [TextEditingController()];
  List<TextEditingController> _sBCtrls = [TextEditingController()];
  List<TextEditingController> _sCCtrls = [TextEditingController()];
  List<TextEditingController> _sDCtrls = [TextEditingController()];
  List<TextEditingController> _d1Ctrls = [TextEditingController()];
  List<FocusNode> _saFocus = [FocusNode()];
  List<FocusNode> _sbFocus = [FocusNode()];
  List<FocusNode> _scFocus = [FocusNode()];
  List<FocusNode> _sdFocus = [FocusNode()];
  List<FocusNode> _d1Focus = [FocusNode()];

  // Triangle (3 sides — Heron's formula) — dynamic lists
  List<TextEditingController> _tACtrls = [TextEditingController()];
  List<TextEditingController> _tBCtrls = [TextEditingController()];
  List<TextEditingController> _tCCtrls = [TextEditingController()];
  List<FocusNode> _taFocus = [FocusNode()];
  List<FocusNode> _tbFocus = [FocusNode()];
  List<FocusNode> _tcFocus = [FocusNode()];

  // Trapezoid (parallel sides a,b + height h) — dynamic lists
  List<TextEditingController> _paCtrls = [TextEditingController()];
  List<TextEditingController> _pbCtrls = [TextEditingController()];
  List<TextEditingController> _phCtrls = [TextEditingController()];
  List<FocusNode> _paFocus = [FocusNode()];
  List<FocusNode> _pbFocusNodes = [FocusNode()];
  List<FocusNode> _phFocus = [FocusNode()];

  // Irregular avg mode — dynamic lists
  List<TextEditingController> _irrLengths  = [TextEditingController()];
  List<TextEditingController> _irrBreadths = [TextEditingController()];
  // Focus nodes for dynamic fields
  List<FocusNode> _irrLengthFocus  = [FocusNode()];
  List<FocusNode> _irrBreadthFocus = [FocusNode()];

  Map<String, String>? _result;
  String _errorMsg = '';

  late final AnimationController _animCtrl;
  late final Animation<double>   _fadeAnim;


  final _scrollCtrl = ScrollController();

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
    _scrollCtrl.dispose();
    _animCtrl.dispose();
    for (final c in [..._lenCtrls, ..._widCtrls,
        ..._sACtrls, ..._sBCtrls, ..._sCCtrls, ..._sDCtrls, ..._d1Ctrls,
        ..._tACtrls, ..._tBCtrls, ..._tCCtrls,
        ..._paCtrls, ..._pbCtrls, ..._phCtrls,
        ..._irrLengths, ..._irrBreadths]) {
      c.dispose();
    }
    for (final f in [..._lenFocus, ..._widFocus,
        ..._saFocus, ..._sbFocus, ..._scFocus, ..._sdFocus, ..._d1Focus,
        ..._taFocus, ..._tbFocus, ..._tcFocus,
        ..._paFocus, ..._pbFocusNodes, ..._phFocus,
        ..._irrLengthFocus, ..._irrBreadthFocus]) {
      f.dispose();
    }
    super.dispose();
  }

  void _clearAll() {
    for (final c in [..._lenCtrls, ..._widCtrls,
        ..._sACtrls, ..._sBCtrls, ..._sCCtrls, ..._sDCtrls, ..._d1Ctrls,
        ..._tACtrls, ..._tBCtrls, ..._tCCtrls,
        ..._paCtrls, ..._pbCtrls, ..._phCtrls]) {
      c.dispose();
    }
    for (final f in [..._lenFocus, ..._widFocus,
        ..._saFocus, ..._sbFocus, ..._scFocus, ..._sdFocus, ..._d1Focus,
        ..._taFocus, ..._tbFocus, ..._tcFocus,
        ..._paFocus, ..._pbFocusNodes, ..._phFocus]) {
      f.dispose();
    }
    for (final c in [..._irrLengths, ..._irrBreadths]) c.dispose();
    for (final f in [..._irrLengthFocus, ..._irrBreadthFocus]) f.dispose();
    setState(() {
      _lenCtrls = [TextEditingController()];
      _widCtrls = [TextEditingController()];
      _lenFocus = [FocusNode()];
      _widFocus = [FocusNode()];
      _sACtrls = [TextEditingController()];
      _sBCtrls = [TextEditingController()];
      _sCCtrls = [TextEditingController()];
      _sDCtrls = [TextEditingController()];
      _d1Ctrls = [TextEditingController()];
      _saFocus = [FocusNode()];
      _sbFocus = [FocusNode()];
      _scFocus = [FocusNode()];
      _sdFocus = [FocusNode()];
      _d1Focus = [FocusNode()];
      _tACtrls = [TextEditingController()];
      _tBCtrls = [TextEditingController()];
      _tCCtrls = [TextEditingController()];
      _taFocus = [FocusNode()];
      _tbFocus = [FocusNode()];
      _tcFocus = [FocusNode()];
      _paCtrls = [TextEditingController()];
      _pbCtrls = [TextEditingController()];
      _phCtrls = [TextEditingController()];
      _paFocus = [FocusNode()];
      _pbFocusNodes = [FocusNode()];
      _phFocus = [FocusNode()];
      _irrLengths      = [TextEditingController()];
      _irrBreadths     = [TextEditingController()];
      _irrLengthFocus  = [FocusNode()];
      _irrBreadthFocus = [FocusNode()];
      _result = null;
      _errorMsg = '';
    });
  }

  double _v(TextEditingController c) {
    double val = double.tryParse(c.text.trim()) ?? 0;
    return _inputUnit == 1 ? val * 3.28084 : val;
  }

  // Heron's formula for triangle area given 3 sides
  double _heronArea(double a, double b, double c) {
    final s = (a + b + c) / 2;
    final val = s * (s - a) * (s - b) * (s - c);
    if (val <= 0) return 0;
    return math.sqrt(val);
  }

  void _calculate() {
    FocusScope.of(context).unfocus();
    setState(() { _errorMsg = ''; _result = null; });

    double sqFt = 0;

    if (_mode == _Mode.irregular) {
      final lVals = _irrLengths.map(_v).where((v) => v > 0).toList();
      final bVals = _irrBreadths.map(_v).where((v) => v > 0).toList();
      if (lVals.isEmpty || bVals.isEmpty) { _err(); return; }
      final avgL = lVals.reduce((a, b) => a + b) / lVals.length;
      final avgB = bVals.reduce((a, b) => a + b) / bVals.length;
      sqFt = avgL * avgB;

    } else if (_shape == _Shape.rectangle) {
      final lVals = _lenCtrls.map(_v).where((v) => v > 0).toList();
      final wVals = _widCtrls.map(_v).where((v) => v > 0).toList();
      if (lVals.isEmpty || wVals.isEmpty) { _err(); return; }
      final avgL = lVals.reduce((a, b) => a + b) / lVals.length;
      final avgW = wVals.reduce((a, b) => a + b) / wVals.length;
      sqFt = avgL * avgW;

    } else if (_shape == _Shape.triangle) {
      final aVals = _tACtrls.map(_v).where((v) => v > 0).toList();
      final bVals = _tBCtrls.map(_v).where((v) => v > 0).toList();
      final cVals = _tCCtrls.map(_v).where((v) => v > 0).toList();
      if (aVals.isEmpty || bVals.isEmpty || cVals.isEmpty) { _err(); return; }
      final a = aVals.reduce((x, y) => x + y) / aVals.length;
      final b = bVals.reduce((x, y) => x + y) / bVals.length;
      final c = cVals.reduce((x, y) => x + y) / cVals.length;
      if (a + b <= c || a + c <= b || b + c <= a) {
        setState(() => _errorMsg = _isNepali
            ? 'त्रिभुजका भुजाहरू मान्य छैनन्' : 'Invalid triangle sides');
        return;
      }
      sqFt = _heronArea(a, b, c);

    } else if (_shape == _Shape.trapezoid) {
      final aVals = _paCtrls.map(_v).where((v) => v > 0).toList();
      final bVals = _pbCtrls.map(_v).where((v) => v > 0).toList();
      final hVals = _phCtrls.map(_v).where((v) => v > 0).toList();
      if (aVals.isEmpty || bVals.isEmpty || hVals.isEmpty) { _err(); return; }
      final a = aVals.reduce((x, y) => x + y) / aVals.length;
      final b = bVals.reduce((x, y) => x + y) / bVals.length;
      final h = hVals.reduce((x, y) => x + y) / hVals.length;
      sqFt = ((a + b) / 2) * h;

    } else if (_shape == _Shape.irregular) {
      final aVals = _sACtrls.map(_v).where((v) => v > 0).toList();
      final bVals = _sBCtrls.map(_v).where((v) => v > 0).toList();
      final cVals = _sCCtrls.map(_v).where((v) => v > 0).toList();
      final dVals = _sDCtrls.map(_v).where((v) => v > 0).toList();
      final diagVals = _d1Ctrls.map(_v).where((v) => v > 0).toList();
      if (aVals.isEmpty || bVals.isEmpty || cVals.isEmpty || dVals.isEmpty || diagVals.isEmpty) { _err(); return; }
      final a    = aVals.reduce((x, y) => x + y) / aVals.length;
      final b    = bVals.reduce((x, y) => x + y) / bVals.length;
      final c    = cVals.reduce((x, y) => x + y) / cVals.length;
      final d    = dVals.reduce((x, y) => x + y) / dVals.length;
      final diag = diagVals.reduce((x, y) => x + y) / diagVals.length;
      final t1 = _heronArea(a, b, diag);
      final t2 = _heronArea(c, d, diag);
      if (t1 <= 0 || t2 <= 0) {
        setState(() => _errorMsg = _isNepali
            ? 'नाप मान्य छैन — विकर्ण जाँच गर्नुहोस्' : 'Invalid — check diagonal');
        return;
      }
      sqFt = t1 + t2;
    }

    if (sqFt <= 0) { _err(); return; }
    _buildResult(sqFt);
  }

  void _err() => setState(() => _errorMsg = _isNepali
      ? 'कृपया सबै नाप भर्नुहोस्' : 'Please fill all measurements');

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _buildResult(double sqFt) {
    final sqM  = sqFt / _LC.sqMToSqFt;
    final acre = sqFt / _LC.acreToSqFt;
    final ha   = sqFt / _LC.haToSqFt;

    // Hill breakdown
    final ropani = (sqFt / _LC.ropaniSqFt).floor();
    final aana   = ((sqFt - ropani * _LC.ropaniSqFt) / _LC.aanaSqFt).floor();
    final paisa  = ((sqFt - ropani * _LC.ropaniSqFt - aana * _LC.aanaSqFt) / _LC.paisaSqFt).floor();
    final dam    = ((sqFt - ropani * _LC.ropaniSqFt - aana * _LC.aanaSqFt - paisa * _LC.paisaSqFt) / _LC.damSqFt).round();

    // Terai breakdown
    final bigha  = (sqFt / _LC.bighaSqFt).floor();
    final kattha = ((sqFt - bigha * _LC.bighaSqFt) / _LC.katthaSqFt).floor();
    final dhur   = ((sqFt - bigha * _LC.bighaSqFt - kattha * _LC.katthaSqFt) / _LC.dhurSqFt).round();

    setState(() {
      _result = {
        'sqft': sqFt.toStringAsFixed(2),
        'sqm':  sqM.toStringAsFixed(2),
        'acre': acre.toStringAsFixed(4),
        'ha':   ha.toStringAsFixed(4),
        'ropani': '$ropani', 'aana': '$aana', 'paisa': '$paisa', 'dam': '$dam',
        'ropaniDec': (sqFt / _LC.ropaniSqFt).toStringAsFixed(4),
        'bigha': '$bigha', 'kattha': '$kattha', 'dhur': '$dhur',
        'bighaDec': (sqFt / _LC.bighaSqFt).toStringAsFixed(4),
      };
    });
  }

  String _fmtNum(String v) {
    final parts = v.split('.');
    String out = '';
    final len = parts[0].length;
    for (int i = 0; i < len; i++) {
      if (i > 0 && (len - i) % 3 == 0) out += ',';
      out += parts[0][i];
    }
    return parts.length > 1 ? '$out.${parts[1]}' : out;
  }

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
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const SizedBox(height: 20),
                  _modeToggle(),
                  const SizedBox(height: 16),
                  if (_mode == _Mode.regular) ...[
                    _unitToggle(),
                    const SizedBox(height: 16),
                    _shapeTabs(),
                    const SizedBox(height: 20),
                    _shapeGuide(),
                    const SizedBox(height: 20),
                    _buildRegularInputs(),
                  ] else ...[
                    _unitToggle(),
                    const SizedBox(height: 20),
                    _irregularAvgInputs(),
                  ],
                  const SizedBox(height: 24),
                  if (_errorMsg.isNotEmpty) ...[_errorBanner(), const SizedBox(height: 16)],
                  _calcButton(),
                  if (_result != null) ...[const SizedBox(height: 28), _buildResults()],
                  const SizedBox(height: 32),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  // ── Header ───────────────────────────────────────
  Widget _buildHeader() {
    return AppHeroHeader(
      languageCode: _languageCode,
      title: _isNepali ? 'जग्गा क्षेत्रफल' : (_isHindi ? 'भूमि क्षेत्रफल' : 'Land Area Calculator'),
      activeScreen: HeroScreen.land,
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
            Text(getTxt('रिसेट', 'रीसेट', 'Reset'),
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
          ]),
        ),
      ),
    );
  }

  void _showAppGrid() {
    showAppDrawer(
      context: context,
      languageCode: _languageCode,
      activeScreen: HeroScreen.land,
      onNavigate: _handleQuickNav,
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
      case HeroScreen.currency: push(CurrencyScreen(languageCode: _languageCode)); break;
      case HeroScreen.history:  Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => HistoryScreen(languageCode: _languageCode))); break;
      case HeroScreen.report:   push(ReportScreen(languageCode: _languageCode)); break;
      case HeroScreen.widget:   push(WidgetSettingsScreen(languageCode: _languageCode)); break;
      case HeroScreen.other:    push(ProfitLossScreen(languageCode: _languageCode)); break;
      default: break;
    }
  }

  // ── Unit toggle (feet / meters) ──────────────────
  Widget _unitToggle() {
    return Row(children: [
      Text(_isNepali ? 'नाप एकाइ:' : 'Input Unit:',
          style: TextStyle(color: context.cText3, fontSize: 13, fontWeight: FontWeight.w600)),
      const SizedBox(width: 12),
      _unitBtn(0, _isNepali ? 'फिट (ft)' : 'Feet (ft)', AppColors.blue),
      const SizedBox(width: 8),
      _unitBtn(1, _isNepali ? 'मिटर (m)' : 'Meter (m)', AppColors.indigo),
    ]);
  }

  Widget _unitBtn(int idx, String label, Color color) {
    final sel = _inputUnit == idx;
    return GestureDetector(
      onTap: () => setState(() { _inputUnit = idx; _result = null; }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: sel ? color.withValues(alpha: 0.1) : context.cSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: sel ? color.withValues(alpha: 0.4) : context.cBorder,
              width: sel ? 1.5 : 1),
        ),
        child: Text(label, style: TextStyle(color: sel ? color : context.cText3,
            fontSize: 12, fontWeight: FontWeight.w700)),
      ),
    );
  }

  // ── Shape tabs ───────────────────────────────────
  Widget _shapeTabs() {
    final shapes = [
      {'shape': _Shape.rectangle, 'icon': '▭', 'label': _isNepali ? 'आयत' : 'Rectangle'},
      {'shape': _Shape.irregular, 'icon': '⬠', 'label': _isNepali ? '४ भुजा\n(विकर्ण)' : '4-Side\n(Diagonal)'},
      {'shape': _Shape.triangle,  'icon': '△', 'label': _isNepali ? 'त्रिभुज' : 'Triangle'},
      {'shape': _Shape.trapezoid, 'icon': '⏢', 'label': _isNepali ? 'ट्रापिजियम' : 'Trapezoid'},
    ];
    return Row(children: shapes.asMap().entries.map((e) {
      final s = e.value['shape'] as _Shape;
      final sel = _shape == s;
      const colors = [AppColors.blue, AppColors.green, AppColors.cyan, AppColors.amber];
      final color = colors[e.key];
      return Expanded(child: GestureDetector(
        onTap: () => setState(() { _shape = s; _result = null; _errorMsg = ''; }),
        child: Container(
          margin: EdgeInsets.only(right: e.key < 3 ? 6 : 0),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: sel ? color.withValues(alpha: 0.1) : context.cSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: sel ? color.withValues(alpha: 0.5) : context.cBorder,
                width: sel ? 1.5 : 1),
          ),
          child: Column(children: [
            Text(e.value['icon'] as String,
                style: TextStyle(fontSize: 20, color: sel ? color : context.cText3)),
            const SizedBox(height: 4),
            Text(e.value['label'] as String, textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                    color: sel ? color : context.cText3)),
          ]),
        ),
      ));
    }).toList());
  }

  // ── Shape guide card ─────────────────────────────
  Widget _shapeGuide() {
    String title, desc, formula;
    Color color;
    if (_shape == _Shape.rectangle) {
      color = AppColors.blue;
      title = _isNepali ? 'आयत / वर्गाकार जग्गा' : 'Rectangle / Square Plot';
      desc  = _isNepali ? 'चारै कुना ठीक भएको जग्गाको लम्बाइ र चौडाइ नाप्नुहोस्' : 'Measure length and width of a regular plot';
      formula = 'Area = L × W';
    } else if (_shape == _Shape.irregular) {
      color = AppColors.green;
      title = _isNepali ? 'अनियमित ४ भुजाको जग्गा' : 'Irregular 4-Sided Field';
      desc  = _isNepali
          ? 'चार भुजा (A,B,C,D) र एक विकर्ण (d) नाप्नुहोस् — विकर्णले दुई त्रिभुजमा विभाजन गर्छ'
          : 'Measure 4 sides (A,B,C,D) + 1 diagonal (d) — splits into 2 triangles via Heron\'s formula';
      formula = 'Area = △(A,B,d) + △(C,D,d)';
    } else if (_shape == _Shape.triangle) {
      color = AppColors.cyan;
      title = _isNepali ? 'त्रिभुजाकार जग्गा' : 'Triangular Plot';
      desc  = _isNepali ? 'तीनै भुजा नाप्नुहोस् — हेरोनको सूत्र प्रयोग हुन्छ' : 'Measure all 3 sides — uses Heron\'s formula';
      formula = 's=(a+b+c)/2  →  Area=√(s·(s-a)·(s-b)·(s-c))';
    } else {
      color = AppColors.amber;
      title = _isNepali ? 'ट्रापिजियम जग्गा' : 'Trapezoid / Irregular Field';
      desc  = _isNepali
          ? 'दुई समानान्तर भुजा र उचाइ नाप्नुहोस् — नेपालको खेत प्रायः यस्तै हुन्छ'
          : 'Measure 2 parallel sides + height — common for Nepal farming fields';
      formula = 'Area = ((a + b) / 2) × h';
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
          Icon(Icons.info_outline_rounded, color: color, size: 14),
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

  // ── Mode toggle ──────────────────────────────────
  Widget _modeToggle() {
    return Row(children: [
      Expanded(child: _modeBtn(_Mode.regular,
          _isNepali ? '▭  नियमित आकार' : '▭  Regular Shape',
          _isNepali ? 'आयत • त्रिभुज • ट्रापिजियम' : 'Rectangle • Triangle • Trapezoid',
          AppColors.blue)),
      const SizedBox(width: 10),
      Expanded(child: _modeBtn(_Mode.irregular,
          _isNepali ? '⬠  अनियमित आकार' : '⬠  Irregular Shape',
          _isNepali ? 'औसत लम्बाइ × औसत चौडाइ' : 'Avg Length × Avg Breadth',
          AppColors.green)),
    ]);
  }

  Widget _modeBtn(_Mode m, String title, String sub, Color color) {
    final sel = _mode == m;
    return GestureDetector(
      onTap: () => setState(() { _mode = m; _result = null; _errorMsg = ''; }),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: sel ? color.withValues(alpha: 0.1) : context.cSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: sel ? color.withValues(alpha: 0.5) : context.cBorder,
              width: sel ? 2 : 1),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(color: sel ? color : context.cText2,
              fontSize: 13, fontWeight: FontWeight.w800)),
          const SizedBox(height: 3),
          Text(sub, style: TextStyle(color: sel ? color.withValues(alpha: 0.7) : context.cText4,
              fontSize: 10, fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }

  // ── Irregular avg inputs with + button ───────────
  Widget _irregularAvgInputs() {
    final lVals = _irrLengths.map(_v).where((v) => v > 0).toList();
    final bVals = _irrBreadths.map(_v).where((v) => v > 0).toList();
    final avgL = lVals.isEmpty ? 0.0 : lVals.reduce((a, b) => a + b) / lVals.length;
    final avgB = bVals.isEmpty ? 0.0 : bVals.reduce((a, b) => a + b) / bVals.length;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Info card
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.green.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.green.withValues(alpha: 0.2)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.info_outline_rounded, color: AppColors.green, size: 14),
            const SizedBox(width: 6),
            Text(_isNepali ? 'अनियमित जग्गाको क्षेत्रफल' : 'Irregular Field Area',
                style: const TextStyle(color: AppColors.green, fontSize: 13, fontWeight: FontWeight.w800)),
          ]),
          const SizedBox(height: 6),
          Text(
            _isNepali
                ? 'जग्गाको विभिन्न ठाउँमा लम्बाइ र चौडाइ नाप्नुहोस् — जति धेरै नाप, उति सटीक नतिजा'
                : 'Measure length & breadth at multiple points — more readings = more accurate result',
            style: TextStyle(color: context.cText3, fontSize: 11),
          ),
          const SizedBox(height: 6),
          Text('Area = Avg(L1,L2...) × Avg(B1,B2...)',
              style: const TextStyle(color: AppColors.green, fontSize: 11,
                  fontWeight: FontWeight.w700, fontStyle: FontStyle.italic)),
        ]),
      ),

      const SizedBox(height: 20),

      // LENGTH section
      Row(children: [
        Container(width: 3, height: 16,
            decoration: BoxDecoration(color: AppColors.blue, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 8),
        Text(_isNepali ? 'लम्बाइ (L)' : 'Lengths (L)',
            style: const TextStyle(color: AppColors.blue, fontSize: 14, fontWeight: FontWeight.w700)),
        const Spacer(),
        if (lVals.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${_isNepali ? "औसत" : "Avg"}: ${avgL.toStringAsFixed(2)} ${_inputUnit == 0 ? "ft" : "m"}',
              style: const TextStyle(color: AppColors.blue, fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ),
      ]),
      const SizedBox(height: 10),
      ..._irrLengths.asMap().entries.map((e) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(children: [
          Expanded(child: _dynField(e.value, _irrLengthFocus[e.key], 'L${e.key + 1}', AppColors.blue)),
          if (_irrLengths.length > 1) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => setState(() {
                e.value.dispose();
                _irrLengthFocus[e.key].dispose();
                _irrLengths.removeAt(e.key);
                _irrLengthFocus.removeAt(e.key);
                _result = null;
              }),
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: AppColors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.red.withValues(alpha: 0.3)),
                ),
                child: const Icon(Icons.remove_rounded, color: AppColors.red, size: 18),
              ),
            ),
          ],
        ]),
      )),
      // Add length button
      GestureDetector(
        onTap: () {
          final fn = FocusNode();
          setState(() {
            _irrLengths.add(TextEditingController());
            _irrLengthFocus.add(fn);
          });
          _scrollToBottom();
          Future.delayed(const Duration(milliseconds: 350), () => fn.requestFocus());
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.blue.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.blue.withValues(alpha: 0.3),
                style: BorderStyle.solid),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.add_circle_rounded, color: AppColors.blue, size: 18),
            const SizedBox(width: 8),
            Text(_isNepali ? '+ लम्बाइ थप्नुहोस्' : '+ Add Length',
                style: const TextStyle(color: AppColors.blue, fontSize: 13, fontWeight: FontWeight.w700)),
          ]),
        ),
      ),

      const SizedBox(height: 24),

      // BREADTH section
      Row(children: [
        Container(width: 3, height: 16,
            decoration: BoxDecoration(color: AppColors.amber, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 8),
        Text(_isNepali ? 'चौडाइ (B)' : 'Breadths (B)',
            style: const TextStyle(color: AppColors.amber, fontSize: 14, fontWeight: FontWeight.w700)),
        const Spacer(),
        if (bVals.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${_isNepali ? "औसत" : "Avg"}: ${avgB.toStringAsFixed(2)} ${_inputUnit == 0 ? "ft" : "m"}',
              style: const TextStyle(color: AppColors.amber, fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ),
      ]),
      const SizedBox(height: 10),
      ..._irrBreadths.asMap().entries.map((e) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(children: [
          Expanded(child: _dynField(e.value, _irrBreadthFocus[e.key], 'B${e.key + 1}', AppColors.amber)),
          if (_irrBreadths.length > 1) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => setState(() {
                e.value.dispose();
                _irrBreadthFocus[e.key].dispose();
                _irrBreadths.removeAt(e.key);
                _irrBreadthFocus.removeAt(e.key);
                _result = null;
              }),
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: AppColors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.red.withValues(alpha: 0.3)),
                ),
                child: const Icon(Icons.remove_rounded, color: AppColors.red, size: 18),
              ),
            ),
          ],
        ]),
      )),
      // Add breadth button
      GestureDetector(
        onTap: () {
          final fn = FocusNode();
          setState(() {
            _irrBreadths.add(TextEditingController());
            _irrBreadthFocus.add(fn);
          });
          _scrollToBottom();
          Future.delayed(const Duration(milliseconds: 350), () => fn.requestFocus());
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.amber.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.amber.withValues(alpha: 0.3)),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.add_circle_rounded, color: AppColors.amber, size: 18),
            const SizedBox(width: 8),
            Text(_isNepali ? '+ चौडाइ थप्नुहोस्' : '+ Add Breadth',
                style: const TextStyle(color: AppColors.amber, fontSize: 13, fontWeight: FontWeight.w700)),
          ]),
        ),
      ),
    ]);
  }

  Widget _dynField(TextEditingController ctrl, FocusNode focusNode, String label, Color color) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
      const SizedBox(height: 5),
      TextField(
        controller: ctrl,
        focusNode: focusNode,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
        style: TextStyle(color: context.cText1, fontSize: 16, fontWeight: FontWeight.w700),
        onChanged: (_) => setState(() => _result = null),
        decoration: InputDecoration(
          hintText: '0',
          hintStyle: TextStyle(color: context.cHint),
          suffixText: _inputUnit == 0 ? 'ft' : 'm',
          suffixStyle: TextStyle(color: context.cText4, fontSize: 12),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 11, horizontal: 12),
          filled: true, fillColor: context.cSurface,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: context.cBorder)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: context.cBorder)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: color, width: 1.5)),
        ),
      ),
    ]);
  }

  // ── Regular shape inputs ─────────────────────────
  Widget _buildRegularInputs() {
    switch (_shape) {
      case _Shape.rectangle:  return _rectInputs();
      case _Shape.irregular:  return _irregInputs();
      case _Shape.triangle:   return _triInputs();
      case _Shape.trapezoid:  return _trapInputs();
    }
  }

  Widget _rectInputs() {
    final lVals = _lenCtrls.map(_v).where((v) => v > 0).toList();
    final wVals = _widCtrls.map(_v).where((v) => v > 0).toList();
    final avgL = lVals.isEmpty ? 0.0 : lVals.reduce((a, b) => a + b) / lVals.length;
    final avgW = wVals.isEmpty ? 0.0 : wVals.reduce((a, b) => a + b) / wVals.length;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // LENGTH
      _dynSectionHeader(_isNepali ? 'लम्बाइ (L)' : 'Length (L)', AppColors.blue,
          lVals.isNotEmpty ? '${_isNepali ? "औसत" : "Avg"}: ${avgL.toStringAsFixed(2)} ${_inputUnit == 0 ? "ft" : "m"}' : null),
      const SizedBox(height: 10),
      ..._lenCtrls.asMap().entries.map((e) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(children: [
          Expanded(child: _dynField(e.value, _lenFocus[e.key], 'L${e.key + 1}', AppColors.blue)),
          if (_lenCtrls.length > 1) ...[
            const SizedBox(width: 8),
            _removeBtn(() => setState(() {
              e.value.dispose(); _lenFocus[e.key].dispose();
              _lenCtrls.removeAt(e.key); _lenFocus.removeAt(e.key);
              _result = null;
            })),
          ],
        ]),
      )),
      _addBtn(_isNepali ? '+ लम्बाइ थप्नुहोस्' : '+ Add Length', AppColors.blue, () {
        final fn = FocusNode();
        setState(() { _lenCtrls.add(TextEditingController()); _lenFocus.add(fn); });
        _scrollToBottom();
        Future.delayed(const Duration(milliseconds: 350), () => fn.requestFocus());
      }),
      const SizedBox(height: 20),
      // WIDTH
      _dynSectionHeader(_isNepali ? 'चौडाइ (W)' : 'Width (W)', AppColors.blue,
          wVals.isNotEmpty ? '${_isNepali ? "औसत" : "Avg"}: ${avgW.toStringAsFixed(2)} ${_inputUnit == 0 ? "ft" : "m"}' : null),
      const SizedBox(height: 10),
      ..._widCtrls.asMap().entries.map((e) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(children: [
          Expanded(child: _dynField(e.value, _widFocus[e.key], 'W${e.key + 1}', AppColors.blue)),
          if (_widCtrls.length > 1) ...[
            const SizedBox(width: 8),
            _removeBtn(() => setState(() {
              e.value.dispose(); _widFocus[e.key].dispose();
              _widCtrls.removeAt(e.key); _widFocus.removeAt(e.key);
              _result = null;
            })),
          ],
        ]),
      )),
      _addBtn(_isNepali ? '+ चौडाइ थप्नुहोस्' : '+ Add Width', AppColors.blue, () {
        final fn = FocusNode();
        setState(() { _widCtrls.add(TextEditingController()); _widFocus.add(fn); });
        _scrollToBottom();
        Future.delayed(const Duration(milliseconds: 350), () => fn.requestFocus());
      }),
    ]);
  }

  Widget _irregInputs() {
    Widget sideSection(
      String headerLabel, String avgLabel, List<TextEditingController> ctrls,
      List<FocusNode> foci, Color color, String prefix,
      void Function() onAdd,
    ) {
      final vals = ctrls.map(_v).where((v) => v > 0).toList();
      final avg = vals.isEmpty ? 0.0 : vals.reduce((a, b) => a + b) / vals.length;
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _dynSectionHeader(headerLabel, color,
            vals.isNotEmpty ? '${_isNepali ? "औसत" : "Avg"}: ${avg.toStringAsFixed(2)} ${_inputUnit == 0 ? "ft" : "m"}' : null),
        const SizedBox(height: 10),
        ...ctrls.asMap().entries.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(children: [
            Expanded(child: _dynField(e.value, foci[e.key], '$prefix${e.key + 1}', color)),
            if (ctrls.length > 1) ...[
              const SizedBox(width: 8),
              _removeBtn(() => setState(() {
                e.value.dispose(); foci[e.key].dispose();
                ctrls.removeAt(e.key); foci.removeAt(e.key);
                _result = null;
              })),
            ],
          ]),
        )),
        _addBtn(_isNepali ? '+ $headerLabel थप्नुहोस्' : '+ Add $headerLabel', color, onAdd),
      ]);
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: context.cSurface2, borderRadius: BorderRadius.circular(10)),
        child: Text(
          '     A\n  ◉────────◉\n  │          │\nD │   d →  │ B\n  │          │\n  ◉────────◉\n     C',
          style: TextStyle(color: context.cText3, fontSize: 11, fontFamily: 'monospace', height: 1.5),
        ),
      ),
      const SizedBox(height: 16),
      sideSection(_isNepali ? 'भुजा A (माथि)' : 'Side A (Top)', 'A', _sACtrls, _saFocus, AppColors.green, 'A', () {
        final fn = FocusNode();
        setState(() { _sACtrls.add(TextEditingController()); _saFocus.add(fn); });
        _scrollToBottom();
        Future.delayed(const Duration(milliseconds: 350), () => fn.requestFocus());
      }),
      const SizedBox(height: 16),
      sideSection(_isNepali ? 'भुजा B (दायाँ)' : 'Side B (Right)', 'B', _sBCtrls, _sbFocus, AppColors.green, 'B', () {
        final fn = FocusNode();
        setState(() { _sBCtrls.add(TextEditingController()); _sbFocus.add(fn); });
        _scrollToBottom();
        Future.delayed(const Duration(milliseconds: 350), () => fn.requestFocus());
      }),
      const SizedBox(height: 16),
      sideSection(_isNepali ? 'भुजा C (तल)' : 'Side C (Bottom)', 'C', _sCCtrls, _scFocus, AppColors.green, 'C', () {
        final fn = FocusNode();
        setState(() { _sCCtrls.add(TextEditingController()); _scFocus.add(fn); });
        _scrollToBottom();
        Future.delayed(const Duration(milliseconds: 350), () => fn.requestFocus());
      }),
      const SizedBox(height: 16),
      sideSection(_isNepali ? 'भुजा D (बायाँ)' : 'Side D (Left)', 'D', _sDCtrls, _sdFocus, AppColors.green, 'D', () {
        final fn = FocusNode();
        setState(() { _sDCtrls.add(TextEditingController()); _sdFocus.add(fn); });
        _scrollToBottom();
        Future.delayed(const Duration(milliseconds: 350), () => fn.requestFocus());
      }),
      const SizedBox(height: 16),
      sideSection(
        _isNepali ? 'विकर्ण d (एक कुनाबाट अर्को कुनासम्म)' : 'Diagonal d (corner to corner)',
        'd', _d1Ctrls, _d1Focus, AppColors.amber, 'd', () {
          final fn = FocusNode();
          setState(() { _d1Ctrls.add(TextEditingController()); _d1Focus.add(fn); });
          _scrollToBottom();
          Future.delayed(const Duration(milliseconds: 350), () => fn.requestFocus());
        },
      ),
    ]);
  }

  Widget _triInputs() {
    Widget sideSection(
      String headerLabel, List<TextEditingController> ctrls,
      List<FocusNode> foci, String prefix, void Function() onAdd,
    ) {
      final vals = ctrls.map(_v).where((v) => v > 0).toList();
      final avg = vals.isEmpty ? 0.0 : vals.reduce((a, b) => a + b) / vals.length;
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _dynSectionHeader(headerLabel, AppColors.cyan,
            vals.isNotEmpty ? '${_isNepali ? "औसत" : "Avg"}: ${avg.toStringAsFixed(2)} ${_inputUnit == 0 ? "ft" : "m"}' : null),
        const SizedBox(height: 10),
        ...ctrls.asMap().entries.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(children: [
            Expanded(child: _dynField(e.value, foci[e.key], '$prefix${e.key + 1}', AppColors.cyan)),
            if (ctrls.length > 1) ...[
              const SizedBox(width: 8),
              _removeBtn(() => setState(() {
                e.value.dispose(); foci[e.key].dispose();
                ctrls.removeAt(e.key); foci.removeAt(e.key);
                _result = null;
              })),
            ],
          ]),
        )),
        _addBtn(_isNepali ? '+ $headerLabel थप्नुहोस्' : '+ Add $headerLabel', AppColors.cyan, onAdd),
      ]);
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      sideSection(_isNepali ? 'भुजा A' : 'Side A', _tACtrls, _taFocus, 'A', () {
        final fn = FocusNode();
        setState(() { _tACtrls.add(TextEditingController()); _taFocus.add(fn); });
        _scrollToBottom();
        Future.delayed(const Duration(milliseconds: 350), () => fn.requestFocus());
      }),
      const SizedBox(height: 16),
      sideSection(_isNepali ? 'भुजा B' : 'Side B', _tBCtrls, _tbFocus, 'B', () {
        final fn = FocusNode();
        setState(() { _tBCtrls.add(TextEditingController()); _tbFocus.add(fn); });
        _scrollToBottom();
        Future.delayed(const Duration(milliseconds: 350), () => fn.requestFocus());
      }),
      const SizedBox(height: 16),
      sideSection(_isNepali ? 'भुजा C' : 'Side C', _tCCtrls, _tcFocus, 'C', () {
        final fn = FocusNode();
        setState(() { _tCCtrls.add(TextEditingController()); _tcFocus.add(fn); });
        _scrollToBottom();
        Future.delayed(const Duration(milliseconds: 350), () => fn.requestFocus());
      }),
    ]);
  }

  Widget _trapInputs() {
    Widget sideSection(
      String headerLabel, List<TextEditingController> ctrls,
      List<FocusNode> foci, String prefix, void Function() onAdd,
    ) {
      final vals = ctrls.map(_v).where((v) => v > 0).toList();
      final avg = vals.isEmpty ? 0.0 : vals.reduce((a, b) => a + b) / vals.length;
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _dynSectionHeader(headerLabel, AppColors.amber,
            vals.isNotEmpty ? '${_isNepali ? "औसत" : "Avg"}: ${avg.toStringAsFixed(2)} ${_inputUnit == 0 ? "ft" : "m"}' : null),
        const SizedBox(height: 10),
        ...ctrls.asMap().entries.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(children: [
            Expanded(child: _dynField(e.value, foci[e.key], '$prefix${e.key + 1}', AppColors.amber)),
            if (ctrls.length > 1) ...[
              const SizedBox(width: 8),
              _removeBtn(() => setState(() {
                e.value.dispose(); foci[e.key].dispose();
                ctrls.removeAt(e.key); foci.removeAt(e.key);
                _result = null;
              })),
            ],
          ]),
        )),
        _addBtn(_isNepali ? '+ $headerLabel थप्नुहोस्' : '+ Add $headerLabel', AppColors.amber, onAdd),
      ]);
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      sideSection(_isNepali ? 'माथिल्लो भुजा (a)' : 'Top Side (a)', _paCtrls, _paFocus, 'a', () {
        final fn = FocusNode();
        setState(() { _paCtrls.add(TextEditingController()); _paFocus.add(fn); });
        _scrollToBottom();
        Future.delayed(const Duration(milliseconds: 350), () => fn.requestFocus());
      }),
      const SizedBox(height: 16),
      sideSection(_isNepali ? 'तल्लो भुजा (b)' : 'Bottom Side (b)', _pbCtrls, _pbFocusNodes, 'b', () {
        final fn = FocusNode();
        setState(() { _pbCtrls.add(TextEditingController()); _pbFocusNodes.add(fn); });
        _scrollToBottom();
        Future.delayed(const Duration(milliseconds: 350), () => fn.requestFocus());
      }),
      const SizedBox(height: 16),
      sideSection(_isNepali ? 'उचाइ / height (h)' : 'Perpendicular Height (h)', _phCtrls, _phFocus, 'h', () {
        final fn = FocusNode();
        setState(() { _phCtrls.add(TextEditingController()); _phFocus.add(fn); });
        _scrollToBottom();
        Future.delayed(const Duration(milliseconds: 350), () => fn.requestFocus());
      }),
    ]);
  }

  // ── Shared helpers for dynamic sections ──────────
  Widget _dynSectionHeader(String label, Color color, String? avgText) {
    return Row(children: [
      Container(width: 3, height: 16,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
      const SizedBox(width: 8),
      Text(label, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w700),
          overflow: TextOverflow.ellipsis),
      const Spacer(),
      if (avgText != null)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(avgText, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
        ),
    ]);
  }

  Widget _removeBtn(VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 36, height: 36,
      decoration: BoxDecoration(
        color: AppColors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.red.withValues(alpha: 0.3)),
      ),
      child: const Icon(Icons.remove_rounded, color: AppColors.red, size: 18),
    ),
  );

  Widget _addBtn(String label, Color color, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3), style: BorderStyle.solid),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.add_circle_rounded, color: color, size: 18),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w700)),
      ]),
    ),
  );

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
      label: Text(_isNepali ? 'क्षेत्रफल निकाल्नुहोस्' : 'Calculate Area',
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.blue, foregroundColor: Colors.white,
        elevation: 2, shadowColor: AppColors.blue.withValues(alpha: 0.35),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
  );

  // ── Results ──────────────────────────────────────
  Widget _buildResults() {
    final r = _result!;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Standard units
      _secLabel(_isNepali ? 'क्षेत्रफल (मानक)' : 'Area (Standard)', AppColors.indigo),
      const SizedBox(height: 10),
      Container(
        decoration: BoxDecoration(color: context.cSurface,
            borderRadius: BorderRadius.circular(14), border: Border.all(color: context.cBorder)),
        child: Column(children: [
          _row(Icons.square_foot_rounded,  AppColors.indigo, _isNepali ? 'वर्गफिट'  : 'Sq. Feet',  '${_fmtNum(r['sqft']!)} sq.ft'),
          Divider(color: context.cBorder, height: 1),
          _row(Icons.straighten_rounded,   AppColors.cyan,   _isNepali ? 'वर्गमिटर' : 'Sq. Meter', '${_fmtNum(r['sqm']!)} m²'),
          Divider(color: context.cBorder, height: 1),
          _row(Icons.landscape_rounded,    AppColors.green,  _isNepali ? 'एकड'      : 'Acre',       '${r['acre']} acre'),
          Divider(color: context.cBorder, height: 1),
          _row(Icons.park_rounded,         AppColors.blue,   _isNepali ? 'हेक्टेयर' : 'Hectare',   '${r['ha']} ha'),
        ]),
      ),

      const SizedBox(height: 20),

      // Hill system
      _secLabel(_isNepali ? 'पहाडी प्रणाली (रोपनी-आना-पैसा-दाम)' : 'Hill System (Ropani-Aana-Paisa-Dam)', AppColors.blue),
      const SizedBox(height: 10),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: AppColors.blue.withValues(alpha: 0.25), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _bigBox(r['ropani']!, _isNepali ? 'रोपनी' : 'Ropani'),
            _vline(), _bigBox(r['aana']!, _isNepali ? 'आना' : 'Aana'),
            _vline(), _bigBox(r['paisa']!, _isNepali ? 'पैसा' : 'Paisa'),
            _vline(), _bigBox(r['dam']!, _isNepali ? 'दाम' : 'Dam'),
          ]),
          const SizedBox(height: 10),
          Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 8),
          Text('= ${r['ropaniDec']} ${_isNepali ? "रोपनी" : "Ropani"}',
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ]),
      ),

      const SizedBox(height: 16),

      // Terai system
      _secLabel(_isNepali ? 'तराई प्रणाली (बिघा-कट्ठा-धुर)' : 'Terai System (Bigha-Kattha-Dhur)', AppColors.green),
      const SizedBox(height: 10),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: AppTheme.greenGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: AppColors.green.withValues(alpha: 0.25), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _bigBox(r['bigha']!,  _isNepali ? 'बिघा'  : 'Bigha'),
            _vline(), _bigBox(r['kattha']!, _isNepali ? 'कट्ठा' : 'Kattha'),
            _vline(), _bigBox(r['dhur']!,   _isNepali ? 'धुर'   : 'Dhur'),
          ]),
          const SizedBox(height: 10),
          Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 8),
          Text('= ${r['bighaDec']} ${_isNepali ? "बिघा" : "Bigha"}',
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ]),
      ),

      // Reference table
      const SizedBox(height: 24),
      _refTable(),
      const SizedBox(height: 8),
    ]);
  }

  Widget _secLabel(String t, Color c) => Row(children: [
    Container(width: 3, height: 14,
        decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(3))),
    const SizedBox(width: 8),
    Expanded(child: Text(t, style: TextStyle(color: c, fontSize: 12, fontWeight: FontWeight.w700))),
  ]);

  Widget _row(IconData icon, Color color, String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Row(children: [
      Container(width: 32, height: 32,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 16)),
      const SizedBox(width: 12),
      Expanded(child: Text(label, style: TextStyle(color: context.cText3, fontSize: 13))),
      Text(value, style: TextStyle(color: context.cText1, fontSize: 14, fontWeight: FontWeight.w800)),
    ]),
  );

  Widget _bigBox(String val, String lbl) => Column(children: [
    Text(val, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
    Text(lbl, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
  ]);

  Widget _vline() => Container(width: 1, height: 40, color: Colors.white24);

  Widget _refTable() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: context.cSurface,
          borderRadius: BorderRadius.circular(14), border: Border.all(color: context.cBorder)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(_isNepali ? 'सन्दर्भ तालिका' : 'Reference Table',
            style: TextStyle(color: context.cText2, fontSize: 13, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        _ref('🏔️', '1 रोपनी', '= 16 आना = 5476 sq.ft = 508.72 m²'),
        _ref('🏔️', '1 आना',   '= 4 पैसा = 342.25 sq.ft = 31.80 m²'),
        _ref('🏔️', '1 पैसा',  '= 4 दाम = 85.56 sq.ft = 7.95 m²'),
        _ref('🏔️', '1 दाम',   '= 21.39 sq.ft = 1.99 m²'),
        Divider(color: context.cBorder, height: 16),
        _ref('🌾', '1 बिघा',  '= 20 कट्ठा = 72900 sq.ft = 6772.63 m²'),
        _ref('🌾', '1 कट्ठा', '= 20 धुर = 3645 sq.ft = 338.63 m²'),
        _ref('🌾', '1 धुर',   '= 182.25 sq.ft = 16.93 m²'),
      ]),
    );
  }

  Widget _ref(String emoji, String unit, String eq) => Padding(
    padding: const EdgeInsets.only(bottom: 7),
    child: Row(children: [
      Text(emoji, style: const TextStyle(fontSize: 13)),
      const SizedBox(width: 8),
      SizedBox(width: 80, child: Text(unit,
          style: TextStyle(color: context.cText1, fontSize: 11, fontWeight: FontWeight.w700))),
      Expanded(child: Text(eq, style: TextStyle(color: context.cText3, fontSize: 11))),
    ]),
  );
}
