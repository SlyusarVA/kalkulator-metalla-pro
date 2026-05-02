import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/profiles_data.dart';
import '../data/materials_data.dart';
import '../data/gost_sizes.dart';
import '../data/gost_reference.dart';
import '../data/order_prefs.dart';
import '../models/models.dart';
import '../logic/calculator.dart';
import '../widgets/drum_picker.dart';
import '../widgets/tabler_icon.dart';
import 'history_screen.dart';
import 'gost_reference_screen.dart';
import 'settings_screen.dart';

// ── Допуски по весу ГОСТ ─────────────────────────────────────────────────────
const Map<String, double> _gostWeightTolerance = {
  'Круг':           0.025,
  'Арматура':       0.040,
  'Квадрат':        0.025,
  'Шестигранник':   0.025,
  'Полоса':         0.040,
  'Лента':          0.040,
  'Труба кр.':      0.075,
  'Труба проф.':    0.060,
  'Балка':          0.030,
  'Швеллер':        0.030,
  'Уголок равн.':   0.040,
  'Уголок неравн.': 0.040,
  'Пруток':         0.010,
};

// ── Настройка темы ───────────────────────────────────────────────────────────
enum AppThemeMode { light, system, dark }

class ThemeNotifier extends ValueNotifier<AppThemeMode> {
  ThemeNotifier() : super(AppThemeMode.system) { _load(); }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getInt('theme_mode') ?? 1;
    value = AppThemeMode.values[v.clamp(0, 2)];
  }

  Future<void> set(AppThemeMode m) async {
    value = m;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', m.index);
  }

  ThemeMode get flutterMode => switch (value) {
    AppThemeMode.light  => ThemeMode.light,
    AppThemeMode.system => ThemeMode.system,
    AppThemeMode.dark   => ThemeMode.dark,
  };
}

final themeNotifier = ThemeNotifier();

// ── CalcScreen ───────────────────────────────────────────────────────────────
class CalcScreen extends StatefulWidget {
  const CalcScreen({super.key});
  @override
  State<CalcScreen> createState() => _CalcScreenState();
}

class _CalcScreenState extends State<CalcScreen> {
  late MetalProfile _profile;
  late MetalMaterial _material;
  List<String> _groups = metalGroups;         // порядок из настроек
  List<MetalProfile> _orderedProfiles = [];    // порядок из настроек

  final Map<String, double?> _values = {};
  final Map<String, TextEditingController> _ctrl = {};

  int _qty = 1;

  CalcResult? _result;
  CalcResult? _prevResult;
  CalcError?  _error;
  bool _unchanged = false;
  final List<HistoryEntry> _history = [];

  @override
  void initState() {
    super.initState();
    _orderedProfiles = List.from(profiles);
    _profile  = _orderedProfiles.first;
    _material = gradesForGroup(_groups.first).first;
    _rebuild();
    themeNotifier.addListener(() => setState(() {}));
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    final profileOrder = await loadProfileOrder();
    final groupOrder   = await loadGroupOrder();
    final ordered = profileOrder
        .map((name) => profiles.firstWhere((p) => p.name == name,
            orElse: () => profiles.first))
        .where((p) => profiles.contains(p))
        .toList();
    setState(() {
      _orderedProfiles = ordered.isEmpty ? List.from(profiles) : ordered;
      _groups = groupOrder;
      // Обновляем текущий профиль если он сдвинулся
      if (!_orderedProfiles.contains(_profile)) {
        _profile = _orderedProfiles.first;
      }
    });
  }

  void _rebuild() {
    _ctrl.forEach((_, c) => c.dispose());
    _ctrl.clear();
    _values.clear();
    _result = null;
    _prevResult = null;
    _error  = null;
    _unchanged = false;
    _qty    = 1;

    for (final p in _profile.params) {
      _values[p.key] = p.defaultValue;
      final c = TextEditingController(text: _fmt(p.defaultValue));
      c.addListener(() => _onText(p.key, c.text));
      _ctrl[p.key] = c;
    }

    if (!_profile.isVolume) {
      _values[kLength] = null;
      final lc = TextEditingController();
      lc.addListener(() => _onText(kLength, lc.text));
      _ctrl[kLength] = lc;
    }

    _values[kMass] = null;
    final mc = TextEditingController();
    mc.addListener(() => _onText(kMass, mc.text));
    _ctrl[kMass] = mc;
  }

  void _onText(String key, String text) {
    final v = double.tryParse(text.replaceAll(',', '.'));
    if (_values[key] != v) {
      setState(() {
        _values[key] = v;
        _result = null;
        _error  = null;
        _unchanged = false;
      });
    }
  }

  String _fmt(double v) =>
      v == v.truncateToDouble() ? v.toInt().toString() : v.toString();

  void _selectProfile() => showSingleDrumDialog<MetalProfile>(
    context: context, title: 'Сортамент',
    items: _orderedProfiles, selected: _profile, label: (p) => p.name,
    onChanged: (p) => setState(() { _profile = p; _rebuild(); }),
  );

  void _selectMaterial() async {
    final grades = await loadGradeOrder(_material.group);
    if (!mounted) return;
    showTwoDrumDialog(
      context: context,
      groups: _groups,
      selectedGroup: _material.group,
      grades: grades,
      selectedGrade: _material.grade,
      onGroupChanged: (g) async {
        final list = gradesForGroup(g);
        if (list.isNotEmpty) setState(() => _material = list.first);
      },
      onGradeChanged: (grade) {
        final found = materials.where((m) => m.grade == grade).toList();
        if (found.isNotEmpty) setState(() => _material = found.first);
      },
      gradeLoader: loadGradeOrder,
    );
  }

  void _openParamDrum(ProfileParam p) {
    final vals = p.key == 't' && _profile.name == 'Труба кр.'
        ? wallThicknessForDiameter(_values['d'] ?? 57)
        : p.drumValues;
    showSingleDrumDialog<double>(
      context: context, title: p.label,
      items: vals, selected: _values[p.key],
      label: (v) => '${_fmt(v)} ${p.unit}',
      onChanged: (v) => setState(() {
        _values[p.key] = v;
        _ctrl[p.key]?.text = _fmt(v);
        _result = null; _error = null; _unchanged = false;
      }),
    );
  }

  // Очищает поле которое было результатом предыдущего расчёта
  void _clearPrevResultField() {
    if (_prevResult == null) return;
    if (_prevResult!.target == CalcTarget.mass) {
      _ctrl[kMass]?.clear();
      _values[kMass] = null;
    } else if (_prevResult!.target == CalcTarget.length) {
      _ctrl[kLength]?.clear();
      _values[kLength] = null;
    }
    _prevResult = null;
  }

  void _restoreFromHistory(HistoryEntry e) {
    final profile = profiles.firstWhere(
      (p) => p.name == e.profileName,
      orElse: () => _profile,
    );
    final parts = e.materialLabel.split(' · ');
    MetalMaterial material = _material;
    if (parts.length == 2) {
      final grade = parts[1];
      final found = materials.where((m) => m.grade == grade).toList();
      if (found.isNotEmpty) material = found.first;
    }
    setState(() { _profile = profile; _material = material; });
    _rebuild();
    setState(() {
      for (final p in profile.params) {
        final v = e.inputs[p.key];
        if (v != null) { _values[p.key] = v; _ctrl[p.key]?.text = _fmt(v); }
      }
      final length = e.inputs[kLength];
      if (length != null && length != 0) {
        _values[kLength] = length; _ctrl[kLength]?.text = _fmt(length);
      }
      if (e.result.target != CalcTarget.mass) {
        final mass = e.inputs[kMass];
        if (mass != null && mass != 0) {
          _values[kMass] = mass; _ctrl[kMass]?.text = _fmt(mass);
        }
      }
      _qty = (e.inputs[kQuantity] ?? 1).toInt();
    });
  }

  void _calculate() {
    // Очищаем поле результата предыдущего расчёта чтобы калькулятор
    // всегда имел одно неизвестное поле для вычисления
    _clearPrevResultField();

    final inputs = Map<String, double?>.from(_values);
    inputs[kQuantity] = _qty.toDouble();

    final res = Calculator.calculate(
      profile: _profile, density: _material.density,
      inputs: inputs,
    );

    setState(() {
      if (res is CalcResult) {
        final same = _prevResult != null &&
            _prevResult!.target == res.target &&
            (_prevResult!.value - res.value).abs() < 0.0001;

        _unchanged = same;
        _prevResult = res;
        _result = res;
        _error = null;

        if (res.target == CalcTarget.mass) {
          _ctrl[kMass]?.text = res.value.toStringAsFixed(3);
          _values[kMass] = res.value;
        } else if (res.target == CalcTarget.length) {
          _ctrl[kLength]?.text = res.value.toStringAsFixed(3);
          _values[kLength] = res.value;
        }

        if (!same) {
          _history.insert(0, HistoryEntry(
            time: DateTime.now(),
            profileName: _profile.name,
            materialLabel: '${_material.group} · ${_material.grade}',
            inputs: {
              ...inputs.map((k, v) => MapEntry(k, v ?? 0)),
              kQuantity: _qty.toDouble(),
            },
            result: res,
          ));
          if (_history.length > 50) _history.removeLast();
        }
      } else {
        _result = null;
        _prevResult = null;
        _unchanged = false;
        _error = res as CalcError;
      }
    });
  }

  double? get _currentTolerance => _gostWeightTolerance[_profile.name];

  @override
  void dispose() {
    _ctrl.forEach((_, c) => c.dispose());
    themeNotifier.removeListener(() => setState(() {}));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: _ThemeMenuButton(),
        title: const Text('Калькулятор металла',
            style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: TIconAppBar('settings', size: 22),
            tooltip: 'Настройки',
            onPressed: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => SettingsScreen(onOrderChanged: _loadOrder),
            )),
          ),
          if (_history.isNotEmpty)
            IconButton(
              icon: Badge(
                label: Text('${_history.length}'),
                child: TIconAppBar('clock-hour-3', size: 22),
              ),
              tooltip: 'История',
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => HistoryScreen(
                    history: _history,
                    onRestore: _restoreFromHistory,
                  ))),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Кнопки выбора сортамента и металла ──────────────────────────────
          Row(children: [
            Expanded(flex: 5, child: _selBtn(
              label: 'Сортамент',
              value: _profile.name,
              onTap: _selectProfile,
              leading: SvgPicture.asset(_profile.iconAsset, width: 32, height: 32,
                colorFilter: ColorFilter.mode(cs.onSurfaceVariant, BlendMode.srcIn)),
            )),
            const SizedBox(width: 8),
            Expanded(flex: 7, child: _selBtn(
              label: _material.group,
              value: _material.grade,
              onTap: _selectMaterial,
            )),
          ]),
          const SizedBox(height: 8),

          // ── ГОСТ-бар ────────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: cs.primaryContainer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Wrap(spacing: 6, runSpacing: 4, children: [
              _GostChip(code: _profile.gost),
              _GostChip(code: _material.gost),
              _chip('ρ = ${_material.density.toStringAsFixed(0)} кг/м³'),
            ]),
          ),
          const SizedBox(height: 12),

          // ── Размеры ──────────────────────────────────────────────────────────
          Card(child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Размеры', style: Theme.of(context).textTheme.titleSmall
                  ?.copyWith(fontFamily: 'Manrope')),
              const SizedBox(height: 10),
              ..._profile.params.map(_paramField),
            ]),
          )),

          // ── Расчётные данные ─────────────────────────────────────────────────
          Card(child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Расчётные данные', style: Theme.of(context).textTheme.titleSmall
                  ?.copyWith(fontFamily: 'Manrope')),
              const SizedBox(height: 10),
              if (!_profile.isVolume) _fieldWithTrash(kLength, 'Длина', 'м'),
              _qtyRow(),
              _fieldWithTrash(kMass, 'Масса', 'кг',
                readOnly: _result?.target == CalcTarget.mass),
            ]),
          )),

          // ── Ошибка ──────────────────────────────────────────────────────────
          if (_error != null)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(color: cs.errorContainer,
                  borderRadius: BorderRadius.circular(10)),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                TIcon('info-circle', size: 18, color: cs.error),
                const SizedBox(width: 8),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_error!.message,
                    style: TextStyle(color: cs.onErrorContainer,
                        fontWeight: FontWeight.w500, fontFamily: 'Manrope')),
                  if (_error!.missingFields.isNotEmpty)
                    Text(_error!.missingFields.join(', '),
                      style: TextStyle(fontSize: 12,
                          color: cs.onErrorContainer.withOpacity(0.8),
                          fontFamily: 'Manrope')),
                ])),
              ]),
            ),

          // ── «Результат не изменился» ─────────────────────────────────────────
          if (_unchanged)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(children: [
                TIcon('info-circle', size: 16, color: cs.onSurfaceVariant),
                const SizedBox(width: 8),
                Text('Результат не изменился',
                  style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant,
                      fontFamily: 'Manrope')),
              ]),
            ),

          // ── Результат ────────────────────────────────────────────────────────
          if (_result != null && !_unchanged)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              decoration: BoxDecoration(color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(16)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_resLabel().toUpperCase(), style: TextStyle(fontSize: 11,
                    color: cs.onPrimaryContainer.withOpacity(0.75),
                    fontWeight: FontWeight.w600, fontFamily: 'Manrope',
                    letterSpacing: 0.8)),
                const SizedBox(height: 2),
                Text(_resValue(), style: TextStyle(fontSize: 30,
                    fontWeight: FontWeight.w700, color: cs.primary, height: 1.1,
                    fontFamily: 'Manrope')),
                if (_result!.linearMass != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    _profile.isVolume
                        ? '1 шт = ${_result!.linearMass!.toStringAsFixed(3)} кг'
                        : 'Погонный вес: ${_result!.linearMass!.toStringAsFixed(4)} кг/м',
                    style: TextStyle(fontSize: 12,
                        color: cs.onPrimaryContainer.withOpacity(0.65),
                        fontFamily: 'Manrope'),
                  ),
                ],
                if (_result!.target == CalcTarget.mass && _currentTolerance != null)
                  _gostToleranceRow(_result!.value, _currentTolerance!),
              ]),
            ),

          // ── Результат (не изменился) ─────────────────────────────────────────
          if (_result != null && _unchanged)
            Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
              decoration: BoxDecoration(
                color: cs.primaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_resLabel().toUpperCase(), style: TextStyle(fontSize: 11,
                    color: cs.onPrimaryContainer.withOpacity(0.6),
                    fontFamily: 'Manrope', letterSpacing: 0.8)),
                Text(_resValue(), style: TextStyle(fontSize: 24,
                    fontWeight: FontWeight.w600, color: cs.primary.withOpacity(0.7),
                    fontFamily: 'Manrope')),
                if (_result!.target == CalcTarget.mass && _currentTolerance != null)
                  _gostToleranceRow(_result!.value, _currentTolerance!),
              ]),
            ),

          const SizedBox(height: 8),
          FilledButton(
            onPressed: _calculate,
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
              shape: const StadiumBorder(),
            ),
            child: const Text('Рассчитать',
                style: TextStyle(fontSize: 16, fontFamily: 'Manrope',
                    fontWeight: FontWeight.w700, letterSpacing: 0.3)),
          ),
          TextButton(
            onPressed: () => setState(_rebuild),
            child: const Text('Очистить поля',
                style: TextStyle(fontFamily: 'Manrope')),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── Допуск ГОСТ ──────────────────────────────────────────────────────────────
  Widget _gostToleranceRow(double mass, double tol) {
    final cs = Theme.of(context).colorScheme;
    final minV = mass * (1 - tol);
    final maxV = mass * (1 + tol);
    final pct = '±${(tol * 100).toStringAsFixed(1)}%';
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Divider(height: 1, color: cs.onPrimaryContainer.withOpacity(0.15)),
      ),
      Text(
        'min ${minV.toStringAsFixed(2)} кг · $pct · max ${maxV.toStringAsFixed(2)} кг',
        style: TextStyle(fontSize: 12, color: cs.onPrimaryContainer.withOpacity(0.8),
            fontFamily: 'Manrope'),
      ),
    ]);
  }

  // ── Строка количества ────────────────────────────────────────────────────────
  Widget _qtyRow() {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        _QtyButton(
          icon: 'minus',
          onTap: () {
            if (_qty > 1) {
              _clearPrevResultField();
              setState(() { _qty--; _result = null; _error = null; _unchanged = false; });
            }
          },
          onLongPress: () {
            HapticFeedback.heavyImpact();
            _clearPrevResultField();
            setState(() { _qty = 1; _result = null; _error = null; _unchanged = false; });
          },
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              border: Border.all(color: cs.outline.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('Количество', style: TextStyle(fontSize: 12,
                  color: cs.onSurfaceVariant, fontFamily: 'Manrope')),
              Text('$_qty шт', style: const TextStyle(fontSize: 16,
                  fontWeight: FontWeight.w600, fontFamily: 'Manrope')),
            ]),
          ),
        ),
        const SizedBox(width: 4),
        _QtyButton(
          icon: 'plus',
          onTap: () {
            _clearPrevResultField();
            setState(() { _qty++; _result = null; _error = null; _unchanged = false; });
          },
          onLongPress: null,
        ),
      ]),
    );
  }

  // ── Поле ввода с корзиной ────────────────────────────────────────────────────
  Widget _fieldWithTrash(String key, String label, String unit,
      {bool readOnly = false}) {
    final cs = Theme.of(context).colorScheme;
    final isRes = _result != null && (
      (key == kMass   && _result!.target == CalcTarget.mass) ||
      (key == kLength && _result!.target == CalcTarget.length)
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Expanded(
          child: TextField(
            controller: _ctrl[key],
            readOnly: readOnly,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: isRes
                ? TextStyle(color: cs.primary, fontWeight: FontWeight.w600,
                    fontFamily: 'Manrope')
                : TextStyle(fontFamily: 'Manrope', color: cs.onSurface),
            decoration: InputDecoration(
              labelText: label, suffixText: unit,
              labelStyle: const TextStyle(fontFamily: 'Manrope'),
              filled: isRes,
              fillColor: isRes ? cs.primaryContainer.withOpacity(0.3) : null,
              hintText: 'пусто — будет рассчитано',
              hintStyle: TextStyle(fontSize: 12, color: cs.onSurface.withOpacity(0.3),
                  fontFamily: 'Manrope'),
            ),
          ),
        ),
        const SizedBox(width: 4),
        SizedBox(
          width: 40, height: 52,
          child: IconButton(
            icon: TIcon('trash', size: 20, color: cs.onSurfaceVariant.withOpacity(0.6)),
            tooltip: 'Очистить поле',
            onPressed: () {
              _ctrl[key]?.clear();
              setState(() {
                _values[key] = null;
                _result = null; _error = null; _unchanged = false;
              });
            },
          ),
        ),
      ]),
    );
  }

  // ── Кнопка выбора (сортамент / металл) ──────────────────────────────────────
  Widget _selBtn({
    required String label,
    required String value,
    required VoidCallback onTap,
    Widget? leading,
  }) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 62,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          if (leading != null) ...[leading, const SizedBox(width: 6)],
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, maxLines: 1, overflow: TextOverflow.clip,
                style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant,
                    fontFamily: 'Manrope')),
              Text(value, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                    fontFamily: 'Manrope', color: cs.onSurface)),
            ],
          )),
          const SizedBox(width: 2),
          TIcon('chevron-down', size: 18, color: cs.primary),
        ]),
      ),
    );
  }

  Widget _paramField(ProfileParam p) {
    final hasDrum = p.hasDrumValues && p.drumValues.isNotEmpty;
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: hasDrum ? () => _openParamDrum(p) : null,
        child: TextField(
          controller: _ctrl[p.key],
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: TextStyle(fontFamily: 'Manrope', color: cs.onSurface),
          decoration: InputDecoration(
            labelText: p.label, suffixText: p.unit,
            labelStyle: const TextStyle(fontFamily: 'Manrope'),
            suffixIcon: hasDrum
                ? Padding(
                    padding: const EdgeInsets.all(10),
                    child: TIcon('chevron-down', size: 18,
                        color: cs.primary.withOpacity(0.6)),
                  )
                : null,
          ),
        ),
      ),
    );
  }

  Widget _chip(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(text, style: TextStyle(
        fontSize: 11, fontWeight: FontWeight.w500,
        color: Theme.of(context).colorScheme.primary,
        fontFamily: 'Manrope')),
  );

  String _resLabel() => switch (_result!.target) {
    CalcTarget.mass     => 'Масса',
    CalcTarget.length   => 'Длина',
    CalcTarget.quantity => 'Количество',
    CalcTarget.none     => '',
  };

  String _resValue() {
    final v = _result!.value;
    return switch (_result!.target) {
      CalcTarget.quantity => '${v.ceil()} шт',
      CalcTarget.length   => '${v.toStringAsFixed(2)} м',
      CalcTarget.mass     => '${v.toStringAsFixed(3)} кг',
      CalcTarget.none     => '',
    };
  }
}

// ── Кнопка темы в AppBar ─────────────────────────────────────────────────────
class _ThemeMenuButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppThemeMode>(
      valueListenable: themeNotifier,
      builder: (ctx, mode, _) {
        final iconName = switch (mode) {
          AppThemeMode.light  => 'sun',
          AppThemeMode.system => 'brightness-auto',
          AppThemeMode.dark   => 'moon',
        };
        return PopupMenuButton<AppThemeMode>(
          icon: TIconAppBar(iconName, size: 22),
          tooltip: 'Тема',
          onSelected: (m) => themeNotifier.set(m),
          itemBuilder: (_) => [
            PopupMenuItem(
              value: AppThemeMode.light,
              child: Row(children: [
                TIcon('sun', size: 18), const SizedBox(width: 10),
                const Text('Светлая', style: TextStyle(fontFamily: 'Manrope')),
              ]),
            ),
            PopupMenuItem(
              value: AppThemeMode.system,
              child: Row(children: [
                TIcon('brightness-auto', size: 18), const SizedBox(width: 10),
                const Text('Системная', style: TextStyle(fontFamily: 'Manrope')),
              ]),
            ),
            PopupMenuItem(
              value: AppThemeMode.dark,
              child: Row(children: [
                TIcon('moon', size: 18), const SizedBox(width: 10),
                const Text('Тёмная', style: TextStyle(fontFamily: 'Manrope')),
              ]),
            ),
          ],
        );
      },
    );
  }
}

// ── Чип ГОСТа с прогресс-заливкой (5 сек → открыть справку) ────────────────
class _GostChip extends StatefulWidget {
  final String code;
  const _GostChip({required this.code});

  @override
  State<_GostChip> createState() => _GostChipState();
}

class _GostChipState extends State<_GostChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  bool _pressing = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    _ctrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) _onComplete();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onComplete() {
    if (!mounted) return;
    HapticFeedback.heavyImpact();
    final ref = findGostReference(widget.code);
    if (ref != null) {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => GostReferenceScreen(ref: ref)));
    }
    _ctrl.reset();
    setState(() => _pressing = false);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onLongPressStart: (_) {
        setState(() => _pressing = true);
        HapticFeedback.selectionClick();
        _ctrl.forward(from: 0);
      },
      onLongPressEnd: (_) {
        if (_ctrl.status != AnimationStatus.completed) {
          _ctrl.reset();
          setState(() => _pressing = false);
        }
      },
      onLongPressCancel: () {
        _ctrl.reset();
        setState(() => _pressing = false);
      },
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Stack(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              color: cs.primary.withOpacity(0.12),
              child: Text(widget.code, style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600,
                fontFamily: 'Manrope', color: cs.primary,
              )),
            ),
            if (_pressing)
              Positioned.fill(
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _ctrl.value,
                  child: Container(color: cs.primary.withOpacity(0.25)),
                ),
              ),
          ]),
        ),
      ),
    );
  }
}

// ── Кнопка +/− ──────────────────────────────────────────────────────────────
class _QtyButton extends StatelessWidget {
  final String icon;    // Tabler icon name
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _QtyButton({
    required this.icon,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () { HapticFeedback.selectionClick(); onTap(); },
      onLongPress: onLongPress,
      child: Container(
        width: 52, height: 52,
        decoration: BoxDecoration(
          color: cs.primaryContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: TIcon(icon, size: 26, color: cs.primary),
        ),
      ),
    );
  }
}
