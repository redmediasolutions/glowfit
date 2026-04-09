import 'dart:async';

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
  final Color primaryColor = const Color(0xFF6366F1); // Modern Indigo
  final Color secondaryColor = const Color(0xFFF1F5F9); // Light Slate

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

//================================ SAVE USER TO FIRESTORE WITH TIMEOUT ================================
  Future<void> _saveUserToFirestore(User user) async {
    try {
      final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);

      await userDoc.set({
        'uid': user.uid,
        'phoneNumber': user.phoneNumber,
        'lastLogin': FieldValue.serverTimestamp(),
        'full_name': user.displayName ?? "", 
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Firestore save took too long');
        },
      );
    } catch (e) {
      debugPrint("Firestore save error: $e");
      // Don't rethrow - user is already authenticated, Firestore will retry
    }
  }

//===============================OTP SENDING LOGIC - FIXED FOR iOS ===============================
  Future<void> _sendOtp() async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);
    final String fullPhoneNumber = "+91${_phoneController.text.trim()}";
    
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: fullPhoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          if (!mounted) return;
          
          try {
            UserCredential userCredential = await _auth.signInWithCredential(credential);
            
            if (!mounted) return;
            
            if (userCredential.user != null) {
              await _saveUserToFirestore(userCredential.user!);
            }
            
            if (!mounted) return;
            _navigateToHomeIfMounted();
            
          } catch (e) {
            debugPrint("Auto-verification error: $e");
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Verification Failed: ${e.message}")),
            );
            setState(() => _isLoading = false);
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          if (mounted) {
            setState(() {
              _verificationId = verificationId;
              _isOtpSent = true;
              _isLoading = false;
            });
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        timeout: const Duration(seconds: 120),
      );
    } catch (e) {
      debugPrint("Error sending OTP: $e");
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to send OTP. Try again.")),
        );
      }
    }
  }
  
//===============================OTP VERIFICATION LOGIC - FIXED FOR iOS ===============================
  Future<void> _verifyOtp() async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);
    
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _otpController.text.trim(),
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);

      // CHECK MOUNTED BEFORE PROCEEDING
      if (!mounted) return;

      // SAVE TO FIRESTORE
      if (userCredential.user != null) {
        await _saveUserToFirestore(userCredential.user!);
      }

      // CHECK MOUNTED AGAIN BEFORE NAVIGATION
      if (!mounted) return;

      // USE SAFE NAVIGATION
      _navigateToHomeIfMounted();
      
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String errorMsg = "Invalid OTP. Try again.";
        if (e.code == 'invalid-verification-code') {
          errorMsg = "The code you entered is incorrect.";
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg)),
        );
      }
    } catch (e) {
      debugPrint("OTP verification error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Verification failed. Try again.")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// SAFE NAVIGATION - Won't crash even if context is disposed
  void _navigateToHomeIfMounted() {
    if (!mounted) return;
    
    try {
      context.go('/home', extra: int.parse(categoryId));
    } catch (e) {
      debugPrint("Navigation error: $e");
      // Silent fail - widget is likely disposed
    }
  }

//============================ UI BUILD METHOD WITH MODERN DESIGN ==============================
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
              // Header Image/Icon
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
              // Dynamic Text Section
              Text(
                _isOtpSent ? "Verification" : "Welcome Back",
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _isOtpSent
                    ? "We've sent a 6-digit code to ${_phoneController.text}"
                    : "Sign in to continue your shopping journey.",
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 50),

              if (!_isOtpSent) ...[
                // Phone Input
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    // Adds the +91 prefix permanently to the start of the field
                    prefixIcon: const Icon(Icons.phone_android),
                    prefixText: "+91 ",
                    prefixStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    hintText: "Enter Mobile Number",
                    filled: true,
                    fillColor: secondaryColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ] else ...[
                // Custom Pinput Design
                Center(
                  child: Pinput(
                    length: 6,
                    controller: _otpController,
                    onCompleted: (pin) => _verifyOtp(),
                    defaultPinTheme: PinTheme(
                      width: 50,
                      height: 56,
                      textStyle: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: BoxDecoration(
                        color: secondaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    focusedPinTheme: PinTheme(
                      width: 50,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: primaryColor, width: 2),
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 40),

              // Main Button
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton(
                        onPressed: _isOtpSent ? _verifyOtp : _sendOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          _isOtpSent ? "Verify Now" : "Get Verification Code",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

              if (_isOtpSent) ...[
                const SizedBox(height: 15),
                Center(
                  child: TextButton(
                    onPressed: () => setState(() => _isOtpSent = false),
                    child: Text(
                      "Edit Phone Number",
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
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