enum MeasurementKind { length, count }

enum MeasurementQuality { poor, acceptable, good }

class VisionMeasurement {
  final DateTime time;
  final MeasurementKind kind;
  final double? lengthMm;
  final int? count;
  final MeasurementQuality quality;

  const VisionMeasurement({
    required this.time,
    required this.kind,
    this.lengthMm,
    this.count,
    this.quality = MeasurementQuality.good,
  });
}

class MeasurementReport {
  final String id;
  final DateTime createdAt;
  final String profileName;
  final String materialLabel;
  final double? diameterMm;
  final double? wallThicknessMm;
  final double? representativeLengthMm;
  final int quantity;
  final double? linearMassKgM;
  final List<VisionMeasurement> measurements;

  const MeasurementReport({
    required this.id,
    required this.createdAt,
    required this.profileName,
    required this.materialLabel,
    required this.quantity,
    this.diameterMm,
    this.wallThicknessMm,
    this.representativeLengthMm,
    this.linearMassKgM,
    this.measurements = const [],
  });

  MeasurementReport copyWith({
    double? representativeLengthMm,
    int? quantity,
    double? linearMassKgM,
    List<VisionMeasurement>? measurements,
  }) {
    return MeasurementReport(
      id: id,
      createdAt: createdAt,
      profileName: profileName,
      materialLabel: materialLabel,
      diameterMm: diameterMm,
      wallThicknessMm: wallThicknessMm,
      representativeLengthMm:
          representativeLengthMm ?? this.representativeLengthMm,
      quantity: quantity ?? this.quantity,
      linearMassKgM: linearMassKgM ?? this.linearMassKgM,
      measurements: measurements ?? this.measurements,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': createdAt.toIso8601String(),
        'profileName': profileName,
        'materialLabel': materialLabel,
        'diameterMm': diameterMm,
        'wallThicknessMm': wallThicknessMm,
        'representativeLengthMm': representativeLengthMm,
        'quantity': quantity,
        'linearMassKgM': linearMassKgM,
        'measurements': measurements
            .map((m) => {
                  'time': m.time.toIso8601String(),
                  'kind': m.kind.name,
                  'lengthMm': m.lengthMm,
                  'count': m.count,
                  'quality': m.quality.name,
                })
            .toList(),
      };

  factory MeasurementReport.fromJson(Map<String, dynamic> json) {
    final rawMeasurements = (json['measurements'] as List?) ?? const [];
    return MeasurementReport(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      profileName: json['profileName'] as String,
      materialLabel: json['materialLabel'] as String,
      diameterMm: (json['diameterMm'] as num?)?.toDouble(),
      wallThicknessMm: (json['wallThicknessMm'] as num?)?.toDouble(),
      representativeLengthMm:
          (json['representativeLengthMm'] as num?)?.toDouble(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      linearMassKgM: (json['linearMassKgM'] as num?)?.toDouble(),
      measurements: rawMeasurements.map((raw) {
        final m = Map<String, dynamic>.from(raw as Map);
        return VisionMeasurement(
          time: DateTime.parse(m['time'] as String),
          kind: MeasurementKind.values.firstWhere(
            (v) => v.name == m['kind'],
            orElse: () => MeasurementKind.length,
          ),
          lengthMm: (m['lengthMm'] as num?)?.toDouble(),
          count: (m['count'] as num?)?.toInt(),
          quality: MeasurementQuality.values.firstWhere(
            (v) => v.name == m['quality'],
            orElse: () => MeasurementQuality.good,
          ),
        );
      }).toList(),
    );
  }
}
