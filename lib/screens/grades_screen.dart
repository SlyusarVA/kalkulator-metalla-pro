import 'package:flutter/material.dart';
import '../data/materials_data.dart';
import '../models/metal_profile.dart';

class GradesScreen extends StatefulWidget {
  const GradesScreen({super.key});
  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  String _search = '';
  String? _filterGroup;

  List<MetalMaterial> get _filtered {
    var list = materials.where((m) {
      final matchGroup =
          _filterGroup == null || m.group == _filterGroup;
      final matchSearch = _search.isEmpty ||
          m.grade.toLowerCase().contains(_search.toLowerCase()) ||
          m.group.toLowerCase().contains(_search.toLowerCase()) ||
          m.gost.toLowerCase().contains(_search.toLowerCase());
      return matchGroup && matchSearch;
    }).toList();
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final groups = metalGroups;
    final items = _filtered;

    return Scaffold(
      appBar: AppBar(title: const Text('Справочник марок')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Поиск по марке, группе, ГОСТ...',
              prefixIcon: Icon(Icons.search, size: 20),
              isDense: true,
              border: OutlineInputBorder(),
            ),
            onChanged: (s) => setState(() => _search = s),
          ),
        ),
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            children: [
              _chip(context, 'Все', _filterGroup == null,
                  () => setState(() => _filterGroup = null)),
              ...groups.map((g) => _chip(context, g, _filterGroup == g,
                  () => setState(() => _filterGroup = g))),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(10),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 4),
            itemBuilder: (_, i) {
              final m = items[i];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  child: Row(children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.grade,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13)),
                          Text(m.gost,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: cs.onSurface.withOpacity(0.55))),
                        ],
                      ),
                    ),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _groupBadge(context, m.group),
                          const SizedBox(height: 3),
                          Text('${m.density.toInt()} кг/м³',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: cs.primary,
                                  fontWeight: FontWeight.w500)),
                        ]),
                  ]),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }

  Widget _chip(BuildContext context, String label, bool active,
      VoidCallback onTap) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 6, top: 4, bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: active ? cs.primary : cs.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 12,
                color: active ? cs.onPrimary : cs.onSurfaceVariant)),
      ),
    );
  }

  Widget _groupBadge(BuildContext context, String group) {
    final cs = Theme.of(context).colorScheme;
    final colors = {
      'Сталь': cs.secondaryContainer,
      'Нержавейка': const Color(0xFFE8F5E9),
      'Алюминий': const Color(0xFFE3F2FD),
      'Медь': const Color(0xFFFFF3E0),
      'Латунь': const Color(0xFFFFF9C4),
      'Бронза': const Color(0xFFF3E5F5),
      'Титан': const Color(0xFFE0F2F1),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: colors[group] ?? cs.surfaceVariant,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(group,
          style: const TextStyle(
              fontSize: 10, fontWeight: FontWeight.w500)),
    );
  }
}
