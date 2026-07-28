import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/saved_record.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_hero_header.dart';
import '../widgets/app_drawer.dart';
import '../widgets/features_sheet.dart';
import '../widgets/pro_widgets.dart';
import 'simple_interest_screen.dart';
import 'emi_screen.dart';
import 'land_screen.dart';
import 'currency_screen.dart';
import 'report_screen.dart';
import 'widget_settings_screen.dart';
import 'civil_calc_screen.dart';
import 'profit_loss_screen.dart';
import 'input_screen.dart';
import '../widgets/civil_calc_fab.dart';

class HistoryScreen extends StatefulWidget {
  final bool? isNepali;
  final String? languageCode;
  const HistoryScreen({super.key, this.isNepali, this.languageCode});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
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
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final data = await StorageService.loadAll();
    setState(() { _records = data; _loading = false; });
    _fadeCtrl.forward();
  }

  Future<void> _delete(SavedRecord r) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: context.cBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(_isNepali ? 'मेटाउने?' : 'Delete?',
            style: TextStyle(color: context.cText1, fontWeight: FontWeight.w800)),
        content: Text(
          _isNepali ? "'${r.name}' को हिसाब मेटाउनु हुन्छ?" : "Delete record for '${r.name}'?",
          style: TextStyle(color: context.cText3),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(_isNepali ? 'रद्द' : 'Cancel',
                style: TextStyle(color: context.cText3)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red, foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(_isNepali ? 'मेटाउनुहोस्' : 'Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) { await StorageService.delete(r.id); _load(); }
  }

  Future<void> _deleteAll() async {
    if (_records.isEmpty) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: context.cBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(_isNepali ? 'सबै मेटाउने?' : 'Delete All?',
            style: TextStyle(color: context.cText1, fontWeight: FontWeight.w800)),
        content: Text(
          _isNepali ? 'सबै सुरक्षित हिसाबहरू मेटाइनेछ।' : 'All saved records will be deleted.',
          style: TextStyle(color: context.cText3),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(_isNepali ? 'रद्द' : 'Cancel', style: TextStyle(color: context.cText3)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red, foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(_isNepali ? 'सबै मेटाउनुहोस्' : 'Delete All'),
          ),
        ],
      ),
    );
    if (confirm == true) { await StorageService.deleteAll(); _load(); }
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

  String _dateStr(SavedRecord r) =>
      '${r.liekoSal}/${r.liekoMahina}/${r.liekoGate} → ${r.bhujaauneSal}/${r.bhujaauneMahina}/${r.bhujaaune_Gate}';

  String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'just now';
  }

  @override
  Widget build(BuildContext context) {
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
                _buildHeroHeader(),
                HeroCalculatorStrip(
                  activeScreen: HeroScreen.history,
                  languageCode: _languageCode,
                  onTap: _handleQuickNav,
                ),
                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.blue, strokeWidth: 2))
                      : _records.isEmpty
                          ? _emptyState()
                          : RefreshIndicator(
                              onRefresh: _load,
                              color: AppColors.blue,
                              child: ListView.separated(
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                                itemCount: _records.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 12),
                                itemBuilder: (_, i) => _recordCard(_records[i]),
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
      title: getTxt('सुरक्षित हिसाबहरू', 'सुरक्षित रिकॉर्ड', 'Saved Records'),
      activeScreen: HeroScreen.history,
      onLangToggle: _toggleLanguage,
      onBack: () => Navigator.pop(context),
      onGridTap: _showAppGrid,
      onQuickNav: _handleQuickNav,
      trailing: _records.isEmpty ? null : GestureDetector(
        onTap: _deleteAll,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.red.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.red.withValues(alpha: 0.35)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 14),
            const SizedBox(width: 4),
            Text(getTxt('सबै', 'सभी', 'All'),
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
      activeScreen: HeroScreen.history,
      onNavigate: _handleQuickNav,
    );
  }

  void _handleQuickNav(HeroScreen screen) {
    void push(Widget w) => Navigator.push(context, PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (_, __, ___) => w,
      transitionsBuilder: (_, a, __, child) =>
          FadeTransition(opacity: CurvedAnimation(parent: a, curve: Curves.easeOut), child: child),
    ));
    switch (screen) {
      case HeroScreen.compound: push(const InputScreen()); break;
      case HeroScreen.simple:   push(SimpleInterestScreen(languageCode: _languageCode)); break;
      case HeroScreen.emi:      push(EmiScreen(languageCode: _languageCode)); break;
      case HeroScreen.land:     push(LandScreen(languageCode: _languageCode)); break;
      case HeroScreen.currency: push(CurrencyScreen(languageCode: _languageCode)); break;
      case HeroScreen.report:   push(ReportScreen(languageCode: _languageCode)); break;
      case HeroScreen.widget:   push(WidgetSettingsScreen(languageCode: _languageCode)); break;
      case HeroScreen.other:    push(ProfitLossScreen(languageCode: _languageCode)); break;
      default: break;
    }
  }

  Widget _emptyState() {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            color: context.cSurface2,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Icon(Icons.folder_open_rounded, size: 38, color: context.cText4.withValues(alpha: 0.5)),
        ),
        const SizedBox(height: 18),
        Text(
          _isNepali ? 'कुनै हिसाब सुरक्षित छैन' : 'No saved records yet',
          style: TextStyle(color: context.cText2, fontSize: 17, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          _isNepali ? 'हिसाब गरेपछि "सुरक्षित गर्नुहोस्" थिच्नुहोस्' : 'Calculate and press "Save" to store records',
          style: TextStyle(color: context.cText4, fontSize: 13),
          textAlign: TextAlign.center,
        ),
      ]),
    );
  }

  Widget _recordCard(SavedRecord r) {
    return Dismissible(
      key: Key(r.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.red.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.delete_rounded, color: AppColors.red, size: 24),
          const SizedBox(height: 4),
          Text(_isNepali ? 'मेटाउनुहोस्' : 'Delete',
              style: const TextStyle(color: AppColors.red, fontSize: 11, fontWeight: FontWeight.w600)),
        ]),
      ),
      confirmDismiss: (_) async { await _delete(r); return false; },
      child: ProCard(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  r.name.isNotEmpty ? r.name[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(r.name,
                    style: TextStyle(color: context.cText1, fontSize: 15, fontWeight: FontWeight.w800)),
                Text(_relativeTime(r.savedAt),
                    style: TextStyle(color: context.cText4, fontSize: 11)),
              ]),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                gradient: AppTheme.greenGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('रु ${_fmt(r.totalAmount)}',
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800)),
            ),
          ]),
          const SizedBox(height: 12),
          Divider(color: context.cBorder, height: 1),
          const SizedBox(height: 10),
          Row(children: [
            Icon(Icons.date_range_rounded, size: 13, color: context.cText4),
            const SizedBox(width: 6),
            Expanded(child: Text(_dateStr(r),
                style: TextStyle(color: context.cText3, fontSize: 12))),
          ]),
          const SizedBox(height: 8),
          Wrap(spacing: 6, runSpacing: 6, children: [
            ChipBadge(label: 'रु ${_fmt(r.mulDhan)}', color: AppColors.blue),
            ChipBadge(label: '${r.byajDar}% / ${_isNepali ? "महिना" : "mo"}', color: AppColors.amber),
            ChipBadge(label: '${_isNepali ? "ब्याज" : "Int"}: रु ${_fmt(r.jammaByaj)}', color: AppColors.indigo),
          ]),
          if (r.note.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.notes_rounded, size: 13, color: context.cText4),
              const SizedBox(width: 6),
              Expanded(child: Text(r.note,
                  style: TextStyle(color: context.cText3, fontSize: 12, fontStyle: FontStyle.italic))),
            ]),
          ],
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => _delete(r),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.delete_outline_rounded, size: 14, color: AppColors.red.withValues(alpha: 0.7)),
                const SizedBox(width: 4),
                Text(_isNepali ? 'मेटाउनुहोस्' : 'Delete',
                    style: TextStyle(color: AppColors.red.withValues(alpha: 0.7),
                        fontSize: 12, fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}
