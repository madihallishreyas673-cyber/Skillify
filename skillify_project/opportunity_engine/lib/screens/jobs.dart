import 'package:flutter/material.dart';
import '../api.dart';
import '../data.dart';
import '../engine.dart';
import '../state.dart';
import '../ui.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});
  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  final _search = TextEditingController();
  String _mode = 'Explore'; // Explore | Saved | Tracker
  String _type = 'All';
  List<Job> _live = [];
  bool _loading = false;
  String? _error;
  bool _fetched = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _fetchLive() async {
    FocusScope.of(context).unfocus();
    final typed = _search.text.trim();
    final term = typed.isNotEmpty
        ? typed
        : (careerById(appState.data.careerId)?.searchTerms.first ?? 'junior developer');
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final r = await fetchLiveJobs(term);
      if (!mounted) return;
      setState(() {
        _live = r;
        _loading = false;
        _fetched = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error =
            'Could not load live jobs. Check your internet connection and try again. Demo listings are still available.';
      });
    }
  }

  bool _matches(Job j) {
    if (_type != 'All' && j.type != _type) return false;
    final q = _search.text.trim().toLowerCase();
    if (q.isEmpty) return true;
    return j.title.toLowerCase().contains(q) ||
        j.company.toLowerCase().contains(q) ||
        j.tags.any((t) => t.toLowerCase().contains(q));
  }

  Widget _card(BuildContext context, Job j, UserData d) {
    final m = jobMatch(j, d.profile.skills);
    final saved = d.bookmarks.contains(j.id);
    final status = d.applications[j.id];
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Panel(
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => JobDetailScreen(job: j))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
                child: Text(j.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800))),
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              icon: Icon(saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                  color: saved ? C.accent : C.muted),
              onPressed: () => appState.toggleBookmark(j),
            ),
          ]),
          Text('${j.company}${j.location.isEmpty ? '' : ' - ${j.location}'}',
              style: const TextStyle(color: C.muted)),
          const SizedBox(height: 8),
          Wrap(spacing: 6, runSpacing: 6, children: [
            Pill(j.type),
            j.demo ? const Pill('DEMO DATA', color: C.warn) : Pill('LIVE - ${j.source}', color: C.good),
            if (m > 0) Pill('Skill match $m%', color: C.good),
            if (status != null) Pill(status, color: C.accent2),
          ]),
        ]),
      ),
    );
  }

  Widget _empty(String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
            child: Text(text, textAlign: TextAlign.center, style: const TextStyle(color: C.muted))),
      );

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final d = appState.data;
        final children = <Widget>[];

        children.add(Row(children: [
          for (final m in ['Explore', 'Saved', 'Tracker'])
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(m == 'Saved' ? 'Saved (${d.bookmarks.length})' : m),
                selected: _mode == m,
                onSelected: (_) => setState(() => _mode = m),
                selectedColor: C.accent.withAlpha(90),
                backgroundColor: C.surface,
                side: const BorderSide(color: C.line),
                labelStyle: const TextStyle(color: C.text),
              ),
            ),
        ]));
        children.add(const SizedBox(height: 12));

        if (_mode == 'Explore') {
          children.add(TextField(
            controller: _search,
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => setState(() {}),
            decoration: inputDeco('Search title, company or skill', icon: Icons.search_rounded),
          ));
          children.add(const SizedBox(height: 10));
          children.add(SizedBox(
            height: 40,
            child: ListView(scrollDirection: Axis.horizontal, children: [
              for (final t in jobTypes)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(t),
                    selected: _type == t,
                    onSelected: (_) => setState(() => _type = t),
                    selectedColor: C.accent.withAlpha(90),
                    backgroundColor: C.surface,
                    side: const BorderSide(color: C.line),
                    labelStyle: const TextStyle(color: C.text),
                  ),
                ),
            ]),
          ));
          children.add(const SizedBox(height: 10));
          children.add(PrimaryButton(
            label: _fetched ? 'Refresh live remote jobs' : 'Find live remote jobs',
            icon: Icons.public_rounded,
            loading: _loading,
            onPressed: _fetchLive,
          ));
          if (_error != null) {
            children.add(const SizedBox(height: 10));
            children.add(Banner2(_error!, error: true));
          }
          children.add(const SizedBox(height: 10));
          children.add(const Banner2(
              'Live jobs come from the public Remotive job board. "DEMO DATA" listings are samples that show how the app works - they are not real openings.'));
          children.add(const SizedBox(height: 14));

          final live = _live.where(_matches).toList();
          final demo = demoJobs.where(_matches).toList();
          int rel(Job a) => jobMatch(a, d.profile.skills);
          live.sort((a, b) => rel(b).compareTo(rel(a)));
          demo.sort((a, b) => jobRelevance(b, d).compareTo(jobRelevance(a, d)));
          if (live.isEmpty && demo.isEmpty) {
            children.add(_empty('No opportunities match your search or filter.'));
          }
          for (final j in [...live, ...demo]) {
            children.add(_card(context, j, d));
          }
        } else if (_mode == 'Saved') {
          final saved = d.bookmarks.map(appState.jobById).whereType<Job>().toList();
          if (saved.isEmpty) children.add(_empty('No saved opportunities yet.\nTap the bookmark on any listing.'));
          for (final j in saved) {
            children.add(_card(context, j, d));
          }
        } else {
          final any = d.applications.isNotEmpty;
          if (!any) {
            children.add(_empty(
                'No applications tracked yet.\nOpen a listing and set its status after you apply yourself.'));
          }
          for (final s in appStatuses) {
            final ids = d.applications.entries.where((e) => e.value == s).map((e) => e.key);
            final jobs = ids.map(appState.jobById).whereType<Job>().toList();
            if (jobs.isEmpty) continue;
            children.add(SectionTitle('$s (${jobs.length})'));
            for (final j in jobs) {
              children.add(_card(context, j, d));
            }
          }
        }

        return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: children);
      },
    );
  }
}

class JobDetailScreen extends StatelessWidget {
  final Job job;
  const JobDetailScreen({super.key, required this.job});

  Future<void> _apply(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: C.panel,
        title: const Text('Open application page?'),
        content: const Text(
            'This opens the job page in your browser. Nothing is submitted for you - you decide whether and how to apply.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Open page')),
        ],
      ),
    );
    if (ok == true && context.mounted) openLink(context, job.url!);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final d = appState.data;
        final saved = d.bookmarks.contains(job.id);
        final status = d.applications[job.id];
        final m = jobMatch(job, d.profile.skills);
        return Scaffold(
          appBar: AppBar(
            title: const Text('Opportunity'),
            actions: [
              IconButton(
                icon: Icon(saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                    color: saved ? C.accent : C.text),
                onPressed: () => appState.toggleBookmark(job),
              ),
            ],
          ),
          body: ListView(padding: const EdgeInsets.all(16), children: [
            Text(job.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('${job.company}${job.location.isEmpty ? '' : ' - ${job.location}'}',
                style: const TextStyle(color: C.muted, fontSize: 16)),
            const SizedBox(height: 10),
            Wrap(spacing: 6, runSpacing: 6, children: [
              Pill(job.type),
              job.demo
                  ? const Pill('DEMO DATA', color: C.warn)
                  : Pill('LIVE - ${job.source}', color: C.good),
              if (m > 0) Pill('Skill match $m%', color: C.good),
            ]),
            const SizedBox(height: 14),
            if (job.demo)
              const Banner2(
                  'This is sample data created to show how the app works. It is not a real job opening and has no application link.',
                  icon: Icons.warning_amber_rounded),
            const SectionTitle('Salary'),
            Text(
                job.salary != null
                    ? '${job.salary} (as listed by the employer - check the original listing)'
                    : 'Not listed or not verified.',
                style: const TextStyle(color: C.muted)),
            if (job.requirements.isNotEmpty) ...[
              const SectionTitle('Requirements'),
              ...job.requirements.map((r) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Icon(Icons.check_rounded, size: 18, color: C.accent),
                      const SizedBox(width: 8),
                      Expanded(child: Text(r, style: const TextStyle(height: 1.35))),
                    ]),
                  )),
            ],
            if (job.tags.isNotEmpty) ...[
              const SectionTitle('Skills in this listing'),
              Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: job.tags
                      .map((t) => d.profile.skills.contains(t)
                          ? Pill('$t - you have this', color: C.good)
                          : Pill(t, color: C.muted))
                      .toList()),
            ],
            const SectionTitle('About this listing'),
            Text(job.description, style: const TextStyle(color: C.muted, height: 1.45)),
            if (!job.demo) ...[
              const SizedBox(height: 8),
              Text('Source: ${job.source}', style: const TextStyle(color: C.muted, fontSize: 12)),
            ],
            const SizedBox(height: 18),
            if (job.url != null)
              PrimaryButton(
                label: 'Open application page',
                icon: Icons.open_in_new_rounded,
                onPressed: () => _apply(context),
              ),
            const SectionTitle('Track your application'),
            const Text('Update this yourself after you apply. Skillify never applies on your behalf.',
                style: TextStyle(color: C.muted, fontSize: 13)),
            const SizedBox(height: 10),
            Wrap(spacing: 8, runSpacing: 8, children: [
              ChoiceChip(
                label: const Text('Not applied'),
                selected: status == null,
                onSelected: (_) => appState.setApplication(job, null),
                selectedColor: C.accent.withAlpha(90),
                backgroundColor: C.surface,
                side: const BorderSide(color: C.line),
                labelStyle: const TextStyle(color: C.text),
              ),
              for (final s in appStatuses)
                ChoiceChip(
                  label: Text(s),
                  selected: status == s,
                  onSelected: (_) => appState.setApplication(job, s),
                  selectedColor: C.accent.withAlpha(90),
                  backgroundColor: C.surface,
                  side: const BorderSide(color: C.line),
                  labelStyle: const TextStyle(color: C.text),
                ),
            ]),
            const SizedBox(height: 18),
            const Banner2('Never pay money to apply for a job or to "unlock" an offer. Real employers do not ask for it.',
                icon: Icons.shield_rounded),
          ]),
        );
      },
    );
  }
}
