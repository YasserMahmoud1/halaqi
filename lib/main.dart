import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_barber/core/router/app_routers.dart';
import 'package:my_barber/core/shared_preferences/shared_preferences_provider.dart';
import 'package:my_barber/core/themes/app_mode_provider.dart';
import 'package:my_barber/core/themes/app_themes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:my_barber/core/dotenv_consts/app_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!AppConfig.hasValidSupabaseConfig) {
    runApp(
      const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: _StartupConfigErrorScreen(),
      ),
    );
    return;
  }

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );

  final sharedPrefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(sharedPrefs)],
      child: const MyApp(),
    ),
  );
}

class _StartupConfigErrorScreen extends StatelessWidget {
  const _StartupConfigErrorScreen();

  @override
  Widget build(BuildContext context) {
    final missing = AppConfig.missingConfigKeys.join(', ');
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 12),
              const Text(
                'App configuration is missing.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Missing build values: $missing',
                style: const TextStyle(color: Colors.black87),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(appModeProvider);
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > 600;
        final isLandscape = constraints.maxWidth > constraints.maxHeight;

        Size designSize;
        if (isTablet) {
          designSize = isLandscape ? const Size(1024, 768) : const Size(768, 1024);
        } else {
          designSize = isLandscape ? const Size(812, 375) : const Size(375, 812);
        }

        return ScreenUtilInit(
          designSize: designSize,
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return MaterialApp.router(
              theme: AppThemes.lightTheme,
              darkTheme: AppThemes.darkTheme,
              themeMode: themeMode,
              routerConfig: ref.watch(appRouterProvider),
              debugShowCheckedModeBanner: false,
            );
          },
        );
      },
    );
  }
}
