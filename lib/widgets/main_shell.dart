import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../views/dashbord/home_page.dart';
import '../views/dashbord/appointments_page.dart';
import '../views/dashbord/articles_page.dart';
import '../views/dashbord/settings_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selected = 0;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.scaffoldBackground,
    body: IndexedStack(
      index: _selected,
      children: const [
        HomePage(),
        AppointmentsPage(showBack: false),
        ArticlesPage(),
        SettingsPage(),
      ],
    ),
    bottomNavigationBar: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textDark.withValues(alpha: .07),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            labelTextStyle: WidgetStateProperty.resolveWith(
              (states) => TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                fontWeight: states.contains(WidgetState.selected)
                    ? FontWeight.w700
                    : FontWeight.w500,
                color: states.contains(WidgetState.selected)
                    ? AppColors.primary
                    : AppColors.textMuted,
              ),
            ),
            iconTheme: WidgetStateProperty.resolveWith(
              (states) => IconThemeData(
                size: 24,
                color: states.contains(WidgetState.selected)
                    ? AppColors.primary
                    : AppColors.textMuted,
              ),
            ),
          ),
          child: NavigationBar(
            height: 78,
            elevation: 0,
            backgroundColor: Colors.white,
            indicatorColor: AppColors.primaryLighter,
            selectedIndex: _selected,
            onDestinationSelected: (index) {
              FocusManager.instance.primaryFocus?.unfocus();
              setState(() => _selected = index);
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Accueil',
              ),
              NavigationDestination(
                icon: Icon(Icons.calendar_month_outlined),
                selectedIcon: Icon(Icons.calendar_month_rounded),
                label: 'Rendez-vous',
              ),
              NavigationDestination(
                icon: Icon(Icons.article_outlined),
                selectedIcon: Icon(Icons.article_rounded),
                label: 'Articles',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings_rounded),
                label: 'Paramètres',
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
