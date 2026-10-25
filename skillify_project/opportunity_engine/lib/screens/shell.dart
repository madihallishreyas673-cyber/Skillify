import 'package:flutter/material.dart';
import '../ui.dart';
import 'assistant.dart';
import 'dashboard.dart';
import 'jobs.dart';
import 'learn.dart';
import 'profile.dart';
import 'resume.dart';

class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int _i = 0;
  static const _titles = ['Home', 'Learn', 'Opportunities', 'Resume', 'Career Assistant'];

  void _go(int i) => setState(() => _i = i);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(children: [
          const LogoMark(size: 30),
          const SizedBox(width: 10),
          Text(_titles[_i], style: const TextStyle(fontWeight: FontWeight.w800)),
        ]),
        actions: [
          IconButton(
            tooltip: 'Profile',
            icon: const Icon(Icons.person_rounded),
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
          ),
        ],
      ),
      body: IndexedStack(index: _i, children: [
        DashboardScreen(onGo: _go),
        const LearnScreen(),
        const JobsScreen(),
        const ResumeScreen(),
        const AssistantScreen(),
      ]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _i,
        onDestinationSelected: _go,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.school_rounded), label: 'Learn'),
          NavigationDestination(icon: Icon(Icons.work_rounded), label: 'Jobs'),
          NavigationDestination(icon: Icon(Icons.description_rounded), label: 'Resume'),
          NavigationDestination(icon: Icon(Icons.smart_toy_rounded), label: 'Assistant'),
        ],
      ),
    );
  }
}
