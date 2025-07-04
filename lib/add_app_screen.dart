import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';
import 'app_data.dart' as app_data;

class AddAppsScreen extends StatefulWidget {
  final List<app_data.SocialApp> initialSelectedApps;

  const AddAppsScreen({Key? key, required this.initialSelectedApps}) : super(key: key);

  @override
  State<AddAppsScreen> createState() => _AddAppsScreenState();
}

class _AddAppsScreenState extends State<AddAppsScreen> {
  List<app_data.SocialApp> allSocialApps = [];
  List<app_data.SocialApp> filteredApps = [];
  List<app_data.SocialApp> selectedApps = [];
  late Future<void> _initialLoad;
  TextEditingController searchController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    selectedApps = List.from(widget.initialSelectedApps);
    _initialLoad = _loadApps();
    searchController.addListener(_filterApps);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadApps() async {
    setState(() => isLoading = true);
    try {
      if (Platform.isIOS) {
        allSocialApps = app_data.allSocialApps;
      } else {
        List<AppInfo> apps = await InstalledApps.getInstalledApps(true, true);
        allSocialApps = apps.map((appInfo) {
          return app_data.SocialApp(
            name: appInfo.name,
            icon: appInfo.icon,
            color: _generateColorFromName(appInfo.name),
            packageName: appInfo.packageName,
          );
        }).toList();
      }

      setState(() {
        filteredApps = List.from(allSocialApps);
        // If no apps were passed in, select the first 5 as default
        if (widget.initialSelectedApps.isEmpty) {
          selectedApps = allSocialApps.take(5).toList();
        }
      });

    } catch (e) {
      debugPrint('Error loading apps: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Color _generateColorFromName(String input) {
    final hash = input.codeUnits.fold(0, (prev, el) => prev + el);
    final hue = (hash * 37) % 360;
    return HSLColor.fromAHSL(1.0, hue.toDouble(), 0.6, 0.5).toColor();
  }

  void _filterApps() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredApps = query.isEmpty
          ? List.from(allSocialApps)
          : allSocialApps.where((app) => app.name.toLowerCase().contains(query)).toList();
    });
  }

  bool _isSelected(app_data.SocialApp app) => selectedApps.any((a) => a.packageName == app.packageName);

  Future<void> _saveSelectedApps() async {
    if (Platform.isIOS) {
      return; // Do not save on iOS to avoid crashing on IconData
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final appData = selectedApps.map((app) => jsonEncode({
        'name': app.name,
        'packageName': app.packageName,
        'icon': base64Encode(app.icon),
        'color': app.color.value,
      })).toList();

      await prefs.setStringList('selected_apps_data', appData);
    } catch (e) {
      debugPrint('Error saving apps: $e');
    }
  }

  Future<void> _toggleAppSelection(app_data.SocialApp app) async {
    setState(() {
      if (_isSelected(app)) {
        selectedApps.removeWhere((a) => a.packageName == app.packageName);
      } else {
        if (selectedApps.length < 8) {
          selectedApps.add(app);
          _showHideHelpDialog(app.name);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Maximum 8 apps allowed')),
          );
        }
      }
    });

    await _saveSelectedApps();
  }

  void _showHideHelpDialog(String appName) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final instructions = isIOS
        ? "1. Long-press the app icon on your home screen.\n"
        "2. Tap 'Remove App'.\n"
        "3. Select 'Remove from Home Screen' (not Delete)."
        : "1. Long-press the app icon on your home screen.\n"
        "2. Tap 'Remove from Home Screen' or 'Hide App'.";

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Hide $appName App"),
        content: Text(
          "You've added $appName to your wallet.\n\n"
              "To hide the original app from your phone manually:\n\n$instructions",
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Got it"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background with gradient effects
          Positioned.fill(
            child: Image.asset(
              'assets/splash/image 1-1.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(1.3, -1.0),
                radius: 1.5,
                colors: [Color(0xAAAD1457), Colors.transparent],
                stops: [0.1, 1.0],
              ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-1.3, 1.0),
                radius: 1.5,
                colors: [Color(0xAA1A237E), Colors.transparent],
                stops: [0.1, 1.0],
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Header with back button and title
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context, selectedApps),
                      ),
                      const Text(
                        'Select Apps',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.white),
                        onPressed: () => Navigator.pop(context, selectedApps),
                      ),
                    ],
                  ),
                ),

                // Search bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: TextField(
                    controller: searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search apps...',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                      prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.7)),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
                    ),
                  ),
                ),

                // Selected apps count
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    '${selectedApps.length} of ${allSocialApps.length} selected',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ),

                // App list
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : filteredApps.isEmpty && searchController.text.isNotEmpty
                      ? Center(
                    child: Text(
                      'No apps found',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 16,
                      ),
                    ),
                  )
                      : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: filteredApps.length,
                    itemBuilder: (context, index) {
                      final app = filteredApps[index];
                      final isSelected = _isSelected(app);

                      return Card(
                        color: Colors.white.withOpacity(0.1),
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSelected ? app.color : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: app.color.withOpacity(0.2),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: app.color,
                                width: 2,
                              ),
                            ),
                            child: Platform.isIOS
                                ? Icon(app.icon as IconData, color: Colors.white)
                                : Image.memory(app.icon as Uint8List),
                          ),
                          title: Text(
                            app.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          trailing: Checkbox(
                            value: isSelected,
                            onChanged: (value) => _toggleAppSelection(app),
                            activeColor: app.color,
                            shape: const CircleBorder(),
                          ),
                          onTap: () => _toggleAppSelection(app),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}