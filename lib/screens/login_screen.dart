import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'user_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  void login() {
    String user = usernameController.text.trim();
    String pass = passwordController.text.trim();

    // ✅ ADMIN LOGIN → DASHBOARD
    if (user == "admin" && pass == "1234") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    }

    // ✅ USER LOGIN → USER PANEL
    else if (user == "user" && pass == "1234") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const UserScreen()),
      );
    }

    // ❌ WRONG LOGIN
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Wrong Username or Password ❌")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Stack(
        children: [

          // 🖼 BACKGROUND IMAGE
          Positioned.fill(
            child: Image.asset(
              "assets/images/bg.jpg",
              fit: BoxFit.cover,
            ),
          ),

          // 🌫 DARK OVERLAY
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.4),
            ),
          ),

          // 🔐 LOGIN BOX
          Center(
            child: Container(
              width: 350,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  const Text(
                    "Login",
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                      labelText: "Username",
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Password",
                    ),
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: login,
                    child: const Text("Login"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}