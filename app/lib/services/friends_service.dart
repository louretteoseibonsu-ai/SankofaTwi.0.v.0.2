import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// A friend you're connected with (via invite codes).
class Friend {
  final String uid;
  final String name;
  Friend(this.uid, this.name);
}

/// One row in the friends leaderboard.
class FriendRank {
  final String uid;
  final String name;
  final String? photoURL;
  final int xp;
  final bool isMe;
  FriendRank({
    required this.uid,
    required this.name,
    required this.photoURL,
    required this.xp,
    required this.isMe,
  });
}

/// Invite & Earn + Learn-with-friends. The reward/friendship writes happen in
/// Cloud Functions (getInviteCode / redeemReferral) so a friend's account can be
/// credited securely.
class FriendsService {
  final FirebaseFunctions _fns = FirebaseFunctions.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  /// The current user's invite code (created on first call).
  Future<String> inviteCode() async {
    final r = await _fns.httpsCallable('getInviteCode').call();
    return ((r.data as Map)['code'] ?? '').toString();
  }

  /// Redeems a friend's code. Returns the pedis reward. Throws
  /// FirebaseFunctionsException on invalid/duplicate/own code.
  Future<int> redeem(String code) async {
    final r = await _fns
        .httpsCallable('redeemReferral')
        .call<Map<String, dynamic>>({'code': code});
    return (r.data['reward'] as num?)?.toInt() ?? 0;
  }

  /// Live list of your friends.
  Stream<List<Friend>> friends() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();
    return _db
        .collection('users')
        .doc(uid)
        .collection('friends')
        .snapshots()
        .map((s) => s.docs
            .map((d) => Friend(d.id, (d.data()['name'] ?? 'Friend').toString()))
            .toList());
  }

  /// You + your friends, ranked by XP (reads the public leaderboard docs).
  Future<List<FriendRank>> friendsLeaderboard() async {
    final uid = _uid;
    if (uid == null) return [];
    final fsnap =
        await _db.collection('users').doc(uid).collection('friends').get();
    final ids = <String>{...fsnap.docs.map((d) => d.id), uid};
    final ranks = <FriendRank>[];
    for (final id in ids) {
      final lb = await _db.collection('leaderboard').doc(id).get();
      final m = lb.data();
      if (m == null) continue;
      ranks.add(FriendRank(
        uid: id,
        name: (m['name'] ?? 'Friend').toString(),
        photoURL: m['photoURL']?.toString(),
        xp: (m['xp'] as num?)?.toInt() ?? 0,
        isMe: id == uid,
      ));
    }
    ranks.sort((a, b) => b.xp.compareTo(a.xp));
    return ranks;
  }
}
