import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rojgar/feature/auth/presentation/view_model/auth_view_model.dart';
import 'package:rojgar/feature/auth/presentation/state/auth_state.dart';
import 'package:rojgar/feature/auth/presentation/pages/login_screen.dart';
import 'package:rojgar/core/utils/my_snackbar.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (username.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      showMySnackBar(
        context: context,
        message: "Please fill all fields",
        color: Colors.red,
      );
      return;
    }

    if (password != confirmPassword) {
      showMySnackBar(
        context: context,
        message: "Passwords do not match",
        color: Colors.red,
      );
      return;
    }

    /// ✅ ONLY email, username, password
    ref.read(authViewModelProvider.notifier).register(
          username: username,
          email: email,
          password: password,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.registered) {
        showMySnackBar(
          context: context,
          message: "Registration successful! Please login.",
        );

        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => LoginScreen()),
            );
          }
        });
      }

      if (next.status == AuthStatus.error) {
        showMySnackBar(
          context: context,
          message: next.errorMessage ?? "Registration failed",
          color: Colors.red,
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back_ios),
              ),

              const SizedBox(height: 15),

              RichText(
                text: const TextSpan(
                  text: "Let’s ",
                  style: TextStyle(fontSize: 28, color: Colors.black87),
                  children: [
                    TextSpan(
                      text: "Sign Up",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),
              const Text(
                "Connect with the best companies and build your career.",
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 30),

              _inputField(
                controller: _usernameController,
                icon: Icons.person_outline,
                hint: "Username",
              ),

              const SizedBox(height: 20),

              _inputField(
                controller: _emailController,
                icon: Icons.email_outlined,
                hint: "Email",
              ),

              const SizedBox(height: 20),

              _inputField(
                controller: _passwordController,
                icon: Icons.lock_outline,
                hint: "Password",
                isPassword: true,
              ),

              const SizedBox(height: 20),

              _inputField(
                controller: _confirmPasswordController,
                icon: Icons.lock_outline,
                hint: "Confirm Password",
                isPassword: true,
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF003B66),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed:
                      authState.status == AuthStatus.loading ? null : _handleRegister,
                  child: Text(
                    authState.status == AuthStatus.loading
                        ? "SIGNING UP..."
                        : "SIGN UP",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 15),
        ),
      ),
    );
  }
}
