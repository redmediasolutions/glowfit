// Import for JSON
import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';

import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http; // Import for HTTP
import 'package:firebase_auth/firebase_auth.dart'; // Import for Auth

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
final String categoryId = "0";
// --- MAIN LOGIN WIDGET ---
class MobileLoginWidget extends StatefulWidget {
  const MobileLoginWidget({super.key});

  static String routeName = 'MobileLogin';
  static String routePath = '/mobileLogin';

  @override
  State<MobileLoginWidget> createState() => _MobileLoginWidgetState();
}

class _MobileLoginWidgetState extends State<MobileLoginWidget> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;
  String _remoteLogoUrl = "";

  @override
  void initState() {
    super.initState();
    _fetchRemoteLogo();
  }

  // --- FETCH REMOTE CONFIG LOGO ---
  Future<void> _fetchRemoteLogo() async {
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1),
      ));

      await remoteConfig.fetchAndActivate();
      String url = remoteConfig.getString('logo');

      if (url.isNotEmpty && mounted) {
        setState(() {
          _remoteLogoUrl = url;
        });
      }
    } catch (e) {
      print("Remote Config Error: $e");
    }
  }

  // --- 1. SEND OTP FUNCTION ---
  Future<void> _handleSendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Enter a phone number")));
      return;
    }

    setState(() => _isLoading = true);

    const String url =
        'https://us-central1-medz-9eda1.cloudfunctions.net/sendMsg91Otp';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phoneNumber': phone}),
      );

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        final reqId = data['reqId'];

        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("OTP Sent!")));

          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: OtpVerificationSheet(phoneNumber: phone, reqId: reqId),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(data['error'] ?? "Failed to send OTP")));
        }
      }
    } catch (e) {
      print("Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Network Error")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- 3. GUEST LOGIN FUNCTION ---
  Future<void> _handleGuestLogin() async {
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInAnonymously();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Logged in as Guest Successfully!")));
        context.push('/home'); // <--- Already correct here
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Guest Login Failed: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const animDuration = Duration(milliseconds: 600);
    const animCurve = Curves.easeOutQuart;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),

            // --- LOGO ---
            Center(
              child: _remoteLogoUrl.isNotEmpty
                  ? Image.network(
                      _remoteLogoUrl,
                      height: 100,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/images/Logo-108medz_-_Logo_for_app.png',
                          height: 100,
                          fit: BoxFit.contain,
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return SizedBox(
                            height: 100,
                            child: Center(child: CircularProgressIndicator()));
                      },
                    )
                  : SizedBox.shrink(),
            ).animate().fade(duration: animDuration).scale(
                begin: Offset(0.8, 0.8), end: Offset(1, 1), curve: animCurve),

            if (_remoteLogoUrl.isNotEmpty) SizedBox(height: 20),

            // --- TITLE ---
            Text(
              '108 Medz',
              style: TextStyle(
                color: Color(0xFF1D376A),
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            )
                .animate()
                .fade(duration: animDuration, delay: 100.ms)
                .slideY(begin: 0.3, end: 0, curve: animCurve),

            SizedBox(height: 5),

            Text(
              'Save Upto 70% on Medicines',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            )
                .animate()
                .fade(duration: animDuration, delay: 200.ms)
                .slideY(begin: 0.3, end: 0, curve: animCurve),

            SizedBox(height: 40),

            Text(
              'Get Started',
              style: TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            )
                .animate()
                .fade(duration: animDuration, delay: 300.ms)
                .slideY(begin: 0.3, end: 0, curve: animCurve),

            SizedBox(height: 10),

            Text('Enter your WhatsApp number',
                    style: TextStyle(color: Colors.grey[600]))
                .animate()
                .fade(duration: animDuration, delay: 400.ms),

            SizedBox(height: 8),

            // --- INPUT FIELD ---
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  SizedBox(width: 8),
                  Text('+91',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter mobile number',
                        hintStyle: TextStyle(
                            color: const Color.fromARGB(255, 96, 96, 96)),
                      ),
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fade(duration: animDuration, delay: 500.ms)
                .slideY(begin: 0.2, end: 0, curve: animCurve),

            SizedBox(height: 24),

            // --- GET OTP BUTTON ---
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSendOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1D376A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Get OTP',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
              ),
            )
                .animate()
                .fade(duration: animDuration, delay: 600.ms)
                .slideY(begin: 0.2, end: 0, curve: animCurve),

            SizedBox(height: 16),

            // --- GUEST BUTTON ---
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
                      color: const Color.fromARGB(255, 194, 194, 194)),
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
            )
                .animate()
                .fade(duration: animDuration, delay: 700.ms)
                .slideY(begin: 0.2, end: 0, curve: animCurve),

            SizedBox(height: 32),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// --- BOTTOM SHEET WIDGET ---
class OtpVerificationSheet extends StatefulWidget {
  final String phoneNumber;
  final String reqId;

  const OtpVerificationSheet(
      {super.key, required this.phoneNumber, required this.reqId});

  @override
  State<OtpVerificationSheet> createState() => _OtpVerificationSheetState();
}

class _OtpVerificationSheetState extends State<OtpVerificationSheet> {
  final TextEditingController _otpController = TextEditingController();
  bool _isVerifying = false;

  Future<void> _handleVerifyOtp() async {
    final otp = _otpController.text.trim();

    if (otp.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter valid OTP")),
      );
      return;
    }

    setState(() => _isVerifying = true);

    const String url =
        'https://us-central1-medz-9eda1.cloudfunctions.net/verifyMsg91Otp';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phoneNumber': widget.phoneNumber,
          'otp': otp,
          'reqId': widget.reqId,
        }),
      );

      final data = jsonDecode(response.body);

      if (data['success'] != true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? "Invalid OTP")),
          );
        }
        return;
      }

      final String token = data['token'];
      final bool isNewUser = data['isNewUser'] == true;

      // ✅ Sign in to Firebase
      await FirebaseAuth.instance.signInWithCustomToken(token);

      if (!mounted) return;

      // ✅ Get root context BEFORE popping
      final rootContext = Navigator.of(context, rootNavigator: true).context;

      // ✅ Close OTP Bottom Sheet
      Navigator.of(context).pop();

      // ✅ Wait for close animation
      await Future.delayed(const Duration(milliseconds: 300));

      // ✅ If new user → open referral sheet
      // if (isNewUser) {
      //   final referralData = await showModalBottomSheet<Map<String, String>>(
      //     context: rootContext,
      //     isScrollControlled: true,
      //     shape: const RoundedRectangleBorder(
      //       borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      //     ),
      //     builder: (sheetContext) {
      //       return ReferralBottomSheet(
      //         onApplied: (String phone, String referrerId) {
      //           Navigator.pop(sheetContext, {
      //             'userId': referrerId,
      //             'phone': phone,
      //           });
      //         },
      //       );
      //     },
      //   );

      //   // 🔥 Optional: Save referral to Firestore here
      //   if (referralData != null) {
      //     print("Referral Applied: $referralData");
      //   }
      // }

      // ✅ Navigate to Home
      if (mounted) {
         GoRouter.of(rootContext).go('/home', extra: int.parse(categoryId));
      }
    } catch (e) {
      print("Verify Error: $e");

      // Only show error if login truly failed
      if (FirebaseAuth.instance.currentUser == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Verification Failed")),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isVerifying = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24),
      height: 400,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Verification',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Enter the code sent to +91 ${widget.phoneNumber} on WhatsApp',
            style: TextStyle(color: Colors.grey[600]),
          ),
          SizedBox(height: 32),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
              maxLength: 6,
              decoration: InputDecoration(
                counterText: "",
                border: InputBorder.none,
                hintText: '0000',
                hintStyle: TextStyle(color: Colors.grey[400], letterSpacing: 8),
              ),
            ),
          ),
          SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isVerifying ? null : _handleVerifyOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF36B44A),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: _isVerifying
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Verify & Login',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
            ),
          ),
        ],
      )
          .animate()
          .slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOut),
    );
  }
}

// Future<Map<String, String>?> _openReferralBottomSheet(
//   BuildContext context,
// ) {
//   return showModalBottomSheet<Map<String, String>>(
//     context: context,
//     isScrollControlled: true,
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//     ),
//     builder: (sheetContext) {
//       return ReferralBottomSheet(
//         onApplied: (String phone, String referrerId) {
//           Navigator.pop(sheetContext, {
//             'userId': referrerId,
//             'phone': phone,
//           });
//         },
//       );
//     },
//   );
// }
