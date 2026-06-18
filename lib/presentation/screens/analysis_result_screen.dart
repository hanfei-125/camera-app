import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/photo_analysis.dart';
import '../bloc/analysis/analysis_bloc.dart';

class AnalysisResultScreen extends StatelessWidget {
  const AnalysisResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AnalysisBloc, AnalysisState>(
      builder: (context, state) {
        if (state is AnalysisLoading) {
          return Scaffold(
            backgroundColor: AppTheme.backgroundColor,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'AI正在分析中，请稍候...',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          );
        }

        if (state is AnalysisCompleted) {
          return _AnalysisResultView(
            analysis: state.analysis,
            isAutoConfirmed: state.isAutoConfirmed,
          );
        }

        if (state is AnalysisAwaitingConfirmation) {
          return _ManualConfirmationView(analysis: state.analysis);
        }

        if (state is AnalysisError) {
          return Scaffold(
            appBar: AppBar(title: const Text('分析结果')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 60,
                    color: AppTheme.errorColor,
                  ),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('返回重试'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('分析结果')),
          body: const Center(child: Text('暂无分析结果')),
        );
      },
    );
  }
}

class _AnalysisResultView extends StatelessWidget {
  final PhotoAnalysis analysis;
  final bool isAutoConfirmed;

  const _AnalysisResultView({
    required this.analysis,
    required this.isAutoConfirmed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('AI分析结果'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Photo preview
            Card(
              clipBehavior: Clip.antiAlias,
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: Image.file(
                  File(analysis.imagePath),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported, size: 60),
                  ),
                ),
              ),
            )
                .animate()
                .fadeIn()
                .scale(begin: const Offset(0.95, 0.95)),

            const SizedBox(height: 16),

            // Auto-confirmed badge (if applicable)
            if (isAutoConfirmed)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.secondaryColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 16,
                      color: AppTheme.secondaryColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '已自动确认拍摄主题',
                      style: TextStyle(
                        color: AppTheme.secondaryColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(delay: 200.ms),

            const SizedBox(height: 16),

            // Scene recognition
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.auto_fix_high,
                            color: AppTheme.primaryColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '场景识别',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Subject type
                    _InfoRow(
                      label: '拍摄主体',
                      value: _getSubjectTypeName(analysis.subjectType),
                    ),
                    _InfoRow(
                      label: '环境类型',
                      value: _getEnvironmentName(analysis.environmentType),
                    ),
                    _InfoRow(
                      label: '光照条件',
                      value: _getLightLevelName(analysis.lightLevel),
                    ),

                    if (analysis.sceneTags.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: analysis.sceneTags.take(5).map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              tag,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            )
                .animate()
                .fadeIn(delay: 300.ms)
                .slideY(begin: 0.1, end: 0),

            const SizedBox(height: 16),

            // Shooting parameters
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.accentColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.camera,
                            color: AppTheme.accentColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '推荐拍摄参数',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _ParameterBox(
                            label: 'ISO',
                            value: analysis.recommendations.recommendedIso
                                .toString(),
                            icon: Icons.iso,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ParameterBox(
                            label: '快门',
                            value: analysis
                                .recommendations.recommendedShutterSpeed,
                            icon: Icons.shutter_speed,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ParameterBox(
                            label: '光圈',
                            value: analysis.recommendations.recommendedAperture,
                            icon: Icons.blur_circular,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
                .animate()
                .fadeIn(delay: 400.ms)
                .slideY(begin: 0.1, end: 0),

            const SizedBox(height: 16),

            // Angles
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.architecture,
                            color: Colors.purple,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '推荐拍摄角度',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...analysis.recommendations.suggestedAngles.map((angle) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              size: 16,
                              color: AppTheme.secondaryColor,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                angle,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            )
                .animate()
                .fadeIn(delay: 500.ms)
                .slideY(begin: 0.1, end: 0),

            const SizedBox(height: 16),

            // Poses (if applicable)
            if (analysis.recommendations.suggestedPoses.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.teal.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Colors.teal,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '推荐拍摄姿势',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...analysis.recommendations.suggestedPoses.map((pose) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                size: 16,
                                color: AppTheme.secondaryColor,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  pose,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: 600.ms)
                  .slideY(begin: 0.1, end: 0),

            const SizedBox(height: 16),

            // Composition
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.grid_on,
                            color: Colors.orange,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '构图建议',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      analysis.recommendations.compositionSuggestion,
                      style: const TextStyle(fontSize: 14, height: 1.5),
                    ),
                  ],
                ),
              ),
            )
                .animate()
                .fadeIn(delay: 700.ms)
                .slideY(begin: 0.1, end: 0),

            const SizedBox(height: 16),

            // Tips
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.lightbulb,
                            color: Colors.amber,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '拍摄小贴士',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...analysis.recommendations.tips.asMap().entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${entry.key + 1}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                entry.value,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            )
                .animate()
                .fadeIn(delay: 800.ms)
                .slideY(begin: 0.1, end: 0),

            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      context.read<AnalysisBloc>().add(AnalysisResetRequested());
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    child: const Text('重新分析'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/main-shot');
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt),
                        SizedBox(width: 8),
                        Text('开始正式拍摄'),
                      ],
                    ),
                  ),
                ),
              ],
            )
                .animate()
                .fadeIn(delay: 900.ms),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _getSubjectTypeName(SubjectType type) {
    switch (type) {
      case SubjectType.person:
        return '人物';
      case SubjectType.landscape:
        return '风景';
      case SubjectType.object:
        return '物品';
      case SubjectType.food:
        return '美食';
      case SubjectType.animal:
        return '动物';
      case SubjectType.building:
        return '建筑';
      default:
        return '未知';
    }
  }

  String _getEnvironmentName(EnvironmentType type) {
    switch (type) {
      case EnvironmentType.indoor:
        return '室内';
      case EnvironmentType.outdoor:
        return '室外';
      case EnvironmentType.studio:
        return '影棚';
      default:
        return '未知';
    }
  }

  String _getLightLevelName(LightLevel level) {
    switch (level) {
      case LightLevel.bright:
        return '明亮';
      case LightLevel.moderate:
        return '适中';
      case LightLevel.dim:
        return '昏暗';
      case LightLevel.veryDim:
        return '很暗';
      default:
        return '未知';
    }
  }
}

class _ManualConfirmationView extends StatelessWidget {
  final PhotoAnalysis analysis;

  const _ManualConfirmationView({required this.analysis});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('确认拍摄主题'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 80,
              color: AppTheme.secondaryColor,
            ),
            const SizedBox(height: 24),
            Text(
              'AI已识别拍摄主题',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              '拍摄主题: ${_getSubjectTypeName(analysis.subjectType)}\n环境: ${_getEnvironmentName(analysis.environmentType)}',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              '请确认是否正确，或返回重新拍摄',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      context.read<AnalysisBloc>().add(AnalysisRejectRequested());
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    child: const Text('重新拍摄'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<AnalysisBloc>().add(AnalysisConfirmRequested());
                      Navigator.pushReplacementNamed(context, '/main-shot');
                    },
                    child: const Text('确认并拍摄'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getSubjectTypeName(SubjectType type) {
    switch (type) {
      case SubjectType.person:
        return '人物';
      case SubjectType.landscape:
        return '风景';
      case SubjectType.object:
        return '物品';
      case SubjectType.food:
        return '美食';
      case SubjectType.animal:
        return '动物';
      case SubjectType.building:
        return '建筑';
      default:
        return '未知';
    }
  }

  String _getEnvironmentName(EnvironmentType type) {
    switch (type) {
      case EnvironmentType.indoor:
        return '室内';
      case EnvironmentType.outdoor:
        return '室外';
      case EnvironmentType.studio:
        return '影棚';
      default:
        return '未知';
    }
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ParameterBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _ParameterBox({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.15),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
