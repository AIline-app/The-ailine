import 'package:flutter/material.dart';

class ChooseBodyDialog extends StatefulWidget {
  const ChooseBodyDialog({super.key, required this.initialValue});
  final String initialValue;

  @override
  State<ChooseBodyDialog> createState() => _ChooseBodyDialogState();
}

class _ChooseBodyDialogState extends State<ChooseBodyDialog> {
  final items = const ['джип', 'Седан', 'минивен'];
  late String value = widget.initialValue;

  bool isOpen = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Выбрать кузов',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1F3D59),
              ),
            ),
            const SizedBox(height: 14),

            /// Поле
            GestureDetector(
              onTap: () => setState(() => isOpen = !isOpen),
              child: _OutlinedField(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  child: Row(
                    children: [
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black54,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        isOpen
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: const Color(0xFF2D8CFF),
                        size: 28,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            /// Вот он — dropdown список
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 200),
              crossFadeState:
              isOpen ? CrossFadeState.showFirst : CrossFadeState.showSecond,
              firstChild: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: _OutlinedField(
                  child: Column(
                    children: items.map((e) {
                      final selected = e == value;
                      return InkWell(
                        onTap: () {
                          setState(() {
                            value = e;
                            isOpen = false;
                          });
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                          child: Text(
                            e,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: selected
                                  ? FontWeight.w900
                                  : FontWeight.w600,
                              color: selected
                                  ? const Color(0xFF1F3D59)
                                  : Colors.black38,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              secondChild: const SizedBox(),
            ),

            const SizedBox(height: 14),

            SizedBox(
              height: 56,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, value),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D8CFF),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Выбрать',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Dropdown extends StatefulWidget {
  const _Dropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  @override
  State<_Dropdown> createState() => _DropdownState();
}

class _DropdownState extends State<_Dropdown> {
  final _link = LayerLink();
  OverlayEntry? _entry;
  bool _open = false;

  void _toggle() {
    if (_open) {
      _close();
    } else {
      _openMenu();
    }
  }

  void _close() {
    _entry?.remove();
    _entry = null;
    setState(() => _open = false);
  }

  void _openMenu() {
    final overlay = Overlay.of(context);
    if (overlay == null) return;

    _entry = OverlayEntry(
      builder: (ctx) {
        return Stack(
          children: [
            // тап по фону закрывает
            Positioned.fill(
              child: GestureDetector(
                onTap: _close,
                behavior: HitTestBehavior.translucent,
              ),
            ),

            // сам список под полем
            CompositedTransformFollower(
              link: _link,
              showWhenUnlinked: false,
              offset: const Offset(0, 58), // высота поля + отступ
              child: Material(
                color: Colors.transparent,
                child: _OutlinedField(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: widget.items.map((e) {
                      final selected = e == widget.value;
                      return InkWell(
                        onTap: () {
                          widget.onChanged(e);
                          _close();
                        },
                        child: Container(
                          width: 320, // можно убрать, если хочешь под ширину поля
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                          child: Text(
                            e,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
                              color: selected ? const Color(0xFF1F3D59) : Colors.black38,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(_entry!);
    setState(() => _open = true);
  }

  @override
  void dispose() {
    _close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: GestureDetector(
        onTap: _toggle,
        child: _OutlinedField(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            child: Row(
              children: [
                Text(
                  widget.value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black45,
                  ),
                ),
                const Spacer(),
                Icon(
                  _open ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: const Color(0xFF2D8CFF),
                  size: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OutlinedField extends StatelessWidget {
  const _OutlinedField({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade400, width: 2),
        color: Colors.white,
      ),
      clipBehavior: Clip.hardEdge,
      child: child,
    );
  }
}
