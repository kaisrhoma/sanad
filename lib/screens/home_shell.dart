import 'package:flutter/material.dart';

import '../models/profile.dart';
import 'checkin_screen.dart';
import 'exercises_screen.dart';
import 'support_screen.dart';

/// Main app frame with bottom navigation.
class HomeShell extends StatefulWidget {
  final Profile profile;
  const HomeShell({super.key, required this.profile});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      CheckinScreen(profile: widget.profile),
      const ExercisesScreen(),
      const SupportScreen(),
    ];
    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.wb_sunny_outlined), selectedIcon: Icon(Icons.wb_sunny_rounded), label: 'يومي'),
          NavigationDestination(icon: Icon(Icons.spa_outlined), selectedIcon: Icon(Icons.spa_rounded), label: 'تمارين'),
          NavigationDestination(
              icon: Icon(Icons.support_agent_outlined), selectedIcon: Icon(Icons.support_agent_rounded), label: 'الدعم'),
        ],
      ),
    );
  }
}
