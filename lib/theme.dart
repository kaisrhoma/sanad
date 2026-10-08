import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Colors that change between light and dark mode.
class Palette {
  final Brightness brightness;
  final Color bg, surface, surface2, text, muted, border, primary, secondary, shadow;
  const Palette({
    required this.brightness,
    required this.bg,
    required this.surface,
    required this.surface2,
    required this.text,
    required this.muted,
    required this.border,
    required this.primary,
    required this.secondary,
    required this.shadow,
  });

  bool get isDark => brightness == Brightness.dark;

  LinearGradient get gradient => LinearGradient(
        colors: [primary, secondary],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      );

  static const light = Palette(
    brightness: Brightness.light,
    bg: Color(0xFFF4F6FB),
    surface: Colors.white,
    surface2: Color(0xFFEEF1F8),
    text: Color(0xFF161A26),
    muted: Color(0xFF6B7385),
    border: Color(0xFFE3E7F0),
    primary: Color(0xFF4F63E8),
    secondary: Color(0xFF1FB5A3),
    shadow: Color(0x14243B6B),
  );

  static const dark = Palette(
    brightness: Brightness.dark,
    bg: Color(0xFF0D1017),
    surface: Color(0xFF161A23),
    surface2: Color(0xFF1E2330),
    text: Color(0xFFE9ECF3),
    muted: Color(0xFF98A1B3),
    border: Color(0xFF272D3B),
    primary: Color(0xFF8193FF),
    secondary: Color(0xFF39D3BF),
    shadow: Color(0x00000000),
  );

  static Palette of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;
}

/// Fixed meaning colors (same in both modes).
class AppColors {
  static const low = Color(0xFF2FBF85);
  static const medium = Color(0xFFF2A531);
  static const high = Color(0xFFEF5D5A);
}

/// Appearance: follows the phone's setting by default; the user can override it from inside the app.
class ThemeController {
  static final mode = ValueNotifier<ThemeMode>(ThemeMode.system);

  static Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    mode.value = ThemeMode.values[p.getInt('theme_mode') ?? ThemeMode.system.index];
  }

  static Future<void> set(ThemeMode m) async {
    mode.value = m;
    final p = await SharedPreferences.getInstance();
    await p.setInt('theme_mode', m.index);
  }

  static IconData get icon => switch (mode.value) {
        ThemeMode.light => Icons.light_mode_rounded,
        ThemeMode.dark => Icons.dark_mode_rounded,
        ThemeMode.system => Icons.brightness_auto_rounded,
      };

  /// Bottom sheet with three choices: like the phone, light, dark.
  static Future<void> pick(BuildContext context) => showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (ctx) {
          final c = Palette.of(ctx);
          Widget option(ThemeMode m, IconData icon, String title, String sub) => ListTile(
                leading: Icon(icon, color: c.primary),
                title: Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: c.text)),
                subtitle: Text(sub, style: TextStyle(color: c.muted)),
                trailing: mode.value == m ? Icon(Icons.check_circle_rounded, color: c.primary) : null,
                onTap: () {
                  set(m);
                  Navigator.of(ctx).pop();
                },
              );
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text('المظهر', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: c.text)),
                const SizedBox(height: 8),
                option(ThemeMode.system, Icons.brightness_auto_rounded, 'تلقائي', 'مثل إعداد هاتفك'),
                option(ThemeMode.light, Icons.light_mode_rounded, 'فاتح', 'دائماً فاتح'),
                option(ThemeMode.dark, Icons.dark_mode_rounded, 'داكن', 'دائماً داكن'),
              ]),
            ),
          );
        },
      );
}

ThemeData buildTheme(Palette c) {
  final base = ThemeData(
    useMaterial3: true,
    brightness: c.brightness,
    colorScheme: ColorScheme.fromSeed(
      seedColor: c.primary,
      brightness: c.brightness,
      primary: c.primary,
      secondary: c.secondary,
      surface: c.surface,
    ),
    scaffoldBackgroundColor: c.bg,
  );
  final text = GoogleFonts.getTextTheme('IBM Plex Sans Arabic', base.textTheme)
      .apply(bodyColor: c.text, displayColor: c.text);

  return base.copyWith(
    textTheme: text,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: c.text,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: text.titleLarge?.copyWith(fontWeight: FontWeight.w700, color: c.text),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.surface2,
      hintStyle: TextStyle(color: c.muted),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: c.primary, width: 1.5),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: c.surface,
      indicatorColor: c.primary.withValues(alpha: 0.15),
      elevation: 0,
      labelTextStyle: WidgetStatePropertyAll(text.labelMedium?.copyWith(fontWeight: FontWeight.w600)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    dividerTheme: DividerThemeData(color: c.border),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: c.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    ),
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    ),
  );
}
