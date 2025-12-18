import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                  style: TextStyle(
                    fontSize: 28,
                    color: Colors.black87,
                  ),
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
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),

              const SizedBox(height: 30),


              inputField(
                icon: Icons.person_outline,
                hint: "Full Name",
              ),

              const SizedBox(height: 20),


              inputField(
                icon: Icons.phone_android,
                hint: "Phone Number",
              ),

              const SizedBox(height: 20),

              inputField(
                icon: Icons.email_outlined,
                hint: "Email",
              ),

              const SizedBox(height: 20),


              inputField(
                icon: Icons.lock_outline,
                hint: "Password",
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
                  onPressed: () {},
                  child: const Text(
                    "Sign Up",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 30),


              Row(
                children: const [
                  Expanded(child: Divider(thickness: 0.7)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text("OR SIGN UP WITH"),
                  ),
                  Expanded(child: Divider(thickness: 0.7)),
                ],
              ),

              const SizedBox(height: 25),


              socialButton(
                icon: "assets/icons/google.png",
                label: "Google",
              ),

              const SizedBox(height: 20),


              socialButton(
                icon: "assets/icons/facebook.png",
                label: "Facebook",
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }


  Widget inputField({
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


  Widget socialButton({required String icon, required String label}) {
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