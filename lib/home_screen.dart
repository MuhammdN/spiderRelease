import 'package:flutter/material.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math';
import 'dart:convert';
import 'dart:typed_data';
import 'add_app_screen.dart';
import 'settings_screen.dart';
import 'notifications_page.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';
import 'login_screen.dart';
import 'app_data.dart';
import 'social_app_screen.dart';
import 'dart:io';

// Session state management class
class SessionState {
  static bool isAuthenticated = false;

  static void reset() {
    isAuthenticated = false;
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  List<SocialApp> selectedApps = [];
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadSelectedApps();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 100),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _rotateAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.linear,
      ),
    );
  }

  Future<void> _loadSelectedApps() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedAppData = prefs.getStringList('selected_apps_data') ?? [];

      if (Platform.isIOS) {
        // On iOS, always use the static list
        setState(() {
          selectedApps = allSocialApps.take(8).toList();
        });
        return;
      }

      // Check if user is new (no saved apps) and we have installed apps
      if (savedAppData.isEmpty) {
        // Get installed apps
        List<AppInfo> apps = await InstalledApps.getInstalledApps(true, true);

        if (apps.isNotEmpty) {
          // Auto-select first 5 apps
          final autoSelectedApps = apps.take(5).map((appInfo) {
            return SocialApp(
              name: appInfo.name,
              icon: appInfo.icon,
              color: _generateColorFromName(appInfo.name),
              packageName: appInfo.packageName,
            );
          }).toList();

          // Save the auto-selected apps
          await _saveSelectedApps(autoSelectedApps);

          setState(() {
            selectedApps = autoSelectedApps;
          });
          return;
        }
      }

      // Existing user flow
      setState(() {
        selectedApps = savedAppData.map((jsonStr) {
          final data = jsonDecode(jsonStr);
          return SocialApp(
            name: data['name'],
            packageName: data['packageName'],
            icon: base64Decode(data['icon']),
            color: Color(data['color']),
          );
        }).toList();
      });

      // Fallback to old method if no data in new format
      if (selectedApps.isEmpty) {
        final savedAppNames = prefs.getStringList('selected_apps') ?? [];
        setState(() {
          selectedApps = allSocialApps.where((app) => savedAppNames.contains(app.name)).toList();
        });
      }
    } catch (e) {
      debugPrint('Error loading apps: $e');
    }
  }

  Color _generateColorFromName(String input) {
    final hash = input.codeUnits.fold(0, (prev, el) => prev + el);
    final hue = (hash * 37) % 360;
    return HSLColor.fromAHSL(1.0, hue.toDouble(), 0.6, 0.5).toColor();
  }

  Future<void> _saveSelectedApps(List<SocialApp> apps) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final appData = apps.map((app) => jsonEncode({
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

  Future<bool> _authenticateUser(String email, String password) async {
    // Check if the provided credentials match the logged-in user
    if (UserSession.userEmail == email &&
        password.isNotEmpty &&
        password.length >= 6) { // Basic password check
      SessionState.isAuthenticated = true;
      return true;
    }
    return false;
  }

  Future<bool> _showLoginDialog(BuildContext context, String appName) async {
    // Check if already authenticated in this session
    if (SessionState.isAuthenticated) {
      return true;
    }

    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildLoginDialog(context, appName),
    ).then((value) {
      if (value == true) {
        SessionState.isAuthenticated = true;
        return true;
      }
      return false;
    });
  }

  Widget _buildLoginDialog(BuildContext context, String appName) {
    final emailController = TextEditingController(text: UserSession.userEmail);
    final passwordController = TextEditingController();
    bool obscurePassword = true;

    return StatefulBuilder(
      builder: (context, setState) {
        bool isLoading = false;
        String? errorMessage;

        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Modified title row with flexible text
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'Login to $appName',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2, // Allow text to wrap to second line if needed
                        overflow: TextOverflow.ellipsis, // Show ellipsis if still too long
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(false),
                      padding: EdgeInsets.zero, // Remove extra padding
                      constraints: const BoxConstraints(), // Allow icon to be closer to text
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                if (errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                    ),
                  ),

                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                  ),
                  readOnly: true, // Make email read-only since it's the logged-in user
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: isLoading ? null : () async {
                      if (passwordController.text.isEmpty) {
                        setState(() {
                          errorMessage = 'Please enter your password';
                        });
                        return;
                      }

                      setState(() {
                        isLoading = true;
                        errorMessage = null;
                      });

                      final isAuthenticated = await _authenticateUser(
                        emailController.text,
                        passwordController.text,
                      );

                      if (isAuthenticated) {
                        Navigator.of(context).pop(true);
                      } else {
                        setState(() {
                          isLoading = false;
                          errorMessage = 'Invalid password. Please try again.';
                        });
                      }
                    },
                    child: isLoading
                        ? const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    )
                        : const Text(
                      'VERIFY',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _launchApp(SocialApp app) async {
    if (Platform.isIOS) {
      // Try to launch using URL scheme
      if (app.launchUrls != null) {
        for (final url in app.launchUrls!) {
          if (await canLaunchUrl(Uri.parse(url))) {
            await launchUrl(Uri.parse(url));
            return;
          }
        }
      }
      // If not installed, open App Store or fallbackUrl
      if (app.fallbackUrl != null) {
        await launchUrl(Uri.parse(app.fallbackUrl!), mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('App not available')),
        );
      }
      return;
    }
    // Android logic (unchanged)
    try {
      final bool? launched = await InstalledApps.startApp(app.packageName);
      if (launched == null || launched == false) {
        throw Exception('Failed to launch app');
      }
    } catch (e) {
      debugPrint('Error launching app: ${app.name} - $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch ${app.name}')),
        );
      }
    }
  }

  void _navigateToAddAppsScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddAppsScreen(initialSelectedApps: selectedApps),
      ),
    ).then((updatedApps) async {
      if (updatedApps != null && mounted) {
        await _saveSelectedApps(List<SocialApp>.from(updatedApps));
        setState(() {
          selectedApps = List<SocialApp>.from(updatedApps);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _buildAnimatedBackground(),
          _buildGradientOverlays(),
          _buildHeaderSection(),
          _buildSpiderWithApps(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pinkAccent,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _navigateToAddAppsScreen(context),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomAppBar(context),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotateAnimation.value,
            child: Opacity(
              opacity: 0.7,
              child: Image.asset(
                'assets/home/Vector.png',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGradientOverlays() {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
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
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(-1.3, 1.0),
              radius: 1.5,
              colors: [Color(0xAA1A237E), Colors.transparent],
              stops: [0.1, 1.0],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      children: [
        const SizedBox(height: 60),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, ${UserSession.userName ?? "User"}',
                    style: const TextStyle(fontSize: 22, color: Colors.white70),
                  ),
                  Text(
                    'Digital web is ready',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.pinkAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.notifications, color: Colors.white70),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationsPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSpiderWithApps() {
    return Center(
      child: SizedBox(
        width: 300,
        height: 300,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 45),
              child: Image.asset(
                'assets/home/Vector (1).png',
                width: 350,
                height: 350,
              ),
            ),
            ..._buildSpiderLegsWithIcons(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomAppBar(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      color: const Color(0xFF1B1B3A),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.home, color: Colors.white),
              onPressed: null,
            ),
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsScreen(selectedApps: selectedApps),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSpiderLegsWithIcons() {
    const double radius = 120;
    const double centerX = 150;
    const double centerY = 150;

    return List.generate(8, (index) {
      final position = _calculateLegPosition(index, centerX, centerY);

      if (index < selectedApps.length) {
        return _buildAppIcon(
          position.dx,
          position.dy,
          selectedApps[index],
          index,
        );
      } else {
        return _buildEmptySlot(
          position.dx,
          position.dy,
          _getLegColor(index),
          index,
        );
      }
    });
  }

  Color _getLegColor(int index) {
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.yellow,
      Colors.lightBlueAccent,
      Colors.pink,
      Colors.orange,
      Colors.purple,
      Colors.green,
    ];
    return colors[index % colors.length];
  }

  Offset _calculateLegPosition(int index, double centerX, double centerY) {
    double angle = (2 * pi / 8) * index;
    double x = centerX + 120 * cos(angle);
    double y = centerY + 120 * sin(angle);

    switch (index) {
      case 0: return Offset(x - 55, y - 90);
      case 1: return Offset(x + 5, y - 14);
      case 2: return Offset(x + 45, y - 20);
      case 3: return Offset(x + 35, y + 10);
      case 4: return Offset(x + 33, y + 60);
      case 5: return Offset(x + 35, y);
      case 6: return Offset(x - 18, y + 2);
      case 7: return Offset(x - 55, y - 30);
      default: return Offset(x, y);
    }
  }

  Widget _buildAppIcon(double x, double y, SocialApp app, int index) {
    return Positioned(
      left: x - 20,
      top: y - 20,
      child: TweenAnimationBuilder(
        duration: Duration(milliseconds: 500 + (index * 100)),
        tween: Tween<double>(begin: 0, end: 1),
        curve: Curves.easeInOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: Opacity(opacity: value, child: child),
          );
        },
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              final shouldProceed = await _showLoginDialog(context, app.name);
              if (shouldProceed && mounted) await _launchApp(app);
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: app.color.withOpacity(0.6),
                boxShadow: [
                  BoxShadow(
                    color: app.color.withOpacity(0.8),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(child: Platform.isIOS ?  Icon(app.icon): Image.memory(app.icon)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptySlot(double x, double y, Color color, int index) {
    return Positioned(
      left: x - 20,
      top: y - 20,
      child: TweenAnimationBuilder(
        duration: Duration(milliseconds: 500 + (index * 100)),
        tween: Tween<double>(begin: 0, end: 1),
        curve: Curves.easeInOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: Opacity(opacity: value, child: child),
          );
        },
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.4),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.7),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Text(
              '+',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(color: color, blurRadius: 15),
                  Shadow(color: color.withOpacity(0.5), blurRadius: 25),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}