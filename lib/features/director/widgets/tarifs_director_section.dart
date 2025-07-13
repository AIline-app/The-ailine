import 'package:flutter/material.dart';

class TarifsDirector extends StatefulWidget {
  const TarifsDirector({
    super.key,

    required this.title,
    required this.subtitle,
    required this.minutes,
    required this.price,
    this.onEdit,
    this.onDelete,
  });

  final String title;
  final String subtitle;
  final String minutes;
  final String price;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  State<TarifsDirector> createState() => _TarifsDirectorState();
}

class _TarifsDirectorState extends State<TarifsDirector> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 10, left: 15),

      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff1F3D59),
                ),
              ),
              Text(
                widget.subtitle,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          Spacer(),
          Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    widget.minutes,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff1F3D59),
                    ),
                  ),
                  Text(
                    widget.price,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff228CEE),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // что-то новое
          PopupMenuButton<String>(
            padding: EdgeInsets.zero,
            offset: const Offset(-20, 30),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 8,
            icon: const Icon(Icons.more_vert, color: Colors.blue, size: 32),
            onSelected: (value) {
              if (value == 'edit') {
                widget.onEdit?.call();
              } else if (value == 'delete') {
                widget.onDelete?.call();
              }
            },
            itemBuilder:
                (context) => [
                  PopupMenuItem<String>(
                    value: 'edit',
                    enabled: false,
                    child: Text(
                      'Редактировать',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade400,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(
                      'Удалить',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
          ),
        ],
      ),
    );
  }
}
