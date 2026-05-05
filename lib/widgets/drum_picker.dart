import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/materials_data.dart';
import '../widgets/tabler_icon.dart';

// ── Цвета металлов ───────────────────────────────────────────────────────────
const Map<String, _MetalColor> _metalColors = {
  'Сталь':      _MetalColor(bg: Color(0xFF212121), text: Color(0xFFFFFFFF)),
  'Нержавейка': _MetalColor(bg: Color(0xFFB0BEC5), text: Color(0xFF1A1A1A)),
  'Алюминий':   _MetalColor(bg: Color(0xFFEEEEEE), text: Color(0xFF1A1A1A)),
  'Латунь':     _MetalColor(bg: Color(0xFFB8960C), text: Color(0xFF1A1A1A)),
  'Медь':       _MetalColor(bg: Color(0xFFB05A2A), text: Color(0xFFFFFFFF)),
  'Бронза':     _MetalColor(bg: Color(0xFF8D6228), text: Color(0xFFFFFFFF)),
  'Титан':      _MetalColor(bg: Color(0xFF546E7A), text: Color(0xFFFFFFFF)),
  'Никель':     _MetalColor(bg: Color(0xFF9E9E9E), text: Color(0xFF1A1A1A)),
  'Нихром':     _MetalColor(bg: Color(0xFF4E4E4E), text: Color(0xFFFFFFFF)),
  'Вольфрам':   _MetalColor(bg: Color(0xFF37474F), text: Color(0xFFFFFFFF)),
  'Молибден':   _MetalColor(bg: Color(0xFF455A64), text: Color(0xFFFFFFFF)),
  'Цинк':       _MetalColor(bg: Color(0xFF78909C), text: Color(0xFF1A1A1A)),
  'Цирконий':   _MetalColor(bg: Color(0xFF607D8B), text: Color(0xFFFFFFFF)),
};
class _MetalColor {
  final Color bg;
  final Color text;
  const _MetalColor({required this.bg, required this.text});
}

// ── DrumPicker ───────────────────────────────────────────────────────────────
class DrumPicker<T> extends StatefulWidget {
  final List<T> items;
  final T? selectedItem;
  final String Function(T) labelBuilder;
  final ValueChanged<T> onChanged;
  final double itemHeight;
  final String? Function(T)? groupKey;
  const DrumPicker({
    super.key,
    required this.items,
    required this.selectedItem,
    required this.labelBuilder,
    required this.onChanged,
    this.itemHeight = 48,
    this.groupKey,
  });
  @override
  State<DrumPicker<T>> createState() => _DrumPickerState<T>();
}

class _DrumPickerState<T> extends State<DrumPicker<T>> {
  late FixedExtentScrollController _ctrl;
  int _idx = 0;

  @override
  void initState() {
    super.initState();
    _idx = _findIndex(widget.selectedItem);
    _ctrl = FixedExtentScrollController(initialItem: _idx);
  }

  int _findIndex(T? item) {
    if (item == null) return 0;
    final i = widget.items.indexOf(item);
    return i < 0 ? 0 : i;
  }

  @override
  void didUpdateWidget(DrumPicker<T> old) {
    super.didUpdateWidget(old);
    if (widget.items != old.items || widget.selectedItem != old.selectedItem) {
      final target = _findIndex(widget.selectedItem);
      _idx = target;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_ctrl.hasClients) _ctrl.jumpToItem(_idx);
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = cs.surface;

    return SizedBox(
      height: widget.itemHeight * 5,
      child: Stack(
        children: [
          // 1. Барабан — свободное вращение с инерцией (ничем не блокируется)
          ListWheelScrollView.useDelegate(
            controller: _ctrl,
            itemExtent: widget.itemHeight,
            perspective: 0.003,
            diameterRatio: 2.5,
            physics: const FixedExtentScrollPhysics(), // Чистая инерция + привязка к элементам
            onSelectedItemChanged: (i) {
              HapticFeedback.selectionClick(); // Вибрация на КАЖДЫЙ шаг
              setState(() => _idx = i);
              widget.onChanged(widget.items[i]);
            },
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: widget.items.length,
              builder: (_, i) {
                final sel = i == _idx;
                final label = widget.labelBuilder(widget.items[i]);
                final grpKey = widget.groupKey?.call(widget.items[i]);
                final mc = grpKey != null ? _metalColors[grpKey] : null;
                Color textColor;
                Color? rowBg;
                if (sel && mc != null) {
                  rowBg = mc.bg;
                  textColor = mc.text;
                } else if (sel) {
                  textColor = cs.primary;
                } else {
                  textColor = isDark
                      ? cs.onSurface.withOpacity(0.28)
                      : cs.onSurface.withOpacity(0.22);
                }
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: rowBg != null
                      ? BoxDecoration(
                          color: rowBg,
                          borderRadius: BorderRadius.circular(8),
                        )
                      : null,
                  child: Center(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: sel ? 17 : 14,
                        fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                        color: textColor,
                        fontFamily: 'Manrope',
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // 2. Слой обработки тапов по Y-координате
          // Ключевое: onTapUp (не onTapDown!) — срабатывает ТОЛЬКО если не было свайпа
          // Это гарантирует, что вертикальный драг уходит в ListWheelScrollView
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTapUp: (details) {
                final dy = details.localPosition.dy;
                final centerY = widget.itemHeight * 2.5;
                // Смещение от центра в единицах itemHeight
                final offsetItems = ((dy - centerY) / widget.itemHeight).round();
                final targetIndex = (_idx + offsetItems).clamp(0, widget.items.length - 1);

                if (targetIndex != _idx && _ctrl.hasClients) {
                  HapticFeedback.selectionClick();
                  _ctrl.animateToItem(
                    targetIndex,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                  );
                }
              },
              // Не добавляем onVerticalDrag* — они автоматически проходят сквозь
            ),
          ),

          // 3. Градиенты затемнения сверху/снизу
          Positioned(top: 0, left: 0, right: 0, height: widget.itemHeight * 2,
              child: IgnorePointer(child: Container(decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [bg, bg.withOpacity(0)],
              ))))),
          Positioned(bottom: 0, left: 0, right: 0, height: widget.itemHeight * 2,
              child: IgnorePointer(child: Container(decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter,
                    colors: [bg, bg.withOpacity(0)],
              ))))),

          // 4. Линии + стрелка Tabler по центру
          Positioned(
            top: widget.itemHeight * 2,
            left: 0, right: 0,
            height: widget.itemHeight,
            child: IgnorePointer(child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: 4),
                TIcon('arrow-badge-right', size: 22, color: cs.primary),
                Expanded(child: Container(decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: cs.primary.withOpacity(0.4), width: 1),
                    bottom: BorderSide(color: cs.primary.withOpacity(0.4), width: 1),
                  ),
                ))),
                const SizedBox(width: 24),
              ],
            )),
          ),
        ],
      ),
    );
  }
}

// ── Кнопка подтверждения ─────────────────────────────────────────────────────
class _ConfirmButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _ConfirmButton({required this.onPressed});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 11),
        decoration: BoxDecoration(
          color: cs.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          TIcon(isDark ? 'circle-check-filled' : 'circle-check', size: 20, color: cs.onPrimary),
          const SizedBox(width: 8),
          Text('Выбрать', style: TextStyle(
            fontSize: 15, fontWeight: FontWeight.w600,
            color: cs.onPrimary, fontFamily: 'Manrope',
          )),
        ]),
      ),
    );
  }
}

// ── Диалог: одиночный барабан ─────────────────────────────────────────────────
Future<void> showSingleDrumDialog<T>({
  required BuildContext context,
  required String title,
  required List<T> items,
  required T? selected,
  required String Function(T) label,
  required ValueChanged<T> onChanged,
  String? Function(T)? groupKey,
}) {
  HapticFeedback.mediumImpact();
  T cur = selected ?? items.first;
  return showDialog(
    context: context,
    barrierColor: Colors.black54,
    builder: (_) => StatefulBuilder(builder: (ctx, ss) {
      final cs = Theme.of(ctx).colorScheme;
      return Center(
        child: Material(
          borderRadius: BorderRadius.circular(20),
          color: cs.surface,
          elevation: 8,
          child: SizedBox(
            width: MediaQuery.of(ctx).size.width * 0.88,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const SizedBox(height: 16),
              Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
                  fontFamily: 'Manrope', color: cs.onSurface)),
              const SizedBox(height: 8),
              const Divider(height: 1),
              DrumPicker<T>(
                items: items, selectedItem: cur,
                labelBuilder: label, groupKey: groupKey,
                onChanged: (v) { ss(() => cur = v); onChanged(v); },
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  _ConfirmButton(onPressed: () => Navigator.pop(ctx)),
                ]),
              ),
            ]),
          ),
        ),
      );
    }),
  );
}

// ── Диалог: двойной барабан (металл + марка) ──────────────────────────────────
Future<void> showTwoDrumDialog({
  required BuildContext context,
  required List<String> groups,
  required String selectedGroup,
  required List<String> grades,
  required String selectedGrade,
  required ValueChanged<String> onGroupChanged,
  required ValueChanged<String> onGradeChanged,
  Future<List<String>> Function(String group)? gradeLoader,
}) {
  HapticFeedback.mediumImpact();
  String curGroup = selectedGroup;
  String curGrade = selectedGrade;
  List<String> curGrades = List.from(grades);
  return showDialog(
    context: context,
    barrierColor: Colors.black54,
    builder: (_) => StatefulBuilder(builder: (ctx, ss) {
      final cs = Theme.of(ctx).colorScheme;
      return Center(
        child: Material(
          borderRadius: BorderRadius.circular(20),
          color: cs.surface,
          elevation: 8,
          child: SizedBox(
            width: MediaQuery.of(ctx).size.width * 0.92,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const SizedBox(height: 16),
              Text('Металл и марка', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
                  fontFamily: 'Manrope', color: cs.onSurface)),
              const SizedBox(height: 8),
              const Divider(height: 1),
              Row(children: [
                Expanded(flex: 5, child: DrumPicker<String>(
                  items: groups, selectedItem: curGroup,
                  labelBuilder: (s) => s,
                  groupKey: (s) => s,
                  onChanged: (g) async {
                    final newGrades = gradeLoader != null
                        ? await gradeLoader(g)
                        : gradesForGroup(g).map((m) => m.grade).toList();
                    ss(() {
                      curGroup = g;
                      curGrades = newGrades;
                      curGrade = newGrades.isNotEmpty ? newGrades.first : '';
                    });
                    onGroupChanged(g);
                    if (newGrades.isNotEmpty) onGradeChanged(newGrades.first);
                  },
                )),
                Container(width: 1, height: 240, color: cs.outlineVariant),
                Expanded(flex: 6, child: DrumPicker<String>(
                  key: ValueKey(curGroup),
                  items: curGrades,
                  selectedItem: curGrades.contains(curGrade) ? curGrade
                      : (curGrades.isNotEmpty ? curGrades.first : null),
                  labelBuilder: (s) => s,
                  onChanged: (g) { ss(() => curGrade = g); onGradeChanged(g); },
                )),
              ]),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  _ConfirmButton(onPressed: () => Navigator.pop(ctx)),
                ]),
              ),
            ]),
          ),
        ),
      );
    }),
  );
}

// ── Алиасы обратной совместимости ────────────────────────────────────────────
Future<void> showSingleDrumSheet<T>({
  required BuildContext context,
  required String title,
  required List<T> items,
  required T? selected,
  required String Function(T) label,
  required ValueChanged<T> onChanged,
}) => showSingleDrumDialog<T>(
  context: context, title: title, items: items,
  selected: selected, label: label, onChanged: onChanged,
);

Future<void> showTwoDrumSheet({
  required BuildContext context,
  required List<String> groups,
  required String selectedGroup,
  required List<String> grades,
  required String selectedGrade,
  required ValueChanged<String> onGroupChanged,
  required ValueChanged<String> onGradeChanged,
  Future<List<String>> Function(String group)? gradeLoader,
}) => showTwoDrumDialog(
  context: context, groups: groups, selectedGroup: selectedGroup,
  grades: grades, selectedGrade: selectedGrade,
  onGroupChanged: onGroupChanged, onGradeChanged: onGradeChanged,
  gradeLoader: gradeLoader,
);