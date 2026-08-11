import 'package:flutter/material.dart';

import '../../../data/materials_data.dart';
import '../../../data/profiles_data.dart';
import '../../../logic/calculator.dart';
import '../../../models/models.dart';
import '../../../services/history_service.dart';
import '../../../widgets/tabler_icon.dart';
import '../models/measurement_models.dart';

class VisionCalculatorScreen extends StatefulWidget {
  final MeasurementReport report;

  const VisionCalculatorScreen({
    super.key,
    required this.report,
  });

  @override
  State<VisionCalculatorScreen> createState() => _VisionCalculatorScreenState();
}

class _VisionCalculatorScreenState extends State<VisionCalculatorScreen> {
  late final MetalProfile _profile;
  late final MetalMaterial _material;
  late final Map<String, double?> _inputs;
  CalcResult? _result;
  CalcError? _error;

  @override
  void initState() {
    super.initState();
    _profile = profiles.firstWhere(
      (p) => p.name == widget.report.profileName,
      orElse: () => profiles.first,
    );

    _material = _resolveMaterial(widget.report.materialLabel);
    _inputs = <String, double?>{};

    for (final param in _profile.params) {
      _inputs[param.key] = param.defaultValue;
    }

    if (widget.report.diameterMm != null && _inputs.containsKey('d')) {
      _inputs['d'] = widget.report.diameterMm;
    }
    if (widget.report.wallThicknessMm != null && _inputs.containsKey('t')) {
      _inputs['t'] = widget.report.wallThicknessMm;
    }

    _inputs[kLength] = widget.report.representativeLengthMm == null
        ? null
        : widget.report.representativeLengthMm! / 1000.0;
    _inputs[kQuantity] = widget.report.quantity.toDouble();
    _inputs[kMass] = null;

    _calculate();
  }

  MetalMaterial _resolveMaterial(String label) {
    final parts = label.split(' · ');
    if (parts.length >= 2) {
      final group = parts.first.trim();
      final grade = parts.sublist(1).join(' · ').trim();
      final exact = materials
          .where((m) => m.group == group && m.grade == grade)
          .toList();
      if (exact.isNotEmpty) return exact.first;

      final byGrade = materials.where((m) => m.grade == grade).toList();
      if (byGrade.isNotEmpty) return byGrade.first;
    }
    return materials.first;
  }

  void _calculate() {
    final res = Calculator.calculate(
      profile: _profile,
      density: _material.density,
      inputs: Map<String, double?>.from(_inputs),
    );

    if (res is CalcResult) {
      _result = res;
      _error = null;
    } else {
      _result = null;
      _error = res as CalcError;
    }
  }

  Future<void> _saveToHistory() async {
    final result = _result;
    if (result == null) return;

    final history = await loadHistory();
    history.insert(
      0,
      HistoryEntry(
        time: DateTime.now(),
        profileName: _profile.name,
        materialLabel: '${_material.group} · ${_material.grade}',
        inputs: _inputs.map((key, value) => MapEntry(key, value ?? 0)),
        result: result,
      ),
    );
    if (history.length > 50) {
      history.removeRange(50, history.length);
    }
    await saveHistory(history);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Расчёт сохранён в историю')),
    );
  }

  String _fmtParam(String key) {
    final value = _inputs[key];
    if (value == null) return '—';
    if (value == value.truncateToDouble()) return value.toInt().toString();
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final result = _result;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: TIconAppBar('arrow-left', size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Калькулятор металла',
          style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: cs.primaryContainer.withOpacity(0.45),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                TIcon('ruler-measure', size: 20, color: cs.primary),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Данные заполнены из отчёта замера',
                    style: TextStyle(fontFamily: 'Manrope'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  _RowValue(label: 'Сортамент', value: _profile.name),
                  const Divider(height: 1),
                  _RowValue(
                    label: 'Материал',
                    value: '${_material.group} · ${_material.grade}',
                  ),
                  for (final param in _profile.params) ...[
                    const Divider(height: 1),
                    _RowValue(
                      label: param.label,
                      value: '${_fmtParam(param.key)} ${param.unit}',
                    ),
                  ],
                  const Divider(height: 1),
                  _RowValue(
                    label: 'Длина',
                    value: _inputs[kLength] == null
                        ? '—'
                        : '${_inputs[kLength]!.toStringAsFixed(3)} м',
                  ),
                  const Divider(height: 1),
                  _RowValue(
                    label: 'Количество',
                    value: '${widget.report.quantity} шт',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (_error != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _error!.message,
                style: TextStyle(
                  color: cs.onErrorContainer,
                  fontFamily: 'Manrope',
                ),
              ),
            ),
          if (result != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'МАССА',
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 0.8,
                      color: cs.onPrimaryContainer.withOpacity(0.7),
                      fontFamily: 'Manrope',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${result.value.toStringAsFixed(3)} кг',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: cs.primary,
                      fontFamily: 'Manrope',
                    ),
                  ),
                  if (result.linearMass != null)
                    Text(
                      'Погонный вес: ${result.linearMass!.toStringAsFixed(4)} кг/м',
                      style: TextStyle(
                        color: cs.onPrimaryContainer.withOpacity(0.7),
                        fontFamily: 'Manrope',
                      ),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: result == null ? null : _saveToHistory,
            icon: TIcon('device-floppy', size: 20),
            label: const Text(
              'Сохранить расчёт',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w700,
              ),
            ),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Вернуться к отчёту'),
          ),
        ],
      ),
    );
  }
}

class _RowValue extends StatelessWidget {
  final String label;
  final String value;

  const _RowValue({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontFamily: 'Manrope',
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
