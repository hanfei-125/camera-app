class AppConstants {
  // App信息
  static const String appName = 'AI相机';
  static const String appVersion = '1.0.0';

  // 拍摄参数常量
  static const Map<String, ShootingPreset> defaultPresets = {
    'portrait': ShootingPreset(
      name: '人像',
      iso: 100,
      shutterSpeed: '1/200',
      aperture: 'f/1.8',
      description: '背景虚化，突出人物',
    ),
    'landscape': ShootingPreset(
      name: '风景',
      iso: 100,
      shutterSpeed: '1/250',
      aperture: 'f/8.0',
      description: '大景深，画面清晰',
    ),
    'night': ShootingPreset(
      name: '夜景',
      iso: 800,
      shutterSpeed: '1/60',
      aperture: 'f/2.8',
      description: '低光环境，保持稳定',
    ),
    'sports': ShootingPreset(
      name: '运动',
      iso: 400,
      shutterSpeed: '1/1000',
      aperture: 'f/2.8',
      description: '高速快门，捕捉瞬间',
    ),
    'indoor': ShootingPreset(
      name: '室内',
      iso: 400,
      shutterSpeed: '1/125',
      aperture: 'f/2.8',
      description: '平衡光线，避免抖动',
    ),
    'macro': ShootingPreset(
      name: '微距',
      iso: 100,
      shutterSpeed: '1/250',
      aperture: 'f/5.6',
      description: '近距离拍摄细节',
    ),
  };

  // 光照条件推荐
  static const Map<String, LightCondition> lightConditions = {
    'bright_sun': LightCondition(
      name: '强烈阳光',
      description: '避免正午拍摄，选择柔和光线时段',
      recommendedTime: '清晨或傍晚',
      isoRange: [50, 100],
      suggestedAperture: 'f/8-f/11',
    ),
    'cloudy': LightCondition(
      name: '阴天',
      description: '光线柔和，适合人像',
      recommendedTime: '全天适宜',
      isoRange: [100, 200],
      suggestedAperture: 'f/4-f/5.6',
    ),
    'indoor_natural': LightCondition(
      name: '室内自然光',
      description: '靠近窗户，避免逆光',
      recommendedTime: '白天',
      isoRange: [200, 400],
      suggestedAperture: 'f/2.8-f/4',
    ),
    'indoor_artificial': LightCondition(
      name: '室内人工光',
      description: '注意白平衡，避免色偏',
      recommendedTime: '任何时间',
      isoRange: [400, 800],
      suggestedAperture: 'f/2.8-f/4',
    ),
    'blue_hour': LightCondition(
      name: '蓝调时刻',
      description: '日出前日落后，光线层次丰富',
      recommendedTime: '日出前30分钟/日落后30分钟',
      isoRange: [200, 400],
      suggestedAperture: 'f/4-f/5.6',
    ),
  };

  // 拍摄角度推荐
  static const Map<String, AngleRecommendation> angleRecommendations = {
    'person_full': AngleRecommendation(
      subjectType: '全身人像',
      bestAngles: ['低角度仰拍', '45度侧面', '正对面'],
      avoidAngles: ['俯拍（显矮）'],
      tip: '低角度可以显得更高大',
    ),
    'person_half': AngleRecommendation(
      subjectType: '半身人像',
      bestAngles: ['平视', '轻微俯视', '轻微仰视'],
      avoidAngles: ['极端俯视', '极端仰视'],
      tip: '保持眼睛在画面上半部分',
    ),
    'person_face': AngleRecommendation(
      subjectType: '面部特写',
      bestAngles: ['正侧面45度', '3/4侧面'],
      avoidAngles: ['正面全正', '极端侧面'],
      tip: '轻微侧光可以突出轮廓',
    ),
    'object': AngleRecommendation(
      subjectType: '物体拍摄',
      bestAngles: ['与物体高度平齐', '45度斜角'],
      avoidAngles: ['过于正面'],
      tip: '考虑物体形状选择最佳角度',
    ),
    'landscape': AngleRecommendation(
      subjectType: '风景',
      bestAngles: ['低角度', '高处俯拍', '利用前景'],
      avoidAngles: ['随手拍摄'],
      tip: '黄金时段光线最佳',
    ),
  };
}

class ShootingPreset {
  final String name;
  final int iso;
  final String shutterSpeed;
  final String aperture;
  final String description;

  const ShootingPreset({
    required this.name,
    required this.iso,
    required this.shutterSpeed,
    required this.aperture,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'iso': iso,
    'shutterSpeed': shutterSpeed,
    'aperture': aperture,
    'description': description,
  };
}

class LightCondition {
  final String name;
  final String description;
  final String recommendedTime;
  final List<int> isoRange;
  final String suggestedAperture;

  const LightCondition({
    required this.name,
    required this.description,
    required this.recommendedTime,
    required this.isoRange,
    required this.suggestedAperture,
  });
}

class AngleRecommendation {
  final String subjectType;
  final List<String> bestAngles;
  final List<String> avoidAngles;
  final String tip;

  const AngleRecommendation({
    required this.subjectType,
    required this.bestAngles,
    required this.avoidAngles,
    required this.tip,
  });
}
