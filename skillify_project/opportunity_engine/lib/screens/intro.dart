import 'package:flutter/material.dart';
import '../state.dart';
import '../ui.dart';

class _Pg {
  final IconData icon;
  final String title, body;
  const _Pg(this.icon, this.title, this.body);
}

const _pages = [
  _Pg(Icons.psychology_rounded, 'Discover your strengths',
      'Answer a few questions about your education, interests and skills. Skillify shows realistic career options - even if you have no degree or experience yet.'),
  _Pg(Icons.school_rounded, 'Learn step by step',
      'Get a personal learning plan with free resources, daily and weekly tasks, quizzes and practice projects. Track your progress as you grow.'),
  _Pg(Icons.public_rounded, 'Find global opportunities',
      'Search jobs, internships, freelance work and apprenticeships, build your resume and cover letters, and track every application. You always decide where to apply.'),
];

class WelcomeFlow extends StatefulWidget {
  const WelcomeFlow({super.key});
  @override
  State<WelcomeFlow> createState() => _WelcomeFlowState();
}

class _WelcomeFlowState extends State<WelcomeFlow> {
  final _pc = PageController();
  int _i = 0;
  int get _last => _pages.length; // page 0 is the welcome page

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  void _next() {
    if (_i >= _last) {
      appState.completeOnboarding();
    } else {
      _pc.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeOut);
    }
  }

  Widget _welcome() => Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const LogoFull(size: 300),
            const SizedBox(height: 4),
            const Text(kTagline,
                textAlign: TextAlign.center,
                style: TextStyle(color: C.accent, fontSize: 16, letterSpacing: 0.5)),
          ]),
        ),
      );

  Widget _page(_Pg p) => Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(colors: [C.accent, C.accent2]),
                boxShadow: [BoxShadow(color: C.accent.withAlpha(70), blurRadius: 30)],
              ),
              child: Icon(p.icon, size: 56, color: Colors.black),
            ),
            const SizedBox(height: 32),
            Text(p.title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),
            Text(p.body,
                textAlign: TextAlign.center,
                style: const TextStyle(color: C.muted, fontSize: 16, height: 1.5)),
          ]),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Align(
            alignment: Alignment.centerRight,
            child: _i == 0
                ? const SizedBox(height: 48)
                : TextButton(
                    onPressed: () => appState.completeOnboarding(),
                    child: const Text('Skip', style: TextStyle(color: C.muted)),
                  ),
          ),
          Expanded(
            child: PageView(
              controller: _pc,
              onPageChanged: (i) => setState(() => _i = i),
              children: [_welcome(), ..._pages.map(_page)],
            ),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            for (var k = 0; k <= _last; k++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.all(4),
                width: k == _i ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: k == _i ? C.accent : C.line,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
          ]),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                label: _i == 0 ? 'Get started' : (_i == _last ? 'Continue' : 'Next'),
                onPressed: _next,
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
