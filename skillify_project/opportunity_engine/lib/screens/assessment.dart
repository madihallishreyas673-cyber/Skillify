import 'package:flutter/material.dart';
import '../data.dart';
import '../engine.dart';
import '../state.dart';
import '../ui.dart';

void openAssessment(BuildContext context) {
  Navigator.push(context, MaterialPageRoute(builder: (_) => const AssessmentScreen()));
}

class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({super.key});
  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  late Profile p;
  int step = 0; // 0-5 questions, 6 = results
  bool analysing = false;
  List<MatchResult> results = [];

  static const _steps = 6;

  @override
  void initState() {
    super.initState();
    final o = appState.data.profile;
    p = Profile(
      education: o.education,
      experience: o.experience,
      goal: o.goal,
      hours: o.hours.isEmpty ? hoursOptions[1] : o.hours,
      interests: {...o.interests},
      skills: {...o.skills},
    );
  }

  bool get _valid {
    switch (step) {
      case 0:
        return p.education.isNotEmpty;
      case 1:
        return p.experience.isNotEmpty;
      case 2:
        return p.interests.isNotEmpty;
      case 3:
        return true;
      case 4:
        return p.hours.isNotEmpty;
      case 5:
        return p.goal.isNotEmpty;
    }
    return false;
  }

  Future<void> _next() async {
    if (step < _steps - 1) {
      setState(() => step++);
      return;
    }
    setState(() => analysing = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() {
      results = assess(p);
      analysing = false;
      step = _steps;
    });
  }

  Widget _single(List<String> opts, String value, void Function(String) set) => Column(
        children: opts.map((o) {
          final sel = o == value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Panel(
              onTap: () => setState(() => set(o)),
              color: sel ? C.accent.withAlpha(36) : C.panel,
              borderColor: sel ? C.accent : C.line,
              child: Row(children: [
                Expanded(child: Text(o, style: const TextStyle(fontSize: 16))),
                Icon(sel ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                    color: sel ? C.accent : C.muted),
              ]),
            ),
          );
        }).toList(),
      );

  Widget _multi(List<String> opts, Set<String> sel) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: opts
            .map((o) => FilterChip(
                  label: Text(o),
                  selected: sel.contains(o),
                  onSelected: (v) => setState(() => v ? sel.add(o) : sel.remove(o)),
                  selectedColor: C.accent.withAlpha(80),
                  checkmarkColor: Colors.white,
                  backgroundColor: C.surface,
                  side: const BorderSide(color: C.line),
                  labelStyle: const TextStyle(color: C.text),
                ))
            .toList(),
      );

  (String, String, Widget) _question() {
    switch (step) {
      case 0:
        return ('What is your education?', 'Choose the closest one. There are no wrong answers.',
            _single(educationLevels, p.education, (v) => p.education = v));
      case 1:
        return ('How much experience do you have?', 'Projects and volunteering count too.',
            _single(experienceLevels, p.experience, (v) => p.experience = v));
      case 2:
        return ('What are you interested in?', 'Pick everything that excites you.',
            _multi(interestOptions, p.interests));
      case 3:
        return ('Which skills do you already have?',
            'Select only skills you really have. It is fine to select none.',
            _multi(allSkills, p.skills));
      case 4:
        return ('How much time can you learn each week?', 'Be realistic - consistency beats intensity.',
            _single(hoursOptions, p.hours, (v) => p.hours = v));
      default:
        return ('What is your main goal?', 'This helps shape your plan.',
            _single(goalOptions, p.goal, (v) => p.goal = v));
    }
  }

  Widget _results() {
    final top = results.take(3).toList();
    return ListView(padding: const EdgeInsets.all(16), children: [
      const Text('Your results',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
      const SizedBox(height: 4),
      const Text('Top career paths for you right now. Choose one to get your learning plan.',
          style: TextStyle(color: C.muted)),
      const SizedBox(height: 14),
      ...top.asMap().entries.map((e) {
        final r = e.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Panel(
            borderColor: e.key == 0 ? C.accent : C.line,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(r.career.icon, color: C.accent),
                const SizedBox(width: 10),
                Expanded(
                    child: Text(r.career.title,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
                Pill('Fit ${r.fit}%'),
              ]),
              if (e.key == 0) ...[
                const SizedBox(height: 6),
                const Pill('Best match', color: C.good, icon: Icons.star_rounded),
              ],
              const SizedBox(height: 8),
              Text(r.career.summary, style: const TextStyle(color: C.muted, height: 1.4)),
              const SizedBox(height: 10),
              const Text('Your strengths', style: TextStyle(color: C.muted, fontSize: 12)),
              const SizedBox(height: 4),
              Wrap(spacing: 6, runSpacing: 6, children: [
                if (r.strengths.isEmpty)
                  const Text('None yet - you can start from zero.')
                else
                  ...r.strengths.map((s) => Pill(s, color: C.good)),
              ]),
              const SizedBox(height: 10),
              const Text('Skills to build', style: TextStyle(color: C.muted, fontSize: 12)),
              const SizedBox(height: 4),
              Wrap(spacing: 6, runSpacing: 6,
                  children: r.gaps.map((s) => Pill(s, color: C.warn)).toList()),
              const SizedBox(height: 12),
              const Text('Starting without a degree or experience',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(r.career.beginnerPath, style: const TextStyle(color: C.muted, height: 1.4)),
              const SizedBox(height: 14),
              PrimaryButton(
                label: 'Start this path',
                icon: Icons.rocket_launch_rounded,
                onPressed: () {
                  appState.finishAssessment(p, r.career.id);
                  Navigator.pop(context);
                  toast(context, 'Your ${r.career.title} learning plan is ready. Open the Learn tab.');
                },
              ),
            ]),
          ),
        );
      }),
      const Banner2(
          'Fit scores come from a rules-based comparison of your answers with typical skills for each path. They are guidance, not a guarantee of any job or income.'),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    if (analysing) {
      return Scaffold(
        appBar: AppBar(title: const Text('Skill assessment')),
        body: const Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            CircularProgressIndicator(color: C.accent),
            SizedBox(height: 18),
            Text('Analysing your answers...', style: TextStyle(color: C.muted)),
          ]),
        ),
      );
    }
    if (step >= _steps) {
      return Scaffold(
        appBar: AppBar(title: const Text('Skill assessment')),
        body: _results(),
      );
    }
    final (title, sub, body) = _question();
    return Scaffold(
      appBar: AppBar(title: Text('Question ${step + 1} of $_steps')),
      body: Column(children: [
        LinearProgressIndicator(
            value: (step + 1) / _steps, color: C.accent, backgroundColor: C.line, minHeight: 3),
        Expanded(
          child: ListView(padding: const EdgeInsets.all(16), children: [
            Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(sub, style: const TextStyle(color: C.muted)),
            const SizedBox(height: 18),
            body,
          ]),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(children: [
              if (step > 0) ...[
                GhostButton(label: 'Back', onPressed: () => setState(() => step--)),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: PrimaryButton(
                  label: step == _steps - 1 ? 'See my results' : 'Next',
                  onPressed: _valid ? _next : null,
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}
