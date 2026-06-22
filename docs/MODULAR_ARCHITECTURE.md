# 模块化架构设计文档 v1.5

## 文档信息

- **版本**: v1.0
- **日期**: 2026-06-22
- **状态**: 设计中
- **目标**: Phase 1.5 模块化拆分与重构

---

## 一、设计目标

### 1.1 核心目标
- 将现有单体内应用拆分为**模块化架构**
- 支持多模块并行开发与独立发布
- 统一数据层和提醒系统
- 为未来功能扩展预留充足空间

### 1.2 设计原则
1. **模块独立性**：每个模块可独立编译、测试、发布
2. **数据共享**：通过统一数据层共享用户数据
3. **接口清晰**：模块间通过定义好的接口通信
4. **按需加载**：用户未启用的模块不占用资源

---

## 二、模块划分

### 2.1 模块总览

```
┌─────────────────────────────────────────────────────────┐
│                     AI相机 APP (主应用)                   │
├─────────────────────────────────────────────────────────┤
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐      │
│  │ 智能拍照模块 │ │ 生活提醒模块 │ │ 锻炼矫正模块 │      │
│  │  (camera)   │ │  (reminder) │ │ (exercise)  │      │
│  └─────────────┘ └─────────────┘ └─────────────┘      │
├─────────────────────────────────────────────────────────┤
│                    共享层 (shared)                      │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐      │
│  │   数据层    │ │   提醒系统   │ │   认证层    │      │
│  │  (data)     │ │ (notification)│ │  (auth)    │      │
│  └─────────────┘ └─────────────┘ └─────────────┘      │
├─────────────────────────────────────────────────────────┤
│                    Flutter 框架                         │
└─────────────────────────────────────────────────────────┘
```

### 2.2 模块详情

#### 模块 A: 智能拍照模块 (camera_module)
**功能**: 现有AI拍照功能的模块化封装

| 项目 | 说明 |
|------|------|
| 依赖 | ML Kit (图像标签/姿态/人脸) |
| 页面 | 登录、环境确认、相机、AI分析、正式拍摄 |
| 状态 | 已完成，等待重构 |
| 独立性 | 高（核心功能） |

#### 模块 B: 生活提醒模块 (reminder_module)
**功能**: 从WorkBuddy获取每日计划，生成提醒

| 项目 | 说明 |
|------|------|
| 依赖 | WorkBuddy数据接口 |
| 页面 | 提醒列表、提醒详情、设置 |
| 状态 | 新开发 |
| 独立性 | 中（依赖WorkBuddy） |

#### 模块 C: 锻炼矫正模块 (exercise_module)
**功能**: AI实时姿势检测与矫正建议

| 项目 | 说明 |
|------|------|
| 依赖 | ML Kit (姿态检测) |
| 页面 | 锻炼选择、实时监控、记录统计 |
| 状态**: 新开发 |
| 独立性 | 中（依赖相机） |

---

## 三、项目结构设计

### 3.1 整体目录结构

```
camera-app/
├── lib/
│   ├── main.dart                    # 应用入口
│   │
│   ├── app/                         # 应用配置
│   │   ├── app.dart                 # MaterialApp 配置
│   │   ├── routes.dart              # 路由配置
│   │   └── di.dart                  # 依赖注入
│   │
│   ├── shared/                      # 共享层（所有模块共用）
│   │   ├── core/                    # 核心工具
│   │   │   ├── theme/              # 主题配置
│   │   │   ├── constants/          # 常量定义
│   │   │   ├── utils/             # 工具函数
│   │   │   └── extensions/         # 扩展方法
│   │   │
│   │   ├── data/                   # 数据层
│   │   │   ├── repositories/      # 数据仓库
│   │   │   │   ├── user_repository.dart
│   │   │   │   ├── settings_repository.dart
│   │   │   │   └── workbuddy_repository.dart
│   │   │   ├── datasources/        # 数据源
│   │   │   │   ├── local/         # 本地数据
│   │   │   │   └── remote/        # 远程数据
│   │   │   └── models/            # 数据模型
│   │   │       ├── user_model.dart
│   │   │       ├── reminder_model.dart
│   │   │       └── exercise_model.dart
│   │   │
│   │   ├── services/               # 公共服务
│   │   │   ├── notification_service.dart    # 统一提醒服务
│   │   │   ├── storage_service.dart        # 本地存储
│   │   │   └── workbuddy_service.dart      # WorkBuddy数据接口
│   │   │
│   │   └── widgets/               # 共享组件
│   │       ├── app_card.dart
│   │       ├── app_button.dart
│   │       └── loading_widget.dart
│   │
│   ├── modules/                   # 功能模块
│   │   ├── camera/               # 智能拍照模块
│   │   │   ├── camera_module.dart
│   │   │   ├── data/
│   │   │   │   ├── repositories/
│   │   │   │   └── services/
│   │   │   ├── domain/
│   │   │   │   └── entities/
│   │   │   └── presentation/
│   │   │       ├── bloc/
│   │   │       ├── screens/
│   │   │       └── widgets/
│   │   │
│   │   ├── reminder/             # 生活提醒模块
│   │   │   ├── reminder_module.dart
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │
│   │   └── exercise/             # 锻炼矫正模块
│   │       ├── exercise_module.dart
│   │       ├── data/
│   │       ├── domain/
│   │       └── presentation/
│   │
│   └── routes/                    # 路由（可选）
│       └── app_routes.dart
│
├── pubspec.yaml
└── README.md
```

### 3.2 依赖关系图

```
┌────────────────────────────────────────────────────────────┐
│                        main.dart                          │
└────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌────────────────────────────────────────────────────────────┐
│                       app.dart                            │
│              (MultiBlocProvider + 路由配置)                 │
└────────────────────────────────────────────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
        ▼                     ▼                     ▼
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   Camera     │     │   Reminder   │     │   Exercise   │
│   Module     │     │   Module     │     │   Module     │
└──────────────┘     └──────────────┘     └──────────────┘
        │                     │                     │
        └─────────────────────┼─────────────────────┘
                              │
                              ▼
┌────────────────────────────────────────────────────────────┐
│                      Shared Layer                          │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐ │
│  │ Services │  │   Data   │  │  Core    │  │ Widgets  │ │
│  │          │  │          │  │          │  │          │ │
│  │Notifica- │  │Repositories│  │ Theme   │  │AppCard  │ │
│  │tion      │  │ Models   │  │ Constants│  │AppButton│ │
│  │Storage   │  │          │  │ Utils   │  │Loading  │ │
│  │Workbuddy │  │          │  │         │  │         │ │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘ │
└────────────────────────────────────────────────────────────┘
```

---

## 四、数据层设计

### 4.1 WorkBuddy数据接口

#### 接口概述
```
WorkBuddy API (云端) ←→ WorkBuddy Service (本地) ←→ Reminder Module
```

#### 数据类型

```dart
// 1. 每日计划数据
class DailyPlan {
  final String id;
  final DateTime date;
  final List<StudyTask> studies;    // 学习任务
  final List<ExerciseTask> exercises; // 锻炼任务
  final List<MealPlan> meals;       // 餐饮计划
}

// 2. 学习任务
class StudyTask {
  final String id;
  final String title;
  final String description;
  final DateTime scheduledTime;
  final TaskPriority priority;
  final bool isCompleted;
}

// 3. 锻炼任务
class ExerciseTask {
  final String id;
  final String title;           // 如"俯卧撑"
  final int targetCount;        // 目标次数
  final int targetDuration;     // 目标时长(秒)
  final DateTime scheduledTime;
  final ExerciseDifficulty difficulty;
}

// 4. 餐饮计划
class MealPlan {
  final String id;
  final MealType type;          // breakfast/lunch/dinner
  final String menu;
  final DateTime mealTime;
}
```

### 4.2 数据流向

```
┌─────────────────┐
│  WorkBuddy     │
│  自动化任务     │
│  (云端)         │
└────────┬────────┘
         │ 定时拉取 / Webhook
         │
         ▼
┌─────────────────┐
│ WorkBuddy       │
│ Service         │
│ (本地数据接口)   │
└────────┬────────┘
         │
    ┌────┴────┐
    │         │
    ▼         ▼
┌────────┐ ┌────────┐
│Reminder│ │Exercise│
│Module  │ │Module  │
└────────┘ └────────┘
    │         │
    └────┬────┘
         │
         ▼
┌─────────────────┐
│ Notification    │
│ Service         │
│ (统一提醒)      │
└─────────────────┘
```

---

## 五、提醒系统设计

### 5.1 统一提醒架构

```dart
class NotificationService {
  // 发送提醒
  Future<void> sendReminder(Reminder reminder);
  
  // 发送拍照提醒
  Future<void> sendPhotoReminder(PhotoReminder reminder);
  
  // 发送学习提醒
  Future<void> sendStudyReminder(StudyReminder reminder);
  
  // 发送锻炼提醒
  Future<void> sendExerciseReminder(ExerciseReminder reminder);
  
  // 取消提醒
  Future<void> cancelReminder(String reminderId);
  
  // 更新提醒
  Future<void> updateReminder(Reminder reminder);
  
  // 获取今日提醒列表
  Future<List<Reminder>> getTodayReminders();
}
```

### 5.2 提醒类型

| 类型 | 来源 | 内容示例 |
|------|------|---------|
| photo_reminder | 拍照模块 | "最佳拍摄时机：黄金时段" |
| study_reminder | WorkBuddy | "学习时间到：PLC编程练习" |
| exercise_reminder | WorkBuddy | "锻炼时间：俯卧撑3组x15次" |
| meal_reminder | WorkBuddy | "午餐时间到了" |

### 5.3 提醒优先级

```dart
enum ReminderPriority {
  low,      // 低优先级（默认）
  normal,    // 普通
  high,      // 高优先级
  urgent,    // 紧急
}
```

---

## 六、模块配置

### 6.1 模块启用状态

```dart
class ModuleConfig {
  static const cameraEnabled = true;   // 拍照模块（核心，始终启用）
  static const reminderEnabled = true; // 提醒模块
  static const exerciseEnabled = false; // 锻炼模块（待开发）
}

// 用户可在设置中开关非核心模块
```

### 6.2 模块初始化

```dart
// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化共享服务
  await initSharedServices();
  
  // 根据配置初始化模块
  if (ModuleConfig.reminderEnabled) {
    await initReminderModule();
  }
  if (ModuleConfig.exerciseEnabled) {
    await initExerciseModule();
  }
  
  runApp(App());
}
```

---

## 七、实现计划

### 阶段 1: 架构重构（本周）
- [ ] 创建 shared 层目录结构
- [ ] 迁移核心主题和常量到 shared
- [ ] 创建统一提醒服务
- [ ] 创建 WorkBuddy 数据接口

### 阶段 2: 拍照模块重构（下周）
- [ ] 将现有拍照功能封装为独立模块
- [ ] 适配新的数据层
- [ ] 适配新的提醒服务

### 阶段 3: 提醒模块开发
- [ ] 实现 WorkBuddy 数据拉取
- [ ] 开发提醒列表页面
- [ ] 集成统一提醒系统

### 阶段 4: 锻炼模块开发
- [ ] 设计姿势检测逻辑
- [ ] 开发实时监控页面
- [ ] 实现矫正建议功能

---

## 八、技术选型

### 8.1 状态管理
- **方案**: Riverpod 2.0
- **理由**: 
  - 编译时安全
  - 更好的依赖注入
  - 模块化友好
  - 官方推荐

### 8.2 路由方案
- **方案**: GoRouter
- **理由**:
  - 声明式路由
  - 深层链接支持
  - 模块化路由配置

### 8.3 本地存储
- **方案**: Hive + SharedPreferences
- **理由**:
  - Hive: 结构化数据
  - SharedPreferences: 简单配置

### 8.4 提醒推送
- **方案**: flutter_local_notifications
- **理由**:
  - Android原生支持
  - 定时提醒支持
  - 按渠道分组

---

## 九、注意事项

### 9.1 WorkBuddy数据安全
- 敏感数据使用加密存储
- API调用使用HTTPS
- 定期刷新Token

### 9.2 模块解耦
- 模块间不直接依赖
- 通过接口和事件通信
- 避免循环依赖

### 9.3 性能优化
- 按需加载模块
- 懒加载非核心页面
- 图片缓存优化

---

*文档结束 - 待更新*
