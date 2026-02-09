import 'package:flutter/material.dart';

class VoteCounter extends StatelessWidget {
  final IconData icon;
  final int count;
  final Color color;

  const VoteCounter({
    super.key,
    required this.icon,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text('$count', style: TextStyle(fontSize: 12, color: color)),
      ],
    );
  }
}
