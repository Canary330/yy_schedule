import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSnapshot {
  const AppSnapshot({
    required this.courses,
    required this.todos,
    required this.settings,
  });

  final List<CourseMeeting> courses;
  final List<TodoItem> todos;
  final AppSettings settings;
}

class LocalStore {
  static const _coursesKey = 'courses';
  static const _todosKey = 'todos';
  static const _settingsKey = 'settings';

  static Future<AppSnapshot> load() async {
    final prefs = await SharedPreferences.getInstance();
    final coursesJson = prefs.getString(_coursesKey);
    final todosJson = prefs.getString(_todosKey);
    final settingsJson = prefs.getString(_settingsKey);
    final courses = coursesJson == null
        ? <CourseMeeting>[]
        : (jsonDecode(coursesJson) as List<dynamic>)
              .map(
                (item) => CourseMeeting.fromMap(item as Map<String, dynamic>),
              )
              .toList();
    final todos = todosJson == null
        ? <TodoItem>[]
        : (jsonDecode(todosJson) as List<dynamic>)
              .map((item) => TodoItem.fromMap(item as Map<String, dynamic>))
              .toList();
    final settings = settingsJson == null
        ? AppSettings.initial()
        : AppSettings.fromMap(jsonDecode(settingsJson) as Map<String, dynamic>);
    return AppSnapshot(courses: courses, todos: todos, settings: settings);
  }

  static Future<void> save(AppSnapshot snapshot) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _coursesKey,
      jsonEncode(snapshot.courses.map((item) => item.toMap()).toList()),
    );
    await prefs.setString(
      _todosKey,
      jsonEncode(snapshot.todos.map((item) => item.toMap()).toList()),
    );
    await prefs.setString(_settingsKey, jsonEncode(snapshot.settings.toMap()));
  }
}

class AppSettings {
  const AppSettings({
    required this.termStartDate,
    required this.defaultCampus,
    required this.showWeekend,
    required this.classRemindersEnabled,
    required this.lastTabIndex,
    required this.activeSemesterId,
    required this.semesters,
    required this.campusSchedules,
    required this.privacyPolicyAccepted,
  });

  final DateTime termStartDate;
  final String defaultCampus;
  final bool showWeekend;
  final bool classRemindersEnabled;
  final int lastTabIndex;
  final String activeSemesterId;
  final List<SemesterConfig> semesters;
  final Map<String, CampusSchedule> campusSchedules;
  final bool privacyPolicyAccepted;

  SemesterConfig get activeSemester => semesters.firstWhere(
    (item) => item.id == activeSemesterId,
    orElse: () => semesters.first,
  );

  CampusSchedule scheduleForCampus(String campus) =>
      campusSchedules[campus] ?? CampusSchedule.defaultFor(campus);

  factory AppSettings.initial() {
    final semesters = [
      SemesterConfig(
        id: 'semester_2026_spring',
        name: '2025-2026 第2学期',
        startDate: DateTime(2026, 3, 9),
      ),
    ];
    return AppSettings(
      termStartDate: semesters.first.startDate,
      defaultCampus: campusJiangAn,
      showWeekend: true,
      classRemindersEnabled: false,
      lastTabIndex: 0,
      activeSemesterId: semesters.first.id,
      semesters: semesters,
      campusSchedules: {
        campusJiangAn: CampusSchedule.defaultFor(campusJiangAn),
        campusWangJiangHuaXi: CampusSchedule.defaultFor(campusWangJiangHuaXi),
      },
      privacyPolicyAccepted: false,
    );
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    final semesters =
        (map['semesters'] as List<dynamic>?)
            ?.map(
              (item) => SemesterConfig.fromMap(item as Map<String, dynamic>),
            )
            .toList() ??
        [
          SemesterConfig(
            id: 'semester_legacy',
            name: '当前学期',
            startDate:
                DateTime.tryParse(map['termStartDate'] as String? ?? '') ??
                DateTime(2026, 3, 9),
          ),
        ];
    final activeSemesterId =
        map['activeSemesterId'] as String? ?? semesters.first.id;
    final activeSemester = semesters.firstWhere(
      (item) => item.id == activeSemesterId,
      orElse: () => semesters.first,
    );
    final storedCampusSchedules =
        (map['campusSchedules'] as Map<String, dynamic>?)?.map(
          (key, value) => MapEntry(
            key,
            CampusSchedule.fromMap(key, value as Map<String, dynamic>),
          ),
        ) ??
        <String, CampusSchedule>{};
    return AppSettings(
      termStartDate: activeSemester.startDate,
      defaultCampus: map['defaultCampus'] as String? ?? campusJiangAn,
      showWeekend: map['showWeekend'] as bool? ?? true,
      classRemindersEnabled: map['classRemindersEnabled'] as bool? ?? false,
      lastTabIndex: map['lastTabIndex'] as int? ?? 0,
      activeSemesterId: activeSemester.id,
      semesters: semesters,
      campusSchedules: {
        campusJiangAn:
            storedCampusSchedules[campusJiangAn] ??
            CampusSchedule.defaultFor(campusJiangAn),
        campusWangJiangHuaXi:
            storedCampusSchedules[campusWangJiangHuaXi] ??
            CampusSchedule.defaultFor(campusWangJiangHuaXi),
      },
      privacyPolicyAccepted: map['privacyPolicyAccepted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'termStartDate': termStartDate.toIso8601String(),
      'defaultCampus': defaultCampus,
      'showWeekend': showWeekend,
      'classRemindersEnabled': classRemindersEnabled,
      'lastTabIndex': lastTabIndex,
      'activeSemesterId': activeSemesterId,
      'semesters': semesters.map((item) => item.toMap()).toList(),
      'campusSchedules': campusSchedules.map(
        (key, value) => MapEntry(key, value.toMap()),
      ),
      'privacyPolicyAccepted': privacyPolicyAccepted,
    };
  }

  AppSettings copyWith({
    DateTime? termStartDate,
    String? defaultCampus,
    bool? showWeekend,
    bool? classRemindersEnabled,
    int? lastTabIndex,
    String? activeSemesterId,
    List<SemesterConfig>? semesters,
    Map<String, CampusSchedule>? campusSchedules,
    bool? privacyPolicyAccepted,
  }) {
    final resolvedSemesters = semesters ?? this.semesters;
    final resolvedActiveId = activeSemesterId ?? this.activeSemesterId;
    final resolvedActiveSemester = resolvedSemesters.firstWhere(
      (item) => item.id == resolvedActiveId,
      orElse: () => resolvedSemesters.first,
    );
    return AppSettings(
      termStartDate: termStartDate ?? resolvedActiveSemester.startDate,
      defaultCampus: defaultCampus ?? this.defaultCampus,
      showWeekend: showWeekend ?? this.showWeekend,
      classRemindersEnabled:
          classRemindersEnabled ?? this.classRemindersEnabled,
      lastTabIndex: lastTabIndex ?? this.lastTabIndex,
      activeSemesterId: resolvedActiveSemester.id,
      semesters: resolvedSemesters,
      campusSchedules: campusSchedules ?? this.campusSchedules,
      privacyPolicyAccepted:
          privacyPolicyAccepted ?? this.privacyPolicyAccepted,
    );
  }
}

class SemesterConfig {
  const SemesterConfig({
    required this.id,
    required this.name,
    required this.startDate,
  });

  final String id;
  final String name;
  final DateTime startDate;

  factory SemesterConfig.fromMap(Map<String, dynamic> map) {
    return SemesterConfig(
      id: map['id'] as String,
      name: map['name'] as String? ?? '当前学期',
      startDate:
          DateTime.tryParse(map['startDate'] as String? ?? '') ??
          DateTime(2026, 3, 9),
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'startDate': startDate.toIso8601String()};
  }

  SemesterConfig copyWith({String? id, String? name, DateTime? startDate}) {
    return SemesterConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
    );
  }
}

class CampusSchedule {
  const CampusSchedule({
    required this.campus,
    required this.afternoonStartSection,
    required this.eveningStartSection,
    required this.sectionTimes,
  });

  final String campus;
  final int afternoonStartSection;
  final int eveningStartSection;
  final Map<int, SectionTimeRange> sectionTimes;

  factory CampusSchedule.defaultFor(String campus) {
    final source = campus == campusJiangAn
        ? jiangAnSchedule
        : wangJiangHuaXiSchedule;
    return CampusSchedule(
      campus: campus,
      afternoonStartSection: 5,
      eveningStartSection: 10,
      sectionTimes: source.map(
        (key, value) => MapEntry(key, SectionTimeRange.fromText(value)),
      ),
    );
  }

  factory CampusSchedule.fromMap(String campus, Map<String, dynamic> map) {
    final rawSectionTimes =
        (map['sectionTimes'] as Map<String, dynamic>?) ?? {};
    final sectionTimes = <int, SectionTimeRange>{};
    for (final section in sectionNumbers) {
      final value = rawSectionTimes['$section'];
      if (value is Map<String, dynamic>) {
        sectionTimes[section] = SectionTimeRange.fromMap(value);
      } else if (value is String) {
        sectionTimes[section] = SectionTimeRange.fromText(value);
      }
    }
    final fallback = CampusSchedule.defaultFor(campus);
    for (final section in sectionNumbers) {
      sectionTimes.putIfAbsent(section, () => fallback.sectionTimes[section]!);
    }
    return CampusSchedule(
      campus: campus,
      afternoonStartSection: map['afternoonStartSection'] as int? ?? 5,
      eveningStartSection: map['eveningStartSection'] as int? ?? 10,
      sectionTimes: sectionTimes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'afternoonStartSection': afternoonStartSection,
      'eveningStartSection': eveningStartSection,
      'sectionTimes': sectionTimes.map(
        (key, value) => MapEntry('$key', value.toMap()),
      ),
    };
  }

  CampusSchedule copyWith({
    String? campus,
    int? afternoonStartSection,
    int? eveningStartSection,
    Map<int, SectionTimeRange>? sectionTimes,
  }) {
    return CampusSchedule(
      campus: campus ?? this.campus,
      afternoonStartSection:
          afternoonStartSection ?? this.afternoonStartSection,
      eveningStartSection: eveningStartSection ?? this.eveningStartSection,
      sectionTimes: sectionTimes ?? this.sectionTimes,
    );
  }
}

class SectionTimeRange {
  const SectionTimeRange({required this.start, required this.end});

  final String start;
  final String end;

  factory SectionTimeRange.fromText(String text) {
    final parts = text.split('-');
    return SectionTimeRange(
      start: parts.isNotEmpty ? parts.first : '08:00',
      end: parts.length > 1 ? parts.last : '08:45',
    );
  }

  factory SectionTimeRange.fromMap(Map<String, dynamic> map) {
    return SectionTimeRange(
      start: map['start'] as String? ?? '08:00',
      end: map['end'] as String? ?? '08:45',
    );
  }

  Map<String, dynamic> toMap() => {'start': start, 'end': end};

  String get label => '$start-$end';
}

class CourseMeeting {
  const CourseMeeting({
    required this.id,
    required this.title,
    required this.teacher,
    required this.location,
    required this.campus,
    required this.dayOfWeek,
    required this.startSection,
    required this.endSection,
    required this.weeks,
    required this.weekDescription,
    required this.source,
    this.courseCode,
    this.courseSequence,
    this.weekRange,
  });

  final String id;
  final String title;
  final String teacher;
  final String location;
  final String campus;
  final int dayOfWeek;
  final int startSection;
  final int endSection;
  final List<int> weeks;
  final String weekDescription;
  final String source;
  final String? courseCode;
  final String? courseSequence;
  final WeekRange? weekRange;

  factory CourseMeeting.fromMap(Map<String, dynamic> map) {
    return CourseMeeting(
      id: map['id'] as String,
      title: map['title'] as String? ?? '',
      teacher: map['teacher'] as String? ?? '',
      location: map['location'] as String? ?? '',
      campus: map['campus'] as String? ?? campusJiangAn,
      dayOfWeek: map['dayOfWeek'] as int? ?? 1,
      startSection: map['startSection'] as int? ?? 1,
      endSection: map['endSection'] as int? ?? 1,
      weeks:
          (map['weeks'] as List<dynamic>? ?? const [])
              .map((item) => item as int)
              .toList()
              .isEmpty
          ? parseWeeksFromDescription(
              map['weekDescription'] as String? ?? '1-16周',
            )
          : (map['weeks'] as List<dynamic>? ?? const [])
                .map((item) => item as int)
                .toList(),
      weekDescription: map['weekDescription'] as String? ?? '1-16周',
      source: map['source'] as String? ?? CourseSource.manual,
      courseCode: map['courseCode'] as String?,
      courseSequence: map['courseSequence'] as String?,
      weekRange: map['weekRange'] == null
          ? parseWeekRange(map['weekDescription'] as String? ?? '1-16周')
          : WeekRange.fromMap(map['weekRange'] as Map<String, dynamic>),
    );
  }

  factory CourseMeeting.fromImportedMap(Map<String, dynamic> map) {
    final dayOfWeek = map['dayOfWeek'] as int? ?? 1;
    final startSection = map['startSection'] as int? ?? 1;
    final endSection = map['endSection'] as int? ?? startSection;
    final weekDescription = (map['weekDescription'] as String? ?? '1-16周')
        .replaceAll(' ', '');
    final range = parseWeekRange(weekDescription);
    return CourseMeeting(
      id:
          map['id'] as String? ??
          '${map['courseCode']}_${map['courseSequence']}_$dayOfWeek$startSection${map['location']}',
      title: map['title'] as String? ?? '',
      teacher: map['teacher'] as String? ?? '',
      location: map['location'] as String? ?? '',
      campus: normalizeCampus(
        map['campus'] as String? ?? map['location'] as String? ?? '',
      ),
      dayOfWeek: dayOfWeek,
      startSection: startSection,
      endSection: endSection,
      weeks: parseWeeksFromDescription(weekDescription),
      weekDescription: weekDescription,
      source: CourseSource.scu,
      courseCode: map['courseCode'] as String?,
      courseSequence: map['courseSequence'] as String?,
      weekRange: range,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'teacher': teacher,
      'location': location,
      'campus': campus,
      'dayOfWeek': dayOfWeek,
      'startSection': startSection,
      'endSection': endSection,
      'weeks': weeks,
      'weekDescription': weekDescription,
      'source': source,
      'courseCode': courseCode,
      'courseSequence': courseSequence,
      'weekRange': weekRange?.toMap(),
    };
  }

  bool occursInWeek(int week) => weeks.contains(week);

  static int sorter(CourseMeeting a, CourseMeeting b) {
    final weekdayCompare = a.dayOfWeek.compareTo(b.dayOfWeek);
    if (weekdayCompare != 0) {
      return weekdayCompare;
    }
    final sectionCompare = a.startSection.compareTo(b.startSection);
    if (sectionCompare != 0) {
      return sectionCompare;
    }
    return a.title.compareTo(b.title);
  }
}

class TodoItem {
  const TodoItem({
    required this.id,
    required this.title,
    required this.note,
    required this.dueAt,
    required this.category,
    required this.isDone,
    this.completedAt,
  });

  final String id;
  final String title;
  final String note;
  final DateTime dueAt;
  final String category;
  final bool isDone;
  final DateTime? completedAt;

  factory TodoItem.fromMap(Map<String, dynamic> map) {
    return TodoItem(
      id: map['id'] as String,
      title: map['title'] as String? ?? '',
      note: map['note'] as String? ?? '',
      dueAt: DateTime.tryParse(map['dueAt'] as String? ?? '') ?? DateTime.now(),
      category: map['category'] as String? ?? '学习',
      isDone: map['isDone'] as bool? ?? false,
      completedAt: DateTime.tryParse(map['completedAt'] as String? ?? ''),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'note': note,
      'dueAt': dueAt.toIso8601String(),
      'category': category,
      'isDone': isDone,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  TodoItem copyWith({
    String? id,
    String? title,
    String? note,
    DateTime? dueAt,
    String? category,
    bool? isDone,
    DateTime? completedAt,
  }) {
    return TodoItem(
      id: id ?? this.id,
      title: title ?? this.title,
      note: note ?? this.note,
      dueAt: dueAt ?? this.dueAt,
      category: category ?? this.category,
      isDone: isDone ?? this.isDone,
      completedAt: completedAt,
    );
  }

  static int sorter(TodoItem a, TodoItem b) {
    final doneCompare = a.isDone == b.isDone ? 0 : (a.isDone ? 1 : -1);
    if (doneCompare != 0) {
      return doneCompare;
    }
    return a.dueAt.compareTo(b.dueAt);
  }
}

class WeekRange {
  const WeekRange({
    required this.startWeek,
    required this.endWeek,
    required this.mode,
  });

  final int startWeek;
  final int endWeek;
  final WeekMode mode;

  factory WeekRange.fromMap(Map<String, dynamic> map) {
    return WeekRange(
      startWeek: map['startWeek'] as int? ?? 1,
      endWeek: map['endWeek'] as int? ?? 16,
      mode: WeekMode.fromValue(map['mode'] as String? ?? WeekMode.all.value),
    );
  }

  Map<String, dynamic> toMap() {
    return {'startWeek': startWeek, 'endWeek': endWeek, 'mode': mode.value};
  }

  String get description {
    final base = '$startWeek-$endWeek周';
    switch (mode) {
      case WeekMode.all:
        return base;
      case WeekMode.odd:
        return '$base(单周)';
      case WeekMode.even:
        return '$base(双周)';
    }
  }
}

enum WeekMode {
  all('all'),
  odd('odd'),
  even('even');

  const WeekMode(this.value);

  final String value;

  static WeekMode fromValue(String value) {
    return WeekMode.values.firstWhere(
      (item) => item.value == value,
      orElse: () => WeekMode.all,
    );
  }
}

class TodoTemplate {
  const TodoTemplate({
    required this.title,
    required this.category,
    required this.icon,
    required this.offsetDays,
  });

  final String title;
  final String category;
  final IconData icon;
  final int offsetDays;

  TodoItem toTodo() {
    return TodoItem(
      id: 'todo_${DateTime.now().microsecondsSinceEpoch}_$title',
      title: title,
      note: '',
      dueAt: DateTime.now().add(Duration(days: offsetDays)),
      category: category,
      isDone: false,
    );
  }
}

class CourseVisualStyle {
  const CourseVisualStyle({
    required this.background,
    required this.border,
    required this.text,
  });

  final Color background;
  final Color border;
  final Color text;
}

class ManualCourseDraft {
  const ManualCourseDraft({
    required this.dayOfWeek,
    required this.startSection,
    required this.endSection,
    required this.startWeek,
    required this.endWeek,
  });

  final int dayOfWeek;
  final int startSection;
  final int endSection;
  final int startWeek;
  final int endWeek;
}

class CourseSource {
  static const scu = '四川大学教务处';
  static const manual = '手动添加';
}

const campusJiangAn = '江安';
const campusWangJiangHuaXi = '望江/华西';
const campusOptions = [campusJiangAn, campusWangJiangHuaXi];
const sectionNumbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
final canUseEmbeddedScuWebImport =
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android);

const quickTodoTemplates = [
  TodoTemplate(
    title: '交实验报告',
    category: '学习',
    icon: Icons.science_outlined,
    offsetDays: 2,
  ),
  TodoTemplate(
    title: '准备课堂展示',
    category: '学习',
    icon: Icons.slideshow_rounded,
    offsetDays: 3,
  ),
  TodoTemplate(
    title: '期中复习',
    category: '考试',
    icon: Icons.menu_book_rounded,
    offsetDays: 5,
  ),
  TodoTemplate(
    title: '社团例会',
    category: '社团',
    icon: Icons.groups_rounded,
    offsetDays: 1,
  ),
  TodoTemplate(
    title: '宣讲会/面试',
    category: '求职',
    icon: Icons.work_outline_rounded,
    offsetDays: 4,
  ),
  TodoTemplate(
    title: '宿舍缴费',
    category: '生活',
    icon: Icons.payments_outlined,
    offsetDays: 7,
  ),
];

const jiangAnSchedule = {
  1: '08:15-09:00',
  2: '09:10-09:55',
  3: '10:15-11:00',
  4: '11:10-11:55',
  5: '13:50-14:35',
  6: '14:45-15:30',
  7: '15:40-16:25',
  8: '16:45-17:30',
  9: '17:40-18:25',
  10: '19:20-20:05',
  11: '20:15-21:00',
  12: '21:10-21:55',
};

const wangJiangHuaXiSchedule = {
  1: '08:00-08:45',
  2: '08:55-09:40',
  3: '10:00-10:45',
  4: '10:55-11:40',
  5: '14:00-14:45',
  6: '14:55-15:40',
  7: '15:50-16:35',
  8: '16:55-17:40',
  9: '17:50-18:35',
  10: '19:30-20:15',
  11: '20:25-21:10',
  12: '21:20-22:05',
};

String weekdayLabel(int weekday) {
  const labels = {
    1: '周一',
    2: '周二',
    3: '周三',
    4: '周四',
    5: '周五',
    6: '周六',
    7: '周日',
  };
  return labels[weekday] ?? '周一';
}

String weekHeaderLabel(int weekday) {
  const labels = {1: '一', 2: '二', 3: '三', 4: '四', 5: '五', 6: '六', 7: '日'};
  return labels[weekday] ?? '一';
}

String formatMonthDay(DateTime date) => '${date.month}月${date.day}日';

String formatFullDate(DateTime date) =>
    '${date.year}年${date.month}月${date.day}日';

int semesterWeek(DateTime termStartDate, DateTime today) {
  final start = DateTime(
    termStartDate.year,
    termStartDate.month,
    termStartDate.day,
  );
  final current = DateTime(today.year, today.month, today.day);
  final diff = current.difference(start).inDays;
  if (diff < 0) {
    return 1;
  }
  return (diff ~/ 7) + 1;
}

String formatCourseTime(
  AppSettings settings,
  String campus,
  int startSection,
  int endSection,
) {
  final schedule = settings.scheduleForCampus(campus).sectionTimes;
  final start = schedule[startSection];
  final end = schedule[endSection];
  if (start == null || end == null) {
    return '时间待补充';
  }
  return '${start.start}-${end.end}';
}

String sectionTimeLabel(AppSettings settings, String campus, int section) {
  final range = settings.scheduleForCampus(campus).sectionTimes[section];
  return range == null ? '' : '${range.start}\n${range.end}';
}

const courseVisualPalette = [
  CourseVisualStyle(
    background: Color(0xFFE6F2FF),
    border: Color(0xFFBDD8FF),
    text: Color(0xFF3668A8),
  ),
  CourseVisualStyle(
    background: Color(0xFFFFF0DA),
    border: Color(0xFFFFD59C),
    text: Color(0xFFC46B00),
  ),
  CourseVisualStyle(
    background: Color(0xFFEAF7EA),
    border: Color(0xFFBEE2BE),
    text: Color(0xFF2E7D4D),
  ),
  CourseVisualStyle(
    background: Color(0xFFFFE8EF),
    border: Color(0xFFF7BECD),
    text: Color(0xFFC75A7C),
  ),
  CourseVisualStyle(
    background: Color(0xFFE8F7F4),
    border: Color(0xFFAFE3D8),
    text: Color(0xFF1F7F71),
  ),
  CourseVisualStyle(
    background: Color(0xFFF8EFFF),
    border: Color(0xFFDCC1F6),
    text: Color(0xFF8655B4),
  ),
  CourseVisualStyle(
    background: Color(0xFFFFF5DB),
    border: Color(0xFFF1DA9A),
    text: Color(0xFF9B6900),
  ),
  CourseVisualStyle(
    background: Color(0xFFEAF1FF),
    border: Color(0xFFC4D5FF),
    text: Color(0xFF4A63B8),
  ),
];

CourseVisualStyle courseStyleByIndex(int index) =>
    courseVisualPalette[index % courseVisualPalette.length];

CourseVisualStyle courseStyle(CourseMeeting course) {
  final seed = course.title.runes.fold<int>(
    0,
    (sum, rune) => (sum + rune) % courseVisualPalette.length,
  );
  return courseStyleByIndex(seed);
}

String normalizeCampus(String text) {
  if (text.contains('江安')) {
    return campusJiangAn;
  }
  if (text.contains('望江') || text.contains('华西')) {
    return campusWangJiangHuaXi;
  }
  return campusJiangAn;
}

WeekRange parseWeekRange(String raw) {
  final text = raw.replaceAll('周', '').replaceAll(' ', '');
  final rangeMatch = RegExp(r'(\d+)-(\d+)').firstMatch(text);
  final singleMatch = RegExp(r'(\d+)').firstMatch(text);
  final startWeek =
      int.tryParse(rangeMatch?.group(1) ?? singleMatch?.group(1) ?? '1') ?? 1;
  final endWeek =
      int.tryParse(rangeMatch?.group(2) ?? singleMatch?.group(1) ?? '16') ?? 16;
  final mode = text.contains('单')
      ? WeekMode.odd
      : text.contains('双')
      ? WeekMode.even
      : WeekMode.all;
  return WeekRange(startWeek: startWeek, endWeek: endWeek, mode: mode);
}

List<int> buildWeeks(WeekRange range) {
  final weeks = <int>[];
  for (var week = range.startWeek; week <= range.endWeek; week++) {
    final shouldInclude = switch (range.mode) {
      WeekMode.all => true,
      WeekMode.odd => week.isOdd,
      WeekMode.even => week.isEven,
    };
    if (shouldInclude) {
      weeks.add(week);
    }
  }
  return weeks;
}

List<int> parseWeeksFromDescription(String raw) {
  final normalized = raw
      .replaceAll('周', '')
      .replaceAll(' ', '')
      .replaceAll('，', ',');
  final mode = normalized.contains('单')
      ? WeekMode.odd
      : normalized.contains('双')
      ? WeekMode.even
      : WeekMode.all;
  final body = normalized
      .replaceAll('(单)', '')
      .replaceAll('(双)', '')
      .replaceAll('单周', '')
      .replaceAll('双周', '');
  final weeks = <int>{};
  for (final part in body.split(',')) {
    if (part.isEmpty) {
      continue;
    }
    final rangeMatch = RegExp(r'^(\d+)-(\d+)$').firstMatch(part);
    if (rangeMatch != null) {
      final start = int.parse(rangeMatch.group(1)!);
      final end = int.parse(rangeMatch.group(2)!);
      for (var week = start; week <= end; week++) {
        final include = switch (mode) {
          WeekMode.all => true,
          WeekMode.odd => week.isOdd,
          WeekMode.even => week.isEven,
        };
        if (include) {
          weeks.add(week);
        }
      }
      continue;
    }
    final single = int.tryParse(part);
    if (single != null) {
      final include = switch (mode) {
        WeekMode.all => true,
        WeekMode.odd => single.isOdd,
        WeekMode.even => single.isEven,
      };
      if (include) {
        weeks.add(single);
      }
    }
  }
  if (weeks.isEmpty) {
    return buildWeeks(
      const WeekRange(startWeek: 1, endWeek: 16, mode: WeekMode.all),
    );
  }
  return weeks.toList()..sort();
}
