import 'package:flutter/material.dart';

import '../../core/app_core.dart';
import '../../core/privacy_policy.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
    required this.settings,
    required this.courseCount,
    required this.todoCount,
    required this.onSettingsChanged,
    required this.onClearAllData,
  });

  final AppSettings settings;
  final int courseCount;
  final int todoCount;
  final Future<void> Function(AppSettings settings) onSettingsChanged;
  final Future<void> Function() onClearAllData;

  @override
  Widget build(BuildContext context) {
    final activeSemester = settings.activeSemester;
    final currentSchedule = settings.scheduleForCampus(campusJiangAn);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      children: [
        const Text(
          '设置',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        const Text(
          '在这里调整学期、默认校区、作息时间和应用数据。',
          style: TextStyle(color: Color(0xFF64748B), height: 1.6),
        ),
        const SizedBox(height: 18),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '学期设置',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 14),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('当前学期'),
                  subtitle: Text(
                    '${activeSemester.name} · ${formatFullDate(activeSemester.startDate)}开学',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _openSemesterManager(context),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('手动添课默认校区'),
                  subtitle: Text(settings.defaultCampus),
                  trailing: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: settings.defaultCampus,
                      items: campusOptions
                          .map(
                            (campus) => DropdownMenuItem(
                              value: campus,
                              child: Text(campus),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          onSettingsChanged(
                            settings.copyWith(defaultCampus: value),
                          );
                        }
                      },
                    ),
                  ),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('高级作息模板'),
                  subtitle: Text(
                    '上午 ${currentSchedule.sectionTimes[1]?.start ?? '--'} / 下午 ${currentSchedule.sectionTimes[currentSchedule.afternoonStartSection]?.start ?? '--'} / 晚上 ${currentSchedule.sectionTimes[currentSchedule.eveningStartSection]?.start ?? '--'}',
                  ),
                  trailing: const Icon(Icons.tune_rounded),
                  onTap: () => _openScheduleEditor(context),
                ),
                const Divider(),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('课表显示周末'),
                  subtitle: const Text('关闭后仅展示周一到周五'),
                  value: settings.showWeekend,
                  onChanged: (value) {
                    onSettingsChanged(settings.copyWith(showWeekend: value));
                  },
                ),
                const Divider(),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('上课时间提醒'),
                  subtitle: const Text('在课程开始时发送通知提醒，默认关闭'),
                  value: settings.classRemindersEnabled,
                  onChanged: (value) {
                    onSettingsChanged(
                      settings.copyWith(classRemindersEnabled: value),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '数据',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 14),
                _InfoRow(label: '已保存课程', value: '$courseCount'),
                _InfoRow(label: '已保存待办', value: '$todoCount'),
                const SizedBox(height: 12),
                const Text(
                  '一键导课仅在用户主动登录四川大学官方教务处后读取“选课结果”中的必要课程信息，不采集账号密码，不上传到第三方服务器。',
                  style: TextStyle(color: Color(0xFF475569), height: 1.7),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('清空本地数据'),
                        content: const Text('将删除本机保存的课程和待办，这个动作无法恢复。'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('取消'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('确认清空'),
                          ),
                        ],
                      ),
                    );
                    if (ok == true) {
                      await onClearAllData();
                    }
                  },
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: const Text('清空本地课程与待办'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () => openPrivacyPolicy(context),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    foregroundColor: const Color(0xFF2563EB),
                  ),
                  child: const Text(
                    '隐私政策',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: () => openAppleStandardEula(context),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    foregroundColor: const Color(0xFF2563EB),
                  ),
                  child: const Text(
                    'EULA',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openSemesterManager(BuildContext context) async {
    final result = await showModalBottomSheet<AppSettings>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SemesterManagerSheet(settings: settings),
    );
    if (result != null) {
      await onSettingsChanged(result);
    }
  }

  Future<void> _openScheduleEditor(BuildContext context) async {
    final result = await showModalBottomSheet<CampusSchedule>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CampusScheduleEditorSheet(
        schedule: settings.scheduleForCampus(campusJiangAn),
      ),
    );
    if (result != null) {
      final updated = Map<String, CampusSchedule>.from(
        settings.campusSchedules,
      );
      updated[campusJiangAn] = result.copyWith(campus: campusJiangAn);
      updated[campusWangJiangHuaXi] = result.copyWith(
        campus: campusWangJiangHuaXi,
      );
      await onSettingsChanged(settings.copyWith(campusSchedules: updated));
    }
  }
}

class _SemesterManagerSheet extends StatefulWidget {
  const _SemesterManagerSheet({required this.settings});

  final AppSettings settings;

  @override
  State<_SemesterManagerSheet> createState() => _SemesterManagerSheetState();
}

class _SemesterManagerSheetState extends State<_SemesterManagerSheet> {
  late List<SemesterConfig> _semesters;
  late String _activeSemesterId;

  @override
  void initState() {
    super.initState();
    _semesters = List<SemesterConfig>.from(widget.settings.semesters);
    _activeSemesterId = widget.settings.activeSemesterId;
  }

  @override
  Widget build(BuildContext context) {
    return _SheetFrame(
      title: '学期管理',
      child: Column(
        children: [
          for (final semester in _semesters)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: () => setState(() => _activeSemesterId = semester.id),
                child: Icon(
                  _activeSemesterId == semester.id
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: _activeSemesterId == semester.id
                      ? const Color(0xFF4B84D4)
                      : const Color(0xFF94A3B8),
                ),
              ),
              title: Text(semester.name),
              subtitle: Text('开学：${formatFullDate(semester.startDate)}'),
              onTap: () => setState(() => _activeSemesterId = semester.id),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => _editSemester(semester),
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  IconButton(
                    onPressed: _semesters.length == 1
                        ? null
                        : () => _deleteSemester(semester),
                    icon: const Icon(Icons.delete_outline_rounded),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _editSemester(),
              icon: const Icon(Icons.add_rounded),
              label: const Text('新增学期'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(onPressed: _save, child: const Text('保存学期设置')),
          ),
        ],
      ),
    );
  }

  Future<void> _editSemester([SemesterConfig? editing]) async {
    final result = await showModalBottomSheet<SemesterConfig>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SemesterEditSheet(initial: editing),
    );
    if (result == null) return;
    setState(() {
      final index = _semesters.indexWhere((item) => item.id == result.id);
      if (index == -1) {
        _semesters.add(result);
      } else {
        _semesters[index] = result;
      }
      if (editing == null) {
        _activeSemesterId = result.id;
      }
    });
  }

  void _deleteSemester(SemesterConfig semester) {
    setState(() {
      _semesters.removeWhere((item) => item.id == semester.id);
      if (_activeSemesterId == semester.id && _semesters.isNotEmpty) {
        _activeSemesterId = _semesters.first.id;
      }
    });
  }

  void _save() {
    final active = _semesters.firstWhere(
      (item) => item.id == _activeSemesterId,
      orElse: () => _semesters.first,
    );
    Navigator.of(context).pop(
      widget.settings.copyWith(
        semesters: _semesters,
        activeSemesterId: active.id,
        termStartDate: active.startDate,
      ),
    );
  }
}

class _SemesterEditSheet extends StatefulWidget {
  const _SemesterEditSheet({this.initial});

  final SemesterConfig? initial;

  @override
  State<_SemesterEditSheet> createState() => _SemesterEditSheetState();
}

class _SemesterEditSheetState extends State<_SemesterEditSheet> {
  late final TextEditingController _nameController;
  late DateTime _startDate;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initial?.startDate ?? DateTime.now();
    _nameController = TextEditingController(
      text: widget.initial?.name ?? _defaultSemesterName(_startDate),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SheetFrame(
      title: widget.initial == null ? '新增学期' : '编辑学期',
      child: Column(
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: '学期名称',
              hintText: '例如：2026-2027 第1学期',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('开学日期'),
            subtitle: Text(formatFullDate(_startDate)),
            trailing: const Icon(Icons.calendar_month_rounded),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _startDate,
                firstDate: DateTime(2024),
                lastDate: DateTime(2035),
              );
              if (picked != null) {
                setState(() {
                  _startDate = picked;
                  if (widget.initial == null ||
                      _nameController.text.trim().isEmpty) {
                    _nameController.text = _defaultSemesterName(_startDate);
                  }
                });
              }
            },
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(onPressed: _submit, child: const Text('保存学期')),
          ),
        ],
      ),
    );
  }

  void _submit() {
    final name = _nameController.text.trim().isEmpty
        ? _defaultSemesterName(_startDate)
        : _nameController.text.trim();
    Navigator.of(context).pop(
      SemesterConfig(
        id:
            widget.initial?.id ??
            'semester_${DateTime.now().microsecondsSinceEpoch}',
        name: name,
        startDate: _startDate,
      ),
    );
  }

  String _defaultSemesterName(DateTime date) {
    if (date.month >= 8) {
      return '${date.year}-${date.year + 1} 学年 秋季学期';
    }
    return '${date.year - 1}-${date.year} 学年 春季学期';
  }
}

class _CampusScheduleEditorSheet extends StatefulWidget {
  const _CampusScheduleEditorSheet({required this.schedule});
  final CampusSchedule schedule;

  @override
  State<_CampusScheduleEditorSheet> createState() =>
      _CampusScheduleEditorSheetState();
}

class _CampusScheduleEditorSheetState
    extends State<_CampusScheduleEditorSheet> {
  late int _afternoonStartSection;
  late int _eveningStartSection;
  late Map<int, SectionTimeRange> _sectionTimes;

  @override
  void initState() {
    super.initState();
    _afternoonStartSection = widget.schedule.afternoonStartSection;
    _eveningStartSection = widget.schedule.eveningStartSection;
    _sectionTimes = Map<int, SectionTimeRange>.from(
      widget.schedule.sectionTimes,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _SheetFrame(
      title: '高级作息',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '你可以自定义每节课的开始与结束时间，也可以定义下午和晚上的起始节次。',
            style: TextStyle(color: Color(0xFF64748B), height: 1.6),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  initialValue: _afternoonStartSection,
                  decoration: const InputDecoration(
                    labelText: '下午开始节次',
                    border: OutlineInputBorder(),
                  ),
                  items: sectionNumbers
                      .map(
                        (item) => DropdownMenuItem(
                          value: item,
                          child: Text('第$item节'),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(
                    () => _afternoonStartSection =
                        value ?? _afternoonStartSection,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<int>(
                  initialValue: _eveningStartSection,
                  decoration: const InputDecoration(
                    labelText: '晚上开始节次',
                    border: OutlineInputBorder(),
                  ),
                  items: sectionNumbers
                      .map(
                        (item) => DropdownMenuItem(
                          value: item,
                          child: Text('第$item节'),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(
                    () => _eveningStartSection = value ?? _eveningStartSection,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (final section in sectionNumbers) ...[
            Row(
              children: [
                SizedBox(
                  width: 56,
                  child: Text(
                    '第$section节',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pickTime(section, true),
                    child: Text(_sectionTimes[section]?.start ?? '--:--'),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('至'),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pickTime(section, false),
                    child: Text(_sectionTimes[section]?.end ?? '--:--'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
          SizedBox(
            width: double.infinity,
            child: FilledButton(onPressed: _save, child: const Text('保存高级作息')),
          ),
        ],
      ),
    );
  }

  Future<void> _pickTime(int section, bool isStart) async {
    final current = _sectionTimes[section]!;
    final source = isStart ? current.start : current.end;
    final parts = source.split(':');
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.tryParse(parts.first) ?? 8,
        minute: int.tryParse(parts.last) ?? 0,
      ),
    );
    if (picked == null) return;
    final formatted =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    setState(() {
      _sectionTimes[section] = SectionTimeRange(
        start: isStart ? formatted : current.start,
        end: isStart ? current.end : formatted,
      );
    });
  }

  void _save() {
    Navigator.of(context).pop(
      widget.schedule.copyWith(
        afternoonStartSection: _afternoonStartSection,
        eveningStartSection: _eveningStartSection,
        sectionTimes: _sectionTimes,
      ),
    );
  }
}

class _SheetFrame extends StatelessWidget {
  const _SheetFrame({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            child: Column(
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
                const SizedBox(height: 20),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      splashRadius: 20,
                    ),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF64748B))),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
