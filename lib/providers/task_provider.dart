import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart';

final taskBoxProvider = Provider<Box<Task>>((ref) {
  throw UnimplementedError();
});

final taskListProvider = StateNotifierProvider<TaskNotifier, List<Task>>((ref) {
  final box = ref.watch(taskBoxProvider);
  return TaskNotifier(box);
});

class TaskNotifier extends StateNotifier<List<Task>> {
  final Box<Task> _box;

  TaskNotifier(this._box) : super(_box.values.toList());

  Future<void> addTask(Task task) async {
    await _box.put(task.id, task);
    state = _box.values.toList();
  }

  Future<void> updateTask(Task task) async {
    await _box.put(task.id, task);
    state = _box.values.toList();
  }

  Future<void> deleteTask(String id) async {
    await _box.delete(id);
    state = _box.values.toList();
  }

  Future<void> toggleTaskCompletion(String id) async {
    final task = _box.get(id);
    if (task != null) {
      task.isCompleted = !task.isCompleted;
      await _box.put(id, task);
      state = _box.values.toList();
    }
  }
}
