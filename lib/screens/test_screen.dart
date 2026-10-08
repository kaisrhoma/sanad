import 'package:flutter/material.dart';

import '../services/gemini_service.dart';

/// Temporary screen for step 1: checks that Gemini answers. Removed in step 2.
class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final _gemini = GeminiService();
  final _controller = TextEditingController(
    text: 'نحس روحي مضغوط واجد، المشروع ما خلصش والمناقشة قريبة، وما نقدرش نقول لبوي إني متأخر.',
  );
  String _output = '';
  bool _loading = false;

  Future<void> _run(Future<String> Function() task) async {
    setState(() { _loading = true; _output = ''; });
    try {
      final r = await task();
      setState(() => _output = r);
    } catch (e, st) {
      debugPrint('SANAD_ERROR: $e');
      debugPrint('SANAD_STACK: $st');
      setState(() => _output = 'خطأ:\n$e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('اختبار Gemini')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(controller: _controller, maxLines: 4),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loading ? null : () => _run(() async =>
                (await _gemini.analyze(_controller.text, mood: 2, sleep: 2)).toString()),
            child: const Text('تحليل الضغط'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _loading ? null : () => _run(() async {
                  final r = await _gemini.compose(_controller.text, 'parent');
                  return '${r.intro}\n\n${r.message}\n\n${r.tip}';
                }),
            child: const Text('صياغة رسالة للوالد'),
          ),
          const SizedBox(height: 20),
          if (_loading) const Center(child: CircularProgressIndicator()),
          SelectableText(_output, style: const TextStyle(fontSize: 15, height: 1.6)),
        ],
      ),
    );
  }
}
