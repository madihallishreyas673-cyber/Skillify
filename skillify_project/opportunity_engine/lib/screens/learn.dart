import 'package:flutter/material.dart';
import '../data.dart';
import '../engine.dart';
import '../state.dart';
import '../ui.dart';
import 'assessment.dart';
import 'quiz.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  Widget _noPlan(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.school_rounded, size: 64, color: C.accent),
            const SizedBox(height: 16),
            const Text('No learning plan yet',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            const Text(
                'Take the skill assessment and Skillify will build a step-by-step plan with free resources, tasks, quizzes and projects.',
                textAlign: TextAlign.center,
                style: TextStyle(color: C.muted, height: 1.4)),
            const SizedBox(height: 20),
            PrimaryButton(
                label: 'Start skill assessment',
                icon: Icons.psychology_rounded,
                onPressed: () => openAssessment(context)),
          ]),
        ),
      );

  Widget _lessonRow(BuildContext context, PlanLesson x, bool done) {
    return Panel(
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            icon: Icon(done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                color: done ? C.good : C.muted),
            onPressed: () => appState.toggleLesson(x.lesson.id),
          ),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(x.lesson.title,
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      decoration: done ? TextDecoration.lineThrough : null,
                      color: done ? C.muted : C.text)),
              Text('Week ${x.week} - ${x.lesson.resource}',
                  style: const TextStyle(color: C.muted, fontSize: 12)),
            ]),
          ),
          if (x.lesson.url.isNotEmpty)
            IconButton(
              tooltip: 'Open free resource',
              icon: const Icon(Icons.open_in_new_rounded, color: C.accent),
              onPressed: () => openLink(context, x.lesson.url),
            ),
        ]),
        Padding(
          padding: const EdgeInsets.only(left: 8, top: 4),
          child: Text('Practice: ${x.lesson.practice}',
              style: const TextStyle(color: C.muted, fontSize: 13, height: 1.35)),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final d = appState.data;
        final c = careerById(d.careerId);
        if (c == null) return _noPlan(context);
        final plan = buildPlan(c, d.profile);
        final doneCount = plan.where((x) => d.doneAt.containsKey(x.lesson.id)).length;
        PlanLesson? n;
        for (final x in plan) {
          if (!d.doneAt.containsKey(x.lesson.id)) {
            n = x;
            break;
          }
        }
        final PlanLesson? nx = n;
        final totalWeeks = plan.last.week;
        final curWeek = nx?.week ?? totalWeeks;
        final weekItems = plan.where((x) => x.week == curWeek).toList();
        final weekById = {for (final x in plan) x.lesson.id: x.week};
        final today = todayKey();
        final best = d.quizBest[c.id];

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Panel(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Icon(c.icon, color: C.accent),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Text(c.title,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
                ]),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                    value: doneCount / plan.length,
                    color: C.accent,
                    backgroundColor: C.line,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(8)),
                const SizedBox(height: 8),
                Text(
                    '$doneCount of ${plan.length} lessons done - week $curWeek of $totalWeeks (${lessonsPerWeek(d.profile)} lesson${lessonsPerWeek(d.profile) == 1 ? '' : 's'} per week)',
                    style: const TextStyle(color: C.muted, fontSize: 13)),
                const SizedBox(height: 6),
                const Text(
                    'This is a starter roadmap. Keep going with the linked free courses after you finish it.',
                    style: TextStyle(color: C.muted, fontSize: 12)),
              ]),
            ),

            // Daily tasks
            const SectionTitle('Today\'s tasks'),
            if (nx == null)
              const Banner2('You finished your starter plan. Build portfolio projects and start applying!',
                  icon: Icons.celebration_rounded)
            else
              Panel(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                child: Column(children: [
                  for (final t in [
                    MapEntry('$today|${nx.lesson.id}|study',
                        'Study (about 45 min): ${nx.lesson.title}'),
                    MapEntry('$today|${nx.lesson.id}|practice', 'Practise: ${nx.lesson.practice}'),
                    MapEntry('$today|${nx.lesson.id}|note',
                        'Write 3 lines on what you learned and what is still unclear'),
                  ])
                    CheckboxListTile(
                      value: d.tasksDone.contains(t.key),
                      onChanged: (_) => appState.toggleTask(t.key),
                      activeColor: C.accent,
                      checkColor: Colors.black,
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      title: Text(t.value, style: const TextStyle(fontSize: 14, height: 1.3)),
                    ),
                ]),
              ),

            // Weekly tasks
            SectionTitle('This week (week $curWeek)'),
            ...weekItems.map((x) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _lessonRow(context, x, d.doneAt.containsKey(x.lesson.id)),
                )),

            // Quiz
            const SectionTitle('Quiz'),
            Panel(
              child: Row(children: [
                const Icon(Icons.quiz_rounded, color: C.accent),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${c.title} quiz',
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text(best == null ? '${c.quiz.length} questions' : 'Best score: $best / ${c.quiz.length}',
                        style: const TextStyle(color: C.muted, fontSize: 13)),
                  ]),
                ),
                GhostButton(
                    label: best == null ? 'Start' : 'Retake',
                    onPressed: () => Navigator.push(
                        context, MaterialPageRoute(builder: (_) => QuizScreen(career: c)))),
              ]),
            ),

            // Roadmap
            const SectionTitle('Full roadmap'),
            ...c.modules.map((m) {
              final doneInModule = m.lessons.where((l) => d.doneAt.containsKey(l.id)).length;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: Container(
                    decoration: BoxDecoration(
                      color: C.panel,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: C.line),
                    ),
                    child: ExpansionTile(
                      shape: const Border(),
                      collapsedShape: const Border(),
                      iconColor: C.accent,
                      collapsedIconColor: C.muted,
                      title: Text(m.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text('${m.goal}  ($doneInModule/${m.lessons.length})',
                          style: const TextStyle(color: C.muted, fontSize: 12)),
                      childrenPadding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                      children: m.lessons
                          .map((l) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: _lessonRow(
                                    context,
                                    PlanLesson(l, m.title, weekById[l.id] ?? 1),
                                    d.doneAt.containsKey(l.id)),
                              ))
                          .toList(),
                    ),
                  ),
                ),
              );
            }),

            // Projects
            const SectionTitle('Practice projects'),
            Panel(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              child: Column(children: [
                for (var i = 0; i < c.projects.length; i++)
                  CheckboxListTile(
                    value: d.projectsDone.contains('${c.id}|$i'),
                    onChanged: (_) => appState.toggleProject('${c.id}|$i'),
                    activeColor: C.accent,
                    checkColor: Colors.black,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    title: Text(c.projects[i], style: const TextStyle(fontSize: 14)),
                  ),
              ]),
            ),
            const SizedBox(height: 16),
            GhostButton(
                label: 'Change path / retake assessment',
                icon: Icons.refresh_rounded,
                onPressed: () => openAssessment(context)),
          ],
        );
      },
    );
  }
}
