import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/gost_reference.dart';
import '../widgets/tabler_icon.dart';

class GostReferenceScreen extends StatefulWidget {
  final GostReference ref;
  const GostReferenceScreen({super.key, required this.ref});

  @override
  State<GostReferenceScreen> createState() => _GostReferenceScreenState();
}

class _GostReferenceScreenState extends State<GostReferenceScreen> {
  bool _searching = false;
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Widget _highlighted(String text, TextStyle base) {
    if (_query.isEmpty) return Text(text, style: base);
    final lower = text.toLowerCase();
    final q = _query.toLowerCase();
    final spans = <TextSpan>[];
    int start = 0;
    int idx;
    while ((idx = lower.indexOf(q, start)) != -1) {
      if (idx > start) {
        spans.add(TextSpan(text: text.substring(start, idx), style: base));
      }
      spans.add(TextSpan(
        text: text.substring(idx, idx + q.length),
        style: base.copyWith(backgroundColor: Colors.yellow.withOpacity(0.5)),
      ));
      start = idx + q.length;
    }
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start), style: base));
    }
    return RichText(text: TextSpan(children: spans));
  }

  bool _matches(String text) =>
      _query.isEmpty || text.toLowerCase().contains(_query.toLowerCase());

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ref = widget.ref;

    final TextStyle body = TextStyle(
        fontSize: 14, height: 1.6, fontFamily: 'Manrope', color: cs.onSurface);
    final TextStyle bold = body.copyWith(fontWeight: FontWeight.w700);
    final TextStyle boldItalic = body.copyWith(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
        color: cs.error);
    final TextStyle label = TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        fontFamily: 'Manrope',
        color: cs.primary,
        letterSpacing: 0.5);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: TIconAppBar('arrow-left', size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: _searching
            ? TextField(
                controller: _searchCtrl,
                autofocus: true,
                style:
                    const TextStyle(color: Colors.white, fontFamily: 'Manrope'),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  hintText: 'Поиск в документе...',
                  hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontFamily: 'Manrope'),
                  border: InputBorder.none,
                  isDense: true,
                ),
                onChanged: (v) => setState(() => _query = v),
              )
            : Text(ref.code,
                style: const TextStyle(
                    fontFamily: 'Manrope', fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: TIconAppBar(_searching ? 'x' : 'search', size: 22),
            onPressed: () => setState(() {
              _searching = !_searching;
              if (!_searching) {
                _query = '';
                _searchCtrl.clear();
              }
            }),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Название
          if (_matches(ref.title)) ...[
            _highlighted(
                ref.title,
                TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Manrope',
                    color: cs.onSurface,
                    height: 1.4)),
            const SizedBox(height: 16),
          ],

          // Область применения
          if (_matches(ref.scope)) ...[
            Text('Область применения', style: label),
            const SizedBox(height: 6),
            _section(child: _highlighted(ref.scope, body), cs: cs),
            const SizedBox(height: 14),
          ],

          // Ключевые параметры
          if (ref.keyParams.any(_matches)) ...[
            Text('Ключевые параметры', style: label),
            const SizedBox(height: 6),
            _section(
              cs: cs,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: ref.keyParams
                    .where(_matches)
                    .map((p) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('• ',
                                  style: body.copyWith(color: cs.primary)),
                              Expanded(child: _highlighted(p, body)),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Допуски — жирным
          if (ref.tolerances.any(_matches)) ...[
            Text('Допуски и нормы', style: label),
            const SizedBox(height: 6),
            _section(
              cs: cs,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: ref.tolerances
                    .where(_matches)
                    .map((t) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('• ',
                                  style: bold.copyWith(color: cs.primary)),
                              Expanded(child: _highlighted(t, bold)),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Критически важное — жирный + курсив + красный
          if (ref.critical.any(_matches)) ...[
            Text('Важно знать', style: label.copyWith(color: cs.error)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.errorContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: cs.error.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: ref.critical
                    .where(_matches)
                    .map((c) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('⚠ ', style: boldItalic),
                              Expanded(child: _highlighted(c, boldItalic)),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Маркировка
          if (_matches(ref.marking)) ...[
            Text('Маркировка', style: label),
            const SizedBox(height: 6),
            _section(child: _highlighted(ref.marking, body), cs: cs),
            const SizedBox(height: 14),
          ],

          // Расшифровка марки — раскрывающийся блок
          if (ref.decoding.isNotEmpty) ...[
            _DecodingTile(
              ref: ref,
              label: label,
              body: body,
              cs: cs,
              highlighted: _highlighted,
              matches: _matches,
            ),
            const SizedBox(height: 24),
          ] else
            const SizedBox(height: 10),

          // Кнопка полного текста
          FilledButton.icon(
            onPressed: () async {
              final uri = Uri.parse(ref.fullTextUrl);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              shape: const StadiumBorder(),
            ),
            icon: TIcon('external-link', size: 20, color: Colors.white),
            label: const Text('Полный текст документа',
                style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _section({required Widget child, required ColorScheme cs}) =>
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: child,
      );
}

// ─── Раскрывающийся блок расшифровки марки ───────────────────────────────────

class _DecodingTile extends StatefulWidget {
  final GostReference ref;
  final TextStyle label;
  final TextStyle body;
  final ColorScheme cs;
  final Widget Function(String, TextStyle) highlighted;
  final bool Function(String) matches;

  const _DecodingTile({
    required this.ref,
    required this.label,
    required this.body,
    required this.cs,
    required this.highlighted,
    required this.matches,
  });

  @override
  State<_DecodingTile> createState() => _DecodingTileState();
}

class _DecodingTileState extends State<_DecodingTile>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _ctrl;
  late final Animation<double> _iconTurn;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _iconTurn = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _ctrl.forward() : _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final ref = widget.ref;
    final cs = widget.cs;
    final body = widget.body;
    final label = widget.label;

    final visibleItems = ref.decoding
        .where((d) => widget.matches(d.symbol) || widget.matches(d.meaning))
        .toList();

    if (visibleItems.isEmpty) return const SizedBox.shrink();

    // Заголовок шапки: пример обозначения или fallback
    final headerTitle = ref.decodingExample != null
        ? ref.decodingExample!
        : 'Расшифровка марки';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Расшифровка марки', style: label),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: _toggle,
          child: Container(
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: cs.primary.withOpacity(0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Шапка — всегда видна, показывает пример марки
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 12),
                  child: Row(
                    children: [
                      // Иконка-подсказка
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: cs.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.abc_rounded,
                            size: 20, color: cs.primary),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Как читать марку',
                              style: body.copyWith(
                                fontSize: 11,
                                color: cs.onSurface.withOpacity(0.55),
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              headerTitle,
                              style: body.copyWith(
                                fontWeight: FontWeight.w700,
                                color: cs.primary,
                                fontSize: 14,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      RotationTransition(
                        turns: _iconTurn,
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: cs.primary,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),

                // Раскрывающаяся таблица
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Divider(
                            color: cs.primary.withOpacity(0.2), height: 1),
                        const SizedBox(height: 10),
                        ...visibleItems.map((d) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Символ / обозначение — бейджик
                                  Container(
                                    constraints:
                                        const BoxConstraints(minWidth: 72),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: cs.primary.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: widget.highlighted(
                                      d.symbol,
                                      body.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: cs.primary,
                                        fontSize: 13,
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  // Значение
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: widget.highlighted(
                                        d.meaning,
                                        body.copyWith(fontSize: 13),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                  crossFadeState: _expanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 250),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
