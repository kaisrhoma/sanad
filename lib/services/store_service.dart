import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/options.dart';
import '../models/analysis.dart';
import '../models/profile.dart';

/// One anonymous record per check-in. No text, no user id.
class CheckinRecord {
  final DateTime date;
  final String status, ageGroup, city, university, level, source;

  CheckinRecord({
    required this.date,
    required this.status,
    required this.ageGroup,
    required this.city,
    required this.university,
    required this.level,
    required this.source,
  });

  int get levelValue => level == 'high' ? 3 : (level == 'medium' ? 2 : 1);

  Map<String, dynamic> toMap() => {
        'date': Timestamp.fromDate(date),
        'status': status,
        'age_group': ageGroup,
        'city': city,
        'university': university,
        'level': level,
        'source': source,
      };

  /// Tolerant reader: accepts Timestamp or ISO-string dates, and English/Arabic names or ids.
  /// Returns null for records that cannot be read (they are skipped, never shown wrongly).
  static CheckinRecord? tryParse(Map<String, dynamic> m) {
    final date = _date(m['date']);
    final level = _str(m['level']);
    if (date == null || !const ['low', 'medium', 'high'].contains(level)) return null;
    final source = _str(m['source']);
    return CheckinRecord(
      date: date,
      status: _id(m['status'], statusOptions),
      ageGroup: _id(m['age_group'], ageOptions),
      city: _id(m['city'], cityOptions),
      university: _id(m['university'], universityOptions),
      level: level,
      source: sourceLabels.containsKey(source) ? source : 'other',
    );
  }

  static DateTime? _date(Object? v) {
    if (v is Timestamp) return v.toDate();
    if (v is String) return DateTime.tryParse(v)?.toLocal();
    if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
    return null;
  }

  static String _str(Object? v) => (v ?? '').toString().trim().toLowerCase();

  /// Maps a stored value to a known option id ("Tripoli", "tripoli" or "طرابلس" -> "tripoli").
  static String _id(Object? v, List<Option> options) {
    final raw = (v ?? '').toString().trim();
    if (raw.isEmpty) return skip;
    final low = raw.toLowerCase();
    for (final o in options) {
      if (o.id == low || o.label == raw) return o.id;
    }
    return low;
  }
}

/// An institution account allowed to read "نبض". Stored in /institutions/{uid}.
class Institution {
  final String name;
  final String scope; // all | university | city
  final String value; // university or city id when scope is not "all"
  const Institution({required this.name, required this.scope, required this.value});

  factory Institution.fromMap(Map<String, dynamic> m) => Institution(
        name: (m['name'] ?? 'جهة').toString(),
        scope: (m['scope'] ?? 'all').toString(),
        value: (m['value'] ?? '').toString(),
      );

  String get scopeLabel => switch (scope) {
        'university' => labelOf(universityOptions, value),
        'city' => 'مدينة ${labelOf(cityOptions, value)}',
        _ => 'كل ليبيا',
      };
}

class StoreService {
  final _col = FirebaseFirestore.instance.collection('checkins');

  /// Saves the anonymous numbers only. Failures are ignored so the user flow never breaks.
  Future<void> saveCheckin(Profile p, Analysis a) async {
    try {
      await _col.add(CheckinRecord(
        date: DateTime.now(),
        status: p.status,
        ageGroup: p.ageGroup,
        city: p.city,
        university: p.university,
        level: a.level,
        source: a.source,
      ).toMap());
    } catch (e) {
      // ignore: avoid_print
      print('SANAD_SAVE_FAIL: $e');
    }
  }

  /// Reads the records an institution is allowed to see (the security rules enforce the same scope).
  /// Dates are filtered on the phone to avoid needing a composite index.
  /// TODO: move aggregation to a Cloud Function once volume grows, so only totals leave the server.
  Future<List<CheckinRecord>> fetch(Institution inst, {int days = 84}) async {
    Query<Map<String, dynamic>> q = _col;
    if (inst.scope == 'university') q = q.where('university', isEqualTo: inst.value);
    if (inst.scope == 'city') q = q.where('city', isEqualTo: inst.value);
    final snap = await q.get();
    final since = DateTime.now().subtract(Duration(days: days));
    return snap.docs
        .map((d) => CheckinRecord.tryParse(d.data()))
        .whereType<CheckinRecord>()
        .where((r) => r.date.isAfter(since))
        .toList();
  }
}
