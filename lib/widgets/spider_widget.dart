import 'package:flutter/material.dart';
import 'dart:math'; // for sin, cos, pi
import '../app_data.dart'; // Adjust path if needed

class SpiderWidget extends StatelessWidget {
  final List<SocialApp> selectedApps;
  final Function(SocialApp) onIconTap;

  const SpiderWidget({
    Key? key,
    required this.selectedApps,
    required this.onIconTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final center = Offset(150, 150);
    final double radius = 100;
    final int total = selectedApps.length;

    return SizedBox(
      width: 300,
      height: 300,
      child: Stack(
        children: [
          ...List.generate(total, (index) {
            final angle = (2 * pi / total) * index;
            final iconX = center.dx + radius * cos(angle);
            final iconY = center.dy + radius * sin(angle);

            return Positioned(
              left: iconX - 20,
              top: iconY - 20,
              child: GestureDetector(
                onTap: () => onIconTap(selectedApps[index]),
                child: CircleAvatar(
                  backgroundColor: selectedApps[index].color,
                  radius: 20,
                  child: Icon(
                    selectedApps[index].icon,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          }),
          Positioned(
            left: center.dx - 30,
            top: center.dy - 30,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.bug_report,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
