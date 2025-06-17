import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final User user;

  const AuthSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthSignUpSuccess extends AuthState {
  final User user;

  const AuthSignUpSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthOTPVerified extends AuthState {
  final User user;

  const AuthOTPVerified(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthOTPResent extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
