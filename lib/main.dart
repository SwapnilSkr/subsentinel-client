import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'screens/dashboard_screen.dart';
import 'screens/vault_screen.dart';
import 'screens/lens_screen.dart';
import 'screens/strategy_screen.dart';
import 'widgets/floating_tab_bar.dart';

import 'screens/auth/login_screen.dart';
import 'data/providers/auth_provider.dart';

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
    return MaterialApp(
      title: 'SubSentinel',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (authState.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.canvas,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF00FF41)),
        ),
      );
    }

    if (authState.user != null) {
      return const MainNavigationShell();
    }

    return const LoginScreen();
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
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
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
