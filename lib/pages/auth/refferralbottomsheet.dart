// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';


// class ReferralBottomSheet extends StatefulWidget {
//   final Function(String phone, String referrerId) onApplied;
//   final VoidCallback? onRemoved;

//   const ReferralBottomSheet({
//     super.key,
//     required this.onApplied,
//     this.onRemoved,
//   });

//   @override
//   State<ReferralBottomSheet> createState() => _ReferralBottomSheetState();
// }

// class _ReferralBottomSheetState extends State<ReferralBottomSheet> {
//   final TextEditingController _controller = TextEditingController();

//   bool _loading = false;
//   String? _error;

//   // ================= APPLY REFERRAL =================

//   Future<void> _validateAndApply() async {
//     setState(() {
//       _loading = true;
//       _error = null;
//     });

//     final phone = _controller.text.trim();

//     if (phone.isEmpty) {
//       setState(() {
//         _loading = false;
//         _error = 'Enter phone number';
//       });
//       return;
//     }

//     try {
//       final referrer =
//           await FirestoreService().validateReferralPhone(phone);

//       if (referrer == null) {
//         setState(() {
//           _loading = false;
//           _error = 'Invalid referral phone number';
//         });
//         return;
//       }

//       final currentUser = FirebaseAuth.instance.currentUser;
//       if (currentUser == null) {
//         setState(() {
//           _loading = false;
//           _error = 'User not logged in';
//         });
//         return;
//       }

//       if (referrer['userId'] == currentUser.uid) {
//         setState(() {
//           _loading = false;
//           _error = 'You cannot refer yourself';
//         });
//         return;
//       }

//       final userRef = FirebaseFirestore.instance
//           .collection('Users')
//           .doc(currentUser.uid);

//       await userRef.update({
//         'referredByUserId': referrer['userId'],
//         'referredByPhone': referrer['phone'],
//         'referralUpdatedAt': FieldValue.serverTimestamp(),
//       });

//       widget.onApplied(referrer['phone'], referrer['userId']);
//       Navigator.pop(context);
//     } catch (_) {
//       setState(() {
//         _error = 'Something went wrong. Try again.';
//       });
//     } finally {
//       if (mounted) setState(() => _loading = false);
//     }
//   }

//   // ================= REMOVE REFERRAL =================

//   Future<void> _removeReferral() async {
//     setState(() {
//       _loading = true;
//       _error = null;
//     });

//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) return;

//       await FirebaseFirestore.instance
//           .collection('Users')
//           .doc(user.uid)
//           .update({
//         'referredByUserId': FieldValue.delete(),
//         'referredByPhone': FieldValue.delete(),
//         'referralUpdatedAt': FieldValue.serverTimestamp(),
//       });

//       widget.onRemoved?.call();
//       Navigator.pop(context);
//     } catch (_) {
//       setState(() {
//         _error = 'Failed to remove referral';
//       });
//     } finally {
//       if (mounted) setState(() => _loading = false);
//     }
//   }

//   // ================= UI =================

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.fromLTRB(
//         16,
//         20,
//         16,
//         MediaQuery.of(context).viewInsets.bottom + 24,
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           /// HEADER
//           const Text(
//             'Referral',
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 6),
//           const Text(
//             'Enter a referral phone number to earn rewards',
//             style: TextStyle(fontSize: 13, color: Colors.grey),
//             textAlign: TextAlign.center,
//           ),

//           const SizedBox(height: 16),

//           /// INPUT
//           TextField(
//             controller: _controller,
//             keyboardType: TextInputType.phone,
//             decoration: InputDecoration(
//               hintText: '+91XXXXXXXXXX',
//               errorText: _error,
//               filled: true,
//               fillColor: Colors.grey.shade100,
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//                 borderSide: BorderSide.none,
//               ),
//             ),
//           ),

//           const SizedBox(height: 20),

//           /// APPLY BUTTON (PRIMARY)
//           SizedBox(
//             width: double.infinity,
//             height: 48,
//             child: ElevatedButton(
//               onPressed: _loading ? null : _validateAndApply,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Theme.of(context).primaryColor,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               child: _loading
//                   ? const SizedBox(
//                       width: 22,
//                       height: 22,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2,
//                         color: Colors.white,
//                       ),
//                     )
//                   : const Text(
//                       'Apply Referral',
//                       style: TextStyle(
//                         fontWeight: FontWeight.w600,
//                         fontSize: 15,
//                         color: Colors.white,
//                       ),
//                     ),
//             ),
//           ),

//           const SizedBox(height: 10),

//           /// REMOVE BUTTON (DESTRUCTIVE OUTLINE)
//           SizedBox(
//             width: double.infinity,
//             height: 44,
//             child: OutlinedButton(
//               onPressed: _loading ? null : _removeReferral,
//               style: OutlinedButton.styleFrom(
//                 side: const BorderSide(color: Colors.red),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               child: const Text(
//                 'Remove Referral',
//                 style: TextStyle(
//                   color: Colors.red,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ),

//           SizedBox(height: 50),
//         ],
//       ),
//     );
//   }
// }