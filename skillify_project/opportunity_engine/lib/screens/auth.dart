import 'package:flutter/material.dart';
import '../state.dart';
import '../ui.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pw = TextEditingController();
  bool _register = true;
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _pw.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_form.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final err = _register
        ? await appState.register(_name.text, _email.text, _pw.text)
        : await appState.login(_email.text, _pw.text);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _error = err;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _form,
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  const Center(child: LogoMark(size: 84)),
                  const SizedBox(height: 14),
                  Text(_register ? 'Create your account' : 'Welcome back',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  const Text(kTagline,
                      textAlign: TextAlign.center, style: TextStyle(color: C.accent)),
                  const SizedBox(height: 24),
                  if (_error != null) ...[Banner2(_error!, error: true), const SizedBox(height: 14)],
                  if (_register) ...[
                    TextFormField(
                      controller: _name,
                      textCapitalization: TextCapitalization.words,
                      decoration: inputDeco('Full name', icon: Icons.person_rounded),
                      validator: (v) =>
                          (v == null || v.trim().length < 2) ? 'Please enter your name' : null,
                    ),
                    const SizedBox(height: 14),
                  ],
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: inputDeco('Email', icon: Icons.mail_rounded),
                    validator: (v) => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch((v ?? '').trim())
                        ? null
                        : 'Enter a valid email',
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _pw,
                    obscureText: _obscure,
                    decoration: inputDeco('Password',
                        icon: Icons.lock_rounded,
                        suffix: IconButton(
                          icon: Icon(
                              _obscure ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                              color: C.muted),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        )),
                    validator: (v) =>
                        (v == null || v.length < 6) ? 'Use at least 6 characters' : null,
                  ),
                  const SizedBox(height: 22),
                  PrimaryButton(
                    label: _register ? 'Create account' : 'Log in',
                    loading: _loading,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _loading
                        ? null
                        : () => setState(() {
                              _register = !_register;
                              _error = null;
                            }),
                    child: Text(
                      _register ? 'I already have an account' : 'Create a new account',
                      style: const TextStyle(color: C.accent),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Version 1 stores your account and progress on this phone only. Cloud accounts and sync come in a later version.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: C.muted, fontSize: 12, height: 1.4),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
