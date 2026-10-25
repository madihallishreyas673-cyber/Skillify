import 'package:flutter/material.dart';
import 'data.dart';
import 'state.dart';

String todayKey() {
  final n = DateTime.now();
  return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
}

// ------------------------------------------------------------ Assessment ----

class MatchResult {
  final Career career;
  final int fit;
  final List<String> strengths;
  final List<String> gaps;
  MatchResult(this.career, this.fit, this.strengths, this.gaps);
}

/// Rules-based assessment: compares your skills and interests with each
/// career's required skills. It is guidance, not a guarantee.
List<MatchResult> assess(Profile p) {
  final out = <MatchResult>[];
  for (final c in careers) {
    final have = c.skills.where((s) => p.skills.contains(s)).toList();
    final gaps = c.skills.where((s) => !p.skills.contains(s)).toList();
    final skillScore = have.length / c.skills.length;
    final interestHits = c.interests.where((i) => p.interests.contains(i)).length;
    final interestScore = interestHits / c.interests.length;
    var raw = 0.5 * skillScore + 0.4 * interestScore;
    if (p.experience == experienceLevels.first && c.beginnerFriendly) raw += 0.08;
    final fit = (raw * 100).round().clamp(10, 97);
    out.add(MatchResult(c, fit, have, gaps));
  }
  out.sort((a, b) => b.fit.compareTo(a.fit));
  return out;
}

// --------------------------------------------------------------- Learning ----

class PlanLesson {
  final Lesson lesson;
  final String module;
  final int week;
  PlanLesson(this.lesson, this.module, this.week);
}

int lessonsPerWeek(Profile p) {
  const per = [1, 2, 3, 4];
  final i = hoursOptions.indexOf(p.hours);
  return i < 0 ? 2 : per[i];
}

List<PlanLesson> buildPlan(Career c, Profile p) {
  final per = lessonsPerWeek(p);
  final out = <PlanLesson>[];
  var i = 0;
  for (final m in c.modules) {
    for (final l in m.lessons) {
      out.add(PlanLesson(l, m.title, i ~/ per + 1));
      i++;
    }
  }
  return out;
}

int doneThisWeek(Map<String, String> doneAt) {
  final now = DateTime.now();
  final monday = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
  return doneAt.values.where((s) {
    final d = DateTime.tryParse(s);
    return d != null && !d.isBefore(monday);
  }).length;
}

// ------------------------------------------------------------------ Jobs ----

int jobMatch(Job j, Set<String> skills) {
  if (j.tags.isEmpty) return 0;
  final hit = j.tags.where((t) => skills.contains(t)).length;
  return (hit * 100 / j.tags.length).round();
}

int jobRelevance(Job j, UserData d) {
  final c = careerById(d.careerId);
  final u = j.tags.where((t) => d.profile.skills.contains(t)).length;
  final cs = c == null ? 0 : j.tags.where((t) => c.skills.contains(t)).length;
  return u * 2 + cs;
}

List<Job> recommendedJobs(UserData d, {int n = 3}) {
  final list = [...demoJobs];
  list.sort((a, b) => jobRelevance(b, d).compareTo(jobRelevance(a, d)));
  return list.take(n).toList();
}

// ---------------------------------------------------------- Next actions ----

class NextAction {
  final String text;
  final IconData icon;
  final int tab;
  final bool assess;
  NextAction(this.text, this.icon, {this.tab = 0, this.assess = false});
}

List<NextAction> nextActions(UserData d) {
  final out = <NextAction>[];
  final c = careerById(d.careerId);
  if (!d.assessed || c == null) {
    out.add(NextAction('Take the skill assessment', Icons.psychology_rounded, assess: true));
  } else {
    final plan = buildPlan(c, d.profile);
    PlanLesson? n;
    for (final x in plan) {
      if (!d.doneAt.containsKey(x.lesson.id)) {
        n = x;
        break;
      }
    }
    if (n != null) out.add(NextAction('Study: ${n.lesson.title}', Icons.school_rounded, tab: 1));
    if (!d.quizBest.containsKey(c.id)) {
      out.add(NextAction('Take the ${c.title} quiz', Icons.quiz_rounded, tab: 1));
    }
    if (d.projectsDone.isEmpty) {
      out.add(NextAction('Start a practice project: ${c.projects.first}', Icons.build_rounded, tab: 1));
    }
  }
  if (d.bookmarks.isEmpty) {
    out.add(NextAction('Browse opportunities and save a few', Icons.search_rounded, tab: 2));
  }
  if (d.resume.headline.trim().isEmpty || d.resume.skills.isEmpty) {
    out.add(NextAction('Complete your resume basics', Icons.description_rounded, tab: 3));
  }
  if (d.bookmarks.isNotEmpty && d.applications.isEmpty) {
    out.add(NextAction('Review your saved jobs and decide where to apply', Icons.work_rounded, tab: 2));
  }
  return out.take(4).toList();
}

// ------------------------------------------------- Offline career assistant ----

/// Offline, rules-based assistant. Uses only what you entered in the app.
/// It never applies to jobs or contacts anyone.
String localReply(String q, UserData d) {
  final t = q.toLowerCase();
  final c = careerById(d.careerId);
  bool has(List<String> words) => words.any((w) => t.contains(w));

  if (has(['interview', 'question'])) {
    final qs = c?.interviewQs ??
        [
          'Tell me about yourself.',
          'Why do you want this role?',
          'Describe a problem you solved.',
          'What are you learning right now?'
        ];
    return 'Interview practice${c == null ? '' : ' for ${c.title}'}:\n\n'
        '${qs.asMap().entries.map((e) => '${e.key + 1}. ${e.value}').join('\n')}\n\n'
        'How to answer: use the STAR method - Situation, Task, Action, Result. Use real examples from your own projects and learning. '
        'If you do not have work experience yet, talk about practice projects and what you learned. Never claim experience you do not have.';
  }

  if (has(['next', 'what should', 'start', 'where do i'])) {
    if (c == null) {
      return 'Your best next step is the skill assessment (Home tab). It takes about 3 minutes and gives you a realistic career path and a learning plan.';
    }
    final plan = buildPlan(c, d.profile);
    for (final x in plan) {
      if (!d.doneAt.containsKey(x.lesson.id)) {
        return 'Your next step on the ${c.title} path:\n\nStudy "${x.lesson.title}" (${x.lesson.resource}).\nThen practise: ${x.lesson.practice}\n\nMark it complete in the Learn tab when you are done.';
      }
    }
    return 'You finished every lesson in your starter plan. Next: build 2-3 portfolio projects, then save and apply to opportunities in the Jobs tab. You decide where to apply.';
  }

  if (has(['project', 'portfolio'])) {
    final ps = c?.projects ?? ['Pick a career path first (Home tab) to get tailored project ideas.'];
    return 'Project ideas${c == null ? '' : ' for ${c.title}'}:\n\n${ps.map((e) => '- $e').join('\n')}\n\n'
        'Finish each one, write 3-4 honest lines about what you did and learned, then add it in Resume > Portfolio.';
  }

  if (has(['apply', 'application', 'how do i get'])) {
    return 'How to apply:\n\n'
        '1. Read the full listing and requirements.\n'
        '2. Update your resume and tailor the cover letter (Resume tab) using only true information.\n'
        '3. Open the official application page from the job details screen.\n'
        '4. Submit it yourself, then mark it as Applied so you can track it.\n\n'
        'I never submit applications or contact employers for you - you stay in control. Never pay money to apply for a job.';
  }

  if (has(['resume', 'cv', 'cover letter'])) {
    return 'Resume tips:\n\n'
        '- Keep it to one page and put your strongest, truest points first.\n'
        '- List real projects with a link and one line about the result.\n'
        '- Match your skills to the listing, but only list skills you truly have.\n'
        '- Use the Resume tab to edit and export a PDF.';
  }

  if (has(['gap', 'skills', 'improve', 'learn'])) {
    if (c == null) return 'Take the skill assessment (Home tab) and I can show your strengths and skill gaps.';
    final gaps = c.skills.where((s) => !d.profile.skills.contains(s)).toList();
    final have = c.skills.where((s) => d.profile.skills.contains(s)).toList();
    return 'For ${c.title}:\n\nStrengths: ${have.isEmpty ? 'none selected yet - that is fine, everyone starts somewhere' : have.join(', ')}\n'
        'Skills to build: ${gaps.isEmpty ? 'none - great!' : gaps.join(', ')}\n\nYour learning plan in the Learn tab covers these step by step.';
  }

  if (has(['money', 'income', 'salary', 'earn', 'pay'])) {
    return c == null
        ? 'Take the skill assessment first so I can suggest realistic ways to start earning.'
        : '${c.firstIncome}\n\nIncome varies a lot by country, client and experience, so I cannot promise numbers. Only trust salary figures that are listed by the employer on a real listing.';
  }

  if (has(['degree', 'no experience', 'beginner', 'fresher', 'without'])) {
    return c == null
        ? 'You can start without a degree or experience. Take the skill assessment and I will suggest a beginner-friendly path.'
        : c.beginnerPath;
  }

  return 'I can help with:\n\n'
      '- What to do next on your path\n- Interview practice\n- Project ideas for your portfolio\n- How to apply safely\n- Resume and cover letter tips\n- Your skill gaps\n\n'
      'Tap a suggestion below or ask me in your own words. For smarter AI answers, connect your own secure server in Profile > Cloud AI.';
}
