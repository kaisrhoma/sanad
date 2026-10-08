import 'dart:math';

import 'package:flutter/material.dart';

import '../data/options.dart';
import '../models/analysis.dart';
import '../theme.dart';
import 'breathing_screen.dart';
import 'how_to_say_screen.dart';
import 'support_screen.dart';
import 'widgets.dart';

class ResultScreen extends StatelessWidget {
  final Analysis analysis;
  final String text;
  const ResultScreen({super.key, required this.analysis, required this.text});

  @override
  Widget build(BuildContext context) {
    final c = Palette.of(context);
    final color = levelColor(analysis.level);
    final value = analysis.level == 'high' ? 1.0 : (analysis.level == 'medium' ? 0.62 : 0.3);
    final suggestHowToSay = analysis.suggest == 'how_to_say' || analysis.level == 'high';

    final howToSay = ActionTile(
      icon: Icons.forum_rounded,
      title: 'كيف نقولها؟',
      subtitle: 'نساعدك تكتب رسالة لشخص تثق به',
      accent: c.primary,
      onTap: () => Navigator.of(context).push(fadeRoute(HowToSayScreen(text: text))),
    );
    final breathe = ActionTile(
      icon: Icons.air_rounded,
      title: 'تمرين تنفس موجّه',
      subtitle: 'دقيقتان لتهدئة جسمك وأفكارك',
      accent: c.secondary,
      onTap: () => Navigator.of(context).push(fadeRoute(const BreathingScreen())),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('نتيجتك')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
        children: [
          AppCard(
            child: Column(children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: value),
                duration: const Duration(milliseconds: 1100),
                curve: Curves.easeOutCubic,
                builder: (context, v, _) => SizedBox(
                  width: 170,
                  height: 170,
                  child: CustomPaint(
                    painter: _RingPainter(progress: v, color: color, track: c.surface2),
                    child: Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Text('مستوى الضغط', style: TextStyle(color: c.muted, fontSize: 13)),
                        Text(levelLabels[analysis.level] ?? analysis.level,
                            style: TextStyle(color: color, fontSize: 30, fontWeight: FontWeight.w800)),
                      ]),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Pill('المصدر الأبرز: ${sourceLabels[analysis.source] ?? 'أخرى'}',
                  color: c.primary, icon: Icons.track_changes_rounded),
              const SizedBox(height: 16),
              Text(resultMessages[analysis.level] ?? '',
                  textAlign: TextAlign.center, style: TextStyle(height: 1.75, fontSize: 15.5, color: c.text)),
            ]),
          ),
          const SizedBox(height: 4),
          const Label('خطوتك التالية', icon: Icons.directions_walk_rounded),
          if (suggestHowToSay) ...[howToSay, breathe] else ...[breathe, howToSay],
          ActionTile(
            icon: Icons.support_agent_rounded,
            title: 'جهات الدعم',
            subtitle: 'إذا شعرت أنك تحتاج مساعدة أكبر',
            accent: AppColors.high,
            onTap: () => Navigator.of(context).push(fadeRoute(const SupportScreen())),
          ),
          const Disclaimer('هذه النتيجة للدعم والتوجيه فقط، وليست تشخيصاً طبياً.'),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color, track;
  _RingPainter({required this.progress, required this.color, required this.track});

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 14.0;
    final rect = Offset.zero & size;
    final r = rect.deflate(stroke / 2);
    final bg = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    final fg = Paint()
      ..shader = SweepGradient(
        colors: [color.withValues(alpha: 0.55), color],
        startAngle: -pi / 2,
        endAngle: 3 * pi / 2,
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(r, 0, 2 * pi, false, bg);
    canvas.drawArc(r, -pi / 2, 2 * pi * progress, false, fg);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.progress != progress || old.color != color;
}
