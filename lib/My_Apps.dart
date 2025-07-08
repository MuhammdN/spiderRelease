import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spider/app_data.dart';
import 'dart:convert';
import 'dart:typed_data';

class MyAppsScreen extends StatefulWidget {
  final List<SocialApp> selectedApps;

  const MyAppsScreen({Key? key, required this.selectedApps}) : super(key: key);

  @override
  State<MyAppsScreen> createState() => _MyAppsScreenState();
}

class _MyAppsScreenState extends State<MyAppsScreen> {
  late List<SocialApp> _currentApps;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentApps = List.from(widget.selectedApps);
    _loadSelectedApps();
  }

  Future<void> _loadSelectedApps() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedAppData = prefs.getStringList('selected_apps_data') ?? [];

      List<SocialApp> loadedApps = [];

      // Try loading from new format first
      if (savedAppData.isNotEmpty) {
        loadedApps = savedAppData.map((jsonStr) {
          final data = jsonDecode(jsonStr);
          return SocialApp(
            name: data['name'],
            packageName: data['packageName'],
            icon: base64Decode(data['icon']),
            color: Color(data['color']),
          );
        }).toList();
      }

      // Fallback to old format if new format is empty
      if (loadedApps.isEmpty) {
        final savedAppNames = prefs.getStringList('selected_apps') ?? [];
        loadedApps = allSocialApps.where((app) => savedAppNames.contains(app.name)).toList();
      }

      setState(() {
        _currentApps = loadedApps;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading apps: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSelectedApps() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final appData = _currentApps.map((app) => jsonEncode({
        'name': app.name,
        'packageName': app.packageName,
        'icon': base64Encode(app.icon),
        'color': app.color.value,
      })).toList();

      await prefs.setStringList('selected_apps_data', appData);
    } catch (e) {
      debugPrint('Error saving apps: $e');
      rethrow;
    }
  }

  Future<void> _removeApp(int index) async {
    if (index < 0 || index >= _currentApps.length) return;

    final removedApp = _currentApps[index];
    final messenger = ScaffoldMessenger.of(context);

    setState(() {
      _currentApps.removeAt(index);
    });

    try {
      await _saveSelectedApps();
      messenger.showSnackBar(
        SnackBar(
          content: Text('${removedApp.name} removed'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              setState(() {
                _currentApps.insert(index, removedApp);
              });
              _saveSelectedApps();
            },
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error removing app: $e');
      setState(() {
        _currentApps.insert(index, removedApp);
      });
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Failed to remove app'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildAppItem(SocialApp app, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            app.color.withOpacity(0.15),
            app.color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: app.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: app.color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Image.memory(
            app.icon,
            width: 28,
            height: 28,
          ),
        ),
        title: Text(
          app.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete_outline, color: Colors.red.withOpacity(0.8)),
          onPressed: () => _removeApp(index),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.apps_outlined,
            size: 72,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'No apps selected yet',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'You can add apps from the home screen to manage them here',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          Text(
            'Loading your apps...',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
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
          // Gradient overlays (same as SettingsScreen)
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
                // App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context, _currentApps),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'My Apps',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Content
                Expanded(
                  child: _isLoading
                      ? _buildLoadingState()
                      : _currentApps.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 20),
                    itemCount: _currentApps.length,
                    itemBuilder: (context, index) =>
                        _buildAppItem(_currentApps[index], index),
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