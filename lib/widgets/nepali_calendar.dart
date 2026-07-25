import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/nepali_date.dart';
import '../theme/app_theme.dart';
import '../widgets/pro_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// LIVE NEPALI DATE WIDGET — tappable, shows today's BS date + day name
// ─────────────────────────────────────────────────────────────────────────────
class LiveNepaliDateWidget extends StatefulWidget {
  final bool isNepali;
  const LiveNepaliDateWidget({super.key, required this.isNepali});

  @override
  State<LiveNepaliDateWidget> createState() => _LiveNepaliDateWidgetState();
}

class _LiveNepaliDateWidgetState extends State<LiveNepaliDateWidget> {
  late NepaliDate _today;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _today = NepaliDate.today();
    // Refresh at midnight
    _timer = Timer.periodic(const Duration(minutes: 30), (_) {
      final fresh = NepaliDate.today();
      if (fresh != _today) setState(() => _today = fresh);
    });
    _syncTodayDate();
  }

  Future<void> _syncTodayDate() async {
    try {
      final res = await http.get(Uri.parse('https://worldtimeapi.org/api/timezone/Asia/Kathmandu')).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final dtStr = data['datetime']?.toString() ?? '';
        if (dtStr.isNotEmpty) {
          final dt = DateTime.parse(dtStr);
          final fresh = NepaliDate.fromAD(dt);
          if (mounted && fresh != _today) {
            setState(() => _today = fresh);
          }
        }
      }
    } catch (_) {
      // Fail silently, fallback to system clock
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wd = NepaliDate.weekday(_today);
    final dayName = widget.isNepali
        ? NepaliDate.weekdaysFullNP[wd]
        : NepaliDate.weekdaysFullEN[wd];
    final monthName = widget.isNepali
        ? NepaliDate.monthsNP[_today.month - 1]
        : NepaliDate.monthsEN[_today.month - 1];
    final dayNum = widget.isNepali
        ? NepaliDate.toNepaliNum(_today.day)
        : _today.day.toString();
    final yearNum = widget.isNepali
        ? NepaliDate.toNepaliNum(_today.year)
        : _today.year.toString();

    // AD date
    final ad = NepaliDate.toAD(_today);
    const adMonthsEN = ['Jan','Feb','Mar','Apr','May','Jun',
                        'Jul','Aug','Sep','Oct','Nov','Dec'];
    const adMonthsNP = ['जन','फेब','मार','अप्रिल','मे','जुन',
                        'जुलाई','अग','सेप्ट','अक्ट','नोभ','डिस'];
    final adMonth = widget.isNepali ? adMonthsNP[ad.month - 1] : adMonthsEN[ad.month - 1];
    final adDay   = widget.isNepali ? NepaliDate.toNepaliNum(ad.day) : ad.day.toString();
    final adYear  = widget.isNepali ? NepaliDate.toNepaliNum(ad.year) : ad.year.toString();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        '$dayNum $monthName $yearNum ${widget.isNepali ? "बि.सं." : "BS"}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        '$adDay $adMonth $adYear, $dayName',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.7),
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    ]);
  }

  void _openCalendar(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NepaliCalendarSheet(
        initialDate: _today,
        isNepali: widget.isNepali,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FULL NEPALI CALENDAR SHEET
// ─────────────────────────────────────────────────────────────────────────────
class NepaliCalendarSheet extends StatefulWidget {
  final NepaliDate initialDate;
  final bool isNepali;
  const NepaliCalendarSheet({
    super.key,
    required this.initialDate,
    required this.isNepali,
  });

  @override
  State<NepaliCalendarSheet> createState() => _NepaliCalendarSheetState();
}

class _NepaliCalendarSheetState extends State<NepaliCalendarSheet>
    with SingleTickerProviderStateMixin {
  late int _viewYear;
  late int _viewMonth;
  late NepaliDate _today;
  late NepaliDate _selected;
  late AnimationController _animCtrl;
  late Animation<double> _scaleAnim;

  bool _isLoadingApi = false;
  Map<int, Map<String, dynamic>> _apiDayData = {};

  @override
  void initState() {
    super.initState();
    _today    = NepaliDate.today();
    _selected = widget.initialDate;
    _viewYear  = _selected.year;
    _viewMonth = _selected.month;
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 280));
    _scaleAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutBack);
    _animCtrl.forward();
    _fetchApiData(_viewYear, _viewMonth);
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  bool get isNP => widget.isNepali;

  int? _parseNPNum(String np) {
    const npDigits = {'०': 0, '१': 1, '२': 2, '३': 3, '४': 4, '५': 5, '६': 6, '७': 7, '८': 8, '९': 9};
    String digits = '';
    for (int i = 0; i < np.length; i++) {
      final char = np[i];
      if (npDigits.containsKey(char)) {
        digits += npDigits[char].toString();
      }
    }
    return int.tryParse(digits);
  }

  Future<void> _fetchApiData(int year, int month) async {
    setState(() {
      _isLoadingApi = true;
      _apiDayData = {};
    });
    try {
      final url = Uri.parse('https://raw.githubusercontent.com/S4NKALP/nepali-calendar-api/main/data/$year/$month.json');
      final res = await http.get(url).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final List<dynamic> days = data['days'] ?? [];
        final Map<int, Map<String, dynamic>> parsedData = {};
        for (final dayObj in days) {
          final nStr = dayObj['n']?.toString() ?? '';
          if (nStr.isNotEmpty) {
            final dayNum = _parseNPNum(nStr);
            if (dayNum != null) {
              parsedData[dayNum] = Map<String, dynamic>.from(dayObj);
            }
          }
        }
        if (mounted && _viewYear == year && _viewMonth == month) {
          setState(() {
            _apiDayData = parsedData;
            _isLoadingApi = false;
          });
        }
      } else {
        throw Exception('Server error: ${res.statusCode}');
      }
    } catch (e) {
      debugPrint('Failed to fetch calendar data: $e');
      if (mounted && _viewYear == year && _viewMonth == month) {
        setState(() {
          _isLoadingApi = false;
        });
      }
    }
  }

  void _prevMonth() {
    setState(() {
      if (_viewMonth == 1) { _viewMonth = 12; _viewYear--; }
      else { _viewMonth--; }
    });
    _fetchApiData(_viewYear, _viewMonth);
  }

  void _nextMonth() {
    setState(() {
      if (_viewMonth == 12) { _viewMonth = 1; _viewYear++; }
      else { _viewMonth++; }
    });
    _fetchApiData(_viewYear, _viewMonth);
  }

  void _goToday() {
    setState(() {
      _viewYear  = _today.year;
      _viewMonth = _today.month;
      _selected  = _today;
    });
    _fetchApiData(_viewYear, _viewMonth);
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
      child: DraggableScrollableSheet(
        initialChildSize: 0.90,
        minChildSize: 0.60,
        maxChildSize: 0.95,
        builder: (_, scrollCtrl) => Container(
          decoration: BoxDecoration(
            color: context.cBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(children: [
            const SizedBox(height: 12),
            const SheetHandle(),
            const SizedBox(height: 4),
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollCtrl,
                child: Column(children: [
                  _buildWeekdayRow(context),
                  _buildDayGrid(context),
                  const SizedBox(height: 16),
                  _buildSelectedDetails(context),
                  const SizedBox(height: 24),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final monthName = isNP
        ? NepaliDate.monthsNP[_viewMonth - 1]
        : NepaliDate.monthsEN[_viewMonth - 1];
    final yearStr = isNP
        ? NepaliDate.toNepaliNum(_viewYear)
        : _viewYear.toString();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Row(children: [
        _navBtn(Icons.chevron_left_rounded, _prevMonth),
        const SizedBox(width: 6),
        Expanded(
          child: Column(children: [
            GestureDetector(
              onTap: _goToday,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$monthName $yearStr',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: context.cText1,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  if (_isLoadingApi) ...[
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.blue),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              isNP ? 'बि.सं. (Bikram Sambat)' : 'Bikram Sambat (बि.सं.)',
              style: TextStyle(color: context.cText4, fontSize: 11),
            ),
          ]),
        ),
        const SizedBox(width: 6),
        _navBtn(Icons.chevron_right_rounded, _nextMonth),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: _goToday,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isNP ? 'आज' : 'Today',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _navBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: context.cSurface2,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: context.cText2, size: 22),
      ),
    );
  }

  Widget _buildWeekdayRow(BuildContext context) {
    final days = isNP ? NepaliDate.weekdaysNP : NepaliDate.weekdaysEN;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: List.generate(7, (i) {
          final isSun = i == 0;
          final isSat = i == 6;
          return Expanded(
            child: Center(
              child: Text(
                days[i],
                style: TextStyle(
                  color: isSun
                      ? AppColors.red
                      : isSat
                          ? AppColors.blue
                          : context.cText4,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDayGrid(BuildContext context) {
    final firstWd   = NepaliDate.firstWeekdayOfMonth(_viewYear, _viewMonth);
    final daysInMon = NepaliDate.daysInMonth(_viewYear, _viewMonth);
    final prevMonth = _viewMonth == 1 ? 12 : _viewMonth - 1;
    final prevYear  = _viewMonth == 1 ? _viewYear - 1 : _viewYear;
    final prevDays  = NepaliDate.daysInMonth(prevYear, prevMonth);

    final totalCells = (firstWd + daysInMon + 6) ~/ 7 * 7;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          childAspectRatio: 1.0,
        ),
        itemCount: totalCells,
        itemBuilder: (_, idx) {
          int day;
          bool currentMonth;
          bool isNextMonth;

          if (idx < firstWd) {
            day = prevDays - firstWd + idx + 1;
            currentMonth = false;
            isNextMonth = false;
          } else if (idx < firstWd + daysInMon) {
            day = idx - firstWd + 1;
            currentMonth = true;
            isNextMonth = false;
          } else {
            day = idx - firstWd - daysInMon + 1;
            currentMonth = false;
            isNextMonth = true;
          }

          final thisDate = currentMonth
              ? NepaliDate(_viewYear, _viewMonth, day)
              : isNextMonth
                  ? NepaliDate(
                      _viewMonth == 12 ? _viewYear + 1 : _viewYear,
                      _viewMonth == 12 ? 1 : _viewMonth + 1,
                      day,
                    )
                  : NepaliDate(prevYear, prevMonth, day);

          final isToday   = thisDate == _today;
          final isSelected = thisDate == _selected;
          final weekday   = idx % 7; // 0=Sun, 6=Sat
          final isSunday  = weekday == 0;
          final isSaturday = weekday == 6;

          // Get API details
          final apiData = currentMonth ? _apiDayData[day] : null;
          final tithi = apiData?['t']?.toString() ?? '';
          final isHoliday = apiData?['h'] == true;

          Color textColor;
          if (!currentMonth) {
            textColor = context.cText4.withValues(alpha: 0.4);
          } else if (isHoliday || isSaturday) {
            textColor = AppColors.red;
          } else if (isSunday) {
            textColor = context.cText1;
          } else {
            textColor = context.cText1;
          }

          final dayStr = isNP ? NepaliDate.toNepaliNum(day) : day.toString();

          return GestureDetector(
            onTap: currentMonth ? () => setState(() => _selected = thisDate) : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.blue
                    : isToday
                        ? AppColors.blue.withValues(alpha: 0.12)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: isToday && !isSelected
                    ? Border.all(color: AppColors.blue, width: 1.5)
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayStr,
                    style: TextStyle(
                      color: isSelected ? Colors.white : textColor,
                      fontSize: 14,
                      fontWeight: isToday || isSelected ? FontWeight.w800 : FontWeight.w500,
                    ),
                  ),
                  if (currentMonth && tithi.isNotEmpty) ...[
                    const SizedBox(height: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Text(
                        tithi,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isSelected ? Colors.white.withValues(alpha: 0.85) : context.cText4,
                          fontSize: 8,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSelectedDetails(BuildContext context) {
    final ad = NepaliDate.toAD(_selected);
    final wd = NepaliDate.weekday(_selected);
    final dayNameNP = NepaliDate.weekdaysFullNP[wd];
    final dayNameEN = NepaliDate.weekdaysFullEN[wd];
    final bsMonthNP = NepaliDate.monthsNP[_selected.month - 1];
    final bsMonthEN = NepaliDate.monthsEN[_selected.month - 1];

    const adMonthsEN = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    const adMonthsNP = [
      'जनवरी','फेब्रुअरी','मार्च','अप्रिल','मे','जुन',
      'जुलाई','अगस्त','सेप्टेम्बर','अक्टोबर','नोभेम्बर','डिसेम्बर'
    ];
    final adMonthName = isNP ? adMonthsNP[ad.month - 1] : adMonthsEN[ad.month - 1];
    final isSelectedToday = _selected == _today;

    final apiData = _apiDayData[_selected.day];
    final tithiVal = apiData?['t']?.toString() ?? '';
    final festivalVal = apiData?['f']?.toString() ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ProCard(
        padding: EdgeInsets.zero,
        borderColor: AppColors.blue.withValues(alpha: 0.2),
        child: Column(children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  isNP
                      ? '${NepaliDate.toNepaliNum(_selected.day)} $bsMonthNP ${NepaliDate.toNepaliNum(_selected.year)}'
                      : '${_selected.day} $bsMonthEN ${_selected.year}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  isNP ? '$dayNameNP — बि.सं.' : '$dayNameEN — BS',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 13,
                  ),
                ),
              ]),
              const Spacer(),
              if (isSelectedToday)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isNP ? 'आज' : 'Today',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ]),
          ),
          _detailRow(
            context,
            Icons.calendar_today_rounded,
            AppColors.green,
            isNP ? 'इ.सं. मिति' : 'AD Date',
            isNP
                ? '${NepaliDate.toNepaliNum(ad.day)} $adMonthName ${NepaliDate.toNepaliNum(ad.year)}'
                : '${ad.day} $adMonthName ${ad.year}',
            false,
          ),
          if (tithiVal.isNotEmpty)
            _detailRow(
              context,
              Icons.star_rounded,
              AppColors.purple,
              isNP ? 'तिथि' : 'Tithi',
              tithiVal,
              festivalVal.isEmpty,
            ),
          if (festivalVal.isNotEmpty)
            _detailRow(
              context,
              Icons.festival_rounded,
              AppColors.red,
              isNP ? 'चाडपर्व / घटना' : 'Festival / Event',
              festivalVal,
              true,
            ),
          if (tithiVal.isEmpty && festivalVal.isEmpty) ...[
            _detailRow(
              context,
              Icons.wb_sunny_rounded,
              AppColors.amber,
              isNP ? 'वार दिन' : 'Day of Week',
              isNP ? dayNameNP : dayNameEN,
              false,
            ),
            _detailRow(
              context,
              Icons.date_range_rounded,
              AppColors.indigo,
              isNP ? 'महिना' : 'Month',
              isNP
                  ? '$bsMonthNP (${_selected.month}${isNP ? "" : "th"} month)'
                  : '$bsMonthEN (Month ${_selected.month})',
              false,
            ),
            _detailRow(
              context,
              Icons.view_week_rounded,
              AppColors.cyan,
              isNP ? 'हप्ताको दिन नं.' : 'Week Day No.',
              isNP
                  ? NepaliDate.toNepaliNum(wd + 1)
                  : (wd + 1).toString(),
              true,
            ),
          ]
        ]),
      ),
    );
  }

  Widget _detailRow(BuildContext ctx, IconData icon, Color color,
      String label, String value, bool isLast) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: color, size: 17),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: TextStyle(color: ctx.cText3, fontSize: 13)),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: ctx.cText1,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                )),
          ),
        ]),
      ),
      if (!isLast)
        Divider(color: ctx.cBorder, height: 1, indent: 16, endIndent: 16),
    ]);
  }
}

