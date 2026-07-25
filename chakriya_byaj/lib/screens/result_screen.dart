import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_strings.dart';
import '../models/calculation_model.dart';
import '../models/saved_record.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_hero_header.dart';
import '../widgets/features_sheet.dart';
import '../widgets/pro_widgets.dart';
import 'history_screen.dart';
import 'simple_interest_screen.dart';
import 'emi_screen.dart';
import 'land_screen.dart';
import 'currency_screen.dart';
import 'report_screen.dart';
import 'widget_settings_screen.dart';

class ResultScreen extends StatefulWidget {
  final CalculationModel model;
  final bool? isNepali;
  final String? languageCode;
  const ResultScreen({
    super.key,
    required this.model,
    this.isNepali,
    this.languageCode,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with TickerProviderStateMixin {
  late String _languageCode;
  bool get _isNepali => _languageCode == 'np';
  bool get _isHindi => _languageCode == 'hi';
  bool get _isEnglish => _languageCode == 'en';

  String getTxt(String np, String hi, String en) {
    if (_isNepali) return np;
    if (_isHindi) return hi;
    return en;
  }

  bool _saved = false;

  late final AnimationController _countCtrl;
  late final Animation<double> _countAnim;
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;
  late final AnimationController _slideCtrl;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _languageCode = widget.languageCode ?? (widget.isNepali == true ? 'np' : 'en');
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));

    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _slideCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));
    _countCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _countAnim = CurvedAnimation(parent: _countCtrl, curve: Curves.easeOutCubic);
    _fadeCtrl.forward();
    _slideCtrl.forward();
    _countCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _slideCtrl.dispose();
    _countCtrl.dispose();
    super.dispose();
  }

  AppStrings get s => AppStrings(languageCode: _languageCode);

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

  void _openSaveSheet() {
    final nameCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.cBg,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 14,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          const SheetHandle(),
          const SizedBox(height: 20),
          Text(_isNepali ? 'हिसाब सुरक्षित गर्नुहोस्' : 'Save Record',
              style: TextStyle(color: context.cText1, fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 5),
          Text(_isNepali ? 'ऋणीको नाम र टिप्पणी थप्नुहोस्' : 'Add borrower name and optional note',
              style: TextStyle(color: context.cText4, fontSize: 13)),
          const SizedBox(height: 20),
          Text(_isNepali ? 'ऋणीको नाम *' : 'Borrower Name *',
              style: TextStyle(color: context.cText3, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          _saveTextField(nameCtrl, _isNepali ? 'जस्तै: राम बहादुर' : 'e.g. Ram Bahadur',
              Icons.person_rounded, AppColors.blue, autofocus: true),
          const SizedBox(height: 16),
          Text(_isNepali ? 'टिप्पणी (वैकल्पिक)' : 'Note (optional)',
              style: TextStyle(color: context.cText3, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          _saveTextArea(noteCtrl, _isNepali ? 'जस्तै: घर जग्गाको लागि ऋण' : 'e.g. Loan for house'),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(ctx),
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.cText2,
                  side: BorderSide(color: context.cBorderMid),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(_isNepali ? 'रद्द' : 'Cancel',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(flex: 2, child: ElevatedButton.icon(
              onPressed: () async {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) {
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                    content: Text(_isNepali ? 'नाम अनिवार्य छ' : 'Name is required'),
                    backgroundColor: AppColors.red, behavior: SnackBarBehavior.floating,
                  ));
                  return;
                }
                final m = widget.model;
                final record = SavedRecord(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: name, note: noteCtrl.text.trim(),
                  liekoSal: m.liekoSal, liekoMahina: m.liekoMahina, liekoGate: m.liekoGate,
                  bhujaauneSal: m.bhujaauneSal, bhujaauneMahina: m.bhujaauneMahina,
                  bhujaaune_Gate: m.bhujaaune_Gate, mulDhan: m.mulDhan, byajDar: m.byajDar,
                  jammaByaj: m.jammaByaj, totalAmount: m.totalAmount, savedAt: DateTime.now(),
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
                    Text(_isNepali ? "'$name' को हिसाब सुरक्षित भयो" : "'$name' saved successfully"),
                  ]),
                  backgroundColor: AppColors.green, behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ));
              },
              icon: const Icon(Icons.save_rounded, size: 18),
              label: Text(_isNepali ? 'सुरक्षित गर्नुहोस्' : 'Save',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green, foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15), elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            )),
          ]),
        ]),
      ),
    );
  }

  Widget _saveTextField(TextEditingController ctrl, String hint, IconData icon, Color color, {bool autofocus = false}) {
    return TextField(
      controller: ctrl, autofocus: autofocus,
      textCapitalization: TextCapitalization.words,
      style: TextStyle(color: context.cText1, fontSize: 16, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: hint, hintStyle: TextStyle(color: context.cHint),
        prefixIcon: Icon(icon, color: color, size: 18),
        filled: true, fillColor: context.cSurface, isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: context.cBorder)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: context.cBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: color, width: 2)),
      ),
    );
  }

  Widget _saveTextArea(TextEditingController ctrl, String hint) {
    return TextField(
      controller: ctrl, maxLines: 3,
      textCapitalization: TextCapitalization.sentences,
      style: TextStyle(color: context.cText1, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint, hintStyle: TextStyle(color: context.cHint, fontSize: 13),
        prefixIcon: const Padding(padding: EdgeInsets.only(bottom: 40),
            child: Icon(Icons.notes_rounded, color: AppColors.amber, size: 18)),
        filled: true, fillColor: context.cSurface, isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: context.cBorder)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: context.cBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.amber, width: 2)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final m     = widget.model;
    final dur   = m.byajChaleko;
    final byaj  = m.jammaByaj;
    final total = m.totalAmount;

    return Scaffold(
      backgroundColor: context.cBg,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: SafeArea(
            child: CustomScrollView(
              physics: const ClampingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: AppHeroHeader(
                  languageCode: _languageCode,
                  title: s.appTitle,
                  activeScreen: HeroScreen.result,
                  onLangToggle: _toggleLanguage,
                  onBack: () => Navigator.pop(context),
                  onGridTap: () => showFeaturesSheet(
                    context: context,
                    languageCode: _languageCode,
                    onNavigate: (icon) {
                      void push(Widget screen) => Navigator.push(context, PageRouteBuilder(
                        transitionDuration: const Duration(milliseconds: 320),
                        pageBuilder: (_, __, ___) => screen,
                        transitionsBuilder: (_, anim, __, child) => FadeTransition(
                            opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut), child: child),
                      ));
                      if (icon == Icons.calculate_rounded) {
                        Navigator.pop(context);
                      } else if (icon == Icons.history_rounded) {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => HistoryScreen(languageCode: _languageCode)));
                      } else if (icon == Icons.percent_rounded) {
                        push(SimpleInterestScreen(languageCode: _languageCode));
                      } else if (icon == Icons.account_balance_rounded) {
                        push(EmiScreen(languageCode: _languageCode));
                      } else if (icon == Icons.terrain_rounded) {
                        push(LandScreen(languageCode: _languageCode));
                      } else if (icon == Icons.currency_exchange_rounded) {
                        push(CurrencyScreen(languageCode: _languageCode));
                      } else if (icon == Icons.pie_chart_rounded) {
                        push(ReportScreen(languageCode: _languageCode));
                      } else if (icon == Icons.widgets_rounded) {
                        push(WidgetSettingsScreen(languageCode: _languageCode));
                      }
                    },
                  ),
                  onQuickNav: (screen) {
                    void push(Widget w) => Navigator.push(context, PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 320),
                      pageBuilder: (_, __, ___) => w,
                      transitionsBuilder: (_, a, __, child) => FadeTransition(
                          opacity: CurvedAnimation(parent: a, curve: Curves.easeOut), child: child),
                    ));
                    switch (screen) {
                      case HeroScreen.compound: Navigator.pop(context); break;
                      case HeroScreen.simple:   push(SimpleInterestScreen(languageCode: _languageCode)); break;
                      case HeroScreen.emi:      push(EmiScreen(languageCode: _languageCode)); break;
                      case HeroScreen.land:     push(LandScreen(languageCode: _languageCode)); break;
                      case HeroScreen.currency: push(CurrencyScreen(languageCode: _languageCode)); break;
                      case HeroScreen.history:  Navigator.push(context, MaterialPageRoute(builder: (_) => HistoryScreen(languageCode: _languageCode))); break;
                      case HeroScreen.report:   push(ReportScreen(languageCode: _languageCode)); break;
                      case HeroScreen.widget:   push(WidgetSettingsScreen(languageCode: _languageCode)); break;
                      default: break;
                    }
                  },
                )),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(delegate: SliverChildListDelegate([
                    const SizedBox(height: 24),
                    _sectionLabel(_isNepali ? 'विवरण' : 'Details'),
                    const SizedBox(height: 12),
                    ProCard(
                      padding: EdgeInsets.zero,
                      child: Column(children: [
                        SummaryRow(icon: Icons.south_rounded, color: AppColors.cyan,
                            label: s.liekoMitiResult,
                            value: '${m.liekoSal}${s.salSuffix}${m.liekoMahina}${s.mahinaSuffix}${m.liekoGate}${s.gateSuffix}'),
                        SummaryRow(icon: Icons.north_rounded, color: AppColors.indigo,
                            label: s.bhujaauneMitiResult,
                            value: '${m.bhujaauneSal}${s.salSuffix}${m.bhujaauneMahina}${s.mahinaSuffix}${m.bhujaaune_Gate}${s.gateSuffix}'),
                        SummaryRow(icon: Icons.currency_rupee_rounded, color: AppColors.blue,
                            label: s.mulDhanResult, value: 'रु ${_fmt(m.mulDhan)}'),
                        SummaryRow(icon: Icons.percent_rounded, color: AppColors.amber,
                            label: s.byajDarResult, value: '${m.byajDar}% ${_isNepali ? "/ महिना" : "/ month"}', isLast: true),
                      ]),
                    ),
                    const SizedBox(height: 24),
                    _sectionLabel(s.byajChaleko),
                    const SizedBox(height: 12),
                    _durationRow(dur),
                    const SizedBox(height: 24),
                    _sectionLabel(_isNepali ? 'नतिजा' : 'Result'),
                    const SizedBox(height: 12),
                    AnimatedBuilder(
                      animation: _countAnim,
                      builder: (_, __) => ResultTile(
                        label: s.jammaByaj,
                        value: 'रु ${_fmt(byaj * _countAnim.value)}',
                        accent: AppColors.indigo,
                      ),
                    ),
                    const SizedBox(height: 10),
                    AnimatedBuilder(
                      animation: _countAnim,
                      builder: (_, __) => HeroTotalCard(
                        title: s.jammaRakam,
                        amount: 'रु ${_fmt(total * _countAnim.value)}',
                        subtitle: _isNepali ? 'मूलधन + जम्मा ब्याज सहित' : 'Principal + Total Interest',
                        gradient: AppTheme.greenGradient,
                        shadows: AppTheme.greenShadow,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_rounded, size: 18),
                          label: Text(s.newCalc,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: context.cText2,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            side: BorderSide(color: context.cBorderMid),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: ElevatedButton.icon(
                        onPressed: _saved ? null : _openSaveSheet,
                        icon: Icon(_saved ? Icons.check_circle_rounded : Icons.save_rounded, size: 18),
                        label: Text(
                          _saved ? (_isNepali ? 'सुरक्षित' : 'Saved') : (_isNepali ? 'सुरक्षित गर्नुहोस्' : 'Save'),
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _saved ? AppColors.green.withValues(alpha: 0.7) : AppColors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15), elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      )),
                    ]),
                    const SizedBox(height: 24),
                    _footer(context),
                    const SizedBox(height: 24),
                  ])),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String t) => Text(t,
      style: TextStyle(
        color: context.cText4, fontSize: 11,
        fontWeight: FontWeight.w700, letterSpacing: 0.8,
      ));

  Widget _durationRow(Map<String, int> dur) {
    return Row(children: [
      Expanded(child: _durBox(dur['sal']!.toString(), _isNepali ? 'साल' : 'Year', AppColors.blue)),
      const SizedBox(width: 10),
      Expanded(child: _durBox(dur['mahina']!.toString(), _isNepali ? 'महिना' : 'Month', AppColors.indigo)),
      const SizedBox(width: 10),
      Expanded(child: _durBox(dur['din']!.toString(), _isNepali ? 'दिन' : 'Day', AppColors.cyan)),
    ]);
  }

  Widget _durBox(String val, String lbl, Color color) {
    return ProCard(
      padding: const EdgeInsets.symmetric(vertical: 16),
      borderColor: color.withValues(alpha: 0.2),
      child: Column(children: [
        Text(val, style: TextStyle(
          color: context.cText1, fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
        const SizedBox(height: 3),
        Text(lbl, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
      ]),
    );
  }

  Widget _footer(BuildContext ctx) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Row(children: [
        Container(
          width: 30, height: 30,
          decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.business_rounded, color: Colors.white, size: 15),
        ),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Tech Procod PVT LTD',
              style: TextStyle(color: ctx.cText2, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.2)),
          Text(_isNepali ? 'सफ्टवेयर समाधान' : 'Software Solutions',
              style: TextStyle(color: ctx.cText4, fontSize: 9, fontWeight: FontWeight.w500)),
        ]),
      ]),
      Row(children: [
        Icon(Icons.phone_outlined, color: ctx.cText4, size: 13),
        const SizedBox(width: 5),
        Text('+977 9805916598', style: TextStyle(color: ctx.cText3, fontSize: 12)),
      ]),
    ]);
  }
}
