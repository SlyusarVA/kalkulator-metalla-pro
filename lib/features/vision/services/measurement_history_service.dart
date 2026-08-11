import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/measurement_models.dart';

const _measurementHistoryKey = 'vision_measurement_history_v1';

Future<List<MeasurementReport>> loadMeasurementHistory() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(_measurementHistoryKey);
  if (raw == null || raw.isEmpty) return [];

  try {
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => MeasurementReport.fromJson(
              Map<String, dynamic>.from(e as Map),
            ))
        .toList();
  } catch (_) {
    return [];
  }
}

Future<void> saveMeasurementHistory(List<MeasurementReport> reports) async {
  final prefs = await SharedPreferences.getInstance();
  final payload = jsonEncode(reports.map((e) => e.toJson()).toList());
  await prefs.setString(_measurementHistoryKey, payload);
}

Future<void> upsertMeasurementReport(MeasurementReport report) async {
  final reports = await loadMeasurementHistory();
  final index = reports.indexWhere((e) => e.id == report.id);
  if (index >= 0) {
    reports[index] = report;
  } else {
    reports.insert(0, report);
  }
  if (reports.length > 100) {
    reports.removeRange(100, reports.length);
  }
  await saveMeasurementHistory(reports);
}
