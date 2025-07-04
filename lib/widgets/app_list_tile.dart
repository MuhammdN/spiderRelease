import 'package:flutter/material.dart';
import '../app_data.dart'; // ✅ Adjust if needed

class AppListTile extends StatelessWidget {
  final String appName;
  final bool isSelected;
  final Function(bool?) onChanged;

  const AppListTile({
    super.key,
    required this.appName,
    required this.isSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final app = allSocialApps.firstWhere((a) => a.name == appName);

    return CheckboxListTile(
      title: Text(app.name),
      secondary: CircleAvatar(
        backgroundColor: app.color,
        child: Icon(app.icon, color: Colors.white),
      ),
      value: isSelected,
      onChanged: onChanged,
    );
  }
}
