import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  User? get currentUser => _supabase.auth.currentUser;

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Đăng ký với email - Supabase sẽ gửi OTP
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
      emailRedirectTo: null, // Không redirect, chỉ gửi OTP
    );
  }

  // Verify OTP từ email
  Future<AuthResponse> verifyOTP({
    required String email,
    required String token,
  }) async {
    return await _supabase.auth.verifyOTP(
      email: email,
      token: token,
      type: OtpType.signup,
    );
  }

  // Resend OTP
  Future<void> resendOTP({
    required String email,
  }) async {
    await _supabase.auth.resend(
      type: OtpType.signup,
      email: email,
    );
  }

  // Hoàn tất thông tin profile sau khi verify OTP
  Future<void> completeProfile({
    required String displayName,
    String? avatarUrl,
  }) async {
    final user = currentUser;
    if (user != null) {
      final userData = <String, dynamic>{
        'display_name': displayName,
      };

      if (avatarUrl != null && avatarUrl.isNotEmpty) {
        userData['avatar_url'] = avatarUrl;
      }

      await _supabase.auth.updateUser(
        UserAttributes(
          data: userData,
        ),
      );

      // Lưu vào SharedPreferences
      await _saveUserToSharedPreferences(user);
    }
  }

  // Cập nhật avatar
  Future<void> updateAvatar(String avatarUrl) async {
    final user = currentUser;
    if (user != null) {
      await _supabase.auth.updateUser(
        UserAttributes(
          data: {
            ...user.userMetadata ?? {},
            'avatar_url': avatarUrl,
          },
        ),
      );

      // Cập nhật SharedPreferences
      await _saveUserToSharedPreferences(user);
    }
  }

  // Cập nhật display name
  Future<void> updateDisplayName(String displayName) async {
    final user = currentUser;
    if (user != null) {
      await _supabase.auth.updateUser(
        UserAttributes(
          data: {
            ...user.userMetadata ?? {},
            'display_name': displayName,
          },
        ),
      );

      // Cập nhật SharedPreferences
      await _saveUserToSharedPreferences(user);
    }
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    // Lưu thông tin đăng nhập vào SharedPreferences
    if (response.user != null) {
      await _saveUserToSharedPreferences(response.user!);
    }

    return response;
  }

  Future<void> signOut() async {
    await _clearUserFromSharedPreferences();
    await _supabase.auth.signOut();
  }

  // Lưu thông tin user vào SharedPreferences
  Future<void> _saveUserToSharedPreferences(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', user.id);
    await prefs.setString('user_email', user.email ?? '');
    await prefs.setString(
        'user_display_name', user.userMetadata?['display_name'] ?? '');
    await prefs.setString(
        'user_avatar_url', user.userMetadata?['avatar_url'] ?? '');
    await prefs.setString('user_created_at', user.createdAt);
  }

  // Xóa thông tin user khỏi SharedPreferences
  Future<void> _clearUserFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('user_email');
    await prefs.remove('user_display_name');
    await prefs.remove('user_avatar_url');
    await prefs.remove('user_created_at');
  }

  // Lấy thông tin user từ SharedPreferences
  Future<Map<String, String?>> getUserFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'user_id': prefs.getString('user_id'),
      'user_email': prefs.getString('user_email'),
      'user_display_name': prefs.getString('user_display_name'),
      'user_avatar_url': prefs.getString('user_avatar_url'),
      'user_created_at': prefs.getString('user_created_at'),
    };
  }

  // Lấy avatar URL từ userMetadata
  String? getUserAvatarUrl() {
    final user = currentUser;
    if (user != null) {
      return user.userMetadata?['avatar_url'] as String?;
    }
    return null;
  }

  // Lấy display name từ userMetadata
  String? getUserDisplayName() {
    final user = currentUser;
    if (user != null) {
      return user.userMetadata?['display_name'] as String?;
    }
    return null;
  }

  // Public method để lưu user info
  Future<void> saveUserToSharedPreferences(User user) async {
    await _saveUserToSharedPreferences(user);
  }

  // Kiểm tra xem user đã hoàn tất profile chưa
  bool isProfileComplete() {
    final user = currentUser;
    if (user != null) {
      final displayName = user.userMetadata?['display_name'] as String?;
      // Only require display name, avatar is optional
      return displayName != null && displayName.isNotEmpty;
    }
    return false;
  }
}
