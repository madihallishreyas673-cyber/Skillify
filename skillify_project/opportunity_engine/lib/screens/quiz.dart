import 'package:flutter/material.dart';
import '../data.dart';
import '../state.dart';
import '../ui.dart';

class QuizScreen extends StatefulWidget {
  final Career career;
  const QuizScreen({super.key, required this.career});
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int idx = 0;
  int score = 0;
  int? picked;
  bool finished = false;

  void _restart() => setState(() {
        idx = 0;
        score = 0;
        picked = null;
        finished = false;
      });

  @override
  Widget build(BuildContext context) {
    final qs = widget.career.quiz;
    if (finished) {
      final pct = (score * 100 / qs.length).round();
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz results')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              ProgressRing(value: score / qs.length, size: 130, label: '$score/${qs.length}'),
              const SizedBox(height: 20),
              Text(pct >= 75 ? 'Great work!' : 'Good start - keep learning',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(
                  pct >= 75
                      ? 'You are building solid foundations.'
                      : 'Revisit the lessons you found hard, then retake the quiz.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: C.muted)),
              const SizedBox(height: 24),
              PrimaryButton(label: 'Done', onPressed: () => Navigator.pop(context)),
              const SizedBox(height: 10),
              GhostButton(label: 'Try again', onPressed: _restart),
            ]),
          ),
        ),
      );
    }

    final q = qs[idx];
    final answered = picked != null;
    return Scaffold(
      appBar: AppBar(title: Text('Question ${idx + 1} of ${qs.length}')),
      body: Column(children: [
        LinearProgressIndicator(
            value: (idx + 1) / qs.length, color: C.accent, backgroundColor: C.line, minHeight: 3),
        Expanded(
          child: ListView(padding: const EdgeInsets.all(16), children: [
            Text(q.q, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, height: 1.3)),
            const SizedBox(height: 18),
            for (var i = 0; i < q.options.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Builder(builder: (context) {
                  Color border = C.line;
                  Color fill = C.panel;
                  IconData? icon;
                  if (answered) {
                    if (i == q.answer) {
                      border = C.good;
                      fill = C.good.withAlpha(30);
                      icon = Icons.check_circle_rounded;
                    } else if (i == picked) {
                      border = C.bad;
                      fill = C.bad.withAlpha(30);
                      icon = Icons.cancel_rounded;
                    }
                  }
                  return Panel(
                    color: fill,
                    borderColor: border,
                    onTap: answered
                        ? null
                        : () => setState(() {
                              picked = i;
                              if (i == q.answer) score++;
                            }),
                    child: Row(children: [
                      Expanded(child: Text(q.options[i], style: const TextStyle(fontSize: 16))),
                      if (icon != null) Icon(icon, color: border),
                    ]),
                  );
                }),
              ),
            if (answered) ...[
              const SizedBox(height: 6),
              Banner2(q.why, icon: Icons.lightbulb_rounded),
            ],
          ]),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: PrimaryButton(
              label: idx == qs.length - 1 ? 'Finish' : 'Next question',
              onPressed: answered
                  ? () {
                      if (idx == qs.length - 1) {
                        appState.recordQuiz(widget.career.id, score);
                        setState(() => finished = true);
                      } else {
                        setState(() {
                          idx++;
                          picked = null;
                        });
                      }
                    }
                  : null,
            ),
          ),
        ),
      ]),
    );
  }
}
