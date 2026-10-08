import 'package:flutter/material.dart';

import '../theme.dart';
import 'widgets.dart';

/// Privacy policy (text by Taha).
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  static const _sections = [
    (
      Icons.person_off_rounded,
      'عدم جمع البيانات الشخصية',
      [
        'لا نطلب ولا نجمع أي بيانات تحدد هويتك الشخصية، مثل: الاسم، رقم الهاتف، البريد الإلكتروني، الحسابات الشخصية، أو الموقع الجغرافي الدقيق (GPS).',
        'بدون تسجيل حساب: يمكنك استخدام التطبيق والاستفادة من خدماته فوراً دون الحاجة لإنشاء حساب أو إدخال أي معلومات تعريفية.',
      ],
    ),
    (
      Icons.auto_awesome_rounded,
      'معالجة النصوص والذكاء الاصطناعي',
      [
        'معالجة لحظية عابرة: النصوص واليوميات التي تكتبها باللهجة المحلية، والتسجيلات الصوتية إن استخدمتها، يتم تحليلها لحظياً عبر تقنيات الذكاء الاصطناعي (Gemini عبر Firebase AI Logic) لتقديم التوجيه المناسب في نفس اللحظة.',
        'عدم التخزين إطلاقاً: لا يتم حفظ، تخزين، أو أرشفة أي نص أو كلمة تكتبها أو تسجيل صوتي في قواعد بياناتنا بعد انتهاء التحليل اللحظي، ويُحذف التسجيل الصوتي من هاتفك فور التحليل.',
      ],
    ),
    (
      Icons.bar_chart_rounded,
      'البيانات الإحصائية المجمعة',
      [
        'لغرض تقديم الخدمة وفهم التوجهات العامة، نقتصر على تسجيل خيارات مجهولة الهوية تماماً تشمل:',
        '• الفئة العمرية (للمستخدمين من سن 18 سنة فما فوق).',
        '• الوضع الحالي (دراسة أو عمل) والجامعة والمدينة، إن اخترت ذكرها.',
        '• مستوى الضغط النفسي ومصدره (مثل: الدراسة، العمل، المال، الأسرة، العلاقات، الصحة).',
        '• تاريخ ووقت التسجيل.',
      ],
    ),
    (
      Icons.insights_rounded,
      'كيف نستخدم هذه البيانات؟ (لوحة "نبض")',
      [
        'تُستخدم هذه البيانات بصورة مجمعة ومجهولة الهوية لغرض الرصد الإحصائي العام فقط.',
        'تُعرض هذه الأرقام المجمعة عبر لوحة المؤشرات "نبض" الخاصة بالمؤسسات والجامعات والجهات المسؤولة لتسليط الضوء على احتياجات الشباب ودعم صناع القرار، دون أي إمكانية لربط أي رقم بمستخدم بعينه أو تتبع مصدره الأصلي. ولا تُعرض أي مجموعة يقل عددها عن 10 أشخاص.',
      ],
    ),
    (
      Icons.shield_rounded,
      'أمان البيانات والحماية',
      [
        'يتم تخزين البيانات الإحصائية المجمعة في قواعد بيانات سحابية مؤمنة (Firebase) ومشفرة، مع فرض قواعد أمان صارمة تمنع التعديل أو الوصول غير المصرح به.',
      ],
    ),
    (
      Icons.health_and_safety_rounded,
      'إخلاء مسؤولية وتنويه طبي',
      [
        'تطبيق "سند" أداة للدعم الذاتي والمساعدة في تخفيف ضغوط الحياة اليومية، وليس بديلاً عن التشخيص الطبي أو الاستشارة النفسية المتخصصة.',
        'التطبيق لا يقدم تشخيصات طبية ولا يصرف علاجات. إذا كنت تمر بأزمة نفسية شديدة أو تحتاج إلى مساعدة متخصصة، انتقل إلى شاشة الدعم داخل التطبيق وتواصل فوراً مع الجهات أو الأشخاص الموثوقين.',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final c = Palette.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('سياسة الخصوصية')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
        children: [
          Text(
            'في تطبيق "سند"، نضع خصوصيتك وأمانك النفسي والتعامل اللطيف مع بياناتك على رأس أولوياتنا. '
            'صُمم التطبيق ليكون مساحة آمنة تماماً دون أي تخوف من تتبع الهوية.',
            style: TextStyle(color: c.text, height: 1.7, fontSize: 15),
          ),
          const SizedBox(height: 18),
          for (var i = 0; i < _sections.length; i++)
            AppCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: c.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(_sections[i].$1, color: c.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('${i + 1}. ${_sections[i].$2}',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15.5, color: c.text)),
                  ),
                ]),
                const SizedBox(height: 12),
                for (final line in _sections[i].$3)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(line, style: TextStyle(color: c.text, height: 1.7, fontSize: 14)),
                  ),
              ]),
            ),
        ],
      ),
    );
  }
}
