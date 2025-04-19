import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:focusyn_app/constants/theme_icons.dart';
import 'package:focusyn_app/services/cloud_sync_service.dart';
import 'package:hive/hive.dart';
import 'package:focusyn_app/constants/keys.dart';
import 'package:focusyn_app/pages/onboarding_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  bool loading = false;

  void _signUp() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // Validate inputs
    if (name.isEmpty) {
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text("Invalid Name"),
              content: const Text("Please enter your name"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                ),
              ],
            ),
      );
      return;
    }

    setState(() => loading = true);
    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Set display name in Auth
      await userCredential.user?.updateDisplayName(name);
      // Store in Firestore profile
      await CloudSyncService.updateUserProfile(name);

      // Initialize example data for new account
      final taskBox = Hive.box(Keys.taskBox);
      final filterBox = Hive.box(Keys.filterBox);
      final brainBox = Hive.box(Keys.brainBox);

      // Initialize tasks
      taskBox.putAll({
        Keys.actions: [
          {
            Keys.text: "Complete Focusyn App",
            Keys.priority: 1,
            Keys.brainPoints: 10,
            Keys.list: "Work",
            Keys.createdAt: DateTime.now().toIso8601String(),
          },
        ],
        Keys.flows: [
          {
            Keys.text: "Morning Routine",
            Keys.date: "2025-03-30",
            Keys.time: "07:30",
            Keys.duration: 15,
            Keys.repeat: "Daily",
            Keys.brainPoints: 10,
            Keys.history: [],
            Keys.list: "Morning",
            Keys.createdAt: DateTime.now().toIso8601String(),
          },
        ],
        Keys.moments: [
          {
            Keys.text: "Doctor's Appointment",
            Keys.date: "2025-04-03",
            Keys.time: "10:30",
            Keys.duration: 30,
            Keys.location: "Clinic",
            Keys.list: "Health",
            Keys.createdAt: DateTime.now().toIso8601String(),
          },
        ],
        Keys.thoughts: [
          {
            Keys.text: "I should start reading more books",
            Keys.createdAt: DateTime.now().toIso8601String(),
          },
        ],
      });

      // Initialize filters
      filterBox.putAll({
        Keys.actions: [Keys.all, 'Home', 'Errands', 'Work'],
        Keys.flows: [Keys.all, 'Morning', 'Wellness'],
        Keys.moments: [Keys.all, 'Appointments', 'Social'],
        Keys.thoughts: [Keys.all, 'Ideas', 'Journal'],
      });

      // Initialize brain points
      brainBox.put(Keys.brainPoints, 100);
      brainBox.put('lastReset', DateTime.now().toIso8601String());

      // Sync initialized data to Firestore
      await CloudSyncService.syncOnLogin(taskBox, filterBox, brainBox);

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const OnboardingPage()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text("Sign Up Failed"),
              content: Text(e.toString()),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                ),
              ],
            ),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo and Title
                    Icon(
                      ThemeIcons.focusesIcon,
                      size: 64,
                      color: Colors.blue[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Focusyn",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[300],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Create your account",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Input Fields
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(13),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          TextField(
                            controller: nameController,
                            decoration: InputDecoration(
                              labelText: 'Display Name',
                              hintText: 'Enter your display name',
                              prefixIcon: Icon(
                                ThemeIcons.userIcon,
                                color: Colors.blue[300],
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(
                                ThemeIcons.emailIcon,
                                color: Colors.blue[300],
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Password (min 6 chars)',
                              prefixIcon: Icon(
                                ThemeIcons.lockIcon,
                                color: Colors.blue[300],
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          loading
                              ? const CircularProgressIndicator()
                              : ElevatedButton(
                                onPressed: _signUp,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue[300],
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size.fromHeight(50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  "Sign Up",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Login Link
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Already have an account? Log in",
                        style: TextStyle(
                          color: Colors.blue[300],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
