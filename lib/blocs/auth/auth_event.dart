import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class EmailSignInRequested extends AuthEvent {
  final String email;
  final String password;

  const EmailSignInRequested(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

class EmailSignUpRequested extends AuthEvent {
  final String email;
  final String password;

  const EmailSignUpRequested(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

class GoogleSignInRequested extends AuthEvent {}

class VerifyOTPRequested extends AuthEvent {
  final String email;
  final String token;

  const VerifyOTPRequested(this.email, this.token);

  @override
  List<Object?> get props => [email, token];
}

class ResendOTPRequested extends AuthEvent {
  final String email;

  const ResendOTPRequested(this.email);

  @override
  List<Object?> get props => [email];
}

class SignOutRequested extends AuthEvent {}
