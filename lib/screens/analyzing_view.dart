import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme.dart';

/// Full-screen "analysing" state shown while Gemini works.
/// Instead of a spinner, the user is invited to breathe with a calm orb while
/// short progress steps tick off, so the wait feels intentional rather than slow.
class AnalyzingView extends StatefulWidget {
  final bool voice;
  const AnalyzingView({super.key, this.voice = false});

  @override
  State<AnalyzingView> createState() => _AnalyzingViewState();
}

class _AnalyzingViewState extends State<AnalyzingView> with TickerProviderStateMixin {
  static const _stepEvery = Duration(milliseconds: 1300);

  late final AnimationController _breath =
      AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);
  late final AnimationController _enter =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 350))..forward();
  Timer? _timer;
  int _done = 0; // number of completed steps (the last one stays active until the answer arrives)

  List<String> get _steps => widget.voice
      ? const ['نستمع لكلامك', 'نفهم مصدر الضغط', 'نجهّز لك خطوة مناسبة']
      : const ['نقرأ كلماتك', 'نفهم مصدر الضغط', 'نجهّز لك خطوة مناسبة'];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(_stepEvery, (t) {
      if (_done >= _steps.length - 1) {
        t.cancel();
        return;
      }
      setState(() => _done++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _breath.dispose();
    _enter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Palette.of(context);
    return Positioned.fill(
      child: FadeTransition(
        opacity: CurvedAnimation(parent: _enter, curve: Curves.easeOut),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            color: c.bg.withValues(alpha: 0.86),
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: SafeArea(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                _BreathingOrb(controller: _breath),
                const SizedBox(height: 18),
                AnimatedBuilder(
                  animation: _breath,
                  builder: (_, __) {
                    final inhale = _breath.status == AnimationStatus.forward;
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: Text(
                        inhale ? 'شهيق بهدوء...' : 'وزفير ببطء...',
                        key: ValueKey(inhale),
                        style: TextStyle(color: c.primary, fontWeight: FontWeight.w700, fontSize: 16),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 4),
                Text('تنفّس مع الدائرة بينما يجهّز سند ردّه',
                    textAlign: TextAlign.center, style: TextStyle(color: c.muted, fontSize: 13.5)),
                const SizedBox(height: 34),
                for (var i = 0; i < _steps.length; i++)
                  _Step(text: _steps[i], state: i < _done ? 2 : (i == _done ? 1 : 0)),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class _BreathingOrb extends StatelessWidget {
  final AnimationController controller;
  const _BreathingOrb({required this.controller});

  @override
  Widget build(BuildContext context) {
    final c = Palette.of(context);
    final t = CurvedAnimation(parent: controller, curve: Curves.easeInOut);
    return SizedBox(
      width: 190,
      height: 190,
      child: AnimatedBuilder(
        animation: t,
        builder: (_, __) {
          final v = t.value;
          return Stack(alignment: Alignment.center, children: [
            // soft halo
            Container(
              width: 150 + 40 * v,
              height: 150 + 40 * v,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c.primary.withValues(alpha: 0.07 + 0.05 * v),
              ),
            ),
            Container(
              width: 118 + 30 * v,
              height: 118 + 30 * v,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c.secondary.withValues(alpha: 0.10 + 0.06 * v),
              ),
            ),
            // core
            Container(
              width: 88 + 22 * v,
              height: 88 + 22 * v,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: c.gradient,
                boxShadow: [
                  BoxShadow(color: c.primary.withValues(alpha: 0.35), blurRadius: 30 + 20 * v),
                ],
              ),
              child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 34),
            ),
          ]);
        },
      ),
    );
  }
}

/// state: 0 = waiting, 1 = in progress, 2 = done
class _Step extends StatelessWidget {
  final String text;
  final int state;
  const _Step({required this.text, required this.state});

  @override
  Widget build(BuildContext context) {
    final c = Palette.of(context);
    final active = state > 0;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: active ? 1 : 0.4,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(
            width: 22,
            height: 22,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (w, a) => ScaleTransition(scale: a, child: w),
              child: state == 2
                  ? Icon(Icons.check_circle_rounded, key: const ValueKey(2), color: AppColors.low, size: 22)
                  : state == 1
                      ? Padding(
                          key: const ValueKey(1),
                          padding: const EdgeInsets.all(3),
                          child: CircularProgressIndicator(strokeWidth: 2.2, color: c.primary),
                        )
                      : Icon(Icons.circle_outlined, key: const ValueKey(0), color: c.muted, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 190,
            child: Text(text,
                style: TextStyle(
                  color: c.text,
                  fontSize: 15,
                  fontWeight: state == 1 ? FontWeight.w700 : FontWeight.w500,
                )),
          ),
        ]),
      ),
    );
  }
}
