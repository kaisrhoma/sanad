/// Result returned by Gemini for one daily check-in.
class Analysis {
  final bool risk;
  final String level;   // low | medium | high
  final String source;  // study | work | money | family | relationships | health | other
  final String suggest; // exercise | how_to_say | support

  const Analysis({
    required this.risk,
    required this.level,
    required this.source,
    required this.suggest,
  });

  factory Analysis.fromJson(Map<String, dynamic> j) => Analysis(
        risk: j['risk'] == true,
        level: (j['level'] ?? 'medium') as String,
        source: (j['source'] ?? 'other') as String,
        suggest: (j['suggest'] ?? 'exercise') as String,
      );

  /// Used when the local keyword check finds a risk phrase (no network call).
  static const localRisk =
      Analysis(risk: true, level: 'high', source: 'other', suggest: 'support');

  @override
  String toString() => 'risk=$risk, level=$level, source=$source, suggest=$suggest';
}
