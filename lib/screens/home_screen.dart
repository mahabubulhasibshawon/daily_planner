// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../models/task.dart';
import '../services/notification_service.dart';
import '../widgets/task_tile.dart';
import '../widgets/weekly_calendar.dart';
import '../providers/task_provider.dart';
import 'package:intl/intl.dart';

final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(taskListProvider);
    final selectedDate = ref.watch(selectedDateProvider);

    // Filter tasks for the selected date
    final filteredTasks = tasks.where((task) {
      if (task.alarmTime == null) return false;

      return DateUtils.isSameDay(task.alarmTime!, selectedDate);
    }).toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            WeeklyCalendar(
              selectedDate: selectedDate,
              onDaySelected: (date) {
                ref.read(selectedDateProvider.notifier).state = date;
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    'Tasks for ${DateFormat('MMM d').format(selectedDate)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: filteredTasks.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.task_alt,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No tasks for ${DateFormat('MMMM d').format(selectedDate)}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                itemCount: filteredTasks.length,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, index) {
                  final task = filteredTasks[index];
                  return TaskTile(task: task);
                },
              ),
            ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => _showAddTaskDialog(context, ref),
      //   child: const Icon(Icons.add),
      // ),
    );
  }

  // void _showAddTaskDialog(BuildContext context, WidgetRef ref) {
  //   final selectedDate = ref.read(selectedDateProvider);
  //   final titleController = TextEditingController();
  //   final descriptionController = TextEditingController();
  //   DateTime? selectedTime;
  //
  //   // Set initial time to current selected date at current time
  //   selectedTime = DateTime(
  //     selectedDate.year,
  //     selectedDate.month,
  //     selectedDate.day,
  //     TimeOfDay.now().hour,
  //     TimeOfDay.now().minute,
  //   );
  //
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: Text('Add Task for ${DateFormat('MMM d').format(selectedDate)}'),
  //       content: SingleChildScrollView(
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             TextField(
  //               controller: titleController,
  //               decoration: const InputDecoration(
  //                 labelText: 'Title',
  //                 hintText: 'Enter task title',
  //               ),
  //             ),
  //             const SizedBox(height: 16),
  //             TextField(
  //               controller: descriptionController,
  //               decoration: const InputDecoration(
  //                 labelText: 'Description',
  //                 hintText: 'Enter task description',
  //               ),
  //               maxLines: 3,
  //             ),
  //             const SizedBox(height: 16),
  //             ListTile(
  //               title: const Text('Set Time'),
  //               trailing: IconButton(
  //                 icon: const Icon(Icons.access_time),
  //                 onPressed: () async {
  //                   final time = await showTimePicker(
  //                     context: context,
  //                     initialTime: TimeOfDay.fromDateTime(selectedTime!),
  //                   );
  //                   if (time != null) {
  //                     selectedTime = DateTime(
  //                       selectedDate.year,
  //                       selectedDate.month,
  //                       selectedDate.day,
  //                       time.hour,
  //                       time.minute,
  //                     );
  //                   }
  //                 },
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('Cancel'),
  //         ),
  //         TextButton(
  //           onPressed: () {
  //             if (titleController.text.isNotEmpty && selectedTime != null) {
  //               final task = Task(
  //                 id: DateTime.now().toString(),
  //                 title: titleController.text,
  //                 description: descriptionController.text,
  //                 alarmTime: selectedTime,
  //               );
  //               ref.read(taskListProvider.notifier).addTask(task);
  //
  //               if (selectedTime != null) {
  //                 NotificationService.scheduleNotification(
  //                   taskId: task.id,
  //                   title: task.title,
  //                   description: task.description,
  //                   scheduleTime: selectedTime!,
  //                 );
  //               }
  //               Navigator.pop(context);
  //             }
  //           },
  //           child: const Text('Add'),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
