import 'dart:async';

import 'package:flutter/material.dart';

import '../theme.dart';
import 'widgets.dart';

/// Guided box breathing (4-4-4-4) with an animated circle, as in Taha's exercise list.
class BreathingScreen extends StatefulWidget {
  const BreathingScreen({super.key});
  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen> {
  static const _phases = [
    ('شهيق', 4, 1.0),
    ('احبس نفسك', 4, 1.0),
    ('زفير ببطء', 4, 0.55),
    ('انتظر', 4, 0.55),
  ];
  static const _cycles = 4;

  Timer? _timer;
  bool _running = false;
  int _phase = 0;
  int _left = 0;
  int _cycle = 0;
  double _scale = 0.55;

  void _start() {
    setState(() {
      _running = true;
      _cycle = 1;
      _setPhase(0);
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _setPhase(int i) {
    _phase = i;
    _left = _phases[i].$2;
    _scale = _phases[i].$3;
  }

  void _tick() {
    setState(() {
      _left--;
      if (_left > 0) return;
      if (_phase < _phases.length - 1) {
        _setPhase(_phase + 1);
      } else if (_cycle < _cycles) {
        _cycle++;
        _setPhase(0);
      } else {
        _stop();
      }
    });
  }

  void _stop() {
    _timer?.cancel();
    _running = false;
    _scale = 0.55;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Palette.of(context);
    final p = _phases[_phase];
    return Scaffold(
      appBar: AppBar(title: const Text('تنفس المربع')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          Text(
            _running ? 'الدورة $_cycle من $_cycles' : 'اجلس بشكل مريح، وأرخِ كتفيك',
            style: TextStyle(color: c.muted, fontSize: 15),
          ),
          Expanded(
            child: Center(
              child: AnimatedScale(
                scale: _scale,
                duration: Duration(seconds: _running ? p.$2 : 1),
                curve: Curves.easeInOut,
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: c.gradient,
                    boxShadow: [BoxShadow(color: c.primary.withValues(alpha: 0.35), blurRadius: 60, spreadRadius: 8)],
                  ),
                  alignment: Alignment.center,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(_running ? p.$1 : 'جاهز؟',
                        style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800)),
                    if (_running)
                      Text('$_left',
                          style: const TextStyle(color: Colors.white, fontSize: 46, fontWeight: FontWeight.w300)),
                  ]),
                ),
              ),
            ),
          ),
          Text('شهيق 4 • حبس 4 • زفير 4 • انتظار 4', style: TextStyle(color: c.muted)),
          const SizedBox(height: 18),
          _running
              ? OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(54),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  onPressed: () => setState(_stop),
                  child: const Text('إيقاف'),
                )
              : GradientButton(label: 'ابدأ التمرين', icon: Icons.play_arrow_rounded, onPressed: _start),
        ]),
      ),
    );
  }
}
