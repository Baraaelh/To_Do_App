import 'package:flutter/material.dart';
import 'services/database_helper.dart';
import 'models/task_model.dart';

void main() {
  runApp(
    const MaterialApp(debugShowCheckedModeBanner: false, home: TodoScreen()),
  );
}

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    _refreshTasks();
  }

  // تحديث قائمة المهام من قاعدة البيانات
  void _refreshTasks() async {
    final data = await _dbHelper.getAllTasks();
    setState(() {
      _tasks = data;
    });
  }

  // إظهار نافذة الإضافة أو التعديل
  void _showTaskForm(Task? task) {
    if (task != null) {
      _titleController.text = task.title;
      _descController.text = task.description;
    } else {
      _titleController.clear();
      _descController.clear();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          top: 20,
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              textAlign: TextAlign.right, // الكتابة من اليمين
              textDirection: TextDirection.rtl, // اتجاه النص من اليمين لليسار
              decoration: const InputDecoration(
                labelText: 'عنوان المهمة',
                alignLabelWithHint: true,
              ),
            ),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'الوصف'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (task == null) {
                  await _dbHelper.insertTask(
                    Task(
                      title: _titleController.text,
                      description: _descController.text,
                    ),
                  );
                } else {
                  task.title = _titleController.text;
                  task.description = _descController.text;
                  await _dbHelper.updateTask(task);
                }
                _refreshTasks();
                Navigator.pop(context);
              },
              child: Text(task == null ? 'إضافة مهمة' : 'تحديث المهمة'),
            ),
          ],
        ),
      ),
    );
  }

  // حوار تأكيد الحذف
  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("تأكيد الحذف"),
        content: const Text("هل تريد حذف هذه المهمة نهائياً؟"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("إلغاء"),
          ),
          TextButton(
            onPressed: () async {
              await _dbHelper.deleteTask(id);
              _refreshTasks();
              Navigator.pop(ctx);
            },
            child: const Text("حذف", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () async {
              await _dbHelper.deleteCompletedTasks();
              _refreshTasks();
            },
            tooltip: "حذف المكتمل",
          ),
        ],
      ),
      body: _tasks.isEmpty
          ? const Center(child: Text("لا توجد مهام حالياً"))
          : ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final item = _tasks[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: ListTile(
                    leading: Checkbox(
                      value: item.isComplete == 1,
                      onChanged: (val) async {
                        item.isComplete = val! ? 1 : 0;
                        await _dbHelper.updateTask(item);
                        _refreshTasks();
                      },
                    ),
                    title: Text(
                      item.title,
                      style: TextStyle(
                        decoration: item.isComplete == 1
                            ? TextDecoration.lineThrough
                            : null,
                        color: item.isComplete == 1
                            ? Colors.grey
                            : Colors.black,
                      ),
                    ),
                    subtitle: Text(item.description),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showTaskForm(item),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDelete(item.id!),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTaskForm(null),
        child: const Icon(Icons.add),
      ),
    );
  }
}
