import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';

const String _kHistoryKey = 'calc_history_v1';
const int _kMaxHistoryEntries = 50;

Future<List<HistoryEntry>> loadHistory() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(_kHistoryKey);
  if (raw == null || raw.trim().isEmpty) return const [];

  try {
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];

    return decoded
        .whereType<Map>()
        .map((e) => _historyEntryFromJson(Map<String, dynamic>.from(e)))
        .whereType<HistoryEntry>()
        .take(_kMaxHistoryEntries)
        .toList(growable: true);
  } catch (_) {
    // Повреждённая история не должна ломать запуск приложения.
    await prefs.remove(_kHistoryKey);
    return const [];
  }
}

Future<void> saveHistory(List<HistoryEntry> history) async {
  final prefs = await SharedPreferences.getInstance();
  final limited = history.take(_kMaxHistoryEntries).map(_historyEntryToJson).toList();
  await prefs.setString(_kHistoryKey, jsonEncode(limited));
}

Future<void> clearHistory() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_kHistoryKey);
}

Map<String, dynamic> _historyEntryToJson(HistoryEntry e) => {
      'time': e.time.toIso8601String(),
      'profileName': e.profileName,
      'materialLabel': e.materialLabel,
      'inputs': e.inputs,
      'result': _calcResultToJson(e.result),
    };

HistoryEntry? _historyEntryFromJson(Map<String, dynamic> json) {
  final timeRaw = json['time'];
  final profileName = json['profileName'];
  final materialLabel = json['materialLabel'];
  final inputsRaw = json['inputs'];
  final resultRaw = json['result'];

  if (timeRaw is! String ||
      profileName is! String ||
      materialLabel is! String ||
      inputsRaw is! Map ||
      resultRaw is! Map) {
    return null;
  }

  final time = DateTime.tryParse(timeRaw);
  final result = _calcResultFromJson(Map<String, dynamic>.from(resultRaw));
  if (time == null || result == null) return null;

  final inputs = <String, double>{};
  for (final e in inputsRaw.entries) {
    final key = e.key.toString();
    final value = e.value;
    if (value is num) {
      inputs[key] = value.toDouble();
    } else if (value is String) {
      final parsed = double.tryParse(value.replaceAll(',', '.'));
      if (parsed != null) inputs[key] = parsed;
    }
  }

  return HistoryEntry(
    time: time,
    profileName: profileName,
    materialLabel: materialLabel,
    inputs: inputs,
    result: result,
  );
}

Map<String, dynamic> _calcResultToJson(CalcResult r) => {
      'target': r.target.name,
      'value': r.value,
      'unit': r.unit,
      'linearMass': r.linearMass,
    };

CalcResult? _calcResultFromJson(Map<String, dynamic> json) {
  final targetRaw = json['target'];
  final valueRaw = json['value'];
  final unitRaw = json['unit'];
  final linearMassRaw = json['linearMass'];

  if (targetRaw is! String || valueRaw is! num || unitRaw is! String) {
    return null;
  }

  CalcTarget? target;
  for (final candidate in CalcTarget.values) {
    if (candidate.name == targetRaw) {
      target = candidate;
      break;
    }
  }
  if (target == null) return null;

  return CalcResult(
    target: target,
    value: valueRaw.toDouble(),
    unit: unitRaw,
    linearMass: linearMassRaw is num ? linearMassRaw.toDouble() : null,
  );
}
