import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data.dart';
import '../pdf_export.dart';
import '../state.dart';
import '../ui.dart';

Future<Entry?> showEntrySheet(
  BuildContext context, {
  Entry? initial,
  required String titleLabel,
  required String orgLabel,
  String datesLabel = 'Dates',
  bool showDates = true,
}) {
  return showModalBottomSheet<Entry>(
    context: context,
    isScrollControlled: true,
    backgroundColor: C.surface,
    builder: (_) => _EntrySheet(
      initial: initial,
      titleLabel: titleLabel,
      orgLabel: orgLabel,
      datesLabel: datesLabel,
      showDates: showDates,
    ),
  );
}

class _EntrySheet extends StatefulWidget {
  final Entry? initial;
  final String titleLabel, orgLabel, datesLabel;
  final bool showDates;
  const _EntrySheet({
    required this.initial,
    required this.titleLabel,
    required this.orgLabel,
    required this.datesLabel,
    required this.showDates,
  });
  @override
  State<_EntrySheet> createState() => _EntrySheetState();
}

class _EntrySheetState extends State<_EntrySheet> {
  late final TextEditingController t, o, dt, de;
  @override
  void initState() {
    super.initState();
    final e = widget.initial;
    t = TextEditingController(text: e?.title ?? '');
    o = TextEditingController(text: e?.org ?? '');
    dt = TextEditingController(text: e?.dates ?? '');
    de = TextEditingController(text: e?.details ?? '');
  }

  @override
  void dispose() {
    t.dispose();
    o.dispose();
    dt.dispose();
    de.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          TextField(controller: t, decoration: inputDeco(widget.titleLabel)),
          const SizedBox(height: 12),
          TextField(controller: o, decoration: inputDeco(widget.orgLabel)),
          if (widget.showDates) ...[
            const SizedBox(height: 12),
            TextField(controller: dt, decoration: inputDeco(widget.datesLabel)),
          ],
          const SizedBox(height: 12),
          TextField(
              controller: de,
              minLines: 3,
              maxLines: 6,
              decoration: inputDeco('Details (only what is true)')),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Save',
            onPressed: () {
              if (t.text.trim().isEmpty) {
                toast(context, '${widget.titleLabel} is required', error: true);
                return;
              }
              Navigator.pop(
                  context,
                  Entry(
                      title: t.text.trim(),
                      org: o.text.trim(),
                      dates: dt.text.trim(),
                      details: de.text.trim()));
            },
          ),
        ]),
      ),
    );
  }
}

class ResumeScreen extends StatefulWidget {
  const ResumeScreen({super.key});
  @override
  State<ResumeScreen> createState() => _ResumeScreenState();
}

class _ResumeScreenState extends State<ResumeScreen> {
  late final TextEditingController _name, _email, _phone, _loc, _headline, _summary, _links, _skills;
  final _company = TextEditingController();
  final _role = TextEditingController();
  final _letter = TextEditingController();
  bool _busy = false;

  Resume get r => appState.data.resume;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: r.name);
    _email = TextEditingController(text: r.email);
    _phone = TextEditingController(text: r.phone);
    _loc = TextEditingController(text: r.location);
    _headline = TextEditingController(text: r.headline);
    _summary = TextEditingController(text: r.summary);
    _links = TextEditingController(text: r.links);
    _skills = TextEditingController(text: r.skills.join(', '));
  }

  @override
  void dispose() {
    for (final c in [_name, _email, _phone, _loc, _headline, _summary, _links, _skills, _company, _role, _letter]) {
      c.dispose();
    }
    super.dispose();
  }

  Widget _tf(String label, TextEditingController c, void Function(String) on,
      {int lines = 1, TextInputType? type, String? hint, IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        minLines: lines,
        maxLines: lines == 1 ? 1 : lines + 4,
        keyboardType: type,
        decoration: inputDeco(label, hint: hint, icon: icon),
        onChanged: (v) {
          on(v);
          appState.persist();
        },
      ),
    );
  }

  void _autofill() {
    final pr = appState.data.profile;
    setState(() {
      if (r.name.isEmpty) r.name = appState.name ?? '';
      if (r.email.isEmpty) r.email = appState.email ?? '';
      if (r.skills.isEmpty) r.skills = pr.skills.toList();
      _name.text = r.name;
      _email.text = r.email;
      _skills.text = r.skills.join(', ');
    });
    appState.persist();
    toast(context, 'Filled from your account and assessment. Please review everything.');
  }

  void _draftSummary() {
    if (_summary.text.trim().isNotEmpty) {
      toast(context, 'Clear the summary box first to generate a new draft.');
      return;
    }
    final c = careerById(appState.data.careerId);
    final parts = <String>[];
    if (r.headline.trim().isNotEmpty) parts.add('${r.headline.trim()}.');
    if (r.skills.isNotEmpty) parts.add('Skills include ${r.skills.take(6).join(', ')}.');
    if (c != null) {
      parts.add(
          'Building job-ready skills for ${c.title.toLowerCase()} work through a structured learning plan.');
    }
    final pj = r.projects.map((e) => e.title).where((t) => t.isNotEmpty).take(3).toList();
    if (pj.isNotEmpty) parts.add('Projects: ${pj.join(', ')}.');
    if (parts.isEmpty) {
      toast(context, 'Add a headline and skills first.', error: true);
      return;
    }
    setState(() {
      _summary.text = parts.join(' ');
      r.summary = _summary.text;
    });
    appState.persist();
    toast(context, 'Draft added from your own details. Edit it so it sounds like you.');
  }

  Future<void> _addEntry(List<Entry> list,
      {required String titleLabel,
      required String orgLabel,
      String datesLabel = 'Dates',
      bool showDates = true,
      Entry? edit}) async {
    final e = await showEntrySheet(context,
        initial: edit,
        titleLabel: titleLabel,
        orgLabel: orgLabel,
        datesLabel: datesLabel,
        showDates: showDates);
    if (e == null) return;
    setState(() {
      if (edit != null) {
        final i = list.indexOf(edit);
        if (i >= 0) list[i] = e;
      } else {
        list.add(e);
      }
    });
    appState.persist();
  }

  Widget _entrySection(String title, List<Entry> list,
      {required String titleLabel,
      required String orgLabel,
      String datesLabel = 'Dates',
      bool showDates = true}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SectionTitle(title,
          trailing: TextButton.icon(
            onPressed: () => _addEntry(list,
                titleLabel: titleLabel,
                orgLabel: orgLabel,
                datesLabel: datesLabel,
                showDates: showDates),
            icon: const Icon(Icons.add_rounded, color: C.accent),
            label: const Text('Add', style: TextStyle(color: C.accent)),
          )),
      if (list.isEmpty)
        const Text('Nothing added yet.', style: TextStyle(color: C.muted)),
      ...list.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Panel(
              onTap: () => _addEntry(list,
                  titleLabel: titleLabel,
                  orgLabel: orgLabel,
                  datesLabel: datesLabel,
                  showDates: showDates,
                  edit: e),
              child: Row(children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(e.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                    if (e.org.isNotEmpty || e.dates.isNotEmpty)
                      Text([e.org, e.dates].where((s) => s.isNotEmpty).join(' - '),
                          style: const TextStyle(color: C.muted, fontSize: 13)),
                    if (e.details.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(e.details,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: C.muted, fontSize: 13)),
                      ),
                  ]),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: C.muted),
                  onPressed: () {
                    setState(() => list.remove(e));
                    appState.persist();
                  },
                ),
              ]),
            ),
          )),
    ]);
  }

  Future<void> _exportResume() async {
    if (r.name.trim().isEmpty) {
      toast(context, 'Add your name first.', error: true);
      return;
    }
    setState(() => _busy = true);
    try {
      final bytes = await buildResumePdf(r);
      final safe = r.name.trim().replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_');
      await sharePdf(bytes, 'Resume_$safe.pdf');
    } catch (_) {
      if (mounted) toast(context, 'Could not create the PDF. Please try again.', error: true);
    }
    if (mounted) setState(() => _busy = false);
  }

  Widget _resumeTab() {
    return ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 24), children: [
      const Banner2(
          'Only add things that are true. Skillify never invents qualifications or experience for you.',
          icon: Icons.verified_user_rounded),
      const SizedBox(height: 12),
      GhostButton(label: 'Fill from my account and assessment', icon: Icons.auto_fix_high_rounded, onPressed: _autofill),
      const SectionTitle('Contact'),
      _tf('Full name', _name, (v) => r.name = v, icon: Icons.person_rounded),
      _tf('Email', _email, (v) => r.email = v, type: TextInputType.emailAddress, icon: Icons.mail_rounded),
      _tf('Phone (optional)', _phone, (v) => r.phone = v, type: TextInputType.phone, icon: Icons.phone_rounded),
      _tf('Location (optional)', _loc, (v) => r.location = v, icon: Icons.place_rounded),
      _tf('Links (portfolio, GitHub, LinkedIn)', _links, (v) => r.links = v, icon: Icons.link_rounded),
      const SectionTitle('Headline and summary'),
      _tf('Headline', _headline, (v) => r.headline = v, hint: 'e.g. Aspiring video editor'),
      _tf('Summary', _summary, (v) => r.summary = v, lines: 4),
      GhostButton(label: 'Draft summary from my details', icon: Icons.edit_note_rounded, onPressed: _draftSummary),
      const SectionTitle('Skills'),
      _tf('Skills (comma separated)', _skills, (v) {
        r.skills = v.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      }),
      _entrySection('Experience', r.experience,
          titleLabel: 'Role', orgLabel: 'Organisation', datesLabel: 'Dates'),
      _entrySection('Education', r.education,
          titleLabel: 'Course / qualification', orgLabel: 'School / institute', datesLabel: 'Years'),
      const SizedBox(height: 4),
      const Text('Projects are added in the Portfolio tab and included in your PDF.',
          style: TextStyle(color: C.muted, fontSize: 12)),
      const SizedBox(height: 20),
      PrimaryButton(
          label: 'Export resume as PDF',
          icon: Icons.picture_as_pdf_rounded,
          loading: _busy,
          onPressed: _exportResume),
      const SizedBox(height: 6),
      const Text('PDF export currently supports Latin letters only.',
          textAlign: TextAlign.center, style: TextStyle(color: C.muted, fontSize: 12)),
    ]);
  }

  // ---------------------------------------------------------- Cover letter ----

  Future<void> _pickJob() async {
    final d = appState.data;
    final jobs = d.bookmarks.map(appState.jobById).whereType<Job>().toList();
    if (jobs.isEmpty) {
      toast(context, 'Save a job in the Jobs tab first, or type the company and role below.');
      return;
    }
    final j = await showModalBottomSheet<Job>(
      context: context,
      backgroundColor: C.surface,
      builder: (ctx) => ListView(
        padding: const EdgeInsets.all(12),
        children: jobs
            .map((j) => ListTile(
                  title: Text(j.title),
                  subtitle: Text(j.company, style: const TextStyle(color: C.muted)),
                  onTap: () => Navigator.pop(ctx, j),
                ))
            .toList(),
      ),
    );
    if (j == null) return;
    setState(() {
      _role.text = j.title;
      _company.text = j.demo ? '' : j.company;
    });
  }

  void _genLetter() {
    final d = appState.data;
    final c = careerById(d.careerId);
    final company = _company.text.trim().isEmpty ? '[Company name]' : _company.text.trim();
    final role = _role.text.trim().isEmpty ? '[Role title]' : _role.text.trim();
    Job? target;
    for (final j in [...demoJobs, ...d.bookmarks.map(appState.jobById).whereType<Job>()]) {
      if (j.title == _role.text.trim()) target = j;
    }
    final mine = r.skills.isNotEmpty ? r.skills : d.profile.skills.toList();
    final matched = target == null ? mine.take(5).toList() : mine.where((s) => target!.tags.contains(s)).toList();
    final pj = r.projects.map((e) => e.title).where((t) => t.isNotEmpty).take(2).toList();
    final b = StringBuffer()
      ..writeln('Dear Hiring Team at $company,')
      ..writeln()
      ..write('I am writing to express my interest in the $role position. ');
    if (r.summary.trim().isNotEmpty) b.write(r.summary.trim());
    b.writeln();
    b.writeln();
    if (matched.isNotEmpty) b.writeln('My relevant skills include ${matched.join(', ')}.');
    if (pj.isNotEmpty) b.writeln('Examples of my work include ${pj.join(' and ')}.');
    if (c != null) {
      b.writeln('I am currently developing my skills in ${c.title.toLowerCase()} through a structured learning plan.');
    }
    b
      ..writeln()
      ..writeln('[Add one honest sentence about why this company or role interests you.]')
      ..writeln()
      ..writeln('I would welcome the opportunity to discuss how I can contribute. Thank you for your time and consideration.')
      ..writeln()
      ..writeln('Sincerely,')
      ..write(r.name.isEmpty ? '[Your name]' : r.name);
    setState(() => _letter.text = b.toString());
    toast(context, 'Draft created from your own details. Edit the [brackets] before using it.');
  }

  Future<void> _exportLetter() async {
    if (_letter.text.trim().isEmpty) {
      toast(context, 'Generate or write a letter first.', error: true);
      return;
    }
    setState(() => _busy = true);
    try {
      final bytes = await buildLetterPdf(_letter.text, r.name);
      await sharePdf(bytes, 'Cover_Letter.pdf');
    } catch (_) {
      if (mounted) toast(context, 'Could not create the PDF. Please try again.', error: true);
    }
    if (mounted) setState(() => _busy = false);
  }

  Widget _letterTab() {
    return ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 24), children: [
      const Banner2(
          'The draft uses only details you entered. Review it, fill in the [brackets], and make it sound like you.',
          icon: Icons.verified_user_rounded),
      const SizedBox(height: 12),
      GhostButton(label: 'Pick from my saved jobs', icon: Icons.bookmark_rounded, onPressed: _pickJob),
      const SizedBox(height: 12),
      TextField(controller: _company, decoration: inputDeco('Company', icon: Icons.business_rounded)),
      const SizedBox(height: 12),
      TextField(controller: _role, decoration: inputDeco('Role', icon: Icons.work_rounded)),
      const SizedBox(height: 12),
      PrimaryButton(label: 'Generate draft', icon: Icons.auto_awesome_rounded, onPressed: _genLetter),
      const SizedBox(height: 16),
      TextField(
        controller: _letter,
        minLines: 12,
        maxLines: 40,
        decoration: inputDeco('Cover letter (editable)'),
      ),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(
          child: GhostButton(
              label: 'Copy',
              icon: Icons.copy_rounded,
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: _letter.text));
                if (mounted) toast(context, 'Copied to clipboard');
              }),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: PrimaryButton(
              label: 'Export PDF',
              icon: Icons.picture_as_pdf_rounded,
              loading: _busy,
              onPressed: _exportLetter),
        ),
      ]),
    ]);
  }

  // -------------------------------------------------------------- Portfolio ----

  Widget _portfolioTab() {
    final d = appState.data;
    final c = careerById(d.careerId);
    final suggestions = <String>[];
    if (c != null) {
      for (var i = 0; i < c.projects.length; i++) {
        if (d.projectsDone.contains('${c.id}|$i') &&
            !r.projects.any((e) => e.title == c.projects[i])) {
          suggestions.add(c.projects[i]);
        }
      }
    }
    return ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 24), children: [
      const Banner2(
          'Your portfolio shows real projects you completed. Describe honestly what you built and what you did yourself.',
          icon: Icons.folder_special_rounded),
      if (suggestions.isNotEmpty) ...[
        const SectionTitle('Add finished practice projects'),
        Wrap(
            spacing: 8,
            runSpacing: 8,
            children: suggestions
                .map((s) => ActionChip(
                      label: Text(s),
                      backgroundColor: C.surface,
                      side: const BorderSide(color: C.line),
                      labelStyle: const TextStyle(color: C.text),
                      onPressed: () {
                        setState(() => r.projects.add(Entry(title: s, details: '')));
                        appState.persist();
                        toast(context, 'Added. Now tap it to describe what you actually built.');
                      },
                    ))
                .toList()),
      ],
      _entrySection('Projects', r.projects,
          titleLabel: 'Project name', orgLabel: 'Link (optional)', showDates: false),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(children: [
        const TabBar(
          indicatorColor: C.accent,
          labelColor: C.accent,
          unselectedLabelColor: C.muted,
          dividerColor: C.line,
          tabs: [Tab(text: 'Resume'), Tab(text: 'Cover letter'), Tab(text: 'Portfolio')],
        ),
        Expanded(
          child: TabBarView(children: [_resumeTab(), _letterTab(), _portfolioTab()]),
        ),
      ]),
    );
  }
}
