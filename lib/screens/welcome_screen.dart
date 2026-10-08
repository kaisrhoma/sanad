import 'package:flutter/material.dart';

import '../data/options.dart';
import '../models/profile.dart';
import '../theme.dart';
import 'home_shell.dart';
import 'privacy_screen.dart';
import 'widgets.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _p = Profile();
  bool _agree = false;
  bool _adult = false;

  Future<void> _start() async {
    await _p.save();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(fadeRoute(HomeShell(profile: _p)));
  }

  @override
  Widget build(BuildContext context) {
    final c = Palette.of(context);
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ---------- Hero ----------
          Container(
            padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 30, 24, 34),
            decoration: BoxDecoration(
              gradient: c.gradient,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(36)),
            ),
            child: Column(children: [
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: const ThemeButton(),
              ),
              Container(
                width: 104,
                height: 104,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 24, offset: const Offset(0, 8))],
                ),
                child: Image.asset('assets/logo/logo.png'),
              ),
              const SizedBox(height: 14),
              const Text('سند',
                  style: TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.w800, height: 1.1)),
              const SizedBox(height: 6),
              Text('مساحتك الآمنة لتخفيف الضغط، بلهجتك',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 16)),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              // ---------- Welcome (Taha) ----------
              AppCard(
                child: Text(welcomeText, style: TextStyle(color: c.text, height: 1.8, fontSize: 15)),
              ),
              const Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: [
                _Badge(icon: Icons.lock_rounded, text: 'بدون اسم أو حساب'),
                _Badge(icon: Icons.visibility_off_rounded, text: 'لا نحفظ ما تكتبه'),
                _Badge(icon: Icons.health_and_safety_rounded, text: 'ليس تشخيصاً طبياً'),
              ]),
              const SizedBox(height: 22),
              // ---------- Optional questions ----------
              AppCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Label('عرّفنا عليك (اختياري، بدون اسم)', icon: Icons.person_outline_rounded),
                  OptionDropdown(
                      label: 'وضعك الحالي',
                      icon: Icons.work_outline_rounded,
                      options: statusOptions,
                      value: _p.status,
                      onChanged: (v) => setState(() => _p.status = v)),
                  if (_p.status == 'university_student') ...[
                    const SizedBox(height: 12),
                    OptionDropdown(
                        label: 'الجامعة',
                        icon: Icons.school_outlined,
                        options: universityOptions,
                        value: _p.university,
                        onChanged: (v) => setState(() => _p.university = v)),
                  ],
                  const SizedBox(height: 12),
                  OptionDropdown(
                      label: 'الفئة العمرية',
                      icon: Icons.cake_outlined,
                      options: ageOptions,
                      value: _p.ageGroup,
                      onChanged: (v) => setState(() => _p.ageGroup = v)),
                  const SizedBox(height: 12),
                  OptionDropdown(
                      label: 'المدينة',
                      icon: Icons.location_on_outlined,
                      options: cityOptions,
                      value: _p.city,
                      onChanged: (v) => setState(() => _p.city = v)),
                ]),
              ),
              _Check(value: _adult, text: 'عمري 18 سنة أو أكثر', onChanged: (v) => setState(() => _adult = v)),
              _Check(
                  value: _agree,
                  text: 'فهمت أن سند للدعم والتوجيه وليس تشخيصاً طبياً',
                  onChanged: (v) => setState(() => _agree = v)),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  onPressed: () => Navigator.of(context).push(fadeRoute(const PrivacyScreen())),
                  icon: const Icon(Icons.privacy_tip_outlined, size: 18),
                  label: const Text('اقرأ سياسة الخصوصية'),
                ),
              ),
              const SizedBox(height: 8),
              GradientButton(
                label: 'لنبدأ',
                icon: Icons.arrow_forward_rounded,
                onPressed: (_agree && _adult) ? _start : null,
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Badge({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) {
    final c = Palette.of(context);
    return Pill(text, color: c.primary, icon: icon);
  }
}

class _Check extends StatelessWidget {
  final bool value;
  final String text;
  final ValueChanged<bool> onChanged;
  const _Check({required this.value, required this.text, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    final c = Palette.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(children: [
          Checkbox(value: value, onChanged: (v) => onChanged(v ?? false)),
          Expanded(child: Text(text, style: TextStyle(color: c.text))),
        ]),
      ),
    );
  }
}
