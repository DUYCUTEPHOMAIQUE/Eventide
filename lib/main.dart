import 'package:enva/blocs/blocs.dart';
import 'package:enva/models/models.dart';
import 'package:enva/screens/screens.dart';
import 'package:enva/theme/minimalist_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'services/auth_listener_service.dart';
import 'services/fcm_service.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    debug: true,
  );
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Hive.initFlutter();
  Hive.registerAdapter(CardModelAdapter());
  await Hive.openBox<CardModel>('cards');

  // Initialize AuthListenerService to handle automatic profile creation
  AuthListenerService.initialize();

  // Initialize FCM Service for push notifications (async, non-blocking)
  _initializeFCMAsync();

  runApp(const EnvaApp());
}

// Initialize FCM asynchronously without blocking app startup
void _initializeFCMAsync() async {
  try {
    print('Starting FCM initialization...');
    await FCMService().initialize();
    print('FCM initialization completed successfully');
  } catch (e) {
    print('FCM initialization failed: $e');
    // Don't crash the app if FCM fails to initialize
  }
}

class EnvaApp extends StatelessWidget {
  const EnvaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc()),
        BlocProvider(create: (_) => ThemeCubit()..loadThemePreference()),
      ],
      child: Builder(
        builder: (context) {
          final themeMode = context.watch<ThemeCubit>().state;

          return MaterialApp(
            title: 'Enva',
            debugShowCheckedModeBanner: false,

            theme: MinimalistTheme.lightTheme,
            darkTheme: MinimalistTheme.darkTheme,
            themeMode: themeMode, // Supports light/dark/system modes
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}
