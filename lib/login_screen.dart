import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:spider/signup_screen.dart';
import 'ForgotPasswordScreen.dart';
import 'home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String baseUrl = 'https://my-backend-production-d82c.up.railway.app';

class UserSession {
  static String? _userId;
  static String? _userName;
  static String? _userEmail;
  static bool _isLoggedIn = false;

  static String? get userId => _userId;
  static String? get userName => _userName;
  static String? get userEmail => _userEmail;
  static bool get isLoggedIn => _isLoggedIn;

  static void setUserData(String id, String name, String email) {
    _userId = id;
    _userName = name;
    _userEmail = email;
    _isLoggedIn = true;
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('is_logged_in');
    await prefs.remove('rememberMe');
    await prefs.remove('savedEmail');
    await prefs.remove('savedPassword');

    // Clear all app-specific authentication flags
    final keys = prefs.getKeys();
    for (String key in keys) {
      if (key.startsWith('auth_')) {
        await prefs.remove(key);
      }
    }

    _userId = null;
    _userName = null;
    _userEmail = null;
    _isLoggedIn = false;
  }

  static Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('is_logged_in') ?? false;
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static Future<void> logout(BuildContext context) async {
    await UserSession.clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool rememberMe = false;
  bool _obscurePassword = true;
  bool _isLoading = false;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  static const String _rememberMeKey = 'rememberMe';
  static const String _emailKey = 'savedEmail';
  static const String _passwordKey = 'savedPassword';
  static const String _isLoggedInKey = 'is_logged_in';

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final shouldRemember = prefs.getBool(_rememberMeKey) ?? false;

      if (shouldRemember) {
        final savedEmail = prefs.getString(_emailKey);
        final savedPassword = prefs.getString(_passwordKey);

        if (savedEmail != null && savedPassword != null) {
          setState(() {
            rememberMe = true;
            emailController.text = savedEmail;
            passwordController.text = savedPassword;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading saved credentials: $e');
    }
  }

  Future<void> _saveCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isLoggedInKey, true);

      if (rememberMe) {
        await prefs.setBool(_rememberMeKey, true);
        await prefs.setString(_emailKey, emailController.text.trim());
        await prefs.setString(_passwordKey, passwordController.text);
      } else {
        await _clearSavedCredentials();
      }
    } catch (e) {
      debugPrint('Error saving credentials: $e');
    }
  }

  Future<void> _clearSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_rememberMeKey);
      await prefs.remove(_emailKey);
      await prefs.remove(_passwordKey);
    } catch (e) {
      debugPrint('Error clearing credentials: $e');
    }
  }

  Future<void> loginUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse('$baseUrl/login');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': emailController.text.trim(),
          'password': passwordController.text,
        }),
      );

      final responseData = jsonDecode(response.body);
      debugPrint('Full Login Response: $responseData');

      if (response.statusCode == 200) {
        if (responseData['user'] != null) {
          final user = responseData['user'];
          UserSession.setUserData(
              user['_id'].toString(),
              user['name'] ?? user['email']?.split('@').first ?? 'User',
              user['email'] ?? ''
          );

          await _saveCredentials();

          if (mounted) {
            await Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          }
        }
      } else {
        final errorResponse = jsonDecode(response.body);
        if (mounted) {
          _showErrorDialog(errorResponse['message'] ?? 'Login failed');
        }
      }
    } catch (e) {
      debugPrint('Login error: $e');
      if (mounted) {
        _showErrorDialog('Network error occurred. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Failed', style: TextStyle(color: Colors.red)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter your email';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter a password';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/splash/image 1-2.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(1.3, -1.0),
                radius: 1.5,
                colors: [
                  Color(0xAAAD1457),
                  Colors.transparent,
                ],
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
                colors: [
                  Color(0xAA1A237E),
                  Colors.transparent,
                ],
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
          Padding(
            padding: const EdgeInsets.only(top: 100),
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Image.asset('assets/splash/Group 1410092262.png', height: 100),
                      const SizedBox(height: 70),
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                "Login",
                                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text("Don't have an account? "),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const SignupScreen()),
                                      );
                                    },
                                    child: const Text(
                                      "Sign Up",
                                      style: TextStyle(color: Colors.orange),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: emailController,
                                decoration: const InputDecoration(labelText: 'Email'),
                                validator: _validateEmail,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                ),
                                validator: _validatePassword,
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Checkbox(
                                    value: rememberMe,
                                    onChanged: (val) {
                                      setState(() {
                                        rememberMe = val!;
                                      });
                                    },
                                  ),
                                  const Text("Remember me"),
                                  const Spacer(),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                                      );
                                    },
                                    child: const Text(
                                      "Forgot Password?",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              GestureDetector(
                                onTap: _isLoading ? null : loginUser,
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    gradient: const LinearGradient(
                                      colors: [Colors.orange, Colors.pink],
                                    ),
                                  ),
                                  child: Center(
                                    child: _isLoading
                                        ? const CircularProgressIndicator(color: Colors.white)
                                        : const Text(
                                      "Log In",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}