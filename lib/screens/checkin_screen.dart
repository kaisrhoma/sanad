import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../models/profile.dart';
import '../services/gemini_service.dart';
import '../services/store_service.dart';
import '../theme.dart';
import 'analyzing_view.dart';
import 'pulse_screen.dart';
import 'result_screen.dart';
import 'support_screen.dart';
import 'widgets.dart';

class CheckinScreen extends StatefulWidget {
  final Profile profile;
  const CheckinScreen({super.key, required this.profile});
  @override
  State<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends State<CheckinScreen> {
  final _gemini = GeminiService();
  final _store = StoreService();
  final _text = TextEditingController();
  int _mood = 3;
  int _sleep = 3;
  bool _loading = false;

  // ---------- Voice (optional; typing stays the main way) ----------
  static const _maxSeconds = 60;
  final _rec = AudioRecorder();
  Timer? _ticker;
  bool _recording = false;
  bool _listening = false; // true while Gemini analyses a recording
  int _seconds = 0;

  @override
  void dispose() {
    _ticker?.cancel();
    _rec.dispose();
    _text.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    FocusScope.of(context).unfocus();
    try {
      if (!await _rec.hasPermission()) {
        _snack('اسمح لسند باستخدام الميكروفون لتسجيل صوتك');
        return;
      }
      final dir = await getTemporaryDirectory();
      await _rec.start(
        const RecordConfig(encoder: AudioEncoder.wav, sampleRate: 16000, numChannels: 1),
        path: '${dir.path}/sanad_voice.wav',
      );
      setState(() {
        _recording = true;
        _seconds = 0;
      });
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() => _seconds++);
        if (_seconds >= _maxSeconds) _stopAndSend();
      });
    } catch (e) {
      debugPrint('SANAD_ERROR: $e');
      _snack('تعذّر بدء التسجيل على هذا الجهاز');
    }
  }

  Future<void> _cancelRecording() async {
    _ticker?.cancel();
    await _rec.cancel(); // stops and deletes the file
    if (mounted) setState(() => _recording = false);
  }

  Future<void> _stopAndSend() async {
    _ticker?.cancel();
    final path = await _rec.stop();
    setState(() => _recording = false);
    if (path == null) return;
    if (_seconds < 2) {
      await _deleteFile(path);
      _snack('التسجيل قصير جداً، اضغط وتكلم قليلاً');
      return;
    }
    setState(() {
      _loading = true;
      _listening = true;
    });
    try {
      final bytes = await File(path).readAsBytes();
      final r = await _atLeast(_gemini.analyzeVoice(bytes, 'audio/wav', mood: _mood, sleep: _sleep));
      if (!mounted) return;
      if (r.transcript.isEmpty && !r.analysis.risk) {
        _snack('لم نسمعك بوضوح، حاول مرة أخرى في مكان أهدأ');
        return;
      }
      _text.text = r.transcript;
      _store.saveCheckin(widget.profile, r.analysis); // anonymous numbers only
      Navigator.of(context).push(fadeRoute(
        r.analysis.risk
            ? const SupportScreen(emergency: true)
            : ResultScreen(analysis: r.analysis, text: r.transcript),
      ));
    } catch (e) {
      debugPrint('SANAD_ERROR: $e');
      _snack('تعذّر الاتصال الآن. تأكد من الإنترنت وحاول مرة أخرى.');
    } finally {
      await _deleteFile(path); // the recording never stays on the phone
      if (mounted) {
        setState(() {
          _loading = false;
          _listening = false;
        });
      }
    }
  }

  /// Keeps the analysing view up for a short minimum, so a fast answer doesn't flicker.
  static Future<T> _atLeast<T>(Future<T> work, [Duration min = const Duration(milliseconds: 1600)]) async {
    final results = await Future.wait([work, Future<void>.delayed(min)]);
    return results.first as T;
  }

  Future<void> _deleteFile(String path) async {
    try {
      final f = File(path);
      if (await f.exists()) await f.delete();
    } catch (_) {}
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'صباح الخير';
    if (h < 18) return 'نهارك سعيد';
    return 'مساء الخير';
  }

  Future<void> _analyze() async {
    final text = _text.text.trim();
    if (text.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اكتب جملة قصيرة عن يومك أولاً')),
      );
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    try {
      final a = await _atLeast(_gemini.analyze(text, mood: _mood, sleep: _sleep));
      _store.saveCheckin(widget.profile, a); // anonymous numbers only, not awaited
      if (!mounted) return;
      Navigator.of(context).push(fadeRoute(
        a.risk ? const SupportScreen(emergency: true) : ResultScreen(analysis: a, text: text),
      ));
    } catch (e) {
      debugPrint('SANAD_ERROR: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذّر الاتصال الآن. تأكد من الإنترنت وحاول مرة أخرى.')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = Palette.of(context);
    return Scaffold(
      body: Stack(children: [
        ListView(
          padding: EdgeInsets.zero,
          children: [
            GradientHeader(
              title: '$_greeting 👋',
              subtitle: 'خذ نصف دقيقة لنفسك. كيف كان يومك؟',
              actions: [
                const ThemeButton(),
                HeaderIcon(
                  icon: Icons.insights_rounded,
                  tooltip: 'نبض (للجهات)',
                  onTap: () => Navigator.of(context).push(fadeRoute(const PulseScreen())),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                AppCard(
                  child: Column(children: [
                    const Label('مزاجك اليوم', icon: Icons.mood_rounded),
                    EmojiScale(
                      value: _mood,
                      onChanged: (v) => setState(() => _mood = v),
                      emojis: const ['😣', '😕', '😐', '🙂', '😄'],
                      labels: const ['سيئ جداً', 'ليس جيداً', 'عادي', 'جيد', 'ممتاز'],
                    ),
                  ]),
                ),
                AppCard(
                  child: Column(children: [
                    const Label('نومك البارحة', icon: Icons.bedtime_rounded),
                    EmojiScale(
                      value: _sleep,
                      onChanged: (v) => setState(() => _sleep = v),
                      emojis: const ['😫', '😪', '😐', '😌', '😴'],
                      labels: const ['لم أنم تقريباً', 'قليل ومتقطع', 'متوسط', 'جيد', 'مريح جداً'],
                    ),
                  ]),
                ),
                AppCard(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Label('احكيلي على يومك', icon: Icons.edit_note_rounded),
                    TextField(
                      controller: _text,
                      maxLines: 6,
                      minLines: 4,
                      maxLength: 600,
                      decoration: const InputDecoration(
                        hintText: 'اكتب بلهجتك، مثلاً: الامتحانات قربت ومش لاحق نذاكر...',
                      ),
                    ),
                    Row(children: [
                      Icon(Icons.lock_outline_rounded, size: 15, color: c.muted),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text('لا نحفظ ما تكتبه ولا صوتك',
                            style: TextStyle(color: c.muted, fontSize: 12.5)),
                      ),
                    ]),
                    const SizedBox(height: 14),
                    _VoiceBar(
                      recording: _recording,
                      seconds: _seconds,
                      maxSeconds: _maxSeconds,
                      enabled: !_loading,
                      onStart: _startRecording,
                      onSend: _stopAndSend,
                      onCancel: _cancelRecording,
                    ),
                  ]),
                ),
                const SizedBox(height: 4),
                GradientButton(
                  label: 'حلّل يومي',
                  icon: Icons.auto_awesome_rounded,
                  loading: _loading,
                  onPressed: _analyze,
                ),
              ]),
            ),
          ],
        ),
        if (_loading) AnalyzingView(voice: _listening),
      ]),
    );
  }
}

/// Optional voice input: tap the mic, speak up to a minute, then send or cancel.
class _VoiceBar extends StatelessWidget {
  final bool recording, enabled;
  final int seconds, maxSeconds;
  final VoidCallback onStart, onSend, onCancel;
  const _VoiceBar({
    required this.recording,
    required this.seconds,
    required this.maxSeconds,
    required this.enabled,
    required this.onStart,
    required this.onSend,
    required this.onCancel,
  });

  String get _time => '0:${seconds.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final c = Palette.of(context);
    if (!recording) {
      return Material(
        color: c.primary.withValues(alpha: c.isDark ? 0.16 : 0.08),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: enabled ? onStart : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(gradient: c.gradient, shape: BoxShape.circle),
                child: const Icon(Icons.mic_rounded, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('أو احكي بصوتك',
                      style: TextStyle(fontWeight: FontWeight.w700, color: c.text, fontSize: 15)),
                  Text('حتى دقيقة، بلهجتك. يُحذف التسجيل فور التحليل',
                      style: TextStyle(color: c.muted, fontSize: 12.5)),
                ]),
              ),
            ]),
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.high.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.high.withValues(alpha: 0.35)),
      ),
      child: Row(children: [
        const _PulsingDot(),
        const SizedBox(width: 10),
        Text(_time, style: TextStyle(fontWeight: FontWeight.w800, color: c.text, fontSize: 16)),
        const SizedBox(width: 10),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: seconds / maxSeconds,
              minHeight: 6,
              color: AppColors.high,
              backgroundColor: AppColors.high.withValues(alpha: 0.15),
            ),
          ),
        ),
        IconButton(
          tooltip: 'إلغاء',
          onPressed: onCancel,
          icon: Icon(Icons.close_rounded, color: c.muted),
        ),
        IconButton.filled(
          tooltip: 'إرسال',
          style: IconButton.styleFrom(backgroundColor: c.primary),
          onPressed: onSend,
          icon: const Icon(Icons.send_rounded, color: Colors.white),
        ),
      ]),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot();
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
    ..repeat(reverse: true);
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: Tween(begin: 0.3, end: 1.0).animate(_c),
        child: Container(
          width: 12,
          height: 12,
          decoration: const BoxDecoration(color: AppColors.high, shape: BoxShape.circle),
        ),
      );
}
