import 'package:flutter/material.dart';

import '../../core/app_core.dart';

class ManualCourseSheet extends StatefulWidget {
  const ManualCourseSheet({
    super.key,
    required this.settings,
    this.initialCourse,
    this.initialDraft,
  });

  final AppSettings settings;
  final CourseMeeting? initialCourse;
  final ManualCourseDraft? initialDraft;

  @override
  State<ManualCourseSheet> createState() => _ManualCourseSheetState();
}

class _ManualCourseSheetState extends State<ManualCourseSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _teacherController;
  late final TextEditingController _locationController;
  late int _dayOfWeek;
  late int _startSection;
  late int _endSection;
  late int _startWeek;
  late int _endWeek;
  late String _weekMode;
  late String _campus;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialCourse;
    final draft = widget.initialDraft;
    _titleController = TextEditingController(text: initial?.title ?? '');
    _teacherController = TextEditingController(text: initial?.teacher ?? '');
    _locationController = TextEditingController(text: initial?.location ?? '');
    _dayOfWeek = initial?.dayOfWeek ?? draft?.dayOfWeek ?? 1;
    _startSection = initial?.startSection ?? draft?.startSection ?? 1;
    _endSection = initial?.endSection ?? draft?.endSection ?? 2;
    final weekRange =
        initial?.weekRange ??
        WeekRange(
          startWeek: draft?.startWeek ?? 1,
          endWeek: draft?.endWeek ?? 16,
          mode: WeekMode.all,
        );
    _startWeek = weekRange.startWeek;
    _endWeek = weekRange.endWeek;
    _weekMode = weekRange.mode.value;
    _campus = initial?.campus ?? widget.settings.defaultCampus;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _teacherController.dispose();
    _locationController.dispose();
    super.dispose();
  }

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
                Text(
                  widget.initialCourse == null ? '手动添课' : '编辑课程',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '适合补课、实验、讲座、自习安排等临时或个性化课程。',
                  style: TextStyle(color: Color(0xFF64748B), height: 1.6),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: '课程名称',
                    hintText: '例如：数据库系统实验',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _teacherController,
                  decoration: const InputDecoration(
                    labelText: '教师',
                    hintText: '可不填',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: '地点',
                    hintText: '例如：江安一教A座A106',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: _dayOfWeek,
                        decoration: const InputDecoration(
                          labelText: '星期',
                          border: OutlineInputBorder(),
                        ),
                        items: List.generate(
                          7,
                          (index) => DropdownMenuItem(
                            value: index + 1,
                            child: Text(weekdayLabel(index + 1)),
                          ),
                        ),
                        onChanged: (value) =>
                            setState(() => _dayOfWeek = value ?? 1),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _campus,
                        decoration: const InputDecoration(
                          labelText: '校区作息',
                          border: OutlineInputBorder(),
                        ),
                        items: campusOptions
                            .map(
                              (item) => DropdownMenuItem(
                                value: item,
                                child: Text(item),
                              ),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _campus = value ?? campusJiangAn),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: _startSection,
                        decoration: const InputDecoration(
                          labelText: '开始节次',
                          border: OutlineInputBorder(),
                        ),
                        items: sectionNumbers
                            .map(
                              (section) => DropdownMenuItem(
                                value: section,
                                child: Text('第$section节'),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _startSection = value ?? 1;
                            if (_endSection < _startSection) {
                              _endSection = _startSection;
                            }
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: _endSection,
                        decoration: const InputDecoration(
                          labelText: '结束节次',
                          border: OutlineInputBorder(),
                        ),
                        items: sectionNumbers
                            .where((section) => section >= _startSection)
                            .map(
                              (section) => DropdownMenuItem(
                                value: section,
                                child: Text('第$section节'),
                              ),
                            )
                            .toList(),
                        onChanged: (value) => setState(
                          () => _endSection = value ?? _startSection,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  '上课周次',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: _startWeek,
                        decoration: const InputDecoration(
                          labelText: '开始周',
                          border: OutlineInputBorder(),
                        ),
                        items: List.generate(
                          25,
                          (index) => DropdownMenuItem(
                            value: index + 1,
                            child: Text('第${index + 1}周'),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _startWeek = value ?? 1;
                            if (_endWeek < _startWeek) {
                              _endWeek = _startWeek;
                            }
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: _endWeek,
                        decoration: const InputDecoration(
                          labelText: '结束周',
                          border: OutlineInputBorder(),
                        ),
                        items:
                            List.generate(25, (index) {
                                  final week = index + 1;
                                  return DropdownMenuItem(
                                    value: week,
                                    child: Text('第$week周'),
                                  );
                                })
                                .where(
                                  (item) => (item.value ?? 1) >= _startWeek,
                                )
                                .toList(),
                        onChanged: (value) =>
                            setState(() => _endWeek = value ?? _startWeek),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'all', label: Text('全周')),
                    ButtonSegment(value: 'odd', label: Text('单周')),
                    ButtonSegment(value: 'even', label: Text('双周')),
                  ],
                  selected: {_weekMode},
                  onSelectionChanged: (value) =>
                      setState(() => _weekMode = value.first),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _submit,
                    child: const Text('保存课程'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请先填写课程名称')));
      return;
    }

    final weekRange = WeekRange(
      startWeek: _startWeek,
      endWeek: _endWeek,
      mode: WeekMode.fromValue(_weekMode),
    );
    final weeks = buildWeeks(weekRange);
    final course = CourseMeeting(
      id:
          widget.initialCourse?.id ??
          'manual_${DateTime.now().microsecondsSinceEpoch}',
      title: title,
      teacher: _teacherController.text.trim(),
      location: _locationController.text.trim(),
      campus: _campus,
      dayOfWeek: _dayOfWeek,
      startSection: _startSection,
      endSection: _endSection,
      weeks: weeks,
      weekDescription: weekRange.description,
      source: CourseSource.manual,
      weekRange: weekRange,
    );
    Navigator.of(context).pop(course);
  }
}
