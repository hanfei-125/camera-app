import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import '../../domain/entities/photo_analysis.dart';

/// 智能拍照分析服务
/// 基于Google ML Kit实现场景识别、姿态检测、人脸检测
/// 自动推荐最佳拍摄参数
class PhotoAnalysisService {
  late ImageLabeler _imageLabeler;
  late PoseDetector _poseDetector;
  late FaceDetector _faceDetector;

  PhotoAnalysisService() {
    // 图像标签检测器 - 识别场景和物体
    final ImageLabelerOptions labelOptions = ImageLabelerOptions(
      confidenceThreshold: 0.5,
    );
    _imageLabeler = ImageLabeler(options: labelOptions);

    // 姿态检测器 - 检测人体姿态
    final PoseDetectorOptions poseOptions = PoseDetectorOptions(
      mode: PoseDetectionMode.single,
      model: PoseDetectionModel.base,
    );
    _poseDetector = PoseDetector(options: poseOptions);

    // 人脸检测器 - 检测人脸特征和表情
    final FaceDetectorOptions faceOptions = FaceDetectorOptions(
      enableLandmarks: true,
      enableClassification: true,
      performanceMode: FaceDetectorMode.accurate,
    );
    _faceDetector = FaceDetector(options: faceOptions);
  }

  /// 分析照片并返回拍摄建议
  Future<PhotoAnalysis> analyzePhoto(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final file = File(imagePath);

    if (!await file.exists()) {
      throw Exception('图片文件不存在: $imagePath');
    }

    // 并行执行所有检测任务以提高性能
    final results = await Future.wait([
      _imageLabeler.processImage(inputImage),  // 场景标签
      _processPose(inputImage),                // 人体姿态
      _processFaces(inputImage),               // 人脸检测
      _analyzeEnvironment(file),              // 环境分析
    ]);

    final labels = results[0] as List<ImageLabel>;
    final poseData = results[1] as PoseData?;
    final faceData = results[2] as FaceData?;
    final envData = results[3] as EnvironmentData;

    // 综合分析所有数据生成最终推荐
    return _synthesizeAnalysis(
      imagePath: imagePath,
      labels: labels,
      poseData: poseData,
      faceData: faceData,
      envData: envData,
    );
  }

  /// 处理姿态检测
  Future<PoseData?> _processPose(InputImage image) async {
    try {
      final poses = await _poseDetector.processImage(image);
      if (poses.isEmpty) return null;

      final pose = poses.first;
      final landmarks = <String, PoseLandmark>{};

      // 提取关键身体部位
      for (final landmark in pose.landmarks.values) {
        if (_isImportantLandmark(landmark.type)) {
          landmarks[landmark.type.name] = landmark;
        }
      }

      return PoseData(
        detected: true,
        landmarks: landmarks,
        confidence: pose.confidence,
      );
    } catch (e) {
      return null;
    }
  }

  /// 判断是否为重要身体部位
  bool _isImportantLandmark(PoseLandmarkType type) {
    const importantTypes = [
      PoseLandmarkType.leftShoulder,
      PoseLandmarkType.rightShoulder,
      PoseLandmarkType.leftElbow,
      PoseLandmarkType.rightElbow,
      PoseLandmarkType.leftWrist,
      PoseLandmarkType.rightWrist,
      PoseLandmarkType.leftHip,
      PoseLandmarkType.rightHip,
      PoseLandmarkType.leftKnee,
      PoseLandmarkType.rightKnee,
      PoseLandmarkType.leftAnkle,
      PoseLandmarkType.rightAnkle,
      PoseLandmarkType.nose,
    ];
    return importantTypes.contains(type);
  }

  /// 处理人脸检测
  Future<FaceData?> _processFaces(InputImage image) async {
    try {
      final faces = await _faceDetector.processImage(image);
      if (faces.isEmpty) return null;

      final face = faces.first;
      final landmarks = <String, dynamic>{};

      // 提取表情和特征数据
      if (face.smilingProbability != null) {
        landmarks['smiling'] = face.smilingProbability;
      }
      if (face.leftEyeOpenProbability != null) {
        landmarks['leftEyeOpen'] = face.leftEyeOpenProbability;
      }
      if (face.rightEyeOpenProbability != null) {
        landmarks['rightEyeOpen'] = face.rightEyeOpenProbability;
      }

      return FaceData(
        detected: true,
        faceCount: faces.length,
        landmarks: landmarks,
      );
    } catch (e) {
      return null;
    }
  }

  /// 分析拍摄环境 - 根据实际图片像素数据判断光照和环境
  Future<EnvironmentData> _analyzeEnvironment(File file) async {
    try {
      final bytes = await file.readAsBytes();
      // 在 isolate 中解码图片以避免阻塞UI线程
      final image = await compute(_decodeImage, bytes);

      if (image == null) {
        // 解码失败时使用默认推断
        return _inferEnvironmentFromLabels([]);
      }

      // 采样分析图片亮度（每20像素取一个样本）
      final sampleStep = 20;
      int totalR = 0, totalG = 0, totalB = 0;
      int sampleCount = 0;
      final maxX = image.width;
      final maxY = image.height;

      for (int y = 0; y < maxY; y += sampleStep) {
        for (int x = 0; x < maxX; x += sampleStep) {
          final pixel = image.getPixel(x, y);
          totalR += pixel.r.toInt();
          totalG += pixel.g.toInt();
          totalB += pixel.b.toInt();
          sampleCount++;
        }
      }

      if (sampleCount == 0) {
        return _inferEnvironmentFromLabels([]);
      }

      final avgR = totalR ~/ sampleCount;
      final avgG = totalG ~/ sampleCount;
      final avgB = totalB ~/ sampleCount;

      // 计算亮度 (使用标准亮度公式 Y = 0.299*R + 0.587*G + 0.114*B)
      final brightness = (0.299 * avgR + 0.587 * avgG + 0.114 * avgB).round();

      // 判断光照等级（0-255范围）
      LightLevel lightLevel;
      if (brightness > 180) {
        lightLevel = LightLevel.bright;
      } else if (brightness > 120) {
        lightLevel = LightLevel.moderate;
      } else if (brightness > 60) {
        lightLevel = LightLevel.dim;
      } else {
        lightLevel = LightLevel.veryDim;
      }

      // 推断环境类型（根据色温）
      // 室外偏蓝/偏白，室内偏暖黄
      EnvironmentType environment;
      if (brightness > 150 && (avgB > avgR * 0.9)) {
        environment = EnvironmentType.outdoor;
      } else if (brightness < 80) {
        environment = EnvironmentType.indoor;
      } else {
        // 根据饱和度辅助判断：室外饱和度更高
        final maxChannel = [avgR, avgG, avgB].reduce(max);
        final minChannel = [avgR, avgG, avgB].reduce(min);
        final saturation = maxChannel == 0 ? 0 : (maxChannel - minChannel) / maxChannel;
        environment = saturation > 0.2 ? EnvironmentType.outdoor : EnvironmentType.indoor;
      }

      // 提取主要颜色
      final dominantColors = [
        '#${avgR.toRadixString(16).padLeft(2, '0')}${avgG.toRadixString(16).padLeft(2, '0')}${avgB.toRadixString(16).padLeft(2, '0')}'.toUpperCase(),
        '#${(avgR * 0.8).toInt().toRadixString(16).padLeft(2, '0')}${(avgG * 0.8).toInt().toRadixString(16).padLeft(2, '0')}${(avgB * 0.8).toInt().toRadixString(16).padLeft(2, '0')}'.toUpperCase(),
      ];

      return EnvironmentData(
        environment: environment,
        lightLevel: lightLevel,
        dominantColors: dominantColors,
      );
    } catch (e) {
      // 分析失败时回退到默认推断
      return _inferEnvironmentFromLabels([]);
    }
  }

  /// 根据标签推断环境类型（降级方案）
  EnvironmentData _inferEnvironmentFromLabels(List<ImageLabel> labels) {
    final labelTexts = labels.map((l) => l.label.toLowerCase()).toList();

    EnvironmentType env = EnvironmentType.unknown;
    if (labelTexts.any((l) => ['indoor', 'room', 'office', 'home', 'restaurant', 'cafe', 'kitchen', 'bedroom'].contains(l))) {
      env = EnvironmentType.indoor;
    } else if (labelTexts.any((l) => ['outdoor', 'sky', 'mountain', 'beach', 'park', 'street', 'road', 'city'].contains(l))) {
      env = EnvironmentType.outdoor;
    } else if (labelTexts.any((l) => ['studio', 'background', 'backdrop'].contains(l))) {
      env = EnvironmentType.studio;
    } else {
      env = EnvironmentType.indoor; // 默认室内
    }

    return EnvironmentData(
      environment: env,
      lightLevel: LightLevel.moderate,
      dominantColors: ['#FFFFFF', '#F5F5F5'],
    );
  }

  /// 综合分析生成最终结果
  PhotoAnalysis _synthesizeAnalysis({
    required String imagePath,
    required List<ImageLabel> labels,
    required PoseData? poseData,
    required FaceData? faceData,
    required EnvironmentData envData,
  }) {
    // 确定拍摄主体类型
    final subjectType = _determineSubjectType(labels, poseData, faceData);
    final detectedSubject = labels.isNotEmpty ? labels.first.label : null;
    final sceneTags = labels.map((l) => l.label).toList();

    // 生成智能推荐参数
    final recommendations = _generateRecommendations(
      subjectType: subjectType,
      environmentType: envData.environment,
      lightLevel: envData.lightLevel,
      poseData: poseData,
      faceData: faceData,
      labels: labels,
    );

    return PhotoAnalysis(
      imagePath: imagePath,
      analyzedAt: DateTime.now(),
      subjectType: subjectType,
      environmentType: envData.environment,
      lightLevel: envData.lightLevel,
      detectedSubject: detectedSubject,
      sceneTags: sceneTags,
      recommendations: recommendations,
    );
  }

  /// 判断拍摄主体类型
  SubjectType _determineSubjectType(
    List<ImageLabel> labels,
    PoseData? poseData,
    FaceData? faceData,
  ) {
    final labelTexts = labels.map((l) => l.label.toLowerCase()).toList();

    // 人像检测优先级最高
    if (faceData?.detected == true || poseData?.detected == true) {
      if (labelTexts.any((l) => ['person', 'people', 'human', 'man', 'woman', 'child', 'boy', 'girl'].contains(l))) {
        return SubjectType.person;
      }
      return SubjectType.person;
    }

    // 细分场景识别
    if (labelTexts.any((l) => ['food', 'dish', 'meal', 'restaurant', 'cake', 'dessert'].contains(l))) {
      return SubjectType.food;
    }
    if (labelTexts.any((l) => ['dog', 'cat', 'bird', 'pet', 'animal', 'wildlife'].contains(l))) {
      return SubjectType.animal;
    }
    if (labelTexts.any((l) => ['building', 'house', 'architecture', 'city', 'skyscraper'].contains(l))) {
      return SubjectType.building;
    }
    if (labelTexts.any((l) => ['flower', 'plant', 'tree', 'garden', 'nature', 'landscape'].contains(l))) {
      return SubjectType.landscape;
    }
    if (labelTexts.any((l) => ['product', 'item', 'object', 'electronics'].contains(l))) {
      return SubjectType.object;
    }

    return SubjectType.unknown;
  }

  /// 生成智能拍摄推荐
  ShootingRecommendations _generateRecommendations({
    required SubjectType subjectType,
    required EnvironmentType environmentType,
    required LightLevel lightLevel,
    required PoseData? poseData,
    required FaceData? faceData,
    required List<ImageLabel> labels,
  }) {
    // 基础参数（根据光照条件）
    int iso;
    String shutterSpeed;
    String aperture;

    // 光照智能判断
    switch (lightLevel) {
      case LightLevel.bright:
        iso = 100;
        shutterSpeed = '1/500';
        aperture = 'f/8';
        break;
      case LightLevel.moderate:
        iso = 200;
        shutterSpeed = '1/250';
        aperture = 'f/5.6';
        break;
      case LightLevel.dim:
        iso = 400;
        shutterSpeed = '1/125';
        aperture = 'f/4';
        break;
      case LightLevel.veryDim:
        iso = 800;
        shutterSpeed = '1/60';
        aperture = 'f/2.8';
        break;
      default:
        iso = 200;
        shutterSpeed = '1/250';
        aperture = 'f/5.6';
    }

    // 角度、姿势、构图建议
    List<String> angles;
    List<String> poses;
    List<String> tips;
    String composition;

    // 根据主体类型定制推荐
    switch (subjectType) {
      case SubjectType.person:
        angles = _getPersonAngles(poseData);
        poses = _generatePersonPoses(poseData, faceData);
        tips = _getPersonTips(faceData);
        composition = '三分法构图，将眼睛放在画面上方1/3处，背景占1/3';
        aperture = 'f/1.8-f/2.8'; // 大光圈虚化背景，突出人物
        break;

      case SubjectType.landscape:
        angles = ['低角度（突出前景）', '高点俯拍（展现全貌）', '利用引导线'];
        poses = [];
        tips = [
          '黄金时段（清晨/傍晚）光线最柔和',
          '使用三脚架保持稳定',
          '加入前景元素增加层次',
          '考虑天空和地面的比例',
        ];
        composition = '三分法或黄金分割，天空/地面根据天气调整比例';
        aperture = 'f/8-f/11'; // 大景深，前景到背景都清晰
        shutterSpeed = '1/125';
        break;

      case SubjectType.food:
        angles = ['45度斜角（经典视角）', '正上方俯拍（平面展示）', '低角度侧面'];
        poses = [];
        tips = [
          '使用自然侧光或逆光，突出食物质感',
          '保持餐具和背景简洁',
          '可以轻微调整食物摆放位置',
          '使用微距模式展现细节',
        ];
        composition = '中心构图或对角线构图，适当留白增加高级感';
        aperture = 'f/2.8-f/4';
        break;

      case SubjectType.animal:
        angles = ['与动物视线平齐', '低角度仰拍', '俯视（小型动物）'];
        poses = [];
        tips = [
          '耐心等待自然姿态出现',
          '使用连拍模式抓拍',
          '对焦点务必放在眼睛上',
          '保持安静，不要惊扰动物',
        ];
        composition = '将动物眼睛放在三分点或黄金分割点';
        iso = min(iso * 2, 3200); // 动物可能需要更高ISO
        shutterSpeed = '1/500'; // 快速快门捕捉动作
        break;

      case SubjectType.building:
        angles = ['低角度仰拍（显宏伟）', '45度侧面展示立体感', '正面对称构图'];
        poses = [];
        tips = [
          '寻找独特的线条和几何形状',
          '注意控制透视畸变',
          '利用天气和时段创造氛围',
          '寻找框架元素增加层次',
        ];
        composition = '对称构图或引导线构图，强调建筑线条';
        aperture = 'f/8-f/11';
        break;

      default:
        angles = ['45度主视角', '正面', '侧面'];
        poses = [];
        tips = ['选择简洁的背景'];
        composition = '中心构图或三分法';
    }

    // 环境补充建议
    tips = _addEnvironmentTips(tips, environmentType, lightLevel, iso);

    return ShootingRecommendations(
      recommendedIso: iso,
      recommendedShutterSpeed: shutterSpeed,
      recommendedAperture: aperture,
      suggestedAngles: angles,
      suggestedPoses: poses,
      tips: tips,
      compositionSuggestion: composition,
    );
  }

  /// 获取人像推荐角度
  List<String> _getPersonAngles(PoseData? poseData) {
    if (poseData == null || poseData.landmarks.isEmpty) {
      return ['平视（自然角度）', '轻微俯视（5-10度，显瘦）', '低角度仰拍（显高）'];
    }

    final hasUpperBody = poseData.landmarks.containsKey('leftShoulder') &&
        poseData.landmarks.containsKey('rightShoulder');
    final hasLowerBody = poseData.landmarks.containsKey('leftHip') &&
        poseData.landmarks.containsKey('rightHip');

    if (hasUpperBody && !hasLowerBody) {
      return ['平视（半身照）', '轻微俯视（头部特写）', '侧面45度'];
    }
    return ['平视（标准人像）', '轻微俯视（5-10度）', '低角度仰拍（显腿长）', '侧面三分脸'];
  }

  /// 获取人像拍摄技巧
  List<String> _getPersonTips(FaceData? faceData) {
    final tips = <String>[
      '保持肩膀放松，避免耸肩',
      '下巴微微收紧，显得更精神',
      '眼神焦点放在镜头稍微上方',
    ];

    if (faceData != null) {
      final smiling = faceData.landmarks['smiling'];
      if (smiling != null && smiling < 0.3) {
        tips.add('尝试自然微笑，嘴唇微微张开');
      }

      final leftEye = faceData.landmarks['leftEyeOpen'];
      final rightEye = faceData.landmarks['rightEyeOpen'];
      if (leftEye != null && leftEye < 0.5) {
        tips.add('眼睛睁大一些，会更有神');
      }
    }

    tips.add('舌尖轻抵上颚，嘴角自然上扬');
    return tips;
  }

  /// 生成人物姿势建议
  List<String> _generatePersonPoses(PoseData? poseData, FaceData? faceData) {
    final poses = <String>[];

    if (poseData != null && poseData.landmarks.isNotEmpty) {
      // 根据检测到的姿态生成建议
      final hasUpperBody = poseData.landmarks.containsKey('leftShoulder') &&
          poseData.landmarks.containsKey('rightShoulder');
      final hasLowerBody = poseData.landmarks.containsKey('leftHip') &&
          poseData.landmarks.containsKey('rightHip');

      if (hasUpperBody && !hasLowerBody) {
        poses.addAll([
          '双手叉腰，肩膀微微向后',
          '单手支撑头部，另一手自然下垂',
          '假装整理头发或衣服，增加互动感',
        ]);
      } else if (hasUpperBody && hasLowerBody) {
        poses.addAll([
          '站立时重心放在一只脚上，胯部轻微转向',
          '一脚微微踏前，重心分布7:3',
          '靠墙或依靠物体，分散重心更自然',
          '行走中抓拍，动作更生动',
        ]);
      }
    } else {
      // 默认姿势建议
      poses.addAll([
        '放松肩膀和手臂，避免僵硬',
        '下巴略微向前伸，减少双下巴',
        '手臂不要贴近身体，稍有距离更显瘦',
        '尝试不同的头部角度找到最佳表情',
      ]);
    }

    // 根据表情调整建议
    if (faceData?.landmarks['smiling'] != null) {
      final smileProb = faceData!.landmarks['smiling'] as double;
      if (smileProb < 0.3) {
        poses.add('尝试自然微笑，露出轻微牙齿');
      } else if (smileProb > 0.7) {
        poses.add('笑容很棒！注意眼睛也要跟着微笑');
      }
    }

    return poses;
  }

  /// 添加环境相关建议
  List<String> _addEnvironmentTips(
    List<String> tips,
    EnvironmentType environmentType,
    LightLevel lightLevel,
    int iso,
  ) {
    final additionalTips = <String>[];

    if (environmentType == EnvironmentType.indoor) {
      additionalTips.add('室内拍摄注意手持稳定性，必要时靠在固定物上');
      if (lightLevel == LightLevel.dim || lightLevel == LightLevel.veryDim) {
        additionalTips.add('光线不足时，可使用人工补光或靠近窗户');
        additionalTips.add('如果没有三脚架，手持时快门不要慢于1/60');
      }
    } else if (environmentType == EnvironmentType.outdoor) {
      additionalTips.add('户外注意避免阳光直射镜头造成眩光');
      additionalTips.add('强光下可使用遮光罩或寻找阴影处');
      additionalTips.add('阴天光线柔和，适合人像拍摄');
    }

    // 高ISO警告
    if (iso >= 800) {
      additionalTips.add('当前光线较弱，注意照片可能出现噪点');
      additionalTips.add('尽量保持稳定，有条件使用三脚架');
    }

    return [...tips, ...additionalTips];
  }

  /// 释放资源
  void dispose() {
    _imageLabeler.close();
    _poseDetector.close();
    _faceDetector.close();
  }
}

/// 在 isolate 中解码图片（顶层函数，供 compute 调用）
img.Image? _decodeImage(List<int> bytes) {
  return img.decodeImage(bytes);
}

// 辅助数据类
class PoseData {
  final bool detected;
  final Map<String, PoseLandmark> landmarks;
  final double confidence;

  PoseData({
    required this.detected,
    required this.landmarks,
    required this.confidence,
  });
}

class FaceData {
  final bool detected;
  final int faceCount;
  final Map<String, dynamic> landmarks;

  FaceData({
    required this.detected,
    required this.faceCount,
    required this.landmarks,
  });
}

class EnvironmentData {
  final EnvironmentType environment;
  final LightLevel lightLevel;
  final List<String> dominantColors;

  EnvironmentData({
    required this.environment,
    required this.lightLevel,
    required this.dominantColors,
  });
}
