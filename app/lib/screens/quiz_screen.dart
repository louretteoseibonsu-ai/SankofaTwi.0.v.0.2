import 'package:flutter/material.dart';
import '../data/quiz_questions.dart';
import '../theme.dart';
import '../widgets/continue_button.dart';
import '../widgets/floating_card.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _index = 0;
  int _score = 0;
  String? _selected;
  bool _finished = false;

  void _answer(String option) {
    if (_selected != null) return;
    setState(() {
      _selected = option;
      if (option == kQuizQuestions[_index].answer) _score++;
    });
  }

  void _next() {
    if (_index < kQuizQuestions.length - 1) {
      setState(() {
        _index++;
        _selected = null;
      });
    } else {
      setState(() => _finished = true);
    }
  }

  void _restart() {
    setState(() {
      _index = 0;
      _score = 0;
      _selected = null;
      _finished = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$_score / ${kQuizQuestions.length}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 44, color: plantainDeep)),
              const SizedBox(height: 8),
              const Text('Yɛ wo adɛn! (Well done!)',
                  style: TextStyle(fontSize: 16, color: ink)),
              const SizedBox(height: 20),
              FilledButton(onPressed: _restart, child: const Text('Try again')),
            ],
          ),
        ),
      );
    }

    final q = kQuizQuestions[_index];
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Quiz · ${q.category}',
                style: const TextStyle(
                    color: plantainGreen, fontWeight: FontWeight.w700, fontSize: 12)),
            Text('${_index + 1} / ${kQuizQuestions.length}',
                style: const TextStyle(color: Colors.black54, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 8),
        Text(q.question,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: ink)),
        const SizedBox(height: 16),
        ...q.options.map((opt) {
          Color border = Colors.black12;
          Color bg = Colors.white;
          if (_selected != null) {
            if (opt == q.answer) {
              border = plantainGreen;
              bg = const Color(0xFFEFF7F1);
            } else if (opt == _selected) {
              border = accentCoral;
              bg = const Color(0xFFFBEEEA);
            }
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: bg,
              borderRadius: BorderRadius.circular(24),
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: _selected == null ? () => _answer(opt) : null,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: border, width: 1.5),
                  ),
                  child: Text(opt,
                      style: const TextStyle(fontWeight: FontWeight.w600, color: ink)),
                ),
              ),
            ),
          );
        }),
        if (_selected != null) ...[
          const SizedBox(height: 8),
          FloatingCard(
            child: Text(q.explanation, style: const TextStyle(height: 1.4, color: ink)),
          ),
          const SizedBox(height: 16),
          ContinueButton(onPressed: _next),
        ],
        const SizedBox(height: 24),
      ],
    );
  }
}
