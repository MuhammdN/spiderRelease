import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'EditAccountScreen.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

const String baseUrl = 'https://my-backend-production-d82c.up.railway.app';

class MyAccountScreen extends StatefulWidget {
  const MyAccountScreen({super.key});

  @override
  State<MyAccountScreen> createState() => _MyAccountScreenState();
}

class _MyAccountScreenState extends State<MyAccountScreen> {
  String name = '';
  String email = '';
  bool isLoading = true;
  bool isDeleting = false;

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
  }

  Future<void> fetchUserInfo() async {
    setState(() => isLoading = true);
    final userId = UserSession.userId;
    if (userId == null) return;

    try {
      final url = Uri.parse('$baseUrl/users/$userId');
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        setState(() {
          name = userData['fullName'] ?? 'N/A';
          email = userData['email'] ?? 'N/A';
          isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load user: ${response.statusCode}')),
        );
        setState(() => isLoading = false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
      setState(() => isLoading = false);
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Account"),
        content: const Text("Are you sure you want to delete your account? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAccount();
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    setState(() => isDeleting = true);
    final userId = UserSession.userId;
    if (userId == null) return;

    try {
      final url = Uri.parse('$baseUrl/users/$userId');
      final response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      // Check if response is successful (200-299)
      if (response.statusCode >= 200 && response.statusCode < 300) {
        UserSession.clear();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const SignupScreen()),
              (route) => false,
        );
      }
      // Handle non-successful responses
      else {
        String errorMessage;
        // Try to parse as JSON first
        try {
          final error = jsonDecode(response.body);
          errorMessage = error['message'] ?? 'Failed to delete account';
        }
        // If parsing fails, use the raw response or status code
        catch (e) {
          errorMessage = 'Failed to delete account (Status: ${response.statusCode})';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: ${e.toString()}')),
      );
    } finally {
      setState(() => isDeleting = false);
    }
  }

  Widget _buildHeader(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
        ),
        const Text(
          "My Account",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildBackground() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : Column(
              children: [
                const SizedBox(height: 20),
                _buildHeader(context),
                const SizedBox(height: 40),
                _InfoRow(label: "Name", value: name),
                const Divider(color: Colors.white24, indent: 20, endIndent: 20),
                _InfoRow(label: "Email Address", value: email),
                const Divider(color: Colors.white24, indent: 20, endIndent: 20),
                _InfoRow(label: "Password", value: "********"),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: isDeleting ? null : _showDeleteConfirmation,
                    child: isDeleting
                        ? const CircularProgressIndicator(color: Colors.red)
                        : const Text("Delete Account"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFAC30F4),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                      shadowColor: Colors.purple.withOpacity(0.5),
                    ),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditAccountScreen(),
                        ),
                      );
                      if (result != null && result['updated'] == true) {
                        await fetchUserInfo();
                      }
                    },
                    child: const Text("Edit Account"),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$label:",
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}