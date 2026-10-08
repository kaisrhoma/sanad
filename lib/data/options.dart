/// Lists and texts used across the app.

class Option {
  final String id;
  final String label;
  const Option(this.id, this.label);
}

const String skip = 'unknown';

const statusOptions = [
  Option('university_student', 'طالب جامعي'),
  Option('institute_student', 'طالب معهد أو تدريب مهني'),
  Option('graduate_job_seeking', 'خريج أبحث عن عمل'),
  Option('employee', 'موظف'),
  Option('freelance', 'أعمل لحسابي / عمل حر'),
  Option('not_working_or_studying', 'لا أدرس ولا أعمل حالياً'),
  Option(skip, 'أفضّل عدم الإجابة'),
];

const ageOptions = [
  Option('18-24', '18 – 24'),
  Option('25-30', '25 – 30'),
  Option('31-35', '31 – 35'),
  Option(skip, 'أفضّل عدم الإجابة'),
];

// Cities: west, east, south (Taha's list).
const cityOptions = [
  Option('tripoli', 'طرابلس'),
  Option('misrata', 'مصراتة'),
  Option('zawiya', 'الزاوية'),
  Option('zliten', 'زليتن'),
  Option('gharyan', 'غريان'),
  Option('khoms', 'الخمس'),
  Option('sabratha', 'صبراتة'),
  Option('zuwara', 'زوارة'),
  Option('tarhuna', 'ترهونة'),
  Option('baniwalid', 'بني وليد'),
  Option('ghadames', 'غدامس'),
  Option('zintan', 'الزنتان'),
  Option('yafran', 'يفرن'),
  Option('sirte', 'سرت'),
  Option('benghazi', 'بنغازي'),
  Option('bayda', 'البيضاء'),
  Option('tobruk', 'طبرق'),
  Option('derna', 'درنة'),
  Option('marj', 'المرج'),
  Option('ajdabiya', 'أجدابيا'),
  Option('shahat', 'شحات'),
  Option('sabha', 'سبها'),
  Option('ubari', 'أوباري'),
  Option('murzuq', 'مرزق'),
  Option('ghat', 'غات'),
  Option('kufra', 'الكفرة'),
  Option('brak', 'براك الشاطئ'),
  Option('other', 'مدينة أخرى'),
  Option(skip, 'أفضّل عدم الإجابة'),
];

// Universities: public then private (Taha's list).
const universityOptions = [
  Option('uot', 'جامعة طرابلس'),
  Option('uob', 'جامعة بنغازي'),
  Option('misurata', 'جامعة مصراتة'),
  Option('zawiya', 'جامعة الزاوية'),
  Option('asmarya', 'الجامعة الأسمرية الإسلامية (زليتن)'),
  Option('elmergib', 'جامعة المرقب (الخمس)'),
  Option('gharyan', 'جامعة غريان'),
  Option('zintan', 'جامعة الزنتان'),
  Option('sabratha', 'جامعة صبراتة'),
  Option('sirte', 'جامعة سرت'),
  Option('baniwalid', 'جامعة بني وليد'),
  Option('azzaytuna', 'جامعة الزيتونة (ترهونة)'),
  Option('nalut', 'جامعة نالوت'),
  Option('jfara', 'جامعة الجفارة'),
  Option('sidra', 'جامعة خليج السدرة (بن جواد)'),
  Option('omar', 'جامعة عمر المختار (البيضاء)'),
  Option('tobruk', 'جامعة طبرق'),
  Option('derna', 'جامعة درنة'),
  Option('ajdabiya', 'جامعة أجدابيا'),
  Option('marj', 'جامعة المرج'),
  Option('ashhab', 'جامعة بئر الأشهب'),
  Option('sati', 'جامعة النجم الساطع (البريقة)'),
  Option('sebha', 'جامعة سبها'),
  Option('fezzan', 'جامعة فزان (مرزق)'),
  Option('shatti', 'جامعة وادي الشاطئ (براك الشاطئ)'),
  Option('jufra', 'جامعة الجفرة (هون)'),
  Option('open', 'الجامعة المفتوحة'),
  Option('limu', 'الجامعة الليبية الدولية للعلوم الطبية (بنغازي)'),
  Option('tripoli_private', 'جامعة طرابلس الأهلية'),
  Option('africa', 'جامعة إفريقيا للعلوم الإنسانية والتطبيقية'),
  Option('rifaq', 'جامعة الرفاق'),
  Option('hadera', 'جامعة الحاضرة للعلوم الإنسانية والتطبيقية'),
  Option('tahadi', 'جامعة التحدي للعلوم الطبية'),
  Option('libyan_hum', 'الجامعة الليبية للعلوم الإنسانية والتطبيقية'),
  Option('asima', 'جامعة العاصمة الأهلية'),
  Option('marifa', 'جامعة المعرفة للعلوم الإنسانية والتطبيقية'),
  Option('saraya', 'جامعة السرايا الحمراء'),
  Option('belagrae', 'جامعة بلاغراي للعلوم الحديثة (بنغازي)'),
  Option('med_intl', 'جامعة البحر المتوسط الدولية'),
  Option('bernice', 'جامعة برنيتشي (بنغازي)'),
  Option('benghazi_private', 'جامعة بنغازي الأهلية'),
  Option('manara', 'جامعة المنارة الأهلية (مصراتة)'),
  Option('razi', 'جامعة الرازي (مصراتة)'),
  Option('qurtuba', 'جامعة قرطبة'),
  Option('maarif', 'جامعة المعارف الدولية'),
  Option('lebda', 'جامعة لبدة الأهلية'),
  Option('riyada', 'جامعة الريادة'),
  Option('qalam', 'جامعة القلم'),
  Option('sahwa', 'جامعة الصحوة'),
  Option('sarh', 'جامعة صرح المستقبل'),
  Option('nahda', 'جامعة النهضة'),
  Option('arab_med', 'جامعة العرب الطبية الأهلية'),
  Option('hadath', 'جامعة الحدث الأهلية'),
  Option('ibnkhaldun', 'جامعة ابن خلدون'),
  Option('zawiya_private', 'جامعة الزاوية الأهلية'),
  Option('hidaya', 'جامعة الهداية الأهلية'),
  Option('other', 'جامعة أو معهد آخر'),
  Option(skip, 'أفضّل عدم الإجابة'),
];

const sourceLabels = {
  'study': 'الدراسة',
  'work': 'العمل',
  'money': 'الضغط المادي',
  'family': 'الأسرة',
  'relationships': 'العلاقات',
  'health': 'الصحة',
  'other': 'أخرى',
};

const levelLabels = {'low': 'منخفض', 'medium': 'متوسط', 'high': 'مرتفع'};

String labelOf(List<Option> list, String id) =>
    list.firstWhere((o) => o.id == id, orElse: () => const Option('', '—')).label;

// ---------------- Texts (reviewed by Taha) ----------------
const welcomeText =
    'أهلاً بك في مساحتك الآمنة. صُمم هذا التطبيق ليسمعك ويساعدك على تفريغ ضغط اليوم، '
    'وهو مخصص للشباب (18 سنة فما فوق). نحن هنا لتقديم الدعم اليومي وليس التشخيص الطبي. '
    'راحتك وخصوصيتك هي الأساس؛ لا نطلب اسمك، ولا نحفظ أي حرف تكتبه. خود راحتك، واكتب اللي في خاطرك.';

const resultMessages = {
  'low': 'باين إن يومك كان هادي ومستقر. استمر في روتينك، ومتنساش تاخذ وقت لنفسك وتكافئها على المجهود البسيط.',
  'medium': 'شكلها الأيام دي فيها شوية ضغط. هذا طبيعي، حاول تاخذ راحة قصيرة وتفصل، وجرب أحد تمارين التنفس هنا لتجديد طاقتك.',
  'high': 'واضح إنك تمر بفترة صعبة ومضغوط هلبا. تذكر إنك مش مضطر تشيل الحمل بروحك. '
      'جرب ميزة "كيف نقولها؟" عشان ترتب أفكارك، وشارك اللي تحس بيه مع شخص تثق فيه.',
};

const emergencyText =
    'في أوقات نحسوا فيها إن الحمل ثقيل هلبا ولا يمكن احتماله، وهذا شعور يمر بيه الكثيرون. '
    'أرجوك، لا تبقَ وحدك في هذه اللحظة. التحدث مع شخص تثق فيه أو التواصل مع جهة متخصصة يمثل خطوة شجاعة ومهمة. '
    'الجهات أدناه متاحة لتسمعك وتساعدك بسرية تامة.';

class Exercise {
  final String title;
  final String duration;
  final List<String> steps;
  const Exercise(this.title, this.duration, this.steps);
}

// Exercises for stress, each under two minutes (Taha).
const exercises = [
  Exercise('تنفس المربع', 'دقيقة', [
    'خذ نفساً عميقاً من أنفك مع العد لـ 4.',
    'احبس أنفاسك مع العد لـ 4.',
    'أخرج الهواء ببطء من فمك مع العد لـ 4.',
    'انتظر بدون تنفس مع العد لـ 4. كرر الخطوات 4 مرات.',
  ]),
  Exercise('تقنية 3-2-1 للحواس', 'دقيقة', [
    'سمِّ 3 أشياء تراها حولك الآن (مثلاً: طاولة، شباك).',
    'سمِّ شيئين يمكنك لمسهما، وركز على ملمسهما (مثلاً: قماش ملابسك، سطح المكتب).',
    'سمِّ شيئاً واحداً تسمعه الآن بوضوح.',
  ]),
  Exercise('الاسترخاء العضلي السريع', 'نصف دقيقة', [
    'ارفع كتفيك للأعلى باتجاه أذنيك وشدهما بقوة لمدة 5 ثوانٍ.',
    'أرخِ كتفيك فجأة واترك التوتر يخرج مع زفير طويل من فمك.',
    'كررها 3 مرات.',
  ]),
  Exercise('التنفس البطني العميق', 'دقيقة', [
    'ضع يداً على صدرك والأخرى على بطنك.',
    'تنفس ببطء من أنفك؛ اجعل بطنك ينتفخ بينما يبقى صدرك ثابتاً.',
    'أخرج الهواء ببطء شديد وتخيل أن التوتر يخرج معه.',
  ]),
  Exercise('تغيير التركيز الحركي', 'نصف دقيقة', [
    'قف على قدميك، وافرد ظهرك تماماً.',
    'هز يديك وقدميك برفق لمدة 30 ثانية لتنشيط الدورة الدموية وتشتيت التركيز عن التوتر.',
  ]),
];

class SupportPhone {
  final String label; // e.g. branch name, empty if only one number
  final String number;
  const SupportPhone(this.number, [this.label = '']);
}

class SupportContact {
  final String name;
  final String hours;
  final List<SupportPhone> phones;
  final String? url;
  final String? source;
  /// Opening rule used for the "open now" badge. weekdays: DateTime.monday..sunday.
  final List<int>? openDays;
  final int? openHour, closeHour; // 24h, local time; null with openDays == null means unknown
  final bool alwaysOpen;
  const SupportContact({
    required this.name,
    required this.hours,
    this.phones = const [],
    this.url,
    this.source,
    this.openDays,
    this.openHour,
    this.closeHour,
    this.alwaysOpen = false,
  });

  /// true / false, or null when the hours are not fixed.
  bool? isOpen(DateTime now) {
    if (alwaysOpen) return true;
    if (openDays == null || openHour == null || closeHour == null) return null;
    return openDays!.contains(now.weekday) && now.hour >= openHour! && now.hour < closeHour!;
  }
}

const _allButFriday = [
  DateTime.saturday, DateTime.sunday, DateTime.monday, DateTime.tuesday, DateTime.wednesday, DateTime.thursday,
];

// Verified by Taha (October 2026). Keep the source for each entry.
const supportContacts = [
  SupportContact(
    name: 'فريق الدعم النفسي الاجتماعي - ليبيا (الخط الساخن)',
    hours: 'يومياً عدا الجمعة، 8 صباحاً – 8 مساءً',
    phones: [SupportPhone('0915555973')],
    url: 'https://www.facebook.com/100072367820925/',
    source: 'صندوق الأمم المتحدة للسكان ووزارة الشؤون الاجتماعية',
    openDays: _allButFriday,
    openHour: 8,
    closeHour: 20,
  ),
  SupportContact(
    name: 'مستشفى الرازي للأمراض النفسية والعصبية',
    hours: 'على مدار 24 ساعة طوال الأسبوع',
    phones: [SupportPhone('+218214771900')],
    url: 'https://share.google/i6A8eInQuF8LGoMGk',
    source: 'وزارة الصحة الليبية',
    alwaysOpen: true,
  ),
  SupportContact(
    name: 'مصحة وعيادة الأمل للعلاج والتأهيل النفسي - بنغازي',
    hours: 'السبت إلى الخميس، 9 صباحاً – 8 مساءً',
    phones: [SupportPhone('0944020930', 'فرع القوارشة'), SupportPhone('0925328703', 'فرع امتداد شارع 20')],
    url: 'https://www.facebook.com/100067321760209/',
    openDays: _allButFriday,
    openHour: 9,
    closeHour: 20,
  ),
  SupportContact(
    name: 'الهلال الأحمر الليبي - بنغازي (وحدة الدعم النفسي والاجتماعي)',
    hours: 'تختلف حسب جداول التدريب وحالات الطوارئ',
    // TODO(Taha): the number (+218 21 444 4444) needs a second check before adding a call button.
    url: 'https://lrc.org.ly/',
  ),
];

