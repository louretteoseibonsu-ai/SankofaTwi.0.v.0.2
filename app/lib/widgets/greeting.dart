import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../data/akan_day_names.dart';

/// Time-aware Akan greeting.
String akanGreeting() {
  final h = DateTime.now().hour;
  if (h < 12) return 'Maakye'; // good morning
  if (h < 17) return 'Maaha'; // good afternoon
  return 'Maadwo'; // good evening
}

/// The user's first name (falls back to the email handle, then "friend").
String firstNameOf(User? u) {
  final dn = u?.displayName?.trim();
  if (dn != null && dn.isNotEmpty) return dn.split(' ').first;
  final email = u?.email;
  if (email != null && email.contains('@')) return email.split('@').first;
  return 'friend';
}

/// The Akan day-name (kra din) for a date of birth. [female] chooses the
/// female name (e.g. Ama), otherwise the male name (e.g. Kwame).
/// Dart weekday: Mon=1..Sun=7; the Akan table is Sun=0..Sat=6 → weekday % 7.
String? akanDayNameFor(DateTime? dob, {required bool female}) {
  if (dob == null) return null;
  final d = kAkanDayNames[dob.weekday % 7];
  return female ? d.femaleName : d.maleName;
}

/// "Maakye, Ama Kwabena" — a personalised, time-aware greeting. Appends the
/// user's Akan day-name (kra din) once their date of birth is known.
class GreetingTitle extends StatefulWidget {
  final double fontSize;
  const GreetingTitle({super.key, this.fontSize = 20});

  @override
  State<GreetingTitle> createState() => _GreetingTitleState();
}

class _GreetingTitleState extends State<GreetingTitle> {
  String? _dayName;

  @override
  void initState() {
    super.initState();
    _loadDayName();
  }

  Future<void> _loadDayName() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = doc.data() ?? {};
      final dobStr = data['dob'] as String?;
      final gender = (data['gender'] as String?) ?? '';
      if (dobStr == null) return;
      final name =
          akanDayNameFor(DateTime.tryParse(dobStr), female: gender == 'Woman');
      if (mounted && name != null) setState(() => _dayName = name);
    } catch (_) {
      // No day-name if the profile isn't reachable — greeting still works.
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snap) {
        final u = snap.data ?? FirebaseAuth.instance.currentUser;
        final first = firstNameOf(u);
        // Don't repeat the day-name if the display name already is it
        // (e.g. someone whose name is "Akua" born on Wednesday → not "Akua Akua").
        final showDay =
            _dayName != null && _dayName!.toLowerCase() != first.toLowerCase();
        final label = showDay
            ? '${akanGreeting()}, $first $_dayName'
            : '${akanGreeting()}, $first';
        return Text(
          label,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: widget.fontSize,
            color: Colors.white,
            shadows: const [
              Shadow(
                  color: Color(0x99000000),
                  blurRadius: 4,
                  offset: Offset(0, 1)),
            ],
          ),
        );
      },
    );
  }
}
