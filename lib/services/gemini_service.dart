import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_ai/firebase_ai.dart';

import '../models/analysis.dart';
import 'prompts.dart';
import 'safety.dart';

/// All calls to Gemini go through this class (Firebase AI Logic, no API key in the app).
class GeminiService {
  // Main model first; the lighter model is used automatically if the main one is busy (503) or slow.
  static const models = ['gemini-3.8-flash', 'gemini-3.5-flash-lite'];
  static const _timeout = Duration(seconds: 15);

  static final _schema = Schema.object(properties: {
    'risk': Schema.boolean(),
    'level': Schema.enumString(enumValues: ['low', 'medium', 'high']),
    'source': Schema.enumString(enumValues: [
      'study', 'work', 'money', 'family', 'relationships', 'health', 'other'
    ]),
    'suggest': Schema.enumString(enumValues: ['exercise', 'how_to_say', 'support']),
  });

  static final _composeSchema = Schema.object(properties: {
    'intro': Schema.string(),
    'suggested_message': Schema.string(),
    'delivery_tip': Schema.string(),
  });

  static final _voiceSchema = Schema.object(properties: {
    'transcript': Schema.string(),
    'risk': Schema.boolean(),
    'level': Schema.enumString(enumValues: ['low', 'medium', 'high']),
    'source': Schema.enumString(enumValues: [
      'study', 'work', 'money', 'family', 'relationships', 'health', 'other'
    ]),
    'suggest': Schema.enumString(enumValues: ['exercise', 'how_to_say', 'support']),
  });

  static const _voiceNote = '''

ملاحظة للمدخل الصوتي: المدخل هنا تسجيل صوتي قصير باللهجة الليبية بدل النص.
1) اكتب في الحقل transcript ما قاله المتكلم كما قاله بالحروف العربية، واستبدل أي اسم شخص بـ [اسم] وأي رقم هاتف بـ [رقم].
2) إذا كان التسجيل صامتاً أو غير مفهوم فاجعل transcript فارغاً و level = "low".
3) طبّق على الكلام نفس القواعد السابقة كاملة، وخاصة قواعد الخطر.
''';

  GenerativeModel _voiceAnalyzerFor(String name) => FirebaseAI.googleAI().generativeModel(
        model: name,
        systemInstruction: Content.system(Prompts.analyze + _voiceNote),
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          responseSchema: _voiceSchema,
          temperature: 0.2,
        ),
      );

  GenerativeModel _analyzerFor(String name) => FirebaseAI.googleAI().generativeModel(
        model: name,
        systemInstruction: Content.system(Prompts.analyze),
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          responseSchema: _schema,
          temperature: 0.2,
        ),
      );

  GenerativeModel _composerFor(String name) => FirebaseAI.googleAI().generativeModel(
        model: name,
        systemInstruction: Content.system(Prompts.compose),
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          responseSchema: _composeSchema,
          temperature: 0.7,
        ),
      );

  /// Tries each model in order; moves to the next one on busy/timeout errors.
  Future<String> _generate(GenerativeModel Function(String) build, String prompt) =>
      _generateContent(build, [Content.text(prompt)]);

  Future<String> _generateContent(GenerativeModel Function(String) build, List<Content> content) async {
    Object? lastError;
    for (final name in models) {
      try {
        final res = await build(name)
            .generateContent(content)
            .timeout(_timeout);
        final text = res.text;
        if (text != null && text.trim().isNotEmpty) return text;
      } catch (e) {
        lastError = e;
        // ignore: avoid_print
        print('SANAD_MODEL_FAIL [$name]: $e');
      }
    }
    throw lastError ?? Exception('No response from Gemini');
  }

  /// Removes obvious personal data (phone numbers, emails) before sending.
  static String _scrub(String s) => s
      .replaceAll(RegExp(r'\+?\d[\d\s-]{6,}'), '[رقم]')
      .replaceAll(RegExp(r'\S+@\S+'), '[بريد]');

  Future<Analysis> analyze(String text, {int? mood, int? sleep}) async {
    // 1) Offline safety check first
    if (Safety.containsRisk(text)) return Analysis.localRisk;

    // 2) Gemini
    final prompt = 'المزاج (1-5): ${mood ?? '-'}\nالنوم (1-5): ${sleep ?? '-'}\nالنص: ${_scrub(text)}';
    try {
      final raw = await _generate(_analyzerFor, prompt);
      return Analysis.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      // 3) No answer from Gemini: if the text has softer warning signs, stay on the safe side.
      if (Safety.containsConcern(text)) return Analysis.localRisk;
      rethrow;
    }
  }

  /// Voice check-in: Gemini listens to the recording, writes the transcript and analyses it
  /// in one call. The local safety check then runs on the transcript as well.
  Future<VoiceResult> analyzeVoice(Uint8List audio, String mimeType, {int? mood, int? sleep}) async {
    final content = [
      Content.multi([
        TextPart('المزاج (1-5): ${mood ?? '-'}\nالنوم (1-5): ${sleep ?? '-'}\nالمدخل: تسجيل صوتي'),
        InlineDataPart(mimeType, audio),
      ]),
    ];
    final raw = await _generateContent(_voiceAnalyzerFor, content);
    final j = jsonDecode(raw) as Map<String, dynamic>;
    final transcript = (j['transcript'] ?? '').toString().trim();
    if (Safety.containsRisk(transcript)) return VoiceResult(Analysis.localRisk, transcript);
    return VoiceResult(Analysis.fromJson(j), transcript);
  }

  /// Recipient ids used by the app, mapped to the exact values in Radwan's instructions.
  static const recipients = {
    'parent': 'أحد الوالدين',
    'friend': 'صديق مقرب',
    'manager': 'مدير في العمل / صاحب الشغل',
    'professor': 'أستاذ / دكتور في الجامعة',
    'counselor': 'مرشد نفسي / مختص',
  };

  Future<ComposeResult> compose(String text, String to) async {
    final prompt = 'target_recipient: ${recipients[to] ?? to}\nuser_problem: ${_scrub(text)}';
    final raw = await _generate(_composerFor, prompt);
    return ComposeResult.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }
}

class ComposeResult {
  final String intro, message, tip;
  const ComposeResult({required this.intro, required this.message, required this.tip});

  static String _clean(Object? v) =>
      (v ?? '').toString().trim().replaceAll(RegExp('^["«“]+|["»”]+\$'), '').trim();

  factory ComposeResult.fromJson(Map<String, dynamic> j) => ComposeResult(
        intro: _clean(j['intro']),
        message: _clean(j['suggested_message']),
        tip: _clean(j['delivery_tip']),
      );
}

class VoiceResult {
  final Analysis analysis;
  final String transcript;
  const VoiceResult(this.analysis, this.transcript);
}
