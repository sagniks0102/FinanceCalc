// import 'package:flutter/material.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
// import 'screens/home_screen.dart';
// import 'utils/app_settings.dart';
// import 'utils/app_theme.dart';

// void main() => runApp(const FinCalcApp());

// class FinCalcApp extends StatelessWidget {
//   const FinCalcApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final settings = AppSettings.instance;
//     return ValueListenableBuilder<ThemeMode>(
//       valueListenable: settings.themeMode,
//       builder: (_, mode, __) => ValueListenableBuilder<String>(
//         valueListenable: settings.language,
//         builder: (_, lang, __) => MaterialApp(
//           title: 'Financial Calculator',
//           debugShowCheckedModeBanner: false,
//           themeMode: mode,

//           // Locale
//           locale: AppSettings.localeMap[lang],
//           supportedLocales: AppSettings.localeMap.values.toList(),
//           localizationsDelegates: const [
//             GlobalMaterialLocalizations.delegate,
//             GlobalWidgetsLocalizations.delegate,
//             GlobalCupertinoLocalizations.delegate,
//           ],

//           theme: AppTheme.lightTheme,
//           darkTheme: AppTheme.darkTheme,
//           home: const HomeScreen(),
//         ),
//       ),
//     );
//   }
// }






import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'screens/home_screen.dart';
import 'utils/app_settings.dart';
import 'utils/app_theme.dart';
import 'firebase_options.dart';

Future<void> main() async {
  // Required for Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Send all Flutter errors to Crashlytics
  FlutterError.onError =
      FirebaseCrashlytics.instance.recordFlutterFatalError;

  runApp(const FinCalcApp());
}

class FinCalcApp extends StatelessWidget {
  const FinCalcApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = AppSettings.instance;
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: settings.themeMode,
      builder: (_, mode, __) => ValueListenableBuilder<String>(
        valueListenable: settings.language,
        builder: (_, lang, __) => MaterialApp(
          title: 'Financial Calculator',
          debugShowCheckedModeBanner: false,
          themeMode: mode,

          // Locale
          locale: AppSettings.localeMap[lang],
          supportedLocales: AppSettings.localeMap.values.toList(),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: const HomeScreen(),
        ),
      ),
    );
  }
}