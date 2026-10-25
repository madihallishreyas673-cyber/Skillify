import 'package:flutter/material.dart';
import '../data.dart';
import '../engine.dart';
import '../state.dart';
import '../ui.dart';
import 'assessment.dart';
import 'jobs.dart';

class DashboardScreen extends StatelessWidget {
  final void Function(int) onGo;
  const DashboardScreen({super.key, required this.onGo});

  Widget _stat(String label, String value, IconData icon) => Expanded(
        child: Panel(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
          child: Column(children: [
            Icon(icon, color: C.accent, size: 22),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(color: C.muted, fontSize: 12)),
          ]),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final d = appState.data;
        final career = careerById(d.careerId);
        final first = (appState.name ?? '').trim().split(' ').first;

        var pct = 0.0;
        var doneCount = 0;
        var total = 0;
        if (career != null) {
          final plan = buildPlan(career, d.profile);
          total = plan.length;
          doneCount = plan.where((x) => d.doneAt.containsKey(x.lesson.id)).length;
          pct = total == 0 ? 0 : doneCount / total;
        }
        final goal = lessonsPerWeek(d.profile);
        final weekDone = doneThisWeek(d.doneAt);
        final statusCounts = <String, int>{};
        for (final s in d.applications.values) {
          statusCounts[s] = (statusCounts[s] ?? 0) + 1;
        }
        final projectsDone = d.projectsDone.length;
        final actions = nextActions(d);
        final recs = recommendedJobs(d);

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Text('Hi${first.isEmpty ? '' : ', $first'}',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
            const Text(kTagline, style: TextStyle(color: C.accent)),
            const SizedBox(height: 16),

            // Assessment results
            if (career == null)
              Panel(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Find your best path',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  const Text(
                      'Take the 3-minute skill assessment to see your strengths, skill gaps and realistic career options - no degree or experience needed.',
                      style: TextStyle(color: C.muted, height: 1.4)),
                  const SizedBox(height: 14),
                  PrimaryButton(
                    label: 'Start skill assessment',
                    icon: Icons.psychology_rounded,
                    onPressed: () => openAssessment(context),
                  ),
                ]),
              )
            else
              Builder(builder: (context) {
                final res = assess(d.profile).firstWhere((m) => m.career.id == career.id);
                return Panel(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Icon(career.icon, color: C.accent),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Text(career.title,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
                      Pill('Fit ${res.fit}%'),
                    ]),
                    const SizedBox(height: 10),
                    const Text('Strengths', style: TextStyle(color: C.muted, fontSize: 12)),
                    const SizedBox(height: 4),
                    Wrap(spacing: 6, runSpacing: 6, children: [
                      if (res.strengths.isEmpty)
                        const Text('Starting fresh - that is fine!',
                            style: TextStyle(color: C.text))
                      else
                        ...res.strengths.take(4).map((s) => Pill(s, color: C.good)),
                    ]),
                    const SizedBox(height: 10),
                    const Text('Skills to build', style: TextStyle(color: C.muted, fontSize: 12)),
                    const SizedBox(height: 4),
                    Wrap(spacing: 6, runSpacing: 6,
                        children: res.gaps.take(4).map((s) => Pill(s, color: C.warn)).toList()),
                    const SizedBox(height: 12),
                    GhostButton(
                        label: 'View or retake assessment',
                        icon: Icons.refresh_rounded,
                        onPressed: () => openAssessment(context)),
                  ]),
                );
              }),

            // Progress + weekly goal
            const SectionTitle('Your progress'),
            Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Expanded(
                child: Panel(
                  child: Column(children: [
                    ProgressRing(value: pct, label: '${(pct * 100).round()}%'),
                    const SizedBox(height: 8),
                    Text(career == null ? 'No plan yet' : '$doneCount of $total lessons',
                        style: const TextStyle(color: C.muted, fontSize: 13)),
                  ]),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Panel(
                  child: Column(children: [
                    ProgressRing(
                        value: goal == 0 ? 0 : weekDone / goal,
                        label: '$weekDone/$goal'),
                    const SizedBox(height: 8),
                    const Text('Weekly goal (lessons)',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: C.muted, fontSize: 13)),
                  ]),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              _stat('Saved jobs', '${d.bookmarks.length}', Icons.bookmark_rounded),
              const SizedBox(width: 10),
              _stat('Applications', '${d.applications.length}', Icons.send_rounded),
              const SizedBox(width: 10),
              _stat('Projects done', '$projectsDone', Icons.build_rounded),
            ]),
            if (statusCounts.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (final s in appStatuses)
                  if (statusCounts.containsKey(s)) Pill('$s: ${statusCounts[s]}'),
              ]),
            ],

            // Next actions
            const SectionTitle('Recommended next actions'),
            ...actions.map((a) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Panel(
                    onTap: () => a.assess ? openAssessment(context) : onGo(a.tab),
                    child: Row(children: [
                      Icon(a.icon, color: C.accent),
                      const SizedBox(width: 12),
                      Expanded(child: Text(a.text, style: const TextStyle(fontWeight: FontWeight.w600))),
                      const Icon(Icons.chevron_right_rounded, color: C.muted),
                    ]),
                  ),
                )),

            // Recommended opportunities
            SectionTitle('Recommended opportunities',
                trailing: TextButton(
                    onPressed: () => onGo(2),
                    child: const Text('See all', style: TextStyle(color: C.accent)))),
            const Banner2('These are sample listings (demo data). Open the Jobs tab to load live remote jobs.'),
            const SizedBox(height: 10),
            ...recs.map((j) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Panel(
                    onTap: () => Navigator.push(
                        context, MaterialPageRoute(builder: (_) => JobDetailScreen(job: j))),
                    child: Row(children: [
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(j.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 6),
                          Wrap(spacing: 6, runSpacing: 6, children: [
                            Pill(j.type),
                            const Pill('DEMO DATA', color: C.warn),
                          ]),
                        ]),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: C.muted),
                    ]),
                  ),
                )),
          ],
        );
      },
    );
  }
}
