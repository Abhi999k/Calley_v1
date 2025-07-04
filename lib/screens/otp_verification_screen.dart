import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  final String username;
  final String password;

  const OtpVerificationScreen({
    super.key,
    required this.email,
    required this.username,
    required this.password,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _canResend = false;
  int _remainingSeconds = 60;
  Timer? _timer;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    setState(() {
      _canResend = false;
      _remainingSeconds = 60;
    });

    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingSeconds == 0) {
        setState(() => _canResend = true);
        timer.cancel();
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  Future<void> registerUser() async {
    final url = Uri.parse('https://mock-api.calleyacd.com/api/auth/register');

    final body = {
      "username": widget.username,
      "email": widget.email,
      "password": widget.password,
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("✅ Registration successful"),
            duration: Duration(seconds: 2),
          ),
        );
        Future.delayed(Duration(seconds: 1), () {
          Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
        });
      } else {
        final message =
            jsonDecode(response.body)['message'] ?? "Registration failed";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ $message"), duration: Duration(seconds: 2)),
        );
      }
    } catch (e) {
      print("❌ Registration error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Network error during registration"),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> verifyOtpAndRegister() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter a valid 6-digit OTP")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('https://mock-api.calleyacd.com/api/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"email": widget.email, "otp": otp}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("✅ OTP Verified"),
            duration: Duration(seconds: 1),
          ),
        );
        await registerUser();
      } else {
        final message = jsonDecode(response.body)['message'] ?? "Invalid OTP";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ $message"), duration: Duration(seconds: 2)),
        );
      }
    } catch (e) {
      print("Error verifying OTP: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Network error during OTP verification"),
          duration: Duration(seconds: 2),
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text(
                'CALLEY_V1',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                'CALL DIALER BY AK',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Email OTP Verification',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'Please enter the OTP sent to your email.\nEmail: ${widget.email}',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[700]),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _otpController,
                maxLength: 6,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, letterSpacing: 16),
                decoration: InputDecoration(
                  counterText: "",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 18),
                ),
              ),
              const SizedBox(height: 10),
              _canResend
                  ? Text(
                      "If you didn't receive the OTP, try again after registering.",
                      style: TextStyle(color: Colors.grey),
                    )
                  : Text(
                      "Wait $_remainingSeconds seconds",
                      style: TextStyle(color: Colors.grey),
                    ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: isLoading ? null : verifyOtpAndRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isLoading ? "Verifying..." : "Verify and Register",
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
    );
  }
}
