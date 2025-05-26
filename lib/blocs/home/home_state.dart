import 'package:equatable/equatable.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeSuccess extends HomeState {}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}

class HomeLogout extends HomeState {}

class HomePrintUser extends HomeState {
  final String user;

  const HomePrintUser(this.user);

  @override
  List<Object?> get props => [user];
}

class HomePrintAvatar extends HomeState {
  final String avatarUrl;

  const HomePrintAvatar(this.avatarUrl);

  @override
  List<Object?> get props => [avatarUrl];
}

class HomePrintAvatarError extends HomeState {
  final String message;

  const HomePrintAvatarError(this.message);

  @override
  List<Object?> get props => [message];
}

class HomePrintAvatarLoading extends HomeState {}

class HomePrintAvatarSuccess extends HomeState {
  final String avatarUrl;

  const HomePrintAvatarSuccess(this.avatarUrl);

  @override
  List<Object?> get props => [avatarUrl];
}

class HomePrintAvatarEmpty extends HomeState {}
