import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/profiles_data.dart';
import '../data/materials_data.dart';
import '../data/order_prefs.dart';
import '../widgets/tabler_icon.dart';
import 'calc_screen.dart' show AppThemeMode, themeNotifier;

class SettingsScreen extends StatefulWidget {
  /// Вызывается когда порядок изменился — CalcScreen должен перезагрузить списки
  final VoidCallback onOrderChanged;
  const SettingsScreen({super.key, required this.onOrderChanged});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: TIconAppBar('arrow-left', size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Настройки',
            style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // ── Тема ────────────────────────────────────────────────────────────
          _sectionTitle('Тема интерфейса', cs),
          Card(child: ValueListenableBuilder<AppThemeMode>(
            valueListenable: themeNotifier,
            builder: (_, mode, __) => Column(children: [
              _themeOption(context, AppThemeMode.light,  'Светлая',   'sun',              mode),
              const Divider(height: 1, indent: 16),
              _themeOption(context, AppThemeMode.system, 'Системная', 'brightness-auto',  mode),
              const Divider(height: 1, indent: 16),
              _themeOption(context, AppThemeMode.dark,   'Тёмная',    'moon',             mode),
            ]),
          )),
          const SizedBox(height: 20),

          // ── Порядок барабанов ────────────────────────────────────────────────
          _sectionTitle('Порядок в барабанах', cs),
          Card(child: Column(children: [
            _orderTile(context, 'Сортамент', 'category', () => _openOrder(
              context, _OrderType.profiles,
            )),
            const Divider(height: 1, indent: 16),
            _orderTile(context, 'Вид металла', 'layers-difference', () => _openOrder(
              context, _OrderType.groups,
            )),
            const Divider(height: 1, indent: 16),
            _orderTile(context, 'Марки металлов', 'list-details', () => _openOrder(
              context, _OrderType.grades,
            )),
          ])),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text, ColorScheme cs) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: TextStyle(
      fontSize: 12, fontWeight: FontWeight.w600,
      color: cs.primary, fontFamily: 'Manrope',
      letterSpacing: 0.5,
    )),
  );

  Widget _themeOption(BuildContext ctx, AppThemeMode mode, String label,
      String icon, AppThemeMode current) {
    final cs = Theme.of(ctx).colorScheme;
    final selected = mode == current;
    return InkWell(
      onTap: () => themeNotifier.set(mode),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(children: [
          TIcon(icon, size: 20, color: selected ? cs.primary : cs.onSurfaceVariant),
          const SizedBox(width: 14),
          Expanded(child: Text(label, style: TextStyle(
            fontSize: 15, fontFamily: 'Manrope',
            color: selected ? cs.primary : cs.onSurface,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ))),
          if (selected) TIcon('check', size: 20, color: cs.primary),
        ]),
      ),
    );
  }

  Widget _orderTile(BuildContext ctx, String label, String icon, VoidCallback onTap) {
    final cs = Theme.of(ctx).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(children: [
          TIcon(icon, size: 20, color: cs.onSurfaceVariant),
          const SizedBox(width: 14),
          Expanded(child: Text(label, style: const TextStyle(
            fontSize: 15, fontFamily: 'Manrope',
          ))),
          TIcon('chevron-right', size: 18, color: cs.onSurfaceVariant),
        ]),
      ),
    );
  }

  Future<void> _openOrder(BuildContext ctx, _OrderType type) async {
    if (type == _OrderType.grades) {
      // Для марок сначала выбираем группу
      final groups = await loadGroupOrder();
      if (!mounted) return;
      await showModalBottomSheet(
        context: ctx,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        builder: (_) => _GroupPickerSheet(
          groups: groups,
          onGroupSelected: (g) async {
            Navigator.pop(ctx);
            await Navigator.push(ctx, MaterialPageRoute(
              builder: (_) => _ReorderScreen(
                title: 'Марки · $g',
                loader: () => loadGradeOrder(g),
                saver: (list) => saveGradeOrder(g, list),
                resetter: () => resetGradeOrder(g),
                onChanged: widget.onOrderChanged,
              ),
            ));
          },
        ),
      );
    } else {
      await Navigator.push(ctx, MaterialPageRoute(
        builder: (_) => _ReorderScreen(
          title: type == _OrderType.profiles ? 'Порядок сортамента' : 'Порядок видов металла',
          loader: type == _OrderType.profiles ? loadProfileOrder : loadGroupOrder,
          saver: type == _OrderType.profiles ? saveProfileOrder : saveGroupOrder,
          resetter: type == _OrderType.profiles ? resetProfileOrder : resetGroupOrder,
          onChanged: widget.onOrderChanged,
        ),
      ));
    }
  }
}

enum _OrderType { profiles, groups, grades }

// ── Выбор группы для настройки марок ─────────────────────────────────────────
class _GroupPickerSheet extends StatelessWidget {
  final List<String> groups;
  final void Function(String) onGroupSelected;
  const _GroupPickerSheet({required this.groups, required this.onGroupSelected});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        margin: const EdgeInsets.only(top: 10, bottom: 4),
        width: 36, height: 4,
        decoration: BoxDecoration(color: cs.outlineVariant,
            borderRadius: BorderRadius.circular(2)),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Text('Выберите металл', style: TextStyle(
          fontSize: 15, fontWeight: FontWeight.w600, fontFamily: 'Manrope',
          color: cs.onSurface,
        )),
      ),
      const Divider(height: 1),
      Flexible(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: groups.length,
          itemBuilder: (_, i) => InkWell(
            onTap: () => onGroupSelected(groups[i]),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(children: [
                Expanded(child: Text(groups[i], style: const TextStyle(
                  fontSize: 15, fontFamily: 'Manrope',
                ))),
                TIcon('chevron-right', size: 18, color: cs.onSurfaceVariant),
              ]),
            ),
          ),
        ),
      ),
      const SizedBox(height: 16),
    ]);
  }
}

// ── Экран перетаскивания ──────────────────────────────────────────────────────
class _ReorderScreen extends StatefulWidget {
  final String title;
  final Future<List<String>> Function() loader;
  final Future<void> Function(List<String>) saver;
  final Future<void> Function() resetter;
  final VoidCallback onChanged;

  const _ReorderScreen({
    required this.title,
    required this.loader,
    required this.saver,
    required this.resetter,
    required this.onChanged,
  });

  @override
  State<_ReorderScreen> createState() => _ReorderScreenState();
}

class _ReorderScreenState extends State<_ReorderScreen> {
  List<String> _items = [];
  bool _loading = true;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await widget.loader();
    setState(() { _items = items; _loading = false; });
  }

  Future<void> _save() async {
    await widget.saver(_items);
    widget.onChanged();
    setState(() => _dirty = false);
  }

  Future<void> _reset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Сбросить порядок?',
            style: TextStyle(fontFamily: 'Manrope')),
        content: const Text('Вернуть исходный порядок позиций.',
            style: TextStyle(fontFamily: 'Manrope')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена', style: TextStyle(fontFamily: 'Manrope')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Сбросить', style: TextStyle(fontFamily: 'Manrope')),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await widget.resetter();
    widget.onChanged();
    await _load();
    setState(() => _dirty = false);
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
        title: Text(widget.title,
            style: const TextStyle(
                fontFamily: 'Manrope', fontWeight: FontWeight.w700)),
        actions: [
          // Кнопка сброса
          IconButton(
            icon: TIconAppBar('rotate', size: 22),
            tooltip: 'Сбросить порядок',
            onPressed: _reset,
          ),
          // Кнопка сохранения — только если были изменения
          if (_dirty)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilledButton(
                onPressed: _save,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: const StadiumBorder(),
                ),
                child: const Text('Сохранить',
                    style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w600)),
              ),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(children: [
                  TIcon('grip-vertical', size: 16, color: cs.onSurfaceVariant.withOpacity(0.5)),
                  const SizedBox(width: 8),
                  Text('Удерживайте и перетаскивайте для изменения порядка',
                      style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant,
                          fontFamily: 'Manrope')),
                ]),
              ),
              const Divider(height: 1),
              Expanded(
                child: ReorderableListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _items.length,
                  onReorder: (oldIndex, newIndex) {
                    HapticFeedback.selectionClick();
                    setState(() {
                      if (newIndex > oldIndex) newIndex--;
                      final item = _items.removeAt(oldIndex);
                      _items.insert(newIndex, item);
                      _dirty = true;
                    });
                  },
                  itemBuilder: (_, i) {
                    final item = _items[i];
                    return ListTile(
                      key: ValueKey(item),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 2),
                      leading: Text(
                        '${i + 1}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: cs.primary.withOpacity(0.6),
                          fontFamily: 'Manrope',
                        ),
                      ),
                      title: Text(item, style: const TextStyle(
                        fontSize: 15, fontFamily: 'Manrope',
                      )),
                      trailing: ReorderableDragStartListener(
                        index: i,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: TIcon('grip-vertical', size: 22,
                              color: cs.onSurfaceVariant.withOpacity(0.4)),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ]),
    );
  }
}
