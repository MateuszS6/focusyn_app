import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:focusyn_app/constants/theme_icons.dart';
import 'package:focusyn_app/services/cloud_service.dart';
import 'package:focusyn_app/services/filter_service.dart';
import 'package:hive/hive.dart';
import 'package:focusyn_app/constants/keys.dart';
import 'package:focusyn_app/pages/onboarding_page.dart';

/// A page that handles new user registration and account creation.
///
/// This page provides:
/// - User registration with name, email, and password
/// - Input validation and error handling
/// - Automatic initialization of user data and preferences
/// - Navigation to onboarding after successful registration
/// - Integration with Firebase Authentication and Cloud Firestore
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

/// Manages the state of the signup page, including:
/// - Form input controllers and validation
/// - Loading state during registration
/// - User data initialization
/// - Error handling and user feedback
class _SignUpPageState extends State<SignUpPage> {
  // Controllers for form inputs
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();

  // State variables
  bool loading = false;
  bool _obscurePassword = true;

  /// Handles the signup process by:
  /// 1. Validating user inputs
  /// 2. Creating Firebase Auth account
  /// 3. Initializing user data and preferences
  /// 4. Syncing data to Firestore
  /// 5. Navigating to onboarding page
  void _signUp() async {
    // Get and trim input values
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // Validate name input
    if (name.isEmpty) {
      _showErrorDialog("Invalid Name", "Please enter your name");
      return;
    }

    setState(() => loading = true);
    try {
      // Create Firebase Auth account
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Update user profile
      await userCredential.user?.updateDisplayName(name);
      await CloudService.updateUserProfile(name);

      // Initialize example tasks for new users
      _initializeExampleTasks();

      // Initialize default filters
      FilterService.initDefaultFilters();

      // Initialize brain points system
      _initializeBrainPoints();

      // Sync all initialized data to Firestore
      await CloudService.syncOnLogin();

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const OnboardingPage()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog("Sign Up Failed", e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  /// Shows an error dialog with the given title and message
  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
    );
  }

  /// Initializes example tasks for new users
  void _initializeExampleTasks() {
    final taskBox = Hive.box<List>(Keys.taskBox);
    taskBox.putAll({
      Keys.actions: [
        {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'text': "Complete Focusyn App",
          'priority': 1,
          'brainPoints': 10,
          'list': "Work",
          'createdAt': DateTime.now().toIso8601String(),
        },
      ],
      Keys.flows: [
        {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'text': "Morning Routine",
          'date': "2025-03-30",
          'time': "07:30",
          'duration': 15,
          'repeat': "Daily",
          'brainPoints': 10,
          'list': "Morning",
          'createdAt': DateTime.now().toIso8601String(),
        },
      ],
      Keys.moments: [
        {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'text': "Doctor's Appointment",
          'date': "2025-04-03",
          'time': "10:30",
          'duration': 30,
          'location': "Clinic",
          'list': "Health",
          'createdAt': DateTime.now().toIso8601String(),
        },
      ],
      Keys.thoughts: [
        {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'text': "I should start reading more books",
          'createdAt': DateTime.now().toIso8601String(),
        },
      ],
    });
  }

  /// Initializes brain points system with starting values
  void _initializeBrainPoints() {
    final brainBox = Hive.box(Keys.brainBox);
    brainBox.put(Keys.brainPoints, 100);
    brainBox.put('lastReset', DateTime.now().toIso8601String());
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
                    // App Logo
                    Image.asset(
                      'assets/logo_transparent_text.png',
                      height: 200,
                      fit: BoxFit.contain,
                    ),
                    Text(
                      "Create your account",
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(color: Colors.grey[500]),
                    ),
                    const SizedBox(height: 32),
                    // Sign Up Form
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
                          // Name Input
                          TextField(
                            controller: nameController,
                            decoration: InputDecoration(
                              labelText: 'Display Name',
                              hintText: 'Create a display name',
                              prefixIcon: Icon(
                                ThemeIcons.user,
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
                          // Email Input
                          TextField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              hintText: 'Enter your email',
                              prefixIcon: Icon(
                                ThemeIcons.email,
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
                          // Password Input
                          TextField(
                            controller: passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Password (min 6 chars)',
                              hintText: 'Create a password',
                              prefixIcon: Icon(
                                ThemeIcons.lock,
                                color: Colors.blue[300],
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? ThemeIcons.visibilityOff
                                      : ThemeIcons.visibilityOn,
                                  color: Colors.grey[600],
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
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
                          // Sign Up Button
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
