import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../theme.dart';
import '../widgets/continue_button.dart';
import '../widgets/floating_card.dart';

class LessonsScreen extends StatefulWidget {
  const LessonsScreen({super.key});

  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {
  Map<String, dynamic>? _unit;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final raw = await rootBundle.loadString('assets/content/unit_001.example.json');
    if (!mounted) return;
    setState(() => _unit = json.decode(raw) as Map<String, dynamic>);
  }

  @override
  Widget build(BuildContext context) {
    final u = _unit;
    if (u == null) return const Center(child: CircularProgressIndicator());

    final vocab = u['vocabulary_spotlight'] as Map<String, dynamic>;
    final bridge = vocab['phonetic_bridge'] as Map<String, dynamic>;
    final challenges =
        (u['lineage_challenges'] as List).cast<Map<String, dynamic>>();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(u['unit_title'] as String,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 22, color: ink)),
        const SizedBox(height: 14),
        FloatingCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Vocabulary Spotlight',
                  style: TextStyle(
                      color: plantainGreen, fontWeight: FontWeight.w700, fontSize: 12)),
              const SizedBox(height: 6),
              Text(vocab['headword'] as String,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: ink)),
              Text(bridge['pronunciation'] as String,
                  style: const TextStyle(color: Colors.black54)),
              const SizedBox(height: 6),
              Text(vocab['gloss'] as String, style: const TextStyle(height: 1.4, color: ink)),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const Text('Lineage Challenges (10)',
            style: TextStyle(fontWeight: FontWeight.w800, color: ink)),
        const SizedBox(height: 10),
        for (int i = 0; i < challenges.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: FloatingCard(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: plantainGreen,
                    child: Text('${i + 1}',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(challenges[i]['prompt'] as String,
                        style: const TextStyle(height: 1.3, color: ink)),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 16),
        ContinueButton(onPressed: () {}),
        const SizedBox(height: 24),
      ],
    );
  }
}
