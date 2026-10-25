import 'package:flutter/material.dart';
import '../api.dart';
import '../data.dart';
import '../engine.dart';
import '../state.dart';
import '../ui.dart';

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});
  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  bool _busy = false;

  static const _quick = [
    'What should I do next?',
    'Interview practice',
    'Project ideas',
    'How do I apply?',
    'Resume tips',
    'My skill gaps',
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _toEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _send(String text) async {
    final q = text.trim();
    if (q.isEmpty || _busy) return;
    _ctrl.clear();
    final d = appState.data;
    appState.addChat(Msg(true, q));
    setState(() => _busy = true);
    _toEnd();

    String reply;
    if (d.backendUrl.isNotEmpty) {
      try {
        final c = careerById(d.careerId);
        reply = await askBackend(d.backendUrl, d.backendKey, d.chat, {
          'career': c?.title,
          'skills': d.profile.skills.toList(),
          'skillGaps': c == null ? [] : c.skills.where((s) => !d.profile.skills.contains(s)).toList(),
          'goal': d.profile.goal,
        });
      } catch (_) {
        reply = '${localReply(q, d)}\n\n(Cloud AI could not be reached, so this answer is from the built-in assistant.)';
      }
    } else {
      await Future.delayed(const Duration(milliseconds: 400));
      reply = localReply(q, d);
    }
    if (!mounted) return;
    appState.addChat(Msg(false, reply));
    setState(() => _busy = false);
    _toEnd();
  }

  Widget _bubble(Msg m) {
    return Align(
      alignment: m.user ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.84),
        decoration: BoxDecoration(
          gradient: m.user ? const LinearGradient(colors: [C.accent, C.accent2]) : null,
          color: m.user ? null : C.panel,
          borderRadius: BorderRadius.circular(16),
          border: m.user ? null : Border.all(color: C.line),
        ),
        child: SelectableText(m.text,
            style: TextStyle(color: m.user ? Colors.black : C.text, height: 1.4)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final chat = appState.data.chat;
        return Column(children: [
          Expanded(
            child: ListView(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              children: [
                _bubble(Msg(false,
                    'Hi! I am your career assistant. I can suggest your next step, help you prepare for interviews, suggest projects and explain how to apply.\n\nI never apply to jobs or contact employers for you - you stay in control.')),
                ...chat.map(_bubble),
                if (_busy)
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: C.accent)),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(
            height: 46,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: _quick
                  .map((q) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ActionChip(
                          label: Text(q),
                          backgroundColor: C.surface,
                          side: const BorderSide(color: C.line),
                          labelStyle: const TextStyle(color: C.text),
                          onPressed: () => _send(q),
                        ),
                      ))
                  .toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onSubmitted: _send,
                  decoration: inputDeco('Ask about your career...'),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                style: IconButton.styleFrom(backgroundColor: C.accent, foregroundColor: Colors.black),
                onPressed: _busy ? null : () => _send(_ctrl.text),
                icon: const Icon(Icons.send_rounded),
              ),
            ]),
          ),
        ]);
      },
    );
  }
}
