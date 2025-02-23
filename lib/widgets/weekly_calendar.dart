// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
//
// import '../models/task.dart';
// import '../providers/task_provider.dart';
// import '../screens/home_screen.dart';
// import '../services/notification_service.dart';
//
// // This provider will handle the dates we need to display in the calendar
// final dateListProvider = Provider<List<DateTime>>((ref) {
//   final today = DateTime.now();
//   final List<DateTime> dateList = [];
//
//   // Add previous 7 days
//   for (int i = 7; i > 0; i--) {
//     dateList.add(today.subtract(Duration(days: i)));
//   }
//   // Add today
//   dateList.add(today);
//   // Add next 7 days
//   for (int i = 1; i <= 7; i++) {
//     dateList.add(today.add(Duration(days: i)));
//   }
//   return dateList;
// });
//
// class WeeklyCalendar extends ConsumerWidget {
//   final Function(DateTime) onDaySelected;
//   final DateTime selectedDate;
//
//   const WeeklyCalendar({
//     Key? key,
//     required this.onDaySelected,
//     required this.selectedDate,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final dates = ref.watch(dateListProvider);
//     final today = DateTime.now();
//
//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Today',
//                     style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   Text(
//                     DateFormat('MMMM, yyyy').format(selectedDate),
//                     style: TextStyle(
//                       color: Colors.grey[600],
//                       fontSize: 16,
//                     ),
//                   ),
//                 ],
//               ),
//               FloatingActionButton.extended(
//                 onPressed: () => _showAddTaskDialog(context, ref),
//                 label: const Text('Add Task'),
//                 icon: const Icon(Icons.add),
//               ),
//             ],
//           ),
//         ),
//         Container(
//           height: 90,
//           margin: const EdgeInsets.symmetric(vertical: 16),
//           child: ShaderMask(
//             shaderCallback: (Rect bounds) {
//               return LinearGradient(
//                 begin: Alignment.centerLeft,
//                 end: Alignment.centerRight,
//                 colors: [
//                   Colors.white.withOpacity(0.0),
//                   Colors.white,
//                   Colors.white,
//                   Colors.white.withOpacity(0.0),
//                 ],
//                 stops: const [0.0, 0.05, 0.95, 1.0],
//               ).createShader(bounds);
//             },
//             blendMode: BlendMode.dstIn,
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               itemCount: dates.length,
//               itemBuilder: (context, index) {
//                 final date = dates[index];
//                 return _buildDayCell(context, date, selectedDate);
//               },
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildDayCell(BuildContext context, DateTime date, DateTime selectedDate) {
//     final isSelected = DateUtils.isSameDay(date, selectedDate);
//     final isToday = DateUtils.isSameDay(date, DateTime.now());
//     final dayName = DateFormat('E').format(date);
//     final dayNumber = date.day.toString();
//
//     return GestureDetector(
//       onTap: () => onDaySelected(date),
//       child: Container(
//         width: 60,
//         margin: const EdgeInsets.symmetric(horizontal: 4),
//         decoration: BoxDecoration(
//           color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               dayName,
//               style: TextStyle(
//                 color: isSelected ? Colors.white : Colors.grey,
//                 fontSize: 12,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Container(
//               width: 36,
//               height: 36,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: isToday && !isSelected
//                     ? Theme.of(context).primaryColor.withOpacity(0.1)
//                     : null,
//                 border: isToday && !isSelected
//                     ? Border.all(
//                   color: Theme.of(context).primaryColor,
//                   width: 2,
//                 )
//                     : null,
//               ),
//               child: Center(
//                 child: Text(
//                   dayNumber,
//                   style: TextStyle(
//                     color: isSelected
//                         ? Colors.white
//                         : isToday
//                         ? Theme.of(context).primaryColor
//                         : Colors.black,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
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
//                 ref.read(taskListProvider.notifier).addTask(task);
//
//                 if (selectedTime != null) {
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



// lib/widgets/weekly_calendar.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../models/task.dart';
import '../providers/task_provider.dart';
import '../screens/home_screen.dart';
import '../services/notification_service.dart';

class WeeklyCalendar extends HookConsumerWidget {
  final Function(DateTime) onDaySelected;
  final DateTime selectedDate;

  const WeeklyCalendar({
    Key? key,
    required this.onDaySelected,
    required this.selectedDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = DateTime.now();
    final scrollController = useScrollController();

    // Generate 15 days (7 days before today, today, and 7 days after)
    final dates = useMemoized(() {
      final List<DateTime> dateList = [];
      // Add previous 7 days
      for (int i = 7; i > 0; i--) {
        dateList.add(today.subtract(Duration(days: i)));
      }
      // Add today
      dateList.add(today);
      // Add next 7 days
      for (int i = 1; i <= 7; i++) {
        dateList.add(today.add(Duration(days: i)));
      }
      return dateList;
    }, [today]);

    // Scroll to center (today) when first built
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Calculate the scroll position to center today
        // Assuming each date cell has a width of 60 (including margins)
        final centerPosition = (7 * 43).toDouble();
        scrollController.jumpTo(centerPosition);
      });
      return null;
    }, []);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Today',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    DateFormat('MMMM, yyyy').format(selectedDate),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              FloatingActionButton.extended(
                onPressed: () => _showAddTaskDialog(context, ref),
                label: const Text('Add Task'),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ),
        Container(
          height: 90,
          margin: const EdgeInsets.symmetric(vertical: 16),
          child: ShaderMask(
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.white.withOpacity(0.0),
                  Colors.white,
                  Colors.white,
                  Colors.white.withOpacity(0.0),
                ],
                stops: const [0.0, 0.05, 0.95, 1.0],
              ).createShader(bounds);
            },
            blendMode: BlendMode.dstIn,
            child: ListView.builder(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: dates.length,
              itemBuilder: (context, index) {
                final date = dates[index];
                return _buildDayCell(context, date);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDayCell(BuildContext context, DateTime date) {
    final isSelected = DateUtils.isSameDay(date, selectedDate);
    final isToday = DateUtils.isSameDay(date, DateTime.now());
    final dayName = DateFormat('E').format(date);
    final dayNumber = date.day.toString();

    return GestureDetector(
      onTap: () => onDaySelected(date),
      child: Container(
        width: 60,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dayName,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isToday && !isSelected
                    ? Theme.of(context).primaryColor.withOpacity(0.1)
                    : null,
                border: isToday && !isSelected
                    ? Border.all(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                )
                    : null,
              ),
              child: Center(
                child: Text(
                  dayNumber,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : isToday
                        ? Theme.of(context).primaryColor
                        : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.read(selectedDateProvider);
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime? selectedTime;

    // Set initial time to current selected date at current time
    selectedTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      TimeOfDay.now().hour,
      TimeOfDay.now().minute,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Task for ${DateFormat('MMM d').format(selectedDate)}'),
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
                title: const Text('Set Time'),
                trailing: IconButton(
                  icon: const Icon(Icons.access_time),
                  onPressed: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(selectedTime!),
                    );
                    if (time != null) {
                      selectedTime = DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
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
              if (titleController.text.isNotEmpty && selectedTime != null) {
                final task = Task(
                  id: DateTime.now().toString(),
                  title: titleController.text,
                  description: descriptionController.text,
                  alarmTime: selectedTime,
                );
                ref.read(taskListProvider.notifier).addTask(task);

                if (selectedTime != null) {
                  NotificationService.scheduleNotification(
                    taskId: task.id,
                    title: task.title,
                    description: task.description,
                    scheduleTime: selectedTime!,
                  );
                }
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}