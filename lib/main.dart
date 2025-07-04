import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'onboard.dart';

void main() {
   WidgetsFlutterBinding.ensureInitialized();
   runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const InitialBlackScreen(),
    );
  }
}

class InitialBlackScreen extends StatelessWidget {
  const InitialBlackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SplashWithSequence()),
      );
    });

    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(),
    );
  }
}

class SplashWithSequence extends StatefulWidget {
  const SplashWithSequence({super.key});

  @override
  _SplashWithSequenceState createState() => _SplashWithSequenceState();
}

class _SplashWithSequenceState extends State<SplashWithSequence>
    with TickerProviderStateMixin {
  bool _assetsPreloaded = false;
  int _currentStage = 0;
  bool _showFourthImage = false;
  bool _showFifthImage = false;

  late AnimationController _animationController;
  late Animation<Alignment> _alignmentAnimation;

  final List<String> _centerImagePaths = [
    'assets/splash/Group 1410092258-1.png',
    'assets/splash/Group 1410092258-2.png',
    'assets/splash/Group 1410092258-3.png',
  ];

  final String _fourthImagePath = 'assets/splash/Group 1410092262.png';
  final String _fifthImagePath = 'assets/splash/Group 1410092258-5.png';

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _alignmentAnimation = Tween<Alignment>(
      begin: Alignment.bottomCenter,
      end: Alignment.center,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _preloadAssets().then((_) {
      setState(() => _assetsPreloaded = true);
      Future.delayed(const Duration(seconds: 2), () => setState(() => _currentStage = 1));
      Future.delayed(const Duration(seconds: 3), () => setState(() => _currentStage = 2));
      Future.delayed(const Duration(seconds: 5), () => setState(() => _showFourthImage = true));
      Future.delayed(const Duration(seconds: 7), () {
        setState(() {
          _showFifthImage = true;
          _currentStage = 3;
        });
        _animationController.forward().then((_) {
          // Navigate to OnboardingPager directly
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) =>  OnboardingPager()),
          );
        });
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _preloadAssets() async {
    try {
      await Future.wait([
        ..._centerImagePaths.map((path) => precacheImage(AssetImage(path), context)),
        precacheImage(AssetImage(_fourthImagePath), context),
        precacheImage(AssetImage(_fifthImagePath), context),
        ..._centerImagePaths.map((path) => rootBundle.load(path)),
        rootBundle.load(_fourthImagePath),
        rootBundle.load(_fifthImagePath),
      ]);
    } catch (e) {
      debugPrint('Error preloading assets: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _assetsPreloaded
          ? Stack(
        children: [
          _buildBackground(),

          if (_currentStage < 3)
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: _buildCenterImage(_centerImagePaths[_currentStage]),
            ),

          if (_showFifthImage)
            AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 700),
              child: Center(
                child: Image.asset(
                  _fifthImagePath,
                  width: 200,
                  height: 200,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),

          if (_showFourthImage)
            AlignTransition(
              alignment: _alignmentAnimation,
              child: Image.asset(
                _fourthImagePath,
                width: 200,
                height: 200,
                filterQuality: FilterQuality.high,
              ),
            ),
        ],
      )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildCenterImage(String path) {
    return Center(
      key: ValueKey<String>(path),
      child: Image.asset(
        path,
        width: 200,
        height: 200,
        filterQuality: FilterQuality.high,
        errorBuilder: (context, error, stackTrace) {
          return Text(
            'Failed to load ${path.split('/').last}',
            style: const TextStyle(color: Colors.white),
          );
        },
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(
      children: [
        SizedBox.expand(
          child: Image.asset(
            'assets/splash/image 1-2.png',
            fit: BoxFit.cover,
          ),
        ),
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
        Center(
          child: Transform.rotate(
            angle: 0.5,
            child: Container(
              width: 300,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.transparent,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.6),
                    blurRadius: 60,
                    spreadRadius: 40,
                    offset: const Offset(40, 40),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

