import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/task.dart';
import '../providers/task_provider.dart';
import '../services/notification_service.dart';

class TaskTile extends ConsumerWidget {
  final Task task;

  const TaskTile({required this.task});

  void _showEditTaskDialog(BuildContext context, WidgetRef ref, Task task) {
    final titleController = TextEditingController(text: task.title);
    final descriptionController = TextEditingController(text: task.description);
    DateTime? selectedTime = task.alarmTime;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Task'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter task title',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter task description',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Set Reminder'),
                trailing: IconButton(
                  icon: const Icon(Icons.alarm_add),
                  onPressed: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: selectedTime != null
                          ? TimeOfDay.fromDateTime(selectedTime!)
                          : TimeOfDay.now(),
                    );
                    if (time != null) {
                      final now = DateTime.now();
                      selectedTime = DateTime(
                        now.year,
                        now.month,
                        now.day,
                        time.hour,
                        time.minute,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                // Cancel existing notification if any
                if (task.alarmTime != null) {
                  NotificationService.cancelNotification(task.id);
                }

                final updatedTask = Task(
                  id: task.id,
                  title: titleController.text,
                  description: descriptionController.text,
                  isCompleted: task.isCompleted,
                  alarmTime: selectedTime,
                );
                ref.read(taskListProvider.notifier).updateTask(updatedTask);

                // Schedule new notification if time is selected
                if (selectedTime != null) {
                  NotificationService.scheduleNotification(
                    taskId: updatedTask.id,
                    title: updatedTask.title,
                    description: updatedTask.description,
                    scheduleTime: selectedTime!,
                  );
                }
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: Key(task.id),
      onDismissed: (_) {
        ref.read(taskListProvider.notifier).deleteTask(task.id);
        if (task.alarmTime != null) {
          NotificationService.cancelNotification(task.id);
        }
      },
      child: ListTile(
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text(task.description),
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (_) {
            ref.read(taskListProvider.notifier).toggleTaskCompletion(task.id);
          },
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (task.alarmTime != null)
              Icon(Icons.alarm, color: Theme.of(context).primaryColor),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showEditTaskDialog(context, ref, task),
            ),
          ],
        ),
      ),
    );
  }
}
