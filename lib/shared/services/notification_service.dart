import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

/// 提醒优先级
enum ReminderPriority {
  low,
  normal,
  high,
  urgent,
}

/// 提醒类型
enum ReminderType {
  photo,     // 拍照提醒
  study,     // 学习提醒
  exercise,  // 锻炼提醒
  meal,      // 餐饮提醒
  general,   // 一般提醒
}

/// 统一提醒模型
class Reminder {
  final String id;
  final String title;
  final String body;
  final ReminderType type;
  final ReminderPriority priority;
  final DateTime scheduledTime;
  final Map<String, dynamic>? payload;

  Reminder({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.priority = ReminderPriority.normal,
    required this.scheduledTime,
    this.payload,
  });
}

/// 统一提醒服务
/// 管理APP内所有类型的提醒
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// 初始化提醒服务
  Future<void> init() async {
    if (_isInitialized) return;

    // 初始化时区
    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _isInitialized = true;
  }

  /// 通知点击回调
  void _onNotificationTap(NotificationResponse response) {
    // 处理通知点击事件
    // 可以根据 payload 导航到对应页面
    final payload = response.payload;
    if (payload != null) {
      print('通知点击: $payload');
    }
  }

  /// 发送提醒
  Future<void> sendReminder(Reminder reminder) async {
    await _ensureInitialized();

    final androidDetails = AndroidNotificationDetails(
      _getChannelId(reminder.type),
      _getChannelName(reminder.type),
      channelDescription: _getChannelDescription(reminder.type),
      importance: _getImportance(reminder.priority),
      priority: _getPriority(reminder.priority),
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      reminder.id.hashCode,
      reminder.title,
      reminder.body,
      details,
      payload: reminder.payload?.toString(),
    );
  }

  /// 发送定时提醒
  Future<void> scheduleReminder(Reminder reminder) async {
    await _ensureInitialized();

    final androidDetails = AndroidNotificationDetails(
      _getChannelId(reminder.type),
      _getChannelName(reminder.type),
      channelDescription: _getChannelDescription(reminder.type),
      importance: _getImportance(reminder.priority),
      priority: _getPriority(reminder.priority),
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      reminder.id.hashCode,
      reminder.title,
      reminder.body,
      tz.TZDateTime.from(reminder.scheduledTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: reminder.payload?.toString(),
    );
  }

  /// 发送拍照提醒
  Future<void> sendPhotoReminder({
    required String message,
    DateTime? scheduledTime,
  }) async {
    final reminder = Reminder(
      id: 'photo_${DateTime.now().millisecondsSinceEpoch}',
      title: '📷 智能拍照',
      body: message,
      type: ReminderType.photo,
      priority: ReminderPriority.normal,
      scheduledTime: scheduledTime ?? DateTime.now(),
    );

    if (scheduledTime != null) {
      await scheduleReminder(reminder);
    } else {
      await sendReminder(reminder);
    }
  }

  /// 发送学习提醒
  Future<void> sendStudyReminder({
    required String taskTitle,
    DateTime? scheduledTime,
  }) async {
    final reminder = Reminder(
      id: 'study_${DateTime.now().millisecondsSinceEpoch}',
      title: '📚 学习提醒',
      body: taskTitle,
      type: ReminderType.study,
      priority: ReminderPriority.normal,
      scheduledTime: scheduledTime ?? DateTime.now(),
    );

    if (scheduledTime != null) {
      await scheduleReminder(reminder);
    } else {
      await sendReminder(reminder);
    }
  }

  /// 发送锻炼提醒
  Future<void> sendExerciseReminder({
    required String exerciseTitle,
    required int targetCount,
    DateTime? scheduledTime,
  }) async {
    final reminder = Reminder(
      id: 'exercise_${DateTime.now().millisecondsSinceEpoch}',
      title: '💪 锻炼时间',
      body: '$exerciseTitle - 目标: $targetCount次',
      type: ReminderType.exercise,
      priority: ReminderPriority.high,
      scheduledTime: scheduledTime ?? DateTime.now(),
    );

    if (scheduledTime != null) {
      await scheduleReminder(reminder);
    } else {
      await sendReminder(reminder);
    }
  }

  /// 发送餐饮提醒
  Future<void> sendMealReminder({
    required String mealType,
    required String menu,
    DateTime? scheduledTime,
  }) async {
    final reminder = Reminder(
      id: 'meal_${DateTime.now().millisecondsSinceEpoch}',
      title: '🍽️ $mealType 时间到',
      body: menu,
      type: ReminderType.meal,
      priority: ReminderPriority.low,
      scheduledTime: scheduledTime ?? DateTime.now(),
    );

    if (scheduledTime != null) {
      await scheduleReminder(reminder);
    } else {
      await sendReminder(reminder);
    }
  }

  /// 取消提醒
  Future<void> cancelReminder(String reminderId) async {
    await _notifications.cancel(reminderId.hashCode);
  }

  /// 取消所有提醒
  Future<void> cancelAllReminders() async {
    await _notifications.cancelAll();
  }

  /// 获取待发送的提醒数
  Future<List<PendingNotificationRequest>> getPendingReminders() async {
    return await _notifications.pendingNotificationRequests();
  }

  // ==================== 私有方法 ====================

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await init();
    }
  }

  String _getChannelId(ReminderType type) {
    switch (type) {
      case ReminderType.photo:
        return 'photo_reminders';
      case ReminderType.study:
        return 'study_reminders';
      case ReminderType.exercise:
        return 'exercise_reminders';
      case ReminderType.meal:
        return 'meal_reminders';
      case ReminderType.general:
        return 'general_reminders';
    }
  }

  String _getChannelName(ReminderType type) {
    switch (type) {
      case ReminderType.photo:
        return '拍照提醒';
      case ReminderType.study:
        return '学习提醒';
      case ReminderType.exercise:
        return '锻炼提醒';
      case ReminderType.meal:
        return '餐饮提醒';
      case ReminderType.general:
        return '一般提醒';
    }
  }

  String _getChannelDescription(ReminderType type) {
    switch (type) {
      case ReminderType.photo:
        return '智能拍照相关提醒';
      case ReminderType.study:
        return '学习任务提醒';
      case ReminderType.exercise:
        return '锻炼计划提醒';
      case ReminderType.meal:
        return '餐饮时间提醒';
      case ReminderType.general:
        return '一般通知';
    }
  }

  Importance _getImportance(ReminderPriority priority) {
    switch (priority) {
      case ReminderPriority.low:
        return Importance.low;
      case ReminderPriority.normal:
        return Importance.defaultImportance;
      case ReminderPriority.high:
        return Importance.high;
      case ReminderPriority.urgent:
        return Importance.max;
    }
  }

  Priority _getPriority(ReminderPriority priority) {
    switch (priority) {
      case ReminderPriority.low:
        return Priority.low;
      case ReminderPriority.normal:
        return Priority.defaultPriority;
      case ReminderPriority.high:
        return Priority.high;
      case ReminderPriority.urgent:
        return Priority.max;
    }
  }
}
