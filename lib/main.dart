import 'package:enva/blocs/blocs.dart';
import 'package:enva/models/models.dart';
import 'package:enva/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:hive_flutter/hive_flutter.dart';

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
  Hive.registerAdapter(InviteModelAdapter());
  await Hive.openBox<CardModel>('cards');
  await Hive.openBox<InviteModel>('invites');
  runApp(const EnvaApp());
}

class EnvaApp extends StatelessWidget {
  const EnvaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc()),
        BlocProvider(create: (_) => ThemeCubit()..loadThemePreference()),
        BlocProvider(create: (_) => LocaleCubit()),
      ],
      child: Builder(
        builder: (context) {
          final themeMode = context.watch<ThemeCubit>().state;
          final locale = context.watch<LocaleCubit>().state.locale;
          return MaterialApp(
            title: 'Enva',
            debugShowCheckedModeBanner: false,
            locale: locale,

            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: themeMode, // Áp dụng ThemeMode từ ThemeCubit
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}
