import 'package:flutter/material.dart';

import '../../../widgets/tabler_icon.dart';
import '../models/measurement_models.dart';
import '../services/measurement_history_service.dart';
import 'vision_calculator_screen.dart';

class MeasurementReportScreen extends StatefulWidget {
  final MeasurementReport report;

  const MeasurementReportScreen({
    super.key,
    required this.report,
  });

  @override
  State<MeasurementReportScreen> createState() =>
      _MeasurementReportScreenState();
}

class _MeasurementReportScreenState extends State<MeasurementReportScreen> {
  late MeasurementReport _report;

  @override
  void initState() {
    super.initState();
    _report = widget.report;
  }

  String _fmtLength(double? mm) {
    if (mm == null) return '—';
    if (mm >= 1000) return '${(mm / 1000).toStringAsFixed(3)} м';
    return '${mm.toStringAsFixed(0)} мм';
  }

  String _qualityLabel() {
    if (_report.measurements.isEmpty) return '—';
    final worst = _report.measurements
        .map((e) => e.quality.index)
        .reduce((a, b) => a < b ? a : b);
    return switch (MeasurementQuality.values[worst]) {
      MeasurementQuality.poor => 'Низкое',
      MeasurementQuality.acceptable => 'Допустимое',
      MeasurementQuality.good => 'Хорошее',
    };
  }

  bool get _canTransferToCalculator {
    if (_report.representativeLengthMm == null || _report.quantity < 1) {
      return false;
    }
    return switch (_report.profileName) {
      'Круг' || 'Пруток' => _report.diameterMm != null,
      'Труба кр.' =>
        _report.diameterMm != null && _report.wallThicknessMm != null,
      _ => false,
    };
  }

  Future<void> _changeQuantity(int delta) async {
    final next = (_report.quantity + delta).clamp(1, 99999);
    if (next == _report.quantity) return;
    setState(() => _report = _report.copyWith(quantity: next));
    await upsertMeasurementReport(_report);
  }

  Future<void> _calculateWeight() async {
    if (!_canTransferToCalculator) return;
    await upsertMeasurementReport(_report);
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VisionCalculatorScreen(report: _report),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final lengthMeasurements = _report.measurements
        .where((m) => m.kind == MeasurementKind.length && m.lengthMm != null)
        .toList()
      ..sort((a, b) => b.time.compareTo(a.time));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: TIconAppBar('arrow-left', size: 22),
          onPressed: () => Navigator.pop(context, _report),
        ),
        title: const Text(
          'Отчёт за сессию',
          style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      _report.profileName,
                      style: TextStyle(
                        color: cs.onPrimaryContainer,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Manrope',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _report.materialLabel,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontFamily: 'Manrope',
                      ),
                    ),
                  ),
                  if (_report.diameterMm != null)
                    Text(
                      'Ø${_report.diameterMm!.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontFamily: 'Manrope',
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: Column(
                children: [
                  _InfoRow(
                    label: 'Длина',
                    value: _fmtLength(_report.representativeLengthMm),
                    emphasis: true,
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Количество',
                            style: TextStyle(
                              color: cs.onSurfaceVariant,
                              fontFamily: 'Manrope',
                            ),
                          ),
                        ),
                        IconButton.filledTonal(
                          visualDensity: VisualDensity.compact,
                          onPressed: () => _changeQuantity(-1),
                          icon: const Icon(Icons.remove, size: 18),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            '${_report.quantity} шт',
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton.filledTonal(
                          visualDensity: VisualDensity.compact,
                          onPressed: () => _changeQuantity(1),
                          icon: const Icon(Icons.add, size: 18),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  _InfoRow(
                    label: 'Замеров длины',
                    value: '${lengthMeasurements.length}',
                  ),
                  const Divider(height: 1),
                  _InfoRow(
                    label: 'Погонный вес',
                    value: _report.linearMassKgM == null
                        ? '—'
                        : '${_report.linearMassKgM!.toStringAsFixed(3)} кг/м',
                    emphasis: true,
                  ),
                  const Divider(height: 1),
                  _InfoRow(
                    label: 'Качество',
                    value: _qualityLabel(),
                    emphasis: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Последние замеры',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (lengthMeasurements.isEmpty)
                    Text(
                      'Нет замеров длины',
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontFamily: 'Manrope',
                      ),
                    )
                  else
                    ...lengthMeasurements.take(10).toList().asMap().entries.map(
                          (entry) => ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            leading: Text('${entry.key + 1}.'),
                            title: Text(
                              '${entry.value.lengthMm!.toStringAsFixed(0)} мм',
                              style: TextStyle(
                                color: cs.primary,
                                fontFamily: 'Manrope',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _canTransferToCalculator ? _calculateWeight : null,
            icon: TIcon('calculator', size: 20),
            label: const Text(
              'Рассчитать вес',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w700,
              ),
            ),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
            ),
          ),
          if (!_canTransferToCalculator) ...[
            const SizedBox(height: 6),
            Text(
              'Для передачи в калькулятор нужны длина и размеры профиля.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: cs.onSurfaceVariant,
                fontFamily: 'Manrope',
              ),
            ),
          ],
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () async {
              await upsertMeasurementReport(_report);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Отчёт сохранён')),
              );
            },
            icon: TIcon('device-floppy', size: 20),
            label: const Text('Сохранить отчёт'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasis;

  const _InfoRow({
    required this.label,
    required this.value,
    this.emphasis = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
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
          Text(
            value,
            style: TextStyle(
              color: emphasis ? cs.primary : cs.onSurface,
              fontFamily: 'Manrope',
              fontWeight: emphasis ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
