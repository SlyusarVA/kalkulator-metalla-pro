import '../models/models.dart';

/// Ключи полей расчёта (помимо параметров профиля)
const String kLength = '__length__'; // длина, м
const String kQuantity = '__quantity__'; // количество, шт
const String kMass = '__mass__'; // масса, кг

class Calculator {
  /// Выполняет расчёт.
  ///
  /// [profile] — выбранный профиль
  /// [density] — плотность материала, кг/м³
  /// [inputs] — карта всех полей: ключ → значение (null = поле пустое)
  ///
  /// Возвращает [CalcResult] или [CalcError].
  static dynamic calculate({
    required MetalProfile profile,
    required double density,
    required Map<String, double?> inputs,
  }) {
    String fieldName(String key) {
      if (key == kLength) return 'Длина (м)';
      if (key == kQuantity) return 'Количество (шт)';
      if (key == kMass) return 'Масса (кг)';
      try {
        return profile.params.firstWhere((p) => p.key == key).label;
      } catch (_) {
        return key;
      }
    }

    // Разбиваем на заполненные, пустые и некорректные значения.
    final filled = <String, double>{};
    final missing = <String>[];
    final invalid = <String>[];

    for (final e in inputs.entries) {
      final v = e.value;
      if (v == null) {
        missing.add(e.key);
      } else if (v > 0) {
        filled[e.key] = v;
      } else {
        invalid.add(e.key);
        missing.add(e.key);
      }
    }

    if (invalid.isNotEmpty) {
      return CalcError(
        message: 'Значения должны быть больше нуля',
        missingFields: invalid.map(fieldName).toList(),
      );
    }

    // Если все заполнены
    if (missing.isEmpty) {
      return const CalcError(message: 'Все данные уже внесены');
    }

    final geometryError = _validateGeometry(profile, filled, fieldName);
    if (geometryError != null) return geometryError;

    // ── ЛИСТ / ПЛИТА ──────────────────────────────────────────────────────────
    if (profile.isVolume) {
      final paramKeys = profile.params.map((p) => p.key).toList();
      final missingParams = paramKeys.where((k) => !filled.containsKey(k)).toList();

      if (missingParams.isNotEmpty) {
        return CalcError(
          message: 'Укажите недостающие данные',
          missingFields: missingParams.map(fieldName).toList(),
        );
      }

      final volume = profile.sectionArea(filled); // мм³
      if (volume <= 0) return const CalcError(message: 'Нулевой объём профиля');
      final massOne = volume / 1e9 * density;

      if (missing.length == 1 && missing.first == kMass) {
        final qty = filled[kQuantity] ?? 1.0;
        return CalcResult(
          target: CalcTarget.mass,
          value: massOne * qty,
          unit: 'кг',
          linearMass: massOne,
        );
      }

      if (missing.length == 1 && missing.first == kQuantity) {
        if (!filled.containsKey(kMass)) {
          return CalcError(
            message: 'Укажите недостающие данные',
            missingFields: [fieldName(kMass)],
          );
        }
        return CalcResult(
          target: CalcTarget.quantity,
          value: filled[kMass]! / massOne,
          unit: 'шт',
          linearMass: massOne,
        );
      }

      return CalcError(
        message: 'Укажите недостающие данные',
        missingFields: missing.map(fieldName).toList(),
      );
    }

    // ── ЛИНЕЙНЫЕ ПРОФИЛИ ─────────────────────────────────────────────────────
    final paramKeys = profile.params.map((p) => p.key).toList();
    final missingParams = paramKeys.where((k) => !filled.containsKey(k)).toList();

    if (missingParams.isNotEmpty) {
      return CalcError(
        message: 'Укажите недостающие данные',
        missingFields: missingParams.map(fieldName).toList(),
      );
    }

    // Площадь сечения (мм²)
    final section = profile.sectionArea(filled);
    if (section <= 0) return const CalcError(message: 'Нулевое сечение профиля');

    // Погонный вес (кг/м)
    final linearMass = section / 1e6 * density;

    final hasLength = filled.containsKey(kLength);
    final hasQuantity = filled.containsKey(kQuantity);
    final hasMass = filled.containsKey(kMass);

    final missingCalc = missing
        .where((k) => k == kLength || k == kQuantity || k == kMass)
        .toList();

    // Ровно одно пустое поле из [длина, кол-во, масса]
    if (missingCalc.length == 1) {
      final target = missingCalc.first;

      if (target == kMass) {
        final len = filled[kLength] ?? 1.0;
        final qty = filled[kQuantity] ?? 1.0;
        return CalcResult(
          target: CalcTarget.mass,
          value: linearMass * len * qty,
          unit: 'кг',
          linearMass: linearMass,
        );
      }

      if (target == kLength) {
        if (!hasMass || !hasQuantity) {
          final need = <String>[];
          if (!hasMass) need.add(fieldName(kMass));
          if (!hasQuantity) need.add(fieldName(kQuantity));
          return CalcError(message: 'Укажите недостающие данные', missingFields: need);
        }
        final qty = filled[kQuantity]!;
        final totalLen = filled[kMass]! / (linearMass * qty);
        return CalcResult(
          target: CalcTarget.length,
          value: totalLen,
          unit: 'м',
          linearMass: linearMass,
        );
      }

      if (target == kQuantity) {
        if (!hasMass || !hasLength) {
          final need = <String>[];
          if (!hasMass) need.add(fieldName(kMass));
          if (!hasLength) need.add(fieldName(kLength));
          return CalcError(message: 'Укажите недостающие данные', missingFields: need);
        }
        final len = filled[kLength]!;
        final qty = filled[kMass]! / (linearMass * len);
        return CalcResult(
          target: CalcTarget.quantity,
          value: qty,
          unit: 'шт',
          linearMass: linearMass,
        );
      }
    }

    // Несколько пустых полей
    if (missingCalc.length > 1) {
      return CalcError(
        message: 'Укажите недостающие данные',
        missingFields: missingCalc.map(fieldName).toList(),
      );
    }

    return CalcError(
      message: 'Укажите недостающие данные',
      missingFields: missing.map(fieldName).toList(),
    );
  }

  static CalcError? _validateGeometry(
    MetalProfile profile,
    Map<String, double> filled,
    String Function(String key) fieldName,
  ) {
    final name = profile.name;

    if (name == 'Труба кр.' && filled.containsKey('d') && filled.containsKey('t')) {
      final d = filled['d']!;
      final t = filled['t']!;
      if (2 * t >= d) {
        return CalcError(
          message: 'Толщина стенки должна быть меньше половины диаметра',
          missingFields: [fieldName('d'), fieldName('t')],
        );
      }
    }

    if (name == 'Труба проф.' &&
        filled.containsKey('a') &&
        filled.containsKey('b') &&
        filled.containsKey('t')) {
      final a = filled['a']!;
      final b = filled['b']!;
      final t = filled['t']!;
      if (2 * t >= a || 2 * t >= b) {
        return CalcError(
          message: 'Толщина стенки должна быть меньше половины стороны профиля',
          missingFields: [fieldName('a'), fieldName('b'), fieldName('t')],
        );
      }
    }

    return null;
  }
}
