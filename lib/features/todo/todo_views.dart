import 'package:flutter/material.dart';

import '../../core/app_core.dart';

class TodoPage extends StatelessWidget {
  const TodoPage({
    super.key,
    required this.todos,
    required this.onToggleTodo,
    required this.onSaveTodo,
    required this.onDeleteTodo,
  });

  final List<TodoItem> todos;
  final Future<void> Function(TodoItem item, bool checked) onToggleTodo;
  final Future<void> Function(TodoItem item) onSaveTodo;
  final Future<void> Function(TodoItem item) onDeleteTodo;

  @override
  Widget build(BuildContext context) {
    final pending = todos.where((todo) => !todo.isDone).toList()
      ..sort(TodoItem.sorter);
    final finished = todos.where((todo) => todo.isDone).toList()
      ..sort(TodoItem.sorter);
    final templates = quickTodoTemplates;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      children: [
        const Text(
          '待办事项',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        const Text(
          '把作业、实验、答辩、社团和值班这些大学生日常安排放在一起。',
          style: TextStyle(color: Color(0xFF64748B), height: 1.6),
        ),
        const SizedBox(height: 18),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      '常用事件',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    FilledButton.icon(
                      onPressed: () => _openTodoSheet(context),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('新增待办'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final template in templates)
                      ActionChip(
                        label: Text(template.title),
                        avatar: Icon(template.icon, size: 18),
                        onPressed: () => onSaveTodo(template.toTodo()),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        _TodoSection(
          title: '进行中',
          items: pending,
          emptyHint: '现在很清爽，给自己加一个今天要完成的小目标吧。',
          onToggleTodo: onToggleTodo,
          onDeleteTodo: onDeleteTodo,
          onEditTodo: (item) => _openTodoSheet(context, item),
        ),
        const SizedBox(height: 18),
        _TodoSection(
          title: '已完成',
          items: finished,
          emptyHint: '完成的待办会出现在这里。',
          onToggleTodo: onToggleTodo,
          onDeleteTodo: onDeleteTodo,
          onEditTodo: (item) => _openTodoSheet(context, item),
        ),
      ],
    );
  }

  Future<void> _openTodoSheet(BuildContext context, [TodoItem? initial]) async {
    final result = await showModalBottomSheet<TodoItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TodoSheet(initialItem: initial),
    );
    if (result != null) {
      await onSaveTodo(result);
    }
  }
}

class TodoSheet extends StatefulWidget {
  const TodoSheet({super.key, this.initialItem});

  final TodoItem? initialItem;

  @override
  State<TodoSheet> createState() => _TodoSheetState();
}

class _TodoSheetState extends State<TodoSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _noteController;
  late DateTime _dueAt;
  late String _category;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.initialItem?.title ?? '',
    );
    _noteController = TextEditingController(
      text: widget.initialItem?.note ?? '',
    );
    _dueAt =
        widget.initialItem?.dueAt ??
        DateTime.now().add(const Duration(days: 1));
    _category = widget.initialItem?.category ?? '学习';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
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
                  widget.initialItem == null ? '新增待办' : '编辑待办',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: '标题',
                    hintText: '例如：交数据库实验报告',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  decoration: const InputDecoration(
                    labelText: '分类',
                    border: OutlineInputBorder(),
                  ),
                  items: const ['学习', '考试', '社团', '生活', '求职']
                      .map(
                        (item) =>
                            DropdownMenuItem(value: item, child: Text(item)),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _category = value ?? '学习'),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('截止时间'),
                  subtitle: Text(_formatDueAt(_dueAt)),
                  trailing: const Icon(Icons.schedule_rounded),
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _dueAt,
                      firstDate: DateTime(2024),
                      lastDate: DateTime(2030),
                    );
                    if (pickedDate == null || !context.mounted) {
                      return;
                    }
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_dueAt),
                    );
                    if (pickedTime != null) {
                      setState(() {
                        _dueAt = DateTime(
                          pickedDate.year,
                          pickedDate.month,
                          pickedDate.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _noteController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: '备注',
                    hintText: '可填写教室、DDL、要准备的材料等',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _submit,
                    child: const Text('保存待办'),
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
      ).showSnackBar(const SnackBar(content: Text('请填写待办标题')));
      return;
    }
    Navigator.of(context).pop(
      TodoItem(
        id:
            widget.initialItem?.id ??
            'todo_${DateTime.now().microsecondsSinceEpoch}',
        title: title,
        note: _noteController.text.trim(),
        dueAt: _dueAt,
        category: _category,
        isDone: widget.initialItem?.isDone ?? false,
        completedAt: widget.initialItem?.completedAt,
      ),
    );
  }

  String _formatDueAt(DateTime value) {
    final hh = value.hour.toString().padLeft(2, '0');
    final mm = value.minute.toString().padLeft(2, '0');
    return '${formatFullDate(value)} $hh:$mm';
  }
}

class _TodoSection extends StatelessWidget {
  const _TodoSection({
    required this.title,
    required this.items,
    required this.emptyHint,
    required this.onToggleTodo,
    required this.onDeleteTodo,
    required this.onEditTodo,
  });

  final String title;
  final List<TodoItem> items;
  final String emptyHint;
  final Future<void> Function(TodoItem item, bool checked) onToggleTodo;
  final Future<void> Function(TodoItem item) onDeleteTodo;
  final Future<void> Function(TodoItem item) onEditTodo;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 14),
            if (items.isEmpty)
              Text(
                emptyHint,
                style: const TextStyle(color: Color(0xFF64748B), height: 1.6),
              )
            else
              ...items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ListTile(
                      leading: Checkbox(
                        value: item.isDone,
                        onChanged: (value) =>
                            onToggleTodo(item, value ?? false),
                      ),
                      title: Text(
                        item.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          decoration: item.isDone
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      subtitle: Text(
                        '${item.category} · ${formatFullDate(item.dueAt)}${item.note.isEmpty ? '' : '\n${item.note}'}',
                        style: const TextStyle(height: 1.6),
                      ),
                      isThreeLine: item.note.isNotEmpty,
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            onEditTodo(item);
                          }
                          if (value == 'delete') {
                            onDeleteTodo(item);
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem<String>(
                            value: 'edit',
                            child: Text('编辑'),
                          ),
                          PopupMenuItem<String>(
                            value: 'delete',
                            child: Text('删除'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
