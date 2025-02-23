// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:intl/intl.dart';
//
// import '../models/task.dart';
// import '../providers/task_provider.dart';
// import '../widgets/weekly_calendar.dart';
// import '../services/notification_service.dart';
//
// final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());
//
// class HomeScreen extends ConsumerWidget {
//   const HomeScreen({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // Watching task list and selected date state from Riverpod providers
//     final taskList = ref.watch(taskListProvider);
//     final selectedDate = ref.watch(selectedDateProvider);
//
//     return Scaffold(
//       body: Column(
//         children: [
//           // Weekly calendar widget
//           WeeklyCalendar(
//             onDaySelected: (selectedDate) {
//               // Update selected date in Riverpod state
//               ref.read(selectedDateProvider.notifier).update((state) => selectedDate);
//             },
//             selectedDate: selectedDate,
//           ),
//           // const Divider(),
//           // Padding(
//           //   padding: const EdgeInsets.all(16.0),
//           //   child: Row(
//           //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           //     children: [
//           //       const Text(
//           //         'Tasks',
//           //         style: TextStyle(
//           //           fontSize: 24,
//           //           fontWeight: FontWeight.bold,
//           //         ),
//           //       ),
//           //       IconButton(
//           //         icon: const Icon(Icons.add),
//           //         onPressed: () {
//           //           _showAddTaskDialog(context, ref);
//           //         },
//           //       ),
//           //     ],
//           //   ),
//           // ),
//           // Displaying the list of tasks
//           Expanded(
//             child: taskList.isEmpty
//                 ? Center(child: Text('No tasks for ${DateFormat('MMM d').format(selectedDate)}'))
//                 : ListView.builder(
//               itemCount: taskList.length,
//               itemBuilder: (context, index) {
//                 final task = taskList[index];
//                 return ListTile(
//                   title: Text(task.title),
//                   subtitle: Text(task.description),
//                   trailing: IconButton(
//                     icon: const Icon(Icons.delete),
//                     onPressed: () {
//                       // Remove task
//                       ref.read(taskListProvider.notifier).deleteTask(task.id);
//                     },
//                   ),
//                   onTap: () {
//                     // Handle task details
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Method to show the task add dialog
//   void _showAddTaskDialog(BuildContext context, WidgetRef ref) {
//     final selectedDate = ref.read(selectedDateProvider);
//     final titleController = TextEditingController();
//     final descriptionController = TextEditingController();
//     DateTime? selectedTime;
//
//     // Set initial time to current selected date at current time
//     selectedTime = DateTime(
//       selectedDate.year,
//       selectedDate.month,
//       selectedDate.day,
//       TimeOfDay.now().hour,
//       TimeOfDay.now().minute,
//     );
//
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Add Task for ${DateFormat('MMM d').format(selectedDate)}'),
//         content: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 controller: titleController,
//                 decoration: const InputDecoration(
//                   labelText: 'Title',
//                   hintText: 'Enter task title',
//                 ),
//               ),
//               const SizedBox(height: 16),
//               TextField(
//                 controller: descriptionController,
//                 decoration: const InputDecoration(
//                   labelText: 'Description',
//                   hintText: 'Enter task description',
//                 ),
//                 maxLines: 3,
//               ),
//               const SizedBox(height: 16),
//               ListTile(
//                 title: const Text('Set Time'),
//                 trailing: IconButton(
//                   icon: const Icon(Icons.access_time),
//                   onPressed: () async {
//                     final time = await showTimePicker(
//                       context: context,
//                       initialTime: TimeOfDay.fromDateTime(selectedTime!),
//                     );
//                     if (time != null) {
//                       selectedTime = DateTime(
//                         selectedDate.year,
//                         selectedDate.month,
//                         selectedDate.day,
//                         time.hour,
//                         time.minute,
//                       );
//                     }
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               if (titleController.text.isNotEmpty && selectedTime != null) {
//                 final task = Task(
//                   id: DateTime.now().toString(),
//                   title: titleController.text,
//                   description: descriptionController.text,
//                   alarmTime: selectedTime,
//                 );
//                 // Add task to the list
//                 ref.read(taskListProvider.notifier).addTask(task);
//
//                 if (selectedTime != null) {
//                   // Schedule notification for the task
//                   NotificationService.scheduleNotification(
//                     taskId: task.id,
//                     title: task.title,
//                     description: task.description,
//                     scheduleTime: selectedTime!,
//                   );
//                 }
//                 Navigator.pop(context);
//               }
//             },
//             child: const Text('Add'),
//           ),
//         ],
//       ),
//     );
//   }
// }



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
}
