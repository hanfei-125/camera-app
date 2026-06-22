/// 模块配置
/// 控制各功能模块的启用状态
class ModuleConfig {
  /// 智能拍照模块（核心功能，始终启用）
  static const bool cameraEnabled = true;

  /// 生活提醒模块
  static const bool reminderEnabled = true;

  /// 锻炼矫正模块（待开发）
  static const bool exerciseEnabled = false;

  /// 获取所有已启用的模块列表
  static List<String> get enabledModules {
    final modules = <String>[];
    if (cameraEnabled) modules.add('camera');
    if (reminderEnabled) modules.add('reminder');
    if (exerciseEnabled) modules.add('exercise');
    return modules;
  }

  /// 检查模块是否启用
  static bool isModuleEnabled(String moduleName) {
    switch (moduleName) {
      case 'camera':
        return cameraEnabled;
      case 'reminder':
        return reminderEnabled;
      case 'exercise':
        return exerciseEnabled;
      default:
        return false;
    }
  }
}
