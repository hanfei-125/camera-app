# AI相机 - 智能拍照APP

## 项目概述

一款基于小米手机环境开发的AI智能拍照APP，能够根据拍摄环境和主体自动分析并推荐最佳拍摄参数。

## 功能特性

### 1. 用户登录
- 简洁的登录界面
- 用户名密码验证
- 演示模式（任意用户名+4位密码即可登录）

### 2. 环境与主题确认
登录完成后，弹出用户环境及拍照主题、主体确认按钮：

- 点击按钮显示"请拍摄照片主体及拍照环境"
- 拍摄完成后，AI自动分析照片确认拍摄主题
- 自动确认完成后，提示用户人工确认
- 用户可选择"确认"或"重新拍摄"

### 3. AI智能分析

基于"环境及主体照片"分析以下内容：

#### 场景识别
- 拍摄主体类型（人像/风景/物品/美食/动物/建筑）
- 环境类型（室内/室外/影棚）
- 光照条件（明亮/适中/昏暗/很暗）
- 场景标签自动识别

#### 推荐拍摄参数
- **ISO感光度**：根据光线条件自动推荐（50-3200）
- **快门速度**：根据拍摄场景推荐（1/1000 - 1/15）
- **光圈值**：根据拍摄类型推荐（f/1.4 - f/11）

#### 最佳拍摄角度
- 根据主体类型推荐最佳拍摄角度
- 明确说明需要避免的角度
- 提供专业的拍摄提示

#### 人物姿势建议
- 根据检测到的人体姿态推荐最佳姿势
- 提供多种可选姿势方案
- 面部表情和眼神建议

#### 构图建议
- 三分法、黄金分割等构图建议
- 根据场景类型定制化建议
- 前景引导线等专业技巧

### 4. 正式拍摄界面

- 实时相机预览
- 自动模式/手动模式切换
- 拍摄参数实时显示
- 可调节参数：
  - ISO感光度（50-3200）
  - 快门速度（1/1000 - 1/15）
  - 光圈值（f/1.4 - f/11）

## 技术架构

### 框架
- **Flutter 3.x**：跨平台UI框架
- **BLoC**：状态管理

### AI/ML能力
- **Google ML Kit**：图像标签、姿态检测、人脸检测
- **TensorFlow Lite**：本地AI推理（可选）

### 核心模块

```
lib/
├── core/
│   ├── theme/          # 主题配置
│   ├── constants/      # 常量定义
│   └── utils/          # 工具类
├── data/
│   ├── models/         # 数据模型
│   └── repositories/   # 数据仓库
│       └── photo_analysis_service.dart  # AI分析服务
├── domain/
│   └── entities/       # 领域实体
├── presentation/
│   ├── bloc/          # 状态管理
│   │   ├── auth/      # 认证状态
│   │   ├── camera/    # 相机状态
│   │   └── analysis/  # 分析状态
│   ├── screens/        # 页面
│   └── widgets/        # 组件
```

## 依赖包

```yaml
dependencies:
  flutter:
    sdk: flutter

  # UI
  cupertino_icons: ^1.0.6
  google_fonts: ^6.1.0
  flutter_animate: ^4.3.0

  # 相机功能
  camera: ^0.10.5+9
  image_picker: ^1.0.4

  # AI/ML
  google_mlkit_pose_detection: ^0.9.0
  google_mlkit_face_detection: ^0.9.0
  google_mlkit_image_labeling: ^0.9.0

  # 状态管理
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5

  # 权限
  permission_handler: ^11.0.1
```

## 安装运行

### 环境要求
- Flutter SDK 3.0+
- Android SDK 21+
- 小米手机（MIUI 12+）

### 运行步骤

1. 克隆项目
```bash
git clone <repo>
cd camera-app
```

2. 安装依赖
```bash
flutter pub get
```

3. 配置Android
```bash
# android/app/build.gradle 中确保 minSdkVersion >= 21
```

4. 运行应用
```bash
flutter run
```

## 权限说明

应用需要以下权限：
- **相机权限**：拍照和录像功能
- **存储权限**：保存照片到相册

## AI分析逻辑

### 场景识别流程

```
1. 接收环境照片
2. 并行执行多个AI模型检测：
   - 图像标签检测（场景分类）
   - 人体姿态检测（人物姿势）
   - 人脸检测（面部表情）
3. 综合分析结果
4. 生成推荐参数
```

### 参数推荐策略

| 条件 | ISO | 快门 | 光圈 | 说明 |
|------|-----|------|------|------|
| 强光 | 50-100 | 1/500+ | f/8-11 | 户外晴天 |
| 适中 | 200 | 1/250 | f/5.6 | 一般光线 |
| 昏暗 | 400 | 1/125 | f/4 | 室内阴天 |
| 很暗 | 800+ | 1/60 | f/2.8 | 夜景/暗光 |

### 主体类型适配

| 主体类型 | 推荐光圈 | 推荐快门 | 特殊建议 |
|---------|---------|---------|---------|
| 人像 | f/1.4-2.8 | 1/200+ | 背景虚化 |
| 风景 | f/8-11 | 任意 | 大景深 |
| 运动 | f/2.8 | 1/500+ | 高速凝固 |
| 美食 | f/2.8-4 | 任意 | 侧光照明 |

## 开发说明

### 添加新的AI模型

在 `photo_analysis_service.dart` 中扩展分析逻辑：

```dart
// 添加新的检测器
late CustomDetector _customDetector;

// 在分析流程中调用
final customResult = await _customDetector.processImage(inputImage);
```

### 自定义拍摄预设

在 `app_constants.dart` 中添加新的预设：

```dart
static const Map<String, ShootingPreset> customPresets = {
  'custom': ShootingPreset(
    name: '自定义',
    iso: 200,
    shutterSpeed: '1/250',
    aperture: 'f/4',
    description: '自定义场景',
  ),
};
```

## 版本历史

### v1.0.0 (2026-06-17)
- 初始版本
- 实现登录功能
- 实现环境确认流程
- 实现AI照片分析
- 实现拍摄参数推荐
- 实现正式拍摄界面

## 许可证

MIT License
