import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../data/options.dart';
import '../services/pulse_auth.dart';
import '../services/store_service.dart';
import '../theme.dart';
import 'widgets.dart';

/// "نبض": anonymous, aggregated view for universities and youth institutions.
/// Real data only. Access needs an institution account (see PulseAuth), and the
/// Firestore rules only let that account read the records inside its scope.
class PulseScreen extends StatefulWidget {
  const PulseScreen({super.key});
  @override
  State<PulseScreen> createState() => _PulseScreenState();
}

class _PulseScreenState extends State<PulseScreen> {
  static const _minGroup = 10; // never show a group smaller than this (privacy)

  Institution? _inst;
  bool _checking = true;
  bool _loading = false;
  String? _error;
  DateTime? _updated;
  List<CheckinRecord> _all = [];

  // filters
  int _weeks = 8;
  String _status = 'all', _age = 'all', _city = 'all', _uni = 'all';

  @override
  void initState() {
    super.initState();
    _restore();
  }

  Future<void> _restore() async {
    try {
      _inst = await PulseAuth.current();
    } catch (_) {}
    setState(() => _checking = false);
    if (_inst != null) _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final rows = await StoreService().fetch(_inst!, days: 84);
      setState(() {
        _all = rows;
        _updated = DateTime.now();
      });
    } catch (e) {
      debugPrint('SANAD_ERROR: $e');
      setState(() => _error = 'تعذّر تحميل البيانات. تأكد من الإنترنت ثم اسحب للتحديث.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signOut() async {
    await PulseAuth.signOut();
    setState(() {
      _inst = null;
      _all = [];
    });
  }

  List<CheckinRecord> get _rows {
    final since = DateTime.now().subtract(Duration(days: _weeks * 7));
    return _all
        .where((r) =>
            r.date.isAfter(since) &&
            (_status == 'all' || r.status == _status) &&
            (_age == 'all' || r.ageGroup == _age) &&
            (_city == 'all' || r.city == _city) &&
            (_uni == 'all' || r.university == _uni))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('نبض'),
        actions: [
          if (_inst != null) ...[
            IconButton(tooltip: 'تحديث', onPressed: _loading ? null : _load, icon: const Icon(Icons.refresh_rounded)),
            IconButton(tooltip: 'تسجيل الخروج', onPressed: _signOut, icon: const Icon(Icons.logout_rounded)),
          ],
        ],
      ),
      body: _checking
          ? const Center(child: CircularProgressIndicator())
          : _inst == null
              ? _PulseLogin(onSignedIn: (i) {
                  setState(() => _inst = i);
                  _load();
                })
              : _dashboard(),
    );
  }

  // ------------------------------------------------------------------ dashboard
  Widget _dashboard() {
    final c = Palette.of(context);
    final rows = _rows;
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 30),
        children: [
          _institutionCard(),
          _filters(),
          const SizedBox(height: 12),
          if (_loading && _all.isEmpty)
            const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator()))
          else if (_error != null)
            _message(Icons.cloud_off_rounded, _error!)
          else if (rows.length < _minGroup)
            _message(Icons.privacy_tip_outlined,
                'لا توجد مشاركات كافية في هذا الاختيار بعد. نعرض النتائج عندما تصل المشاركات إلى $_minGroup على الأقل، حمايةً للخصوصية.')
          else ...[
            _summary(rows),
            _levelsCard(rows),
            AppCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Label('متوسط الضغط أسبوعياً', icon: Icons.show_chart_rounded),
                Text('1 منخفض  •  2 متوسط  •  3 مرتفع. الأسابيع التي فيها أقل من $_minGroup مشاركات لا تظهر.',
                    style: TextStyle(color: c.muted, fontSize: 12, height: 1.5)),
                const SizedBox(height: 14),
                SizedBox(height: 200, child: _weeklyChart(rows)),
              ]),
            ),
            AppCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Label('مصادر الضغط', icon: Icons.bar_chart_rounded),
                const SizedBox(height: 8),
                SizedBox(height: 220, child: _sourcesChart(rows)),
              ]),
            ),
            _breakdown(rows),
          ],
          if (_updated != null)
            Center(
              child: Text('آخر تحديث ${_hhmm(_updated!)}', style: TextStyle(color: c.muted, fontSize: 12)),
            ),
          const Disclaimer('أرقام مجمّعة فقط. لا تُعرض أي مجموعة أقل من 10 أشخاص، ولا تُحفظ أي نصوص أو هويات.'),
        ],
      ),
    );
  }

  String _hhmm(DateTime d) => '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  Widget _institutionCard() {
    final c = Palette.of(context);
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(gradient: c.gradient, borderRadius: BorderRadius.circular(14)),
          child: const Icon(Icons.apartment_rounded, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_inst!.name, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: c.text)),
            Text('نطاق البيانات: ${_inst!.scopeLabel}', style: TextStyle(color: c.muted, fontSize: 13)),
          ]),
        ),
      ]),
    );
  }

  Widget _filters() {
    final c = Palette.of(context);
    final scope = _inst!.scope;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Wrap(spacing: 8, children: [
        for (final w in const [4, 8, 12])
          ChoiceChip(
            label: Text('آخر $w أسابيع'),
            selected: _weeks == w,
            onSelected: (_) => setState(() => _weeks = w),
            selectedColor: c.primary.withValues(alpha: 0.18),
            side: BorderSide(color: _weeks == w ? c.primary : c.border),
          ),
      ]),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: _filter('الفئة', _status, statusOptions, (v) => _status = v)),
        const SizedBox(width: 10),
        Expanded(child: _filter('العمر', _age, ageOptions, (v) => _age = v)),
      ]),
      if (scope != 'university') ...[
        const SizedBox(height: 10),
        Row(children: [
          if (scope == 'all') ...[
            Expanded(child: _filter('المدينة', _city, cityOptions, (v) => _city = v)),
            const SizedBox(width: 10),
          ],
          Expanded(child: _filter('الجامعة', _uni, universityOptions, (v) => _uni = v)),
        ]),
      ],
    ]);
  }

  Widget _filter(String label, String value, List<Option> opts, void Function(String) set) {
    final c = Palette.of(context);
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      menuMaxHeight: 420,
      dropdownColor: c.surface,
      borderRadius: BorderRadius.circular(16),
      decoration: InputDecoration(labelText: label),
      items: [
        const DropdownMenuItem(value: 'all', child: Text('الكل')),
        ...opts
            .where((o) => o.id != skip)
            .map((o) => DropdownMenuItem(value: o.id, child: Text(o.label, overflow: TextOverflow.ellipsis))),
      ],
      onChanged: (v) => setState(() => set(v ?? 'all')),
    );
  }

  Widget _message(IconData icon, String text) {
    final c = Palette.of(context);
    return AppCard(
      child: Column(children: [
        Icon(icon, color: c.primary, size: 34),
        const SizedBox(height: 10),
        Text(text, textAlign: TextAlign.center, style: TextStyle(color: c.text, height: 1.7)),
      ]),
    );
  }

  // ------------------------------------------------------------------ summary
  Widget _summary(List<CheckinRecord> rows) {
    final c = Palette.of(context);
    final high = rows.where((r) => r.level == 'high').length;
    final now = DateTime.now();
    final recent = rows.where((r) => now.difference(r.date).inDays < 14).toList();
    final older = rows.where((r) => now.difference(r.date).inDays >= 14).toList();
    double avg(List<CheckinRecord> l) => l.isEmpty ? 0 : l.map((r) => r.levelValue).reduce((a, b) => a + b) / l.length;
    final rising = recent.length >= _minGroup && older.length >= _minGroup && avg(recent) > avg(older) + 0.15;

    final counts = <String, int>{};
    for (final r in rows) {
      counts[r.source] = (counts[r.source] ?? 0) + 1;
    }
    // Most common named source; "other" is only shown when nothing else is present.
    final ranked = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final named = ranked.where((e) => e.key != 'other').toList();
    final topSource = named.isNotEmpty ? named.first : ranked.first;
    final topLabel = sourceLabels[topSource.key] ?? '';

    return Column(children: [
      Row(children: [
        Expanded(child: _stat('${rows.length}', 'مشاركة', Icons.groups_rounded, c.primary)),
        const SizedBox(width: 10),
        Expanded(
            child: _stat('${(high * 100 / rows.length).round()}%', 'ضغط مرتفع', Icons.trending_up_rounded,
                AppColors.high)),
        const SizedBox(width: 10),
        Expanded(
            child: _stat(topLabel, 'المصدر الأبرز', Icons.flag_rounded, c.secondary,
                small: true)),
      ]),
      if (rising)
        AppCard(
          color: AppColors.high.withValues(alpha: 0.12),
          child: Row(children: [
            const Icon(Icons.notifications_active_rounded, color: AppColors.high),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'إنذار مبكر: متوسط الضغط في آخر أسبوعين أعلى من الفترة السابقة. '
                'يُقترح تنظيم دعم أو ورشة لهذه الفئة${topSource.key == 'other' ? '' : '، خصوصاً حول: $topLabel'}.',
                style: TextStyle(height: 1.6, color: c.text),
              ),
            ),
          ]),
        ),
    ]);
  }

  Widget _stat(String value, String label, IconData icon, Color color, {bool small = false}) {
    final c = Palette.of(context);
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: Text(value,
              style: TextStyle(fontSize: small ? 18 : 26, fontWeight: FontWeight.w800, color: color, height: 1.3)),
        ),
        Text(label, style: TextStyle(color: c.muted, fontSize: 12.5)),
      ]),
    );
  }

  Widget _levelsCard(List<CheckinRecord> rows) {
    final c = Palette.of(context);
    final n = rows.length;
    final parts = [
      ('منخفض', rows.where((r) => r.level == 'low').length, AppColors.low),
      ('متوسط', rows.where((r) => r.level == 'medium').length, AppColors.medium),
      ('مرتفع', rows.where((r) => r.level == 'high').length, AppColors.high),
    ];
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Label('توزيع مستويات الضغط', icon: Icons.donut_large_rounded),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            height: 16,
            child: Row(children: [
              for (final p in parts)
                if (p.$2 > 0) Expanded(flex: p.$2, child: Container(color: p.$3)),
            ]),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(spacing: 16, runSpacing: 6, children: [
          for (final p in parts)
            Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 10, height: 10, decoration: BoxDecoration(color: p.$3, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text('${p.$1} ${(p.$2 * 100 / n).round()}%', style: TextStyle(color: c.text, fontSize: 13)),
            ]),
        ]),
      ]),
    );
  }

  // ------------------------------------------------------------------ charts
  Widget _weeklyChart(List<CheckinRecord> rows) {
    final c = Palette.of(context);
    final now = DateTime.now();
    final n = _weeks;
    final sums = List<double>.filled(n, 0), counts = List<int>.filled(n, 0);
    for (final r in rows) {
      final w = n - 1 - now.difference(r.date).inDays ~/ 7;
      if (w < 0 || w >= n) continue;
      sums[w] += r.levelValue;
      counts[w]++;
    }
    final spots = <FlSpot>[
      for (var i = 0; i < n; i++)
        if (counts[i] >= _minGroup) FlSpot(i.toDouble(), sums[i] / counts[i]),
    ];
    if (spots.isEmpty) {
      return Center(
        child: Text('لا يوجد أسبوع فيه $_minGroup مشاركات أو أكثر بعد.',
            textAlign: TextAlign.center, style: TextStyle(color: c.muted)),
      );
    }
    final axisStyle = TextStyle(fontSize: 11, color: c.muted);
    return LineChart(LineChartData(
      minY: 1,
      maxY: 3,
      minX: 0,
      maxX: (n - 1).toDouble(),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 0.5,
        getDrawingHorizontalLine: (_) => FlLine(color: c.border, strokeWidth: 1),
      ),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 26,
            interval: 1,
            getTitlesWidget: (v, meta) => Text(v.toInt().toString(), style: axisStyle),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: n > 8 ? 2 : 1,
            getTitlesWidget: (v, meta) => Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(v.toInt() == n - 1 ? 'الآن' : '-${n - 1 - v.toInt()}أ', style: axisStyle),
            ),
          ),
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          preventCurveOverShooting: true,
          gradient: c.gradient,
          barWidth: 4,
          dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [c.primary.withValues(alpha: 0.25), c.primary.withValues(alpha: 0.0)],
            ),
          ),
        ),
      ],
    ));
  }

  Widget _sourcesChart(List<CheckinRecord> rows) {
    final c = Palette.of(context);
    final counts = <String, int>{};
    for (final r in rows) {
      counts[r.source] = (counts[r.source] ?? 0) + 1;
    }
    // Sources with fewer than 10 records are merged into "أخرى" instead of being shown alone.
    final merged = <String, int>{};
    counts.forEach((k, v) {
      final key = v >= _minGroup ? k : 'other';
      merged[key] = (merged[key] ?? 0) + v;
    });
    final top = (merged.entries.toList()..sort((a, b) => b.value.compareTo(a.value))).take(7).toList();
    return BarChart(BarChartData(
      maxY: 100,
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipItem: (g, _, rod, __) => BarTooltipItem(
            '${rod.toY.round()}%',
            const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ),
      ),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (v, meta) {
              final i = v.toInt();
              if (i < 0 || i >= top.length) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(sourceLabels[top[i].key] ?? '', style: TextStyle(fontSize: 10.5, color: c.muted)),
              );
            },
          ),
        ),
      ),
      barGroups: [
        for (var i = 0; i < top.length; i++)
          BarChartGroupData(x: i, barRods: [
            BarChartRodData(
              toY: top[i].value * 100 / rows.length,
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [c.primary, c.secondary],
              ),
              width: 22,
              borderRadius: BorderRadius.circular(8),
            ),
          ]),
      ],
    ));
  }

  /// Groups ranked by share of high stress. Cities for national accounts, otherwise categories.
  Widget _breakdown(List<CheckinRecord> rows) {
    final c = Palette.of(context);
    final byCity = _inst!.scope == 'all' && _city == 'all';
    final opts = byCity ? cityOptions : statusOptions;
    final groups = <String, List<CheckinRecord>>{};
    for (final r in rows) {
      final k = byCity ? r.city : r.status;
      if (k == skip) continue;
      (groups[k] ??= []).add(r);
    }
    final list = groups.entries.where((e) => e.value.length >= _minGroup).map((e) {
      final high = e.value.where((r) => r.level == 'high').length * 100 / e.value.length;
      return (labelOf(opts, e.key), e.value.length, high);
    }).toList()
      ..sort((a, b) => b.$3.compareTo(a.$3));
    if (list.isEmpty) return const SizedBox.shrink();
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Label(byCity ? 'المدن حسب نسبة الضغط المرتفع' : 'الفئات حسب نسبة الضغط المرتفع',
            icon: Icons.leaderboard_rounded),
        for (final g in list.take(8))
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(g.$1, style: TextStyle(color: c.text, fontWeight: FontWeight.w600))),
                Text('${g.$3.round()}%  •  ${g.$2} مشاركة', style: TextStyle(color: c.muted, fontSize: 12.5)),
              ]),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: g.$3 / 100,
                  minHeight: 8,
                  color: AppColors.high,
                  backgroundColor: c.surface2,
                ),
              ),
            ]),
          ),
      ]),
    );
  }
}

// -------------------------------------------------------------------- login
class _PulseLogin extends StatefulWidget {
  final ValueChanged<Institution> onSignedIn;
  const _PulseLogin({required this.onSignedIn});
  @override
  State<_PulseLogin> createState() => _PulseLoginState();
}

class _PulseLoginState extends State<_PulseLogin> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  bool _hide = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_email.text.trim().isEmpty || _password.text.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() => _busy = true);
    try {
      final inst = await PulseAuth.signIn(_email.text, _password.text);
      if (mounted) widget.onSignedIn(inst);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(PulseAuth.message(e))));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = Palette.of(context);
    return ListView(padding: const EdgeInsets.all(24), children: [
      const SizedBox(height: 10),
      Center(child: Image.asset('assets/logo/logo.png', width: 96, height: 96)),
      const SizedBox(height: 16),
      Text('لوحة نبض للجهات',
          textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: c.text)),
      const SizedBox(height: 8),
      Text('للجامعات والجهات المسؤولة عن الشباب. أرقام مجمّعة فقط، بدون أي أسماء أو نصوص.',
          textAlign: TextAlign.center, style: TextStyle(height: 1.7, color: c.muted)),
      const SizedBox(height: 24),
      TextField(
        controller: _email,
        keyboardType: TextInputType.emailAddress,
        textDirection: TextDirection.ltr,
        autofillHints: const [AutofillHints.email],
        decoration: const InputDecoration(labelText: 'البريد الإلكتروني للجهة', prefixIcon: Icon(Icons.mail_outline_rounded)),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: _password,
        obscureText: _hide,
        textDirection: TextDirection.ltr,
        autofillHints: const [AutofillHints.password],
        onSubmitted: (_) => _submit(),
        decoration: InputDecoration(
          labelText: 'كلمة المرور',
          prefixIcon: const Icon(Icons.lock_outline_rounded),
          suffixIcon: IconButton(
            onPressed: () => setState(() => _hide = !_hide),
            icon: Icon(_hide ? Icons.visibility_rounded : Icons.visibility_off_rounded),
          ),
        ),
      ),
      const SizedBox(height: 18),
      GradientButton(label: 'دخول', icon: Icons.login_rounded, loading: _busy, onPressed: _submit),
      const SizedBox(height: 16),
      Text('حسابات الجهات يُنشئها فريق سند. لطلب حساب لجامعتك أو جهتك تواصل معنا.',
          textAlign: TextAlign.center, style: TextStyle(color: c.muted, fontSize: 12.5, height: 1.6)),
    ]);
  }
}
