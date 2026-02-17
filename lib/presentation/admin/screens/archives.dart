import 'package:flutter/material.dart';
import 'package:theIline/core/theme/text_styles.dart';

import '../../../core/widgets/custom_back_button.dart';

enum SortType { time, boxes, washers }

extension SortTypeTitle on SortType {
  String get title {
    switch (this) {
      case SortType.time:
        return 'По времени';
      case SortType.boxes:
        return 'По боксам';
      case SortType.washers:
        return 'По мойщикам';
    }
  }
}

class AdminArchives extends StatefulWidget {
  const AdminArchives({super.key});

  @override
  State<AdminArchives> createState() => _AdminArchivesState();
}

class _AdminArchivesState extends State<AdminArchives> {
  final _sortLink = LayerLink();
  OverlayEntry? _sortOverlay;

  SortType _sort = SortType.time;

  final List<_DaySection> _sections = [
    _DaySection(
      date: '05.03.2024',
      expanded: true,
      items: [
        _WashItem(paid: true, code: 'B8190A', time: null),
        _WashItem(paid: true, code: 'B8190A', time: null),
        _WashItem(paid: true, code: 'B8190A', time: '16:30'),
      ],
    ),
    _DaySection(date: '04.03.2024', expanded: false, items: []),
    _DaySection(date: '03.03.2024', expanded: false, items: []),
    _DaySection(date: '02.03.2024', expanded: false, items: []),
  ];

  @override
  void dispose() {
    _removeSortOverlay();
    super.dispose();
  }

  void _removeSortOverlay() {
    _sortOverlay?.remove();
    _sortOverlay = null;
  }

  void _toggleSortDropdown() {
    if (_sortOverlay != null) {
      _removeSortOverlay();
      setState(() {});
      return;
    }

    _sortOverlay = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            // клик по фону закрывает
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  _removeSortOverlay();
                  setState(() {});
                },
                behavior: HitTestBehavior.translucent,
                child: const SizedBox(),
              ),
            ),

            // сам попап, привязан к иконке
            CompositedTransformFollower(
              link: _sortLink,
              showWhenUnlinked: false,
              offset: const Offset(-175, 32), // подгони под пиксель под свой макет
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 210,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 22,
                        spreadRadius: 0,
                        offset: const Offset(0, 10),
                        color: Colors.black.withOpacity(0.15),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _menuRow(SortType.time),
                      _divider(),
                      _menuRow(SortType.boxes),
                      _divider(),
                      _menuRow(SortType.washers),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_sortOverlay!);
    setState(() {});
  }

  Widget _divider() => const Divider(height: 1, thickness: 1, color: Color(0xFFE6E6E6));

  Widget _menuRow(SortType type) {
    final selected = _sort == type;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        setState(() => _sort = type);
        _removeSortOverlay();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                type.title,
                style: AppTextStyles.bold18Black,
              ),
            ),
            if (selected)
              const Icon(Icons.check, size: 18, color: Color(0xFF2D8CFF)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF1F2F3);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        leading: CustomBackButton(),
        backgroundColor: bg,
        elevation: 0,
        shadowColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 22, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Автомойка Капля',
                  style: AppTextStyles.title,
                ),
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 22),
                itemBuilder: (context, i) => _DayCard(
                  section: _sections[i],
                  onToggle: () => setState(() => _sections[i].expanded = !_sections[i].expanded),
                  sortLink: _sortLink,
                  dropdownOpened: _sortOverlay != null,
                  onSortTap: _toggleSortDropdown,
                ),
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemCount: _sections.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  const _DayCard({
    required this.section,
    required this.onToggle,
    required this.sortLink,
    required this.onSortTap,
    required this.dropdownOpened,
  });

  final _DaySection section;
  final VoidCallback onToggle;

  final LayerLink sortLink;
  final VoidCallback onSortTap;
  final bool dropdownOpened;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [

          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(
                    section.expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    size: 19,
                    color: const Color(0xFF2D8CFF),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        section.date,
                        style: AppTextStyles.normal14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (section.expanded) ...[
            const Divider(height: 1, thickness: 1, color: Color(0xFFE6E6E6)),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CompositedTransformTarget(
                    link: sortLink,
                    child: GestureDetector(
                      onTap: onSortTap,
                      child: Icon(
                        Icons.swap_vert,
                        size: 19,
                        color: dropdownOpened ? const Color(0xFF2D8CFF) : const Color(0xFF2D8CFF),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // список записей
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 14),
              child: Column(
                children: section.items
                    .map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _WashRow(item: e),
                ))
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _WashRow extends StatelessWidget {
  const _WashRow({required this.item});

  final _WashItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFDFEAF3),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),

          // Плашка "Оплачено"
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFF1DB954), width: 2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Оплачено',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E2B35),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 26,
                  height: 26,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1DB954),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.currency_ruble, color: Colors.white, size: 18),
                ),
              ],
            ),
          ),

          const SizedBox(width: 14),
          Expanded(
            child: Text(
              item.code,
              style: AppTextStyles.normal16w500,
            ),
          ),

          // Время справа (оранжевое)
          if (item.time != null)
            Container(
              height: 30,
              padding: EdgeInsets.symmetric(horizontal: 10),
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF59A2A),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                item.time!,
                style: AppTextStyles.bold16w600,
              ),
            ),
        ],
      ),
    );
  }
}

class _DaySection {
  _DaySection({required this.date, required this.expanded, required this.items});

  final String date;
  bool expanded;
  final List<_WashItem> items;
}

class _WashItem {
  _WashItem({required this.paid, required this.code, required this.time});

  final bool paid;
  final String code;
  final String? time;
}
