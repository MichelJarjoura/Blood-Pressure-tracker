import 'package:hive/hive.dart';

part 'bp_reading.g.dart';

@HiveType(typeId: 0)
class BpReading extends HiveObject {
  @HiveField(0)
  final int systolic;

  @HiveField(1)
  final int diastolic;

  @HiveField(2)
  final int? pulse;

  @HiveField(3)
  final DateTime timestamp;

  @HiveField(4)
  final String? note;

  @HiveField(5)
  final String? arm; // 'left' | 'right'

  @HiveField(6)
  final String? bodyPosition; // 'sitting' | 'lying' | 'standing'

  BpReading({
    required this.systolic,
    required this.diastolic,
    this.pulse,
    required this.timestamp,
    this.note,
    this.arm,
    this.bodyPosition,
  });

  BpCategory get category {
    if (systolic < 90 || diastolic < 60) return BpCategory.low;
    if (systolic < 120 && diastolic < 80) return BpCategory.normal;
    if (systolic < 130 && diastolic < 80) return BpCategory.elevated;
    if (systolic < 140 || diastolic < 90) return BpCategory.highStage1;
    if (systolic < 180 && diastolic < 120) return BpCategory.highStage2;
    return BpCategory.crisis;
  }

  BpReading copyWith({
    int? systolic,
    int? diastolic,
    int? pulse,
    DateTime? timestamp,
    String? note,
    String? arm,
    String? bodyPosition,
  }) {
    return BpReading(
      systolic: systolic ?? this.systolic,
      diastolic: diastolic ?? this.diastolic,
      pulse: pulse ?? this.pulse,
      timestamp: timestamp ?? this.timestamp,
      note: note ?? this.note,
      arm: arm ?? this.arm,
      bodyPosition: bodyPosition ?? this.bodyPosition,
    );
  }

  Map<String, dynamic> toMap() => {
        'systolic': systolic,
        'diastolic': diastolic,
        'pulse': pulse,
        'timestamp': timestamp.toIso8601String(),
        'note': note,
        'arm': arm,
        'bodyPosition': bodyPosition,
      };
}

enum BpCategory {
  low,
  normal,
  elevated,
  highStage1,
  highStage2,
  crisis;

  String get label {
    switch (this) {
      case BpCategory.low:
        return 'Low';
      case BpCategory.normal:
        return 'Normal';
      case BpCategory.elevated:
        return 'Elevated';
      case BpCategory.highStage1:
        return 'High Stage 1';
      case BpCategory.highStage2:
        return 'High Stage 2';
      case BpCategory.crisis:
        return 'Crisis';
    }
  }

  String get description {
    switch (this) {
      case BpCategory.low:
        return 'Your blood pressure is below the normal range.';
      case BpCategory.normal:
        return 'Your blood pressure is within the healthy range.';
      case BpCategory.elevated:
        return 'Your blood pressure is slightly above normal.';
      case BpCategory.highStage1:
        return 'Stage 1 hypertension. Consider lifestyle changes.';
      case BpCategory.highStage2:
        return 'Stage 2 hypertension. Consult your doctor.';
      case BpCategory.crisis:
        return 'Hypertensive crisis! Seek medical attention immediately.';
    }
  }
}
