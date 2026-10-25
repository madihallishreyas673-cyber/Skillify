import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Skillify palette: black + gold, matching the logo.
class C {
  static const bg = Color(0xFF000000);
  static const surface = Color(0xFF0D0D0D);
  static const panel = Color(0xFF151515);
  static const line = Color(0xFF2E2819);
  static const accent = Color(0xFFF2C14E);
  static const accent2 = Color(0xFFC8901A);
  static const text = Color(0xFFF5F1E6);
  static const muted = Color(0xFFA39B87);
  static const warn = Color(0xFFF59E0B);
  static const bad = Color(0xFFEF4444);
  static const good = Color(0xFF22C55E);
}

const kAppName = 'Skillify';
const kTagline = 'Your Skills. Global Opportunities.';

ThemeData buildTheme() {
  final scheme = ColorScheme.dark(
    primary: C.accent,
    secondary: C.accent2,
    surface: C.surface,
    onSurface: C.text,
    onPrimary: Colors.black,
    error: C.bad,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: C.bg,
    appBarTheme: const AppBarTheme(
      backgroundColor: C.bg,
      foregroundColor: C.text,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: C.surface,
      indicatorColor: C.accent.withAlpha(60),
    ),
  );
}

void toast(BuildContext context, String msg, {bool error = false}) {
  final m = ScaffoldMessenger.of(context);
  m.hideCurrentSnackBar();
  m.showSnackBar(SnackBar(
    content: Text(msg, style: const TextStyle(color: C.text)),
    backgroundColor: error ? const Color(0xFF7F1D1D) : C.panel,
    behavior: SnackBarBehavior.floating,
  ));
}

InputDecoration inputDeco(String label,
    {String? hint, IconData? icon, Widget? suffix}) {
  OutlineInputBorder b(Color c) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: c));
  return InputDecoration(
    labelText: label,
    hintText: hint,
    labelStyle: const TextStyle(color: C.muted),
    hintStyle: TextStyle(color: C.muted.withAlpha(150)),
    prefixIcon: icon == null ? null : Icon(icon, color: C.muted),
    suffixIcon: suffix,
    filled: true,
    fillColor: C.surface,
    border: b(C.line),
    enabledBorder: b(C.line),
    focusedBorder: b(C.accent),
    errorBorder: b(C.bad),
    focusedErrorBorder: b(C.bad),
  );
}

Future<void> openLink(BuildContext context, String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null) {
    toast(context, 'This link is not valid.', error: true);
    return;
  }
  try {
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      toast(context, 'Could not open the link.', error: true);
    }
  } catch (_) {
    if (context.mounted) toast(context, 'Could not open the link.', error: true);
  }
}

class Panel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;
  const Panel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.color,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? C.panel,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: borderColor ?? C.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(onTap: onTap, child: Padding(padding: padding, child: child)),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    return Opacity(
      opacity: onPressed == null ? 0.45 : 1,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [C.accent, C.accent2]),
            borderRadius: BorderRadius.circular(14),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: enabled ? onPressed : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              child: Center(
                child: loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.black))
                    : Row(mainAxisSize: MainAxisSize.min, children: [
                        if (icon != null) ...[
                          Icon(icon, size: 20, color: Colors.black),
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          child: Text(label,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16)),
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

class GhostButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  const GhostButton({super.key, required this.label, this.onPressed, this.icon});

  @override
  Widget build(BuildContext context) {
    final style = OutlinedButton.styleFrom(
      foregroundColor: C.text,
      side: const BorderSide(color: C.line),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    );
    if (icon == null) {
      return OutlinedButton(onPressed: onPressed, style: style, child: Text(label));
    }
    return OutlinedButton.icon(
        onPressed: onPressed, style: style, icon: Icon(icon, size: 18), label: Text(label));
  }
}

class Pill extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;
  const Pill(this.text, {super.key, this.color = C.accent, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(32),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(110)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[Icon(icon, size: 13, color: color), const SizedBox(width: 4)],
        Flexible(
          child: Text(text,
              style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String text;
  final Widget? trailing;
  const SectionTitle(this.text, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 22, 2, 10),
      child: Row(children: [
        Expanded(
          child: Text(text,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w800, color: C.text)),
        ),
        if (trailing != null) trailing!,
      ]),
    );
  }
}

class Banner2 extends StatelessWidget {
  final String text;
  final bool error;
  final IconData? icon;
  const Banner2(this.text, {super.key, this.error = false, this.icon});

  @override
  Widget build(BuildContext context) {
    final col = error ? C.bad : C.accent;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: col.withAlpha(24),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: col.withAlpha(90)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon ?? (error ? Icons.error_outline_rounded : Icons.info_outline_rounded),
            color: col, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: const TextStyle(color: C.text, height: 1.35))),
      ]),
    );
  }
}

/// The Skillify logo (full lockup, black background).
class LogoFull extends StatelessWidget {
  final double size;
  const LogoFull({super.key, this.size = 240});
  @override
  Widget build(BuildContext context) =>
      Image.asset('assets/logo_full.png', width: size, height: size, fit: BoxFit.contain);
}

/// Small rounded emblem for app bars.
class LogoMark extends StatelessWidget {
  final double size;
  const LogoMark({super.key, this.size = 34});
  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.25),
        child: Image.asset('assets/icon.png', width: size, height: size, fit: BoxFit.cover),
      );
}

class ProgressRing extends StatelessWidget {
  final double value;
  final double size;
  final String label;
  const ProgressRing({super.key, required this.value, this.size = 84, required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(alignment: Alignment.center, children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            value: value.clamp(0.0, 1.0),
            strokeWidth: 8,
            backgroundColor: C.line,
            color: C.accent,
          ),
        ),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
      ]),
    );
  }
}
