import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrate/features/history/history_screen.dart';
import 'package:hydrate/features/home/home_screen.dart';
import 'package:hydrate/features/settings/settings_screen.dart';
import 'package:hydrate/core/providers/user_preferences_provider.dart';
import 'package:hydrate/core/providers/notification_provider.dart';

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MainAppState();
}

class _MainAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  int _selectedIndex = 0;
  bool _hasResumed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    if (!_hasResumed) {
      _hasResumed = true;
      return;
    }
    _repairReminderOnResume();
  }

  Future<void> _repairReminderOnResume() async {
    // Allow an in-progress Settings save to finish after returning from the
    // Android Alarms & reminders permission screen.
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    final service = ref.read(notificationServiceProvider);
    if (!await service.areNotificationsEnabled()) return;
    final interval = ref
        .read(userPreferencesProvider)
        .notificationIntervalMinutes;
    try {
      await service.scheduleIntervalReminders(interval);
    } catch (error) {
      debugPrint('Could not repair water reminder schedule: $error');
    }
  }

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userPreferences = ref.watch(userPreferencesProvider);

    // Initialize notifications
    ref.watch(notificationInitProvider);

    return MaterialApp(
      title: 'Hydrate',
      debugShowCheckedModeBanner: false,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: userPreferences.darkModeEnabled
          ? ThemeMode.dark
          : ThemeMode.light,
      home: Scaffold(
        body: _widgetOptions.elementAt(_selectedIndex),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.2),
                width: 0.5,
              ),
            ),
          ),
          child: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.water_drop_outlined),
                activeIcon: Icon(Icons.water_drop),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.analytics_outlined),
                activeIcon: Icon(Icons.analytics),
                label: 'History',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined),
                activeIcon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
          ),
        ),
      ),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF4A90E2),
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF4A90E2),
        unselectedItemColor: Colors.grey.shade600,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF4A90E2),
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: const Color(0xFF1E1E1E),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xFF1E1E1E),
        selectedItemColor: const Color(0xFF6BB6FF),
        unselectedItemColor: Colors.grey.shade400,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
