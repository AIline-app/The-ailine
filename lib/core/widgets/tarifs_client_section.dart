import 'package:flutter/material.dart';

class TarifsClientSection extends StatelessWidget {
  const TarifsClientSection({
    super.key,

    required this.title,
    required this.subtitle,
    required this.minutes,
    required this.price,
    this.onTap,
    this.leading,
  });

  final String title;
  final String subtitle;
  final String minutes;
  final String price;
  final VoidCallback? onTap;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ListTile(
        leading: leading,
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xff1F3D59),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              minutes,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xff1F3D59),
              ),
            ),
            Text(
              price,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xff228CEE),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
