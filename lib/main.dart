import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/di/injection_container.dart' as di;
import 'core/env/supabase.dart';
import 'core/env/stripe.dart';
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
  assert(() {
    if (supabaseKey.startsWith('sb_')) {
      // Not a hard error, but a strong signal the wrong key is configured.
      // The correct Anon public key is in Supabase Dashboard → Settings → API.
      debugPrint(
        'WARNING: supabaseKey looks like an sb_publishable key. '
        'Use the Anon public key (usually starts with eyJ...) to avoid Edge Function Invalid JWT.',
      );
    }
    return true;
  }());
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseKey,
  );

  // Initialize Stripe
  Stripe.publishableKey = stripePublishableKey;
  await Stripe.instance.applySettings();

  // Initialize dependencies
  await di.initializeDependencies();

  runApp(const SentraApp());
}
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   await Supabase.initialize(
//     url: 'https://pnopbaulalcwaucrynim.supabase.co',
//     anonKey: 'YOUR_REAL_ANON_KEY',
//   );

//   Stripe.publishableKey = stripePublishableKey;
//   await Stripe.instance.applySettings();

//   await di.initializeDependencies();
//   runApp(const SentraApp());
//   // runApp(
//   //   const MaterialApp(
//   //     debugShowCheckedModeBanner: false,
//   //     home: Scaffold(
//   //       backgroundColor: Colors.blue,
//   //       body: Center(
//   //         child: Text(
//   //           "SUPABASE + STRIPE WORKING",
//   //           style: TextStyle(color: Colors.white, fontSize: 22),
//   //         ),
//   //       ),
//   //     ),
//   //   ),
//   // );
// }
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
