import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/models/daily_plan_model.dart';

/// WorkBuddy 数据服务
/// 负责从WorkBuddy获取每日计划数据
class WorkbuddyService {
  // TODO: 配置你的WorkBuddy API地址
  static const String _baseUrl = 'http://localhost:8765';
  
  final http.Client _client;
  
  WorkbuddyService({http.Client? client}) : _client = client ?? http.Client();
  
  /// 获取今日计划
  Future<DailyPlanModel?> getTodayPlan() async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/api/daily-plan'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return DailyPlanModel.fromJson(data);
      }
      return null;
    } catch (e) {
      // 网络错误或服务不可用
      print('WorkBuddy服务错误: $e');
      return null;
    }
  }
  
  /// 获取指定日期的计划
  Future<DailyPlanModel?> getPlanByDate(DateTime date) async {
    try {
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final response = await _client.get(
        Uri.parse('$_baseUrl/api/daily-plan?date=$dateStr'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return DailyPlanModel.fromJson(data);
      }
      return null;
    } catch (e) {
      print('WorkBuddy服务错误: $e');
      return null;
    }
  }
  
  /// 获取本周计划摘要
  Future<List<DailyPlanModel>> getWeekPlan() async {
    final plans = <DailyPlanModel>[];
    final now = DateTime.now();
    
    for (int i = 0; i < 7; i++) {
      final date = now.add(Duration(days: i));
      final plan = await getPlanByDate(date);
      if (plan != null) {
        plans.add(plan);
      }
    }
    
    return plans;
  }
  
  /// 获取待办事项列表
  Future<List<TaskModel>> getPendingTasks() async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/api/tasks/pending'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        return data.map((e) => TaskModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('获取待办事项错误: $e');
      return [];
    }
  }
  
  void dispose() {
    _client.close();
  }
}
