import 'package:flutter/material.dart';
import 'package:gghgggfsfs/presentation/client/widgets/custom_circle_checkbox.dart';

class TarifsSection extends StatelessWidget {
  const TarifsSection({
    super.key,

    required this.title,
    required this.subtitle,
    required this.minutes,
    required this.price,
  });

  final String title;
  final String subtitle;
  final String minutes;
  final String price;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CustomCircleCheckbox(),
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
    );
  }
}
