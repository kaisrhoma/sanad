import 'package:flutter/material.dart';

import '../models/profile.dart';
import '../theme.dart';
import 'home_shell.dart';
import 'welcome_screen.dart';
import 'widgets.dart';

/// Animated splash shown right after the native splash (same background, so the hand-off is seamless).
/// The logo has no background of its own, so it looks right in both light and dark mode.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..forward();

  @override
  void initState() {
    super.initState();
    _go();
  }

  Future<void> _go() async {
    final results = await Future.wait([
      Profile.load(),
      Future<void>.delayed(const Duration(milliseconds: 1500)),
    ]);
    if (!mounted) return;
    final p = results.first as Profile?;
    Navigator.of(context).pushReplacement(fadeRoute(p == null ? const WelcomeScreen() : HomeShell(profile: p)));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Palette.of(context);
    final logo = CurvedAnimation(parent: _c, curve: const Interval(0, 0.6, curve: Curves.easeOutBack));
    final text = CurvedAnimation(parent: _c, curve: const Interval(0.35, 1, curve: Curves.easeOut));
    return Scaffold(
      backgroundColor: c.bg,
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ScaleTransition(
            scale: Tween(begin: 0.8, end: 1.0).animate(logo),
            child: FadeTransition(
              opacity: CurvedAnimation(parent: _c, curve: const Interval(0, 0.4)),
              child: Image.asset('assets/logo/logo.png', width: 150, height: 150),
            ),
          ),
          const SizedBox(height: 22),
          FadeTransition(
            opacity: text,
            child: SlideTransition(
              position: Tween(begin: const Offset(0, 0.3), end: Offset.zero).animate(text),
              child: Column(children: [
                ShaderMask(
                  shaderCallback: (r) => c.gradient.createShader(r),
                  child: const Text('سند',
                      style: TextStyle(fontSize: 44, fontWeight: FontWeight.w800, color: Colors.white, height: 1.1)),
                ),
                const SizedBox(height: 6),
                Text('مساحتك الآمنة لتخفيف الضغط', style: TextStyle(color: c.muted, fontSize: 15)),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}
