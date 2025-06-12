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
        emit(const AuthError('Sign in failed'));
      }
    } catch (e) {
      print('AuthBloc: Email sign-in error: $e');
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onEmailSignUpRequested(
    EmailSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      print('AuthBloc: Starting email sign-up for ${event.email}');
      final response = await SupabaseServices.signUpWithEmail(
        event.email,
        event.password,
      );
      if (response.user != null) {
        print(
            'AuthBloc: Email sign-up successful for user ${response.user!.id}');
        // Đăng ký thành công, nhưng user chưa được confirm
        emit(AuthSignUpSuccess(response.user!));
      } else {
        print('AuthBloc: Email sign-up failed - no user returned');
        emit(const AuthError('Sign up failed'));
      }
    } catch (e) {
      print('AuthBloc: Email sign-up error: $e');
      emit(AuthError(e.toString()));
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
        emit(const AuthError('Google sign in failed'));
      }
    } catch (e) {
      print('AuthBloc: Google sign-in error: $e');
      emit(AuthError(e.toString()));
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
        emit(AuthSuccess(response.user!));
      } else {
        print('AuthBloc: OTP verification failed - no user returned');
        emit(const AuthError('OTP verification failed'));
      }
    } catch (e) {
      print('AuthBloc: OTP verification error: $e');
      emit(AuthError(e.toString()));
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
      emit(AuthError(e.toString()));
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
      emit(AuthError(e.toString()));
    }
  }
}
