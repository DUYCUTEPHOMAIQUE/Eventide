import 'package:enva/screens/home/enhanced_minimalist_home_screen.dart';
import 'package:enva/screens/auth/minimalist_dashboard_screen.dart';
import 'package:enva/screens/auth/complete_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:enva/screens/screens.dart';
import 'package:enva/services/auth_service.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final session = snapshot.data!.session;
          if (session != null) {
            // Lưu thông tin user khi đăng nhập thành công
            _saveUserInfo(session.user);

            // Kiểm tra xem user đã verify email chưa
            if (session.user.emailConfirmedAt != null) {
              // User đã verify email, kiểm tra profile
              final authService = AuthService();
              if (authService.isProfileComplete()) {
                return const EnhancedMinimalistHomeScreen();
              } else {
                // User chưa hoàn tất profile, chuyển đến màn hình hoàn tất
                return const CompleteProfileScreen();
              }
            } else {
              // User chưa verify email, quay về màn hình đăng nhập
              // Điều này sẽ xảy ra nếu user refresh app hoặc mở lại app
              // mà chưa verify email
              return const MinimalistDashboardScreen();
            }
          }
        }
        return const MinimalistDashboardScreen();
      },
    );
  }

  // Lưu thông tin user vào SharedPreferences
  void _saveUserInfo(User user) async {
    final authService = AuthService();
    await authService.saveUserToSharedPreferences(user);
  }
}
