// Push notifications are TABLED UNTIL LAUNCH.
//
// The `firebase_messaging` dependency is commented out in pubspec.yaml, so this
// is a no-op stub that keeps the app building. `register()` is still called from
// the auth gate — it just does nothing for now.
//
// TO RE-ENABLE AT LAUNCH:
//   1. Uncomment `firebase_messaging` in pubspec.yaml, then `flutter pub get`.
//   2. Replace this file's body with the real implementation below.
//   3. Deploy the `sendDailyNudges` Cloud Function (needs Blaze + Cloud Scheduler).
//
// ── Real implementation (paste back in) ─────────────────────────────────────
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
//
// class NotificationService {
//   NotificationService._();
//   static final NotificationService instance = NotificationService._();
//   final FirebaseMessaging _fm = FirebaseMessaging.instance;
//
//   Future<void> register() async {
//     try {
//       final settings =
//           await _fm.requestPermission(alert: true, badge: true, sound: true);
//       if (settings.authorizationStatus == AuthorizationStatus.denied) {
//         await _clearToken();
//         return;
//       }
//       final token = await _fm.getToken();
//       if (token != null) await _saveToken(token);
//       _fm.onTokenRefresh.listen(_saveToken);
//     } catch (_) {}
//   }
//
//   Future<void> _saveToken(String token) async {
//     final uid = FirebaseAuth.instance.currentUser?.uid;
//     if (uid == null) return;
//     try {
//       await FirebaseFirestore.instance.collection('users').doc(uid).set({
//         'fcmToken': token,
//         'notifOptOut': false,
//         'notifUpdatedAt': FieldValue.serverTimestamp(),
//       }, SetOptions(merge: true));
//     } catch (_) {}
//   }
//
//   Future<void> _clearToken() async {
//     final uid = FirebaseAuth.instance.currentUser?.uid;
//     if (uid == null) return;
//     try {
//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(uid)
//           .set({'fcmToken': FieldValue.delete()}, SetOptions(merge: true));
//     } catch (_) {}
//   }
// }

/// No-op stub while push notifications are tabled until launch.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  /// Does nothing until FCM is re-enabled (see notes at top of file).
  Future<void> register() async {}
}
