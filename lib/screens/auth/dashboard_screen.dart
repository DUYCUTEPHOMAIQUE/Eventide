// ignore_for_file: prefer_const_constructors

import 'dart:ui';

import 'package:enva/blocs/auth/auth_bloc.dart';
import 'package:enva/blocs/auth/auth_event.dart';
import 'package:enva/blocs/auth/auth_state.dart';
import 'package:enva/screens/auth/widgets/toogle_language_button.dart';
import 'package:enva/screens/auth/widgets/widgets.dart';
import 'package:enva/services/services.dart';
import 'package:enva/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rive/rive.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  void _showAuthSheet(BuildContext context) {
    final TextEditingController _nameController = TextEditingController();
    final TextEditingController _emailController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController();
    showModalBottomSheet(
      context: context,
      showDragHandle: true, // Hiển thị drag handle

      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Welcome',
                style: TextStyle(
                  fontFamily: 'Aldrich',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    buildTextField(
                        label: 'EMAIL', controller: _emailController),
                    const SizedBox(height: 16),
                    buildTextField(
                        label: 'PASSWORD', controller: _passwordController),
                    const SizedBox(height: 16),
                    buildAuthButton(context, 'SIGN IN', Colors.black, () {
                      context.read<AuthBloc>().add(
                            EmailSignInRequested(
                              _emailController.text.trim(),
                              _passwordController.text.trim(),
                            ),
                          );
                    }),
                    const SizedBox(height: 16),
                    Text('You don' 't have an account?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 14,
                        )),
                    Text('Or',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        )),
                    Text('Forgot password',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                        )),
                    const SizedBox(height: 16),
                    buildAuthButton(
                        context, 'SIGN IN WITH GOOGLE', Colors.black, () {
                      context.read<AuthBloc>().add(GoogleSignInRequested());
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            Navigator.pop(context); // Đóng BottomSheet khi đăng nhập thành công
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: const SizedBox(),
                ),
              ),
              SafeArea(
                child: Stack(
                  children: [
                    // Theme Toggle Button positioned at top-right
                    Positioned(
                      top: 20,
                      right: 90,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ToggleLanguageButton(),
                      ),
                    ),
                    Positioned(
                      top: 20,
                      right: 20,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const ThemeToggleButton(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 24, left: 8),
                      child: Text(
                        'Title',
                        style: TextStyle(
                          fontFamily: 'Aldrich',
                          color: Theme.of(context).textTheme.bodyLarge!.color,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          const Spacer(),
                          const SizedBox(height: 40),
                          AnimatedAuthButton(
                              text: 'Let\'s make your invites',
                              onPressed: () {
                                _showAuthSheet(context);
                              },
                              color: Colors.white),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (state is AuthLoading) const LoadingOverlay(),
            ],
          );
        },
      ),
    );
  }
}
