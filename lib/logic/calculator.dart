import '../models/models.dart';

/// Ключи полей расчёта (помимо параметров профиля)
const String kLength   = '__length__';   // длина, м
const String kQuantity = '__quantity__'; // количество, шт
const String kMass     = '__mass__';     // масса, кг

class Calculator {
  /// Выполняет расчёт.
  ///
  /// [profile]  — выбранный профиль
  /// [density]  — плотность материала, кг/м³
  /// [inputs]   — карта всех полей: ключ → значение (null = поле пустое)
  ///
  /// Возвращает [CalcResult] или [CalcError].
  static dynamic calculate({
    required MetalProfile profile,
    required double density,
    required Map<String, double?> inputs,
  }) {
    // Разбиваем на заполненные и пустые
    final filled  = <String, double>{};
    final missing = <String>[];

    for (final e in inputs.entries) {
      if (e.value != null && e.value! > 0) {
        filled[e.key] = e.value!;
      } else {
        missing.add(e.key);
      }
    }

    // Если все заполнены
    if (missing.isEmpty) {
      return const CalcError(message: 'Все данные уже внесены');
    }

    // Человекочитаемые имена полей
    String fieldName(String key) {
      if (key == kLength)   return 'Длина (м)';
      if (key == kQuantity) return 'Количество (шт)';
      if (key == kMass)     return 'Масса (кг)';
      try {
        return profile.params.firstWhere((p) => p.key == key).label;
      } catch (_) {
        return key;
      }
    }

    // ── ЛИСТ / ПЛИТА ──────────────────────────────────────────────────────────
    if (profile.isVolume) {
      final paramKeys = profile.params.map((p) => p.key).toList();
      final missingParams = paramKeys.where((k) => !filled.containsKey(k)).toList();

      if (missingParams.isNotEmpty) {
        // Если пустое только kMass — можно считать массу
        if (missing.length == 1 && missing.first == kMass) {
          // все размеры + кол-во заполнены
          if (!filled.containsKey(kQuantity)) {
            return CalcError(
              message: 'Укажите недостающие данные',
              missingFields: [fieldName(kQuantity)],
            );
          }
          final volume = profile.sectionArea(filled); // мм³
          final massOne = volume / 1e9 * density;
          final qty = filled[kQuantity]!;
          return CalcResult(
            target: CalcTarget.mass,
            value: massOne * qty,
            unit: 'кг',
            linearMass: massOne,
          );
        }

        // Если пустое kQuantity и масса задана — считаем количество
        if (missing.length == 1 && missing.first == kQuantity) {
          if (!filled.containsKey(kMass)) {
            return CalcError(
              message: 'Укажите недостающие данные',
              missingFields: [fieldName(kMass)],
            );
          }
          final volume = profile.sectionArea(filled); // мм³
          final massOne = volume / 1e9 * density;
          if (massOne <= 0) return const CalcError(message: 'Нулевой объём профиля');
          final qty = filled[kMass]! / massOne;
          return CalcResult(
            target: CalcTarget.quantity,
            value: qty,
            unit: 'шт',
            linearMass: massOne,
          );
        }

        return CalcError(
          message: 'Укажите недостающие данные',
          missingFields: missingParams.map(fieldName).toList(),
        );
      }

      // Все размерные параметры заполнены
      final volume = profile.sectionArea(filled); // мм³
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
        if (massOne <= 0) return const CalcError(message: 'Нулевой объём профиля');
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
    // Погонный вес (кг/м)
    final linearMass = section / 1e6 * density;

    final hasLength   = filled.containsKey(kLength);
    final hasQuantity = filled.containsKey(kQuantity);
    final hasMass     = filled.containsKey(kMass);

    final missingCalc = missing.where((k) =>
        k == kLength || k == kQuantity || k == kMass).toList();

    // Ровно одно пустое поле из [длина, кол-во, масса]
    if (missingCalc.length == 1) {
      final target = missingCalc.first;

      if (target == kMass) {
        // Считаем массу
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
        if (linearMass <= 0) return const CalcError(message: 'Нулевое сечение профиля');
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
        if (linearMass <= 0) return const CalcError(message: 'Нулевое сечение профиля');
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

    // Ничего не пустого среди служебных полей, но что-то пустое в параметрах
    return CalcError(
      message: 'Укажите недостающие данные',
      missingFields: missing.map(fieldName).toList(),
    );
  }
}
