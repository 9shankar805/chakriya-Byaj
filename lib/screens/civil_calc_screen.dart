import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../widgets/app_hero_header.dart';
import '../widgets/app_drawer.dart';
import '../widgets/features_sheet.dart';
import 'history_screen.dart';
import 'simple_interest_screen.dart';
import 'emi_screen.dart';
import 'land_screen.dart';
import 'currency_screen.dart';
import 'report_screen.dart';
import 'widget_settings_screen.dart';
import 'profit_loss_screen.dart';
import 'input_screen.dart';

class CivilCalcScreen extends StatefulWidget {
  final String languageCode;
  const CivilCalcScreen({super.key, required this.languageCode});
  @override
  State<CivilCalcScreen> createState() => _CivilCalcScreenState();
}

class _CivilCalcScreenState extends State<CivilCalcScreen>
    with SingleTickerProviderStateMixin {
  late String _languageCode;
  bool get _isNepali => _languageCode == 'np';
  bool get _isHindi => _languageCode == 'hi';
  bool get _isEnglish => _languageCode == 'en';
  String _display = '';
  String _result  = '';
  final List<String> _history = [];
  int _tab = 0; // 0=Length 1=Area 2=Volume
  final List<_Token> _tokens = [];
  String _currentNum = '';
  bool _newEntry = false;

  late final AnimationController _animCtrl;
  late final Animation<double>   _fadeAnim;

  // Colors
  static const _bgKey     = Color(0xFF1E2740);
  static const _bgNum     = Color(0xFF2A3655);
  static const _bgOp      = Color(0xFF2E3D68);
  static const _bgUnit    = Color(0xFF1B4FE4);
  static const _bgEq      = Color(0xFF1B4FE4);
  static const _bgClear   = Color(0xFF3D1A1A);
  static const _bgDel     = Color(0xFF2E3D68);
  static const _textNum   = Color(0xFFE8EEFF);
  static const _textOp    = Color(0xFF90A8FF);
  static const _textUnit  = Colors.white;

  static const double _mmPerFoot  = 304.8;
  static const double _mmPerInch  = 25.4;
  static const double _mmPerMeter = 1000.0;

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
    super.dispose();
  }

  double _toMm(double v, _Unit u) {
    switch (u) {
      case _Unit.feet:  return v * _mmPerFoot;
      case _Unit.inch:  return v * _mmPerInch;
      case _Unit.meter: return v * _mmPerMeter;
      default:          return v;
    }
  }

  double _fromMm(double mm, _Unit u) {
    switch (u) {
      case _Unit.feet:  return mm / _mmPerFoot;
      case _Unit.inch:  return mm / _mmPerInch;
      case _Unit.meter: return mm / _mmPerMeter;
      default:          return mm;
    }
  }

  void _pressNum(String n) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_newEntry) { _currentNum = ''; _newEntry = false; }
      if (n == '.' && _currentNum.contains('.')) return;
      _currentNum += n;
      _display = _buildExpr();
    });
  }

  void _pressUnit(_Unit unit) {
    if (_currentNum.isEmpty) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _tokens.add(_Token(double.tryParse(_currentNum) ?? 0, unit));
      _currentNum = '';
      _display = _buildExpr();
    });
  }

  void _pressOp(String op) {
    _commit();
    HapticFeedback.lightImpact();
    setState(() {
      if (_tokens.isNotEmpty && _tokens.last.isOp) {
        _tokens.last = _Token.op(op);
      } else {
        _tokens.add(_Token.op(op));
      }
      _display = _buildExpr();
    });
  }

  void _pressEquals() {
    _commit();
    HapticFeedback.heavyImpact();
    setState(() {
      final res = _evaluate();
      if (res != null) {
        final expr = _display;
        _Unit lastUnit = _Unit.none;
        for (int i = _tokens.length - 1; i >= 0; i--) {
          if (!_tokens[i].isOp && _tokens[i].unit != _Unit.none) {
            lastUnit = _tokens[i].unit;
            break;
          }
        }
        if (lastUnit != _Unit.none) {
          final suffix = _unitSuffix(lastUnit);
          _result = '${_fmt(res)} $suffix'.trim();
        } else {
          _result = _fmt(res);
        }
        _history.insert(0, '$expr\n= $_result');
        if (_history.length > 50) _history.removeLast();
        _tokens.clear();
        _currentNum = '';
        _display = _result;
        _newEntry = true;
      }
    });
  }

  void _pressClear() {
    HapticFeedback.heavyImpact();
    setState(() { _tokens.clear(); _currentNum = ''; _display = ''; _result = ''; _newEntry = false; });
  }

  void _pressBack() {
    HapticFeedback.lightImpact();
    setState(() {
      if (_currentNum.isNotEmpty) {
        _currentNum = _currentNum.substring(0, _currentNum.length - 1);
      } else if (_tokens.isNotEmpty) {
        _tokens.removeLast();
      }
      _display = _buildExpr();
    });
  }

  void _pressPM() {
    setState(() {
      if (_currentNum.isNotEmpty) {
        _currentNum = _currentNum.startsWith('-')
            ? _currentNum.substring(1) : '-$_currentNum';
        _display = _buildExpr();
      }
    });
  }

  void _pressPct() {
    setState(() {
      if (_currentNum.isNotEmpty) {
        final v = (double.tryParse(_currentNum) ?? 0) / 100;
        _currentNum = _fmt(v);
        _display = _buildExpr();
      }
    });
  }

  void _commit() {
    if (_currentNum.isNotEmpty) {
      _tokens.add(_Token(double.tryParse(_currentNum) ?? 0, _Unit.none));
      _currentNum = '';
    }
  }

  double? _evaluate() {
    if (_tokens.isEmpty) return null;
    bool hasUnits = _tokens.any((t) => !t.isOp && t.unit != _Unit.none);
    if (!hasUnits) {
      double acc = 0; String op = '+';
      for (final t in _tokens) {
        if (t.isOp) { op = t.op!; }
        else {
          final v = t.value;
          switch (op) {
            case '+': acc += v; break;
            case '-': acc -= v; break;
            case '×': acc *= v; break;
            case '÷': if (v != 0) acc /= v; break;
          }
        }
      }
      return acc;
    }
    double acc = 0; String op = '+';
    for (final t in _tokens) {
      if (t.isOp) { op = t.op!; }
      else {
        final v = _toMm(t.value, t.unit);
        switch (op) {
          case '+': acc += v; break;
          case '-': acc -= v; break;
          case '×': acc *= v; break;
          case '÷': if (v != 0) acc /= v; break;
        }
      }
    }
    return acc;
  }

  String _buildExpr() {
    final buf = StringBuffer();
    for (final t in _tokens) {
      if (t.isOp) { buf.write(' ${t.op} '); }
      else {
        buf.write(_fmt(t.value));
        if (t.unit != _Unit.none) buf.write(_unitSuffix(t.unit));
        buf.write(' ');
      }
    }
    buf.write(_currentNum);
    return buf.toString().trim();
  }

  String _unitSuffix(_Unit u) {
    switch (u) {
      case _Unit.feet:  return "'";
      case _Unit.inch:  return '"';
      case _Unit.meter: return 'M';
      case _Unit.mm:    return 'mm';
      default:          return '';
    }
  }

  String _fmt(double v) {
    if (v == v.roundToDouble() && v.abs() < 1e10) return v.toInt().toString();
    return v.toStringAsFixed(4).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  // ── Conversion strip ──────────────────────────────────────────────────────
  List<_ConvItem> get _convItems {
    switch (_tab) {
      case 0: return [
        _ConvItem("'\"→ft",  () => _convLast(_Unit.feet)),
        _ConvItem("'\"→in",  () => _convLast(_Unit.inch)),
        _ConvItem("'\"→M",   () => _convLast(_Unit.meter)),
        _ConvItem("'\"→mm",  () => _convLast(_Unit.mm)),
        _ConvItem("M→mm",    () => _convLast(_Unit.mm)),
      ];
      case 1: return [
        _ConvItem("ft²→m²",  () => _convA('ft2m2')),
        _ConvItem("m²→ft²",  () => _convA('m2ft2')),
        _ConvItem("in²→ft²", () => _convA('in2ft2')),
        _ConvItem("ft²→in²", () => _convA('ft2in2')),
        _ConvItem("m²→cm²",  () => _convA('m2cm2')),
      ];
      default: return [
        _ConvItem("ft³→m³",    () => _convV('ft2m')),
        _ConvItem("m³→ft³",    () => _convV('m2ft')),
        _ConvItem("in³→ft³",   () => _convV('in2ft')),
        _ConvItem("ft³→brass", () => _convV('ft2brass')),
        _ConvItem("ft³→ltr",   () => _convV('ft2ltr')),
      ];
    }
  }

  double _extractValue() {
    if (_tokens.isNotEmpty) {
      for (int i = _tokens.length - 1; i >= 0; i--) {
        if (!_tokens[i].isOp) {
          return _tokens[i].unit != _Unit.none
              ? _toMm(_tokens[i].value, _tokens[i].unit)
              : _tokens[i].value;
        }
      }
    }
    if (_currentNum.isNotEmpty) {
      return double.tryParse(_currentNum.replaceAll(',', '')) ?? 0.0;
    }
    final targetStr = _result.isNotEmpty ? _result : _display;
    final clean = targetStr.replaceAll(RegExp(r'[^0-9.-]'), '');
    return double.tryParse(clean) ?? 0.0;
  }

  void _convLast(_Unit to) {
    _commit();
    final val = _extractValue();
    final converted = _fromMm(val, to);
    final suffix = _unitSuffix(to);
    setState(() {
      _tokens.clear();
      _tokens.add(_Token(converted, to));
      _currentNum = '';
      _result = '${_fmt(converted)}${suffix.isNotEmpty ? " $suffix" : ""}';
      _display = _result;
      _newEntry = true;
    });
  }

  void _convA(String t) {
    _commit();
    final v = _extractValue();
    double r;
    String u = '';
    switch (t) {
      case 'ft2m2':  r = v / 10.7639; u = 'm²';  break;
      case 'm2ft2':  r = v * 10.7639; u = 'ft²'; break;
      case 'in2ft2': r = v / 144;     u = 'ft²'; break;
      case 'ft2in2': r = v * 144;     u = 'in²'; break;
      case 'm2cm2':  r = v * 10000;   u = 'cm²'; break;
      default:       r = v;
    }
    setState(() {
      _tokens.clear();
      _tokens.add(_Token(r, _Unit.none));
      _currentNum = '';
      _result = '${_fmt(r)} $u'.trim();
      _display = _result;
      _newEntry = true;
    });
  }

  void _convV(String t) {
    _commit();
    final v = _extractValue();
    double r;
    String u = '';
    switch (t) {
      case 'ft2m':     r = v * 0.0283168; u = 'm³';    break;
      case 'm2ft':     r = v * 35.3147;   u = 'ft³';   break;
      case 'in2ft':    r = v / 1728;      u = 'ft³';   break;
      case 'ft2brass': r = v / 100;       u = 'brass'; break;
      case 'ft2ltr':   r = v * 28.3168;   u = 'L';     break;
      default:         r = v;
    }
    setState(() {
      _tokens.clear();
      _tokens.add(_Token(r, _Unit.none));
      _currentNum = '';
      _result = '${_fmt(r)} $u'.trim();
      _display = _result;
      _newEntry = true;
    });
  }

  // ── Build method and layout ───────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.cBg,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SafeArea(
          child: Column(
            children: [
              _buildHeroHeader(),
              _buildTabs(),
              _buildDisplay(),
              _buildConversionStrip(),
              _buildUnitButtons(),
              _buildKeyboard(),
            ],
          ),
        ),
      ),
    );
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

  Widget _buildHeroHeader() {
    return AppHeroHeader(
      languageCode: _languageCode,
      title: _isNepali ? 'सिभिल क्याल्कुलेटर' : (_isHindi ? 'सिविल कैलकुलेटर' : 'Civil Calculator'),
      activeScreen: HeroScreen.other,
      onLangToggle: _toggleLanguage,
      onGridTap: _showAppGrid,
      onQuickNav: _handleQuickNav,
    );
  }

  Widget _buildTabs() {
    final tabs = [
      _isNepali ? 'लम्बाई' : (_isHindi ? 'लंबाई' : 'Length'),
      _isNepali ? 'क्षेत्रफल' : (_isHindi ? 'क्षेत्रफल' : 'Area'),
      _isNepali ? 'आयतन' : (_isHindi ? 'आयतन' : 'Volume'),
    ];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: context.cSurface2,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = _tab == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _tab = index;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.blue : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isSelected ? AppTheme.blueShadow : null,
                ),
                child: Text(
                  tabs[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : context.cText3,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDisplay() {
    return Expanded(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        decoration: BoxDecoration(
          color: context.cSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.cBorder),
          boxShadow: context.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.bottomRight,
                child: SingleChildScrollView(
                  reverse: true,
                  child: Text(
                    _display.isEmpty ? '0' : _display,
                    style: TextStyle(
                      fontSize: 20,
                      color: context.cText3,
                      fontFamily: 'monospace',
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _result.isEmpty ? '0' : _result,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.blue,
                height: 1.2,
              ),
              textAlign: TextAlign.right,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversionStrip() {
    final items = _convItems;
    return Container(
      height: 42,
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Container(
            margin: const EdgeInsets.only(right: 6, top: 2, bottom: 2),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: context.cSurface2,
                foregroundColor: AppColors.blue,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: context.cBorder),
                ),
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                item.onTap();
              },
              child: Text(
                item.label,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUnitButtons() {
    final units = [
      {'label': 'ft', 'unit': _Unit.feet},
      {'label': 'in', 'unit': _Unit.inch},
      {'label': 'M', 'unit': _Unit.meter},
      {'label': 'mm', 'unit': _Unit.mm},
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Row(
        children: units.map((u) {
          final label = u['label'] as String;
          final unit = u['unit'] as _Unit;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _bgUnit,
                  foregroundColor: _textUnit,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 1,
                ),
                onPressed: () => _pressUnit(unit),
                child: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildKeyboard() {
    return Container(
      color: _bgKey,
      padding: const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 12),
      child: Column(
        children: [
          Row(
            children: [
              _buildKey('AC', _bgClear, Colors.redAccent, _pressClear),
              _buildKey('', _bgDel, _textOp, _pressBack, isIcon: true, icon: Icons.backspace_rounded),
              _buildKey('%', _bgOp, _textOp, _pressPct),
              _buildKey('÷', _bgOp, _textOp, () => _pressOp('÷')),
            ],
          ),
          Row(
            children: [
              _buildKey('7', _bgNum, _textNum, () => _pressNum('7')),
              _buildKey('8', _bgNum, _textNum, () => _pressNum('8')),
              _buildKey('9', _bgNum, _textNum, () => _pressNum('9')),
              _buildKey('×', _bgOp, _textOp, () => _pressOp('×')),
            ],
          ),
          Row(
            children: [
              _buildKey('4', _bgNum, _textNum, () => _pressNum('4')),
              _buildKey('5', _bgNum, _textNum, () => _pressNum('5')),
              _buildKey('6', _bgNum, _textNum, () => _pressNum('6')),
              _buildKey('-', _bgOp, _textOp, () => _pressOp('-')),
            ],
          ),
          Row(
            children: [
              _buildKey('1', _bgNum, _textNum, () => _pressNum('1')),
              _buildKey('2', _bgNum, _textNum, () => _pressNum('2')),
              _buildKey('3', _bgNum, _textNum, () => _pressNum('3')),
              _buildKey('+', _bgOp, _textOp, () => _pressOp('+')),
            ],
          ),
          Row(
            children: [
              _buildKey('±', _bgNum, _textNum, _pressPM),
              _buildKey('0', _bgNum, _textNum, () => _pressNum('0')),
              _buildKey('.', _bgNum, _textNum, () => _pressNum('.')),
              _buildKey('=', _bgEq, _textUnit, _pressEquals),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKey(String label, Color bg, Color textColor, VoidCallback onTap, {bool isIcon = false, IconData? icon}) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
        height: 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: bg,
            foregroundColor: textColor,
            elevation: 0,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: onTap,
          child: isIcon
              ? Icon(icon, color: textColor, size: 22)
              : Text(
                  label,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
        ),
      ),
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
      case HeroScreen.compound: push(const InputScreen()); break;
      case HeroScreen.simple:   push(SimpleInterestScreen(languageCode: _languageCode)); break;
      case HeroScreen.emi:      push(EmiScreen(languageCode: _languageCode)); break;
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
      activeScreen: HeroScreen.result,
      onNavigate: _handleQuickNav,
    );
  }
}

enum _Unit { feet, inch, meter, mm, none }

class _Token {
  final double value;
  final _Unit unit;
  final String? op;
  final bool isOp;

  _Token(this.value, this.unit)
      : op = null,
        isOp = false;

  _Token.op(this.op)
      : value = 0,
        unit = _Unit.none,
        isOp = true;
}

class _ConvItem {
  final String label;
  final VoidCallback onTap;
  _ConvItem(this.label, this.onTap);
}
