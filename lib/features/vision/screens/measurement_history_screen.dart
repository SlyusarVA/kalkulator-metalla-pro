import 'package:flutter/material.dart';

import '../../../widgets/tabler_icon.dart';
import '../models/measurement_models.dart';
import '../services/measurement_history_service.dart';
import 'measurement_report_screen.dart';

class MeasurementHistoryScreen extends StatefulWidget {
  const MeasurementHistoryScreen({super.key});

  @override
  State<MeasurementHistoryScreen> createState() =>
      _MeasurementHistoryScreenState();
}

class _MeasurementHistoryScreenState extends State<MeasurementHistoryScreen> {
  List<MeasurementReport> _reports = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final reports = await loadMeasurementHistory();
    if (!mounted) return;
    setState(() {
      _reports = reports;
      _loading = false;
    });
  }

  String _date(DateTime time) =>
      '${time.day.toString().padLeft(2, '0')}.${time.month.toString().padLeft(2, '0')}';

  String _length(double? mm) {
    if (mm == null) return '—';
    return '${(mm / 1000).toStringAsFixed(3)} м';
  }

  String _profileDetails(MeasurementReport report) {
    if (report.diameterMm == null) return report.materialLabel;
    if (report.wallThicknessMm != null) {
      return '${report.materialLabel} · Ø${report.diameterMm!.toStringAsFixed(0)}×${report.wallThicknessMm!.toStringAsFixed(0)}';
    }
    return '${report.materialLabel} · Ø${report.diameterMm!.toStringAsFixed(0)}';
  }

  Future<void> _open(MeasurementReport report) async {
    await Navigator.push<MeasurementReport>(
      context,
      MaterialPageRoute(
        builder: (_) => MeasurementReportScreen(report: report),
      ),
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: TIconAppBar('arrow-left', size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'История замеров',
          style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w700),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _reports.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TIcon(
                        'ruler-measure',
                        size: 48,
                        color: cs.onSurfaceVariant.withOpacity(0.3),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Нет сохранённых замеров',
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontFamily: 'Manrope',
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: _reports.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final report = _reports[index];
                    return InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _open(report),
                      child: Card(
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: cs.primaryContainer,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      report.profileName,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: cs.onPrimaryContainer,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Manrope',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      _profileDetails(report),
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: cs.onSurfaceVariant,
                                        fontFamily: 'Manrope',
                                      ),
                                    ),
                                  ),
                                  Text(
                                    _date(report.createdAt),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: cs.onSurfaceVariant,
                                      fontFamily: 'Manrope',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    _length(report.representativeLengthMm),
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: cs.primary,
                                      fontFamily: 'Manrope',
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: cs.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '${report.quantity} шт',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: cs.onSurfaceVariant,
                                        fontFamily: 'Manrope',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (report.linearMassKgM != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    'Погонный вес: ${report.linearMassKgM!.toStringAsFixed(4)} кг/м',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: cs.onSurfaceVariant,
                                      fontFamily: 'Manrope',
                                    ),
                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Row(
                                  children: [
                                    TIcon(
                                      'file-description',
                                      size: 13,
                                      color: cs.primary.withOpacity(0.5),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Нажмите чтобы открыть отчёт',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: cs.primary.withOpacity(0.5),
                                        fontFamily: 'Manrope',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
