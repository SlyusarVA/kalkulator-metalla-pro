import 'package:flutter/material.dart';
import '../models/models.dart';
import '../logic/calculator.dart';

class HistoryScreen extends StatelessWidget {
  final List<HistoryEntry> history;
  const HistoryScreen({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('История расчётов')),
      body: history.isEmpty
          ? const Center(child: Text('Нет расчётов'))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: history.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (ctx, i) {
                final e = history[i];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: cs.primaryContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(e.profileName,
                              style: TextStyle(fontSize: 11, color: cs.onPrimaryContainer,
                                  fontWeight: FontWeight.w500)),
                        ),
                        const SizedBox(width: 6),
                        Expanded(child: Text(e.materialLabel,
                            style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                            overflow: TextOverflow.ellipsis)),
                        Text(_timeStr(e.time),
                            style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant)),
                      ]),
                      const SizedBox(height: 6),
                      Text(_resultStr(e.result),
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700,
                              color: cs.primary)),
                      if (e.result.linearMass != null)
                        Text(
                          e.result.target == CalcTarget.mass
                              ? 'Погонный вес: ${e.result.linearMass!.toStringAsFixed(4)} кг/м'
                              : '1 шт = ${e.result.linearMass!.toStringAsFixed(3)} кг',
                          style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                        ),
                    ]),
                  ),
                );
              },
            ),
    );
  }

  String _resultStr(CalcResult r) {
    switch (r.target) {
      case CalcTarget.mass:     return '${r.value.toStringAsFixed(3)} кг';
      case CalcTarget.length:   return '${r.value.toStringAsFixed(2)} м';
      case CalcTarget.quantity: return '${r.value.ceil()} шт';
      case CalcTarget.none:     return '';
    }
  }

  String _timeStr(DateTime t) {
    final now = DateTime.now();
    if (now.difference(t).inMinutes < 1) return 'только что';
    if (t.day == now.day) return '${t.hour.toString().padLeft(2,'0')}:${t.minute.toString().padLeft(2,'0')}';
    return '${t.day}.${t.month.toString().padLeft(2,'0')}';
  }
}
