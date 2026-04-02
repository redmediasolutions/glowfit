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


//================================ save user to firestore after successful login ================================
Future<void> _saveUserToFirestore(User user) async {
  final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);

  await userDoc.set({
    'uid': user.uid,
    'phoneNumber': user.phoneNumber,
    'lastLogin': FieldValue.serverTimestamp(),
    // We set these as empty if it's a new user, 
    // so the Profile page can fetch them later
    'full_name': user.displayName ?? "", 
    'createdAt': FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));
}
//===============================OTP SENDING LOGIC===============================
  Future<void> _sendOtp() async {
    setState(() => _isLoading = true);
    final String fullPhoneNumber = "+91${_phoneController.text.trim()}";
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber:fullPhoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
  UserCredential userCredential = await _auth.signInWithCredential(credential);
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
  
//===============================OPT VERIFICATION LOGIC===============================
Future<void> _verifyOtp() async {
  setState(() => _isLoading = true);
  try {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: _verificationId,
      smsCode: _otpController.text.trim(),
    );

    UserCredential userCredential = await _auth.signInWithCredential(credential);

    // 1. SAVE TO FIRESTORE
    if (userCredential.user != null) {
      await _saveUserToFirestore(userCredential.user!);
    }

    // 2. THE FIX: Check if the widget is still mounted before using context
    if (!mounted) return; 

    _navigateToHome();
    
  } catch (e) {
    // 3. THE FIX: Check here too before showing a SnackBar
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid OTP. Try again.")),
      );
    }
  } finally {
    // 4. THE FIX: Check before calling setState
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}
  void _navigateToHome() {
    context.go('/home', extra: int.parse(categoryId));
  }

  Future<void> _handleGuestLogin() async {
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInAnonymously();
      if (!mounted) return;
      _navigateToHome();
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Guest Login Failed: ${e.message}")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Guest Login Failed")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
                          const SizedBox(height: 8),
                          Text(
                            _isOtpSent
                                ? "We sent a 6-digit code to +91 ${_phoneController.text}"
                                : "Sign in to save your cart and track orders.",
                            style: TextStyle(
                              fontSize: 15,
                              color: inkColor.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 26),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 18,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (!_isOtpSent && _showPhoneInput) ...[
                                  TextField(
                                    controller: _phoneController,
                                    keyboardType: TextInputType.phone,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: inkColor,
                                    ),
                                    decoration: InputDecoration(
                                      prefixIcon: const Icon(Icons.phone_android),
                                      prefixText: "+91 ",
                                      prefixStyle: TextStyle(
                                        color: inkColor,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
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
                                  const SizedBox(height: 18),
                                ],
                                if (_isOtpSent) ...[
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
                                          border: Border.all(
                                            color: primaryColor,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                ],
                                _isLoading
                                    ? const Center(
                                        child: CircularProgressIndicator(),
                                      )
                                    : Column(
                                        children: [
                                          SizedBox(
                                            width: double.infinity,
                                            height: 56,
                                            child: ElevatedButton(
                                              onPressed: _isOtpSent
                                                  ? _verifyOtp
                                                  : () {
                                                      if (!_showPhoneInput) {
                                                        setState(() {
                                                          _showPhoneInput = true;
                                                        });
                                                        return;
                                                      }
                                                      _sendOtp();
                                                    },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: primaryColor,
                                                foregroundColor: Colors.white,
                                                elevation: 0,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                              ),
                                              child: Text(
                                                _isOtpSent
                                                    ? "Verify Now"
                                                    : "Continue with Phone",
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          if (!_isOtpSent && allowGuest) ...[
                                            const SizedBox(height: 12),
                                            SizedBox(
                                              width: double.infinity,
                                              height: 54,
                                              child: OutlinedButton(
                                                onPressed: _handleGuestLogin,
                                                style: OutlinedButton.styleFrom(
                                                  foregroundColor: primaryColor,
                                                  side: BorderSide(
                                                    color: primaryColor,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(16),
                                                  ),
                                                ),
                                                child: const Text(
                                                  "Continue as Guest",
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                              ],
                            ),
                          ),
                          if (!_isOtpSent && _showPhoneInput) ...[
                            const SizedBox(height: 12),
                            Center(
                              child: TextButton(
                                onPressed: () {
                                  setState(() {
                                    _showPhoneInput = false;
                                  });
                                },
                                child: Text(
                                  "Back",
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                          if (_isOtpSent) ...[
                            const SizedBox(height: 12),
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
                          const Spacer(),
                        ],
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
