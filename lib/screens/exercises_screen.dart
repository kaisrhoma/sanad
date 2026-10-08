import 'package:flutter/material.dart';

import '../data/options.dart';
import '../theme.dart';
import 'breathing_screen.dart';
import 'widgets.dart';

class ExercisesScreen extends StatelessWidget {
  const ExercisesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Palette.of(context);
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          const GradientHeader(title: 'تمارين تهدئة', subtitle: 'خطوات قصيرة تساعدك تهدأ الآن'),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
            child: Column(children: [
              // featured guided breathing
              AppCard(
                onTap: () => Navigator.of(context).push(fadeRoute(const BreathingScreen())),
                color: c.primary.withValues(alpha: c.isDark ? 0.18 : 0.10),
                child: Row(children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(gradient: c.gradient, shape: BoxShape.circle),
                    child: const Icon(Icons.air_rounded, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('تنفّس موجّه', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: c.text)),
                      Text('تنفس المربع مع دائرة تتنفس معك، دقيقة واحدة', style: TextStyle(color: c.muted)),
                    ]),
                  ),
                  Icon(Icons.play_circle_fill_rounded, color: c.primary, size: 34),
                ]),
              ),
              ...exercises.map((ex) => AppCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                              color: c.secondary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
                          child: Icon(Icons.spa_rounded, color: c.secondary),
                        ),
                        title: Text(ex.title, style: TextStyle(fontWeight: FontWeight.w700, color: c.text)),
                        subtitle: Text(ex.duration, style: TextStyle(color: c.muted)),
                        children: [
                          for (var i = 0; i < ex.steps.length; i++)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                CircleAvatar(
                                  radius: 12,
                                  backgroundColor: c.primary,
                                  child: Text('${i + 1}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                    child: Text(ex.steps[i], style: TextStyle(height: 1.55, color: c.text))),
                              ]),
                            ),
                        ],
                      ),
                    ),
                  )),
            ]),
          ),
        ],
      ),
    );
  }
}
