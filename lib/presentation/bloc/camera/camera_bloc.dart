import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';

// Events
abstract class CameraEvent extends Equatable {
  const CameraEvent();

  @override
  List<Object?> get props => [];
}

class CameraInitializeRequested extends CameraEvent {}

class CameraCaptureRequested extends CameraEvent {
  final String imagePath;

  const CameraCaptureRequested({required this.imagePath});

  @override
  List<Object?> get props => [imagePath];
}

class CameraResetRequested extends CameraEvent {}

class CameraSwitchRequested extends CameraEvent {}

// States
abstract class CameraState extends Equatable {
  const CameraState();

  @override
  List<Object?> get props => [];
}

class CameraInitial extends CameraState {}

class CameraLoading extends CameraState {}

class CameraReady extends CameraState {
  final List<CameraDescription> cameras;
  final int currentCameraIndex;
  final CameraController? controller;

  const CameraReady({
    required this.cameras,
    required this.currentCameraIndex,
    this.controller,
  });

  @override
  List<Object?> get props => [cameras, currentCameraIndex];

  CameraDescription get currentCamera => cameras[currentCameraIndex];
  bool get isFrontCamera =>
      currentCamera.lensDirection == CameraLensDirection.front;
}

class CameraCapturing extends CameraState {}

class CameraCaptured extends CameraState {
  final String imagePath;

  const CameraCaptured({required this.imagePath});

  @override
  List<Object?> get props => [imagePath];
}

class CameraError extends CameraState {
  final String message;

  const CameraError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Bloc
class CameraBloc extends Bloc<CameraEvent, CameraState> {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  int _currentCameraIndex = 0;

  CameraBloc() : super(CameraInitial()) {
    on<CameraInitializeRequested>(_onInitializeRequested);
    on<CameraCaptureRequested>(_onCaptureRequested);
    on<CameraResetRequested>(_onResetRequested);
    on<CameraSwitchRequested>(_onSwitchRequested);
  }

  Future<void> _onInitializeRequested(
    CameraInitializeRequested event,
    Emitter<CameraState> emit,
  ) async {
    emit(CameraLoading());

    try {
      _cameras = await availableCameras();

      if (_cameras.isEmpty) {
        emit(const CameraError(message: '未检测到相机'));
        return;
      }

      // 优先使用后置摄像头
      _currentCameraIndex = _cameras.indexWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
      );
      if (_currentCameraIndex == -1) _currentCameraIndex = 0;

      await _initializeController(_currentCameraIndex);

      emit(CameraReady(
        cameras: _cameras,
        currentCameraIndex: _currentCameraIndex,
        controller: _controller,
      ));
    } catch (e) {
      emit(CameraError(message: '相机初始化失败: $e'));
    }
  }

  Future<void> _initializeController(int cameraIndex) async {
    await _controller?.dispose();

    _controller = CameraController(
      _cameras[cameraIndex],
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await _controller!.initialize();
  }

  Future<void> _onCaptureRequested(
    CameraCaptureRequested event,
    Emitter<CameraState> emit,
  ) async {
    emit(CameraCapturing());

    try {
      if (_controller == null || !_controller!.value.isInitialized) {
        emit(const CameraError(message: '相机未初始化'));
        return;
      }

      final XFile image = await _controller!.takePicture();
      emit(CameraCaptured(imagePath: image.path));
    } catch (e) {
      emit(CameraError(message: '拍照失败: $e'));
    }
  }

  Future<void> _onResetRequested(
    CameraResetRequested event,
    Emitter<CameraState> emit,
  ) async {
    emit(CameraReady(
      cameras: _cameras,
      currentCameraIndex: _currentCameraIndex,
      controller: _controller,
    ));
  }

  Future<void> _onSwitchRequested(
    CameraSwitchRequested event,
    Emitter<CameraState> emit,
  ) async {
    if (_cameras.length < 2) return;

    emit(CameraLoading());

    try {
      _currentCameraIndex = (_currentCameraIndex + 1) % _cameras.length;
      await _initializeController(_currentCameraIndex);

      emit(CameraReady(
        cameras: _cameras,
        currentCameraIndex: _currentCameraIndex,
        controller: _controller,
      ));
    } catch (e) {
      emit(CameraError(message: '切换相机失败: $e'));
    }
  }

  @override
  Future<void> close() {
    _controller?.dispose();
    return super.close();
  }
}
