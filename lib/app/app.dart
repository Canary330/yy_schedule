import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/app_core.dart';
import '../core/notification_service.dart';
import '../core/privacy_policy.dart';
import '../features/import/scu_import_page.dart';
import '../features/manual/manual_course_sheet.dart';
import '../features/schedule/schedule_views.dart';
import '../features/settings/settings_page.dart';
import '../features/todo/todo_views.dart';

class ScheduleApp extends StatelessWidget {
  const ScheduleApp({super.key, required this.initialSnapshot});

  final AppSnapshot initialSnapshot;

  @override
  Widget build(BuildContext context) {
    const brand = Color(0xFF7DB7FF);
    final scheme = ColorScheme.fromSeed(
      seedColor: brand,
      brightness: Brightness.light,
    );

    return MaterialApp(
      title: '丫丫课程表',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: scheme,
        scaffoldBackgroundColor: const Color(0xFFF8FBFF),
        useMaterial3: true,
        textTheme: ThemeData.light().textTheme.apply(
          bodyColor: const Color(0xFF1F2937),
          displayColor: const Color(0xFF1F2937),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFF0F172A),
          elevation: 0,
        ),
        navigationBarTheme: NavigationBarThemeData(
          height: 74,
          backgroundColor: const Color(0xFFF7FAFF),
          indicatorColor: const Color(0xFFD9EAFF),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              color: selected
                  ? const Color(0xFF3567A6)
                  : const Color(0xFF5B667A),
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return IconThemeData(
              color: selected
                  ? const Color(0xFF3567A6)
                  : const Color(0xFF5B667A),
            );
          }),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
        ),
      ),
      home: HomeShell(initialSnapshot: initialSnapshot),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.initialSnapshot});

  final AppSnapshot initialSnapshot;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late List<CourseMeeting> _courses;
  late List<TodoItem> _todos;
  late AppSettings _settings;
  int _tabIndex = 0;
  int _selectedWeekday = DateTime.now().weekday;

  @override
  void initState() {
    super.initState();
    _courses = List<CourseMeeting>.from(widget.initialSnapshot.courses);
    _todos = List<TodoItem>.from(widget.initialSnapshot.todos);
    _settings = widget.initialSnapshot.settings;
    _tabIndex = widget.initialSnapshot.settings.lastTabIndex.clamp(0, 3);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensurePrivacyPolicyAccepted();
    });

    unawaited(_syncNotifications());
  }

  Future<void> _persist() {
    return LocalStore.save(
      AppSnapshot(courses: _courses, todos: _todos, settings: _settings),
    );
  }

  Future<void> _ensurePrivacyPolicyAccepted() async {
    if (_settings.privacyPolicyAccepted) {
      return;
    }

    final agree = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: const Text('隐私政策'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '丫丫课程表尊重并保护所有用户的个人隐私权。',
                  style: TextStyle(height: 1.6),
                ),
                const SizedBox(height: 8),
                const Text(
                  '数据收集：本应用不上传用户的个人信息，所有数据均在本地存储。',
                  style: TextStyle(height: 1.6),
                ),
                const SizedBox(height: 4),
                const Text(
                  '数据使用：应用仅在本地获取您明确授权的元数据，仅用于应用内展示。',
                  style: TextStyle(height: 1.6),
                ),
                const SizedBox(height: 4),
                const Text('内购处理：应用完全免费。', style: TextStyle(height: 1.6)),
                const SizedBox(height: 4),
                const Text(
                  '第三方 SDK：本应用未集成任何第三方广告或数据追踪 SDK。',
                  style: TextStyle(height: 1.6),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => openPrivacyPolicy(context),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    foregroundColor: const Color(0xFF2563EB),
                  ),
                  child: const Text(
                    '《隐私政策》',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('不同意并退出'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('同意'),
            ),
          ],
        ),
      ),
    );

    if (agree != true) {
      exit(0);
    }

    setState(() {
      _settings = _settings.copyWith(privacyPolicyAccepted: true);
    });
    await _persist();
  }

  Future<void> _importFromScu() async {
    final imported = await Navigator.of(context).push<List<CourseMeeting>>(
      MaterialPageRoute(
        builder: (_) => const ScuImportPage(),
        fullscreenDialog: true,
      ),
    );
    if (!mounted || imported == null || imported.isEmpty) {
      return;
    }
    await _replaceImportedCourses(imported);
  }

  Future<void> _showImportChooser() async {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(6, 2, 6, 10),
                child: Text(
                  '选择导课来源',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.school_rounded),
                title: const Text('四川大学教务处'),
                subtitle: const Text('登录教务系统后自动导入当前课表'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () async {
                  Navigator.of(context).pop();
                  await _importFromScu();
                },
              ),
              const SizedBox(height: 8),
              InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: () async {
                  Navigator.of(context).pop();
                  await _showSchoolFeedbackDialog();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FBFF),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFFDCE8F7)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.mark_email_read_outlined),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '未找到学校？发送反馈',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                      Icon(Icons.open_in_new_rounded, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _replaceImportedCourses(List<CourseMeeting> imported) async {
    setState(() {
      _courses.removeWhere((course) => course.source == CourseSource.scu);
      _courses.addAll(imported);
      _courses.sort(CourseMeeting.sorter);
    });
    await _persist();
    await _syncNotifications();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('已导入 ${imported.length} 条四川大学课程安排')));
  }

  Future<void> _openManualCourseSheet({
    CourseMeeting? editing,
    ManualCourseDraft? draft,
  }) async {
    final result = await showModalBottomSheet<CourseMeeting>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ManualCourseSheet(
        initialCourse: editing,
        initialDraft: draft,
        settings: _settings,
      ),
    );

    if (result == null) return;
    setState(() {
      _courses.removeWhere((course) => course.id == result.id);
      _courses.add(result);
      _courses.sort(CourseMeeting.sorter);
    });
    await _persist();
    await _syncNotifications();
  }

  Future<void> _deleteCourse(CourseMeeting course) async {
    setState(() {
      _courses.removeWhere((item) => item.id == course.id);
    });
    await _persist();
    await _syncNotifications();
  }

  Future<void> _toggleTodo(TodoItem item, bool checked) async {
    setState(() {
      _todos = _todos
          .map(
            (todo) => todo.id == item.id
                ? todo.copyWith(
                    isDone: checked,
                    completedAt: checked ? DateTime.now() : null,
                  )
                : todo,
          )
          .toList();
    });
    await _persist();
    await _syncNotifications();
  }

  Future<void> _saveTodo(TodoItem item) async {
    setState(() {
      _todos.removeWhere((todo) => todo.id == item.id);
      _todos.add(item);
      _todos.sort(TodoItem.sorter);
    });
    await _persist();
    final granted = await _ensureNotificationPermission(
      featureName: '待办截止提醒',
      requestIfNeeded: true,
    );
    if (granted) {
      await _syncNotifications();
    }
  }

  Future<void> _deleteTodo(TodoItem item) async {
    setState(() {
      _todos.removeWhere((todo) => todo.id == item.id);
    });
    await _persist();
    await _syncNotifications();
  }

  Future<void> _updateSettings(AppSettings settings) async {
    if (settings.classRemindersEnabled && !_settings.classRemindersEnabled) {
      final granted = await _ensureNotificationPermission(
        featureName: '上课时间提醒',
        requestIfNeeded: true,
      );
      if (!granted) {
        return;
      }
    }
    setState(() {
      _settings = settings;
    });
    await _persist();
    await _syncNotifications();
  }

  Future<void> _clearAllData() async {
    setState(() {
      _courses = <CourseMeeting>[];
      _todos = <TodoItem>[];
    });
    await _persist();
    await _syncNotifications();
  }

  Future<void> _saveLastTabIndex(int value) async {
    setState(() {
      _tabIndex = value;
      _settings = _settings.copyWith(lastTabIndex: value);
    });
    await _persist();
  }

  Future<void> _syncNotifications() {
    return NotificationService.instance.syncAll(
      todos: _todos,
      courses: _courses,
      settings: _settings,
    );
  }

  Future<bool> _ensureNotificationPermission({
    required String featureName,
    required bool requestIfNeeded,
  }) async {
    final status = await NotificationService.instance.notificationStatus();
    if (status.isGranted) {
      return true;
    }

    if (requestIfNeeded &&
        (status.isDenied || status.isRestricted || status.isLimited)) {
      final granted = await NotificationService.instance.requestPermission();
      if (granted) {
        return true;
      }
    }

    if (!mounted) {
      return false;
    }

    final shouldOpenSettings = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('通知未开启'),
        content: Text('要使用$featureName，需要开启系统通知权限。当前无法直接使用提醒，是否前往系统设置打开通知？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('暂不'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('去设置'),
          ),
        ],
      ),
    );
    if (shouldOpenSettings == true) {
      await NotificationService.instance.openSystemSettings();
    }
    return false;
  }

  Future<void> _showSchoolFeedbackDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('发送学校适配反馈'),
        content: const Text(
          '请先登录学校的教务处网站后，进入课表界面， 按下“ctrl s”保存文件。\n手机端可点击浏览器右上角“…”后选择“下载内容”。\n如果你愿意发送反馈，确认后会打开邮箱。请附上刚刚保存的 HTML 附件发送给我们。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('确认'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    final subject = Uri.encodeComponent('【学校适配反馈】丫丫课程表导课适配申请');
    final body = Uri.encodeComponent(
      '你好，我想反馈新的学校导课适配需求。\n\n学校名称：\n教务系统名称/网址：\n使用设备：\n系统版本：\n问题描述：\n\n请在发送本邮件时，附上刚刚保存的课表 HTML 文件附件，方便适配与排查。\n谢谢！',
    );
    final uri = Uri.parse(
      'mailto:canmico@icloud.com?subject=$subject&body=$body',
    );
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('没有找到可用的邮箱应用，请先配置系统邮箱。')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      SchedulePage(
        courses: _courses,
        settings: _settings,
        selectedWeekday: _selectedWeekday,
        onSelectedWeekdayChanged: (value) =>
            setState(() => _selectedWeekday = value),
        onImportTap: _showImportChooser,
        onManualAddTap: (draft) => _openManualCourseSheet(draft: draft),
        onDeleteCourse: _deleteCourse,
      ),
      WeekSchedulePage(
        courses: _courses,
        settings: _settings,
        onImportTap: _showImportChooser,
        onManualAddTap: (draft) => _openManualCourseSheet(draft: draft),
        onDeleteCourse: _deleteCourse,
      ),
      TodoPage(
        todos: _todos,
        onToggleTodo: _toggleTodo,
        onSaveTodo: _saveTodo,
        onDeleteTodo: _deleteTodo,
      ),
      SettingsPage(
        settings: _settings,
        courseCount: _courses.length,
        todoCount: _todos.length,
        onSettingsChanged: _updateSettings,
        onClearAllData: _clearAllData,
      ),
    ];

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEAF4FF), Color(0xFFFFF9E8), Color(0xFFFFFFFF)],
          ),
        ),
        child: SafeArea(child: pages[_tabIndex]),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: _saveLastTabIndex,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: '首页'),
          NavigationDestination(
            icon: Icon(Icons.calendar_view_week_rounded),
            label: '课表',
          ),
          NavigationDestination(
            icon: Icon(Icons.checklist_rounded),
            label: '待办',
          ),
          NavigationDestination(icon: Icon(Icons.tune_rounded), label: '设置'),
        ],
      ),
    );
  }
}
