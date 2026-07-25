import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
import 'widget_settings_screen.dart';
import 'civil_calc_screen.dart';
import '../widgets/civil_calc_fab.dart';

class ReportScreen extends StatefulWidget {
  final bool? isNepali;
  final String? languageCode;
  const ReportScreen({super.key, this.isNepali, this.languageCode});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen>
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

  List<SavedRecord> _records = [];
  bool _loading = true;

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _languageCode = widget.languageCode ?? (widget.isNepali == true ? 'np' : 'en');
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _load();
  }

  @override
  void dispose() { _fadeCtrl.dispose(); super.dispose(); }

  Future<void> _load() async {
    final data = await StorageService.loadAll();
    setState(() { _records = data; _loading = false; });
    _fadeCtrl.forward();
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

  double get _totalPrincipal => _records.fold(0, (s, r) => s + r.mulDhan);
  double get _totalInterest  => _records.fold(0, (s, r) => s + r.jammaByaj);
  double get _totalPayable   => _records.fold(0, (s, r) => s + r.totalAmount);
  double get _avgRate        => _records.isEmpty ? 0 : _records.fold(0.0, (s, r) => s + r.byajDar) / _records.length;
  SavedRecord? get _highestLoan     => _records.isEmpty ? null : _records.reduce((a, b) => a.mulDhan > b.mulDhan ? a : b);
  SavedRecord? get _highestInterest => _records.isEmpty ? null : _records.reduce((a, b) => a.jammaByaj > b.jammaByaj ? a : b);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.cBg,
      floatingActionButton: CivilCalcFab(languageCode: _languageCode),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SafeArea(
          child: Column(children: [
            _buildHeroHeader(),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.blue, strokeWidth: 2))
                  : _records.isEmpty
                      ? _emptyState()
                      : RefreshIndicator(
                          onRefresh: _load,
                          color: AppColors.blue,
                          child: ListView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                            children: [
                              _sectionLabel(_isNepali ? 'सारांश' : 'Summary'),
                              const SizedBox(height: 12),
                              _summarySection(),
                              const SizedBox(height: 24),
                              _sectionLabel(_isNepali ? 'विश्लेषण' : 'Analysis'),
                              const SizedBox(height: 12),
                              _analysisCard(),
                              const SizedBox(height: 24),
                              _sectionLabel(_isNepali ? 'ऋणीहरूको तुलना' : 'Borrower Comparison'),
                              const SizedBox(height: 12),
                              _borrowerBars(),
                              const SizedBox(height: 24),
                              _sectionLabel(_isNepali ? 'उल्लेखनीय' : 'Highlights'),
                              const SizedBox(height: 12),
                              _highlights(),
                            ],
                          ),
                        ),
            ),
          ]),
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
      title: getTxt('रिपोर्ट', 'रिपोर्ट', 'Reports'),
      activeScreen: HeroScreen.report,
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
      case HeroScreen.compound: Navigator.pop(context); break;
      case HeroScreen.simple:   push(SimpleInterestScreen(languageCode: _languageCode)); break;
      case HeroScreen.emi:      push(EmiScreen(languageCode: _languageCode)); break;
      case HeroScreen.land:     push(LandScreen(languageCode: _languageCode)); break;
      case HeroScreen.currency: push(CurrencyScreen(languageCode: _languageCode)); break;
      case HeroScreen.history:  Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => HistoryScreen(languageCode: _languageCode))); break;
      case HeroScreen.widget:   push(WidgetSettingsScreen(languageCode: _languageCode)); break;
      default: break;
    }
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
          push(SimpleInterestScreen(languageCode: _languageCode));
        } else if (icon == Icons.account_balance_rounded) {
          push(EmiScreen(languageCode: _languageCode));
        } else if (icon == Icons.terrain_rounded) {
          push(LandScreen(languageCode: _languageCode));
        } else if (icon == Icons.currency_exchange_rounded) {
          push(CurrencyScreen(languageCode: _languageCode));
        } else if (icon == Icons.widgets_rounded) {
          push(WidgetSettingsScreen(languageCode: _languageCode));
        } else if (icon == Icons.construction_rounded) {
          push(CivilCalcScreen(languageCode: _languageCode));
        }
        // pie_chart = already here
      },
    );
  }

  Widget _sectionLabel(String t) => Text(t,
      style: TextStyle(color: context.cText4, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8));

  Widget _summarySection() {
    return Column(children: [
      HeroTotalCard(
        title: _isNepali ? 'जम्मा भुक्तानी योग्य' : 'Total Payable',
        amount: 'रु ${_fmt(_totalPayable)}',
        subtitle: _isNepali ? 'मूलधन + ब्याज सहित' : 'Principal + Interest',
        gradient: AppTheme.greenGradient,
        shadows: AppTheme.greenShadow,
      ),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: StatTile(icon: Icons.currency_rupee_rounded, color: AppColors.blue,
            value: 'रु ${_fmt(_totalPrincipal)}', label: _isNepali ? 'जम्मा मूलधन' : 'Total Principal')),
        const SizedBox(width: 12),
        Expanded(child: StatTile(icon: Icons.percent_rounded, color: AppColors.indigo,
            value: 'रु ${_fmt(_totalInterest)}', label: _isNepali ? 'जम्मा ब्याज' : 'Total Interest')),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: StatTile(icon: Icons.people_rounded, color: AppColors.cyan,
            value: '${_records.length}', label: _isNepali ? 'ऋणीहरू' : 'Borrowers')),
        const SizedBox(width: 12),
        Expanded(child: StatTile(icon: Icons.trending_up_rounded, color: AppColors.amber,
            value: '${_avgRate.toStringAsFixed(1)}%', label: _isNepali ? 'औसत दर' : 'Avg Rate')),
      ]),
    ]);
  }

  Widget _analysisCard() {
    final total = _totalPrincipal + _totalInterest;
    final pRatio = total > 0 ? _totalPrincipal / total : 0.5;
    final iRatio = 1 - pRatio;
    return ProCard(
      padding: const EdgeInsets.all(18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(_isNepali ? 'मूलधन बनाम ब्याज' : 'Principal vs Interest',
            style: TextStyle(color: context.cText1, fontSize: 15, fontWeight: FontWeight.w800)),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Row(children: [
            Expanded(flex: (pRatio * 100).round(),
              child: Container(height: 16, decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.blue, AppColors.cyan])))),
            Expanded(flex: (iRatio * 100).round(),
              child: Container(height: 16, decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.indigo, AppColors.purple])))),
          ]),
        ),
        const SizedBox(height: 14),
        Row(children: [
          _legendItem(AppColors.blue, _isNepali ? 'मूलधन' : 'Principal',
              'रु ${_fmt(_totalPrincipal)}', '${(pRatio * 100).toStringAsFixed(1)}%'),
          const SizedBox(width: 20),
          _legendItem(AppColors.indigo, _isNepali ? 'ब्याज' : 'Interest',
              'रु ${_fmt(_totalInterest)}', '${(iRatio * 100).toStringAsFixed(1)}%'),
        ]),
      ]),
    );
  }

  Widget _legendItem(Color color, String label, String amount, String pct) {
    return Expanded(child: Row(children: [
      Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
      const SizedBox(width: 8),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(color: context.cText4, fontSize: 11)),
        Text(amount, style: TextStyle(color: context.cText1, fontSize: 13, fontWeight: FontWeight.w800)),
        Text(pct, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
      ])),
    ]));
  }

  Widget _borrowerBars() {
    final sorted = [..._records]..sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
    final top = sorted.take(5).toList();
    final maxVal = top.isEmpty ? 1.0 : top.first.totalAmount;
    return ProCard(
      padding: const EdgeInsets.all(18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(_isNepali ? 'शीर्ष ऋणीहरू (जम्मा रकम)' : 'Top Borrowers (Total Amount)',
            style: TextStyle(color: context.cText1, fontSize: 15, fontWeight: FontWeight.w800)),
        const SizedBox(height: 16),
        ...top.asMap().entries.map((e) {
          final r = e.value;
          final ratio = r.totalAmount / maxVal;
          const colors = [AppColors.blue, AppColors.indigo, AppColors.cyan, AppColors.green, AppColors.amber];
          final color = colors[e.key % colors.length];
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(r.name,
                    style: TextStyle(color: context.cText1, fontSize: 13, fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis)),
                Text('रु ${_fmt(r.totalAmount)}',
                    style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
              ]),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Stack(children: [
                  Container(height: 8, color: context.cSurface2),
                  FractionallySizedBox(widthFactor: ratio,
                      child: Container(height: 8, color: color)),
                ]),
              ),
            ]),
          );
        }),
      ]),
    );
  }

  Widget _highlights() {
    return Column(children: [
      if (_highestLoan != null)
        _highlightCard(icon: Icons.arrow_upward_rounded, color: AppColors.blue,
          title: _isNepali ? 'सबैभन्दा ठूलो ऋण' : 'Largest Loan',
          name: _highestLoan!.name, value: 'रु ${_fmt(_highestLoan!.mulDhan)}'),
      if (_highestInterest != null) ...[
        const SizedBox(height: 10),
        _highlightCard(icon: Icons.trending_up_rounded, color: AppColors.indigo,
          title: _isNepali ? 'सबैभन्दा बढी ब्याज' : 'Highest Interest',
          name: _highestInterest!.name, value: 'रु ${_fmt(_highestInterest!.jammaByaj)}'),
      ],
    ]);
  }

  Widget _highlightCard({required IconData icon, required Color color,
      required String title, required String name, required String value}) {
    return ProCard(
      padding: const EdgeInsets.all(16),
      borderColor: color.withValues(alpha: 0.2),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(color: context.cText4, fontSize: 11, fontWeight: FontWeight.w600)),
          Text(name, style: TextStyle(color: context.cText1, fontSize: 14, fontWeight: FontWeight.w800)),
        ])),
        Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w900)),
      ]),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(color: context.cSurface2, borderRadius: BorderRadius.circular(24)),
          child: Icon(Icons.pie_chart_outline_rounded, size: 38, color: context.cText4.withValues(alpha: 0.5)),
        ),
        const SizedBox(height: 18),
        Text(_isNepali ? 'रिपोर्टका लागि डाटा छैन' : 'No data for report',
            style: TextStyle(color: context.cText2, fontSize: 17, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text(_isNepali ? 'पहिले हिसाब गरेर सुरक्षित गर्नुहोस्' : 'Calculate and save records first',
            style: TextStyle(color: context.cText4, fontSize: 13), textAlign: TextAlign.center),
      ]),
    );
  }
}
