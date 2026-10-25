import 'package:flutter/material.dart';
import '../data.dart';
import '../state.dart';
import '../ui.dart';
import 'assessment.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _url;
  late final TextEditingController _key;

  @override
  void initState() {
    super.initState();
    _url = TextEditingController(text: appState.data.backendUrl);
    _key = TextEditingController(text: appState.data.backendKey);
  }

  @override
  void dispose() {
    _url.dispose();
    _key.dispose();
    super.dispose();
  }

  Future<bool> _confirm(String title, String body, String yes) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: C.panel,
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(yes)),
        ],
      ),
    );
    return ok == true;
  }

  @override
  Widget build(BuildContext context) {
    final name = appState.name ?? '';
    final c = careerById(appState.data.careerId);
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Center(
          child: CircleAvatar(
            radius: 40,
            backgroundColor: C.accent,
            child: Text(name.isEmpty ? '?' : name[0].toUpperCase(),
                style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: Colors.black)),
          ),
        ),
        const SizedBox(height: 12),
        Center(child: Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800))),
        Center(child: Text(appState.email ?? '', style: const TextStyle(color: C.muted))),
        const SizedBox(height: 8),
        Center(child: Pill(c == null ? 'No career path chosen yet' : 'Path: ${c.title}')),

        const SectionTitle('Your plan'),
        Panel(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: const [
              Icon(Icons.workspace_premium_rounded, color: C.accent),
              SizedBox(width: 10),
              Text('Free plan', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            ]),
            const SizedBox(height: 8),
            const Text(
                'Everything in this version is free. Premium AI features and tools for employers are planned for later versions. No payments are included yet.',
                style: TextStyle(color: C.muted, height: 1.4)),
          ]),
        ),

        const SectionTitle('Cloud AI (optional)'),
        const Banner2(
            'Connect your own secure backend to get smarter AI answers. Your server keeps the AI key secret. Messages and your skill summary are sent to that server. Leave empty to use the built-in assistant.'),
        const SizedBox(height: 12),
        TextField(
            controller: _url,
            keyboardType: TextInputType.url,
            decoration: inputDeco('Backend URL', hint: 'https://your-server.example.com', icon: Icons.cloud_rounded)),
        const SizedBox(height: 12),
        TextField(
            controller: _key,
            obscureText: true,
            decoration: inputDeco('Access key', icon: Icons.key_rounded)),
        const SizedBox(height: 12),
        GhostButton(
          label: 'Save Cloud AI settings',
          icon: Icons.save_rounded,
          onPressed: () {
            final u = _url.text.trim();
            if (u.isNotEmpty && !(u.startsWith('https://') || u.startsWith('http://'))) {
              toast(context, 'The URL must start with https://', error: true);
              return;
            }
            appState.setBackend(u, _key.text);
            toast(context, u.isEmpty ? 'Cloud AI turned off' : 'Cloud AI settings saved');
          },
        ),

        const SectionTitle('Your data'),
        GhostButton(
            label: 'Retake skill assessment',
            icon: Icons.psychology_rounded,
            onPressed: () => openAssessment(context)),
        const SizedBox(height: 10),
        GhostButton(
            label: 'Clear assistant chat',
            icon: Icons.chat_bubble_outline_rounded,
            onPressed: () {
              appState.clearChat();
              toast(context, 'Chat cleared');
            }),
        const SizedBox(height: 10),
        GhostButton(
          label: 'Reset learning progress',
          icon: Icons.restart_alt_rounded,
          onPressed: () async {
            final ok = await _confirm('Reset progress?',
                'This clears completed lessons, quiz scores, tasks and projects. Your resume and saved jobs stay.', 'Reset');
            if (ok) {
              appState.resetProgress();
              if (mounted) toast(context, 'Progress reset');
            }
          },
        ),

        const SectionTitle('About'),
        const Text(
            'Skillify v1.0 (first test version)\n\n'
            'Sample listings marked DEMO DATA are not real jobs. Live remote jobs come from Remotive (remotive.com). '
            'Fit scores and career suggestions are guidance, not a guarantee of any job or income.',
            style: TextStyle(color: C.muted, height: 1.45)),
        const SizedBox(height: 24),
        PrimaryButton(
          label: 'Log out',
          icon: Icons.logout_rounded,
          onPressed: () async {
            final nav = Navigator.of(context);
            nav.popUntil((r) => r.isFirst);
            await appState.logout();
          },
        ),
      ]),
    );
  }
}
