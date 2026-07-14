import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

/// A user record as shown in the admin panel. Backed by users/{uid}, which
/// every sign-up mirrors via AuthService.syncUserDoc().
class AdminUser {
  final String uid;
  final String? email;
  final String? name;
  final bool premium;
  final bool disabled;
  final int pedis;
  final int xp;
  final DateTime? createdAt;
  final DateTime? lastSeen;

  AdminUser({
    required this.uid,
    this.email,
    this.name,
    this.premium = false,
    this.disabled = false,
    this.pedis = 0,
    this.xp = 0,
    this.createdAt,
    this.lastSeen,
  });

  factory AdminUser.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? {};
    DateTime? ts(dynamic v) => v is Timestamp ? v.toDate() : null;
    return AdminUser(
      uid: d.id,
      email: m['email'] as String?,
      name: m['name'] as String?,
      premium: (m['premium'] as bool?) ?? false,
      disabled: (m['disabled'] as bool?) ?? false,
      pedis: (m['pedis'] as num?)?.toInt() ?? 0,
      xp: (m['xp'] as num?)?.toInt() ?? 0,
      createdAt: ts(m['createdAt']),
      lastSeen: ts(m['lastSeen']),
    );
  }

  String get label =>
      (name != null && name!.trim().isNotEmpty) ? name! : (email ?? uid);
}

/// Admin-only operations over the users collection. All writes require the
/// caller to be in admins/{uid} (enforced by firestore.rules).
class AdminService {
  final _db = FirebaseFirestore.instance;

  /// Live stream of all sign-ups, newest first (by createdAt).
  Stream<List<AdminUser>> usersStream() {
    return _db
        .collection('users')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(AdminUser.fromDoc).toList());
  }

  Future<void> setPremium(String uid, bool value) {
    return _db.collection('users').doc(uid).set({
      'premium': value,
      'premiumSince': value ? FieldValue.serverTimestamp() : null,
    }, SetOptions(merge: true));
  }

  /// Suspends or restores an account. The app gate (auth_gate.dart) blocks
  /// access whenever `disabled` is true.
  Future<void> setDisabled(String uid, bool value) {
    return _db
        .collection('users')
        .doc(uid)
        .set({'disabled': value}, SetOptions(merge: true));
  }

  Future<void> addPedis(String uid, int delta) {
    return _db
        .collection('users')
        .doc(uid)
        .set({'pedis': FieldValue.increment(delta)}, SetOptions(merge: true));
  }

  /// Permanently deletes the user — Auth login + Firestore records — via the
  /// `adminDeleteUser` Cloud Function (Admin SDK). The function re-verifies the
  /// caller is an admin server-side. Throws FirebaseFunctionsException on
  /// failure (e.g. permission-denied, or trying to delete your own account).
  Future<void> deleteUser(String uid) async {
    final callable =
        FirebaseFunctions.instance.httpsCallable('adminDeleteUser');
    await callable.call<Map<String, dynamic>>({'uid': uid});
  }
}
