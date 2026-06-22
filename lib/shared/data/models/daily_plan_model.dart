/// 每日计划数据模型
/// 从WorkBuddy获取的每日计划数据结构
class DailyPlanModel {
  final String id;
  final DateTime date;
  final List<StudyTaskModel> studies;
  final List<ExerciseTaskModel> exercises;
  final List<MealPlanModel> meals;
  final DateTime? fetchedAt;

  DailyPlanModel({
    required this.id,
    required this.date,
    required this.studies,
    required this.exercises,
    required this.meals,
    this.fetchedAt,
  });

  factory DailyPlanModel.fromJson(Map<String, dynamic> json) {
    return DailyPlanModel(
      id: json['id'] ?? '',
      date: DateTime.parse(json['date']),
      studies: (json['studies'] as List?)
          ?.map((e) => StudyTaskModel.fromJson(e))
          .toList() ?? [],
      exercises: (json['exercises'] as List?)
          ?.map((e) => ExerciseTaskModel.fromJson(e))
          .toList() ?? [],
      meals: (json['meals'] as List?)
          ?.map((e) => MealPlanModel.fromJson(e))
          .toList() ?? [],
      fetchedAt: json['fetched_at'] != null
          ? DateTime.parse(json['fetched_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'studies': studies.map((e) => e.toJson()).toList(),
    'exercises': exercises.map((e) => e.toJson()).toList(),
    'meals': meals.map((e) => e.toJson()).toList(),
  };
}

/// 学习任务模型
class StudyTaskModel {
  final String id;
  final String title;
  final String description;
  final DateTime scheduledTime;
  final TaskPriority priority;
  final bool isCompleted;

  StudyTaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.scheduledTime,
    required this.priority,
    this.isCompleted = false,
  });

  factory StudyTaskModel.fromJson(Map<String, dynamic> json) {
    return StudyTaskModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      scheduledTime: DateTime.parse(json['scheduled_time']),
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => TaskPriority.normal,
      ),
      isCompleted: json['is_completed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'scheduled_time': scheduledTime.toIso8601String(),
    'priority': priority.name,
    'is_completed': isCompleted,
  };
}

/// 锻炼任务模型
class ExerciseTaskModel {
  final String id;
  final String title;
  final String exerciseType;
  final int targetCount;
  final int targetDuration;
  final DateTime scheduledTime;
  final ExerciseDifficulty difficulty;
  final bool isCompleted;

  ExerciseTaskModel({
    required this.id,
    required this.title,
    required this.exerciseType,
    required this.targetCount,
    required this.targetDuration,
    required this.scheduledTime,
    required this.difficulty,
    this.isCompleted = false,
  });

  factory ExerciseTaskModel.fromJson(Map<String, dynamic> json) {
    return ExerciseTaskModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      exerciseType: json['exercise_type'] ?? 'general',
      targetCount: json['target_count'] ?? 0,
      targetDuration: json['target_duration'] ?? 0,
      scheduledTime: DateTime.parse(json['scheduled_time']),
      difficulty: ExerciseDifficulty.values.firstWhere(
        (e) => e.name == json['difficulty'],
        orElse: () => ExerciseDifficulty.medium,
      ),
      isCompleted: json['is_completed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'exercise_type': exerciseType,
    'target_count': targetCount,
    'target_duration': targetDuration,
    'scheduled_time': scheduledTime.toIso8601String(),
    'difficulty': difficulty.name,
    'is_completed': isCompleted,
  };
}

/// 餐饮计划模型
class MealPlanModel {
  final String id;
  final MealType type;
  final String menu;
  final DateTime mealTime;

  MealPlanModel({
    required this.id,
    required this.type,
    required this.menu,
    required this.mealTime,
  });

  factory MealPlanModel.fromJson(Map<String, dynamic> json) {
    return MealPlanModel(
      id: json['id'] ?? '',
      type: MealType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MealType.dinner,
      ),
      menu: json['menu'] ?? '',
      mealTime: DateTime.parse(json['meal_time']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'menu': menu,
    'meal_time': mealTime.toIso8601String(),
  };
}

/// 任务优先级
enum TaskPriority {
  low,
  normal,
  high,
  urgent,
}

/// 锻炼难度
enum ExerciseDifficulty {
  easy,
  medium,
  hard,
}

/// 餐饮类型
enum MealType {
  breakfast,
  lunch,
  dinner,
  snack,
}

/// 通用任务模型（用于待办列表）
class TaskModel {
  final String id;
  final String title;
  final String description;
  final DateTime? dueDate;
  final String category;
  final bool isCompleted;

  TaskModel({
    required this.id,
    required this.title,
    this.description = '',
    this.dueDate,
    this.category = 'general',
    this.isCompleted = false,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'])
          : null,
      category: json['category'] ?? 'general',
      isCompleted: json['is_completed'] ?? false,
    );
  }
}
