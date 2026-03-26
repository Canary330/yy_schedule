import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'app_core.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const _todoChannelId = 'todo_deadlines';
  static const _classChannelId = 'class_reminders';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      tz.initializeTimeZones();
      final timezoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneName));

      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const ios = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      const settings = InitializationSettings(android: android, iOS: ios);
      await _plugin.initialize(settings);

      final androidImpl = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await androidImpl?.createNotificationChannel(
        const AndroidNotificationChannel(
          _todoChannelId,
          '待办截止提醒',
          description: '在待办截止时发送提醒',
          importance: Importance.max,
        ),
      );
      await androidImpl?.createNotificationChannel(
        const AndroidNotificationChannel(
          _classChannelId,
          '上课时间提醒',
          description: '在课程开始时发送提醒',
          importance: Importance.defaultImportance,
        ),
      );
      _initialized = true;
    } on MissingPluginException {
      _initialized = false;
    } catch (_) {
      _initialized = false;
    }
  }

  Future<PermissionStatus> notificationStatus() async {
    try {
      return await Permission.notification.status;
    } catch (_) {
      return PermissionStatus.denied;
    }
  }

  Future<bool> requestPermission() async {
    try {
      final status = await Permission.notification.request();
      return status.isGranted;
    } catch (_) {
      return false;
    }
  }

  Future<bool> openSystemSettings() async {
    try {
      return await openAppSettings();
    } catch (_) {
      return false;
    }
  }

  Future<void> syncAll({
    required List<TodoItem> todos,
    required List<CourseMeeting> courses,
    required AppSettings settings,
  }) async {
    await initialize();
    if (!_initialized) return;
    final status = await notificationStatus();
    if (!status.isGranted) {
      await cancelAll();
      return;
    }

    await cancelAll();
    for (final todo in todos) {
      await _scheduleTodo(todo);
    }
    if (settings.classRemindersEnabled) {
      for (final course in courses) {
        await _scheduleCourseMeetings(course, settings);
      }
    }
  }

  Future<void> cancelAll() async {
    try {
      await _plugin.cancelAll();
    } catch (_) {}
  }

  Future<void> _scheduleTodo(TodoItem todo) async {
    if (todo.isDone || !todo.dueAt.isAfter(DateTime.now())) return;
    await _plugin.zonedSchedule(
      _stableId('todo_${todo.id}'),
      todo.title,
      todo.note.isEmpty ? '待办截止时间到了' : todo.note,
      tz.TZDateTime.from(todo.dueAt, tz.local),
      NotificationDetails(
        android: const AndroidNotificationDetails(
          _todoChannelId,
          '待办截止提醒',
          channelDescription: '在待办截止时发送提醒',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> _scheduleCourseMeetings(
    CourseMeeting course,
    AppSettings settings,
  ) async {
    final startTime = settings
        .scheduleForCampus(course.campus)
        .sectionTimes[course.startSection];
    if (startTime == null) return;
    final startParts = startTime.start.split(':');
    final hour = int.tryParse(startParts.first) ?? 8;
    final minute = int.tryParse(startParts.last) ?? 0;
    final base = DateTime(
      settings.termStartDate.year,
      settings.termStartDate.month,
      settings.termStartDate.day,
    );

    for (final week in course.weeks) {
      final date = base.add(
        Duration(days: (week - 1) * 7 + (course.dayOfWeek - 1)),
      );
      final scheduled = DateTime(date.year, date.month, date.day, hour, minute);
      if (!scheduled.isAfter(DateTime.now())) continue;
      await _plugin.zonedSchedule(
        _stableId('course_${course.id}_$week'),
        '${course.title} 开始上课',
        course.location.isEmpty
            ? '现在是第${course.startSection}节课'
            : '@${course.location}',
        tz.TZDateTime.from(scheduled, tz.local),
        NotificationDetails(
          android: const AndroidNotificationDetails(
            _classChannelId,
            '上课时间提醒',
            channelDescription: '在课程开始时发送提醒',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }
  }

  int _stableId(String value) => value.hashCode & 0x7fffffff;
}
