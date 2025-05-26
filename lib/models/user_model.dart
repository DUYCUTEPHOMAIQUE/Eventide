import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  const User(
      {required this.id,
      required this.name,
      required this.email,
      required this.avatarUrl});

  @override
  // TODO: implement props
  List<Object?> get props => <Object?>[
        id,
        name,
        email,
      ];
}
