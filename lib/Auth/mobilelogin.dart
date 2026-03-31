import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';

class MobileLogin extends StatefulWidget {
  const MobileLogin({super.key});

  @override
  State<MobileLogin> createState() => _MobileLoginState();
}

final String categoryId = "0";

class _MobileLoginState extends State<MobileLogin> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _verificationId = "";
  bool _isOtpSent = false;
  bool _isLoading = false;

  final Color primaryColor = const Color(0xFF6366F1);
  final Color secondaryColor = const Color(0xFFF1F5F9);

  // ================= SAVE USER =================
  Future<void> _saveUserToFirestore(User user) async {
    final userDoc =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

    await userDoc.set({
      'uid': user.uid,
      'phoneNumber': user.phoneNumber,
      'isGuest': user.isAnonymous, // ✅ important
      'lastLogin': FieldValue.serverTimestamp(),
      'full_name': user.displayName ?? "",
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // ================= GUEST LOGIN =================
  Future<void> _handleGuestLogin() async {
    setState(() => _isLoading = true);

    try {
      User? user = _auth.currentUser;

      // If no user → create guest
      if (user == null) {
        final result = await _auth.signInAnonymously();
        user = result.user;
      }

      if (user != null) {
        await _saveUserToFirestore(user);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Continuing as Guest")),
        );

        context.go('/home', extra: int.parse(categoryId));
      }
    } catch (e) {
      debugPrint("Guest Login Error: $e");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Guest Login Failed")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ================= SEND OTP =================
  Future<void> _sendOtp() async {
    setState(() => _isLoading = true);
    final String fullPhoneNumber = "+91${_phoneController.text.trim()}";

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: fullPhoneNumber,

        verificationCompleted: (PhoneAuthCredential credential) async {
          UserCredential userCredential =
              await _auth.signInWithCredential(credential);

          if (userCredential.user != null) {
            await _saveUserToFirestore(userCredential.user!);
          }

          _navigateToHome();
        },

        verificationFailed: (FirebaseAuthException e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Verification Failed: ${e.message}")),
          );
          setState(() => _isLoading = false);
        },

        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _isOtpSent = true;
            _isLoading = false;
          });
        },

        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      debugPrint("Error: $e");
      setState(() => _isLoading = false);
    }
  }

  // ================= VERIFY OTP =================
  Future<void> _verifyOtp() async {
    setState(() => _isLoading = true);

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _otpController.text.trim(),
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        await _saveUserToFirestore(userCredential.user!);
      }

      if (!mounted) return;

      _navigateToHome();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid OTP. Try again.")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateToHome() {
    context.go('/home', extra: int.parse(categoryId));
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),

              // Icon
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.shopping_bag_rounded,
                    size: 60,
                    color: primaryColor,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              Text(
                _isOtpSent ? "Verification" : "Welcome Back",
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                _isOtpSent
                    ? "We've sent a 6-digit code to ${_phoneController.text}"
                    : "Sign in to continue your shopping journey.",
                style: TextStyle(color: Colors.grey[600]),
              ),

              const SizedBox(height: 50),

              if (!_isOtpSent) ...[
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.phone_android),
                    prefixText: "+91 ",
                    filled: true,
                    fillColor: secondaryColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    hintText: "Enter Mobile Number",
                  ),
                ),
              ] else ...[
                Center(
                  child: Pinput(
                    length: 6,
                    controller: _otpController,
                    onCompleted: (pin) => _verifyOtp(),
                  ),
                ),
              ],

              const SizedBox(height: 40),

              // OTP Button
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton(
                        onPressed: _isOtpSent ? _verifyOtp : _sendOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          _isOtpSent ? "Verify Now" : "Get Verification Code",
                        ),
                      ),
                    ),

              // ✅ GUEST BUTTON ADDED HERE
              if (!_isOtpSent) ...[
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _handleGuestLogin,
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "Continue as Guest",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],

              if (_isOtpSent) ...[
                const SizedBox(height: 15),
                Center(
                  child: TextButton(
                    onPressed: () => setState(() => _isOtpSent = false),
                    child: Text(
                      "Edit Phone Number",
                      style: TextStyle(color: primaryColor),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}