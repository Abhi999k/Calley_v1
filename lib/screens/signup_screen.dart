import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'otp_verification_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final whatsappController = TextEditingController();
  final passwordController = TextEditingController();

  bool agreeTerms = false;
  bool isLoading = false;

  Future<void> sendOtp() async {
    final email = emailController.text.trim();

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('https://mock-api.calleyacd.com/api/auth/send-otp'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("\ud83d\udce9 OTP sent to email")),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OtpVerificationScreen(
              email: emailController.text.trim(),
              username: nameController.text.trim(),
              password: passwordController.text.trim(),
            ),
          ),
        );
      } else if (response.statusCode == 400) {
        final data = jsonDecode(response.body);
        final message = data['message'] ?? "\u274c Email already registered";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("\u274c $message"),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("\u274c Failed to send OTP")),
        );
      }
    } catch (e) {
      debugPrint("OTP send error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("\u274c Network error while sending OTP")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void handleSignup() {
    if (_formKey.currentState!.validate() && agreeTerms) {
      sendOtp();
    } else if (!agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept Terms and Conditions')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text(
                  'CALLEY_V1',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                    letterSpacing: 1.5,
                  ),
                ),
                const Text(
                  'CALL DIALER BY AK',
                  style: TextStyle(
                    fontSize: 12,
                    letterSpacing: 1.2,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Welcome!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please register to continue',
                  style: TextStyle(color: Colors.grey[700]),
                ),
                const SizedBox(height: 30),

                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: 'Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: const Icon(Icons.person_outline),
                  ),
                  validator: (val) =>
                      val!.isEmpty ? 'Please enter your name' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Email address',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: const Icon(Icons.email_outlined),
                  ),
                  validator: (val) =>
                      val!.contains('@') ? null : 'Enter a valid email',
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: const Icon(Icons.lock_outline),
                  ),
                  validator: (val) =>
                      val!.length < 6 ? 'Minimum 6 characters' : null,
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('\ud83c\udde8\ud83c\uddee +91'),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: 'Mobile number',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          suffixIcon: const Icon(Icons.phone_outlined),
                        ),
                        validator: (val) =>
                            val!.length < 10 ? 'Invalid mobile number' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: whatsappController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: 'WhatsApp number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: const Padding(
                      padding: EdgeInsets.only(top: 12, bottom: 12, left: 12),
                      child: FaIcon(
                        FontAwesomeIcons.whatsapp,
                        color: Colors.green,
                        size: 22,
                      ),
                    ),
                  ),
                  validator: (val) =>
                      val!.length < 10 ? 'Invalid WhatsApp number' : null,
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Checkbox(
                      value: agreeTerms,
                      onChanged: (value) => setState(() => agreeTerms = value!),
                    ),
                    const Text("I agree to the "),
                    GestureDetector(
                      onTap: () {},
                      child: const Text(
                        "Terms and Conditions",
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account? "),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/login'),
                      child: const Text(
                        "Sign In",
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: isLoading ? null : handleSignup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
