import 'package:flutter/material.dart';

import 'login_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OnboardingPager(),
    );
  }
}

class OnboardingPager extends StatefulWidget {
  @override
  _OnboardingPagerState createState() => _OnboardingPagerState();
}

class _OnboardingPagerState extends State<OnboardingPager> {
  final PageController _controller = PageController();

  final List<OnboardingData> onboardingScreens = [];

  @override
  void initState() {
    onboardingScreens.addAll([
      OnboardingData(
        image: 'assets/images/native-mobile-app-security.png',
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'One Tap. ',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              WidgetSpan(
                child: ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [Colors.redAccent, Colors.purpleAccent],
                  ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                  child: Text(
                    'Eight Apps',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
        description:
        "Easily access your favorite apps and websites all from one secure, spiderweb-style dashboard",
      ),
      OnboardingData(
        image: 'assets/images/abstract-cybersecurity-concept-design.png',
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Secure & ',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              TextSpan(
                text: 'Smart Login',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  foreground: Paint()
                    ..shader = LinearGradient(
                      colors: [Colors.redAccent, Colors.purpleAccent],
                    ).createShader(Rect.fromLTWH(0, 0, 200, 50)),
                ),
              ),
            ],
          ),
        ),
        description:
        "Use your fingerprint or password to log in once and unlock multiple accounts instantly—safe, fast, and hassle-free.",
      ),
      OnboardingData(
        image: 'assets/images/young-girl-using-digital-tablet-night-beauty-light-bokeh-city.png',
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Digital Web, ',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  foreground: Paint()
                    ..shader = LinearGradient(
                      colors: [Colors.redAccent, Colors.purpleAccent],
                    ).createShader(Rect.fromLTWH(0, 0, 200, 50)),
                ),
              ),
              TextSpan(
                text: 'Your Way',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ],
          ),
        ),
        description:
        "Customize your hub with up to 8 apps. Swipe, tap, & connect with what matters most—your world, at your fingertips.",
      ),
    ]);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _controller,
        itemCount: onboardingScreens.length,
        itemBuilder: (context, index) {
          return OnboardingScreen(
            data: onboardingScreens[index],
            isLast: index == onboardingScreens.length - 1,
            controller: _controller,
          );
        },
      ),
    );
  }
}

class OnboardingData {
  final String image;
  final RichText title;
  final String description;

  OnboardingData({required this.image, required this.title, required this.description});
}

class OnboardingScreen extends StatelessWidget {
  final OnboardingData data;
  final bool isLast;
  final PageController controller;

  const OnboardingScreen({
    required this.data,
    required this.isLast,
    required this.controller,
  });

  void _onContinuePressed(BuildContext context) {
    if (isLast) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    } else {
      controller.nextPage(duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            data.image,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 40,
          right: 20,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.6),
                  blurRadius: 12,
                  spreadRadius: 2,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => LoginScreen()),
                  );
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  backgroundColor: Colors.transparent,
                ),
                child: Text(
                  "Skip",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            margin: EdgeInsets.only(bottom: 20),
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                data.title,
                SizedBox(height: 15),
                Text(
                  data.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black87, fontSize: 15, height: 1.4),
                ),
                SizedBox(height: 20),
                Icon(Icons.circle, size: 12, color: Colors.redAccent),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => _onContinuePressed(context),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: EdgeInsets.zero,
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.redAccent, Colors.purpleAccent],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          "Continue",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

