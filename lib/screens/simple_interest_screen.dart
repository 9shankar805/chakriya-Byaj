import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/saved_record.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../theme/theme_provider.dart';
import '../widgets/app_hero_header.dart';
import '../widgets/features_sheet.dart';
import '../widgets/ms_grid.dart';
import '../widgets/pro_widgets.dart';
import 'history_screen.dart';
import 'emi_screen.dart';
import 'land_screen.dart';
import 'currency_screen.dart';
import 'report_screen.dart';
import 'widget_settings_screen.dart';
import 'civil_calc_screen.dart';
import 'profit_loss_screen.dart';
import '../widgets/civil_calc_fab.dart';

class SimpleInterestScreen extends StatefulWidget {
  final String languageCode;
  const SimpleInterestScreen({super.key, required this.languageCode});

  @override
  State<SimpleInterestScreen> createState() => _SimpleInterestScreenState();
}

class _SimpleInterestScreenState extends State<SimpleInterestScreen>
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
  final _rateCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();

  // true = months, false = years
  bool _timeInMonths = true;

  double? _si;
  double? _total;
  String _errorMsg = '';
  bool _saved = false;

  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _languageCode = widget.languageCode;
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _principalCtrl.dispose();
    _rateCtrl.dispose();
    _timeCtrl.dispose();
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
    setState(() { _errorMsg = ''; _saved = false; });
    FocusScope.of(context).unfocus();

    final principal = double.tryParse(_principalCtrl.text.trim()) ?? 0;
    final rate = double.tryParse(_rateCtrl.text.trim()) ?? 0;
    final timeInput = double.tryParse(_timeCtrl.text.trim()) ?? 0;

    if (principal <= 0) {
      setState(() => _errorMsg = _isNepali
          ? 'मूलधन राम्ररी भर्नुहोस्'
          : 'Please enter a valid Principal amount');
      return;
    }
    if (rate <= 0) {
      setState(() => _errorMsg = _isNepali
          ? 'ब्याज दर राम्ररी भर्नुहोस्'
          : 'Please enter a valid Interest Rate');
      return;
    }
    if (timeInput <= 0) {
      setState(() => _errorMsg = _isNepali
          ? 'समय राम्ररी भर्नुहोस्'
          : 'Please enter a valid Time period');
      return;
    }

    // I = (P * T * R) / 100  — standard simple interest formula
    // T is always in years
    final t = _timeInMonths ? timeInput / 12.0 : timeInput;
    final si = (principal * t * rate) / 100.0;
    final total = principal + si;

    setState(() {
      _si = si;
      _total = total;
    });
  }

  // ── Save sheet ──────────────────────────────────────
  void _openSaveSheet() {
    if (_si == null || _total == null) return;
    final nameCtrl = TextEditingController();
    final noteCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.cBg,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 16,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: context.cBorderMid,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _isNepali ? 'हिसाब सुरक्षित गर्नुहोस्' : 'Save Record',
              style: TextStyle(color: context.cText1, fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 5),
            Text(
              _isNepali ? 'ऋणीको नाम र टिप्पणी थप्नुहोस्' : 'Add borrower name and optional note',
              style: TextStyle(color: context.cText4, fontSize: 13),
            ),
            const SizedBox(height: 20),
            Text(_isNepali ? 'ऋणीको नाम *' : 'Borrower Name *',
                style: TextStyle(color: context.cText3, fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: nameCtrl,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              style: TextStyle(color: context.cText1, fontSize: 16, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: _isNepali ? 'जस्तै: राम बहादुर' : 'e.g. Ram Bahadur',
                hintStyle: TextStyle(color: context.cHint),
                prefixIcon: const Icon(Icons.person_rounded, color: AppColors.blue, size: 18),
                filled: true,
                fillColor: context.cSurface,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: context.cBorder)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: context.cBorder)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.blue, width: 1.5)),
              ),
            ),
            const SizedBox(height: 16),
            Text(_isNepali ? 'टिप्पणी (वैकल्पिक)' : 'Note (optional)',
                style: TextStyle(color: context.cText3, fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: noteCtrl,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              style: TextStyle(color: context.cText1, fontSize: 15),
              decoration: InputDecoration(
                hintText: _isNepali ? 'जस्तै: घर जग्गाको लागि ऋण' : 'e.g. Loan for house construction',
                hintStyle: TextStyle(color: context.cHint, fontSize: 13),
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 40),
                  child: Icon(Icons.notes_rounded, color: AppColors.amber, size: 18),
                ),
                filled: true,
                fillColor: context.cSurface,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: context.cBorder)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: context.cBorder)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.amber, width: 1.5)),
              ),
            ),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.cText2,
                    side: BorderSide(color: context.cBorderMid),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(_isNepali ? 'रद्द गर्नुहोस्' : 'Cancel',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final name = nameCtrl.text.trim();
                    if (name.isEmpty) {
                      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                        content: Text(_isNepali ? 'नाम अनिवार्य छ' : 'Name is required'),
                        backgroundColor: AppColors.red,
                        behavior: SnackBarBehavior.floating,
                      ));
                      return;
                    }
                    final principal = double.tryParse(_principalCtrl.text.trim()) ?? 0;
                    final rate = double.tryParse(_rateCtrl.text.trim()) ?? 0;
                    final record = SavedRecord(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: name,
                      note: noteCtrl.text.trim(),
                      liekoSal: 0, liekoMahina: 0, liekoGate: 0,
                      bhujaauneSal: 0, bhujaauneMahina: 0, bhujaaune_Gate: 0,
                      mulDhan: principal,
                      byajDar: rate,
                      jammaByaj: _si!,
                      totalAmount: _total!,
                      savedAt: DateTime.now(),
                    );
                    final outerMessenger = ScaffoldMessenger.of(context);
                    final nav = Navigator.of(ctx);
                    await StorageService.save(record);
                    if (!mounted) return;
                    nav.pop();
                    setState(() => _saved = true);
                    outerMessenger.showSnackBar(SnackBar(
                      content: Row(children: [
                        const Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
                        const SizedBox(width: 8),
                        Text(_isNepali ? '\'$name\' को हिसाब सुरक्षित भयो' : '\'$name\' saved successfully'),
                      ]),
                      backgroundColor: AppColors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ));
                  },
                  icon: const Icon(Icons.save_rounded, size: 18),
                  label: Text(_isNepali ? 'सुरक्षित गर्नुहोस्' : 'Save',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  // ── Build ───────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.cBg,
      floatingActionButton: CivilCalcFab(languageCode: _languageCode),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SafeArea(
          child: CustomScrollView(
            physics: const ClampingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildHeroHeader()),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(delegate: SliverChildListDelegate([
                  const SizedBox(height: 24),
                  _buildInputSection(),
                  const SizedBox(height: 28),
                  if (_errorMsg.isNotEmpty) ...[_errorBanner(), const SizedBox(height: 16)],
                  _calcButton(),
                  if (_si != null && _total != null) ...[
                    const SizedBox(height: 28),
                    _buildResultSection(),
                  ],
                  const SizedBox(height: 24),
                  _footer(),
                  const SizedBox(height: 20),
                ])),
              ),
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
      title: getTxt('साधारण ब्याज', 'साधारण ब्याज', 'Simple Interest'),
      activeScreen: HeroScreen.simple,
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
      case HeroScreen.compound: Navigator.pop(context); break;
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



  void _showThemePicker(ThemeProvider tp) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.cBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => ChangeNotifierProvider.value(
        value: tp,
        child: Builder(builder: (ctx) {
          final prov = ctx.watch<ThemeProvider>();
          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Center(
                child: Container(
                  width: 36, height: 4,
                  decoration: BoxDecoration(color: context.cBorderMid, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _isNepali ? 'थिम छान्नुहोस्' : 'Choose Theme',
                  style: TextStyle(color: context.cText1, fontSize: 17, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(height: 16),
              ...AppThemeMode.values.map((m) {
                final selected = prov.mode == m;
                return GestureDetector(
                  onTap: () { prov.setMode(m); Navigator.pop(ctx); },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.blue.withValues(alpha: 0.08) : context.cSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? AppColors.blue.withValues(alpha: 0.4) : context.cBorder,
                        width: selected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(children: [
                      Icon(prov.icon(m), color: selected ? AppColors.blue : context.cText3, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _isNepali
                              ? (m == AppThemeMode.system ? 'सिस्टम' : m == AppThemeMode.light ? 'उज्यालो' : 'अँध्यारो')
                              : prov.label(m),
                          style: TextStyle(
                            color: selected ? AppColors.blue : context.cText1,
                            fontSize: 15,
                            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                      if (selected) const Icon(Icons.check_circle_rounded, color: AppColors.blue, size: 18),
                    ]),
                  ),
                );
              }),
            ]),
          );
        }),
      ),
    );
  }

  void _showAppGrid() {
    showFeaturesSheet(
      context: context,
      languageCode: _languageCode,
      onNavigate: (icon) {
        void push(Widget w) {
          // First pop the features sheet, then pop back to main, then push the new screen
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
          Navigator.pop(context);
          Navigator.pop(context);
        } else if (icon == Icons.history_rounded) {
          Navigator.pop(context);
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (_) => HistoryScreen(languageCode: _languageCode)));
        } else if (icon == Icons.percent_rounded) {
          // Already on simple interest, just close the sheet
          Navigator.pop(context);
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
        // Icons.percent_rounded = already here, do nothing
      },
    );
  }

  // ── Input section ─────────────────────────────────
  Widget _buildInputSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Principal
      _group(_isNepali ? 'मूलधन' : 'Principal', AppColors.blue,
        _inputField(
          controller: _principalCtrl,
          hint: _isNepali ? 'जस्तै: 50000' : 'e.g. 50000',
          prefix: 'रु',
          formatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
        ),
      ),
      const SizedBox(height: 20),
      // Rate
      _group(_isNepali ? 'ब्याज दर' : 'Interest Rate', AppColors.amber,
        _inputField(
          controller: _rateCtrl,
          hint: _isNepali ? 'जस्तै: 3.0' : 'e.g. 3.0',
          suffix: '%',
          formatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
        ),
        sub: _isNepali ? '% प्रति महिना' : '% per month',
      ),
      const SizedBox(height: 20),
      // Time with toggle
      _buildTimeGroup(),
    ]);
  }

  Widget _buildTimeGroup() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(width: 3, height: 16,
            decoration: BoxDecoration(color: AppColors.cyan, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 8),
        Text(
          _isNepali ? 'समय' : 'Time',
          style: const TextStyle(color: AppColors.cyan, fontSize: 14, fontWeight: FontWeight.w700),
        ),
        const SizedBox(width: 10),
        // Toggle: months / years
        GestureDetector(
          onTap: () => setState(() { _timeInMonths = true; _si = null; _total = null; }),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _timeInMonths ? AppColors.cyan.withValues(alpha: 0.12) : context.cSurface2,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _timeInMonths ? AppColors.cyan.withValues(alpha: 0.4) : context.cBorder,
                width: _timeInMonths ? 1.5 : 1.0,
              ),
            ),
            child: Text(
              _isNepali ? 'महिना' : 'Months',
              style: TextStyle(
                color: _timeInMonths ? AppColors.cyan : context.cText3,
                fontSize: 12, fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: () => setState(() { _timeInMonths = false; _si = null; _total = null; }),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: !_timeInMonths ? AppColors.cyan.withValues(alpha: 0.12) : context.cSurface2,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: !_timeInMonths ? AppColors.cyan.withValues(alpha: 0.4) : context.cBorder,
                width: !_timeInMonths ? 1.5 : 1.0,
              ),
            ),
            child: Text(
              _isNepali ? 'वर्ष' : 'Years',
              style: TextStyle(
                color: !_timeInMonths ? AppColors.cyan : context.cText3,
                fontSize: 12, fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ]),
      const SizedBox(height: 10),
      _inputField(
        controller: _timeCtrl,
        hint: _timeInMonths
            ? (_isNepali ? 'जस्तै: 12' : 'e.g. 12')
            : (_isNepali ? 'जस्तै: 2' : 'e.g. 2'),
        suffix: _timeInMonths ? (_isNepali ? 'महिना' : 'mo') : (_isNepali ? 'वर्ष' : 'yr'),
        formatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
      ),
    ]);
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    String? prefix,
    String? suffix,
    List<TextInputFormatter>? formatters,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: formatters ?? [FilteringTextInputFormatter.digitsOnly],
      style: TextStyle(color: context.cText1, fontSize: 17, fontWeight: FontWeight.w700),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: context.cHint, fontSize: 15),
        prefixText: prefix != null ? '$prefix  ' : null,
        prefixStyle: TextStyle(color: context.cText3, fontSize: 16, fontWeight: FontWeight.w600),
        suffixText: suffix,
        suffixStyle: const TextStyle(color: AppColors.amber, fontSize: 16, fontWeight: FontWeight.w700),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 13, horizontal: 14),
        filled: true,
        fillColor: context.cSurface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: context.cBorder)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: context.cBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.blue, width: 1.5)),
      ),
    );
  }

  Widget _group(String label, Color color, Widget child, {String? sub}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(width: 3, height: 16,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w700)),
        if (sub != null) ...[
          const SizedBox(width: 6),
          Text(sub, style: TextStyle(color: context.cText4, fontSize: 12)),
        ],
      ]),
      const SizedBox(height: 10),
      child,
    ]);
  }

  Widget _errorBanner() => ErrorBanner(message: _errorMsg);

  Widget _calcButton() => ProButton(
    label: _isNepali ? 'गणना गर्नुहोस्' : 'Calculate',
    icon: Icons.calculate_rounded,
    gradient: AppTheme.primaryGradient,
    onPressed: _calculate,
  );

  // ── Result section ────────────────────────────────
  Widget _buildResultSection() {
    final principal = double.tryParse(_principalCtrl.text.trim()) ?? 0;
    final rate = double.tryParse(_rateCtrl.text.trim()) ?? 0;
    final timeInput = double.tryParse(_timeCtrl.text.trim()) ?? 0;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionLabel(_isNepali ? 'विवरण' : 'Details'),
      const SizedBox(height: 12),
      Container(
        decoration: BoxDecoration(
          color: context.cSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.cBorder),
        ),
        child: Column(children: [
          _summaryRow(Icons.currency_rupee_rounded, AppColors.blue,
              _isNepali ? 'मूलधन' : 'Principal', 'रु ${_fmt(principal)}'),
          Divider(color: context.cSurface2, height: 1, thickness: 1),
          _summaryRow(Icons.percent_rounded, AppColors.amber,
              _isNepali ? 'ब्याज दर' : 'Interest Rate',
              '$rate% ${_isNepali ? "प्रति महिना" : "/ month"}'),
          Divider(color: context.cSurface2, height: 1, thickness: 1),
          _summaryRow(Icons.access_time_rounded, AppColors.cyan,
              _isNepali ? 'समय' : 'Time',
              _timeInMonths
                  ? '$timeInput ${_isNepali ? "महिना" : "Months"}'
                  : '$timeInput ${_isNepali ? "वर्ष" : "Years"} (${(timeInput * 12).toStringAsFixed(0)} ${_isNepali ? "महिना" : "mo"})'),
        ]),
      ),
      const SizedBox(height: 20),
      _sectionLabel(_isNepali ? 'नतिजा' : 'Result'),
      const SizedBox(height: 12),
      // SI result tile
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.indigo.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.indigo.withValues(alpha: 0.18)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(
            _isNepali ? 'साधारण ब्याज' : 'Simple Interest',
            style: const TextStyle(color: AppColors.indigo, fontSize: 14, fontWeight: FontWeight.w600),
          ),
          Text(
            'रु ${_fmt(_si!)}',
            style: TextStyle(color: context.cText1, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.3),
          ),
        ]),
      ),
      const SizedBox(height: 10),
      HeroTotalCard(
        title: _isNepali ? 'जम्मा रकम ब्याज सहित' : 'Total Amount with Interest',
        amount: 'रु ${_fmt(_total!)}',
        subtitle: _isNepali ? 'मूलधन + साधारण ब्याज सहित' : 'Principal + Simple Interest',
        gradient: AppTheme.greenGradient,
        shadows: AppTheme.greenShadow,
      ),
      const SizedBox(height: 20),
      // Save button row
      Row(children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              _principalCtrl.clear();
              _rateCtrl.clear();
              _timeCtrl.clear();
              setState(() { _si = null; _total = null; _errorMsg = ''; _saved = false; });
            },
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text(
              _isNepali ? 'अर्को हिसाब' : 'New Calculation',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: context.cText2,
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(color: context.cBorderMid),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _saved ? null : _openSaveSheet,
            icon: Icon(_saved ? Icons.check_circle_rounded : Icons.save_rounded, size: 18),
            label: Text(
              _saved
                  ? (_isNepali ? 'सुरक्षित' : 'Saved')
                  : (_isNepali ? 'सुरक्षित गर्नुहोस्' : 'Save'),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _saved ? AppColors.green.withValues(alpha: 0.7) : AppColors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: _saved ? 0 : 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ]),
    ]);
  }

  Widget _summaryRow(IconData icon, Color color, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 14),
      child: Row(children: [
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(9)),
          child: Icon(icon, color: color, size: 17),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: TextStyle(color: context.cText3, fontSize: 13))),
        Text(value, style: TextStyle(color: context.cText1, fontSize: 14, fontWeight: FontWeight.w700)),
      ]),
    );
  }

  Widget _sectionLabel(String t) => Text(t,
      style: TextStyle(color: context.cText4, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8));

  // ── Footer ────────────────────────────────────────
  Widget _footer() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Row(children: [
        Container(
          width: 26, height: 26,
          decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(7)),
          child: const Icon(Icons.business_rounded, color: Colors.white, size: 14),
        ),
        const SizedBox(width: 7),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Tech Procod PVT LTD',
              style: TextStyle(color: context.cText2, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.2)),
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
