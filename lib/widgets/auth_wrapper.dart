import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:enva/screens/auth/minimalist_dashboard_screen.dart';
import 'package:enva/screens/home/enhanced_minimalist_home_screen.dart';
import 'package:enva/blocs/auth/auth_bloc.dart';
import 'package:enva/blocs/auth/auth_state.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (state is AuthSuccess) {
          return const EnhancedMinimalistHomeScreen();
        } else {
          return const MinimalistDashboardScreen();
        }
      },
    );
  }
}
