import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/gemini_service.dart';
import '../theme.dart';
import 'widgets.dart';

class HowToSayScreen extends StatefulWidget {
  final String text;
  const HowToSayScreen({super.key, required this.text});
  @override
  State<HowToSayScreen> createState() => _HowToSayScreenState();
}

class _HowToSayScreenState extends State<HowToSayScreen> {
  static const _people = [
    ('parent', 'أحد الوالدين', Icons.family_restroom_rounded),
    ('friend', 'صديق مقرّب', Icons.people_alt_rounded),
    ('manager', 'المدير في العمل', Icons.work_rounded),
    ('professor', 'أستاذ في الجامعة', Icons.school_rounded),
    ('counselor', 'مرشد أو مختص', Icons.health_and_safety_rounded),
  ];

  final _gemini = GeminiService();
  final _msg = TextEditingController();
  String? _to;
  String _intro = '';
  String _tip = '';
  int _version = 0; // bumps on each new suggestion to replay the reveal animation
  bool _loading = false;

  Future<void> _compose(String to) async {
    setState(() {
      _to = to;
      _loading = true;
    });
    try {
      final r = await _gemini.compose(widget.text, to);
      _msg.text = r.message;
      _intro = r.intro;
      _tip = r.tip;
      _version++;
    } catch (e) {
      debugPrint('SANAD_ERROR: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذّر إنشاء الرسالة الآن، حاول مرة أخرى.')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = Palette.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('كيف نقولها؟')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
        children: [
          Text('أحياناً أصعب خطوة هي البداية.',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: c.text)),
          const SizedBox(height: 4),
          Text('اختر الشخص الذي تريد أن تتحدث معه، وسنقترح عليك رسالة تبدأ بها.',
              style: TextStyle(color: c.muted, height: 1.6)),
          const SizedBox(height: 18),
          LayoutBuilder(builder: (context, box) {
            final half = (box.maxWidth - 12) / 2;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: List.generate(_people.length, (i) {
                final p = _people[i];
                final sel = _to == p.$1;
                final last = i == _people.length - 1 && _people.length.isOdd;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: last ? box.maxWidth : half,
                  height: 96,
                  decoration: BoxDecoration(
                    gradient: sel ? c.gradient : null,
                    color: sel ? null : c.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: sel ? Colors.transparent : c.border),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: _loading ? null : () => _compose(p.$1),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(p.$3, size: 28, color: sel ? Colors.white : c.primary),
                        const SizedBox(height: 8),
                        Text(p.$2,
                            style: TextStyle(
                                fontWeight: FontWeight.w700, color: sel ? Colors.white : c.text, fontSize: 14.5)),
                      ]),
                    ),
                  ),
                );
              }),
            );
          }),
          const SizedBox(height: 22),
          if (_loading) const _MessageSkeleton(),
          if (!_loading && _msg.text.isNotEmpty) TweenAnimationBuilder<double>(
            key: ValueKey(_version),
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeOutCubic,
            builder: (_, v, child) => Opacity(
              opacity: v,
              child: Transform.translate(offset: Offset(0, 16 * (1 - v)), child: child),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            if (_intro.isNotEmpty) ...[
              Text(_intro, style: TextStyle(color: c.text, height: 1.6, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
            ],
            const Label('رسالتك المقترحة (يمكنك تعديلها)', icon: Icons.mark_chat_unread_rounded),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: c.primary.withValues(alpha: c.isDark ? 0.16 : 0.08),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(22),
                  topRight: Radius.circular(22),
                  bottomLeft: Radius.circular(22),
                  bottomRight: Radius.circular(6),
                ),
              ),
              child: TextField(
                controller: _msg,
                maxLines: null,
                style: TextStyle(height: 1.7, fontSize: 15.5, color: c.text),
                decoration: const InputDecoration(
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            if (_tip.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.medium.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(Icons.lightbulb_rounded, color: AppColors.medium, size: 22),
                  const SizedBox(width: 10),
                  Expanded(child: Text(_tip, style: TextStyle(color: c.text, height: 1.6, fontSize: 14))),
                ]),
              ),
            ],
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                child: GradientButton(
                  label: 'نسخ الرسالة',
                  icon: Icons.copy_rounded,
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _msg.text));
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text('تم النسخ، أرسلها عندما تكون جاهزاً 💙')));
                  },
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 56,
                width: 56,
                child: IconButton.outlined(
                  tooltip: 'اقتراح آخر',
                  onPressed: () => _compose(_to!),
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ),
            ]),
            ]),
          ),
          const Disclaimer('لا نحفظ هذه الرسالة. أنت من يقرر متى وكيف ترسلها.'),
        ],
      ),
    );
  }
}

/// Placeholder shaped like the final message, with a soft shimmer, shown while Gemini writes.
class _MessageSkeleton extends StatefulWidget {
  const _MessageSkeleton();
  @override
  State<_MessageSkeleton> createState() => _MessageSkeletonState();
}

class _MessageSkeletonState extends State<_MessageSkeleton> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1300))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Widget _bar(Palette c, double widthFactor, double height) => FractionallySizedBox(
        alignment: AlignmentDirectional.centerStart,
        widthFactor: widthFactor,
        child: Container(
          height: height,
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(color: c.surface2, borderRadius: BorderRadius.circular(8)),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final c = Palette.of(context);
    final base = c.surface2;
    final shine = c.isDark ? const Color(0xFF2C3242) : Colors.white;
    return AnimatedBuilder(
      animation: _c,
      builder: (_, child) => ShaderMask(
        blendMode: BlendMode.srcATop,
        shaderCallback: (r) => LinearGradient(
          colors: [base, shine, base],
          stops: const [0.25, 0.5, 0.75],
          begin: Alignment(-1.5 + 3 * _c.value, 0),
          end: Alignment(-0.5 + 3 * _c.value, 0),
        ).createShader(r),
        child: child,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _bar(c, 0.7, 14),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: c.primary.withValues(alpha: c.isDark ? 0.10 : 0.05),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(22),
              topRight: Radius.circular(22),
              bottomLeft: Radius.circular(22),
              bottomRight: Radius.circular(6),
            ),
          ),
          child: Column(children: [_bar(c, 1, 12), _bar(c, 0.92, 12), _bar(c, 0.6, 12)]),
        ),
        const SizedBox(height: 12),
        _bar(c, 0.85, 40),
      ]),
    );
  }
}
