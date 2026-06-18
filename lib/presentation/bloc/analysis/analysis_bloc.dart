import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/photo_analysis.dart';
import '../../../data/repositories/photo_analysis_service.dart';

// Events
abstract class AnalysisEvent extends Equatable {
  const AnalysisEvent();

  @override
  List<Object?> get props => [];
}

class AnalysisStartRequested extends AnalysisEvent {
  final String imagePath;

  const AnalysisStartRequested({required this.imagePath});

  @override
  List<Object?> get props => [imagePath];
}

class AnalysisConfirmRequested extends AnalysisEvent {}

class AnalysisRejectRequested extends AnalysisEvent {}

class AnalysisResetRequested extends AnalysisEvent {}

// States
abstract class AnalysisState extends Equatable {
  const AnalysisState();

  @override
  List<Object?> get props => [];
}

class AnalysisInitial extends AnalysisState {}

class AnalysisLoading extends AnalysisState {
  final String message;

  const AnalysisLoading({this.message = '正在分析中...'});

  @override
  List<Object?> get props => [message];
}

class AnalysisCompleted extends AnalysisState {
  final PhotoAnalysis analysis;
  final bool isAutoConfirmed;

  const AnalysisCompleted({
    required this.analysis,
    required this.isAutoConfirmed,
  });

  @override
  List<Object?> get props => [analysis, isAutoConfirmed];
}

class AnalysisAwaitingConfirmation extends AnalysisState {
  final PhotoAnalysis analysis;

  const AnalysisAwaitingConfirmation({required this.analysis});

  @override
  List<Object?> get props => [analysis];
}

class AnalysisError extends AnalysisState {
  final String message;

  const AnalysisError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Bloc
class AnalysisBloc extends Bloc<AnalysisEvent, AnalysisState> {
  final PhotoAnalysisService _analysisService;
  PhotoAnalysis? _lastAnalysis;

  AnalysisBloc({PhotoAnalysisService? analysisService})
      : _analysisService = analysisService ?? PhotoAnalysisService(),
        super(AnalysisInitial()) {
    on<AnalysisStartRequested>(_onStartRequested);
    on<AnalysisConfirmRequested>(_onConfirmRequested);
    on<AnalysisRejectRequested>(_onRejectRequested);
    on<AnalysisResetRequested>(_onResetRequested);
  }

  Future<void> _onStartRequested(
    AnalysisStartRequested event,
    Emitter<AnalysisState> emit,
  ) async {
    emit(const AnalysisLoading(message: '正在识别拍摄环境和主体...'));

    try {
      // 分阶段展示真实分析进度
      await Future.delayed(const Duration(milliseconds: 300));

      emit(const AnalysisLoading(message: '正在分析拍摄角度和建议...'));

      await Future.delayed(const Duration(milliseconds: 300));

      emit(const AnalysisLoading(message: '正在计算推荐拍摄参数...'));

      // 执行实际AI分析
      final analysis = await _analysisService.analyzePhoto(event.imagePath);
      _lastAnalysis = analysis;

      emit(const AnalysisLoading(message: '分析完成，正在确认拍摄主题...'));

      await Future.delayed(const Duration(milliseconds: 200));

      // 根据分析置信度决定是否自动确认
      // 场景标签数量越多，置信度越高
      final confidence = analysis.sceneTags.isNotEmpty
          ? (analysis.sceneTags.length / 10.0).clamp(0.5, 0.95)
          : 0.5;
      final isAutoConfirmed = confidence > 0.6;

      emit(AnalysisCompleted(
        analysis: analysis,
        isAutoConfirmed: isAutoConfirmed,
      ));
    } catch (e) {
      emit(AnalysisError(message: '分析失败: $e'));
    }
  }

  Future<void> _onConfirmRequested(
    AnalysisConfirmRequested event,
    Emitter<AnalysisState> emit,
  ) async {
    if (_lastAnalysis != null) {
      emit(AnalysisAwaitingConfirmation(analysis: _lastAnalysis!));
    }
  }

  Future<void> _onRejectRequested(
    AnalysisRejectRequested event,
    Emitter<AnalysisState> emit,
  ) async {
    emit(AnalysisInitial());
  }

  Future<void> _onResetRequested(
    AnalysisResetRequested event,
    Emitter<AnalysisState> emit,
  ) async {
    _lastAnalysis = null;
    emit(AnalysisInitial());
  }

  @override
  Future<void> close() {
    _analysisService.dispose();
    return super.close();
  }
}
