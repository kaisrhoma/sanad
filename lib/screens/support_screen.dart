import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/options.dart';
import '../theme.dart';
import 'breathing_screen.dart';
import 'privacy_screen.dart';
import 'widgets.dart';

/// Works offline: no network call on this screen.
class SupportScreen extends StatelessWidget {
  final bool emergency;
  const SupportScreen({super.key, this.emergency = false});

  /// Places that are open right now come first.
  static List<SupportContact> _sorted() {
    final now = DateTime.now();
    int rank(SupportContact s) => switch (s.isOpen(now)) { true => 0, null => 1, false => 2 };
    final list = [...supportContacts];
    list.sort((a, b) => rank(a).compareTo(rank(b)));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final c = Palette.of(context);
    final canPop = Navigator.of(context).canPop();
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 8, 20, 26),
            decoration: BoxDecoration(
              gradient: emergency
                  ? const LinearGradient(colors: [Color(0xFFEF5D5A), Color(0xFFF2A531)])
                  : c.gradient,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (canPop)
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                ),
              Row(children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                  child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(emergency ? 'نحن معك الآن' : 'الدعم والطوارئ',
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                ),
              ]),
              const SizedBox(height: 12),
              Text(
                emergency ? emergencyText : 'إذا كنت تمر بوقت صعب، تواصل مع شخص تثق به أو مع جهة مختصة. طلب المساعدة قوة.',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.95), height: 1.7, fontSize: 15),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const Label('تواصل الآن', icon: Icons.phone_in_talk_rounded),
              _TrustedPersonCard(),
              ..._sorted().map((s) => _ContactCard(contact: s)),
              const SizedBox(height: 6),
              ActionTile(
                icon: Icons.air_rounded,
                title: 'تنفّس معي الآن',
                subtitle: 'تنفس المربع، دقيقة واحدة',
                accent: c.secondary,
                onTap: () => Navigator.of(context).push(fadeRoute(const BreathingScreen())),
              ),
              const Disclaimer('سند ليس خدمة طوارئ. إذا كنت في خطر مباشر، اطلب المساعدة فوراً من أقرب شخص أو جهة.'),
              Center(
                child: TextButton.icon(
                  onPressed: () => Navigator.of(context).push(fadeRoute(const PrivacyScreen())),
                  icon: const Icon(Icons.privacy_tip_outlined, size: 18),
                  label: const Text('سياسة الخصوصية'),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class _TrustedPersonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = Palette.of(context);
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(color: c.secondary.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(14)),
          child: Icon(Icons.people_alt_rounded, color: c.secondary),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('شخص تثق به', style: TextStyle(fontWeight: FontWeight.w700, color: c.text, fontSize: 15.5)),
            Text('صديق، أحد أفراد الأسرة، أو مرشد جامعتك. مكالمة واحدة قد تغيّر يومك.',
                style: TextStyle(color: c.muted, fontSize: 13, height: 1.5)),
          ]),
        ),
      ]),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final SupportContact contact;
  const _ContactCard({required this.contact});

  @override
  Widget build(BuildContext context) {
    final c = Palette.of(context);
    final open = contact.isOpen(DateTime.now());
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
                color: AppColors.high.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.support_agent_rounded, color: AppColors.high),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(contact.name,
                  style: TextStyle(fontWeight: FontWeight.w700, color: c.text, fontSize: 15.5, height: 1.4)),
              const SizedBox(height: 6),
              Wrap(spacing: 8, runSpacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [
                if (open == true) const Pill('متاح الآن', color: AppColors.low, icon: Icons.circle),
                if (open == false) Pill('مغلق الآن', color: c.muted, icon: Icons.schedule_rounded),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.access_time_rounded, size: 15, color: c.muted),
                  const SizedBox(width: 4),
                  Flexible(child: Text(contact.hours, style: TextStyle(color: c.muted, fontSize: 12.5))),
                ]),
              ]),
            ]),
          ),
        ]),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final p in contact.phones)
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.low,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () => launchUrl(Uri(scheme: 'tel', path: p.number)),
              icon: const Icon(Icons.call_rounded, size: 18),
              label: Text(p.label.isEmpty ? 'اتصال' : p.label),
            ),
          if (contact.url != null)
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () => launchUrl(Uri.parse(contact.url!), mode: LaunchMode.externalApplication),
              icon: const Icon(Icons.open_in_new_rounded, size: 18),
              label: const Text('الصفحة'),
            ),
        ]),
      ]),
    );
  }
}
