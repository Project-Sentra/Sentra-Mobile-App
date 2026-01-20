import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/di/injection_container.dart' as di;
import 'core/env/supabase.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://fouccavizcgbhvbemhov.supabase.co',
    anonKey: 'sb_publishable_KdTPl9zNz6WBNCSfhTFKZA_r2x_PKqd',
  );

  // Initialize dependencies
  await di.initializeDependencies();

  runApp(const SentraApp());
}

class SentraApp extends StatelessWidget {
  const SentraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Sentra Parking',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: AppRouter.router,
    );
  }
}
