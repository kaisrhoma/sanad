/// Local, offline safety check that runs BEFORE any network call.
/// Phrases reviewed by Taha (Libyan dialect + MSA), plus Radwan's critical triggers.
///
/// Two tiers:
/// - [riskPhrases]: explicit self-harm / wish to die. Matched anywhere -> support screen immediately,
///   even with no internet.
/// - [concernPhrases]: hopelessness or common expressions that are risky only in context
///   (e.g. "بنموت" is also said about hunger or laughter). These do NOT bypass Gemini, which
///   judges the context with its own risk rules; they are used only when Gemini cannot be reached.
class Safety {
  static const List<String> riskPhrases = [
    'انتحار',
    'إنتحار',
    'إنهاء حياتي',
    'انهاء حياتي',
    'لا أريد العيش',
    'لا اريد العيش',
    'أتخلص من نفسي',
    'أؤذي نفسي',
    'اوذي نفسي',
    'اذي نفسي',
    'أضع حداً لحياتي',
    'اضع حدا لحياتي',
    'اضع حد لحياتي',
    'أقتل نفسي',
    'اقتل نفسي',
    'أتخلص من حياتي',
    'اتخلص من حياتي',
    'أقطع شراييني',
    'اقطع شراييني',
    'أتمنى ألا أستيقظ',
    'اتمنى الا استيقظ',
    'اتمني ان لا استيقظ',
    'يا ليتني أموت',
    'ياليتني اموت',
    'ليتني اموت',
    'النوم للأبد',
    'النوم للابد',
    'الراحة الأبدية',
    'الراحه الابديه',
    'أرتاح من الحياة',
    'ارتاح من الحياه',
    'وداعاً للجميع',
    'وداعا للجميع',
    'رسالة وداع',
    'رساله وداع',
    'سيكونون أفضل بدوني',
    'سيكونون افضل بدوني',
    'حياتهم احسن بدوني',
    'لا فائدة من العيش',
    'لا فايدة من العيش',
    'نبي نموت',
    'بنقتل روحي',
    'نقتل روحي',
    'بننتحر',
    'نبي ننتحر',
    'معاش نبي نعيش',
    'ماعاش نبي نعيش',
    'ما عادش نبي نعيش',
    'بننهي حياتي',
    'ننهي حياتي',
    'بنجرح روحي',
    'بنقطع عروقي',
    'بنأذي روحي',
    'ناذي روحي',
    'نبي نرقد ومعاش نوض',
    'نرقد ومعادش نوض',
    'نتمنى نرقد وما عادش ننوض',
    'ياريتني نموت',
    'ياريتني متت',
    'خيرلهم بلا بيا',
    'خيرلهم من غيري',
    'حياتهم أحسن من غيري',
    'بندير في روحي حاجة',
    'بندير في روحي حاجه',
    'ندير في روحي حاجة',
    'بنهلك روحي',
    'بنريح روحي من هالدنيا',
    'بنلوح روحي من اعلى مكان',
    'نلوح روحي من الكوبري',
    'نفتك من روحي',
    'نشنق روحي',
    'نرقد في البحر',
    'نشرب حبوب ونرتاح',
  ];

  static const List<String> concernPhrases = [
    'الموت',
    'يأس شديد',
    'جرعة زائدة',
    'جرعه زايده',
    'جرعه زائدة',
    'إنهاء العذاب',
    'انهاء العذاب',
    'انهي عذابي',
    'نهاية كل شيء',
    'نهايه كل شيء',
    'نهاية كل شي',
    'أريد أن أختفي',
    'اريد ان اختفي',
    'اتمنى الاختفاء',
    'ارتاح من كل هذا',
    'أنا عبء على الجميع',
    'انا عبئ على الجميع',
    'عالة على اهلي',
    'عاله',
    'لا أمل',
    'لا امل',
    'فقدت الامل',
    'لا فائده',
    'لا أستطيع التحمل أكثر',
    'لا استطيع التحمل اكثر',
    'ألم لا يحتمل',
    'الم لا يحتمل',
    'عذاب مستمر',
    'طريق مسدود',
    'الطريق مسدود',
    'مفيش مخرج',
    'بنموت',
    'كرهت حياتي',
    'كرهت عيشتي',
    'نبي نفتك',
    'مليت من الدنيا',
    'مفيش فايدة',
    'مافيش فايده',
    'نبي نختفي',
    'نبي نرتاح من هالدنيا',
    'حاس روحي حمل عليهم',
    'حاس روحي عالة',
    'عالة عليهم',
    'سكرت في وجهي',
    'معادش نقدر نتحمل',
    'معاش نقدر نتحمل',
    'طابت روحي',
    'معادش فيها',
    'بنهج ومعاش بنولي',
    'بنفجر راسي',
  ];

  /// Normalises common Arabic spelling variants so matching is more robust.
  static String normalize(String s) {
    return s
        .replaceAll(RegExp('[أإآ]'), 'ا')
        .replaceAll('ؤ', 'و')
        .replaceAll('ئ', 'ي')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي')
        .replaceAll('ـ', '') // tatweel
        .replaceAll(RegExp(r'[\u064B-\u0652]'), '') // diacritics
        .replaceAll(RegExp(r'[^\u0600-\u06FFa-zA-Z0-9]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static final _risk = riskPhrases.map(normalize).toList();
  static final _concern = concernPhrases.map(normalize).toList();

  /// Explicit risk: substring match (safety first).
  static bool containsRisk(String text) {
    final t = normalize(text);
    return _risk.any(t.contains);
  }

  /// Softer signals: whole-word match, so "عاله" does not match inside "فعاله".
  static bool containsConcern(String text) {
    final t = ' ${normalize(text)} ';
    return _concern.any((p) => t.contains(' $p '));
  }
}
