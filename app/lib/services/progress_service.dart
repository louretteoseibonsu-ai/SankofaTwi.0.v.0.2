import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/lesson_catalog.dart';

/// Score (out of 10) needed to pass a lesson and unlock the next.
const int kPassScore = 6;

class Progress {
  final Map<String, int> best; // lessonId -> best correct (0..10)
  const Progress(this.best);

  static const empty = Progress({});

  int get totalXp => best.values.fold(0, (a, b) => a + b * 10);
  int get level => 1 + totalXp ~/ 100;
  int get xpIntoLevel => totalXp % 100;
  int get xpForNextLevel => 100;

  bool passed(String id) => (best[id] ?? 0) >= kPassScore;

  bool unlocked(String id) {
    final i = kLessonsFlat.indexWhere((l) => l.id == id);
    if (i <= 0) return true; // first lesson always open
    return passed(kLessonsFlat[i - 1].id);
  }

  /// 0..1 mastery for a category (average best across its lessons).
  double categoryMastery(LessonCategory c) {
    if (c.lessons.isEmpty) return 0;
    final got = c.lessons.fold<int>(0, (a, l) => a + (best[l.id] ?? 0));
    return got / (c.lessons.length * 10);
  }
}

class LeaderboardEntry {
  final String uid;
  final String name;
  final String? photoURL;
  final int xp;
  final int level;
  const LeaderboardEntry({
    required this.uid,
    required this.name,
    this.photoURL,
    required this.xp,
    required this.level,
  });
}

class ProgressService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? get _uid => _auth.currentUser?.uid;

  Future<Progress> load() async {
    final uid = _uid;
    if (uid == null) return Progress.empty;
    final doc = await _db.collection('users').doc(uid).get();
    final data = doc.data() ?? {};
    final raw = (data['lessonBest'] as Map?)?.cast<String, dynamic>() ?? {};
    final best =
        raw.map((k, v) => MapEntry(k, (v as num).toInt()));
    return Progress(best);
  }

  /// Records an attempt (keeps the best per lesson), updates XP and the
  /// public leaderboard. Returns the updated progress.
  Future<Progress> recordResult(String lessonId, int correct) async {
    final uid = _uid;
    if (uid == null) return Progress.empty;
    final current = await load();
    final best = Map<String, int>.from(current.best);
    if (correct > (best[lessonId] ?? 0)) best[lessonId] = correct;
    final updated = Progress(best);

    final user = _auth.currentUser;
    final name = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!.trim()
        : (user?.email?.split('@').first ?? 'Learner');
    final delta = updated.totalXp - current.totalXp; // XP newly earned now

    await _db.collection('users').doc(uid).set({
      'lessonBest': best,
      'xp': updated.totalXp,
      'level': updated.level,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Public all-time leaderboard doc — name + xp + avatar only.
    await _db.collection('leaderboard').doc(uid).set({
      'name': name,
      'photoURL': user?.photoURL,
      'xp': updated.totalXp,
      'level': updated.level,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Weekly board: accumulate XP earned within the current ISO week.
    if (delta > 0) {
      final week = _weekKey(DateTime.now());
      await _db
          .collection('leaderboard_weekly')
          .doc(week)
          .collection('users')
          .doc(uid)
          .set({
        'name': name,
        'photoURL': user?.photoURL,
        'xp': FieldValue.increment(delta),
        'level': updated.level,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    return updated;
  }

  /// ISO-8601 week key, e.g. "2026-W26".
  static String _weekKey(DateTime date) {
    final d = DateTime.utc(date.year, date.month, date.day);
    final thursday = d.add(Duration(days: 3 - ((d.weekday + 6) % 7)));
    final week1 = DateTime.utc(thursday.year, 1, 1);
    final weekNum = 1 + (thursday.difference(week1).inDays / 7).floor();
    return '${thursday.year}-W${weekNum.toString().padLeft(2, '0')}';
  }

  /// Top learners for the current week (for the home-screen strip).
  Stream<List<LeaderboardEntry>> weeklyTop({int limit = 3}) {
    final week = _weekKey(DateTime.now());
    return _db
        .collection('leaderboard_weekly')
        .doc(week)
        .collection('users')
        .orderBy('xp', descending: true)
        .limit(limit)
        .snapshots()
        .map((s) => s.docs.map((d) {
              final m = d.data();
              return LeaderboardEntry(
                uid: d.id,
                name: (m['name'] ?? 'Learner') as String,
                photoURL: m['photoURL'] as String?,
                xp: (m['xp'] as num?)?.toInt() ?? 0,
                level: (m['level'] as num?)?.toInt() ?? 1,
              );
            }).toList());
  }

  Stream<List<LeaderboardEntry>> leaderboard({int limit = 50}) {
    return _db
        .collection('leaderboard')
        .orderBy('xp', descending: true)
        .limit(limit)
        .snapshots()
        .map((s) => s.docs.map((d) {
              final m = d.data();
              return LeaderboardEntry(
                uid: d.id,
                name: (m['name'] ?? 'Learner') as String,
                photoURL: m['photoURL'] as String?,
                xp: (m['xp'] as num?)?.toInt() ?? 0,
                level: (m['level'] as num?)?.toInt() ?? 1,
              );
            }).toList());
  }
}
