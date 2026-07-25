import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/nepali_date.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_hero_header.dart';
import '../widgets/app_drawer.dart';
import '../widgets/features_sheet.dart';
import '../widgets/pro_widgets.dart';
import 'history_screen.dart';
import 'simple_interest_screen.dart';
import 'emi_screen.dart';
import 'land_screen.dart';
import 'currency_screen.dart';
import 'report_screen.dart';
import 'civil_calc_screen.dart';
import 'profit_loss_screen.dart';
import 'input_screen.dart';
import '../widgets/civil_calc_fab.dart';

class WidgetSettingsScreen extends StatefulWidget {
  final bool? isNepali;
  final String? languageCode;
  const WidgetSettingsScreen({super.key, this.isNepali, this.languageCode});

  @override
  State<WidgetSettingsScreen> createState() => _WidgetSettingsScreenState();
}

class _WidgetSettingsScreenState extends State<WidgetSettingsScreen>
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

  bool _notifEnabled  = false;
  bool _notifNepali   = true;
  bool _widgetNepali  = true;
  bool _loading       = true;

  late final AnimationController _fadeCtrl;
  late final Animation<double>   _fadeAnim;

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
    final enabled   = await NotificationService.isEnabled();
    final notifLang = await NotificationService.isNepaliLanguage();
    final prefs     = await SharedPreferences.getInstance();
    final wLang     = prefs.getBool('widget_use_nepali') ?? true;
    setState(() {
      _notifEnabled = enabled;
      _notifNepali  = notifLang;
      _widgetNepali = wLang;
      _loading      = false;
    });
    _fadeCtrl.forward();
  }

  Future<void> _toggleNotification(bool val) async {
    if (val) {
      // show optimistic toggle, then check permission
      setState(() => _notifEnabled = true);
      final granted = await NotificationService.setEnabled(
          enabled: true, useNepali: _notifNepali);
      if (!granted) {
        setState(() => _notifEnabled = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(_isNepali
                ? 'सूचना अनुमति अस्वीकार भयो। सेटिङ्समा गएर अनुमति दिनुहोस्।'
                : 'Notification permission denied. Enable it in app settings.'),
            backgroundColor: AppColors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ));
        }
      }
    } else {
      setState(() => _notifEnabled = false);
      await NotificationService.setEnabled(enabled: false, useNepali: _notifNepali);
    }
  }

  Future<void> _setNotifLang(bool useNepali) async {
    setState(() => _notifNepali = useNepali);
    await NotificationService.updateLanguage(useNepali);
  }

  Future<void> _setWidgetLang(bool useNepali) async {
    setState(() => _widgetNepali = useNepali);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('widget_use_nepali', useNepali);
    // Update home widget
    await HomeWidget.saveWidgetData<bool>('use_nepali_language', useNepali);
    await HomeWidget.updateWidget(
      name: 'NepaliDateWidgetProvider',
    );
    _showSnack(_isNepali ? 'होम स्क्रिन विजेट अपडेट भयो' : 'Home screen widget updated');
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.green,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final today = NepaliDate.today();
    final wd    = NepaliDate.weekday(today);

    return Scaffold(
      backgroundColor: context.cBg,
      floatingActionButton: CivilCalcFab(languageCode: _languageCode),
      body: Container(
        decoration: BoxDecoration(
          gradient: context.isDark ? AppTheme.pageGradientDark : AppTheme.pageGradientLight,
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Column(
              children: [
                _buildHeader(),
                if (_loading)
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.blue, strokeWidth: 2),
                    ),
                  )
                else
                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      children: [
                        _sectionLabel(_isNepali ? 'आजको मिति पूर्वावलोकन' : 'Today\'s Date Preview'),
                        const SizedBox(height: 12),
                        _previewCard(today, wd),
                        const SizedBox(height: 28),
                        _sectionLabel(_isNepali ? 'सूचना पट्टी (Notification Bar)' : 'Notification Bar'),
                        const SizedBox(height: 8),
                        Text(
                          _isNepali
                              ? 'नोटिफिकेसन बारमा आजको नेपाली मिति सधैँ देखाउनुहोस्'
                              : 'Always show today\'s Nepali date in the notification bar',
                          style: TextStyle(color: context.cText4, fontSize: 13),
                        ),
                        const SizedBox(height: 12),
                        ProCard(
                          padding: EdgeInsets.zero,
                          child: Column(
                            children: [
                              _switchRow(
                                icon: Icons.notifications_active_rounded,
                                color: AppColors.blue,
                                title: _isNepali ? 'सूचना सक्रिय गर्नुहोस्' : 'Enable Notification',
                                subtitle: _isNepali
                                    ? 'नोटिफिकेसन बारमा मिति देखाउनुहोस्'
                                    : 'Show date in notification bar',
                                value: _notifEnabled,
                                onChanged: _toggleNotification,
                              ),
                              if (_notifEnabled) ...[
                                Divider(color: context.cBorder, height: 1, indent: 16, endIndent: 16),
                                _langRow(
                                  icon: Icons.translate_rounded,
                                  color: AppColors.indigo,
                                  title: _isNepali ? 'सूचनाको भाषा' : 'Notification Language',
                                  isNepali: _notifNepali,
                                  onChanged: _setNotifLang,
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                        _sectionLabel(_isNepali ? 'होम स्क्रिन विजेट' : 'Home Screen Widget'),
                        const SizedBox(height: 8),
                        Text(
                          _isNepali
                              ? 'होम स्क्रिनमा विजेट थप्न: होम स्क्रिन → लामो थिच्नुहोस् → Widgets → चक्रिय ब्याज'
                              : 'To add widget: Home screen → Long press → Widgets → Chakriya Byaj',
                          style: TextStyle(color: context.cText4, fontSize: 13),
                        ),
                        const SizedBox(height: 12),
                        ProCard(
                          padding: EdgeInsets.zero,
                          child: _langRow(
                            icon: Icons.translate_rounded,
                            color: AppColors.cyan,
                            title: _isNepali ? 'विजेट भाषा' : 'Widget Language',
                            isNepali: _widgetNepali,
                            onChanged: _setWidgetLang,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _widgetPreview(today, wd),
                        const SizedBox(height: 28),
                        _howToCard(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
              ],
            ),
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

  Widget _buildHeader() {
    return AppHeroHeader(
      languageCode: _languageCode,
      title: getTxt('मिति विजेट सेटिङ', 'दिनांक विजेट सेटिंग', 'Date Widget Settings'),
      activeScreen: HeroScreen.widget,
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
      activeScreen: HeroScreen.widget,
      onNavigate: _handleQuickNav,
    );
  }

  Widget _sectionLabel(String t) => Text(t,
      style: TextStyle(color: context.cText4, fontSize: 11,
          fontWeight: FontWeight.w700, letterSpacing: 0.8));

  Widget _previewCard(NepaliDate today, int wd) {
    final dayName    = _isNepali ? NepaliDate.weekdaysFullNP[wd] : NepaliDate.weekdaysFullEN[wd];
    final monthName  = _isNepali ? NepaliDate.monthsNP[today.month - 1] : NepaliDate.monthsEN[today.month - 1];
    final dayNum     = _isNepali ? NepaliDate.toNepaliNum(today.day) : today.day.toString();
    final yearNum    = _isNepali ? NepaliDate.toNepaliNum(today.year) : today.year.toString();
    final ad         = NepaliDate.toAD(today);
    const adMonths   = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final adStr      = '${adMonths[ad.month - 1]} ${ad.day}, ${ad.year} AD';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.blueShadow,
      ),
      child: Row(children: [
        // Big date number
        Container(
          width: 72, height: 72,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Center(
            child: Text(dayNum,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                )),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('$monthName $yearNum',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              )),
          Text(_isNepali ? 'बि.सं.' : 'Bikram Sambat',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 11)),
          const SizedBox(height: 8),
          Text(dayName,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
          Text(adStr,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12)),
        ])),
      ]),
    );
  }

  Widget _switchRow({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(color: context.cText1, fontSize: 14, fontWeight: FontWeight.w700)),
          Text(subtitle, style: TextStyle(color: context.cText4, fontSize: 12)),
        ])),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.blue,
        ),
      ]),
    );
  }

  Widget _langRow({
    required IconData icon,
    required Color color,
    required String title,
    required bool isNepali,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(title,
            style: TextStyle(color: context.cText1, fontSize: 14, fontWeight: FontWeight.w700))),
        // Language toggle chips
        _langChip('नेपाली', isNepali, () => onChanged(true)),
        const SizedBox(width: 8),
        _langChip('English', !isNepali, () => onChanged(false)),
      ]),
    );
  }

  Widget _langChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.blue : context.cSurface2,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.blue : context.cBorder,
          ),
        ),
        child: Text(label,
            style: TextStyle(
              color: selected ? Colors.white : context.cText3,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            )),
      ),
    );
  }

  Widget _widgetPreview(NepaliDate today, int wd) {
    final dayNum    = _widgetNepali ? NepaliDate.toNepaliNum(today.day) : today.day.toString();
    final monthName = _widgetNepali ? NepaliDate.monthsNP[today.month - 1] : NepaliDate.monthsEN[today.month - 1];
    final yearNum   = _widgetNepali ? NepaliDate.toNepaliNum(today.year) : today.year.toString();
    final dayName   = _widgetNepali ? NepaliDate.weekdaysFullNP[wd] : NepaliDate.weekdaysFullEN[wd];
    final ad        = NepaliDate.toAD(today);
    const adMonths  = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final adStr     = '${adMonths[ad.month - 1]} ${ad.day}, ${ad.year} AD';

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        _isNepali ? 'विजेट पूर्वावलोकन' : 'Widget Preview',
        style: TextStyle(color: context.cText4, fontSize: 12, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 10),
      Center(
        child: Container(
          width: 180,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(18),
            boxShadow: AppTheme.blueShadow,
          ),
          child: Column(children: [
            Text(dayNum,
                style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w900, height: 1.0)),
            const SizedBox(height: 4),
            Text('$monthName $yearNum',
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
            Text(dayName,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11)),
            const SizedBox(height: 8),
            Container(height: 1, color: Colors.white.withValues(alpha: 0.3)),
            const SizedBox(height: 8),
            Text(adStr,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 10)),
          ]),
        ),
      ),
    ]);
  }

  Widget _howToCard() {
    final steps = _isNepali ? [
      '१. होम स्क्रिनमा खाली ठाउँमा लामो थिच्नुहोस्',
      '२. "Widgets" विकल्प छान्नुहोस्',
      '३. "चक्रिय ब्याज" खोज्नुहोस्',
      '४. "Nepali Date Widget" छानेर राख्नुहोस्',
    ] : [
      '1. Long press on empty space on your home screen',
      '2. Tap "Widgets" option',
      '3. Search for "Chakriya Byaj"',
      '4. Drag "Nepali Date Widget" to your home screen',
    ];

    return ProCard(
      borderColor: AppColors.amber.withValues(alpha: 0.3),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppColors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.help_outline_rounded, color: AppColors.amber, size: 18),
          ),
          const SizedBox(width: 12),
          Text(
            _isNepali ? 'विजेट कसरी थप्ने?' : 'How to add the widget?',
            style: TextStyle(color: context.cText1, fontSize: 14, fontWeight: FontWeight.w800),
          ),
        ]),
        const SizedBox(height: 14),
        ...steps.map((s) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.circle, color: AppColors.amber, size: 6),
            const SizedBox(width: 10),
            Expanded(child: Text(s,
                style: TextStyle(color: context.cText3, fontSize: 13))),
          ]),
        )),
      ]),
    );
  }
}
