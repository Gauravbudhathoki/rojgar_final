import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rojgar/core/utils/my_snackbar.dart';
import 'package:rojgar/feature/auth/presentation/pages/login_screen.dart';
import 'package:rojgar/feature/auth/presentation/state/auth_state.dart';
import 'package:rojgar/feature/auth/presentation/view_model/auth_view_model.dart';
import 'package:rojgar/feature/auth/presentation/widgets/loginbutton.dart';
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
      SnackbarUtils.showError(context, "Please fill all fields");
      return;
    }

    if (password != confirmPassword) {
      SnackbarUtils.showError(context, "Passwords do not match");
      return;
    }

    // Friend's logic: call register from ViewModel
    ref.read(authViewModelProvider.notifier).register(
          username: username,
          email: email,
          password: password,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    // Friend's logic: listen to auth state changes
    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.registered) {
        SnackbarUtils.showSuccess(
          context,
          "Registration successful! Please login.",
        );

        Future.delayed(const Duration(seconds: 1), () {
          if (context.mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => LoginScreen()),
            );
          }
        });
      }

      if (next.status == AuthStatus.error) {
        SnackbarUtils.showError(
          context,
          next.errorMessage ?? "Registration failed",
        );
      }
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2E3134), Color(0xFF6F6F66)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Image.asset("assets/images/logo.png", height: 280),
                  const SizedBox(height: 10),
                  const Text(
                    "Register",
                    style: TextStyle(
                      color: Color(0xFFFDFCCB),
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Username field
                  _inputField(controller: _usernameController, hint: "Username"),
                  const SizedBox(height: 18),

                  // Email field
                  _inputField(controller: _emailController, hint: "Email"),
                  const SizedBox(height: 18),

                  // Password field
                  _inputField(
                    controller: _passwordController,
                    hint: "Password",
                    obscure: true,
                  ),
                  const SizedBox(height: 18),

                  // Confirm password field
                  _inputField(
                    controller: _confirmPasswordController,
                    hint: "Confirm Password",
                    obscure: true,
                  ),
                  const SizedBox(height: 30),

                  
                  Loginbutton(
                    text: authState.status == AuthStatus.loading
                        ? "SIGNING UP..."
                        : "SIGN UP",
                    onPressed: authState.status == AuthStatus.loading
                        ? () {}
                        : _handleRegister,
                  ),
                  const SizedBox(height: 30),

                  _divider(),
                  const SizedBox(height: 20),
                  _socialRow(),
                  const SizedBox(height: 30),

                  // Login link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account?",
                        style: TextStyle(color: Colors.white),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => LoginScreen()),
                          );
                        },
                        child: const Text(
                          "  LOG IN",
                          style: TextStyle(
                            color: Color(0xFFFDFCCB),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
  }) {
    return Container(
      width: 350,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(border: InputBorder.none, hintText: hint),
      ),
    );
  }

  Widget _divider() {
    return Row(
      children: [
        const SizedBox(width: 50),
        Expanded(child: Container(height: 1, color: Colors.white38)),
        const Text("  OR  ", style: TextStyle(color: Colors.white70)),
        Expanded(child: Container(height: 1, color: Colors.white38)),
        const SizedBox(width: 50),
      ],
    );
  }

  Widget _socialRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {},
          child: Image.asset('assets/icons/github.png', width: 40),
        ),
        const SizedBox(width: 25),
        GestureDetector(
          onTap: () {},
          child: Image.asset('assets/icons/google.png', width: 40),
        ),
      ],
    );
  }
}
