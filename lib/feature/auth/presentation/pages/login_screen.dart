import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rojgar/feature/auth/presentation/view_model/auth_view_model.dart';
import 'package:rojgar/feature/auth/presentation/state/auth_state.dart';
import 'package:rojgar/feature/buttom_navigation/presentation/pages/buttom_navigation_screen.dart';
import 'package:rojgar/feature/auth/presentation/pages/register_screen.dart';
import 'package:rojgar/core/utils/my_snackbar.dart';

class LoginScreen extends ConsumerWidget {
  LoginScreen({super.key});

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);

    /// Listen auth state
    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        showMySnackBar(context: context, message: "Login successful");

        Future.delayed(const Duration(seconds: 1), () {
          if (context.mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const ButtomNavigationScreen(),
              ),
            );
          }
        });
      }

      if (next.status == AuthStatus.error) {
        showMySnackBar(
          context: context,
          message: next.errorMessage ?? "Login failed",
          color: Colors.red,
        );
      }
    });

    void handleLogin() {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      if (email.isEmpty || password.isEmpty) {
        showMySnackBar(
          context: context,
          message: "Please fill all fields",
          color: Colors.red,
        );
        return;
      }

      ref.read(authViewModelProvider.notifier).login(
            email: email,
            password: password,
          );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              /// Title
              RichText(
                text: const TextSpan(
                  text: "Let’s ",
                  style: TextStyle(
                    fontSize: 28,
                    color: Colors.black87,
                  ),
                  children: [
                    TextSpan(
                      text: "Sign In",
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
                "Build your career with the best company here.",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),

              const SizedBox(height: 30),

              /// Logo
              Center(
                child: Image.asset(
                  "assets/images/image3.jpg",
                  height: 220,
                ),
              ),

              const SizedBox(height: 30),

              /// Email
              _inputField(
                controller: _emailController,
                hint: "example@gmail.com",
                icon: Icons.email_outlined,
              ),

              const SizedBox(height: 25),

              /// Password
              _inputField(
                controller: _passwordController,
                hint: "Password",
                icon: Icons.lock_outline,
                obscure: true,
              ),

              const SizedBox(height: 30),

              /// Login Button
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
                      authState.status == AuthStatus.loading ? null : handleLogin,
                  child: Text(
                    authState.status == AuthStatus.loading
                        ? "Logging in..."
                        : "Login",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              /// Forgot + Sign up
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {},
                    child: const Text("Forgot password?"),
                  ),
                  Row(
                    children: [
                      const Text("Don’t have an account? "),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// Divider
              Row(
                children: const [
                  Expanded(child: Divider(thickness: 0.7)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text("OR LOGIN WITH"),
                  ),
                  Expanded(child: Divider(thickness: 0.7)),
                ],
              ),

              const SizedBox(height: 25),

              _socialButton(
                icon: "assets/icons/google.png",
                label: "Google",
              ),

              const SizedBox(height: 22),

              _socialButton(
                icon: "assets/icons/facebook.png",
                label: "Facebook",
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Input Field Widget
  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 15),
        ),
      ),
    );
  }

  /// Social Button
  Widget _socialButton({required String icon, required String label}) {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(icon, height: 22),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }
}
