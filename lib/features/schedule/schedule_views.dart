import 'dart:async';
import 'package:flutter/material.dart';

import '../../core/app_core.dart';

const _courseTileRadius = 11.0;

class SchedulePage extends StatelessWidget {
  const SchedulePage({
    super.key,
    required this.courses,
    required this.settings,
    required this.selectedWeekday,
    required this.onSelectedWeekdayChanged,
    required this.onImportTap,
    required this.onManualAddTap,
    required this.onDeleteCourse,
  });

  final List<CourseMeeting> courses;
  final AppSettings settings;
  final int selectedWeekday;
  final ValueChanged<int> onSelectedWeekdayChanged;
  final Future<void> Function() onImportTap;
  final Future<void> Function(ManualCourseDraft? draft) onManualAddTap;
  final Future<void> Function(CourseMeeting course) onDeleteCourse;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final currentWeek = semesterWeek(settings.termStartDate, now);
    final weekStart = settings.termStartDate.add(
      Duration(days: (currentWeek - 1) * 7),
    );
    final weekdays = settings.showWeekend
        ? [1, 2, 3, 4, 5, 6, 7]
        : [1, 2, 3, 4, 5];
    final currentDayCourses =
        courses
            .where(
              (course) =>
                  course.dayOfWeek == selectedWeekday &&
                  course.occursInWeek(currentWeek),
            )
            .toList()
          ..sort(CourseMeeting.sorter);
    final todayCount = currentDayCourses.length;
    final weekCount = courses
        .where((course) => course.occursInWeek(currentWeek))
        .length;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFD9EBFF),
                        Color(0xFFEAF5FF),
                        Color(0xFFFFF6D6),
                      ],
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1494A3B8),
                        blurRadius: 18,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.66),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Text(
                                '丫丫课程表',
                                style: TextStyle(
                                  color: Color(0xFF355070),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '第$currentWeek周',
                              style: const TextStyle(
                                color: Color(0xFF1E3A5F),
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '本学期开学：${formatMonthDay(settings.termStartDate)}',
                          style: const TextStyle(color: Color(0xFF5D6B82)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${formatMonthDay(weekStart)} - ${formatMonthDay(weekStart.add(const Duration(days: 6)))}',
                          style: const TextStyle(
                            color: Color(0xFF324968),
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _StatBadge(
                                label: '本周课程',
                                value: '$weekCount 节',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatBadge(
                                label: '当日安排',
                                value: '$todayCount 节',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: onImportTap,
                        icon: const Icon(Icons.cloud_sync_rounded),
                        label: const Text('一键导课'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => onManualAddTap(null),
                        icon: const Icon(Icons.edit_calendar_rounded),
                        label: const Text('手动添课'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '首页保留快捷导课。支持的客户端直接在应用内登录教务处并导入课程。',
                  style: TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: 92,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: weekdays.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final weekday = weekdays[index];
                      final date = weekStart.add(Duration(days: weekday - 1));
                      final selected = selectedWeekday == weekday;
                      final count = courses
                          .where(
                            (course) =>
                                course.dayOfWeek == weekday &&
                                course.occursInWeek(currentWeek),
                          )
                          .length;
                      return GestureDetector(
                        onTap: () => onSelectedWeekdayChanged(weekday),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          width: 76,
                          height: 76,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xFF4B84D4)
                                : const Color(0xFFFDFEFF),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: selected
                                  ? const Color(0xFF4B84D4)
                                  : const Color(0xFFDCE8F7),
                            ),
                            boxShadow: selected
                                ? const [
                                    BoxShadow(
                                      color: Color(0x224B84D4),
                                      blurRadius: 16,
                                      offset: Offset(0, 8),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                weekdayLabel(weekday).replaceAll('周', ''),
                                style: TextStyle(
                                  color: selected
                                      ? Colors.white
                                      : const Color(0xFF64748B),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                '${date.day}',
                                style: TextStyle(
                                  color: selected
                                      ? Colors.white
                                      : const Color(0xFF1E293B),
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                '$count 节',
                                style: TextStyle(
                                  color: selected
                                      ? Colors.white.withValues(alpha: 0.9)
                                      : const Color(0xFF94A3B8),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          sliver: currentDayCourses.isEmpty
              ? SliverToBoxAdapter(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${weekdayLabel(selectedWeekday)}没有安排',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '可以试试一键导课，或者手动把临时课程、补课和实验安排加进来。',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: const [
                              _TagPill(text: '支持四川大学一键导课'),
                              _TagPill(text: '支持手动添课'),
                              _TagPill(text: '自动按周次显示'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    if (index.isOdd) return const SizedBox(height: 12);
                    final course = currentDayCourses[index ~/ 2];
                    return CourseCard(
                      course: course,
                      settings: settings,
                      onDelete: () => onDeleteCourse(course),
                    );
                  }, childCount: currentDayCourses.length * 2 - 1),
                ),
        ),
      ],
    );
  }
}

class WeekSchedulePage extends StatefulWidget {
  const WeekSchedulePage({
    super.key,
    required this.courses,
    required this.settings,
    required this.onImportTap,
    required this.onManualAddTap,
    required this.onDeleteCourse,
  });

  final List<CourseMeeting> courses;
  final AppSettings settings;
  final Future<void> Function() onImportTap;
  final Future<void> Function(ManualCourseDraft? draft) onManualAddTap;
  final Future<void> Function(CourseMeeting course) onDeleteCourse;

  @override
  State<WeekSchedulePage> createState() => _WeekSchedulePageState();
}

class _WeekSchedulePageState extends State<WeekSchedulePage> {
  static const _pressDelay = Duration(milliseconds: 240);
  static const _pressMoveSlop = 8.0;

  _GridSelection? _dragSelection;
  _WeekGridLayout? _layout;
  Timer? _pressTimer;
  int? _activePointer;
  Offset? _pressOrigin;
  Offset? _pendingPosition;
  bool _selectionStarted = false;
  int? _displayedWeek;
  PageController? _weekPageController;

  @override
  void dispose() {
    _pressTimer?.cancel();
    _weekPageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final currentWeek = semesterWeek(widget.settings.termStartDate, now);
    _displayedWeek ??= currentWeek;
    final displayedWeek = _displayedWeek!.clamp(1, 25);
    _weekPageController ??= PageController(initialPage: displayedWeek - 1);
    final weekdays = widget.settings.showWeekend
        ? [1, 2, 3, 4, 5, 6, 7]
        : [1, 2, 3, 4, 5];

    return Stack(
      children: [
        PageView.builder(
          controller: _weekPageController,
          physics: _selectionStarted
              ? const NeverScrollableScrollPhysics()
              : const _TightPageScrollPhysics(),
          itemCount: 25,
          onPageChanged: (index) {
            final nextWeek = index + 1;
            if (nextWeek == _displayedWeek) return;
            setState(() {
              _displayedWeek = nextWeek;
            });
          },
          itemBuilder: (context, index) {
            final pageWeek = index + 1;
            final pageWeekStart = widget.settings.termStartDate.add(
              Duration(days: (pageWeek - 1) * 7),
            );
            final pageActiveCourses =
                widget.courses
                    .where((course) => course.occursInWeek(pageWeek))
                    .toList()
                  ..sort(CourseMeeting.sorter);
            final courseStyles = _buildCourseStyleMap(pageActiveCourses);
            final pageOccupiedCells = <String>{};
            for (final course in pageActiveCourses) {
              for (
                var section = course.startSection;
                section <= course.endSection;
                section++
              ) {
                pageOccupiedCells.add('${course.dayOfWeek}-$section');
              }
            }
            return _buildWeekContent(
              now: now,
              displayedWeek: pageWeek,
              weekStart: pageWeekStart,
              currentWeek: currentWeek,
              weekdays: weekdays,
              activeCourses: pageActiveCourses,
              courseStyles: courseStyles,
              occupiedCells: pageOccupiedCells,
            );
          },
        ),
        if (displayedWeek != currentWeek)
          Positioned(
            right: 16,
            bottom: 16,
            child: SafeArea(
              child: FloatingActionButton.extended(
                heroTag: 'back_to_current_week',
                backgroundColor: const Color(0xFF4B84D4),
                foregroundColor: Colors.white,
                onPressed: () {
                  _weekPageController?.animateToPage(
                    currentWeek - 1,
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutCubic,
                  );
                },
                icon: const Icon(Icons.my_location_rounded),
                label: const Text('返回本周'),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _showAddActions() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.cloud_sync_rounded),
                title: const Text('自动导课'),
                subtitle: const Text('登录教务处后自动导入课程'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await widget.onImportTap();
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit_calendar_rounded),
                title: const Text('手动添课'),
                subtitle: const Text('自己填写课程名称、地点和节次'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await widget.onManualAddTap(null);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showCourseDetails(CourseMeeting course) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => CourseDetailSheet(
        course: course,
        settings: widget.settings,
        onDeleteCourse: () async {
          Navigator.of(context).pop();
          await widget.onDeleteCourse(course);
        },
      ),
    );
  }

  Future<void> _showSemesterOverview(int displayedWeek) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SemesterOverviewSheet(
        courses: widget.courses,
        settings: widget.settings,
        displayedWeek: displayedWeek,
        onCourseTap: _showCourseDetails,
      ),
    );
  }

  Widget _buildWeekContent({
    required DateTime now,
    required int displayedWeek,
    required DateTime weekStart,
    required int currentWeek,
    required List<int> weekdays,
    required List<CourseMeeting> activeCourses,
    required Map<String, CourseVisualStyle> courseStyles,
    required Set<String> occupiedCells,
  }) {
    return ListView(
      physics: _selectionStarted ? const NeverScrollableScrollPhysics() : null,
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE4EEF9)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x120F172A),
                blurRadius: 18,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '第$displayedWeek周',
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${weekStart.month}月 ${weekStart.day}日开始  第1学期',
                      style: const TextStyle(
                        color: Color(0xFF71819A),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFDCEBFF),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: IconButton(
                  onPressed: () => _showSemesterOverview(displayedWeek),
                  icon: const Icon(Icons.grid_view_rounded),
                  color: const Color(0xFF4B84D4),
                  iconSize: 22,
                  splashRadius: 20,
                  tooltip: '全览',
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF4B84D4),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: IconButton(
                  onPressed: _showAddActions,
                  icon: const Icon(Icons.add_rounded),
                  color: Colors.white,
                  iconSize: 22,
                  splashRadius: 20,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.fromLTRB(3, 8, 3, 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFE7EEF9)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x100F172A),
                blurRadius: 18,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final phoneWidth = MediaQuery.sizeOf(context).width;
              final compact = phoneWidth < 390;
              final horizontalInset = compact ? 2.0 : 3.0;
              final timeColumnWidth = compact ? 29.0 : 32.0;
              final dayGap = compact ? 0.5 : 1.5;
              final usableWidth = constraints.maxWidth - horizontalInset * 2;
              final dayColumnWidth =
                  (usableWidth -
                      timeColumnWidth -
                      dayGap * (weekdays.length - 1)) /
                  weekdays.length;
              final rowHeight = compact ? 54.0 : 58.0;
              final blockHorizontalInset = compact ? 0.5 : 1.2;
              final blockVerticalInset = compact ? 0.6 : 1.0;
              _layout = _WeekGridLayout(
                weekdays: weekdays,
                horizontalInset: horizontalInset,
                timeColumnWidth: timeColumnWidth,
                dayGap: dayGap,
                dayColumnWidth: dayColumnWidth,
                rowHeight: rowHeight,
              );

              return Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: horizontalInset),
                    child: Row(
                      children: [
                        SizedBox(width: timeColumnWidth),
                        for (
                          var index = 0;
                          index < weekdays.length;
                          index++
                        ) ...[
                          if (index > 0) SizedBox(width: dayGap),
                          SizedBox(
                            width: dayColumnWidth,
                            child: Column(
                              children: [
                                Text(
                                  weekHeaderLabel(weekdays[index]),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: compact ? 13 : 14.5,
                                    color: const Color(0xFF1F2B3D),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Container(
                                  width: compact ? 31 : 35,
                                  height: compact ? 31 : 35,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color:
                                        displayedWeek == currentWeek &&
                                            weekdays[index] == now.weekday
                                        ? const Color(0xFF4B84D4)
                                        : const Color(0xFFF6F9FE),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${weekStart.add(Duration(days: weekdays[index] - 1)).day}',
                                    style: TextStyle(
                                      color:
                                          displayedWeek == currentWeek &&
                                              weekdays[index] == now.weekday
                                          ? Colors.white
                                          : const Color(0xFF687A96),
                                      fontWeight: FontWeight.w800,
                                      fontSize: compact ? 13 : 14.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 3),
                  SizedBox(
                    height: rowHeight * 12,
                    child: Listener(
                      behavior: HitTestBehavior.translucent,
                      onPointerDown: (event) => _handlePointerDown(
                        event.pointer,
                        event.localPosition,
                        occupiedCells,
                      ),
                      onPointerMove: (event) => _handlePointerMove(
                        event.pointer,
                        event.localPosition,
                        occupiedCells,
                      ),
                      onPointerUp: (event) => _handlePointerUp(displayedWeek),
                      onPointerCancel: (_) => _resetPressState(),
                      child: Stack(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: horizontalInset,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: timeColumnWidth,
                                  child: Column(
                                    children: [
                                      for (final section in sectionNumbers)
                                        SizedBox(
                                          height: rowHeight,
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                              right: compact ? 1.5 : 2.5,
                                              top: 1,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  '$section',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: compact
                                                        ? 11
                                                        : 12.5,
                                                    color: const Color(
                                                      0xFF233247,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 1),
                                                Text(
                                                  sectionTimeLabel(
                                                    widget.settings,
                                                    widget
                                                        .settings
                                                        .defaultCampus,
                                                    section,
                                                  ),
                                                  textAlign: TextAlign.right,
                                                  style: TextStyle(
                                                    color: const Color(
                                                      0xFFABB8CC,
                                                    ),
                                                    fontSize: compact
                                                        ? 6.9
                                                        : 7.5,
                                                    height: 1.05,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                for (
                                  var dayIndex = 0;
                                  dayIndex < weekdays.length;
                                  dayIndex++
                                ) ...[
                                  if (dayIndex > 0) SizedBox(width: dayGap),
                                  SizedBox(
                                    width: dayColumnWidth,
                                    child: Column(
                                      children: List.generate(12, (index) {
                                        final occupied = occupiedCells.contains(
                                          '${weekdays[dayIndex]}-${index + 1}',
                                        );
                                        return Container(
                                          height: rowHeight - 1,
                                          margin: const EdgeInsets.symmetric(
                                            vertical: 0.5,
                                          ),
                                          child: occupied
                                              ? null
                                              : const _DashedCell(),
                                        );
                                      }),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (_dragSelection != null)
                            Positioned(
                              left:
                                  horizontalInset +
                                  timeColumnWidth +
                                  _dragSelection!.dayIndex *
                                      (dayColumnWidth + dayGap) +
                                  blockHorizontalInset,
                              top:
                                  (_dragSelection!.startSection - 1) *
                                      rowHeight +
                                  blockVerticalInset,
                              width: dayColumnWidth - blockHorizontalInset * 2,
                              height:
                                  (_dragSelection!.endSection -
                                          _dragSelection!.startSection +
                                          1) *
                                      rowHeight -
                                  blockVerticalInset * 2,
                              child: IgnorePointer(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0x334B84D4),
                                    borderRadius: BorderRadius.circular(
                                      _courseTileRadius,
                                    ),
                                    border: Border.all(
                                      color: const Color(0xFF4B84D4),
                                      width: 1.2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ...activeCourses
                              .where(
                                (course) => weekdays.contains(course.dayOfWeek),
                              )
                              .map((course) {
                                final dayIndex = weekdays.indexOf(
                                  course.dayOfWeek,
                                );
                                final left =
                                    horizontalInset +
                                    timeColumnWidth +
                                    dayIndex * (dayColumnWidth + dayGap) +
                                    blockHorizontalInset;
                                final top =
                                    (course.startSection - 1) * rowHeight +
                                    blockVerticalInset;
                                final height =
                                    (course.endSection -
                                            course.startSection +
                                            1) *
                                        rowHeight -
                                    blockVerticalInset * 2;
                                final style =
                                    courseStyles[course.id] ??
                                    courseStyle(course);
                                return Positioned(
                                  left: left,
                                  top: top,
                                  width:
                                      dayColumnWidth - blockHorizontalInset * 2,
                                  height: height,
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(
                                        _courseTileRadius,
                                      ),
                                      onTap: () => _showCourseDetails(course),
                                      child: Container(
                                        padding: EdgeInsets.fromLTRB(
                                          compact ? 2.5 : 3.5,
                                          compact ? 2.5 : 3.5,
                                          compact ? 2.5 : 3.5,
                                          compact ? 2.5 : 3.5,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              style.background,
                                              style.background.withValues(
                                                alpha: 0.92,
                                              ),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            _courseTileRadius,
                                          ),
                                          border: Border.all(
                                            color: style.border,
                                            width: 1.2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: style.border.withValues(
                                                alpha: 0.06,
                                              ),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: _CourseGridBlock(
                                          course: course,
                                          settings: widget.settings,
                                          style: style,
                                          compact: compact,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  void _handlePointerDown(
    int pointer,
    Offset localPosition,
    Set<String> occupiedCells,
  ) {
    _pressTimer?.cancel();
    _activePointer = pointer;
    _pressOrigin = localPosition;
    _pendingPosition = localPosition;
    _selectionStarted = false;
    _pressTimer = Timer(_pressDelay, () {
      final pending = _pendingPosition;
      if (pending == null || !mounted) return;
      final hit = _resolveHit(pending, occupiedCells);
      if (hit == null) return;
      setState(() {
        _selectionStarted = true;
        _dragSelection = _GridSelection(
          dayOfWeek: hit.dayOfWeek,
          dayIndex: hit.dayIndex,
          startSection: hit.section,
          endSection: hit.section,
        );
      });
    });
  }

  void _handlePointerMove(
    int pointer,
    Offset localPosition,
    Set<String> occupiedCells,
  ) {
    if (_activePointer != pointer) return;
    final origin = _pressOrigin;
    if (!_selectionStarted && origin != null) {
      final movedTooFar = (localPosition - origin).distance > _pressMoveSlop;
      if (movedTooFar) {
        _pressTimer?.cancel();
        _pressTimer = null;
        _activePointer = null;
        _pressOrigin = null;
        _pendingPosition = null;
        return;
      }
    }
    _pendingPosition = localPosition;
    final selection = _dragSelection;
    if (!_selectionStarted || selection == null) return;
    final hit = _resolveHit(localPosition, occupiedCells, selection.dayOfWeek);
    if (hit == null) return;
    final nextStart = selection.startSection < hit.section
        ? selection.startSection
        : hit.section;
    final nextEnd = selection.startSection > hit.section
        ? selection.startSection
        : hit.section;
    for (var section = nextStart; section <= nextEnd; section++) {
      if (occupiedCells.contains('${selection.dayOfWeek}-$section')) {
        return;
      }
    }
    setState(() {
      _dragSelection = _GridSelection(
        dayOfWeek: selection.dayOfWeek,
        dayIndex: selection.dayIndex,
        startSection: nextStart,
        endSection: nextEnd,
      );
    });
  }

  Future<void> _handlePointerUp(int currentWeek) async {
    _pressTimer?.cancel();
    _pressTimer = null;
    _activePointer = null;
    _pressOrigin = null;
    _pendingPosition = null;
    final selection = _dragSelection;
    final selectionStarted = _selectionStarted;
    setState(() {
      _selectionStarted = false;
      _dragSelection = null;
    });
    if (!selectionStarted || selection == null) return;
    await widget.onManualAddTap(
      ManualCourseDraft(
        dayOfWeek: selection.dayOfWeek,
        startSection: selection.startSection,
        endSection: selection.endSection,
        startWeek: currentWeek,
        endWeek: currentWeek,
      ),
    );
  }

  void _resetPressState() {
    _pressTimer?.cancel();
    _pressTimer = null;
    _activePointer = null;
    _pressOrigin = null;
    _pendingPosition = null;
    if (_selectionStarted || _dragSelection != null) {
      setState(() {
        _selectionStarted = false;
        _dragSelection = null;
      });
    }
  }

  _GridHit? _resolveHit(
    Offset localPosition,
    Set<String> occupiedCells, [
    int? requiredDayOfWeek,
  ]) {
    final layout = _layout;
    if (layout == null) return null;
    final x = localPosition.dx - layout.horizontalInset;
    final y = localPosition.dy;
    if (x < layout.timeColumnWidth || y < 0) return null;
    final gridX = x - layout.timeColumnWidth;
    final stride = layout.dayColumnWidth + layout.dayGap;
    final dayIndex = (gridX / stride).floor();
    if (dayIndex < 0 || dayIndex >= layout.weekdays.length) return null;
    final withinDayX = gridX - dayIndex * stride;
    if (withinDayX > layout.dayColumnWidth) return null;
    final section = (y / layout.rowHeight).floor() + 1;
    if (section < 1 || section > 12) return null;
    final dayOfWeek = layout.weekdays[dayIndex];
    if (requiredDayOfWeek != null && requiredDayOfWeek != dayOfWeek) {
      return null;
    }
    if (occupiedCells.contains('$dayOfWeek-$section')) return null;
    return _GridHit(dayOfWeek: dayOfWeek, dayIndex: dayIndex, section: section);
  }
}

class CourseCard extends StatelessWidget {
  const CourseCard({
    super.key,
    required this.course,
    required this.settings,
    required this.onDelete,
  });

  final CourseMeeting course;
  final AppSettings settings;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final timeRange = formatCourseTime(
      settings,
      course.campus,
      course.startSection,
      course.endSection,
    );
    final accent = course.source == CourseSource.scu
        ? const Color(0xFF0F766E)
        : const Color(0xFFEA580C);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 10,
              height: 96,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          course.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'delete') {
                            onDelete();
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem<String>(
                            value: 'delete',
                            child: Text('删除课程'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _TagPill(text: course.campus),
                      _TagPill(text: course.weekDescription),
                      _TagPill(text: course.source),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _DetailLine(
                    icon: Icons.schedule_rounded,
                    text:
                        '$timeRange · 第${course.startSection}-${course.endSection}节',
                  ),
                  _DetailLine(
                    icon: Icons.person_outline_rounded,
                    text: course.teacher.isEmpty ? '教师待补充' : course.teacher,
                  ),
                  _DetailLine(
                    icon: Icons.place_outlined,
                    text: course.location.isEmpty ? '地点待补充' : course.location,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CourseDetailSheet extends StatelessWidget {
  const CourseDetailSheet({
    super.key,
    required this.course,
    required this.settings,
    required this.onDeleteCourse,
  });

  final CourseMeeting course;
  final AppSettings settings;
  final Future<void> Function() onDeleteCourse;

  @override
  Widget build(BuildContext context) {
    final timeRange = formatCourseTime(
      settings,
      course.campus,
      course.startSection,
      course.endSection,
    );
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                course.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _TagPill(text: weekdayLabel(course.dayOfWeek)),
                  _TagPill(text: course.weekDescription),
                  _TagPill(text: course.campus),
                  _TagPill(text: course.source),
                ],
              ),
              const SizedBox(height: 14),
              _DetailLine(
                icon: Icons.schedule_rounded,
                text:
                    '$timeRange · 第${course.startSection}-${course.endSection}节',
              ),
              _DetailLine(
                icon: Icons.person_outline_rounded,
                text: course.teacher.isEmpty ? '教师待补充' : course.teacher,
              ),
              _DetailLine(
                icon: Icons.place_outlined,
                text: course.location.isEmpty ? '地点待补充' : course.location,
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onDeleteCourse,
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: const Text('删除课程'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFDC2626),
                    side: const BorderSide(color: Color(0xFFF2B8B5)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SemesterOverviewSheet extends StatelessWidget {
  const SemesterOverviewSheet({
    super.key,
    required this.courses,
    required this.settings,
    required this.displayedWeek,
    required this.onCourseTap,
  });

  final List<CourseMeeting> courses;
  final AppSettings settings;
  final int displayedWeek;
  final Future<void> Function(CourseMeeting course) onCourseTap;

  @override
  Widget build(BuildContext context) {
    final weekdays = settings.showWeekend
        ? [1, 2, 3, 4, 5, 6, 7]
        : [1, 2, 3, 4, 5];
    final semesterCourses =
        courses.where((course) => weekdays.contains(course.dayOfWeek)).toList()
          ..sort((a, b) {
            final aActive = a.occursInWeek(displayedWeek);
            final bActive = b.occursInWeek(displayedWeek);
            final activeCompare = (bActive ? 1 : 0) - (aActive ? 1 : 0);
            if (activeCompare != 0) return activeCompare;
            return CourseMeeting.sorter(a, b);
          });
    final courseStyles = _buildCourseStyleMap(semesterCourses);
    final occupiedCells = <String>{};
    for (final course in semesterCourses) {
      for (
        var section = course.startSection;
        section <= course.endSection;
        section++
      ) {
        occupiedCells.add('${course.dayOfWeek}-$section');
      }
    }

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF7FBFF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      color: const Color(0xFF24324A),
                      splashRadius: 20,
                    ),
                    const Expanded(
                      child: Text(
                        '学期全览',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF2FF),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '第$displayedWeek周',
                        style: const TextStyle(
                          color: Color(0xFF4B84D4),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Row(
                  children: [
                    _LegendDot(color: Color(0xFF4B84D4), label: '本周课程'),
                    SizedBox(width: 12),
                    _LegendDot(color: Color(0xFF94A3B8), label: '非本周课程'),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(3, 8, 3, 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: const Color(0xFFE7EEF9)),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final phoneWidth = MediaQuery.sizeOf(context).width;
                      final compact = phoneWidth < 390;
                      final horizontalInset = compact ? 2.0 : 3.0;
                      final timeColumnWidth = compact ? 29.0 : 32.0;
                      final dayGap = compact ? 0.5 : 1.5;
                      final usableWidth =
                          constraints.maxWidth - horizontalInset * 2;
                      final dayColumnWidth =
                          (usableWidth -
                              timeColumnWidth -
                              dayGap * (weekdays.length - 1)) /
                          weekdays.length;
                      final rowHeight = compact ? 54.0 : 58.0;
                      final blockHorizontalInset = compact ? 0.5 : 1.2;
                      final blockVerticalInset = compact ? 0.6 : 1.0;

                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: horizontalInset,
                              ),
                              child: Row(
                                children: [
                                  SizedBox(width: timeColumnWidth),
                                  for (
                                    var index = 0;
                                    index < weekdays.length;
                                    index++
                                  ) ...[
                                    if (index > 0) SizedBox(width: dayGap),
                                    SizedBox(
                                      width: dayColumnWidth,
                                      child: Column(
                                        children: [
                                          Text(
                                            weekHeaderLabel(weekdays[index]),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: compact ? 13 : 14.5,
                                              color: const Color(0xFF1F2B3D),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Container(
                                            width: compact ? 31 : 35,
                                            height: compact ? 31 : 35,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF6F9FE),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              weekHeaderLabel(
                                                weekdays[index],
                                              ).replaceAll('周', ''),
                                              style: TextStyle(
                                                color: const Color(0xFF687A96),
                                                fontWeight: FontWeight.w800,
                                                fontSize: compact ? 12.5 : 14,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 3),
                            SizedBox(
                              height: rowHeight * 12,
                              child: Stack(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: horizontalInset,
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: timeColumnWidth,
                                          child: Column(
                                            children: [
                                              for (final section
                                                  in sectionNumbers)
                                                SizedBox(
                                                  height: rowHeight,
                                                  child: Padding(
                                                    padding: EdgeInsets.only(
                                                      right: compact
                                                          ? 1.5
                                                          : 2.5,
                                                      top: 1,
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: [
                                                        Text(
                                                          '$section',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w800,
                                                            fontSize: compact
                                                                ? 11
                                                                : 12.5,
                                                            color: const Color(
                                                              0xFF233247,
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 1,
                                                        ),
                                                        Text(
                                                          sectionTimeLabel(
                                                            settings,
                                                            settings
                                                                .defaultCampus,
                                                            section,
                                                          ),
                                                          textAlign:
                                                              TextAlign.right,
                                                          style: TextStyle(
                                                            color: const Color(
                                                              0xFFABB8CC,
                                                            ),
                                                            fontSize: compact
                                                                ? 6.9
                                                                : 7.5,
                                                            height: 1.05,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        for (
                                          var dayIndex = 0;
                                          dayIndex < weekdays.length;
                                          dayIndex++
                                        ) ...[
                                          if (dayIndex > 0)
                                            SizedBox(width: dayGap),
                                          SizedBox(
                                            width: dayColumnWidth,
                                            child: Column(
                                              children: List.generate(12, (
                                                index,
                                              ) {
                                                final occupied = occupiedCells
                                                    .contains(
                                                      '${weekdays[dayIndex]}-${index + 1}',
                                                    );
                                                return Container(
                                                  height: rowHeight - 1,
                                                  margin:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 0.5,
                                                      ),
                                                  child: occupied
                                                      ? null
                                                      : const _DashedCell(),
                                                );
                                              }),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  ...semesterCourses.map((course) {
                                    final dayIndex = weekdays.indexOf(
                                      course.dayOfWeek,
                                    );
                                    final left =
                                        horizontalInset +
                                        timeColumnWidth +
                                        dayIndex * (dayColumnWidth + dayGap) +
                                        blockHorizontalInset;
                                    final top =
                                        (course.startSection - 1) * rowHeight +
                                        blockVerticalInset;
                                    final height =
                                        (course.endSection -
                                                course.startSection +
                                                1) *
                                            rowHeight -
                                        blockVerticalInset * 2;
                                    final isCurrentWeek = course.occursInWeek(
                                      displayedWeek,
                                    );
                                    final style = isCurrentWeek
                                        ? (courseStyles[course.id] ??
                                              courseStyle(course))
                                        : const CourseVisualStyle(
                                            background: Color(0xFFF2F5F8),
                                            border: Color(0xFFD4DCE6),
                                            text: Color(0xFF7B8794),
                                          );
                                    final backgroundColor = isCurrentWeek
                                        ? style.background
                                        : style.background.withValues(
                                            alpha: 0.68,
                                          );
                                    final borderColor = isCurrentWeek
                                        ? style.border
                                        : style.border.withValues(alpha: 0.8);
                                    final textColor = isCurrentWeek
                                        ? style.text
                                        : style.text.withValues(alpha: 0.82);
                                    return Positioned(
                                      left: left,
                                      top: top,
                                      width:
                                          dayColumnWidth -
                                          blockHorizontalInset * 2,
                                      height: height,
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(
                                            _courseTileRadius,
                                          ),
                                          onTap: () => onCourseTap(course),
                                          child: Container(
                                            padding: EdgeInsets.fromLTRB(
                                              compact ? 2.5 : 3.5,
                                              compact ? 2.5 : 3.5,
                                              compact ? 2.5 : 3.5,
                                              compact ? 2.5 : 3.5,
                                            ),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  backgroundColor,
                                                  backgroundColor.withValues(
                                                    alpha: 0.92,
                                                  ),
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    _courseTileRadius,
                                                  ),
                                              border: Border.all(
                                                color: borderColor,
                                                width: 1.2,
                                              ),
                                            ),
                                            child: _CourseGridBlock(
                                              course: course,
                                              settings: settings,
                                              style: CourseVisualStyle(
                                                background: backgroundColor,
                                                border: borderColor,
                                                text: textColor,
                                              ),
                                              compact: compact,
                                              badgeLabel: isCurrentWeek
                                                  ? null
                                                  : '非本周',
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CourseGridBlock extends StatelessWidget {
  const _CourseGridBlock({
    required this.course,
    required this.settings,
    required this.style,
    required this.compact,
    this.badgeLabel,
  });

  final CourseMeeting course;
  final AppSettings settings;
  final CourseVisualStyle style;
  final bool compact;
  final String? badgeLabel;

  @override
  Widget build(BuildContext context) {
    final sectionLabel = course.startSection == course.endSection
        ? '${course.startSection}节'
        : '${course.startSection}-${course.endSection}节';
    final timeLabel = formatCourseTime(
      settings,
      course.campus,
      course.startSection,
      course.endSection,
    );
    final teacher = course.teacher.trim();
    final location = course.location.trim().isEmpty ? '地点待补充' : course.location;

    return LayoutBuilder(
      builder: (context, constraints) {
        final showHeader =
            constraints.maxHeight >= 54 && constraints.maxWidth >= 28;
        final showHeaderAccent = constraints.maxWidth >= 52;
        final showTime = constraints.maxHeight >= 70;
        final showTeacher =
            constraints.maxHeight >= 92 &&
            teacher.isNotEmpty &&
            constraints.maxWidth >= 44;
        final titleLines = showTeacher
            ? (compact ? 3 : 4)
            : (showTime ? (compact ? 4 : 5) : (compact ? 5 : 6));
        final titleFontSize =
            constraints.maxHeight >= 120 && constraints.maxWidth >= 62
            ? (compact ? 10.2 : 11.4)
            : constraints.maxHeight >= 88 && constraints.maxWidth >= 50
            ? (compact ? 9.7 : 10.6)
            : (compact ? 9.0 : 9.8);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showHeader)
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Flexible(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: showHeaderAccent ? 4.5 : 3.0,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: style.border.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        badgeLabel ?? sectionLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: style.text.withValues(alpha: 0.9),
                          fontSize: compact ? 6.7 : 7.1,
                          height: 1,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  if (showHeaderAccent) ...[
                    const SizedBox(width: 4),
                    Container(
                      width: compact ? 10 : 12,
                      height: 3,
                      decoration: BoxDecoration(
                        color: style.border,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ],
                ],
              ),
            if (showHeader) const SizedBox(height: 3),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    course.title,
                    maxLines: titleLines,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: style.text,
                      fontWeight: FontWeight.w900,
                      height: 1.08,
                      fontSize: titleFontSize,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    location,
                    maxLines: showTime ? 2 : 3,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: style.text.withValues(alpha: 0.72),
                      fontSize: compact ? 7.0 : 7.6,
                      height: 1.08,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (showTime) ...[
                    const SizedBox(height: 2),
                    Text(
                      timeLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: style.text.withValues(alpha: 0.66),
                        fontSize: compact ? 6.6 : 7.1,
                        height: 1.05,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  if (showTeacher) ...[
                    const SizedBox(height: 1),
                    Text(
                      teacher,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: style.text.withValues(alpha: 0.62),
                        fontSize: compact ? 6.4 : 6.8,
                        height: 1.05,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _WeekGridLayout {
  const _WeekGridLayout({
    required this.weekdays,
    required this.horizontalInset,
    required this.timeColumnWidth,
    required this.dayGap,
    required this.dayColumnWidth,
    required this.rowHeight,
  });

  final List<int> weekdays;
  final double horizontalInset;
  final double timeColumnWidth;
  final double dayGap;
  final double dayColumnWidth;
  final double rowHeight;
}

class _GridSelection {
  const _GridSelection({
    required this.dayOfWeek,
    required this.dayIndex,
    required this.startSection,
    required this.endSection,
  });

  final int dayOfWeek;
  final int dayIndex;
  final int startSection;
  final int endSection;
}

class _GridHit {
  const _GridHit({
    required this.dayOfWeek,
    required this.dayIndex,
    required this.section,
  });

  final int dayOfWeek;
  final int dayIndex;
  final int section;
}

class _TightPageScrollPhysics extends PageScrollPhysics {
  const _TightPageScrollPhysics({super.parent});

  @override
  _TightPageScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return _TightPageScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double? get dragStartDistanceMotionThreshold => 18;

  @override
  double get minFlingDistance => 32;

  @override
  double get minFlingVelocity => 520;
}

Map<String, CourseVisualStyle> _buildCourseStyleMap(
  List<CourseMeeting> courses,
) {
  final sorted = [...courses]
    ..sort((a, b) {
      final dayCompare = a.dayOfWeek.compareTo(b.dayOfWeek);
      if (dayCompare != 0) return dayCompare;
      final sectionCompare = a.startSection.compareTo(b.startSection);
      if (sectionCompare != 0) return sectionCompare;
      final spanCompare = (b.endSection - b.startSection).compareTo(
        a.endSection - a.startSection,
      );
      if (spanCompare != 0) return spanCompare;
      return a.title.compareTo(b.title);
    });

  final assigned = <String, int>{};
  for (final course in sorted) {
    final blocked = <int>{};
    for (final other in sorted) {
      if (other.id == course.id) continue;
      final index = assigned[other.id];
      if (index == null) continue;
      if (_coursesTouch(course, other)) {
        blocked.add(index);
      }
    }
    final preferred = _preferredCourseColorIndex(course);
    var selected = preferred;
    for (var offset = 0; offset < courseVisualPalette.length; offset++) {
      final candidate = (preferred + offset) % courseVisualPalette.length;
      if (!blocked.contains(candidate)) {
        selected = candidate;
        break;
      }
    }
    assigned[course.id] = selected;
  }

  return {
    for (final entry in assigned.entries)
      entry.key: courseStyleByIndex(entry.value),
  };
}

int _preferredCourseColorIndex(CourseMeeting course) {
  final titleSeed = course.title.runes.fold<int>(0, (sum, rune) => sum + rune);
  final slotSeed =
      (course.dayOfWeek * 7) + (course.startSection * 5) + course.endSection;
  return (titleSeed + slotSeed) % courseVisualPalette.length;
}

bool _coursesTouch(CourseMeeting a, CourseMeeting b) {
  if (a.dayOfWeek == b.dayOfWeek) {
    return a.startSection <= b.endSection + 1 &&
        b.startSection <= a.endSection + 1;
  }
  if ((a.dayOfWeek - b.dayOfWeek).abs() != 1) {
    return false;
  }
  return a.startSection <= b.endSection && b.startSection <= a.endSection;
}

class _StatBadge extends StatelessWidget {
  const _StatBadge({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFEFF),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFD9E7FA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF64748B))),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF1E3A5F),
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  const _TagPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF334155),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF64748B)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Color(0xFF475569), height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedCell extends StatelessWidget {
  const _DashedCell();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: const _DashedCellPainter(),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFCFEFF),
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}

class _DashedCellPainter extends CustomPainter {
  const _DashedCellPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const radius = Radius.circular(14);
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect.deflate(0.6), radius);

    final fillPaint = Paint()..color = const Color(0xFFFCFEFF);
    canvas.drawRRect(rrect, fillPaint);

    final borderPaint = Paint()
      ..color = const Color(0xFFD8E4F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        const dash = 5.0;
        const gap = 3.0;
        final next = distance + dash;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          borderPaint,
        );
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
