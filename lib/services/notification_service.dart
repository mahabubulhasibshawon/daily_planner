import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static Future<void> initialize() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'task_alerts',
          channelName: 'Task Alerts',
          channelDescription: 'Notifications for task reminders',
          defaultColor: const Color(0xFF9D50DD),
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          // Removed soundSource to use default sound
          playSound: true,
          enableVibration: true,
        ),
      ],
    );

    await requestNotificationPermissions();
  }

  static Future<bool> requestNotificationPermissions() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();

    if (!isAllowed) {
      isAllowed = await AwesomeNotifications().requestPermissionToSendNotifications();
    }

    return isAllowed;
  }

  static Future<void> scheduleNotification({
    required String taskId,
    required String title,
    required String description,
    required DateTime scheduleTime,
  }) async {
    bool isAllowed = await requestNotificationPermissions();

    if (!isAllowed) {
      debugPrint('Notification permissions not granted');
      return;
    }

    if (scheduleTime.isBefore(DateTime.now())) {
      debugPrint('Cannot schedule notification for past time');
      return;
    }

    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: taskId.hashCode,
          channelKey: 'task_alerts',
          title: title,
          body: description,
          notificationLayout: NotificationLayout.Default,
        ),
        schedule: NotificationCalendar.fromDate(
          date: scheduleTime,
          allowWhileIdle: true,
          preciseAlarm: true,
        ),
      );
      debugPrint('Notification scheduled for $scheduleTime');
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  static Future<void> cancelNotification(String taskId) async {
    await AwesomeNotifications().cancel(taskId.hashCode);
  }
}