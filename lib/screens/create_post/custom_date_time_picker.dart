import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/constants/post_repeat.dart';
import '../../core/theme/app_colors.dart';
import 'package:velie_app/l10n/app_localizations.dart';

export '../../core/constants/post_repeat.dart' show PostRepeat;

/// Result portrait chosen in the custom date & time picker.
class VeliePickerResult {
  final DateTime dateTime;
  final PostRepeat repeat;

  const VeliePickerResult({required this.dateTime, required this.repeat});
}

/// Velie-styled bottom-sheet date & time picker (no Material picker) with a
/// repeat selector. Modeled after SynCal's custom picker. `initialRepeat`
/// carries the previous selection.
Future<VeliePickerResult?> showCustomDateTimePicker({
  required BuildContext context,
  required DateTime initialDateTime,
  DateTime? firstDate,
  DateTime? lastDate,
  PostRepeat initialRepeat = PostRepeat.once,
}) {
  final use24Hour = MediaQuery.of(context).alwaysUse24HourFormat;
  return showModalBottomSheet<VeliePickerResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _CustomDateTimeSheet(
      initialDateTime: initialDateTime,
      firstDate: firstDate ?? DateTime.now(),
      lastDate: lastDate ?? DateTime.now().add(const Duration(days: 365 * 2)),
      initialRepeat: initialRepeat,
      use24Hour: use24Hour,
    ),
  );
}

// PART2

class _CustomDateTimeSheet extends StatefulWidget {
  final DateTime initialDateTime;
  final DateTime firstDate;
  final DateTime lastDate;
  final PostRepeat initialRepeat;
  final bool use24Hour;

  const _CustomDateTimeSheet({
    required this.initialDateTime,
    required this.firstDate,
    required this.lastDate,
    required this.initialRepeat,
    required this.use24Hour,
  });

  @override
  State<_CustomDateTimeSheet> createState() => _CustomDateTimeSheetState();
}

class _CustomDateTimeSheetState extends State<_CustomDateTimeSheet> {
  late DateTime _selectedDate;
  late int _hour24;
  late int _minute;
  late DateTime _visibleMonth;
  late PostRepeat _repeat;
  int _tabIndex = 0; // 0 = date, 1 = time

  static const _months = [
    'Januari', 'Februari', 'Machi', 'Aprili', 'Mei', 'Juni',
    'Julai', 'Agosti', 'Septemba', 'Oktoba', 'Novemba', 'Desemba',
  ];
  static const _weekdayLabels = ['J2', 'J3', 'J4', 'J5', 'J6', 'J7', 'J1'];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime(
      widget.initialDateTime.year,
      widget.initialDateTime.month,
      widget.initialDateTime.day,
    );
    _hour24 = widget.initialDateTime.hour;
    _minute = widget.initialDateTime.minute;
    _visibleMonth = DateTime(_selectedDate.year, _selectedDate.month);
    _repeat = widget.initialRepeat;
  }

  DateTime get _combined => DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _hour24,
        _minute,
      );

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isDateEnabled(DateTime d) {
    final first = DateTime(widget.firstDate.year, widget.firstDate.month, widget.firstDate.day);
    final last = DateTime(widget.lastDate.year, widget.lastDate.month, widget.lastDate.day);
    if (d.isBefore(first)) return false;
    if (d.isAfter(last)) return false;
    // A weekday repeat must start on a business day.
    if (_repeat == PostRepeat.weekdays && (d.weekday == DateTime.saturday || d.weekday == DateTime.sunday)) {
      return false;
    }
    return true;
  }

  void _changeMonth(int delta) {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + delta);
    });
  }

  String _formatHourMinute(int hour24, int minute) {
    final mm = minute.toString().padLeft(2, '0');
    if (widget.use24Hour) {
      return '${hour24.toString().padLeft(2, '0')}:$mm';
    }
    final isPm = hour24 >= 12;
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    return '$hour12:$mm ${isPm ? 'PM' : 'AM'}';
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;
    final screenHeight = MediaQuery.of(context).size.height;
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          height: screenHeight * 0.85,
          padding: EdgeInsets.fromLTRB(20, 14, 20, bottomInset + 16),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.98),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(
                color: Colors.white.withValues(alpha: 0.08),
                width: 0.5,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Chagua Muda',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        color: AppColors.textPrimary,
                        size: 15,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSegmentedTabs(),
              const SizedBox(height: 18),
              Expanded(
                child: SingleChildScrollView(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _tabIndex == 0
                        ? _buildDateTab(key: const ValueKey('date'))
                        : _buildTimeTab(key: const ValueKey('time')),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildRepeatSection(),
              const SizedBox(height: 16),
              _buildConfirmButton(),
            ],
          ),
        ),
      ),
    );
  }
// PART3

  Widget _buildSegmentedTabs() {
    return Row(
      children: [
        Expanded(child: _tabButton('Tarehe', 0)),
        const SizedBox(width: 8),
        Expanded(child: _tabButton(_formatHourMinute(_hour24, _minute), 1)),
      ],
    );
  }

  Widget _tabButton(String label, int index) {
    final selected = _tabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _tabIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.buttonPrimary.withValues(alpha: 0.16) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.buttonPrimary.withValues(alpha: 0.5) : AppColors.border,
            width: 0.8,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.buttonPrimary : AppColors.textSecondary,
            fontSize: 13,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildDateTab({required Key key}) {
    final firstOfMonth = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    final daysInMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;
    final leadingBlanks = firstOfMonth.weekday - 1;

    final canGoPrev = DateTime(_visibleMonth.year, _visibleMonth.month - 1)
        .isAfter(DateTime(widget.firstDate.year, widget.firstDate.month - 1));
    final canGoNext = DateTime(_visibleMonth.year, _visibleMonth.month + 1)
        .isBefore(DateTime(widget.lastDate.year, widget.lastDate.month + 1));

    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _navArrow(Icons.chevron_left_rounded, canGoPrev ? () => _changeMonth(-1) : null),
            Expanded(
              child: Center(
                child: Text(
                  '${_months[_visibleMonth.month - 1]} ${_visibleMonth.year}',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            _navArrow(Icons.chevron_right_rounded, canGoNext ? () => _changeMonth(1) : null),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: _weekdayLabels
              .map((d) => Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: TextStyle(
                          color: AppColors.ash,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 6),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: leadingBlanks + daysInMonth,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            if (index < leadingBlanks) return const SizedBox.shrink();
            final day = index - leadingBlanks + 1;
            final date = DateTime(_visibleMonth.year, _visibleMonth.month, day);
            final enabled = _isDateEnabled(date);
            final isSelected = _isSameDay(date, _selectedDate);
            final isToday = _isSameDay(date, DateTime.now());

            return GestureDetector(
              onTap: enabled ? () => setState(() => _selectedDate = date) : null,
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.buttonPrimary : Colors.transparent,
                  shape: BoxShape.circle,
                  border: (!isSelected && isToday)
                      ? Border.all(color: AppColors.buttonPrimary.withValues(alpha: 0.5), width: 1)
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$day',
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.textOnButton
                        : (enabled ? AppColors.textPrimary : AppColors.textPrimary.withValues(alpha: 0.18)),
                    fontSize: 13.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _navArrow(IconData icon, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: onTap == null ? Colors.white24 : AppColors.textSecondary, size: 18),
      ),
    );
  }
// PART4

  Widget _buildTimeTab({required Key key}) {
    if (widget.use24Hour) {
      return Column(
        key: key,
        children: [
          SizedBox(
            height: 160,
            child: Row(
              children: [
                Expanded(
                  child: _WheelColumn(
                    itemCount: 24,
                    initialIndex: _hour24,
                    labelBuilder: (i) => i.toString().padLeft(2, '0'),
                    onChanged: (i) => setState(() => _hour24 = i),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    ':',
                    style: TextStyle(
                      color: AppColors.textPrimary.withValues(alpha: 0.4),
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  child: _WheelColumn(
                    itemCount: 60,
                    initialIndex: _minute,
                    labelBuilder: (i) => i.toString().padLeft(2, '0'),
                    onChanged: (i) => setState(() => _minute = i),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    final isPm = _hour24 >= 12;
    final hour12 = _hour24 % 12 == 0 ? 12 : _hour24 % 12;

    return Column(
      key: key,
      children: [
        SizedBox(
          height: 160,
          child: Row(
            children: [
              Expanded(
                child: _WheelColumn(
                  itemCount: 12,
                  initialIndex: hour12 - 1,
                  labelBuilder: (i) => (i + 1).toString().padLeft(2, '0'),
                  onChanged: (i) {
                    final newHour12 = i + 1;
                    setState(() {
                      _hour24 = isPm
                          ? (newHour12 == 12 ? 12 : newHour12 + 12)
                          : (newHour12 == 12 ? 0 : newHour12);
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  ':',
                  style: TextStyle(
                    color: AppColors.textPrimary.withValues(alpha: 0.4),
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(
                child: _WheelColumn(
                  itemCount: 60,
                  initialIndex: _minute,
                  labelBuilder: (i) => i.toString().padLeft(2, '0'),
                  onChanged: (i) => setState(() => _minute = i),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _WheelColumn(
                  itemCount: 2,
                  initialIndex: isPm ? 1 : 0,
                  labelBuilder: (i) => i == 0 ? 'AM' : 'PM',
                  onChanged: (i) {
                    setState(() {
                      final wasPm = _hour24 >= 12;
                      final nowPm = i == 1;
                      if (wasPm != nowPm) {
                        _hour24 = nowPm ? _hour24 + 12 : _hour24 - 12;
                        _hour24 = _hour24 % 24;
                      }
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRepeatSection() {
    final options = <PostRepeat>[PostRepeat.once, PostRepeat.weekdays, PostRepeat.daily];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kurudia',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        ...options.map((r) {
          final selected = _repeat == r;
          return GestureDetector(
            onTap: () => setState(() => _repeat = r),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: selected ? AppColors.buttonPrimary.withValues(alpha: 0.14) : AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected ? AppColors.buttonPrimary : AppColors.border,
                  width: 0.8,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.repeat_rounded,
                    size: 18,
                    color: selected
                        ? AppColors.buttonPrimary
                            : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.localizedLabel(AppLocalizations.of(context)),
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13.5,
                            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          r.localizedSubtitle(AppLocalizations.of(context)),
                          style: TextStyle(color: AppColors.ash, fontSize: 11.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildConfirmButton() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.buttonPrimary, width: 1),
        ),
        child: SizedBox(
          height: 52,
          child: Material(
            color: AppColors.buttonPrimary,
            borderRadius: BorderRadius.circular(30),
            child: InkWell(
              onTap: () => Navigator.pop(
                context,
                VeliePickerResult(dateTime: _combined, repeat: _repeat),
              ),
              borderRadius: BorderRadius.circular(30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_rounded, color: AppColors.textOnButton, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Sawasawa',
                    style: TextStyle(
                      color: AppColors.textOnButton,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Reusable scrolling wheel column for hour / minute / AMâ€“PM.
class _WheelColumn extends StatefulWidget {
  final int itemCount;
  final int initialIndex;
  final String Function(int) labelBuilder;
  final ValueChanged<int> onChanged;

  const _WheelColumn({
    required this.itemCount,
    required this.initialIndex,
    required this.labelBuilder,
    required this.onChanged,
  });

  @override
  State<_WheelColumn> createState() => _WheelColumnState();
}

class _WheelColumnState extends State<_WheelColumn> {
  late FixedExtentScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FixedExtentScrollController(initialItem: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: 40,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        ListWheelScrollView.useDelegate(
          controller: _controller,
          itemExtent: 40,
          perspective: 0.003,
          diameterRatio: 1.6,
          physics: const FixedExtentScrollPhysics(),
          onSelectedItemChanged: widget.onChanged,
          childDelegate: ListWheelChildBuilderDelegate(
            childCount: widget.itemCount,
            builder: (context, index) {
              return Center(
                child: Text(
                  widget.labelBuilder(index),
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}