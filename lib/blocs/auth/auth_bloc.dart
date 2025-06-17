import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/supabase_services.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<EmailSignInRequested>(_onEmailSignInRequested);
    on<EmailSignUpRequested>(_onEmailSignUpRequested);
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<VerifyOTPRequested>(_onVerifyOTPRequested);
    on<ResendOTPRequested>(_onResendOTPRequested);
  }

  Future<void> _onEmailSignInRequested(
    EmailSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      print('AuthBloc: Starting email sign-in for ${event.email}');

      // Kiểm tra email có tồn tại không trước khi đăng nhập
      final emailExists = await SupabaseServices.checkEmailExists(event.email);
      if (!emailExists) {
        emit(const AuthError(
            'Email chưa được đăng ký. Vui lòng kiểm tra lại hoặc chuyển sang đăng ký tài khoản mới'));
        return;
      }

      final response = await SupabaseServices.signInWithEmailAndPassword(
        event.email,
        event.password,
      );
      if (response.user != null) {
        print(
            'AuthBloc: Email sign-in successful for user ${response.user!.id}');
        emit(AuthSuccess(response.user!));
      } else {
        print('AuthBloc: Email sign-in failed - no user returned');
        emit(const AuthError(
            'Đăng nhập thất bại. Vui lòng kiểm tra email và mật khẩu'));
      }
    } catch (e) {
      print('AuthBloc: Email sign-in error: $e');
      emit(AuthError(_getFriendlyErrorMessage(e.toString())));
    }
  }

  Future<void> _onEmailSignUpRequested(
    EmailSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      print('AuthBloc: Starting email sign-up for ${event.email}');

      // Kiểm tra email đã tồn tại chưa
      final emailExists = await SupabaseServices.checkEmailExists(event.email);
      if (emailExists) {
        emit(const AuthError(
            'Email đã được đăng ký. Vui lòng đăng nhập hoặc sử dụng email khác'));
        return;
      }

      // Validate mật khẩu mạnh
      if (!_isStrongPassword(event.password)) {
        emit(const AuthError(
            'Mật khẩu yêu cầu: ít nhất 6 ký tự, bao gồm 1 chữ hoa, 1 chữ thường và 1 số. Ví dụ: Password123'));
        return;
      }

      final response = await SupabaseServices.signUpWithEmail(
        event.email,
        event.password,
      );
      if (response.user != null) {
        print(
            'AuthBloc: Email sign-up successful for user ${response.user!.id}');
        // Đăng ký thành công, nhưng user chưa được confirm
        // Chuyển sang màn hình OTP verification
        emit(AuthSignUpSuccess(response.user!));
      } else {
        print('AuthBloc: Email sign-up failed - no user returned');
        emit(const AuthError('Đăng ký thất bại. Vui lòng thử lại'));
      }
    } catch (e) {
      print('AuthBloc: Email sign-up error: $e');
      emit(AuthError(_getFriendlyErrorMessage(e.toString())));
    }
  }

  Future<void> _onGoogleSignInRequested(
    GoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      print('AuthBloc: Starting Google sign-in');
      final response = await SupabaseServices.signInWithGoogle();
      if (response.session != null) {
        print(
            'AuthBloc: Google sign-in successful for user ${response.user!.id}');
        emit(AuthSuccess(response.user!));
      } else {
        print('AuthBloc: Google sign-in failed - no session returned');
        emit(const AuthError(
            'Đăng nhập Google thất bại. Vui lòng thử lại hoặc sử dụng đăng nhập email'));
      }
    } catch (e) {
      print('AuthBloc: Google sign-in error: $e');
      emit(AuthError(_getFriendlyErrorMessage(e.toString())));
    }
  }

  Future<void> _onVerifyOTPRequested(
    VerifyOTPRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      print('AuthBloc: Starting OTP verification for ${event.email}');
      final response = await SupabaseServices.verifyOTP(
        event.email,
        event.token,
      );
      if (response.user != null) {
        print(
            'AuthBloc: OTP verification successful for user ${response.user!.id}');
        // OTP verification thành công, user đã được confirm
        // Chuyển sang màn hình complete profile
        emit(AuthOTPVerified(response.user!));
      } else {
        print('AuthBloc: OTP verification failed - no user returned');
        emit(const AuthError(
            'Mã OTP không đúng hoặc đã hết hạn. Vui lòng kiểm tra lại mã 6 chữ số hoặc nhấn "Gửi lại mã"'));
      }
    } catch (e) {
      print('AuthBloc: OTP verification error: $e');
      emit(AuthError(_getFriendlyErrorMessage(e.toString())));
    }
  }

  Future<void> _onResendOTPRequested(
    ResendOTPRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      print('AuthBloc: Resending OTP to ${event.email}');
      await SupabaseServices.resendOTP(event.email);
      print('AuthBloc: OTP resent successfully');
      emit(AuthOTPResent());
    } catch (e) {
      print('AuthBloc: OTP resend error: $e');
      emit(AuthError(_getFriendlyErrorMessage(e.toString())));
    }
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      print('AuthBloc: Starting sign-out');
      await SupabaseServices.signOut();
      print('AuthBloc: Sign-out successful');
      emit(AuthInitial());
    } catch (e) {
      print('AuthBloc: Sign-out error: $e');
      emit(AuthError(_getFriendlyErrorMessage(e.toString())));
    }
  }

  // Kiểm tra mật khẩu mạnh
  bool _isStrongPassword(String password) {
    if (password.length < 6) return false;

    // Kiểm tra có ít nhất 1 chữ hoa, 1 chữ thường và 1 số
    bool hasUpperCase = RegExp(r'[A-Z]').hasMatch(password);
    bool hasLowerCase = RegExp(r'[a-z]').hasMatch(password);
    bool hasDigit = RegExp(r'\d').hasMatch(password);

    return hasUpperCase && hasLowerCase && hasDigit;
  }

  // Chuyển đổi lỗi kỹ thuật thành thông báo thân thiện
  String _getFriendlyErrorMessage(String errorMessage) {
    final lowerError = errorMessage.toLowerCase();

    // Lỗi mật khẩu
    if (lowerError.contains('password') || lowerError.contains('mật khẩu')) {
      if (lowerError.contains('weak') || lowerError.contains('yếu')) {
        return 'Mật khẩu yêu cầu: ít nhất 6 ký tự, bao gồm 1 chữ hoa, 1 chữ thường và 1 số. Ví dụ: Password123';
      }
      if (lowerError.contains('incorrect') || lowerError.contains('sai')) {
        return 'Mật khẩu không đúng. Vui lòng kiểm tra lại hoặc sử dụng "Quên mật khẩu"';
      }
      if (lowerError.contains('too short') || lowerError.contains('ngắn')) {
        return 'Mật khẩu quá ngắn. Yêu cầu ít nhất 6 ký tự';
      }
      return 'Mật khẩu không hợp lệ. Vui lòng kiểm tra lại';
    }

    // Lỗi email
    if (lowerError.contains('email')) {
      if (lowerError.contains('invalid') ||
          lowerError.contains('không hợp lệ')) {
        return 'Email không hợp lệ. Vui lòng nhập đúng định dạng email. Ví dụ: example@gmail.com';
      }
      if (lowerError.contains('not found') ||
          lowerError.contains('không tìm thấy')) {
        return 'Email chưa được đăng ký. Vui lòng kiểm tra lại hoặc chuyển sang đăng ký tài khoản mới';
      }
      if (lowerError.contains('already exists') ||
          lowerError.contains('đã tồn tại')) {
        return 'Email đã được đăng ký. Vui lòng đăng nhập hoặc sử dụng email khác';
      }
      if (lowerError.contains('not confirmed') ||
          lowerError.contains('chưa xác thực')) {
        return 'Email chưa được xác thực. Vui lòng kiểm tra email và nhấp vào link xác thực';
      }
      return 'Lỗi email. Vui lòng kiểm tra lại định dạng email';
    }

    // Lỗi mạng
    if (lowerError.contains('network') ||
        lowerError.contains('connection') ||
        lowerError.contains('timeout')) {
      return 'Lỗi kết nối mạng. Vui lòng kiểm tra kết nối internet và thử lại';
    }

    // Lỗi server
    if (lowerError.contains('server') ||
        lowerError.contains('500') ||
        lowerError.contains('503')) {
      return 'Lỗi hệ thống. Vui lòng thử lại sau vài phút';
    }

    // Lỗi xác thực
    if (lowerError.contains('auth') || lowerError.contains('authentication')) {
      return 'Lỗi xác thực. Vui lòng đăng nhập lại';
    }

    // Lỗi OTP
    if (lowerError.contains('otp') || lowerError.contains('token')) {
      if (lowerError.contains('invalid') || lowerError.contains('không đúng')) {
        return 'Mã OTP không đúng. Vui lòng kiểm tra lại mã 6 chữ số';
      }
      if (lowerError.contains('expired') || lowerError.contains('hết hạn')) {
        return 'Mã OTP đã hết hạn. Vui lòng nhấn "Gửi lại mã" để nhận mã mới';
      }
      return 'Lỗi xác thực OTP. Vui lòng thử lại';
    }

    // Lỗi Google Sign In
    if (lowerError.contains('google')) {
      if (lowerError.contains('cancelled')) {
        return 'Đăng nhập Google bị hủy. Vui lòng thử lại';
      }
      return 'Lỗi đăng nhập Google. Vui lòng thử lại hoặc sử dụng đăng nhập email';
    }

    // Lỗi mặc định - hiển thị lỗi gốc nếu không nhận diện được
    return 'Lỗi: $errorMessage. Vui lòng thử lại';
  }
}
