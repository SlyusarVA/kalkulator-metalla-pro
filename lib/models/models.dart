// ─── Profile param ────────────────────────────────────────────────────────────

class ProfileParam {
  final String key;
  final String label;
  final String unit;
  final double defaultValue;
  final List<double> drumValues;

  /// true, если для поля есть ГОСТ-значения и его можно выбирать барабаном.
  bool get hasDrumValues => drumValues.isNotEmpty;

  const ProfileParam({
    required this.key,
    required this.label,
    required this.unit,
    required this.defaultValue,
    this.drumValues = const [],
  });
}

// ─── Profile ─────────────────────────────────────────────────────────────────

class MetalProfile {
  final String name;
  final String gost;
  final String iconAsset;
  final List<ProfileParam> params;

  /// Возвращает площадь сечения в мм².
  /// Для листа/плиты возвращает объём в мм³ (isVolume==true).
  final double Function(Map<String, double> v) sectionArea;
  final bool isVolume; // лист, плита

  const MetalProfile({
    required this.name,
    required this.gost,
    required this.iconAsset,
    required this.params,
    required this.sectionArea,
    this.isVolume = false,
  });
}

// ─── Material ─────────────────────────────────────────────────────────────────

class MetalMaterial {
  final String group;
  final String grade;
  final double density; // кг/м³
  final String gost;

  const MetalMaterial({
    required this.group,
    required this.grade,
    required this.density,
    required this.gost,
  });
}

// ─── Calculation result ───────────────────────────────────────────────────────

enum CalcTarget { mass, length, quantity, none }

class CalcResult {
  final CalcTarget target;
  final double value;
  final String unit;

  // extra info
  final double? linearMass; // кг/м — для линейных профилей

  const CalcResult({
    required this.target,
    required this.value,
    required this.unit,
    this.linearMass,
  });
}

class CalcError {
  final String message;
  final List<String> missingFields;
  const CalcError({required this.message, this.missingFields = const []});
}

// ─── History entry ────────────────────────────────────────────────────────────

class HistoryEntry {
  final DateTime time;
  final String profileName;
  final String materialLabel;
  final Map<String, double> inputs; // все поля включая результат
  final CalcResult result;

  const HistoryEntry({
    required this.time,
    required this.profileName,
    required this.materialLabel,
    required this.inputs,
    required this.result,
  });
}
