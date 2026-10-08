import 'package:flutter/material.dart';

import '../data/options.dart';
import '../theme.dart';

/// Rounded surface card. Soft shadow in light mode, thin border in dark mode.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final VoidCallback? onTap;
  const AppCard({super.key, required this.child, this.padding = const EdgeInsets.all(18), this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = Palette.of(context);
    final card = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? c.surface,
        borderRadius: BorderRadius.circular(22),
        border: c.isDark ? Border.all(color: c.border) : null,
        boxShadow: c.isDark ? null : [BoxShadow(color: c.shadow, blurRadius: 24, offset: const Offset(0, 8))],
      ),
      child: child,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: onTap == null
          ? card
          : Material(
              color: Colors.transparent,
              child: InkWell(borderRadius: BorderRadius.circular(22), onTap: onTap, child: card),
            ),
    );
  }
}

/// Kept for compatibility with earlier screens.
class SectionCard extends AppCard {
  const SectionCard({super.key, required super.child, super.color});
}

class Label extends StatelessWidget {
  final String text;
  final IconData? icon;
  const Label(this.text, {super.key, this.icon});
  @override
  Widget build(BuildContext context) {
    final c = Palette.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        if (icon != null) ...[Icon(icon, size: 20, color: c.primary), const SizedBox(width: 8)],
        Expanded(
          child: Text(text, style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700, color: c.text)),
        ),
      ]),
    );
  }
}

/// Big gradient call-to-action button with loading state.
class GradientButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool loading;
  const GradientButton({super.key, required this.label, this.icon, this.onPressed, this.loading = false});

  @override
  Widget build(BuildContext context) {
    final c = Palette.of(context);
    final enabled = onPressed != null && !loading;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: enabled || loading ? 1 : 0.45,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: c.gradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: c.primary.withValues(alpha: 0.30), blurRadius: 18, offset: const Offset(0, 8))],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: enabled ? onPressed : null,
            child: Center(
              child: loading
                  ? const SizedBox(
                      width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                  : Row(mainAxisSize: MainAxisSize.min, children: [
                      if (icon != null) ...[Icon(icon, color: Colors.white), const SizedBox(width: 8)],
                      Text(label,
                          style: const TextStyle(color: Colors.white, fontSize: 16.5, fontWeight: FontWeight.w700)),
                    ]),
            ),
          ),
        ),
      ),
    );
  }
}

/// Secondary action shown as a wide tappable card with an icon.
class ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? accent;
  final VoidCallback onTap;
  const ActionTile({super.key, required this.icon, required this.title, this.subtitle, this.accent, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = Palette.of(context);
    final a = accent ?? c.primary;
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(color: a.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(14)),
          child: Icon(icon, color: a),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700, color: c.text)),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(subtitle!, style: TextStyle(fontSize: 13, color: c.muted)),
            ],
          ]),
        ),
        Icon(Icons.chevron_right_rounded, color: c.muted),
      ]),
    );
  }
}

/// Header with gradient background used at the top of main screens.
class GradientHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final Widget? bottom;
  const GradientHeader({super.key, required this.title, this.subtitle, this.actions = const [], this.bottom});

  @override
  Widget build(BuildContext context) {
    final c = Palette.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 12, 20, 26),
      decoration: BoxDecoration(
        gradient: c.gradient,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
              if (subtitle != null)
                Text(subtitle!, style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 14)),
            ]),
          ),
          ...actions,
        ]),
        if (bottom != null) ...[const SizedBox(height: 16), bottom!],
      ]),
    );
  }
}

/// Round icon button on top of the gradient header.
class HeaderIcon extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  const HeaderIcon({super.key, required this.icon, required this.tooltip, required this.onTap});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsetsDirectional.only(start: 8),
        child: IconButton(
          tooltip: tooltip,
          onPressed: onTap,
          style: IconButton.styleFrom(backgroundColor: Colors.white.withValues(alpha: 0.18)),
          icon: Icon(icon, color: Colors.white),
        ),
      );
}

/// Header button that opens the appearance picker; its icon follows the saved choice.
class ThemeButton extends StatelessWidget {
  const ThemeButton({super.key});
  @override
  Widget build(BuildContext context) => ValueListenableBuilder<ThemeMode>(
        valueListenable: ThemeController.mode,
        builder: (context, _, __) => HeaderIcon(
          icon: ThemeController.icon,
          tooltip: 'المظهر',
          onTap: () => ThemeController.pick(context),
        ),
      );
}

/// 1–5 picker with emoji faces.
class EmojiScale extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final List<String> emojis;
  final List<String> labels;
  const EmojiScale(
      {super.key, required this.value, required this.onChanged, required this.emojis, required this.labels});

  @override
  Widget build(BuildContext context) {
    final c = Palette.of(context);
    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(5, (i) {
          final v = i + 1;
          final sel = v == value;
          return GestureDetector(
            onTap: () => onChanged(v),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              width: sel ? 58 : 50,
              height: sel ? 58 : 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: sel ? c.primary.withValues(alpha: 0.16) : c.surface2,
                border: Border.all(color: sel ? c.primary : Colors.transparent, width: 2),
              ),
              child: Text(emojis[i], style: TextStyle(fontSize: sel ? 28 : 23)),
            ),
          );
        }),
      ),
      const SizedBox(height: 10),
      AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        child: Text(labels[value - 1],
            key: ValueKey(value), style: TextStyle(color: c.primary, fontWeight: FontWeight.w700)),
      ),
    ]);
  }
}

/// Dropdown for a list of [Option]s.
class OptionDropdown extends StatelessWidget {
  final List<Option> options;
  final String value;
  final ValueChanged<String> onChanged;
  final String? label;
  final IconData? icon;
  const OptionDropdown(
      {super.key, required this.options, required this.value, required this.onChanged, this.label, this.icon});

  @override
  Widget build(BuildContext context) {
    final c = Palette.of(context);
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      menuMaxHeight: 420,
      dropdownColor: c.surface,
      borderRadius: BorderRadius.circular(16),
      icon: Icon(Icons.expand_more_rounded, color: c.muted),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon == null ? null : Icon(icon, color: c.primary),
      ),
      items: options
          .map((o) => DropdownMenuItem(value: o.id, child: Text(o.label, overflow: TextOverflow.ellipsis)))
          .toList(),
      onChanged: (v) => onChanged(v ?? skip),
    );
  }
}

/// Small colored pill.
class Pill extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;
  const Pill(this.text, {super.key, required this.color, this.icon});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(30)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[Icon(icon, size: 16, color: color), const SizedBox(width: 6)],
          Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13)),
        ]),
      );
}

class Disclaimer extends StatelessWidget {
  final String text;
  const Disclaimer(this.text, {super.key});
  @override
  Widget build(BuildContext context) {
    final c = Palette.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.info_outline_rounded, size: 16, color: c.muted),
        const SizedBox(width: 6),
        Flexible(child: Text(text, textAlign: TextAlign.center, style: TextStyle(color: c.muted, fontSize: 12.5))),
      ]),
    );
  }
}

Color levelColor(String level) =>
    level == 'high' ? AppColors.high : (level == 'medium' ? AppColors.medium : AppColors.low);

/// Smooth page transition used across the app.
Route<T> fadeRoute<T>(Widget page) => PageRouteBuilder<T>(
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, a, __, child) => FadeTransition(
        opacity: CurvedAnimation(parent: a, curve: Curves.easeOut),
        child: SlideTransition(
          position: Tween(begin: const Offset(0, 0.04), end: Offset.zero)
              .animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
          child: child,
        ),
      ),
    );
