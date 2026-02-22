import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/theme_mode_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/vault_screen.dart';
import 'screens/lens_screen.dart';
import 'screens/strategy_screen.dart';
import 'screens/account_screen.dart';
import 'widgets/floating_tab_bar.dart';

import 'screens/auth/login_screen.dart';
import 'screens/onboarding_page.dart';
import 'data/providers/auth_provider.dart';
import 'data/providers/onboarding_check_provider.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'core/constants.dart';

Future<void> _checkBackendHealth() async {
  final url = '${AppConstants.apiBaseUrl}/health';
  debugPrint('🔌 Checking Backend Health at: $url');
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      debugPrint('✅ Backend Health Check: OK');
    } else {
      debugPrint(
        '❌ Backend Health Check: FAILED (Status: ${response.statusCode})',
      );
      debugPrint('Response: ${response.body}');
    }
  } catch (e) {
    debugPrint('❌ Backend Health Check: ERROR ($e)');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  _checkBackendHealth(); // Fire and forget health check
  await Firebase.initializeApp();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.canvas,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const ProviderScope(child: SubSentinelApp()));
}

class SubSentinelApp extends ConsumerWidget {
  const SubSentinelApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: isDark
            ? AppColors.canvas
            : AppColors.lightCanvas,
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
      ),
    );

    return MaterialApp(
      title: 'SubSentinel',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      themeAnimationDuration: const Duration(milliseconds: 420),
      themeAnimationCurve: Curves.easeInOutCubicEmphasized,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends ConsumerStatefulWidget {
  const AuthWrapper({super.key});

  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeOnboardingCheck();
    });
  }

  Future<void> _initializeOnboardingCheck() async {
    print('🔄 [AUTHWRAPPER] Initializing onboarding check...');
    final authState = ref.read(authProvider);
    if (authState.user != null) {
      print(
        '✅ [AUTHWRAPPER] User authenticated, checking onboarding status...',
      );
      await ref.read(onboardingCheckProvider.notifier).checkStatus();
    } else {
      print('❌ [AUTHWRAPPER] No user authenticated');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final onboardingCheck = ref.watch(onboardingCheckProvider);

    print('🔄 [AUTHWRAPPER] Building...');
    print('  - Auth loading: ${authState.isLoading}');
    print('  - User exists: ${authState.user != null}');
    print('  - Onboarding loading: ${onboardingCheck.isLoading}');
    print('  - Onboarding complete: ${onboardingCheck.isComplete}');

    if (authState.isLoading) {
      print('📱 [AUTHWRAPPER] Showing loading spinner...');
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.active),
        ),
      );
    }

    if (authState.user == null) {
      print('📱 [AUTHWRAPPER] Showing LoginScreen');
      return const LoginScreen();
    }

    if (onboardingCheck.isLoading) {
      print('📱 [AUTHWRAPPER] Showing onboarding check loading...');
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.active),
        ),
      );
    }

    if (!onboardingCheck.isComplete) {
      print(
        '📱 [AUTHWRAPPER] Showing OnboardingPage (onboarding not complete)',
      );
      return const OnboardingPage();
    }

    print(
      '📱 [AUTHWRAPPER] Showing MainNavigationShell (onboarding complete, user authenticated)',
    );
    return const MainNavigationShell();
  }
}

/// Main navigation shell with floating tab bar
class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    VaultScreen(),
    LensScreen(),
    StrategyScreen(),
    AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Current screen
          IndexedStack(index: _currentIndex, children: _screens),
          // Floating tab bar
          FloatingTabBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
          ),
        ],
      ),
    );
  }
}
