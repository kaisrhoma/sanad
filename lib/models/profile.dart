import 'package:shared_preferences/shared_preferences.dart';

import '../data/options.dart';

/// Anonymous profile kept only on the phone. No name, no phone number.
class Profile {
  String status;
  String ageGroup;
  String city;
  String university;

  Profile({
    this.status = skip,
    this.ageGroup = skip,
    this.city = skip,
    this.university = skip,
  });

  static Future<Profile?> load() async {
    final p = await SharedPreferences.getInstance();
    if (!(p.getBool('onboarded') ?? false)) return null;
    return Profile(
      status: p.getString('status') ?? skip,
      ageGroup: p.getString('age_group') ?? skip,
      city: p.getString('city') ?? skip,
      university: p.getString('university') ?? skip,
    );
  }

  Future<void> save() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool('onboarded', true);
    await p.setString('status', status);
    await p.setString('age_group', ageGroup);
    await p.setString('city', city);
    await p.setString('university', university);
  }
}
