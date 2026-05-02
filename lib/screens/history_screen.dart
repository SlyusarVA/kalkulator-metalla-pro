import 'package:flutter/material.dart';
import '../models/models.dart';
import '../logic/calculator.dart';
import '../widgets/tabler_icon.dart';

class HistoryScreen extends StatelessWidget {
  final List<HistoryEntry> history;
  final void Function(HistoryEntry)? onRestore;

  const HistoryScreen({
    super.key,
    required this.history,
    this.onRestore,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: TIconAppBar('arrow-left', size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('История расчётов',
            style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w700)),
      ),
      body: history.isEmpty
          ? Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                TIcon('history', size: 48, color: cs.onSurfaceVariant.withOpacity(0.3)),
                const SizedBox(height: 12),
                Text('Нет расчётов',
                    style: TextStyle(color: cs.onSurfaceVariant, fontFamily: 'Manrope')),
              ]),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: history.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (ctx, i) {
                final e = history[i];
                final qty = e.inputs[kQuantity]?.toInt() ?? 1;

                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: onRestore == null ? null : () {
                    onRestore!(e);
                    Navigator.pop(context);
                  },
                  child: Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Шапка: сортамент + материал + время
                          Row(children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: cs.primaryContainer,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(e.profileName,
                                  style: TextStyle(fontSize: 11,
                                      color: cs.onPrimaryContainer,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Manrope')),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(e.materialLabel,
                                  style: TextStyle(fontSize: 11,
                                      color: cs.onSurfaceVariant,
                                      fontFamily: 'Manrope'),
                                  overflow: TextOverflow.ellipsis),
                            ),
                            Text(_timeStr(e.time),
                                style: TextStyle(fontSize: 10,
                                    color: cs.onSurfaceVariant,
                                    fontFamily: 'Manrope')),
                          ]),
                          const SizedBox(height: 6),

                          // Результат + количество в одной строке
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(_resultStr(e.result),
                                  style: TextStyle(fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: cs.primary,
                                      fontFamily: 'Manrope')),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: cs.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text('$qty шт',
                                    style: TextStyle(fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: cs.onSurfaceVariant,
                                        fontFamily: 'Manrope')),
                              ),
                            ],
                          ),

                          // Погонный вес / вес 1 шт
                          if (e.result.linearMass != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                e.result.target == CalcTarget.mass
                                    ? 'Погонный вес: ${e.result.linearMass!.toStringAsFixed(4)} кг/м'
                                    : '1 шт = ${e.result.linearMass!.toStringAsFixed(3)} кг',
                                style: TextStyle(fontSize: 11,
                                    color: cs.onSurfaceVariant,
                                    fontFamily: 'Manrope'),
                              ),
                            ),

                          // Подсказка что можно восстановить
                          if (onRestore != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Row(children: [
                                TIcon('restore', size: 13,
                                    color: cs.primary.withOpacity(0.5)),
                                const SizedBox(width: 4),
                                Text('Нажмите чтобы восстановить',
                                    style: TextStyle(fontSize: 10,
                                        color: cs.primary.withOpacity(0.5),
                                        fontFamily: 'Manrope')),
                              ]),
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
    if (t.day == now.day) {
      return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    }
    return '${t.day}.${t.month.toString().padLeft(2, '0')}';
  }
}
