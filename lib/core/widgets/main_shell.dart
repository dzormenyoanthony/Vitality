import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Persistent bottom navigation shell wrapping Home/History/Trends/Learn
/// (PROJECT_SPEC.md §30's "main application" area). Every other screen
/// (Settings, Reminders, Record BP, Reading detail, Article detail) stays
/// reached by pushing on top of this shell, exactly as before — only these
/// four top-level destinations live behind the nav bar.
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.list_alt_outlined), label: 'History'),
          NavigationDestination(icon: Icon(Icons.show_chart), label: 'Trends'),
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), label: 'Learn'),
        ],
      ),
    );
  }
}
