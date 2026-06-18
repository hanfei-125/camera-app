import 'package:equatable/equatable.dart';

enum SubjectType {
  person,
  landscape,
  object,
  food,
  animal,
  building,
  unknown,
}

enum EnvironmentType {
  indoor,
  outdoor,
  studio,
  unknown,
}

enum LightLevel {
  bright,
  moderate,
  dim,
  veryDim,
  unknown,
}

class PhotoAnalysis extends Equatable {
  final String imagePath;
  final DateTime analyzedAt;
  final SubjectType subjectType;
  final EnvironmentType environmentType;
  final LightLevel lightLevel;
  final String? detectedSubject;
  final List<String> sceneTags;
  final ShootingRecommendations recommendations;

  const PhotoAnalysis({
    required this.imagePath,
    required this.analyzedAt,
    required this.subjectType,
    required this.environmentType,
    required this.lightLevel,
    this.detectedSubject,
    required this.sceneTags,
    required this.recommendations,
  });

  @override
  List<Object?> get props => [
    imagePath,
    analyzedAt,
    subjectType,
    environmentType,
    lightLevel,
    detectedSubject,
    sceneTags,
    recommendations,
  ];
}

class ShootingRecommendations extends Equatable {
  final int recommendedIso;
  final String recommendedShutterSpeed;
  final String recommendedAperture;
  final List<String> suggestedAngles;
  final List<String> suggestedPoses;
  final List<String> tips;
  final String compositionSuggestion;

  const ShootingRecommendations({
    required this.recommendedIso,
    required this.recommendedShutterSpeed,
    required this.recommendedAperture,
    required this.suggestedAngles,
    required this.suggestedPoses,
    required this.tips,
    required this.compositionSuggestion,
  });

  @override
  List<Object?> get props => [
    recommendedIso,
    recommendedShutterSpeed,
    recommendedAperture,
    suggestedAngles,
    suggestedPoses,
    tips,
    compositionSuggestion,
  ];

  Map<String, dynamic> toJson() => {
    'iso': recommendedIso,
    'shutterSpeed': recommendedShutterSpeed,
    'aperture': recommendedAperture,
    'angles': suggestedAngles,
    'poses': suggestedPoses,
    'tips': tips,
    'composition': compositionSuggestion,
  };
}
