import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/profiles_data.dart';
import '../data/materials_data.dart';

// ── Ключи SharedPreferences ───────────────────────────────────────────────────
const _kProfiles  = 'order_profiles';
const _kGroups    = 'order_groups';
const _kGradesPfx = 'order_grades_'; // + имя группы

// ── Загрузка ─────────────────────────────────────────────────────────────────

Future<List<String>> loadProfileOrder() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(_kProfiles);
  if (raw == null) return profiles.map((p) => p.name).toList();
  final saved = List<String>.from(jsonDecode(raw));
  // Добавляем новые позиции которых нет в сохранённом списке
  final all = profiles.map((p) => p.name).toList();
  final result = [...saved.where(all.contains), ...all.where((n) => !saved.contains(n))];
  return result;
}

Future<List<String>> loadGroupOrder() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(_kGroups);
  if (raw == null) return metalGroups;
  final saved = List<String>.from(jsonDecode(raw));
  final all = metalGroups;
  return [...saved.where(all.contains), ...all.where((n) => !saved.contains(n))];
}

Future<List<String>> loadGradeOrder(String group) async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString('$_kGradesPfx$group');
  final all = gradesForGroup(group).map((m) => m.grade).toList();
  if (raw == null) return all;
  final saved = List<String>.from(jsonDecode(raw));
  return [...saved.where(all.contains), ...all.where((n) => !saved.contains(n))];
}

// ── Сохранение ────────────────────────────────────────────────────────────────

Future<void> saveProfileOrder(List<String> order) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_kProfiles, jsonEncode(order));
}

Future<void> saveGroupOrder(List<String> order) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_kGroups, jsonEncode(order));
}

Future<void> saveGradeOrder(String group, List<String> order) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('$_kGradesPfx$group', jsonEncode(order));
}

// ── Сброс ─────────────────────────────────────────────────────────────────────

Future<void> resetProfileOrder() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_kProfiles);
}

Future<void> resetGroupOrder() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_kGroups);
}

Future<void> resetGradeOrder(String group) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('$_kGradesPfx$group');
}
