import 'package:flutter/material.dart';
import 'screens/auth.dart';
import 'screens/intro.dart';
import 'screens/shell.dart';
import 'state.dart';
import 'ui.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SkillifyApp());
}

class SkillifyApp extends StatefulWidget {
  const SkillifyApp({super.key});
  @override
  State<SkillifyApp> createState() => _SkillifyAppState();
}

class _SkillifyAppState extends State<SkillifyApp> {
  @override
  void initState() {
    super.initState();
    appState.init();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: kAppName,
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: ListenableBuilder(
        listenable: appState,
        builder: (context, _) {
          if (!appState.loaded) return const _Splash();
          if (!appState.onboarded) return const WelcomeFlow();
          if (appState.email == null) return const AuthScreen();
          return const Shell();
        },
      ),
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: C.bg,
      body: Center(child: LogoFull(size: 260)),
    );
  }
}
