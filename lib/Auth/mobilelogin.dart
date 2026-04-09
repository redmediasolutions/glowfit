import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
  bool _showPhoneInput = false;
  final Color primaryColor = const Color(0xFF8A206E);
  final Color secondaryColor = const Color(0xFFF6F1EE);
  final Color inkColor = const Color(0xFF1D212C);

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
  //=============================== GUEST LOGIN LOGIC ===============================
Future<void> _handleGuestLogin() async {
  if (_isLoading) return; // Prevent double taps

  setState(() => _isLoading = true);
  try {
    // 1. Perform Firebase Auth
    await FirebaseAuth.instance.signInAnonymously();

    if (mounted) {
      // 2. IMPORTANT: Close the BottomSheet first.
      // This prevents the "keyReservation" crash by clearing the modal
      // before the Router tries to rebuild the background page.
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Logged in as Guest Successfully!"),
          duration: Duration(seconds: 2),
        ),
      );

      // 3. Navigate to home using .go (replaces stack)
      context.go('/home');
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Guest Login Failed: $e")),
      );
    }
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}

//=============================== SAFE NAVIGATION ===============================
void _navigateToHomeIfMounted() {
  if (!mounted) return;

  try {
    // Always pop the sheet before switching main routes with GoRouter
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    
    // Pass extra if your route requires the categoryId
    context.go('/home', extra: int.parse(categoryId));
  } catch (e) {
    debugPrint("Navigation error: $e");
  }
}
//============================ UI BUILD METHOD WITH MODERN DESIGN ==============================
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final bool allowGuest = user == null;

    return Scaffold(
      backgroundColor: secondaryColor,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: -120,
              right: -80,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -140,
              left: -60,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(26, 28, 26, 30),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.06),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: SvgPicture.asset(
                                  'assets/images/app-header.svg',
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Gladskin",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: inkColor,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                  Text(
                                    "Skincare, thoughtfully curated",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: inkColor.withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),
                          Text(
                            _isOtpSent ? "Verify your number" : "Welcome back",
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              color: inkColor,
                              letterSpacing: -0.4,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25,),
                    SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _handleGuestLogin,
                    onLongPress: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => const DeveloperLoginPage(),
                      //   ),
                      // );
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: const Color.fromARGB(255, 194, 194, 194),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Login as Guest',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 122, 122, 122),
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
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}